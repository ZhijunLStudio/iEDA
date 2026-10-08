import json, os, re, sys
from pathlib import Path
W = Path('/home/lizhijun/work/ieda-rsi')
sys.path.insert(0, str(W/'ieda/rsi/harness')); sys.path.insert(0, str(W/'ieda/benchmarks/flows'))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G
from gp_metrics_compare import hpwl as ihpwl
BIN = {'ctl': 'build/bin/iEDA-ctl16-nosshim', 'sr20': 'build/bin/iEDA-sr20b-nosshim'}
ds = [x for x in sys.argv[1].split(',') if x]
seeds = [int(x) for x in sys.argv[2].split(',')]
D = R.load_designs()
out = []
for d in ds:
    rec = D[d]; lef = rec.get('lef')
    ref = W/'runs'/'standingB'/d/'ref'
    tr = R.truth_metrics(ref, rec, with_egr=True)
    hp_r = ihpwl(ref/'placement.def', Path(lef)) if lef and (ref/'placement.def').exists() else None
    for seed in seeds:
        for arm in ('ctl', 'sr20'):
            os.environ['IEDA_BIN'] = str(W/'ieda'/BIN[arm])
            wd = W/'runs'/'sr20abb'/('%s_%s_s%d' % (d, arm, seed)); wd.mkdir(parents=True, exist_ok=True)
            cfg = json.loads(Path(rec['pl_config']).read_text()); pl = cfg.get('PL', cfg)
            td = float(pl.get('GP',{}).get('Density',{}).get('target_density',0.8))
            mi = int(pl.get('GP',{}).get('Nesterov',{}).get('max_iter',2000))
            gp = 'placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed %d -report_route_util 1' % (mi, td, seed)
            rc, o, e = G.run_ieda(wd, Path(rec['case_root']), Path(R.foundry_of(rec)), Path(rec['pl_config']), Path(rec['input_def']), [gp,'placer_run_gp -mode accept','placer_run_lg','placer_run_dp'], def_save=True)
            txt = (o or '') + chr(10) + (e or '')
            npass = len([l for l in txt.splitlines() if '[SR-20]' in l])
            if not (wd/'placement.def').exists():
                row = {'design': d, 'arm': arm, 'seed': seed, 'rc': rc, 'sr20_passes': npass, 'def': False}
                out.append(row); print(json.dumps(row), flush=True); continue
            t = R.truth_metrics(wd, rec, with_egr=True)
            hp = ihpwl(wd/'placement.def', Path(lef)) if lef else None
            f = lambda a,b: (round(a/b,4) if (a is not None and b) else None)
            row = {'design': d, 'arm': arm, 'seed': seed, 'rc': rc, 'sr20_passes': npass, 'def': True,
                   'hpwl': f(hp,hp_r), 'union': f(t.get('egr_total_overflow_union'), tr.get('egr_total_overflow_union')),
                   'max': f(t.get('egr_max_overflow_union'), tr.get('egr_max_overflow_union'))}
            out.append(row); print(json.dumps(row), flush=True)
(W/'runs'/'sr20ab').mkdir(parents=True, exist_ok=True)
(W/'runs'/'sr20ab'/'all.json').write_text(json.dumps(out, indent=1))
print('done')