#!/usr/bin/env python3
"""Replay actual DEF publications through old/new serializers, without EDA/API.

The two fixtures are real large global-move publication and64-cell complement
masking. Exact output bytes are the regression oracle, not mirrored test code.
"""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import sys
import time


def load(path):
    return json.loads(Path(path).read_text())


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def module(path, name):
    specification = importlib.util.spec_from_file_location(name, path)
    value = importlib.util.module_from_spec(specification)
    specification.loader.exec_module(value)
    return value


def run(master, new_source, output):
    if output.exists():
        raise FileExistsError(output)
    study = master / 'main-v1'
    os.environ['IEDA_STUDY_ROOT'] = str(study)
    sys.path.insert(0, str(study))
    os.sched_setaffinity(0, {max(os.sched_getaffinity(0))})
    old_source = study / 'legal_refinement.py'
    old, new = module(old_source, 'frozen_serializer'), module(new_source, 'fixed_serializer')
    import work_budget
    if work_budget.ACTIVE is not None:
        raise RuntimeError('Pure serialization benchmark must not own a physical episode')
    rows = []
    jobs = [
        ('global-publication', study / 'episodes/c07-r0/transactions/t0020',
         study / 'episodes/c07-r0/legal-candidates/l19/result.json', 'placement.def'),
        ('local64-complement-mask', master / 'scope-v1/episodes/scope-a/transactions/t0000',
         study / 'episodes/c07-a2/legal-candidates/l00/result.json', 'masked.def'),
    ]
    for name, transaction, parent_result, expected_name in jobs:
        proof = load(transaction / 'proof.json')
        parent = Path(load(parent_result)['def']['path'])
        if sha(parent) != proof['parent_sha256']:
            raise RuntimeError('Fixture does not have the identical immutable parent')
        text, cells = parent.read_text(), old.coordinates(parent)
        blocks, selected = old.component_blocks(text), set(proof['selected_cells'])
        if expected_name == 'placement.def':
            after = old.coordinates(transaction / 'native.def')
            edits = [(blocks[n][0], blocks[n][1],
                      f"+ PLACED ( {after[n]['x']} {after[n]['y']} ) {after[n]['orient']}")
                     for n in sorted(selected)
                     if any(cells[n][k] != after[n][k] for k in ('x', 'y', 'orient'))]
            if len(edits) != proof['changed_count']:
                raise RuntimeError('Changed-cell reconstruction differs from actual transaction')
        else:
            edits = [(a, b, f"+ FIXED ( {cells[n]['x']} {cells[n]['y']} ) {cells[n]['orient']}")
                     for n, (a, b) in blocks.items() if cells[n]['status'] == 'PLACED' and n not in selected]
        expected = (transaction / expected_name).read_text()
        timings, results = {}, {}
        for label, function in [('frozen', old.rewrite), ('fixed', new.rewrite)]:
            started, cpu = time.monotonic(), time.process_time()
            results[label] = function(text, edits)
            timings[label] = {'wall_s': time.monotonic() - started, 'CPU_s': time.process_time() - cpu}
        passed = results['frozen'] == results['fixed'] == expected
        rows.append({'fixture': name, 'ok': passed, 'edits': len(edits),
                     'expected_DEF': str(transaction / expected_name),
                     'expected_DEF_sha256': sha(transaction / expected_name),
                     'parent_DEF_sha256': sha(parent), 'transaction_proof_sha256': sha(transaction / 'proof.json'),
                     'timings': timings, 'fixed_result_sha256': hashlib.sha256(results['fixed'].encode()).hexdigest()})
    result = {'ok': all(row['ok'] for row in rows), 'fixtures': rows,
              'native_or_API_calls': 0, 'new_or_retried_main_episodes': 0,
              'CPU_affinity': sorted(os.sched_getaffinity(0)),
              'frozen_source_sha256': sha(old_source), 'fixed_source_sha256': sha(new_source),
              'kernel_sha256': load(study / 'suite.json')['solver']['sha256'],
              'scope': 'Actual byte-equivalence and serializer-only cost. Budget guard and full transaction require separate technical execution. Main failure remains retained.'}
    with output.open('x') as stream:
        json.dump(result, stream, indent=2)
        stream.write('\n')
    print(json.dumps(result), flush=True)
    if not result['ok']:
        raise SystemExit(1)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--master', type=Path, required=True)
    parser.add_argument('--new-source', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    run(args.master.resolve(), args.new_source.resolve(), args.output.resolve())
