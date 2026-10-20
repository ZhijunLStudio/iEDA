#!/usr/bin/env python3
"""Real headless DSH controller plus owned placement actor, under one deadline."""
import argparse
import hashlib
import http.client
import http.server
import importlib.util
import json
import os
from pathlib import Path
import re
import resource
import shutil
import signal
import subprocess
import threading
import time
from urllib.parse import urlsplit
import yaml
from common import ROOT, SUITE, desc, load, save, sha

SUPERVISION = Path(__file__).with_name('process_supervisor.py')
SPEC = importlib.util.spec_from_file_location('owned_supervision', SUPERVISION)
supervisor = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(supervisor)
ALLOWED_TOOLS = {'pl_observe','pl_start','pl_advance','pl_restore','pl_legalize','pl_refine','pl_evaluate','pl_finish'}


def configured_provider(config_path, plan):
    """Require the existing DSH profile to match the explicitly frozen endpoint."""
    providers=[row['config'] for row in yaml.load(Path(config_path).read_text(),Loader=yaml.BaseLoader)
               if row.get('id')=='llm-deepseek']
    if len(providers)!=1:
        raise ValueError('exactly one llm-deepseek provider must be configured')
    expected=plan.get('gateway_base_url')
    if not isinstance(expected,str) or not expected:
        raise ValueError('freeze gateway_base_url in paired-plan.json before running model episodes')
    endpoint=urlsplit(expected.rstrip('/'))
    if (endpoint.scheme not in ('http','https') or not endpoint.hostname
            or endpoint.username or endpoint.password or endpoint.query or endpoint.fragment
            or endpoint.path!='/v1'):
        raise ValueError('gateway_base_url must be an HTTP(S) /v1 URL without embedded credentials')
    if providers[0].get('baseURL','').rstrip('/')!=expected.rstrip('/'):
        raise ValueError('configured gateway differs from the frozen plan')
    return providers[0]


def gateway_connection(provider, timeout):
    endpoint=urlsplit(provider['baseURL'])
    factory=http.client.HTTPSConnection if endpoint.scheme=='https' else http.client.HTTPConnection
    return factory(endpoint.hostname,endpoint.port,timeout=timeout)


