import json, os, sys, shutil, time
from pathlib import Path
W = Path('/home/lizhijun/work/ieda-rsi')
sys.path.insert(0, str(W/'ieda/rsi/harness')); sys.path.insert(0, str(W/'ieda/benchmarks/flows'))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS)); import gp_agent as G
from gp_metrics_compare import density
D = R.load_designs(); ref = json.loads((W/'runs/four_arm.json').read_text())
BIN = 'iEDA'
DESIGNS = sys.argv[1].split(',')
EFFORTS = [int(x) for x in sys.argv[2].split(',')]
SEED = int(sys.argv[3])
for d in DESIGNS:
    rec = D[d]; Rf = ref['designs'][d]['arms']['ref']
    cfg = json.loads(Path(rec['pl_config']).read_text()); cfg['PL']['num_threads'] = 1
    pinned = W/'runs'/('effcfg_%s.json' % d)
    if not pinned.exists(): pinned.write_text(json.dumps(cfg, indent=1))
    pl = cfg['PL']; td = float(pl['GP']['Density']['target_density']); mi = int(pl['GP']['Nesterov']['max_iter'])
    for eff in EFFORTS:
        wd = W/'runs'/'efftest'/(('%s_e%d_s%d') % (d, eff, SEED))
        if wd.exists(): shutil.rmtree(wd)
        wd.mkdir(parents=True)
        os.environ['OMP_NUM_THREADS'] = '1'; os.environ['IEDA_BIN'] = str(W/'ieda/build/bin'/BIN)
        gp = 'placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed %d -report_route_util 1' % (mi, td, SEED)
        if eff > 0: gp += ' -congestion_effort %d' % eff
        t0 = time.time()
        try:
            G.run_ieda(wd, Path(rec['case_root']), Path(R.foundry_of(rec)), pinned, Path(rec['input_def']),
                       [gp, 'placer_run_gp -mode accept', 'placer_run_lg', 'placer_run_dp'], def_save=True)
        except Exception as exc:
            print('%s eff=%d FLOW FAILED after %.0fs: %r' % (d, eff, time.time()-t0, exc), flush=True)
            continue
        el = time.time()-t0
        defp = wd/'placement.def'
        if not defp.exists():
            print('%s eff=%d NO DEF after %.0fs' % (d, eff, el), flush=True); continue
        r = density(defp, Path(rec['case_root']), 200, Path(R.foundry_of(rec)), 'egr', 64)
        u, m = r.get('egr_total_overflow_union'), r.get('egr_max_overflow_union')
        ru = (u/Rf['union']) if Rf['union'] else 0.0
        rm = (m/Rf['max']) if Rf['max'] else 0.0
        print('%s eff=%d union=%s ratio=%.3f max=%s ratio=%.3f ref=(%s,%s) flow=%.0fs' % (
            d, eff, u, ru, m, rm, Rf['union'], Rf['max'], el), flush=True)
