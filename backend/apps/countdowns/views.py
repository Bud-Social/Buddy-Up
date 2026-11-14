from datetime import timedelta

from rest_framework import views, permissions, status
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from django.core.files.base import ContentFile
from django.core.files.storage import default_storage
from django.db.models import F
from django.shortcuts import get_object_or_404
from django.utils import timezone
from django.utils.dateparse import parse_datetime

from .models import (
    CountdownTemplate, UserCountdown, Routine, RoutineCheckIn, RoutineHighlight,
)
from .serializers import (
    CountdownEventSerializer, CountdownTemplateSerializer,
    UserCountdownSerializer, RoutineSerializer, RoutineCheckInSerializer,
    RoutineHighlightSerializer, RoutineReorderSerializer,
)
from .services import advance_matching_countdowns

import os
import uuid


def _format_remaining(delta: timedelta) -> str:
    """"23h 12m" — how long until the next check-in opens."""
    total = max(0, int(delta.total_seconds()))
    hours, remainder = divmod(total, 3600)
    minutes = remainder // 60
    if hours:
        return f'{hours}h {minutes}m'
    return f'{minutes}m'


class CountdownTemplateListView(views.APIView):
    """List active countdown templates offered to all users."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        qs = CountdownTemplate.objects.filter(is_active=True)
        return Response({
            'success': True,
            'data': CountdownTemplateSerializer(qs, many=True).data,
            'message': 'Templates.', 'errors': None, 'pagination': None,
        })


class UserCountdownListView(views.APIView):
    """List and create the authenticated user's countdowns."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        qs = UserCountdown.objects.filter(user=request.user.profile)
        is_active = request.query_params.get('is_active')
        if is_active is not None:
            qs = qs.filter(is_active=is_active.lower() == 'true')
        return Response({
            'success': True,
            'data': UserCountdownSerializer(qs, many=True).data,
            'message': 'Countdowns.', 'errors': None, 'pagination': {'count': qs.count()},
        })

    def post(self, request):
        serializer = UserCountdownSerializer(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        obj = serializer.save(user=request.user.profile)
        # The stream starts with the creation of the countdown.
        obj._write_event('create')
        return Response({
            'success': True,
            'data': UserCountdownSerializer(obj).data,
            'message': 'Countdown created.', 'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class UserCountdownDetailView(views.APIView):
    """Retrieve, update, or delete a single user countdown."""
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self, pk):
        return get_object_or_404(UserCountdown, id=pk, user=self.request.user.profile)

    def get(self, request, pk):
        obj = self.get_object(pk)
        return Response({
            'success': True,
            'data': UserCountdownSerializer(obj).data,
            'message': 'OK', 'errors': None, 'pagination': None,
        })

    def patch(self, request, pk):
        obj = self.get_object(pk)
        serializer = UserCountdownSerializer(obj, data=request.data, partial=True, context={'request': request})
        serializer.is_valid(raise_exception=True)
        obj = serializer.save()
        # An edit is part of the story too — record what changed.
        obj._write_event('edit', note=(request.data.get('custom_reason') or '')[:200])
        return Response({
            'success': True,
            'data': UserCountdownSerializer(obj).data,
            'message': 'Updated.', 'errors': None, 'pagination': None,
        })

    def delete(self, request, pk):
        obj = self.get_object(pk)
        obj.delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Deleted.', 'errors': None, 'pagination': None,
        })


class CountdownSignalListView(views.APIView):
    """GET /countdowns/signals/ — the signals an automatic countdown can use.

    Each signal names something the app can observe, so the user picks what
    should move the countdown rather than typing a magic string.
    """
    permission_classes = [permissions.IsAuthenticated]

    SIGNALS = [
        {'key': 'activity_walk', 'label': 'A logged walk', 'unit': 'days'},
        {'key': 'activity_run', 'label': 'A logged run', 'unit': 'days'},
        {'key': 'activity_cycle', 'label': 'A logged cycle', 'unit': 'days'},
        {'key': 'activity_hike', 'label': 'A logged hike', 'unit': 'days'},
        {'key': 'gym_checkin', 'label': 'A gym check-in', 'unit': 'days'},
        {'key': 'workout_logged', 'label': 'A logged workout', 'unit': 'days'},
    ]

    def get(self, request):
        return Response({
            'success': True,
            'data': self.SIGNALS,
            'message': 'Signals.', 'errors': None, 'pagination': None,
        })


