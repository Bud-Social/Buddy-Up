from django.contrib.auth.models import AnonymousUser
from channels.db import database_sync_to_async
from rest_framework_simplejwt.tokens import AccessToken
from rest_framework_simplejwt.exceptions import TokenError, InvalidToken


@database_sync_to_async
def get_user_from_token(token_str):
    from apps.accounts.models import User
    try:
        access = AccessToken(token_str)
        user = User.objects.get(id=access['user_id'])
        return user
    except (TokenError, InvalidToken, User.DoesNotExist, KeyError):
        return AnonymousUser()


def get_token_from_scope(scope):
    """Extract the access token from the websocket scope.

    Preferred carrier is the Sec-WebSocket-Protocol header: the browser
    cannot set arbitrary headers on WebSocket connects, and putting tokens
    in the query string leaks them into access logs, proxies and referrers.
    The client connects with subprotocols ['bearer', token]; we read the
    token from there and strip it from scope so it can never be echoed back
    in the handshake response. The legacy ?token= query parameter is still
    accepted for native clients (no header support there).
    """
    subprotocols = scope.get('subprotocols') or []
    if len(subprotocols) >= 2:
        first, second = subprotocols[0], subprotocols[1]
        if isinstance(first, bytes):
            first = first.decode('utf-8', errors='ignore')
        if isinstance(second, bytes):
            second = second.decode('utf-8', errors='ignore')
        if first == 'bearer' and second:
            # Keep only a harmless marker so no echo ever contains the token.
            scope['subprotocols'] = [b'bearer']
            return second
    query_string = scope.get('query_string', b'').decode('utf-8')
    for part in query_string.split('&'):
        if part.startswith('token='):
            return part[6:]
    return None
