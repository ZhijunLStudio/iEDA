"""Portable publication checks: no physical solver, credentials or model calls."""
import hashlib
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

PACKAGE = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(PACKAGE), str(PACKAGE / 'runtime')]
from episode_runner import configured_provider, gateway_connection
from materialize_study import materialize
from study_contract import verify_study


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


class PublicationChecks(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix='pl-v05-publication-')
        self.root = Path(self.directory.name)

    def tearDown(self):
        self.directory.cleanup()

    def profile(self, url):
        path = self.root / 'profile.yml'
        path.write_text('- id: llm-deepseek\n  config:\n    baseURL: ' + url + '\n')
        return path

    def test_gateway_must_be_explicitly_frozen(self):
        with self.assertRaisesRegex(ValueError, 'gateway_base_url'):
            configured_provider(self.profile('http://localhost:8317/v1'), {})

    def test_profile_cannot_silently_change_gateway(self):
        with self.assertRaisesRegex(ValueError, 'differs'):
            configured_provider(self.profile('http://localhost:8318/v1'),
                                {'gateway_base_url': 'http://localhost:8317/v1'})

    def test_http_and_https_configuration(self):
        for url in ('http://localhost:8317/v1', 'https://gateway.example/v1'):
            with self.subTest(url=url):
                self.assertEqual(configured_provider(self.profile(url),
                    {'gateway_base_url': url + '/'})['baseURL'], url)

    def test_gateway_rejects_credentials_or_ambiguous_paths(self):
        for url in ('http://user:password@localhost/v1', 'file:///v1',
                    'http://localhost/v2', 'http://localhost/v1?key=value',
                    'http://localhost/v1#fragment'):
            with self.subTest(url=url), self.assertRaises(ValueError):
                configured_provider(self.profile(url), {'gateway_base_url': url})

    def test_transport_selection_without_network(self):
        with patch('http.client.HTTPConnection') as http, patch('http.client.HTTPSConnection') as https:
            gateway_connection({'baseURL': 'http://localhost:8317/v1'}, 7)
            http.assert_called_once_with('localhost', 8317, timeout=7)
            https.assert_not_called()
            gateway_connection({'baseURL': 'https://gateway.example/v1'}, 9)
            https.assert_called_once_with('gateway.example', None, timeout=9)

    def fixture(self):
        helpers = self.root / 'helpers'
        helpers.mkdir()
        for source in (PACKAGE / 'helpers').glob('*.py'):
            (helpers / source.name).write_bytes(source.read_bytes())
        assets = {}
        for name in ('input.def', 'pl_config.json', 'default.sdc', 'tech.lef',
                     'cells.lef', 'cells.lib', 'inn.def', 'solver'):
            path = self.root / name
            path.write_text('Synthetic packaging fixture only; never executed.\n')
            assets[name] = str(path)
        descriptor = lambda p: {'path': str(p), 'sha256': digest(p)}
        design = {key: assets[name] for key, name in (
            ('input_def', 'input.def'), ('pl_config', 'pl_config.json'),
            ('sdc', 'default.sdc'), ('tech_lef', 'tech.lef'),
            ('macro_lef', 'cells.lef'), ('inn_def', 'inn.def'))}
        design.update(libs=[assets['cells.lib']], cell_lefs=[assets['cells.lef']])
        suite = {'designs': {'case': design}, 'solver': descriptor(assets['solver']),
                 'original_solver': descriptor(assets['solver']), 'frozen_inputs': [],
                 'helpers': [descriptor(p) for p in (PACKAGE / 'helpers').glob('*.py')]}
        # Technical only: this is not an open formal gate or a placement result.
        plan = {'arms': {'technical': {'budget': {}}}, 'agent': [], 'rule': [],
                'study_phase': 'technical', 'formal_gate': 'closed'}
        refs = self.root / 'references'
        for role in ('ieda', 'inn'):
            path = refs / 'case' / role / 'attempt-1'
            path.mkdir(parents=True)
            (path / 'result.json').write_text(json.dumps(
                {'metrics': {'def': descriptor(assets['input.def'])}}))
        paths = []
        for name, value in (('suite', suite), ('plan', plan), ('experience', {'case': {}})):
            path = self.root / (name + '.json')
            path.write_text(json.dumps(value))
            paths.append(path)
        return paths, helpers, refs

    def test_selected_helpers_must_match_frozen_suite(self):
        paths, helpers, refs = self.fixture()
        (helpers / 'def_hpwl_eval.py').write_text('# altered helper\n')
        output = self.root / 'study'
        with self.assertRaisesRegex(ValueError, 'measurement helper differs'):
            materialize(output, *paths, helpers, refs)
        self.assertFalse(output.exists())

    def test_study_materializes_without_backend_or_api(self):
        paths, helpers, refs = self.fixture()
        output = materialize(self.root / 'study', *paths, helpers, refs)
        manifest = verify_study(output)
        self.assertIn('validation/fixtures/historical-parameter-errors.json', manifest['local'])
        self.assertFalse((output / 'episodes').exists())
        self.assertFalse((output / 'plugin/node_modules').exists())
        with self.assertRaises(FileExistsError):
            materialize(output, *paths, helpers, refs)
        # The selected helpers differ in path from suite.helpers; both are frozen.
        (helpers / 'def_identity.py').write_text('# changed selected helper\n')
        with self.assertRaisesRegex(RuntimeError, 'external asset changed'):
            verify_study(output)

    def test_bundled_helpers_match_the_validated_hashes(self):
        recorded = json.loads((PACKAGE / 'helpers/provenance.json').read_text())
        for name, expected in recorded['files'].items():
            self.assertEqual(digest(PACKAGE / 'helpers' / name), expected)


if __name__ == '__main__':
    unittest.main(verbosity=2)
