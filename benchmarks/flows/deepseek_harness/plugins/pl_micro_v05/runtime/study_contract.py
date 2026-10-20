"""Fail closed when a materialized study or any frozen input has changed."""
from pathlib import Path
from common import ROOT, desc, load, save, sha


def freeze_manifest(root):
    root = Path(root).resolve()
    suite = load(root / 'suite.json')
    local = [*root.glob('*.py'), *root.glob('validation/*.py'), *root.glob('validation/*.js'), *root.glob('validation/fixtures/*.json'), *root.glob('*plan.json'),
             root / 'suite.json', root / 'experience.json',
             root / 'plugin/package.json', root / 'plugin/cordis.patch.yml',
             *root.glob('plugin/lib/*.js')]
    external = {}

    def collect(value):
        if isinstance(value, dict):
            if 'path' in value and 'sha256' in value:
                external[value['path']] = value
            else:
                for child in value.values():
                    collect(child)
        elif isinstance(value, list):
            for child in value:
                collect(child)

    for key in ('solver', 'original_solver', 'helpers', 'frozen_inputs'):
        collect(suite[key])
    for path in (root / 'helpers').glob('*.py'):
        item=desc(path);external[item['path']]=item
    for design, value in suite['designs'].items():
        for key in ('input_def', 'pl_config', 'sdc', 'tech_lef', 'macro_lef', 'inn_def'):
            item = desc(value[key]); external[item['path']] = item
        for path in value['libs'] + value['cell_lefs']:
            item = desc(path); external[item['path']] = item
        for role in ('ieda', 'inn'):
            path = root / 'references' / design / role / 'attempt-1/result.json'
            item = desc(path); external[item['path']] = item
            geometry = load(path)['metrics']['def']
            external[geometry['path']] = geometry
    result = {'schema': 'ieda.pl-study-lock.v05',
              'local': {str(p.relative_to(root)): desc(p)['sha256'] for p in sorted(set(local))},
              'external': sorted(external.values(), key=lambda x: x['path'])}
    save(root / 'study-lock.json', result)
    return result


def verify_study(root=ROOT):
    root = Path(root).resolve()
    manifest = load(root / 'study-lock.json')
    for name, expected in manifest['local'].items():
        if sha(root / name) != expected:
            raise RuntimeError('frozen study source/config changed: ' + name)
    for item in manifest['external']:
        if sha(item['path']) != item['sha256']:
            raise RuntimeError('frozen external asset changed: ' + item['path'])
    plan = load(root / 'paired-plan.json')
    if plan.get('study_phase', 'formal') == 'formal':
        evidence = plan.get('gate_evidence', {})
        if (plan.get('formal_gate') != 'open' or not evidence
                or sha(evidence['path']) != evidence['sha256']
                or not load(evidence['path']).get('ok')):
            raise RuntimeError('formal release gate closed or invalid')
    return manifest
