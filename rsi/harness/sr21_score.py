import os, sys
from pathlib import Path
W = Path('/home/lizhijun/work/ieda-rsi')
sys.path.insert(0, str(W/'ieda/rsi/harness')); sys.path.insert(0, str(W/'ieda/benchmarks/flows'))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
from gp_metrics_compare import hpwl as ihpwl
D = R.load_designs(); d = sys.argv[1]
rec = D[d]; lef = rec.get('lef')
ref = W/'runs'/'standingB'/d/'ref'
tr = R.truth_metrics(ref, rec, with_egr=True)
hpr = ihpwl(ref/'placement.def', Path(lef)) if lef else None
f = lambda a,b: (round(a/b,4) if (a is not None and b) else None)
for tag in sys.argv[2].split(','):
    wd = W/'runs'/tag/d
    if not (wd/'placement.def').exists(): print(tag, 'no def'); continue
    t = R.truth_metrics(wd, rec, with_egr=True)
    hp = ihpwl(wd/'placement.def', Path(lef)) if lef else None
    print('%-10s hpwl %s  union %s  max %s   [abs u=%s m=%s vs ref u=%s m=%s]' % (tag, f(hp,hpr), f(t.get('egr_total_overflow_union'),tr.get('egr_total_overflow_union')), f(t.get('egr_max_overflow_union'),tr.get('egr_max_overflow_union')), t.get('egr_total_overflow_union'), t.get('egr_max_overflow_union'), tr.get('egr_total_overflow_union'), tr.get('egr_max_overflow_union')))