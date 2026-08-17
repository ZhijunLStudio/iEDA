import sys,json,subprocess,shutil,re
from pathlib import Path
d=sys.argv[1]; case=sys.argv[2]; input_def=sys.argv[3]; cfg=sys.argv[4]; lef=sys.argv[5]
root=Path('/tmp/gp_local_restart')/d; shutil.rmtree(root,ignore_errors=True); root.mkdir(parents=True)
def run(*args):
 r=subprocess.run([sys.executable,'benchmarks/flows/gp_agent.py',*args],cwd='/home/lizhijun/work/iEDA.ai',stdout=subprocess.PIPE,stderr=subprocess.DEVNULL,text=True)
 try: return json.loads(r.stdout) if r.stdout.strip() else {}
 except Exception: return {'ok':False,'raw':r.stdout[-300:]}
parent=f'/tmp/gp_agent_search/{d}/parent_400.json'
cand_dir=root/'cand'; cand_dir.mkdir()
cand=run('candidate','--workdir',str(cand_dir),'--case-root',case,'--input-def',input_def,'--config',cfg,'--checkpoint',parent,'--iterations','20','--scope','longnet','--scope-active-count','100','--halo-hops','2','--overflow-penalty','0.005')
verdict=(cand.get('candidate') or {}).get('candidate_verdict')
chosen=(cand.get('candidate') or {}).get('candidate_local_checkpoint') if verdict=='left_better' else (cand.get('candidate') or {}).get('candidate_global_checkpoint')
if not chosen or not Path(chosen).exists():
 chosen=parent; verdict='parent_fallback'
# accept chosen to get placement.def
acc_dir=root/'acc'; acc_dir.mkdir()
run('restore','--workdir',str(acc_dir),'--case-root',case,'--input-def',input_def,'--config',cfg,'--checkpoint',chosen)
run('accept','--workdir',str(acc_dir),'--case-root',case,'--input-def',input_def,'--config',cfg,'--checkpoint',chosen)
local_place=acc_dir/'placement.def'
assert local_place.exists(), 'no chosen placement'
# local restart
lr=root/'local_restart'; lr.mkdir()
run('start','--workdir',str(lr),'--case-root',case,'--input-def',str(local_place),'--config',cfg,'--iterations','600','--seed','42','--random-init','0','--report-route-util','1')
# baseline restart from direct converged def
direct_place=f'/tmp/p0_converged/{d}/placement.def'
br=root/'baseline_restart'; br.mkdir()
if Path(direct_place).exists():
 run('start','--workdir',str(br),'--case-root',case,'--input-def',direct_place,'--config',cfg,'--iterations','600','--seed','42','--random-init','0','--report-route-util','1')
def hpwl(p):
 if not Path(p).exists(): return None
 r=subprocess.run(['python3','benchmarks/flows/def_hpwl_eval.py',lef,str(p)],cwd='/home/lizhijun/work/iEDA.ai',stdout=subprocess.PIPE,text=True)
 m=re.search(r'HPWL=(\d+)',r.stdout); return int(m.group(1)) if m else None
out={'design':d,'verdict':verdict,'chosen':chosen,'local_restart_hpwl':hpwl(lr/'placement.def'),'baseline_restart_hpwl':hpwl(br/'placement.def'),'local_place':str(local_place)}
(root/'result.json').write_text(json.dumps(out,indent=2))
print(json.dumps(out))
