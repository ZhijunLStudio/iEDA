"""Shared frozen-input, native-process and measurement helpers."""
from pathlib import Path
import hashlib
import json
import math
import os
import re
import resource
import signal
import subprocess
import sys
import time

ROOT = Path(os.environ.get('IEDA_STUDY_ROOT', Path(__file__).resolve().parent)).resolve()
SUITE = ROOT / 'suite.json'


def load(path):
    return json.loads(Path(path).read_text())


def save(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_name(path.name + '.tmp')
    temp.write_text(json.dumps(value, ensure_ascii=False, indent=2, allow_nan=False) + '\n')
    temp.replace(path)


def sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for part in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(part)
    return h.hexdigest()


def desc(path):
    path = Path(path).resolve()
    return {'path': str(path), 'sha256': sha(path), 'size_bytes': path.stat().st_size}


def tq(value):
    value = str(value)
    if any(c in value for c in '{}\n\r'):
        raise ValueError('unsupported Tcl path or literal')
    return '{' + value + '}'


def native_env():
    env = os.environ.copy()
    for key in tuple(env):
        if key.startswith(('IEDA_', 'GP_AGENT_')):
            env.pop(key)
    env.update(OMP_NUM_THREADS='1', OMP_THREAD_LIMIT='1', OPENBLAS_NUM_THREADS='1',
               MKL_NUM_THREADS='1', NUMEXPR_NUM_THREADS='1', RAYON_NUM_THREADS='1', MALLOC_ARENA_MAX='1')
    env.update(OMP_PROC_BIND='true',OMP_PLACES='{'+str(native_cpu())+'}',GOMP_CPU_AFFINITY=str(native_cpu()))
    return env


def native_cpu():
    allowed=sorted(os.sched_getaffinity(0))
    selected=int(os.environ['IEDA_NATIVE_CPU'])if os.environ.get('IEDA_NATIVE_CPU')is not None else allowed[os.getpid()%len(allowed)]
    if selected not in allowed:raise RuntimeError('native CPU is outside the permitted affinity set')
    return selected


def native_command(binary,*arguments):
    # The frozen timing evaluator creates its own thread pool independently
    # of PL.num_threads. Constrain all those threads to one logical CPU.
    return ['/usr/bin/taskset','-c',str(native_cpu()),str(binary),*map(str,arguments)]


def canonical_commands(commands, work):
    """Stable relative spellings for episode-local Tcl paths, same files.

    Native allocation order can otherwise depend on output directory/ID length.
    External frozen technology paths remain unchanged. Record dispatched Tcl.
    """
    work = Path(work).resolve()
    episode = next((p for p in (work, *work.parents) if p.parent.name == 'episodes'), work)
    def replace(match):
        path = Path(match[1])
        if path == episode or episode in path.parents:
            return '{' + os.path.relpath(path, work) + '}'
        return match[0]
    return [re.sub(r'\{(/[^{}\n]*)\}', replace, command) for command in commands]


def init_commands(design, work, config, input_def=None):
    work = Path(work)
    work.mkdir(parents=True, exist_ok=True)
    db = {'INPUT': {k: '' for k in ('def_path', 'lef_paths', 'lib_path', 'sdc_path', 'tech_lef_path', 'verilog_path')},
          'OUTPUT': {'output_dir_path': '.'}, 'LayerSettings': {'routing_layer_1st': design['routing_layer_1st']}}
    save(work / 'db_config.json', db)
    for name, source in (('input.def', input_def or design['input_def']), ('pl.json', config)):
        alias = work / name
        if alias.exists() or alias.is_symlink():
            raise RuntimeError('native input alias already exists: ' + str(alias))
        alias.symlink_to(Path(source).resolve())
    libs = '[list ' + ' '.join(tq(p) for p in design['libs']) + ']'
    return ['db_init -config {db_config.json} -output_dir_path {.}',
            f'db_init -lib_path {libs} -sdc_path {tq(design["sdc"])}',
            f'tech_lef_init -path {tq(design["tech_lef"])}',
            *[f'lef_init -path {tq(p)}' for p in design['cell_lefs']],
            'def_init -path {input.def}', 'init_pl -config {pl.json}']


def wrapped_script(commands, marker='NATIVE_COMPLETE'):
    # A Tcl error aborts immediately; no unconditional success marker.
    return 'if {[catch {\n' + '\n'.join(commands) + '\n} msg opts]} {puts stderr $msg; puts stderr [dict get $opts -errorinfo]; exit 1}\nputs ' + marker + '\nflow_exit\n'


def pid_identity(pid):
    try:
        value = Path('/proc', str(pid), 'stat').read_text()
        f = value[value.rfind(')') + 2:].split()
        return {'pid': pid, 'start_ticks': int(f[19]), 'pgid': int(f[2]), 'state': f[0]}
    except (OSError, ValueError, IndexError):
        return None


def run_native(binary, work, commands, timeout=600, marker='NATIVE_COMPLETE'):
    import work_budget
    if work_budget.ACTIVE:
        work_budget.ACTIVE.check()
        if any('run_timing_eval ' in command for command in commands):
            work_budget.ACTIVE.reserve_sta()
    work = Path(work)
    work.mkdir(parents=True, exist_ok=True)
    if (work / 'native-terminal.json').exists():
        raise RuntimeError('native attempt already exists; use a new work directory')
    script = work / 'run.tcl'
    commands = canonical_commands(commands, work)
    script.write_text(wrapped_script(commands, marker))
    started = time.monotonic()
    usage = resource.getrusage(resource.RUSAGE_CHILDREN)
    timed_out = False
    budget_error = None
    with (work / 'native.log').open('wb') as log:
        command=native_command(binary,'-script','run.tcl')
        proc = subprocess.Popen(command, cwd=work, env=native_env(),
                                stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
        identity = pid_identity(proc.pid)
        save(work / 'native-started.json', {'identity': identity, 'timeout_s': timeout, 'command': command, 'script': desc(script), 'native_cpu':native_cpu(), 'native_resources': {k: native_env()[k] for k in ('OMP_NUM_THREADS','OMP_THREAD_LIMIT','RAYON_NUM_THREADS','MALLOC_ARENA_MAX')}})
        try:
            deadline = time.monotonic() + timeout
            while proc.poll() is None:
                if work_budget.ACTIVE:
                    work_budget.ACTIVE.check()
                if time.monotonic() >= deadline:
                    raise subprocess.TimeoutExpired(proc.args, timeout)
                time.sleep(.05)
        except work_budget.BudgetExhausted as exc:
            budget_error = str(exc)
            os.killpg(proc.pid, signal.SIGTERM)
            try:
                proc.wait(timeout=3)
            except subprocess.TimeoutExpired:
                os.killpg(proc.pid, signal.SIGKILL)
                proc.wait(timeout=3)
        except subprocess.TimeoutExpired:
            timed_out = True
            os.killpg(proc.pid, signal.SIGTERM)
            try:
                proc.wait(timeout=3)
            except subprocess.TimeoutExpired:
                os.killpg(proc.pid, signal.SIGKILL)
                proc.wait(timeout=3)
    after = resource.getrusage(resource.RUSAGE_CHILDREN)
    text = (work / 'native.log').read_text(errors='replace')
    result = {'returncode': proc.returncode, 'timed_out': timed_out, 'wall_s': time.monotonic() - started,
              'cpu_s': after.ru_utime + after.ru_stime - usage.ru_utime - usage.ru_stime,
              'peak_rss_kib': after.ru_maxrss, 'complete': marker in text,
              'egr_detected': bool(re.search(r'EGR:|EarlyRouter|trial.route', text)),
              'identity': identity, 'matching_process_live': pid_identity(proc.pid) == identity,
              'budget_error': budget_error,
              'log': desc(work / 'native.log')}
    result['ok'] = result['returncode'] == 0 and not timed_out and result['complete'] and not result['matching_process_live']
    save(work / 'native-terminal.json', result)
    return result


def timing_summary(data):
    clocks = data.get('HPWL', {}).get('clock_timings') or []
    valid = bool(clocks) and all(isinstance(c.get(k), (int, float)) and math.isfinite(c[k])
                               for c in clocks for k in ('setup_wns', 'setup_tns', 'hold_wns', 'hold_tns'))
    return {'ok': valid, 'model': 'HPWL-RC pre-route estimate', 'clock_timings': clocks,
            **{k + '_ns': (min(c[k] for c in clocks) if 'wns' in k else sum(c[k] for c in clocks)) if valid else None
               for k in ('setup_wns', 'setup_tns', 'hold_wns', 'hold_tns')}}


def reference_gaps(candidate, reference, clock_period):
    """Positive shortfall, preserving every raw axis alongside the scalar."""
    if not isinstance(clock_period,(int,float)) or not math.isfinite(clock_period) or clock_period<=0:
        raise ValueError('A positive resolved SDC clock period is required; no silent normalization fallback')
    period = float(clock_period)
    gaps = {}
    for key in ('hpwl_um','rudy_peak','rudy_overflow_sum'):
        if candidate.get(key) is None or reference.get(key) is None:
            return None
        denom = max(abs(reference[key]),1.0 if key=='rudy_overflow_sum' else 1e-12)
        gaps[key] = max(0.,(candidate[key]-reference[key])/denom)
    for key in ('setup_wns_ns','setup_tns_ns','hold_wns_ns','hold_tns_ns'):
        if candidate.get(key) is None or reference.get(key) is None:
            return None
        denom = max(abs(reference[key]),period) if 'tns' in key else period
        gaps[key] = max(0.,(reference[key]-candidate[key])/denom)
    return {'axes':gaps,'worst':max(gaps.values()),'sum':sum(gaps.values()),
            'note':'Ranking aid only; raw regressions/Pareto dominance reported separately.'}


def measure(design, final_def, work, binary=None, timing=True, timeout=600, timing_paths=False):
    work = Path(work)
    suite = load(SUITE)
    config = Path(design['pl_config'])
    commands = init_commands(design, work, config, final_def)
    commands += [f'run_congestion_eval -model rudy -bin_cnt_x 64 -bin_cnt_y 64 -eval_output_path {tq(work)}']
    if timing:
        tail=(' -path_json '+tq(work/'paths.json')+' -max_path 64')if timing_paths else ''
        commands += [f'run_timing_eval -routing_type HPWL -eval_output_path {tq(work)}'+tail]
    terminal = run_native(binary or suite['solver']['path'], work, commands, timeout)
    result = {'ok': False, 'def': desc(final_def), 'terminal': terminal}
    if terminal['ok']:
        sys.path.insert(0, str(ROOT / 'helpers'))
        import def_hpwl_eval as hp
        import placement_legality as legal
        import def_identity
        macros, _ = hp.parse_lef(Path(design['macro_lef']))
        hpwl, nets, skipped, units = hp.parse_def(Path(final_def), macros)
        legality = legal.check_legalized(Path(final_def), Path(design['macro_lef']))
        rudy = load(work / 'congestion_result.json')
        timing_data = load(work/'timing_result.json') if timing else {}
        ts = timing_summary(timing_data)
        identity = def_identity.compare(design['input_def'], final_def)
        result.update(hpwl_dbu=hpwl, hpwl_um=hpwl / units, units_per_um=units, nets=nets, missing_endpoints=skipped,
                      identity=identity,
                      rudy={k: v for k, v in rudy.items() if not k.endswith('_path')}, legality=legality, timing=ts)
        result['ok'] = hpwl > 0 and skipped == 0 and legality['legalized'] and identity['same_netlist'] and identity['same_floorplan'] and (ts['ok'] if timing else True)
    if timing and timing_paths and terminal['ok']:
        result['path_evidence']={'path_json':desc(work/'paths.json'),'source_def_sha256':result['def']['sha256'],
            'captured_in_existing_STA_call':True,'max_setup_paths':64,'max_hold_paths':64}
    save(work / 'metrics.json', result)
    return result
