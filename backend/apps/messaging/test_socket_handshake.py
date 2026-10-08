"""WebSocket handshake tests: Origin policy and rejection close codes.

These lock down the two properties that made the mobile chat failure so hard
to diagnose:

1. ``config.origin.NativeFriendlyOriginValidator`` lets a native handshake (no
   ``Origin`` header at all) through while still refusing a browser whose
   ``Origin`` is not in ``ALLOWED_HOSTS``. The stock Channels validator denies
   both, which is why every Flutter connection was rejected with a bare
   ``HTTP/1.1 403 Access denied``.
2. ``ChatConsumer`` refuses a bad token (4001) and a non-member (4003) by
   accepting first and closing second, so the code survives to the client.
   Daphne's ``serverReject()`` discards any close issued while the connection
   is still CONNECTING and answers ``403 Access denied`` instead, which is why
   clients could only ever observe close code 1006.

The tests drive the real ASGI application (``config.asgi.application``) through
``WebsocketCommunicator``, so the origin validator, the auth middleware, the
URL router and the consumer are all exercised together — the same chain a real
handshake walks.
"""
import asyncio
import logging

from channels.auth import AuthMiddlewareStack
from channels.routing import URLRouter
from channels.security.websocket import AllowedHostsOriginValidator
from channels.testing import WebsocketCommunicator
from django.test import TestCase, TransactionTestCase, override_settings
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.messaging.models import Conversation
from apps.messaging.routing import websocket_urlpatterns
from apps.profiles.models import Profile

from config.origin import native_friendly_origin_validator


def _stack():
    """The inner half of config.asgi's websocket branch, so a test can wrap it
    in whichever Origin validator it is exercising."""
    return AuthMiddlewareStack(URLRouter(websocket_urlpatterns))


def _origin_header(origin):
    return [(b'origin', origin.encode('latin1'))]


def _silence_consumer_logger(case):
    """Keeps the reject warnings these tests deliberately provoke out of the
    test output. Tests that assert on them use assertLogs, which installs its
    own handler regardless."""
    logger = logging.getLogger('apps.messaging.consumers')
    previous_handlers, previous_propagate = logger.handlers, logger.propagate
    logger.handlers = [logging.NullHandler()]
    logger.propagate = False
    case.addCleanup(lambda: _restore(logger, previous_handlers, previous_propagate))


def _restore(logger, handlers, propagate):
    logger.handlers = handlers
    logger.propagate = propagate


class _Verdict(Exception):
    """Internal: the Origin check has spoken — unwind before the denier loops."""


def _validates(validator_factory, origin):
    """True when the validator factory lets an `origin` handshake through.

    The factory is wrapped around a no-op inner application, so this exercises
    the Origin check alone — no router, auth stack or database involved. The
    first message the application emits is the verdict, so the walk is aborted
    as soon as it arrives (the deny path is a consumer that would otherwise sit
    on the channel layer forever).
    """
    async def inner(scope, receive, send):
        await send({'type': 'websocket.accept'})

    wrapped = validator_factory(inner)
    scope = {
        'type': 'websocket', 'path': '/ws/', 'query_string': b'',
        'headers': _origin_header(origin),
    }

    async def receive():
        return {'type': 'websocket.connect'}

    sent = []

    async def run():
        async def send(message):
            sent.append(message)
            raise _Verdict

        await wrapped(scope, receive, send)

    try:
        asyncio.run(run())
    except _Verdict:
        pass
    return bool(sent) and sent[0]['type'] == 'websocket.accept'


def _run(application, path, subprotocols=None, headers=None):
    """Drives one handshake and returns (accepted, subprotocol, messages)."""
    async def drive():
        communicator = WebsocketCommunicator(
            application, path, subprotocols=subprotocols or [], headers=headers,
        )
        accepted, subprotocol = await communicator.connect()
        messages = []
        # Anything after the handshake (the reject close frames) shows up here.
        while True:
            try:
                messages.append(await communicator.receive_output(timeout=1))
            except asyncio.TimeoutError:
                break
        return accepted, subprotocol, messages

    return asyncio.run(drive())


