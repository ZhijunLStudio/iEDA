#!/usr/bin/env python3
"""Validate the byte-equivalent CPU fix after existing experimental jobs exit."""
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
    temporary = path.with_name(path.name + '.tmp')
    temporary.write_text(json.dumps(value, indent=2) + '\n')
    temporary.replace(path)


def identity(pid):
    raw = Path('/proc', str(pid), 'stat').read_text()
    fields = raw[raw.rfind(')') + 2:].split()
    return {'pid': pid, 'start_ticks': int(fields[19]), 'state': fields[0]}


def alive(record):
    try:
        current = identity(record['pid'])
        return current['start_ticks'] == record['start_ticks'] and current['state'] != 'Z'
    except (FileNotFoundError, ProcessLookupError):
        return False


def run(master, study):
    receipt = master / 'attempts/publication-budget-fix-started.json'
    summary = master / 'audit/publication-budget-fix-summary.json'
    if receipt.exists() or summary.exists():
        raise FileExistsError('Existing technical fix attempt; inspect, do not retry')
    save(receipt, {'identity': identity(os.getpid()), 'phase': 'waiting_for_existing_followups',
                   'source_sha256': sha(__file__), 'study': str(study), 'model_requests': 0})
    previous = load(master / 'attempts/unconditional-catchup-started.json')['identity']
    deadline = load(master / 'protocol/source-before.json')['deadline_unix']
    while alive(previous):
        if time.time() >= deadline:
            raise TimeoutError('Deadline before publication CPU regression')
        time.sleep(15)
    # A wrapper exit is insufficient if one of its explicitly recorded commands
    # remains alive. No new physical work overlaps an old experimental cohort.
    for name in ('workflow-v7', 'recovery-workflow-v1', 'unconditional-catchup-workflow-v1'):
        directory = master / name
        for path in directory.glob('*-started.json'):
            if alive(load(path)['identity']):
                raise RuntimeError('Existing experimental command still live: ' + str(path))
    if not load(master / 'audit/rewrite-byte-equivalence.json')['ok']:
        raise RuntimeError('Byte-equivalence must pass before physical validation')
    os.environ['IEDA_STUDY_ROOT'] = str(study)
    sys.path.insert(0, str(study))
    from study_contract import verify_study
    from process_supervisor import OwnedProcesses, enable_subreaper
    verify_study(study)
    enable_subreaper()
    root = study / 'episodes/pub-a0'
    if root.exists():
        raise FileExistsError(root)
    log = study / 'publication-budget.log'
    env = {**os.environ, 'PYTHONPATH': str(study), 'IEDA_NATIVE_CPU': str(min(os.sched_getaffinity(0))),
           'OMP_NUM_THREADS': '1', 'OPENBLAS_NUM_THREADS': '1', 'MKL_NUM_THREADS': '1', 'PYTHONHASHSEED': '42'}
    command = ['/usr/bin/python3', str(study / 'validation/verify_publication_budget_v05.py'),
               '--master', str(master), '--id', 'pub-a0']
    started = time.monotonic()
    with log.open('xb') as stream:
        child = subprocess.Popen(command, cwd=study, env=env, stdout=stream,
                                 stderr=subprocess.STDOUT, start_new_session=True)
        owner = OwnedProcesses(root, child.pid)
        while child.poll() is None:
            owner.refresh()
            if time.monotonic() - started >= 1000 or time.time() >= deadline:
                owner.signal_live(signal.SIGTERM)
                break
            time.sleep(.2)
        owner.refresh()
        if owner.live():
            owner.signal_live(signal.SIGTERM)
            until = time.monotonic() + 3
            while owner.live() and time.monotonic() < until:
                owner.refresh(); owner.reap_adopted(); time.sleep(.05)
            owner.signal_live(signal.SIGKILL)
        child.wait(timeout=5)
        owner.refresh(); owner.reap_adopted()
    path = root / 'validation-result.json'
    value = load(path) if path.exists() else {}
    result = {'ok': child.returncode == 0 and value.get('ok') is True and not owner.live()
              and not owner.ownership_errors and not owner.parse_errors,
              'returncode': child.returncode, 'validation': str(path),
              'validation_sha256': sha(path) if path.exists() else None,
              'work': value.get('work'), 'wall_s': time.monotonic() - started,
              'owned_survivors': owner.live(), 'cleanup_signals': owner.signals,
              'ownership_errors': owner.ownership_errors, 'parse_errors': owner.parse_errors,
              'main_failure_retained': 'c07-r0', 'new_or_retried_main_episodes': 0,
              'model_requests': 0, 'fixed_serializer_sha256': sha(study / 'legal_refinement.py'),
              'scope': 'One engineering regression after all existing followups; same kernel and physical operators. Never changes the frozen main cohort or its technical-failure conclusion.'}
    save(summary, result)
    print(json.dumps({'publication_budget_fix_ok': result['ok'], 'summary': str(summary)}), flush=True)
    if not result['ok']:
        raise SystemExit(1)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--master', required=True, type=Path)
    parser.add_argument('--study', required=True, type=Path)
    args = parser.parse_args()
    try:
        run(args.master.resolve(), args.study.resolve())
    except Exception as exc:
        path = args.master / 'audit/publication-budget-fix-error.json'
        if not path.exists():
            save(path, {'class': type(exc).__name__, 'error': str(exc), 'no_automatic_retry': True})
        raise
