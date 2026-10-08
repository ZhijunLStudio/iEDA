import json, os, sys
from pathlib import Path
W = Path('/home/lizhijun/work/ieda-rsi')
os.environ['OMP_NUM_THREADS'] = '1'
os.environ['IEDA_BIN'] = str(W/'ieda/build/bin/iEDA-sr21-nosshim')
sys.path.insert(0, str(W/'ieda/rsi/harness')); sys.path.insert(0, str(W/'ieda/benchmarks/flows'))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G
D = R.load_designs()
spec = sys.argv[1]
for item in spec.split(';'):
    d, seeds = item.split(':')
    rec = D[d]
    cfg = json.loads(Path(rec['pl_config']).read_text()); pl = cfg.get('PL', cfg)
    td = float(pl.get('GP',{}).get('Density',{}).get('target_density',0.8))
    mi = int(pl.get('GP',{}).get('Nesterov',{}).get('max_iter',2000))
    for sd in seeds.split(','):
        wd = W/'runs'/'sr21'/(d + '_s' + sd); wd.mkdir(parents=True, exist_ok=True)
        gp = 'placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed %s -report_route_util 1' % (mi, td, sd)
        G.run_ieda(wd, Path(rec['case_root']), Path(R.foundry_of(rec)), Path(rec['pl_config']), Path(rec['input_def']), [gp,'placer_run_gp -mode accept','placer_run_lg','placer_run_dp'], def_save=True)
        print('%s seed %s done: %s' % (d, sd, (wd/'placement.def').exists()), flush=True)
print('all done')