#!/usr/bin/env python3
"""Preserve complete tables even when the formal supervisor exits on failure.

No episode is started or retried. All source, attempts and failures are retained.
This report recovery never converts a technical failure into a QoR conclusion.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time


def load(path):
    return json.loads(Path(path).read_text())


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def save(path, value):
    path = Path(path)
    temporary = path.with_name(path.name + '.tmp')
    temporary.write_text(json.dumps(value, indent=2) + '\n')
    temporary.replace(path)


def identity(pid):
    raw = Path('/proc', str(pid), 'stat').read_text()
    fields = raw[raw.rfind(')') + 2:].split()
    return {'pid': pid, 'start_ticks': int(fields[19])}


def alive(record):
    try:
        raw = Path('/proc', str(record['pid']), 'stat').read_text()
        fields = raw[raw.rfind(')') + 2:].split()
        return int(fields[19]) == record['start_ticks'] and fields[0] != 'Z'
    except (FileNotFoundError, ProcessLookupError):
        return False


def run(master):
    receipt = master / 'attempts/terminal-postprocess-started.json'
    final = master / 'audit/terminal-postprocess-summary.json'
    if receipt.exists() or final.exists():
        raise FileExistsError('Existing report recovery; inspect it, never overwrite or retry')
    workflow, study = master / 'workflow-v7', master / 'main-v1'
    save(receipt, {'identity': identity(os.getpid()), 'source_sha256': sha(__file__),
                   'phase': 'waiting_for_formal_supervisor', 'native_or_API_calls': 0})
    deadline = load(master / 'protocol/source-before.json')['deadline_unix']
    supervisor = load(workflow / 'started.json')['identity']
    cohort_owner = load(workflow / 'main-cohort-started.json')['identity']
    while alive(supervisor) or alive(cohort_owner):
        if time.time() >= deadline:
            raise TimeoutError('Two-week deadline before terminal report recovery')
        time.sleep(15)
    cohort = load(study / 'cohort-result.json')
    if cohort.get('completed') != cohort.get('total') or cohort.get('total') != 72:
        raise RuntimeError('Main cohort is not terminal with72 attempts; no report or episode rerun')
    os.environ['IEDA_STUDY_ROOT'] = str(study)
    sys.path.insert(0, str(study))
    from study_contract import verify_study
    verify_study(study)
    logs = master / 'terminal-report-recovery-v1'
    logs.mkdir(exist_ok=False)
    # Reporting is separate from all physical episodes; avoid their assigned cores.
    os.sched_setaffinity(0, {max(os.sched_getaffinity(0))})
    env = {**os.environ, 'IEDA_STUDY_ROOT': str(study),
           'OMP_NUM_THREADS': '1', 'OPENBLAS_NUM_THREADS': '1', 'MKL_NUM_THREADS': '1'}
    commands = []

    def execute(name, script, arguments):
        started = time.monotonic()
        command = ['/usr/bin/python3', str(script), *map(str, arguments)]
        with (logs / (name + '.log')).open('xb') as stream:
            process = subprocess.Popen(command, cwd=study, env=env, stdout=stream,
                                       stderr=subprocess.STDOUT, start_new_session=True)
            save(logs / (name + '-started.json'), {'identity': identity(process.pid), 'command': command})
            while process.poll() is None:
                if time.monotonic() - started >= 900 or time.time() >= deadline:
                    try:
                        os.killpg(process.pid, signal.SIGTERM)
                    except ProcessLookupError:
                        pass
                    try:
                        process.wait(timeout=5)
                    except subprocess.TimeoutExpired:
                        os.killpg(process.pid, signal.SIGKILL)
                        process.wait(timeout=5)
                    raise TimeoutError('Read-only reporting deadline: ' + name)
                time.sleep(.2)
            returncode = process.returncode
        row = {'name': name, 'source': str(script), 'source_sha256': sha(script),
               'returncode': returncode, 'wall_s': time.monotonic() - started,
               'log': str(logs / (name + '.log')), 'native_or_API_calls': 0}
        save(logs / (name + '-terminal.json'), row)
        commands.append(row)
        if returncode:
            raise RuntimeError('Read-only report failed: ' + name)

    analysis = study / 'analysis-v1'
    if not analysis.exists():
        execute('analysis', study / 'analyze_policy_study.py', ['--output', analysis])
    if not (analysis / 'decision.json').exists():
        raise RuntimeError('Existing partial analysis preserved; inspect before any further action')
    plots = [analysis / name for name in ('quality-vs-physical-CPU.png',
             'quality-vs-physical-CPU.pdf', 'delivered-quality-vs-total-wall.png')]
    if not any(path.exists() for path in plots):
        execute('plots', study / 'plot_policy_study.py', ['--analysis', analysis])
    if not all(path.exists() for path in plots):
        raise RuntimeError('Partial plot output preserved; no overwrite')
    attribution = study / 'attribution-v1'
    if not attribution.exists():
        execute('frozen-attribution', study / 'attribute_policy_study.py', ['--output', attribution])
    corrected = master / 'audit/mechanism-use-final.json'
    if not corrected.exists():
        execute('corrected-mechanism-counts', master / 'reporting-mechanisms-v2/audit_mechanism_usage.py',
                ['--study', study, '--output', corrected])
    verify_study(study)
    failed = [key for key, value in cohort['results'].items()
              if not value.get('ok') or not value.get('audit_ok')]
    save(final, {'all72_terminal': True, 'native_or_API_calls': 0, 'new_or_retried_episodes': 0,
                 'technical_validation_incomplete': bool(failed), 'failed_episodes': failed,
                 'direction_conclusion': None, 'main_decision': str(analysis / 'decision.json'),
                 'corrected_counts': str(corrected), 'commands': commands,
                 'disclosure': 'Original supervisor failure and frozen attribution output retained. Postprocessing only; known finish/cache count correction is separate.'})
    print(json.dumps({'reports_recovered': True, 'failed_episodes_retained': failed,
                      'summary': str(final)}), flush=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--master', type=Path, required=True)
    args = parser.parse_args()
    try:
        run(args.master.resolve())
    except Exception as exc:
        output = args.master / 'audit/terminal-postprocess-error.json'
        if not output.exists():
            save(output, {'class': type(exc).__name__, 'error': str(exc), 'no_automatic_retry': True})
        raise