class CountdownEventListView(views.APIView):
    """GET /countdowns/<id>/events/ — a countdown's stream.

    The stream is the history the analytics page reads: every check-in,
    automatic advance and reset, with the counter's value and the time gaps.
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, pk):
        countdown = get_object_or_404(UserCountdown, id=pk, user=request.user.profile)
        qs = countdown.events.all()
        event_type = request.query_params.get('event_type')
        if event_type:
            qs = qs.filter(event_type=event_type)
        limit = min(int(request.query_params.get('limit', 100)), 500)
        return Response({
            'success': True,
            'data': CountdownEventSerializer(qs[:limit], many=True).data,
            'message': 'Events.', 'errors': None, 'pagination': {'count': qs.count()},
        })


class CountdownCheckInView(views.APIView):
    """Manual check-in: advance a manual countdown by one unit.

    A check-in unlocks once per unit — an hourly countdown unlocks every
    hour, a daily one every 24 hours — so the counter cannot be inflated by
    tapping repeatedly.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        obj = get_object_or_404(UserCountdown, id=pk, user=request.user.profile)
        if obj.countdown_type != 'manual':
            return Response({
                'success': False, 'data': None,
                'message': 'Only manual countdowns can be checked in.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        ready, unlock = obj.checkin_ready_at()
        if not ready:
            remaining = unlock - timezone.now()
            return Response({
                'success': False,
                'data': {
                    'next_checkin_at': unlock.isoformat(),
                    'remaining_seconds': int(remaining.total_seconds()),
                },
                'message': (
                    f'Next check-in opens in {_format_remaining(remaining)} '
                    f'— a {obj.unit} countdown can be checked in once per {obj.unit[:-1]}.'
                ),
                'errors': None, 'pagination': None,
            }, status=status.HTTP_409_CONFLICT)

        obj.advance(amount=1)
        return Response({
            'success': True,
            'data': UserCountdownSerializer(obj).data,
            'message': 'Checked in.', 'errors': None, 'pagination': None,
        })


class CountdownResetView(views.APIView):
    """Reset a countdown to zero."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        obj = get_object_or_404(UserCountdown, id=pk, user=request.user.profile)
        obj.reset()
        return Response({
            'success': True,
            'data': UserCountdownSerializer(obj).data,
            'message': 'Reset.', 'errors': None, 'pagination': None,
        })


class CountdownAutoAdvanceView(views.APIView):
    """Server endpoint for automatic signals to advance a countdown.

    Called by activity/gps/workout handlers when an automatic countdown
    should advance (e.g. a logged walk advances the 'walking days' countdown).

    Staff only: a countdown that advances on a signal from the user's own
    activity is advanced by the activity handler, which calls
    ``services.advance_matching_countdowns`` directly. Letting the account
    owner call this would let them advance a streak by tapping a button.
    """
    permission_classes = [permissions.IsAdminUser]

    def post(self, request):
        signal = request.data.get('signal')
        if not signal:
            return Response({
                'success': False, 'data': None,
                'message': 'signal is required.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        advanced = advance_matching_countdowns(request.user.profile, signal)

        return Response({
            'success': True,
            'data': {'advanced_ids': advanced, 'count': len(advanced)},
            'message': 'Auto-advance processed.', 'errors': None, 'pagination': None,
        })


class CountdownSeedTemplatesView(views.APIView):
    """Seed the default countdown templates (idempotent). Dev/staff only."""
    permission_classes = [permissions.IsAdminUser]

    DEFAULT_TEMPLATES = [
        {
            'code': 'sobriety', 'title': 'Sobriety', 'unit': 'days',
            'description': 'Days since last drink.', 'icon': '🍻', 'color': '#ef4444',
            'default_target': 0, 'sort_order': 1,
        },
        {
            'code': 'no_artificial_sugars', 'title': 'No Artificial Sugars', 'unit': 'days',
            'description': 'Days without artificial sweeteners.', 'icon': '🍬', 'color': '#f59e0b',
            'default_target': 0, 'sort_order': 2,
        },
        {
            'code': 'no_animal_proteins', 'title': 'No Animal Proteins', 'unit': 'days',
            'description': 'Days without meat, fish, eggs, or dairy.', 'icon': '🌱', 'color': '#22c55e',
            'default_target': 0, 'sort_order': 3,
        },
        {
            'code': 'gym_attendance', 'title': 'Gym Attendance', 'unit': 'days',
            'description': 'Consecutive days with a gym visit.', 'icon': '🏋️', 'color': '#3b82f6',
            'default_target': 0, 'sort_order': 4,
        },
        {
            'code': 'walking_days', 'title': 'Walking Days', 'unit': 'days',
            'description': 'Days with a logged walk.', 'icon': '🚶', 'color': '#10b981',
            'default_target': 0, 'sort_order': 5,
        },
        {
            'code': 'no_drugs', 'title': 'No Drugs', 'unit': 'days',
            'description': 'Days drug-free.', 'icon': '💊', 'color': '#dc2626',
            'default_target': 0, 'sort_order': 6,
        },
        {
            'code': 'no_nut_month', "title": "No Nut Month", 'unit': 'days',
            'description': 'Days without nuts.', 'icon': '🥜', 'color': '#a855f7',
            'default_target': 30, 'sort_order': 7,
        },
        {
            'code': 'custom', 'title': 'Custom Reason', 'unit': 'days',
            'description': 'Your own countdown reason.', 'icon': '📅', 'color': '#6b7280',
            'default_target': 0, 'sort_order': 99,
        },
    ]

    def post(self, request):
        created = 0
        for data in self.DEFAULT_TEMPLATES:
            obj, was_created = CountdownTemplate.objects.update_or_create(
                code=data['code'], defaults=data,
            )
            if was_created:
                created += 1
        return Response({
            'success': True,
            'data': {'created': created, 'total': CountdownTemplate.objects.count()},
            'message': 'Templates seeded.', 'errors': None, 'pagination': None,
        })


class RoutineListView(views.APIView):
    """List and create the authenticated user's routines."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        qs = Routine.objects.filter(user=request.user.profile, is_active=True)
        return Response({
            'success': True,
            'data': RoutineSerializer(qs, many=True).data,
            'message': 'Routines.', 'errors': None, 'pagination': {'count': qs.count()},
        })

    def post(self, request):
        serializer = RoutineSerializer(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        serializer.save(user=request.user.profile)
        return Response({
            'success': True,
            'data': RoutineSerializer(serializer.instance).data,
            'message': 'Routine created.', 'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class RoutineDetailView(views.APIView):
    """Retrieve, update, or delete a single routine."""
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self, pk):
        return get_object_or_404(Routine, id=pk, user=self.request.user.profile)

    def get(self, request, pk):
        obj = self.get_object(pk)
        return Response({
            'success': True,
            'data': RoutineSerializer(obj, context={'request': request, 'include_highlights': True}).data,
            'message': 'OK', 'errors': None, 'pagination': None,
        })

    def patch(self, request, pk):
        obj = self.get_object(pk)
        serializer = RoutineSerializer(
            obj, data=request.data, partial=True,
            context={'request': request},
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({
            'success': True,
            'data': RoutineSerializer(serializer.instance, context={'request': request}).data,
            'message': 'Updated.', 'errors': None, 'pagination': None,
        })

    def delete(self, request, pk):
        obj = self.get_object(pk)
        obj.is_active = False
        obj.save(update_fields=['is_active'])
        return Response({
            'success': True, 'data': None,
            'message': 'Deleted.', 'errors': None, 'pagination': None,
        })


class RoutineReorderView(views.APIView):
    """Persist a drag-and-drop order for the user's routines."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = RoutineReorderSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        profile = request.user.profile
        owned = set(
            Routine.objects.filter(user=profile, id__in=serializer.validated_data['ordered_ids'])
            .values_list('id', flat=True)
        )
        for index, routine_id in enumerate(serializer.validated_data['ordered_ids']):
            if routine_id not in owned:
                continue
            Routine.objects.filter(id=routine_id, user=profile).update(sort_order=index)
        qs = Routine.objects.filter(user=profile, is_active=True)
        return Response({
            'success': True,
            'data': RoutineSerializer(qs, many=True).data,
            'message': 'Order saved.', 'errors': None, 'pagination': {'count': qs.count()},
        })


class RoutineCheckInView(views.APIView):
    """Check in a routine session, in-app or by hand."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        routine = get_object_or_404(Routine, id=pk, user=request.user.profile)
        value = request.data.get('value')
        if value is not None:
            try:
                value = int(value)
            except (TypeError, ValueError):
                return Response({
                    'success': False, 'data': None,
                    'message': 'value must be a whole number.', 'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)
            if value < 0:
                value = 0

        occurred_raw = (request.data.get('occurred_at') or '').strip()
        occurred_at = parse_datetime(occurred_raw) if occurred_raw else timezone.now()
        if occurred_at is None:
            occurred_at = timezone.now()

        checkin = RoutineCheckIn.objects.create(
            routine=routine,
            value=value,
            note=(request.data.get('note') or '').strip()[:300],
            source='manual' if routine.tracking == 'manual' else 'app',
            occurred_at=occurred_at,
        )
        Routine.objects.filter(pk=routine.pk).update(
            streak=F('streak') + 1,
            completed_today=True,
            last_checkin_at=occurred_at,
        )
        routine.refresh_from_db()
        return Response({
            'success': True,
            'data': {
                'routine': RoutineSerializer(routine).data,
                'check_in': RoutineCheckInSerializer(checkin).data,
            },
            'message': 'Checked in.', 'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class RoutineCheckInListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, pk):
        routine = get_object_or_404(Routine, id=pk, user=request.user.profile)
        rows = routine.check_ins.all()[:50]
        return Response({
            'success': True, 'data': RoutineCheckInSerializer(rows, many=True).data,
            'message': 'OK', 'errors': None, 'pagination': {'count': routine.check_ins.count()},
        })


class RoutineHighlightListView(views.APIView):
    """Highlights (photo/voice/video) attached to a routine."""
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def get(self, request, pk):
        routine = get_object_or_404(Routine, id=pk, user=request.user.profile)
        kind = request.query_params.get('kind')
        qs = routine.highlights.all()
        if kind in ('photo', 'voice', 'video'):
            qs = qs.filter(kind=kind)
        return Response({
            'success': True, 'data': RoutineHighlightSerializer(qs[:60], many=True).data,
            'message': 'OK', 'errors': None, 'pagination': {'count': qs.count()},
        })

    def post(self, request, pk):
        routine = get_object_or_404(Routine, id=pk, user=request.user.profile)
        kind = request.data.get('kind', 'photo')
        if kind not in ('photo', 'voice', 'video'):
            return Response({
                'success': False, 'data': None,
                'message': 'kind must be photo, voice or video.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        upload = request.FILES.get('file') or request.FILES.get('media')
        file_url = (request.data.get('file_url') or '').strip()
        if not upload and not file_url:
            return Response({
                'success': False, 'data': None,
                'message': 'A file or file_url is required.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if upload:
            if upload.size > 60 * 1024 * 1024:
                return Response({
                    'success': False, 'data': None,
                    'message': f'{upload.name} is larger than 60 MB.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)
            ext = os.path.splitext(upload.name)[1].lower()
            saved_name = default_storage.save(
                f'routines/{routine.id}/highlights/{uuid.uuid4().hex}{ext}',
                ContentFile(upload.read()),
            )
            file_url = default_storage.url(saved_name)

        try:
            duration_ms = int(request.data.get('duration_ms') or 0)
        except (TypeError, ValueError):
            duration_ms = None

        highlight = RoutineHighlight.objects.create(
            routine=routine,
            kind=kind,
            file_url=file_url,
            thumbnail_url=(request.data.get('thumbnail_url') or '').strip()[:1000],
            caption=(request.data.get('caption') or '').strip()[:200],
            duration_ms=duration_ms or None,
        )
        return Response({
            'success': True,
            'data': RoutineHighlightSerializer(highlight).data,
            'message': 'Highlight saved.', 'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class RoutineHighlightDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request, pk, highlight_id):
        routine = get_object_or_404(Routine, id=pk, user=request.user.profile)
        highlight = get_object_or_404(RoutineHighlight, id=highlight_id, routine=routine)
        highlight.delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Highlight removed.', 'errors': None, 'pagination': None,
        })


class RoutineShareView(views.APIView):
    """Share a routine as a feed post or a moment (story).

    The metrics card is rendered by the client from ``workout_log_data``; the
    user-chosen overlay position travels with it so a story and a feed post
    can place the numbers differently.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        from apps.feed.models import Post

        routine = get_object_or_404(Routine, id=pk, user=request.user.profile)
        as_story = bool(request.data.get('as_story'))
        overlay = (request.data.get('overlay_position') or 'middle').strip().lower()
        if overlay not in ('top', 'middle', 'bottom'):
            overlay = 'middle'
        media_url = (request.data.get('media_url') or '').strip()
        visibility = request.data.get('visibility', 'public')
        if visibility not in ('public', 'buddies', 'gym_members', 'private'):
            visibility = 'public'

        body = (request.data.get('body') or '').strip() or (
            f'{routine.display_name} — {routine.streak} day streak '
            f'({routine.target} {routine.unit}).'
        )
        metrics = {
            'routine_id': str(routine.id),
            'routine_name': routine.display_name,
            'type': routine.type,
            'streak': routine.streak,
            'target': routine.target,
            'unit': routine.unit,
            'activation': routine.activation,
            'overlay_position': overlay,
            'source': 'routine_share',
        }
        post = Post.objects.create(
            author=request.user.profile,
            post_type='moment' if as_story else 'workout_log',
            body=body,
            visibility=visibility,
            media_urls=[media_url] if media_url else [],
            workout_log_data=metrics,
        )
        return Response({
            'success': True,
            'data': {
                'post_id': str(post.id),
                'post_type': post.post_type,
                'overlay_position': overlay,
            },
            'message': 'Shared.', 'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)
