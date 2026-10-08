import json, os, sys
from pathlib import Path
W = Path('/home/lizhijun/work/ieda-rsi')
os.environ['IEDA_BIN'] = str(W/'ieda/build/bin/iEDA-nosshim')
sys.path.insert(0, str(W/'ieda/rsi/harness')); sys.path.insert(0, str(W/'ieda/benchmarks/flows'))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
from gp_metrics_compare import hpwl as ihpwl
D = R.load_designs()
tag = sys.argv[1]
out = {}
for d in sorted(D):
    rec = D[d]; lef = rec.get('lef')
    ref = W/'runs'/'standingB'/d/'ref'
    wd = W/'runs'/tag/d
    if not ((ref/'placement.def').exists() and (wd/'placement.def').exists()): continue
    tr = R.truth_metrics(ref, rec, with_egr=True)
    t = R.truth_metrics(wd, rec, with_egr=True)
    hp_r = ihpwl(ref/'placement.def', Path(lef)) if lef else None
    hp = ihpwl(wd/'placement.def', Path(lef)) if lef else None
    f = lambda a,b: (round(a/b,4) if (a is not None and b) else None)
    out[d] = {'hpwl': f(hp,hp_r), 'union': f(t.get('egr_total_overflow_union'), tr.get('egr_total_overflow_union')), 'max': f(t.get('egr_max_overflow_union'), tr.get('egr_max_overflow_union')), 'ours': {'hpwl': hp, 'union': t.get('egr_total_overflow_union'), 'max': t.get('egr_max_overflow_union')}, 'ref': {'hpwl': hp_r, 'union': tr.get('egr_total_overflow_union'), 'max': tr.get('egr_max_overflow_union')}}
    print(d, json.dumps(out[d]['ours']), '->', json.dumps(out[d]['ref']), '=', json.dumps({k: out[d][k] for k in ('hpwl','union','max')}), flush=True)
Path('/tmp/arm_' + tag + '.json').write_text(json.dumps(out, indent=1))
print('SCORED', len(out))