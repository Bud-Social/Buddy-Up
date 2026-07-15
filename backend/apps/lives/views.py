from django.shortcuts import get_object_or_404
from django.db import models as db_models
from django.utils import timezone
from django.core.cache import cache

from rest_framework import views, permissions, status
from rest_framework.response import Response

from common.pagination import CursorPagination
from .models import BuddyLive, LiveAttendee
from .serializers import (
    BuddyLiveSerializer, CreateLiveSerializer, RandomDropRequestSerializer,
    LiveAttendeeSerializer, EndLiveInputSerializer, CoHostInputSerializer,
    RecordingChunkInputSerializer,
)
from .provider_service import get_live_credentials, generate_live_channel_id
from .access import can_access_live, has_live_admission, may_publish_media
from apps.profiles.models import Profile, BuddyRelationship
from apps.wallet.models import ArtifactTransaction


def get_live_viewer_count(live_id):
    try:
        return cache.scard(f'live_viewers:{live_id}')
    except (AttributeError, TypeError):
        return 0


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

        count = queryset.count()
        paginator = CursorPagination()
        page = paginator.paginate_queryset(queryset.select_related('host'), request)
        serializer = BuddyLiveSerializer(page, many=True, context={'request': request})

        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': {
                'count': count,
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
        live.viewer_count_cache = get_live_viewer_count(str(live.id))
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
        # Prevent starting a second concurrent live session
        existing_live = BuddyLive.objects.filter(
            host=request.user.profile, status='live'
        ).first()
        if existing_live:
            return Response({
                'success': False,
                'data': None,
                'message': 'You already have an active live session. End it before starting a new one.',
                'errors': None,
                'pagination': None,
            }, status=status.HTTP_409_CONFLICT)

        serializer = CreateLiveSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        channel_id = generate_live_channel_id()

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

        credentials = get_live_credentials(
            live, request, can_publish=may_publish_media(live, request.user.profile),
        )

        if live.status == 'live':
            from apps.notifications.tasks import send_live_started_notification
            send_live_started_notification.delay(str(live.id), str(request.user.profile.user_id))

        if live.status == 'live':
            from .tasks import start_livekit_recording
            start_livekit_recording.delay(str(live.id))

        output = BuddyLiveSerializer(live, context={'request': request})
        return Response({
            'success': True,
            'data': {
                'live': output.data,
                'credentials': credentials,
            },
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
        serializer = EndLiveInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        live.replay_saved = serializer.validated_data['save_replay']
        live.save(update_fields=['status', 'ended_at', 'replay_saved'])

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

        user = request.user.profile
        if not can_access_live(live, user):
            return Response({
                'success': False, 'data': None,
                'message': 'You do not have access to this live session.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)

        # Rejoining must never charge the entry fee twice.
        already_admitted = has_live_admission(live, user)

        if live.artifact_fee and not already_admitted:
            from apps.wallet.utils import deduct_artifacts, credit_artifacts, platform_cut
            from apps.wallet.models import ArtifactTransaction

            for art_type, qty in live.artifact_fee.items():
                if qty > 0:
                    if not deduct_artifacts(request.user.profile, art_type, qty):
                        return Response({
                            'success': False, 'data': None,
                            'message': f'Insufficient {art_type} artifacts. Need {qty}.',
                            'errors': None, 'pagination': None,
                        }, status=status.HTTP_402_PAYMENT_REQUIRED)
                    cut = platform_cut('live_fee', art_type, qty)
                    host_credit = qty - cut
                    if host_credit > 0:
                        credit_artifacts(live.host, art_type, host_credit)
                    ArtifactTransaction.objects.create(
                        user=request.user.profile, transaction_type='live_fee',
                        artifact_type=art_type, quantity=qty, direction='debit',
                        counterparty=live.host, status='completed',
                    )
                    if host_credit > 0:
                        ArtifactTransaction.objects.create(
                            user=live.host, transaction_type='live_fee',
                            artifact_type=art_type, quantity=host_credit, direction='credit',
                            counterparty=request.user.profile, status='completed',
                        )

        credentials = get_live_credentials(
            live, request, can_publish=may_publish_media(live, user),
        )

        # Track attendee
        role = 'host' if user == live.host else 'co_host' if live.co_hosts.filter(id=user.id).exists() else 'attendee'
        LiveAttendee.objects.update_or_create(
            live=live, user=user,
            defaults={'role': role, 'left_at': None},
        )

        return Response({
            'success': True,
            'data': {
                'credentials': credentials,
                'live_type': live.live_type,
                'host_name': live.host.display_name,
                'host_user_id': live.host.user_id,
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

        pool_key = f"random_drop:{data['activity_type']}"
        profile = request.user.profile
        entry = {
            'user_id': str(profile.user_id),
            'username': profile.username,
            'display_name': profile.display_name,
            'avatar_url': profile.avatar_url,
            'duration': data['duration'],
            'timestamp': timezone.now().isoformat(),
            'timezone': str(timezone.get_current_timezone()),
        }
        try:
            import json
            cache.zadd(pool_key, {json.dumps(entry): timezone.now().timestamp()})
            cache.set(
                f"random_drop_user:{request.user.profile.user_id}",
                json.dumps(entry),
                timeout=300,
            )
        except (AttributeError, TypeError):
            pass

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
                    'live_id': match.get('live_id'),
                    'credentials': {
                        'agora': match.get('agora', {}),
                        'livekit': match.get('livekit', {}),
                    },
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
        from .models import LiveRSVP

        rsvp, created = LiveRSVP.objects.get_or_create(
            live=live, user=request.user.profile,
        )
        if not created:
            rsvp.delete()
            return Response({
                'success': True,
                'data': None,
                'message': 'RSVP cancelled.',
                'errors': None, 'pagination': None,
            })

        return Response({
            'success': True,
            'data': None,
            'message': 'RSVP confirmed! You will be notified when the live starts.',
            'errors': None,
            'pagination': None,
        })


class RefundGiftView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, live_id, tx_id):
        live = get_object_or_404(BuddyLive, id=live_id)
        if live.host != request.user.profile:
            return Response({
                'success': False, 'data': None,
                'message': 'Only the host can refund gifts.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)

        tx = get_object_or_404(ArtifactTransaction, id=tx_id, status='completed')

        counterparty = tx.counterparty
        if not counterparty:
            return Response({
                'success': False, 'data': None,
                'message': 'Cannot refund — no counterparty found.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        from apps.wallet.utils import deduct_artifacts, credit_artifacts

        if not deduct_artifacts(live.host, tx.artifact_type, tx.quantity):
            return Response({
                'success': False, 'data': None,
                'message': 'Insufficient artifacts to refund.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        credit_artifacts(counterparty, tx.artifact_type, tx.quantity)

        tx.status = 'refunded'
        tx.save(update_fields=['status'])

        ArtifactTransaction.objects.create(
            user=live.host, transaction_type='refund',
            artifact_type=tx.artifact_type, quantity=tx.quantity,
            direction='debit', counterparty=counterparty,
            status='completed', reference_id=f'live_refund_{live_id}',
            description=f'Refund of {tx.quantity} {tx.artifact_type} to @{counterparty.username}',
        )
        ArtifactTransaction.objects.create(
            user=counterparty, transaction_type='refund',
            artifact_type=tx.artifact_type, quantity=tx.quantity,
            direction='credit', counterparty=live.host,
            status='completed', reference_id=f'live_refund_{live_id}',
            description=f'Refund from @{live.host.username}',
        )

        return Response({
            'success': True, 'data': None,
            'message': f'Refunded {tx.quantity} {tx.artifact_type} to @{counterparty.username}.',
            'errors': None, 'pagination': None,
        })


class AddCoHostView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, live_id):
        live = get_object_or_404(BuddyLive, id=live_id)
        if live.host != request.user.profile:
            return Response({
                'success': False, 'data': None,
                'message': 'Only the host can add co-hosts.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)

        serializer = CoHostInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        profile = get_object_or_404(Profile, username=serializer.validated_data['username'])

        if profile == live.host:
            return Response({
                'success': False, 'data': None,
                'message': 'You are already the host.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        live.co_hosts.add(profile)
        return Response({
            'success': True, 'data': None,
            'message': f'@{profile.username} is now a co-host.',
            'errors': None, 'pagination': None,
        })

    def delete(self, request, live_id):
        live = get_object_or_404(BuddyLive, id=live_id)
        if live.host != request.user.profile:
            return Response({
                'success': False, 'data': None,
                'message': 'Only the host can remove co-hosts.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)

        serializer = CoHostInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        profile = get_object_or_404(Profile, username=serializer.validated_data['username'])
        live.co_hosts.remove(profile)
        return Response({
            'success': True, 'data': None,
            'message': f'@{profile.username} is no longer a co-host.',
            'errors': None, 'pagination': None,
        })


class LiveCredentialsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, live_id):
        live = get_object_or_404(BuddyLive, id=live_id)
        profile = request.user.profile
        if not can_access_live(live, profile) or not has_live_admission(live, profile):
            return Response({
                'success': False, 'data': None,
                'message': 'Join the live session before requesting media credentials.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)
        credentials = get_live_credentials(
            live, request, can_publish=may_publish_media(live, profile),
        )
        viewer_count = get_live_viewer_count(str(live.id))
        return Response({
            'success': True,
            'data': {
                'credentials': credentials,
                'live_type': live.live_type,
                'title': live.title,
                'host_name': live.host.display_name,
                'host_user_id': live.host.user_id,
                'host_avatar': live.host.avatar_url,
                'status': live.status,
                'viewer_count': viewer_count,
                'co_hosts': [
                    {'user_id': p.user_id, 'display_name': p.display_name, 'avatar_url': p.avatar_url}
                    for p in live.co_hosts.all()
                ],
            },
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class UserLivesView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, username):
        profile = get_object_or_404(Profile, username=username)
        tab = request.query_params.get('tab', 'all')

        if tab == 'live':
            queryset = BuddyLive.objects.filter(host=profile, status='live')
        elif tab == 'scheduled':
            queryset = BuddyLive.objects.filter(host=profile, status='scheduled')
        elif tab == 'replays':
            queryset = BuddyLive.objects.filter(host=profile, status='ended', replay_saved=True)
        elif tab == 'co_hosted':
            queryset = BuddyLive.objects.filter(co_hosts=profile)
        else:
            queryset = BuddyLive.objects.filter(
                db_models.Q(host=profile) | db_models.Q(co_hosts=profile)
            ).distinct()

        queryset = queryset.select_related('host')

        count = queryset.count()
        paginator = CursorPagination()
        page = paginator.paginate_queryset(queryset, request)
        serializer = BuddyLiveSerializer(page, many=True, context={'request': request})

        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': {
                'count': count,
                'next': paginator.get_next_link(),
                'previous': paginator.get_previous_link(),
            },
        })


class InitiateClientRecordingView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, live_id):
        live = get_object_or_404(BuddyLive, id=live_id)
        if live.host != request.user.profile and not live.co_hosts.filter(id=request.user.profile.id).exists():
            return Response({
                'success': False, 'data': None,
                'message': 'Only the host or co-host can initiate recording.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)

        if live.status != 'live':
            return Response({
                'success': False, 'data': None,
                'message': 'Live is not active.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        from uuid import uuid4
        session_id = uuid4().hex[:16]
        live.client_recording_session_id = session_id
        live.save(update_fields=['client_recording_session_id'])

        return Response({
            'success': True, 'data': {'session_id': session_id},
            'message': 'Recording session initialized.',
            'errors': None, 'pagination': None,
        })


class UploadReplayChunkView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, live_id):
        live = get_object_or_404(BuddyLive, id=live_id)
        if live.host != request.user.profile and not live.co_hosts.filter(id=request.user.profile.id).exists():
            return Response({
                'success': False, 'data': None,
                'message': 'Only the host or co-host can upload recording chunks.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)

        if not live.client_recording_session_id:
            return Response({
                'success': False, 'data': None,
                'message': 'No recording session active.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        input_serializer = RecordingChunkInputSerializer(data=request.data)
        input_serializer.is_valid(raise_exception=True)
        chunk_index = input_serializer.validated_data['chunk_index']
        chunk_file = request.FILES.get('chunk')
        if not chunk_file:
            return Response({
                'success': False, 'data': None,
                'message': 'chunk file is required.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if chunk_file.size > 50 * 1024 * 1024:
            return Response({
                'success': False, 'data': None,
                'message': 'Chunk size exceeds 50 MB limit.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        ext = chunk_file.name.split('.')[-1].lower() if '.' in chunk_file.name else ''
        if ext not in ('webm', 'mp4'):
            return Response({
                'success': False, 'data': None,
                'message': 'Only WebM and MP4 chunks are accepted.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        from .recording import save_client_replay_chunk
        ok = save_client_replay_chunk(
            str(live.id), int(chunk_index), chunk_file.read(),
            live.client_recording_session_id,
        )
        if not ok:
            return Response({
                'success': False, 'data': None,
                'message': 'Failed to save chunk.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        return Response({
            'success': True, 'data': None,
            'message': f'Chunk {chunk_index} saved.',
            'errors': None, 'pagination': None,
        })


class CompleteClientReplayView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, live_id):
        live = get_object_or_404(BuddyLive, id=live_id)
        if live.host != request.user.profile and not live.co_hosts.filter(id=request.user.profile.id).exists():
            return Response({
                'success': False, 'data': None,
                'message': 'Only the host or co-host can complete a replay.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)

        if not live.client_recording_session_id:
            return Response({
                'success': False, 'data': None,
                'message': 'No recording session active.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        from .tasks import process_live_replay
        process_live_replay.delay(str(live.id))

        return Response({
            'success': True, 'data': None,
            'message': 'Replay processing started.',
            'errors': None, 'pagination': None,
        })


class LiveAttendeesView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, live_id):
        live = get_object_or_404(BuddyLive, id=live_id)
        attendees = LiveAttendee.objects.filter(
            live=live, left_at__isnull=True,
        ).select_related('user').order_by('joined_at')

        serializer = LiveAttendeeSerializer(attendees, many=True)
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })
