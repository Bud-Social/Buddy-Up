"""The dev toolbar must stay out of *both* test runners.

This module exists because of a bug that only showed up under pytest. The
original guard was::

    'test' in _sys.argv or 'pytest' in _sys.argv

`sys.argv` is a list, and `in` on a list tests exact element membership. Under
`manage.py test` the arguments really do include a bare `'test'`, so the guard
fired. Under a pytest console script the first argument is
`/usr/local/bin/pytest` -- never the bare string -- so the guard never fired and
debug-toolbar stayed installed for the entire pytest run.

That is not cosmetic. The toolbar reverse-resolves its own `djdt` namespace
when it renders, and in a test run that namespace is not wired, so any view
that rendered a template produced
``NoReverseMatch: 'djdt' is not a registered namespace`` instead of its real
error. Three marketplace tests passed under `manage.py test` and failed under
pytest with a template error that pointed nowhere near the actual cause.

These tests assert the decision, not the implementation, so rewriting the
guard in a way that works is allowed and rewriting it in a way that regresses
is not.
"""
import subprocess
import sys

from django.conf import settings
from django.test import SimpleTestCase

PROBE = """
import sys
from unittest import mock

argv = sys.argv[1:]
with mock.patch.object(sys, 'argv', argv):
    import importlib

    import config.settings.development as development
    importlib.reload(development)
    print('DISABLED' if development._TOOLBAR_DISABLED else 'ENABLED')
"""


def _decide(argv):
    """Run the guard in a subprocess so reloading settings cannot leak."""
    result = subprocess.run(
        [sys.executable, '-c', PROBE, *argv],
        capture_output=True,
        text=True,
        env={
            'DJANGO_SETTINGS_MODULE': 'config.settings.development',
            'PATH': __import__('os').environ.get('PATH', ''),
            'PYTHONPATH': __import__('os').environ.get('PYTHONPATH', ''),
            'HOME': __import__('os').environ.get('HOME', '/tmp'),
        },
    )
    return result.stdout.strip().splitlines()[-1] if result.stdout.strip() else f'ERROR: {result.stderr[-400:]}'


class DebugToolbarTestRunTests(SimpleTestCase):
    def test_disabled_under_manage_py_test(self):
        self.assertEqual(_decide(['manage.py', 'test', 'apps.gym']), 'DISABLED')

    def test_disabled_under_a_pytest_console_script(self):
        """The regression: argv[0] is a path, so this used to slip through."""
        self.assertEqual(_decide(['/usr/local/bin/pytest', '-q', '--no-cov']), 'DISABLED')

    def test_disabled_under_pytest_module_invocation(self):
        self.assertEqual(_decide(['/usr/bin/python', '-m', 'pytest', 'apps.gym']), 'DISABLED')

    def test_enabled_for_an_ordinary_dev_server(self):
        self.assertEqual(_decide(['manage.py', 'runserver', '0.0.0.0:8000']), 'ENABLED')

    def test_the_toolbar_is_not_installed_right_now(self):
        """Whatever argv this session was launched with, we are in a test run."""
        self.assertNotIn('debug_toolbar', settings.INSTALLED_APPS)