class WebSocketOriginPolicyTests(TransactionTestCase):
    """The Origin check is what separates native clients from cross-site ones.

    TransactionTestCase, not TestCase: an *accepted* handshake goes on to
    resolve a profile and a membership row through ``database_sync_to_async``,
    which reaches sqlite from a thread executor and cannot see an in-transaction
    TestCase connection.
    """

    def setUp(self):
        _silence_consumer_logger(self)
        self.user = User.objects.create_user(
            email='origin-policy@example.com', password='TestPass123!',
        )
        self.profile = Profile.objects.create(
            user=self.user, username='origin-policy', display_name='Origin',
        )
        self.conv = Conversation.objects.create(is_group=False)
        self.conv.participants.add(self.profile)
        self.token = str(RefreshToken.for_user(self.user).access_token)
        self.path = f'/ws/conversation/{self.conv.id}/'

    @override_settings(ALLOWED_HOSTS=['testserver', 'buddyup.app'], DEBUG=False)
    def test_absent_origin_is_allowed_for_native_clients(self):
        # dart:io — and every other non-browser client — sends no Origin at all.
        # This is the case that returned 403 on every single mobile connection.
        accepted, _, _ = _run(
            native_friendly_origin_validator(_stack()),
            self.path,
            subprotocols=['bearer', self.token],
        )
        self.assertTrue(accepted)

    @override_settings(ALLOWED_HOSTS=['testserver', 'buddyup.app'], DEBUG=False)
    def test_disallowed_origin_is_still_rejected(self):
        # The cross-site protection browsers rely on must survive the waiver.
        accepted, _, _ = _run(
            native_friendly_origin_validator(_stack()),
            self.path,
            subprotocols=['bearer', self.token],
            headers=_origin_header('http://evil.example.com'),
        )
        self.assertFalse(accepted)

    @override_settings(ALLOWED_HOSTS=['testserver', 'buddyup.app'], DEBUG=False)
    def test_allowed_origin_is_accepted(self):
        accepted, _, _ = _run(
            native_friendly_origin_validator(_stack()),
            self.path,
            subprotocols=['bearer', self.token],
            headers=_origin_header('http://testserver'),
        )
        self.assertTrue(accepted)

    @override_settings(ALLOWED_HOSTS=['testserver', 'buddyup.app'], DEBUG=False)
    def test_lookalike_host_is_rejected(self):
        # Suffix-matching a trusted domain is the classic bypass.
        accepted, _, _ = _run(
            native_friendly_origin_validator(_stack()),
            self.path,
            subprotocols=['bearer', self.token],
            headers=_origin_header('http://notbuddyup.app'),
        )
        self.assertFalse(accepted)

    @override_settings(ALLOWED_HOSTS=['https://testserver'], DEBUG=False)
    def test_scheme_bearing_allowed_host_is_matched_by_channels(self):
        # Bare hostnames in ALLOWED_HOSTS are matched on host alone (that is
        # Channels' own semantics, unchanged here). When an entry does carry a
        # scheme, scheme and port are part of the match — which is why this
        # delegates to the stock matcher instead of hand-rolling one.
        self.assertTrue(_validates(native_friendly_origin_validator, 'https://testserver'))
        self.assertFalse(_validates(native_friendly_origin_validator, 'http://testserver'))

    @override_settings(ALLOWED_HOSTS=['testserver', 'buddyup.app'], DEBUG=False)
    def test_stock_validator_rejects_the_same_handshake_that_now_passes(self):
        # Pins the regression: this exact request is refused by
        # AllowedHostsOriginValidator. Without it, re-introducing the stock
        # validator would silently re-break every native client.
        accepted, _, _ = _run(
            AllowedHostsOriginValidator(_stack()),
            self.path,
            subprotocols=['bearer', self.token],
        )
        self.assertFalse(accepted)


