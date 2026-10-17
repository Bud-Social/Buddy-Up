"""CORS preflight coverage for the custom headers the clients send.

A header the server does not allow fails *quietly*. The browser answers the
OPTIONS preflight with a 200, decides the header is not permitted, and never
sends the real request -- so the backend log shows a preflight and no GET, the
page renders, its fetch rejects, and the user is bounced somewhere useless with
no error anywhere that points at the cause.

That has now happened three times: 'idempotency-key' broke media uploads,
'x-device-id' broke every request, and 'x-totp-enrolment-token' broke staff 2FA
enrolment so /totp/setup flashed and dumped the user back on /login.

So rather than only pinning today's known headers, this walks the client
sources for the headers they actually send and requires every one of them to be
allowed. A new custom header cannot reach a client without this failing.
"""

import re
from pathlib import Path

from django.conf import settings
from django.test import SimpleTestCase

# Where the clients send headers from. Kept as explicit paths so a stray file
# cannot silently widen the scan.
CLIENT_SOURCES = (
    'frontend/src/api/client.ts',
    'frontend/src/api/auth.ts',
    'frontend/src/api/index.ts',
)

# The clients prefix custom headers with X-; anything they set on an axios
# config object or a headers dict is a candidate. Case-insensitive after the
# prefix: the enrolment header is sent as 'X-TOTP-Enrolment-Token'.
HEADER_USE = re.compile(
    r"""['"](?P<name>[xX]-[A-Za-z0-9-]+)['"]""",
)

# Headers that legitimately appear quoted but are not request headers the
# server must allow (e.g. header *names* asserted in tests, or response keys).
IGNORED = {'x-csrftoken'}


class CorsHeaderCoverageTests(SimpleTestCase):
    repo_root = Path(__file__).resolve().parents[2]

    def _client_headers(self):
        found = set()
        for relative in CLIENT_SOURCES:
            path = self.repo_root / relative
            if not path.exists():
                continue
            for match in HEADER_USE.finditer(path.read_text(encoding='utf-8')):
                name = match.group('name').lower()
                if name not in IGNORED:
                    found.add(name)
        return found

    def test_every_client_header_is_allowed(self):
        """No client-sent header may be missing from CORS_ALLOW_HEADERS."""
        client_headers = self._client_headers()
        self.assertTrue(
            client_headers,
            'No client headers found — the scan is broken, not the clients clean.',
        )

        allowed = {h.lower() for h in settings.CORS_ALLOW_HEADERS}
        missing = sorted(client_headers - allowed)

        self.assertEqual(
            missing,
            [],
            f'Client(s) send header(s) {missing} that CORS_ALLOW_HEADERS does not '
            'allow. Preflight will 200 and the browser will drop the request, '
            'so the failure looks like a hang or a redirect rather than a 403. '
            "Add each to CORS_ALLOW_HEADERS in config/settings/base.py.",
        )

    def test_totp_enrolment_header_is_allowed(self):
        """Named explicitly: this is the header that strands staff at /login."""
        allowed = {h.lower() for h in settings.CORS_ALLOW_HEADERS}
        self.assertIn('x-totp-enrolment-token', allowed)

    def test_known_client_headers_are_allowed(self):
        """The historical regressions, named so deleting one is deliberate."""
        allowed = {h.lower() for h in settings.CORS_ALLOW_HEADERS}
        for header in ('idempotency-key', 'x-device-id', 'x-totp-enrolment-token'):
            with self.subTest(header=header):
                self.assertIn(header, allowed)