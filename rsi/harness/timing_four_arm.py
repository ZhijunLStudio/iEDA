import json, os, sys
from pathlib import Path
W = Path('/home/lizhijun/work/ieda-rsi')
os.environ['OMP_NUM_THREADS'] = '1'
sys.path.insert(0, str(W/'ieda/rsi/harness'))
import rsi_lib as R
import timing_rung as T
D = R.load_designs()
ds = [x for x in sys.argv[1].split(',') if x]
out = {}
for d in ds:
    rec = D[d]
    row = {'design': d, 'pdk': rec.get('pdk'), 'arms': {}}
    arms = {'orig': W/'runs'/'origsweep'/d/'placement.def',
            'cur':  W/'runs'/'standingB'/d/'ours'/'placement.def',
            'sr21': W/'runs'/'cur21sweep'/d/'placement.def',
            'ref':  W/'runs'/'standingB'/d/'ref'/'placement.def'}
    for arm, p in arms.items():
        if not Path(p).exists():
            row['arms'][arm] = {'ok': False, 'reason': 'missing'}; print(d, arm, 'MISSING', flush=True); continue
        try:
            ok, m = T.timing_of(p, d, rec, W/'runs'/'timing4'/(d + '_' + arm))
            r2 = {k: m.get(k) for k in ('setup_wns','setup_tns','hold_wns','hold_tns')}
            r2['ok'] = ok; r2['reason'] = m.get('reason')
        except Exception as ex:
            r2 = {'ok': False, 'reason': repr(ex)}
        row['arms'][arm] = r2
        print(d, arm, json.dumps(r2), flush=True)
    out[d] = row
Path(W/'runs'/'timing4').mkdir(parents=True, exist_ok=True)
Path(W/'runs'/'timing4'/('part_' + ds[0] + '.json')).write_text(json.dumps(out, indent=1))
print('DONE', len(out))