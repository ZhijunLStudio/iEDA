"""Episode-local cache keyed by geometry, every measurement asset and code."""
import copy
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
from common import ROOT, load, sha, desc, native_env, native_cpu


class EvaluationCache:
    def __init__(self):
        self.entries = {}

    def fingerprint(self, design, final_def):
        suite = load(ROOT / 'suite.json')
        paths = {str(Path(final_def).resolve()), str(Path(design['input_def']).resolve()),
                 str(Path(design['pl_config']).resolve()), str(Path(design['sdc']).resolve()),
                 str(Path(design['tech_lef']).resolve()), str(Path(design['macro_lef']).resolve()),
                 str(Path(suite['solver']['path']).resolve())}
        paths.update(str(Path(p).resolve()) for p in design['libs'] + design['cell_lefs'])
        paths.update(str(p.resolve()) for p in Path(__file__).parent.glob('*.py'))
        paths.update(str(p.resolve()) for p in (ROOT / 'helpers').glob('*.py'))
        paths.add('/usr/bin/taskset')
        dynamic = subprocess.run(['ldd', suite['solver']['path']], capture_output=True,
                                 text=True, timeout=15, env=native_env())
        if dynamic.returncode:
            raise RuntimeError('cannot identify measurement shared-library dependencies')
        for match in re.finditer(r'(/[^\s()]+)', dynamic.stdout):
            if Path(match[1]).is_file():
                paths.add(str(Path(match[1]).resolve()))
        assets = {p: sha(p) for p in sorted(paths)}
        context = {'schema': 'pl-evaluation-fingerprint-v05', 'assets': assets,
                   'design_metadata': design, 'grid': [64, 64], 'timing': 'HPWL-RC',
                   'paths': 'setup64+hold64',
                   'native_resources': {k: native_env()[k] for k in ('OMP_NUM_THREADS','OMP_THREAD_LIMIT','RAYON_NUM_THREADS','MALLOC_ARENA_MAX')},
                   'native_CPU_affinity':[native_cpu()],
                   'loader_environment': {k: os.environ.get(k) for k in ('LD_LIBRARY_PATH', 'LD_PRELOAD')}}
        # Paths identify context; geometry identity itself must not depend on
        # which proposal filename contains those exact bytes.
        context['assets'].pop(str(Path(final_def).resolve()), None)
        context['def_sha256'] = sha(final_def)
        key = hashlib.sha256(json.dumps(context, sort_keys=True).encode()).hexdigest()
        return key, context

    def get(self, key):
        entry = self.entries.get(key)
        if not entry:
            return None
        if any(sha(item['path']) != item['sha256'] for item in entry['evidence']):
            raise RuntimeError('cached measurement evidence changed')
        value = copy.deepcopy(entry['value'])
        value['cache'] = {'hit': True, 'fingerprint': key, 'new_native_execution': False}
        return value

    def put(self, key, value):
        if not value.get('ok'):
            return
        directory = Path(value['terminal']['log']['path']).parent
        names = ('metrics.json', 'congestion_result.json', 'rudy_util.csv', 'timing_result.json', 'paths.json')
        self.entries[key] = {'value': copy.deepcopy(value),
                             'evidence': [desc(directory / name) for name in names]}
