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
    query_string = scope.get('query_string', b'').decode('utf-8')
    for part in query_string.split('&'):
        if part.startswith('token='):
            return part[6:]
    return None