class ChatConsumerHandshakeTests(TransactionTestCase):
    """Reject paths must produce an observable 4001/4003, not a bare 403."""

    def setUp(self):
        _silence_consumer_logger(self)
        self.user = User.objects.create_user(
            email='ws-handshake@example.com', password='TestPass123!',
        )
        self.profile = Profile.objects.create(
            user=self.user, username='ws-handshake', display_name='Handshake',
        )
        self.outsider = User.objects.create_user(
            email='ws-outsider@example.com', password='TestPass123!',
        )
        self.outsider_profile = Profile.objects.create(
            user=self.outsider, username='ws-outsider', display_name='Outsider',
        )
        self.conv = Conversation.objects.create(is_group=False)
        self.conv.participants.add(self.profile)
        self.path = f'/ws/conversation/{self.conv.id}/'
        self.app = native_friendly_origin_validator(_stack())

    def _connect(self, subprotocols):
        return _run(self.app, self.path, subprotocols=subprotocols)

    def test_member_is_accepted_and_joins_the_group(self):
        token = str(RefreshToken.for_user(self.user).access_token)
        accepted, _, messages = self._connect(['bearer', token])
        self.assertTrue(accepted)
        self.assertEqual([m['type'] for m in messages if m['type'] != 'websocket.send'], [])

    def test_bad_token_accepts_then_closes_with_4001(self):
        accepted, _, messages = self._connect(['bearer', 'not-a-real-token'])
        # Accepting first is the whole point: a pre-accept close becomes a bare
        # 403 from daphne and the code below would never reach the client.
        self.assertTrue(accepted)
        self.assertEqual(
            [m for m in messages if m['type'] == 'websocket.close'],
            [{'type': 'websocket.close', 'code': 4001}],
        )

    def test_missing_token_accepts_then_closes_with_4001(self):
        accepted, _, messages = self._connect([])
        self.assertTrue(accepted)
        self.assertEqual(
            [m for m in messages if m['type'] == 'websocket.close'],
            [{'type': 'websocket.close', 'code': 4001}],
        )

    def test_non_member_accepts_then_closes_with_4003(self):
        token = str(RefreshToken.for_user(self.outsider).access_token)
        accepted, _, messages = self._connect(['bearer', token])
        self.assertTrue(accepted)
        self.assertEqual(
            [m for m in messages if m['type'] == 'websocket.close'],
            [{'type': 'websocket.close', 'code': 4003}],
        )

    def test_query_string_token_still_authenticates(self):
        # Legacy native path: ?token= on the URL, no subprotocol.
        accepted, _, _ = _run(
            self.app, f'{self.path}?token={RefreshToken.for_user(self.user).access_token}',
        )
        self.assertTrue(accepted)

    def test_rejection_is_logged_with_reason_and_ids(self):
        token = str(RefreshToken.for_user(self.outsider).access_token)
        with self.assertLogs('apps.messaging.consumers', level='WARNING') as captured:
            self._connect(['bearer', token])

        joined = '\n'.join(captured.output)
        self.assertIn('ws rejected', joined)
        self.assertIn('not a member', joined)
        self.assertIn(str(self.conv.id), joined)
        self.assertIn(str(self.outsider.id), joined)
        # Tokens must never reach the logs.
        self.assertNotIn(token, joined)

    def test_bad_token_rejection_is_logged_without_the_token(self):
        with self.assertLogs('apps.messaging.consumers', level='WARNING') as captured:
            self._connect(['bearer', 'super-secret-token-value'])

        joined = '\n'.join(captured.output)
        self.assertIn('bad token', joined)
        self.assertIn(str(self.conv.id), joined)
        self.assertNotIn('super-secret-token-value', joined)


class ChatTokenCarrierTests(TestCase):
    """The token rides Sec-WebSocket-Protocol, with ?token= kept as a fallback."""

    def setUp(self):
        self.user = User.objects.create_user(
            email='ws-carrier@example.com', password='TestPass123!',
        )
        self.token = str(RefreshToken.for_user(self.user).access_token)

    def test_subprotocol_pair_is_read_from_scope(self):
        from .auth import get_token_from_scope

        scope = {'subprotocols': ['bearer', self.token], 'query_string': b''}
        self.assertEqual(get_token_from_scope(scope), self.token)
        # Scope is scrubbed so no handshake response can echo the token back.
        self.assertEqual(scope['subprotocols'], [b'bearer'])

    def test_query_token_is_still_accepted(self):
        from .auth import get_token_from_scope

        scope = {'subprotocols': [], 'query_string': b'token=abc123&x=1'}
        self.assertEqual(get_token_from_scope(scope), 'abc123')

    def test_absent_token_yields_none(self):
        from .auth import get_token_from_scope

        self.assertIsNone(get_token_from_scope({'subprotocols': [], 'query_string': b''}))