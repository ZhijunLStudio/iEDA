#!/usr/bin/env python3
"""GP -> LG -> DP full iPL placement vs Innovus -noPrePlaceOpt on the same full netlist."""
from __future__ import annotations
import argparse, json, os, re, shlex, subprocess, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
CASES=Path('/home/lizhijun/work/iEDA/docs/ipl/pl_vis/cases')
BIN=Path(os.environ.get('IEDA_BIN', ROOT/'build/bin/iEDA'))
FOUNDRY=ROOT/'scripts/foundry/sky130'
EVAL=ROOT/'benchmarks/flows/def_hpwl_eval.py'
LEF=FOUNDRY/'lef/sky130_fd_sc_hd_merged.lef'
DESIGNS=['s1238','apb4_timer','picorv32','aes']

def run_one(design, result_root):
    case=CASES/design; work=result_root/design
    work.mkdir(parents=True, exist_ok=True)
    sdc=next(case.glob('*.sdc'))
    cfg=json.load(open(case/'iEDA_config/pl_default_config.json'))['PL']
    cfg['num_threads']=1
    (work/'pl_clean_config.json').write_text(json.dumps({'PL':cfg},indent=2))
    # derive unplaced full-netlist DEF from the WL noPrePlaceOpt Innovus reference
    src=(case/'innovus_placed_nodel.def').read_text()
    start=src.find('\nCOMPONENTS'); he=src.find('\n',start+1); end=src.find('END COMPONENTS')
    blocks=[]; cur=None
    for line in src[he:end].splitlines():
        if re.match(r'\s*-\s+',line):
            if cur is not None: blocks.append(cur)
            cur=[line]
        elif cur is not None: cur.append(line)
    if cur is not None: blocks.append(cur)
    out=[]
    for b in blocks:
        j=' '.join(b); m=re.match(r'\s*-\s+(\S+)\s+(\S+)',j)
        out.append(f'{m.group(0).rstrip()} + UNPLACED ;' if m else j)
    unplaced=work/'ieda_in_unplaced.def'
    unplaced.write_text(src[:start]+'\n'+src[start+1:he]+'\n'+'\n'.join(out)+'\n'+src[end:])
    tcl=f'''flow_init -config {shlex.quote(str(case/'iEDA_config/flow_config.json'))}
db_init -config {shlex.quote(str(case/'iEDA_config/db_default_config.json'))} -output_dir_path {shlex.quote(str(work))}
source {shlex.quote(str(case/'script/DB_script/db_path_setting.tcl'))}
source {shlex.quote(str(case/'script/DB_script/db_init_lib.tcl'))}
source {shlex.quote(str(case/'script/DB_script/db_init_sdc.tcl'))}
source {shlex.quote(str(case/'script/DB_script/db_init_lef.tcl'))}
def_init -path {shlex.quote(str(unplaced))}
init_pl -config {shlex.quote(str(work/'pl_clean_config.json'))}
placer_run_gp -mode start -iterations 600 -seed 42 -report_route_util 1
catch {{placer_run_gp -mode accept}}
placer_run_lg
placer_run_dp
def_save -path {shlex.quote(str(work/'ieda_full.def'))}
flow_exit
'''
    (work/'run.tcl').write_text(tcl)
    env=os.environ.copy(); env.update(CONFIG_DIR=str(case/'iEDA_config'),RESULT_DIR=str(work),TCL_SCRIPT_DIR=str(case/'script'),FOUNDRY_DIR=str(FOUNDRY),SDC_FILE=str(sdc))
    with open(work/'run.log','w') as log:
        r=subprocess.run([str(BIN),'-script',str(work/'run.tcl')],cwd=ROOT,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=3600)
    outdef=work/'ieda_full.def'
    if r.returncode!=0 or not outdef.exists() or '( -1 -1 )' in outdef.read_text(errors='ignore'):
        return {'design':design,'ok':False,'rc':r.returncode}
    def hpwl(p):
        x=subprocess.run([sys.executable,str(EVAL),str(LEF),str(p)],cwd=ROOT,stdout=subprocess.PIPE,text=True).stdout
        m=re.search(r'HPWL=(\d+)',x); return int(m.group(1)) if m else None
    ih=hpwl(outdef); nh=hpwl(case/'innovus_placed_nodel.def')
    res={'design':design,'ok':True,'rc':0,'ieda_full_hpwl':ih,'innovus_nodel_hpwl':nh,
         'ratio':ih/nh if ih and nh else None,'improvement_pct':(1-ih/nh)*100 if ih and nh else None,
         'workdir':str(work)}
    (work/'result.json').write_text(json.dumps(res,indent=2)); print(json.dumps(res))
    return res

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--designs',nargs='+',default=DESIGNS)
    ap.add_argument('--result-root',default=str(ROOT/'benchmarks/results/ipl_full_compare'))
    args=ap.parse_args(); root=Path(args.result_root)
    for d in args.designs: run_one(d,root)

if __name__=='__main__': raise SystemExit(main())
