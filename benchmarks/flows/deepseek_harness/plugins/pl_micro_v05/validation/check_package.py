"""Check an isolated source package without running EDA or contacting a model."""
import argparse
import ast
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


def run(installed):
    source = Path(__file__).resolve().parents[1]
    if json.loads((installed / 'package.json').read_text())['version'] != '0.2.1-rc.2':
        raise ValueError('checks require the pinned DSH 0.2.1-rc.2 installation')
    with tempfile.TemporaryDirectory(prefix='pl-v05-clean-package-') as directory:
        package = Path(directory) / 'pl_micro_v05'
        shutil.copytree(source, package, ignore=shutil.ignore_patterns(
            '__pycache__', 'node_modules', '.git', 'episodes', 'audits', 'traces', 'cohort-runs'))
        (package / 'node_modules').symlink_to(installed / 'node_modules', target_is_directory=True)
        env = {k: v for k, v in os.environ.items()
               if not k.startswith(('IEDA_', 'GP_AGENT_'))}
        env.update(PYTHONDONTWRITEBYTECODE='1', PYTHONPATH=str(package / 'runtime'),
                   OMP_NUM_THREADS='1', OPENBLAS_NUM_THREADS='1', MKL_NUM_THREADS='1')
        for path in package.rglob('*.py'):
            ast.parse(path.read_text(), filename=str(path.relative_to(package)))
        for path in package.rglob('*.json'):
            json.loads(path.read_text())
        commands = [
            [sys.executable, 'validation/verify_package.py'],
            [sys.executable, 'validation/verify_queue_v05.py'],
            [sys.executable, 'validation/verify_process_supervisor.py'],
            ['node', '--check', 'lib/index.js'],
            ['node', '--check', 'validation/verify_frontend_v05.js'],
            ['node', 'validation/verify_frontend_v05.js', str(package / 'lib/index.js'),
             str(package / 'validation/fixtures/historical-parameter-errors.json')],
        ]
        for command in commands:
            subprocess.run(command, cwd=package, env=env, check=True)
    print(json.dumps({'ok': True, 'isolated_source_package': True,
                      'native_EDA_runs': 0, 'model_requests': 0}))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dsh-install', type=Path,
                        default=Path.home() / '.npm-global/lib/node_modules/@deepseek-ai/dsh')
    run(parser.parse_args().dsh_install)
