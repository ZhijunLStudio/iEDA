"""Ownership regressions and real orphan cleanup; no EDA or model calls."""
import importlib.util,json,os,signal,subprocess,sys,tempfile,time
from pathlib import Path
from unittest.mock import patch

source=Path(__file__).resolve().parents[1]/'runtime/process_supervisor.py'
if not source.exists():source=source.parent.parent/'process_supervisor.py'
spec=importlib.util.spec_from_file_location('bundled_supervisor',source)
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
checks={}
with tempfile.TemporaryDirectory(prefix='pl-owned-processes-')as temp:
    root=Path(temp);procfs=root/'proc';procfs.mkdir()
    def write(pid,ticks,ppid,pgid,sid,state='S'):
        p=procfs/str(pid);p.mkdir(exist_ok=True)
        fields=[state,str(ppid),str(pgid),str(sid)]+['0']*15+[str(ticks)]
        (p/'stat').write_text(str(pid)+' (fake worker) '+' '.join(fields))
    write(100,10,999,100,100);write(200,20,100,200,200);write(201,21,200,200,200)
    stage=root/'placement';stage.mkdir();(stage/'started.json').write_text('{"pid":')
    tracker=module.OwnedProcesses(root,100,owner_pid=999,procfs=procfs);tracker.refresh()
    checks['partial_publication_records_error_but_keeps_descendants']=bool(tracker.parse_errors)and {p['pid']for p in tracker.live()}=={100,200,201}
    (procfs/'200/stat').unlink();(procfs/'200').rmdir();write(201,21,999,200,200)
    (stage/'started.json').write_text(json.dumps({'pid':200,'initial_group':[{'pid':200,'start_ticks':20}]}))
    tracker.refresh();checks['leader_exit_and_adoption_preserve_ownership']=201 in {p['pid']for p in tracker.live()}
    write(200,9999,1,200,200);calls=[]
    with patch.object(module.os,'kill',side_effect=lambda pid,sig:calls.append((pid,int(sig)))):
        tracker.signal_live(signal.SIGTERM)
    checks['reused_PID_not_signaled']=all(pid!=200 for pid,sig in calls)and any(pid==201 for pid,sig in calls)

with tempfile.TemporaryDirectory(prefix='pl-real-orphan-')as temp:
    root=Path(temp);ready=root/'ready';module.enable_subreaper()
    child_code='import signal,time,pathlib;signal.signal(signal.SIGTERM,signal.SIG_IGN);pathlib.Path('+repr(str(ready))+').write_text("ready");time.sleep(60)'
    wrapper_code='import subprocess,sys,time,pathlib; p=subprocess.Popen([sys.executable,"-c",'+repr(child_code)+'],start_new_session=True,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL); deadline=time.monotonic()+5\nwhile not pathlib.Path('+repr(str(ready))+').exists() and time.monotonic()<deadline:time.sleep(.01)\nprint(p.pid,flush=True)'
    wrapper=subprocess.Popen([sys.executable,'-c',wrapper_code],stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
    tracker=module.OwnedProcesses(root,wrapper.pid)
    try:
        output,error=wrapper.communicate(timeout=8);assert wrapper.returncode==0,error
        child_pid=int(output.strip());tracker.refresh()
        checks['real_orphan_is_adopted_and_owned']=child_pid in {p['pid']for p in tracker.live()}
        tracker.signal_live(signal.SIGTERM);time.sleep(.1);tracker.refresh()
        checks['TERM_resistant_owned_child_remains_tracked']=child_pid in {p['pid']for p in tracker.live()}
        tracker.signal_live(signal.SIGKILL)
        deadline=time.monotonic()+3
        while time.monotonic()<deadline:
            tracker.reap_adopted();tracker.refresh()
            if not tracker.live()and not Path('/proc',str(child_pid)).exists():break
            time.sleep(.02)
        checks['KILL_reaps_owned_orphan_without_survivors']=not tracker.live()and not Path('/proc',str(child_pid)).exists()
        checks['real_cleanup_has_no_ownership_or_parse_errors']=not tracker.ownership_errors and not tracker.parse_errors
    finally:
        tracker.signal_live(signal.SIGKILL);tracker.reap_adopted()
        try:wrapper.wait(timeout=1)
        except subprocess.TimeoutExpired:wrapper.kill();wrapper.wait(timeout=1)
result={'ok':all(checks.values()),'checks':checks,'native_or_API_runs':0}
print(json.dumps(result),flush=True)
if not result['ok']:raise SystemExit(1)
