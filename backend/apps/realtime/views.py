import hashlib
import json
import logging
import secrets
from uuid import UUID

from django.conf import settings
from django.db import transaction
from django.http import JsonResponse
from django.utils import timezone
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from rest_framework import permissions, status, views
from rest_framework.response import Response

from .models import RealtimeWebhookEvent

logger = logging.getLogger(__name__)


class RealtimeHealthView(views.APIView):
    """Small operator probe; it does not expose credentials or room data."""

    permission_classes = [permissions.AllowAny]

    def get(self, request):
        expected = getattr(settings, 'REALTIME_HEALTH_TOKEN', '')
        supplied = request.headers.get('X-Realtime-Health-Token', '')
        if expected and not secrets.compare_digest(expected, supplied):
            return Response({'ok': False, 'message': 'Not authorised.'}, status=status.HTTP_401_UNAUTHORIZED)
        api_key = getattr(settings, 'LIVEKIT_API_KEY', '')
        api_secret = getattr(settings, 'LIVEKIT_API_SECRET', '')
        livekit_url = getattr(settings, 'LIVEKIT_URL', '')
        configured = bool(api_key and api_secret and livekit_url)
        return Response({
            'ok': configured,
            'transport': getattr(settings, 'REALTIME_TRANSPORT', 'livekit'),
            'livekit_url': livekit_url,
            'credentials_configured': configured,
            'webhooks_enabled': bool(getattr(settings, 'REALTIME_WEBHOOK_ENABLED', True)),
            'token_ttl_seconds': int(getattr(settings, 'REALTIME_TOKEN_TTL', 900)),
            'checked_at': timezone.now().isoformat(),
        }, status=status.HTTP_200_OK if configured else status.HTTP_503_SERVICE_UNAVAILABLE)


def _webhook_value(event, name, default=''):
    value = getattr(event, name, default)
    return value if value is not None else default


def _room_name(event):
    room = getattr(event, 'room', None)
    return _webhook_value(room, 'name', '') if room else ''


def _participant_identity(event):
    participant = getattr(event, 'participant', None)
    return _webhook_value(participant, 'identity', '') if participant else ''


def _reconcile_call_event(event_type, room_name, identity):
    """Reconcile only durable membership state; media remains SFU-owned."""
    if not room_name.startswith('convo_'):
        return
    from apps.messaging.models import CallParticipant, CallSession
    from apps.profiles.models import Profile

    session = CallSession.objects.filter(room_name=room_name, status__in=('ringing', 'active')).first()
    if not session or not identity:
        return
    try:
        profile = Profile.objects.get(user_id=UUID(identity))
    except (ValueError, Profile.DoesNotExist):
        return
    participant = CallParticipant.objects.filter(session=session, profile=profile).first()
    if participant is None:
        return
    if event_type in ('participant_joined', 'participant_active'):
        if participant.joined_at is None:
            participant.joined_at = timezone.now()
        participant.left_at = None
        participant.save(update_fields=['joined_at', 'left_at', 'updated_at'])
    elif event_type in ('participant_left', 'participant_joined_timeout'):
        participant.left_at = participant.left_at or timezone.now()
        participant.save(update_fields=['left_at', 'updated_at'])


@method_decorator(csrf_exempt, name='dispatch')
class LiveKitWebhookView(views.APIView):
    """Receive signed, replay-safe LiveKit lifecycle events.

    LiveKit remains the media plane; this endpoint only reconciles durable
    call membership and records an idempotency event for later observability.
    """

    authentication_classes = []
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        if not getattr(settings, 'REALTIME_WEBHOOK_ENABLED', True):
            return Response({'ok': False, 'message': 'Webhooks disabled.'}, status=status.HTTP_404_NOT_FOUND)
        body = request.body
        authorization = request.headers.get('Authorization', '')
        try:
            from livekit import api as livekit_api
            event = livekit_api.WebhookReceiver(
                getattr(settings, 'LIVEKIT_API_KEY', ''),
                getattr(settings, 'LIVEKIT_API_SECRET', ''),
            ).receive(body.decode('utf-8'), authorization)
        except Exception as exc:  # noqa: BLE001
            logger.warning('Rejected LiveKit webhook: %s', exc)
            return Response({'ok': False, 'message': 'Invalid webhook signature.'}, status=status.HTTP_401_UNAUTHORIZED)

        try:
            raw = json.loads(body.decode('utf-8'))
        except (TypeError, ValueError):
            raw = {}
        event_type = _webhook_value(event, 'event', '')
        event_id = _webhook_value(event, 'id', '') or raw.get('id')
        if not event_id:
            event_id = hashlib.sha256(body).hexdigest()
        room_name = _room_name(event)
        payload_hash = hashlib.sha256(body).hexdigest()
        with transaction.atomic():
            record, created = RealtimeWebhookEvent.objects.get_or_create(
                event_id=str(event_id),
                defaults={
                    'event_type': event_type,
                    'room_name': room_name,
                    'payload_hash': payload_hash,
                },
            )
            if created:
                _reconcile_call_event(event_type, room_name, _participant_identity(event))
        return Response({'ok': True, 'duplicate': not created}, status=status.HTTP_200_OK)
