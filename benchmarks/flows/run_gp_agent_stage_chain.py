import sys,json,shlex,shutil,re
from pathlib import Path
sys.path.insert(0,'/home/lizhijun/work/iEDA.ai/benchmarks/flows')
from gp_agent import REPO_ROOT, write_tcl, run_ieda, PLV_CASES_ROOT
import subprocess

def main(design,scope,penalty,halo=2,coeff=0.5,active=100,ratio=0.2,start=20,stage_budget=20,stages=19,final_budget=200):
    case_root=Path('/home/lizhijun/work/iEDA/docs/ipl/pl_vis/cases')/design
    input_def=Path('/home/lizhijun/work/iEDA.ai/benchmarks/results/innovus_gp_compare')/design/'ieda_in_unplaced.def'
    config=Path('/home/lizhijun/work/iEDA.ai/benchmarks/results/innovus_gp_compare')/design/'pl_clean_config.json'
    foundry=REPO_ROOT/'scripts/foundry/sky130'
    work=Path('/tmp/gp_stage_chain')/design/f'{scope}_p{penalty}'
    shutil.rmtree(work,ignore_errors=True); work.mkdir(parents=True)
    cmds=[f'placer_run_gp -mode start -iterations {start} -seed 42 -report_route_util 1']
    for s in range(stages):
        sc=['-scope',scope,'-scope_halo_coeff',str(coeff),'-scope_halo_hops',str(halo)]
        if scope=='hotspot': sc += ['-scope_active_ratio',str(ratio)]
        if scope in ('random','longnet'): sc += ['-scope_active_count',str(active)]
        cmds.append(f'placer_run_gp -mode candidate -iterations {stage_budget} ' + ' '.join(sc) + f' -candidate_overflow_penalty {penalty}')
    cmds.append(f'placer_run_gp -mode advance -iterations {final_budget} -report_route_util 1')
    rc,out,err=run_ieda(work,case_root,foundry,config,input_def,cmds,def_save=True)
    # parse final gp line and ledger
    lines=[x for x in out.splitlines() if 'iPL gp.run' in x]
    ledger=work/'pl/gp_experiments.jsonl'
    last=None
    if ledger.exists():
        recs=[json.loads(x) for x in ledger.read_text().splitlines() if x.strip()]
        last=recs[-1] if recs else None
    hpwl=None
    if (work/'placement.def').exists():
        r=subprocess.run([sys.executable,str(Path('/home/lizhijun/work/iEDA.ai/benchmarks/flows/def_hpwl_eval.py')),
          str(Path('/home/lizhijun/work/iEDA.ai/scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef')),str(work/'placement.def')],
          cwd='/home/lizhijun/work/iEDA.ai',stdout=subprocess.PIPE,text=True)
        m=re.search(r'HPWL=(\d+)',r.stdout); hpwl=int(m.group(1)) if m else None
    outd={'design':design,'scope':scope,'penalty':penalty,'rc':rc,'final_line':lines[-1] if lines else None,
          'ledger_last':{k:last.get(k) for k in ['mode','stop_reason','end_iteration','hpwl','overflow','route_util']} if last else None,
          'def_hpwl':hpwl,'workdir':str(work)}
    (work/'result.json').write_text(json.dumps(outd,indent=2)); print(json.dumps(outd))
main(sys.argv[1],sys.argv[2],float(sys.argv[3]))
