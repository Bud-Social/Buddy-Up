import time
import secrets
import hmac
import hashlib
import base64
import struct
import zlib
import logging
import datetime

from django.conf import settings

logger = logging.getLogger(__name__)


def _pack_uint16(x):
    return struct.pack('<H', int(x))


def _pack_uint32(x):
    return struct.pack('<I', int(x))


def _pack_string(s):
    if isinstance(s, bytes):
        data = s
    else:
        data = s.encode('utf-8')
    return _pack_uint16(len(data)) + data


def _pack_map_uint32(m):
    ret = _pack_uint16(len(m))
    for k, v in m.items():
        ret += _pack_uint16(k) + _pack_uint32(v)
    return ret


SERVICE_TYPE_RTC = 1

PRIVILEGE_JOIN_CHANNEL = 1
PRIVILEGE_PUBLISH_AUDIO = 2
PRIVILEGE_PUBLISH_VIDEO = 3
PRIVILEGE_PUBLISH_DATA = 4


def _build_rtc_service(channel_name, uid, role, expire_ts):
    privileges = {PRIVILEGE_JOIN_CHANNEL: expire_ts}
    if role == 1:
        privileges[PRIVILEGE_PUBLISH_AUDIO] = expire_ts
        privileges[PRIVILEGE_PUBLISH_VIDEO] = expire_ts
        privileges[PRIVILEGE_PUBLISH_DATA] = expire_ts

    uid_str = '' if uid == 0 else str(uid)
    return _pack_uint16(SERVICE_TYPE_RTC) + _pack_map_uint32(privileges) + _pack_string(channel_name) + _pack_string(uid_str)


def generate_agora_token(channel_name, uid=0, role='publisher', token_expire_sec=86400):
    app_id = getattr(settings, 'AGORA_APP_ID', '')
    app_certificate = getattr(settings, 'AGORA_APP_CERTIFICATE', '')

    if not app_id:
        logger.warning('AGORA_APP_ID not configured')
        return None
    if not app_certificate:
        logger.debug('AGORA_APP_CERTIFICATE not set — non-secure mode, no token needed')
        return None

    role_int = 1 if role == 'publisher' else 2

    now = int(time.time())
    expire_ts = now + token_expire_sec
    salt = secrets.SystemRandom().randint(1, 99999999)

    services_bytes = _build_rtc_service(channel_name, uid, role_int, expire_ts)

    signing = hmac.new(_pack_uint32(now), app_certificate.encode('utf-8'), hashlib.sha256).digest()
    signing = hmac.new(_pack_uint32(salt), signing, hashlib.sha256).digest()

    signing_info = _pack_string(app_id) + _pack_uint32(now) + _pack_uint32(expire_ts) + _pack_uint32(salt) + _pack_uint16(1) + services_bytes

    signature = hmac.new(signing, signing_info, hashlib.sha256).digest()

    message = _pack_string(signature) + signing_info

    compressed = zlib.compress(message)
    return '007' + base64.b64encode(compressed).decode('utf-8')


def generate_livekit_token(room_name, identity, display_name='', avatar_url='', metadata='', token_expire_sec=86400):
    api_key = getattr(settings, 'LIVEKIT_API_KEY', '')
    api_secret = getattr(settings, 'LIVEKIT_API_SECRET', '')

    if not api_key or not api_secret:
        logger.warning('LIVEKIT_API_KEY or LIVEKIT_API_SECRET not configured')
        return ''

    from livekit import api as livekit_api

    token = livekit_api.AccessToken(api_key, api_secret) \
        .with_identity(identity) \
        .with_name(display_name or identity) \
        .with_grants(
            livekit_api.VideoGrants(
                room_join=True,
                room=room_name,
                can_publish=True,
                can_subscribe=True,
            )
        ) \
        .with_ttl(datetime.timedelta(seconds=token_expire_sec))

    if avatar_url:
        token.with_metadata(avatar_url)
    elif metadata:
        token.with_metadata(metadata)

    return token.to_jwt()


def get_livekit_url():
    return getattr(settings, 'LIVEKIT_URL', '')


def generate_live_channel_id():
    return f"live_{secrets.token_hex(8)}"


def get_live_credentials(live, request=None, uid=None):
    agora_channel = live.agora_channel
    livekit_room = str(live.id)

    display_name = ''
    avatar_url = ''
    if uid:
        identity = str(uid)
    elif request and request.user.is_authenticated:
        profile = request.user.profile
        identity = str(profile.user_id)
        display_name = profile.display_name
        avatar_url = profile.avatar_url
    else:
        identity = f"anon_{secrets.token_hex(4)}"

    agora_token = generate_agora_token(agora_channel, uid=identity, role='publisher')
    livekit_token = generate_livekit_token(livekit_room, identity=identity, display_name=display_name, avatar_url=avatar_url)

    return {
        'agora': {
            'app_id': getattr(settings, 'AGORA_APP_ID', ''),
            'channel': agora_channel,
            'token': agora_token,
        },
        'livekit': {
            'url': get_livekit_url(),
            'room': livekit_room,
            'token': livekit_token,
        },
    }