def run(identifier):
    from study_contract import verify_study
    verify_study()
    preparation_started = time.monotonic()
    root = ROOT/'episodes'/identifier
    prep = load(root/'preparation.json')
    if (root/'episode-started.json').exists():
        raise RuntimeError('episode already attempted; use a new version/ID')
    assert sha(SUITE) == prep['suite']['sha256']
    assert sha(root/'prompt.txt') == prep['prompt']['sha256']
    for item in prep['sources']+prep['plugin_sources']:
        assert sha(item['path']) == item['sha256'], item['path']
    snapshots = root/'execution-source'
    snapshots.mkdir()
    for name in ('study_contract.py','policy_menu.py','legacy_backend.py','evaluation_cache.py','work_budget.py','common.py','process_supervisor.py','native_session.py','pl_backend.py','episode_runner.py','surplus.py','physical_observation.py','legal_refinement.py','rudy_direct.py','rudy_adapter.py'):
        shutil.copy2(ROOT/name,snapshots/name)
    source_cfg=Path.home()/'.dsh/profiles/headless/cordis.patch.yml'
    source_sha=sha(source_cfg)
    # Official Minimal composition can contain !!js platform expressions. Read
    # only provider strings without constructing or executing those expressions.
    provider=configured_provider(source_cfg,load(ROOT/'paired-plan.json'))
    reference=provider.get('apiKeyEnv','DEEPSEEK_API_KEY')
    credential=os.environ.get(reference)
    if not credential:
        credential=yaml.safe_load((Path.home()/'.dsh/.credentials.yaml').read_text()).get('refs',{}).get(reference)
    if not isinstance(credential,str) or not credential:
        raise RuntimeError('existing configured gateway credential unavailable')
    def scrub(value):
        if isinstance(value,str):
            return value.replace(credential,'[REDACTED]')
        if isinstance(value,list):return [scrub(x) for x in value]
        if isinstance(value,dict):return {k:('[REDACTED]' if re.search('authorization|api.?key|secret',str(k),re.I) else scrub(x)) for k,x in value.items()}
        return value
    trace=root/'traces';trace.mkdir()
    lock=threading.Lock();events=[];requests=[]
    def append(path,value):
        with lock:
            with path.open('a') as f:f.write(json.dumps(scrub(value),ensure_ascii=False)+'\n')
    clock={'started':None,'deadline':None}
    def remaining():return max(.01,clock['deadline']-time.monotonic())
    class Relay(http.server.BaseHTTPRequestHandler):
        def log_message(self,*args):pass
        def do_POST(self):
            body=self.rfile.read(int(self.headers.get('Content-Length','0')))
            try:payload=json.loads(body)
            except ValueError:self.send_error(400,'invalid JSON');return
            with lock:
                index=len(requests)+1
                row={'index':index,'elapsed_s':time.monotonic()-clock['started'],'path':self.path,
                     'model':payload.get('model'),'max_tokens':payload.get('max_tokens'),
                     'thinking':payload.get('thinking'),'output_config':payload.get('output_config'),
                     'request_bytes':len(body),'tool_names':[t.get('name') for t in payload.get('tools',[])],
                     'prior_tool_results':sum(1 for m in payload.get('messages',[]) for b in m.get('content',[]) if isinstance(b,dict) and b.get('type')=='tool_result')}
                requests.append(row)
            catalog=payload.get('tools',[])
            encoded=json.dumps(catalog,sort_keys=True,separators=(',',':')).encode()
            catalog_sha=hashlib.sha256(encoded).hexdigest()
            row['tool_schema_sha256']=catalog_sha
            def arrays_valid(schema):
                if isinstance(schema,list):return all(arrays_valid(v)for v in schema)
                if not isinstance(schema,dict):return True
                if schema.get('type')=='object'and not isinstance(schema.get('required'),list):return False
                if any(k in schema and not isinstance(schema[k],list)for k in('required','enum','oneOf','anyOf','allOf')):return False
                return all(arrays_valid(v)for v in schema.values())
            row['wire_tool_schemas_valid']=bool(catalog)and all(isinstance(t.get('input_schema',{}).get('required'),list)and t['input_schema']['required']and arrays_valid(t['input_schema'])for t in catalog)
            row['tool_change_references']=[{'type':block['type'],'tool':block.get('tool')}for message in payload.get('messages',[])for block in message.get('content',[])if isinstance(block,dict)and block.get('type')in('tool_addition','tool_removal')]
            catalog_path=trace/'tool-catalogs'/(catalog_sha+'.json')
            if not catalog_path.exists():save(catalog_path,{'sha256':catalog_sha,'tools':catalog})
            if index>prep['budget']['model_requests'] or row['model']!=prep['model'] or self.path!='/v1/messages' or set(row['tool_names'])!=ALLOWED_TOOLS or row['output_config']!={'effort':prep['effort']}or not row['wire_tool_schemas_valid']:
                row['blocked_before_gateway']=True;append(trace/'requests.jsonl',row)
                self.send_error(400,'episode model/tool-schema/request-cap mismatch');return
            if index==1 and prep.get('test_controls',{}).get('first_request_503'):
                if prep.get('study_phase')!='technical':raise RuntimeError('fault injection outside technical check')
                row.update(http_status=503,technical_injected_fault=True,forwarded_to_gateway=False)
                append(trace/'requests.jsonl',row)
                data=json.dumps({'type':'error','error':{'type':'overloaded_error','message':'Intentional local technical resume check; not a gateway outage'}}).encode()
                self.send_response(503);self.send_header('Content-Type','application/json');self.send_header('Content-Length',str(len(data)));self.end_headers();self.wfile.write(data);return
            row['forwarded_to_gateway']=True
            conn=gateway_connection(provider,min(180,remaining()))
            headers={k:v for k,v in self.headers.items() if k.lower() not in ('host','content-length','connection')}
            try:
                conn.request('POST','/v1/messages',body=body,headers=headers)
                response=conn.getresponse();row['http_status']=response.status
                if response.status>=400:
                    data=response.read(65536)
                    try:
                        error=json.loads(data).get('error',{})
                        row['gateway_error']={k:error.get(k)for k in('type','code','message','request_id')}
                    except (ValueError,AttributeError):row['gateway_error']={'body_bytes_recorded':len(data),'non_JSON':True}
                    self.send_response(response.status);self.send_header('Content-Type','application/json');self.send_header('Connection','close');self.end_headers();self.wfile.write(data);self.wfile.flush()
                    return
                self.send_response(response.status)
                self.send_header('Content-Type',response.getheader('Content-Type','application/json'))
                self.send_header('Connection','close');self.end_headers()
                buffer=b'';usage=[]
                while time.monotonic()<clock['deadline']:
                    chunk=response.read1(65536)
                    if not chunk:break
                    self.wfile.write(chunk);self.wfile.flush();buffer+=chunk
                    while b'\n' in buffer:
                        line,buffer=buffer.split(b'\n',1)
                        if not line.startswith(b'data: '):continue
                        try:value=json.loads(line[6:])
                        except ValueError:continue
                        if value.get('type')=='message_start':
                            usage.append(value.get('message',{}).get('usage',{}))
                            row.setdefault('response_models',[]).append(value.get('message',{}).get('model'))
                        elif value.get('type')=='message_delta' and value.get('usage'):usage.append(value['usage'])
                row['usage_events']=usage
            except Exception as exc:row['transport_error_class']=type(exc).__name__
            finally:
                conn.close();row['wall_s']=time.monotonic()-clock['started']-row['elapsed_s'];append(trace/'requests.jsonl',row)
    server=http.server.ThreadingHTTPServer(('127.0.0.1',0),Relay);server.daemon_threads=True
    threading.Thread(target=server.serve_forever,kwargs={'poll_interval':.1},daemon=True).start()
    profile=root/'dsh-home/profiles/research-pl/cordis.patch.yml'
    rows=yaml.safe_load(profile.read_text())
    next(x['config'] for x in rows if x['id']=='llm-deepseek')['baseURL']=f'http://127.0.0.1:{server.server_port}/v1'
    profile.write_text(yaml.safe_dump(rows,sort_keys=False))
    env=os.environ.copy();native_cpu_setting=env.get('IEDA_NATIVE_CPU')
    for k in tuple(env):
        if k.startswith(('IEDA_','GP_AGENT_')) or k in ('DSH_PROFILE','DEEPSEEK_BASE_URL'):env.pop(k)
    env.update(PYTHONHASHSEED='42',DSH_HOME=str(root/'dsh-home'),DSH_TELEMETRY_DISABLED='1',DSH_TOOLS_MODE='native',NO_COLOR='1',
               IEDA_STUDY_ROOT=str(ROOT),IEDA_EPISODE=str(root),IEDA_MICRO_BACKEND=str(snapshots/'pl_backend.py'),
               DEEPSEEK_API_KEY=credential,OMP_NUM_THREADS='1',OPENBLAS_NUM_THREADS='1',MKL_NUM_THREADS='1')
    env[reference]=credential
    if native_cpu_setting is not None:env['IEDA_NATIVE_CPU']=native_cpu_setting
    preparation_s=time.monotonic()-preparation_started
    supervisor.enable_subreaper()
    clock['started']=time.monotonic();clock['deadline']=clock['started']+prep['budget']['wall_seconds']
    save(root/'episode.json',{'design':prep['design'],'model':prep['model'],'variant':prep.get('variant','autonomous'),'budget':prep['budget'],
                           'deadline_unix':time.time()+prep['budget']['wall_seconds']})
    save(root/'episode-started.json',{'started_unix':time.time(),'preparation_wall_s':preparation_s,
        'preparation':desc(root/'preparation.json'),'source_snapshot':[desc(p) for p in snapshots.glob('*.py')],
        'source_gateway_config_sha256':source_sha,'supervisor':desc(SUPERVISION)})
    usage0=resource.getrusage(resource.RUSAGE_CHILDREN)
    backend_log=(root/'backend-console.log').open('wb')
    backend=subprocess.Popen(['/usr/bin/python3',str(snapshots/'pl_backend.py'),'serve','--episode',str(root)],
                             cwd=root,env=env,stdout=backend_log,stderr=subprocess.STDOUT,start_new_session=True)
    child=None;owned=supervisor.OwnedProcesses(root,backend.pid);error=None;timed_out=False;controller_turns=[]
    def read_stream(pipe,target,structured=False):
        for line in pipe:
            if structured:
                try:value=json.loads(line)
                except ValueError:value={'type':'unparsed','text':line[:2000]}
                if value.get('type')=='thinking':value={'type':'thinking_metadata','characters':len(json.dumps(value))}
                events.append(scrub(value));append(target,value)
            else:append(target,{'text':line.rstrip()[:4000]})
    try:
        ready_deadline=min(clock['deadline'],time.monotonic()+20)
        while not (root/'backend-ready.json').exists():
            owned.refresh()
            if backend.poll() is not None or time.monotonic()>ready_deadline:
                raise RuntimeError('placement domain actor failed to initialize')
            time.sleep(.05)
        session_id=None
        for turn_index in range(3):
            command=['/usr/bin/node',str(Path.home()/'.npm-global/bin/dsh'),'--profile','research-pl','--json']
            if session_id:command+=['--session-id',session_id]
            command+=['-']
            event_start=len(events);turn_started=time.monotonic()
            child=subprocess.Popen(command,cwd=root/'workspace',env=env,stdin=subprocess.PIPE,stdout=subprocess.PIPE,
                                   stderr=subprocess.PIPE,text=True,start_new_session=True)
            owned.refresh()
            readers=[threading.Thread(target=read_stream,args=(child.stdout,trace/'events.jsonl',True),daemon=True),
                     threading.Thread(target=read_stream,args=(child.stderr,trace/'diagnostics.jsonl'),daemon=True)]
            for t in readers:t.start()
            task=(root/'prompt.txt').read_text() if turn_index==0 else (
                'Continue the SAME placement optimization and live backend from your persisted session. '
                'The previous headless turn ended without a successful delivered result, or ended after a recorded transport/output interruption. '
                'The original wall deadline and every physical/action/API quota remain unchanged; nothing has been reset. '
                'Inspect state and remaining budget if necessary. Continue testing useful untried physical hypotheses while budget allows, '
                'or conclude when targets are close or measured evidence supports stopping. '
                'Use concise public decision notes. If you decide to stop, actually call pl_finish on your preferred measured qualified candidate. '
                'If a candidate has already been delivered, only confirm it. No automatic candidate selection or hidden fallback is performed.')
            child.stdin.write(task);child.stdin.close()
            while child.poll() is None:
                owned.refresh()
                if time.monotonic()>clock['deadline']:
                    timed_out=True;break
                time.sleep(.1)
            for t in readers:t.join(timeout=1)
            interval=events[event_start:]
            sessions=[e['sessionId']for e in interval if e.get('type')=='session']
            if sessions:
                if session_id and sessions[-1]!=session_id:raise RuntimeError('continuation changed persisted session identity')
                session_id=sessions[-1]
            endings=[e for e in interval if e.get('type')=='status'and e.get('phase')=='turn_end']
            reason=endings[-1].get('reason',{}).get('kind')if endings else None
            delivered=(root/'delivery.json').exists()
            controller_turns.append({'index':turn_index,'session_id':session_id,'returncode':child.returncode,
                'reason':reason,'wall_s':time.monotonic()-turn_started,'delivery_exists':delivered,'remaining_wall_s':remaining(),
                'same_original_deadline':True,'no_budget_reset':True})
            save(root/'controller-turns.json',controller_turns)
            if timed_out or (child.returncode==0 and reason=='completed'and delivered):break
            # A failed gateway request remains recorded. Resumption is a new
            # model turn in the SAME persisted session and SAME physical actor.
            # It neither regenerates tool results nor chooses a final candidate.
            if not session_id or remaining()<30 or backend.poll()is not None or len(requests)>=prep['budget']['model_requests']:
                break
            if any(r.get('blocked_before_gateway')for r in requests):break
        if not timed_out:
            # The domain actor owns the native process; request its normal close.
            import socket
            try:
                with socket.socket(socket.AF_UNIX,socket.SOCK_STREAM) as conn:
                    conn.settimeout(1);conn.connect(str(root/'backend.sock'))
                    conn.sendall(b'{"op":"__close"}\n');conn.recv(65536)
            except OSError:pass
            try:backend.wait(timeout=2)
            except subprocess.TimeoutExpired:pass
        for t in readers:t.join(timeout=.2)
    except Exception as exc:error=type(exc).__name__+': '+str(exc)
    finally:
        owned.refresh()
        if owned.live():
            owned.signal_live(signal.SIGTERM)
            until=time.monotonic()+3
            while owned.live() and time.monotonic()<until:
                owned.refresh();owned.reap_adopted();time.sleep(.05)
            owned.signal_live(signal.SIGKILL)
        for process in (child,backend):
            if process:
                try:process.wait(timeout=2)
                except subprocess.TimeoutExpired:pass
        owned.refresh();owned.reap_adopted()
        backend_log.close();server.shutdown();server.server_close()
    usage1=resource.getrusage(resource.RUSAGE_CHILDREN)
    state=load(root/'backend-state.json') if (root/'backend-state.json').exists() else {}
    turns=[e for e in events if e.get('type')=='status' and e.get('phase')=='turn_end']
    completed=bool(turns and turns[-1].get('reason',{}).get('kind')=='completed')
    delivery=load(root/'delivery.json') if (root/'delivery.json').exists() else None
    wall=time.monotonic()-clock['started']
    checks={'dsh_exit_zero':bool(child and child.returncode==0),'turn_completed':completed,'actual_delivery':delivery is not None,
            'delivery_SHA_matches':bool(delivery and sha(root/'final.def')==delivery['def']['sha256']),
            'source_global_profile_unchanged':sha(source_cfg)==source_sha,'within_wall_cap':wall<=prep['budget']['wall_seconds'],
            'no_owned_survivors':not owned.live(),'model_and_tool_schema_valid':bool(requests) and all(not r.get('blocked_before_gateway') for r in requests),
            'wire_tool_schemas_valid':bool(requests)and all(r.get('wire_tool_schemas_valid')for r in requests),
            'owned_identity_audit_valid':not owned.ownership_errors and not owned.parse_errors,
            'bounded_same_session_continuations':bool(controller_turns)and len(controller_turns)<=3 and len({t['session_id']for t in controller_turns})==1,
            'gateway_faults_retained_within_policy':sum(bool(r.get('transport_error_class')or r.get('http_status')!=200)for r in requests)<=2,
            'model_tool_execution_visible':any(e.get('type')=='tool_call' for e in events)}
    work=state.get('work',{})
    frontend_calls=root/'frontend-calls.jsonl'
    frontend_count=len(frontend_calls.read_text().splitlines())if frontend_calls.exists()else 0
    tool_count=max(frontend_count,len({e.get('callId')for e in events if e.get('type')=='tool_call'}))
    checks.update(within_physical_CPU=work.get('physical_cpu_s',float('inf'))<=prep['budget']['physical_cpu_seconds'],within_actual_GP=state.get('actual_steps',0)+work.get('unobserved_GP_reserved_steps',0)<=prep['budget']['actual_gp_steps'],within_neighbor_trials=work.get('neighbor_trials_used',0)<=prep['budget']['neighbor_trials'],within_fresh_STA=work.get('fresh_sta_used',0)<=prep['budget']['fresh_sta'],within_starts=state.get('starts',0)<=prep['budget']['starts'],within_tool_calls=tool_count<=prep['budget']['tool_calls'],within_model_requests=len(requests)<=prep['budget']['model_requests'])
    finish_ids={e.get('callId')for e in events if e.get('type')=='tool_call'and e.get('tool')=='pl_finish'}
    def completed_finish(event):
        if event.get('type')!='tool_result' or event.get('callId')not in finish_ids or event.get('status')!='completed':return False
        try:v=json.loads(event.get('result','null'))
        except (ValueError,TypeError):return False
        return isinstance(v,dict)and v.get('ok')is True and v.get('finished')is True
    checks['model_saw_successful_finish']=any(completed_finish(e)for e in events)
    checks['no_DSH_invalid_output']=not any(e.get('type')=='tool_result'and e.get('status')=='error'and
        ('invalid output'in str(e.get('result'))or'lossless JSON'in str(e.get('result')))for e in events)
    result={'episode_id':identifier,'design':prep['design'],'model':prep['model'],'controller':prep['controller'],
            'ok':all(checks.values()),'checks':checks,'error':error,'timed_out':timed_out,'wall_s':wall,
            'preparation_wall_s':preparation_s,'tree_reaped_cpu_s':usage1.ru_utime+usage1.ru_stime-usage0.ru_utime-usage0.ru_stime,
            'DSH_returncode':child.returncode if child else None,'backend_returncode':backend.returncode,
            'work':work,'model_request_count':len(requests),'tool_call_count':tool_count,'backend_call_count':state.get('calls',0),'frontend_call_count':frontend_count,'tool_error_count':len(state.get('errors',[]))+sum(e.get('type')=='tool_result'and e.get('status')=='error'for e in events),
            'gateway_request_attempt_count':sum(r.get('forwarded_to_gateway',True)for r in requests),
            'technical_fault_injection_count':sum(bool(r.get('technical_injected_fault'))for r in requests),
            'starts':state.get('starts',0),'requested_gp_steps':state.get('requested_steps',0),'actual_gp_steps':state.get('actual_steps',0),
            'delivery':delivery,'turns':turns,'controller_turns':controller_turns,
            'all_gateway_attempts_succeeded':bool(requests)and all(r.get('http_status')==200 and not r.get('transport_error_class')for r in requests),
            'owned_processes':list(owned.known.values()),'owned_survivors':owned.live(),
            'cleanup_signals':owned.signals,'ownership_errors':owned.ownership_errors,'parse_errors':owned.parse_errors,
            'no_fallback_model':True,'no_transport_retry':True,'no_hidden_delivery_selection':True,
            'continuation_policy':'At most initial+2 resumed DSH turns, exact same persisted session/actor/deadline and all action/API caps; every failed turn/request/cost retained.'}
    save(root/'result.json',scrub(result))
    print(json.dumps({'id':identifier,'ok':result['ok'],'checks':checks,'metrics':delivery.get('metrics') if delivery else None,
                      'wall_s':wall,'API_requests':len(requests),'errors':result['tool_error_count'],'result':desc(root/'result.json')}),flush=True)


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--id',required=True);a=parser.parse_args();run(a.id)
