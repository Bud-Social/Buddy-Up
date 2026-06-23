import uuid
import secrets
from datetime import timedelta

from django.shortcuts import get_object_or_404
from django.db import models as db_models
from django.utils import timezone
from django.conf import settings

from rest_framework import views, permissions, status
from rest_framework.response import Response

from common.pagination import CursorPagination, PageNumberPagination
from .models import BuddyLive
from .serializers import BuddyLiveSerializer, CreateLiveSerializer, RandomDropRequestSerializer
from apps.profiles.models import BuddyRelationship, BlockRelationship


class LiveBrowserView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        tab = request.query_params.get('tab', 'live')
        category = request.query_params.get('category', '')

        if tab == 'live':
            queryset = BuddyLive.objects.filter(status='live').order_by('-viewer_peak')
        elif tab == 'scheduled':
            queryset = BuddyLive.objects.filter(status='scheduled', scheduled_for__gte=timezone.now()).order_by('scheduled_for')
        elif tab == 'replays':
            queryset = BuddyLive.objects.filter(status='ended', replay_saved=True).order_by('-ended_at')
        elif tab == 'upcoming':
            queryset = BuddyLive.objects.filter(status='scheduled', scheduled_for__gte=timezone.now()).order_by('scheduled_for')
        else:
            queryset = BuddyLive.objects.filter(status='live').order_by('-viewer_peak')

        if category:
            queryset = queryset.filter(category=category)

        paginator = CursorPagination()
        page = paginator.paginate_queryset(queryset.select_related('host'), request)
        serializer = BuddyLiveSerializer(page, many=True, context={'request': request})

        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': {
                'count': paginator.page.paginator.count,
                'next': paginator.get_next_link(),
                'previous': paginator.get_previous_link(),
            },
        })


class LiveDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, live_id):
        live = get_object_or_404(
            BuddyLive.objects.select_related('host'),
            id=live_id,
        )
        serializer = BuddyLiveSerializer(live, context={'request': request})
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class StartLiveView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = CreateLiveSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        channel_id = f"live_{secrets.token_hex(8)}"

        live = BuddyLive.objects.create(
            host=request.user.profile,
            title=data.get('title', 'Untitled Live'),
            live_type=data.get('live_type', 'open_sweat'),
            category=data.get('category', 'other'),
            access=data.get('access', 'public'),
            artifact_fee=data.get('artifact_fee'),
            gym_id=data.get('gym_id') if data.get('gym_id') else None,
            scheduled_for=data.get('scheduled_for'),
            is_recurring=data.get('is_recurring', False),
            recurrence_rule=data.get('recurrence_rule', ''),
            equipment_list=data.get('equipment_list', []),
            status='live' if not data.get('scheduled_for') else 'scheduled',
            started_at=timezone.now() if not data.get('scheduled_for') else None,
            agora_channel=channel_id,
        )

        if 'co_hosts' in data:
            live.co_hosts.set(data['co_hosts'])

        output = BuddyLiveSerializer(live, context={'request': request})
        return Response({
            'success': True,
            'data': output.data,
            'message': 'Live session created.',
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_201_CREATED)


class EndLiveView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, live_id):
        live = get_object_or_404(BuddyLive, id=live_id, host=request.user.profile)
        if live.status != 'live' and live.status != 'scheduled':
            return Response({
                'success': False, 'data': None,
                'message': 'This live has already ended.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        live.status = 'ended'
        live.ended_at = timezone.now()
        live.replay_saved = request.data.get('save_replay', False)
        live.save(update_fields=['status', 'ended_at', 'replay_saved'])

        # TODO: Trigger replay processing via Mux
        if live.replay_saved:
            from .tasks import process_live_replay
            process_live_replay.delay(str(live.id))

        return Response({
            'success': True,
            'data': None,
            'message': 'Live session ended.',
            'errors': None,
            'pagination': None,
        })


class JoinLiveView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, live_id):
        live = get_object_or_404(BuddyLive, id=live_id)

        if live.status == 'ended':
            return Response({
                'success': False, 'data': None,
                'message': 'This live has ended.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if live.access == 'buddies':
            is_buddy = BuddyRelationship.objects.filter(
                (db_models.Q(from_user=request.user.profile, to_user=live.host) |
                 db_models.Q(from_user=live.host, to_user=request.user.profile)),
                status='confirmed',
            ).exists()
            if not is_buddy and request.user.profile != live.host:
                return Response({
                    'success': False, 'data': None,
                    'message': 'This live is for buddies only.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_403_FORBIDDEN)

        if live.artifact_fee:
            # TODO: Deduct artifacts from wallet
            pass

        # TODO: Generate Agora token
        token = f"temp_token_{live.agora_channel}"

        return Response({
            'success': True,
            'data': {
                'agora_channel': live.agora_channel,
                'agora_token': token,
                'agora_app_id': settings.AGORA_APP_ID if hasattr(settings, 'AGORA_APP_ID') else '',
                'live_type': live.live_type,
            },
            'message': 'Joined live session.',
            'errors': None,
            'pagination': None,
        })


class RandomDropStartView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = RandomDropRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        from django.core.cache import cache
        pool_key = f"random_drop:{data['activity_type']}"
        entry = {
            'user_id': str(request.user.profile.user_id),
            'username': request.user.profile.username,
            'duration': data['duration'],
            'timestamp': timezone.now().isoformat(),
            'timezone': str(timezone.get_current_timezone()),
        }
        import json
        cache.zadd(pool_key, {json.dumps(entry): timezone.now().timestamp()})

        cache.set(
            f"random_drop_user:{request.user.profile.user_id}",
            json.dumps(entry),
            timeout=300,
        )

        return Response({
            'success': True,
            'data': {
                'status': 'searching',
                'timeout_seconds': 180,
                'activity_type': data['activity_type'],
            },
            'message': 'Searching for workout buddies...',
            'errors': None,
            'pagination': None,
        })


class RandomDropStatusView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        from django.core.cache import cache
        import json

        user_data = cache.get(f"random_drop_user:{request.user.profile.user_id}")
        if not user_data:
            return Response({
                'success': True,
                'data': {'status': 'not_searching'},
                'message': 'Not in match pool.',
                'errors': None,
                'pagination': None,
            })

        match_data = cache.get(f"random_drop_match:{request.user.profile.user_id}")
        if match_data:
            match = json.loads(match_data) if isinstance(match_data, str) else match_data
            return Response({
                'success': True,
                'data': {
                    'status': 'matched',
                    'agora_channel': match.get('channel'),
                    'agora_token': match.get('token'),
                },
                'message': 'Match found!',
                'errors': None,
                'pagination': None,
            })

        return Response({
            'success': True,
            'data': {'status': 'searching'},
            'message': 'Still searching...',
            'errors': None,
            'pagination': None,
        })

    def delete(self, request):
        from django.core.cache import cache
        cache.delete(f"random_drop_user:{request.user.profile.user_id}")
        return Response({
            'success': True, 'data': None,
            'message': 'Left the matching pool.',
            'errors': None, 'pagination': None,
        })


class GymScheduleView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_id):
        lives = BuddyLive.objects.filter(
            gym_id=gym_id,
            scheduled_for__gte=timezone.now(),
        ).order_by('scheduled_for').select_related('host')

        serializer = BuddyLiveSerializer(lives, many=True, context={'request': request})
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class RSVPLiveView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, live_id):
        live = get_object_or_404(BuddyLive, id=live_id, status='scheduled')
        # TODO: Store RSVP in Redis or DB
        return Response({
            'success': True,
            'data': None,
            'message': 'RSVP confirmed! You will be notified when the live starts.',
            'errors': None,
            'pagination': None,
        })
