"""Run prepared, frozen policy episodes with at most4 workers and full audits."""
import argparse,concurrent.futures,json,os,signal,subprocess,time,queue as std_queue
from pathlib import Path
from common import ROOT,load,save,desc
NATIVE_CORE_SLOTS=None

def cleanup_episode(path):
    signaled=[]
    for record in path.rglob('native-started.json'):
        identity=load(record).get('identity')
        if not identity:continue
        try:
            text=Path('/proc',str(identity['pid']),'stat').read_text();fields=text[text.rfind(')')+2:].split()
            if int(fields[19])==identity['start_ticks']and fields[0]!='Z':
                os.killpg(identity['pgid'],signal.SIGTERM);signaled.append(identity)
        except (OSError,ValueError,IndexError):pass
    return signaled

def worker(entry,agent):
    core=NATIVE_CORE_SLOTS.get()if NATIVE_CORE_SLOTS is not None else None
    try:return execute_worker(entry,agent,core)
    finally:
        if core is not None:NATIVE_CORE_SLOTS.put(core)

def execute_worker(entry,agent,core=None):
    identifier=entry['id'];root=ROOT/'episodes'/identifier
    if root.exists():raise RuntimeError('attempt already exists; review it, do not silently reuse/retry '+identifier)
    logs=ROOT/'cohort-logs';logs.mkdir(exist_ok=True);env=os.environ.copy();env.update(PYTHONHASHSEED='42',OMP_NUM_THREADS='1',OPENBLAS_NUM_THREADS='1',MKL_NUM_THREADS='1',IEDA_STUDY_ROOT=str(ROOT))
    if core is not None:env['IEDA_NATIVE_CPU']=str(core)
    log=logs/(identifier+'.log');started=time.monotonic()
    if agent:
        with (logs/(identifier+'-prepare.log')).open('xb')as out:
            proc=subprocess.run(['/usr/bin/python3',str(ROOT/'prepare_episode.py'),'--id',identifier,'--design',entry['design'],'--model',load(ROOT/'paired-plan.json')['model']],cwd=ROOT,env=env,stdout=out,stderr=subprocess.STDOUT)
        if proc.returncode:
            result={'id':identifier,'ok':False,'stage':'prepare','exit_code':proc.returncode,'wall_s':time.monotonic()-started,'log':desc(logs/(identifier+'-prepare.log'))}
            save(ROOT/'attempt-receipts'/(identifier+'.json'),result)
            return result
    budget=load(ROOT/'paired-plan.json')['arms'][entry['arm']]['budget']
    command=['/usr/bin/python3',str(ROOT/('episode_runner.py'if agent else'policy_controller.py')),'--id',identifier]
    timed_out=False
    with log.open('xb')as out:
        proc=subprocess.Popen(command,cwd=ROOT,env=env,stdout=out,stderr=subprocess.STDOUT,start_new_session=True)
        try:proc.wait(timeout=budget['wall_seconds']+15)
        except subprocess.TimeoutExpired:
            timed_out=True;os.killpg(proc.pid,signal.SIGTERM)
            try:proc.wait(timeout=3)
            except subprocess.TimeoutExpired:os.killpg(proc.pid,signal.SIGKILL);proc.wait(timeout=3)
    emergency=cleanup_episode(root)
    path=root/'result.json';value=load(path)if path.exists()else{}
    result={'id':identifier,'ok':bool(value.get('ok'))and not timed_out and not emergency,'native_cpu':core,'exit_code':proc.returncode,'timed_out':timed_out,'cleanup_signals':emergency,'wall_s':time.monotonic()-started,'result':desc(path)if path.exists()else None}
    # Every actual delivery is freshly remeasured, including failed episodes
    # that left a delivery. No audit feeds back into candidate selection.
    if value.get('delivery'):
        with (logs/(identifier+'-audit.log')).open('xb')as out:
            audit=subprocess.run(['/usr/bin/python3',str(ROOT/'audit_cohort.py'),'--id',identifier],cwd=ROOT,env=env,stdout=out,stderr=subprocess.STDOUT,timeout=900)
        auditpath=ROOT/'audits'/identifier/'result.json';a=load(auditpath)if auditpath.exists()else{}
        result.update(audit_ok=bool(a.get('ok')),audit=desc(auditpath)if auditpath.exists()else None)
        result['ok']=result['ok']and result['audit_ok']
    save(ROOT/'attempt-receipts'/(identifier+'.json'),result)
    return result

def main():
    global NATIVE_CORE_SLOTS
    p=argparse.ArgumentParser();p.add_argument('--workers',type=int,default=4);p.add_argument('--ids',nargs='*');a=p.parse_args()
    if not 1<=a.workers<=4:raise ValueError('workers must be1..4')
    cores=sorted(os.sched_getaffinity(0))[:a.workers]
    if len(cores)<a.workers:raise ValueError('insufficient distinct logical CPUs for requested workers')
    NATIVE_CORE_SLOTS=std_queue.Queue()
    for core in cores:NATIVE_CORE_SLOTS.put(core)
    plan=load(ROOT/'paired-plan.json');jobs=[(e,False)for e in plan['rule']]+[(e,True)for e in plan['agent']]
    if plan.get('execution_order'):
        order=plan['execution_order'];mapping={e['id']:(e,agent)for e,agent in jobs}
        if len(order)!=len(mapping)or set(order)!=set(mapping):raise ValueError('execution order must contain every episode exactly once')
        jobs=[mapping[identifier]for identifier in order]
    if a.ids:
        jobs=[v for v in jobs if v[0]['id']in a.ids]
        if len(jobs)!=len(a.ids):raise ValueError('unknown/duplicate episode IDs')
    if not jobs:raise ValueError('no matching episodes')
    runpath=ROOT/'cohort-runs'/str(time.time_ns());runpath.mkdir(parents=True,exist_ok=False)
    started={'plan':desc(ROOT/'paired-plan.json'),'jobs':[e['id']for e,_ in jobs],'workers':a.workers,'native_cores':cores,'started_unix':time.time()}
    save(runpath/'started.json',started);save(ROOT/'cohort-started.json',started)
    result={}
    with concurrent.futures.ThreadPoolExecutor(max_workers=a.workers)as pool:
        futures={pool.submit(worker,e,agent):e['id']for e,agent in jobs}
        for future in concurrent.futures.as_completed(futures):
            identifier=futures[future]
            try:row=future.result()
            except BaseException as exc:row={'id':identifier,'ok':False,'error':type(exc).__name__+': '+str(exc)}
            result[identifier]=row;progress={'completed':len(result),'total':len(jobs),'results':result};save(runpath/'progress.json',progress);save(ROOT/'cohort-progress.json',progress);print(json.dumps(row),flush=True)
    final={'ok':all(v['ok']for v in result.values()),'completed':len(result),'total':len(jobs),'results':result}
    save(runpath/'result.json',final);save(ROOT/'cohort-result.json',final)
if __name__=='__main__':main()
