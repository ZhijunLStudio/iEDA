#!/usr/bin/env python3
"""Run supplementary cadence controls only after the formal workflow exits.

No model calls, strategy changes, automatic retries or overlapping fifth
episode. Existing attempts and evidence are never overwritten.
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
    h = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()


def save(path, value):
    path = Path(path)
    temporary = path.with_name(path.name + '.tmp')
    temporary.write_text(json.dumps(value, indent=2) + '\n')
    temporary.replace(path)


def alive(identity):
    try:
        raw = Path('/proc', str(identity['pid']), 'stat').read_text()
        fields = raw[raw.rfind(')') + 2:].split()
        return int(fields[19]) == identity['start_ticks'] and fields[0] != 'Z'
    except (FileNotFoundError, ProcessLookupError):
        return False


def run(study, workflow):
    study, workflow = Path(study).resolve(), Path(workflow).resolve()
    master = study.parent
    summary_path = master / 'audit/gp4-equivalence-summary.json'
    receipt = master / 'attempts/gp4-closeout-started.json'
    if receipt.exists() or summary_path.exists():
        raise FileExistsError('Supplementary attempt already exists; inspect it rather than retrying')
    os.environ['IEDA_STUDY_ROOT'] = str(study)
    sys.path.insert(0, str(study))
    from process_supervisor import OwnedProcesses, enable_subreaper
    from common import pid_identity
    from study_contract import verify_study
    from release_gate import CRITICAL
    deadline = load(master / 'protocol/source-before.json')['deadline_unix']
    save(receipt, {'identity': pid_identity(os.getpid()), 'study': str(study),
                   'workflow': str(workflow), 'source_sha256': sha(__file__),
                   'deadline_unix': deadline, 'phase': 'waiting_for_formal_workflow'})
    while True:
        records = [workflow / 'started.json', *workflow.glob('*-started.json')]
        live = [p for p in records if alive(load(p)['identity'])]
        if not live:
            break
        if time.time() >= deadline:
            raise TimeoutError('Two-week deadline before supplementary controls; original results retained')
        time.sleep(15)
    # A dead wrapper alone does not establish that its cohort finished.
    main = master / 'main-v1'
    cohort = load(main / 'cohort-result.json')
    if cohort.get('completed') != cohort.get('total') or cohort.get('total') != 72:
        raise RuntimeError('Formal cohort is not terminal with72 attempts; no extra physical work started')
    plan = load(main / 'paired-plan.json')
    for entry in plan['rule'] + plan['agent']:
        path = main / 'episodes' / entry['id'] / 'result.json'
        if not path.exists():
            previous = load(main / 'attempt-receipts' / (entry['id'] + '.json'))
            if previous.get('stage') != 'prepare':
                raise RuntimeError('Missing owned-process accounting for ' + entry['id'])
            continue
        value = load(path)
        identities = value.get('owned_processes', []) + value.get('owned_survivors', [])
        if any(alive(i) for i in identities):
            raise RuntimeError('Formal owned process remains live; supplementary work deferred')
    verify_study(study); verify_study(main)
    for name in (*CRITICAL, 'plugin/lib/index.js'):
        if sha(study / name) != sha(main / name):
            raise RuntimeError('Supplementary physical/controller source differs: ' + name)
    cores = sorted(os.sched_getaffinity(0))[:2]
    if len(cores) < 2:
        raise RuntimeError('Two distinct cores required for supplementary controls')
    enable_subreaper()
    jobs = [('gcd_nangate45_a', 'g4-n45', cores[0]), ('salsa20_sky130_a', 'g4-sky', cores[1])]
    logs = study / 'closeout-logs'; logs.mkdir(exist_ok=False)

    def execute(job):
        design, identifier, core = job
        root = study / 'episodes' / identifier
        if root.exists():
            raise FileExistsError(root)
        command = ['/usr/bin/python3', str(study / 'validation/verify_gp_partitions_v05.py'),
                   '--design', design, '--id', identifier, '--effort', '4']
        env = {**os.environ, 'IEDA_STUDY_ROOT': str(study), 'PYTHONPATH': str(study),
               'IEDA_NATIVE_CPU': str(core), 'PYTHONHASHSEED': '42',
               'OMP_NUM_THREADS': '1', 'OPENBLAS_NUM_THREADS': '1', 'MKL_NUM_THREADS': '1'}
        started = time.monotonic(); timed_out = False
        with (logs / (identifier + '.log')).open('xb') as stream:
            child = subprocess.Popen(command, cwd=study, env=env, stdout=stream,
                                     stderr=subprocess.STDOUT, start_new_session=True)
            owner = OwnedProcesses(root, child.pid)
            while child.poll() is None:
                owner.refresh()
                if time.monotonic() - started >= 1900 or time.time() >= deadline:
                    timed_out = True
                    break
                time.sleep(.2)
            owner.refresh()
            if owner.live():
                owner.signal_live(signal.SIGTERM)
                end = time.monotonic() + 3
                while owner.live() and time.monotonic() < end:
                    owner.refresh(); owner.reap_adopted(); time.sleep(.05)
                owner.signal_live(signal.SIGKILL)
            child.wait(timeout=5); owner.refresh(); owner.reap_adopted()
        path = root / 'partition-result.json'
        result = load(path) if path.exists() else {}
        row = {'design': design, 'episode': identifier, 'native_cpu': core,
               'ok': child.returncode == 0 and not timed_out and result.get('ok') is True and not owner.live() and not owner.ownership_errors and not owner.parse_errors,
               'returncode': child.returncode, 'timed_out': timed_out,
               'wall_s': time.monotonic() - started, 'work': result.get('work'),
               'result': {'path': str(path), 'sha256': sha(path)} if path.exists() else None,
               'owned_survivors': owner.live(), 'cleanup_signals': owner.signals,
               'ownership_errors': owner.ownership_errors, 'parse_errors': owner.parse_errors}
        save(logs / (identifier + '-terminal.json'), row)
        return row

    # OwnedProcesses adopts all children of this supervisor. Execute serially
    # so one arm's cleanup cannot adopt or signal the other arm's process tree.
    rows = [execute(job) for job in jobs]
    value = {'ok': all(r['ok'] for r in rows), 'cases': rows,
             'kernel_sha256': load(study / 'suite.json')['solver']['sha256'],
             'timing_disclosure': 'Supplementary feedback4 check after formal workflow; original pre-release0/3 evidence preserved, never backdated.',
             'no_model_calls': True, 'no_formal_policy_changes': True, 'no_retries': True,
             'source_compatibility': str(study / 'source-compatibility.json')}
    if summary_path.exists():
        raise FileExistsError(summary_path)
    save(summary_path, value)
    print(json.dumps({'supplementary_GP4_ok': value['ok'], 'summary': str(summary_path)}), flush=True)
    return value


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--study', required=True); p.add_argument('--workflow', required=True)
    a = p.parse_args()
    try:
        result = run(a.study, a.workflow)
        if not result['ok']:
            raise SystemExit(1)
    except Exception as exc:
        path = Path(a.study).resolve() / 'closeout-error.json'
        if not path.exists():
            save(path, {'class': type(exc).__name__, 'error': str(exc), 'no_automatic_retry': True})
        raise
