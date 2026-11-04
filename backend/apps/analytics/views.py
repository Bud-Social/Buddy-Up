import os
import uuid
from django.conf import settings

from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
from django.shortcuts import get_object_or_404
from django.utils import timezone

from rest_framework import views, permissions, status
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.response import Response

from .models import (
    ActivityRecord, WorkoutLog, BodyMetric, AnalyticsReport,
    WORKOUT_TYPE_SPECS, all_category_keys, VideoWatermark,
)
from .serializers import (
    ActivityRecordSerializer, WorkoutLogSerializer,
    BodyMetricSerializer,
)
from . import engine
from . import report as report_service
from .tasks import watermark_video


class BaseOwnedView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]
    model = None
    serializer_class = None

    def get_object(self, pk):
        return get_object_or_404(self.model, id=pk, user=self.request.user.profile)

    def get(self, request, pk=None):
        if pk:
            obj = self.get_object(pk)
            return Response({
                'success': True, 'data': self.serializer_class(obj).data,
                'message': 'OK', 'errors': None, 'pagination': None,
            })
        qs = self.model.objects.filter(user=request.user.profile)
        activity_type = request.query_params.get('activity_type')
        if activity_type and self.model is ActivityRecord:
            qs = qs.filter(activity_type=activity_type)
        category = request.query_params.get('category')
        if category and self.model is WorkoutLog:
            qs = qs.filter(category=category)
        start = request.query_params.get('start')
        end = request.query_params.get('end')
        if start:
            qs = qs.filter(**{f'{self.date_field}__gte': start})
        if end:
            qs = qs.filter(**{f'{self.date_field}__lte': end})
        serializer = self.serializer_class(qs, many=True)
        return Response({
            'success': True, 'data': serializer.data,
            'message': 'OK', 'errors': None, 'pagination': {'count': len(serializer.data)},
        })

    def delete(self, request, pk):
        obj = self.get_object(pk)
        obj.delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Deleted.', 'errors': None, 'pagination': None,
        })


class ActivityRecordView(BaseOwnedView):
    model = ActivityRecord
    serializer_class = ActivityRecordSerializer
    date_field = 'started_at'

    def post(self, request, pk=None):
        if pk:
            obj = self.get_object(pk)
            action = request.data.get('action')
            if action not in ('pause', 'resume'):
                return Response({'detail': 'action must be pause or resume'}, status=400)
            if action == 'pause' and not obj.is_paused:
                obj.is_paused, obj.paused_at = True, timezone.now()
            elif action == 'resume' and obj.is_paused:
                obj.total_pause_seconds += int((timezone.now() - obj.paused_at).total_seconds())
                obj.is_paused, obj.paused_at = False, None
            obj.save(update_fields=['is_paused', 'paused_at', 'total_pause_seconds', 'updated_at'])
            return Response({'success': True, 'data': ActivityRecordSerializer(obj).data})
        serializer = ActivityRecordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        if serializer.validated_data.get('source_event_id'):
            obj, created = ActivityRecord.objects.get_or_create(user=request.user.profile, source_event_id=serializer.validated_data['source_event_id'], defaults=serializer.validated_data)
        else:
            obj, created = serializer.save(user=request.user.profile), True
        return Response({'success': True, 'data': ActivityRecordSerializer(obj).data, 'message': 'Activity recorded.', 'errors': None, 'pagination': None}, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)


class WorkoutLogView(BaseOwnedView):
    model = WorkoutLog
    serializer_class = WorkoutLogSerializer
    date_field = 'performed_at'

    def post(self, request):
        serializer = WorkoutLogSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        event_id = serializer.validated_data.get('source_event_id')
        obj, created = WorkoutLog.objects.get_or_create(
            user=request.user.profile, source_event_id=event_id,
            defaults=serializer.validated_data,
        ) if event_id else (serializer.save(user=request.user.profile), True)
        return Response({
            'success': True, 'data': WorkoutLogSerializer(obj).data,
            'message': 'Workout logged.', 'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)


class WorkoutTypeTaxonomyView(views.APIView):
    """Read-only workout taxonomy.

    Public on purpose: the web and mobile onboarding/logging forms need the
    type list before they have a session, so this is how they stop
    hardcoding (and drifting from) the backend taxonomy.
    """

    permission_classes = [permissions.AllowAny]
    throttle_scope = 'analytics'

    def get(self, request):
        return Response({
            'success': True,
            'data': {
                'workout_types': WORKOUT_TYPE_SPECS,
                'categories': all_category_keys(),
            },
            'message': 'Workout taxonomy.', 'errors': None, 'pagination': None,
        })


class BodyMetricView(BaseOwnedView):
    model = BodyMetric
    serializer_class = BodyMetricSerializer
    date_field = 'measured_at'
    parser_classes = (MultiPartParser, FormParser)

    def post(self, request):
        data = request.data.copy()
        photo = request.FILES.get('photo')
        if photo:
            ext = os.path.splitext(photo.name)[1].lower() or '.jpg'
            filename = f'body_snaps/{uuid.uuid4().hex}{ext}'
            saved = default_storage.save(filename, ContentFile(photo.read()))
            data['photo_url'] = request.build_absolute_uri(default_storage.url(saved))

        scale_photo = request.FILES.get('scale_photo')
        if scale_photo:
            ext = os.path.splitext(scale_photo.name)[1].lower() or '.jpg'
            filename = f'body_snaps/{uuid.uuid4().hex}{ext}'
            saved = default_storage.save(filename, ContentFile(scale_photo.read()))
            data['scale_photo_url'] = request.build_absolute_uri(default_storage.url(saved))
            # Auto-read the weight from the scale display when not provided manually.
            if not data.get('weight_kg'):
                scale_photo.seek(0)
                reading = engine.read_weight_from_photo(request, scale_photo)
                if reading and reading.get('weight_kg'):
                    data['weight_kg'] = reading['weight_kg']

        serializer = BodyMetricSerializer(data=data)
        serializer.is_valid(raise_exception=True)
        obj = serializer.save(user=request.user.profile)
        return Response({
            'success': True, 'data': BodyMetricSerializer(obj).data,
            'message': 'Body metric recorded.', 'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class BodyReadWeightView(views.APIView):
    """Proxies a scale-display photo to the AI service and returns the weight."""

    permission_classes = [permissions.IsAuthenticated]
    parser_classes = (MultiPartParser, FormParser)

    def post(self, request):
        scale_photo = request.FILES.get('scale_photo') or request.FILES.get('photo')
        if not scale_photo:
            return Response({
                'success': False, 'data': None,
                'message': 'No scale photo provided.',
                'errors': 'scale_photo field is required.', 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        reading = engine.read_weight_from_photo(request, scale_photo)
        if reading is None:
            return Response({
                'success': False, 'data': None,
                'message': 'Weight reading service unavailable.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        return Response({
            'success': True, 'data': reading,
            'message': 'Weight reading complete.', 'errors': None, 'pagination': None,
        })


class AnalyticsSummaryView(views.APIView):
    """Comprehensive analytics across all categories for one period."""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        period = request.query_params.get('period', 'all')
        if period not in engine.PERIOD_DAYS:
            period = 'all'
        summary = engine.build_summary(request.user.profile, period)
        return Response({
            'success': True, 'data': summary,
            'message': 'Analytics summary generated.', 'errors': None, 'pagination': None,
        })


class IngestEventsView(views.APIView):
    """Behavioral-event ingestion (batch).

    Authenticated or anonymous (anonymous_id required when anonymous).
    Events lacking consent.analytics=true are skipped, never stored.
    """

    permission_classes = [permissions.AllowAny]
    throttle_scope = 'analytics'

    def post(self, request):
        from .event_ingest import build_event_rows, record_events
        from .models import AnalyticsEvent

        events = request.data.get('events') if isinstance(request.data, dict) else None
        if not isinstance(events, list) or not events:
            return Response({
                'success': False, 'data': None,
                'message': "Body must include a non-empty 'events' list (max 50).",
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)
        if len(events) > 50:
            return Response({
                'success': False, 'data': None,
                'message': 'Too many events per batch (max 50).',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        actor = request.user.profile if request.user.is_authenticated else None
        # Client queues stamp identity per event; accept the first event's
        # identity as the batch default when top-level fields are absent.
        first = events[0] if isinstance(events[0] if events else None, dict) else {}
        request_anonymous_id = str(
            request.data.get('anonymous_id') or first.get('anonymous_id') or '',
        ).strip()
        if actor is None and not request_anonymous_id:
            return Response({
                'success': False, 'data': None,
                'message': 'Anonymous events require an anonymous_id.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        # Client-level identity/session fields apply to every event in the batch.
        defaults = {
            'anonymous_id': request_anonymous_id,
            'session_id': str(request.data.get('session_id') or first.get('session_id') or ''),
            'platform': str(request.data.get('platform') or first.get('platform') or ''),
        }
        stamped = [
            {**defaults, **event} if isinstance(event, dict) else event
            for event in events
        ]

        rows, skipped = build_event_rows(stamped, actor_profile=actor)
        if rows:
            if len(rows) >= 10:
                record_events.delay(events, actor.user_id if actor else None)
                accepted = len(rows)
            else:
                AnalyticsEvent.objects.bulk_create(rows)
                accepted = len(rows)
        else:
            accepted = 0

        return Response({
            'success': True,
            'data': {'accepted': accepted, 'skipped': skipped},
            'message': 'Events accepted.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_202_ACCEPTED)


class AnalyticsReportView(views.APIView):
    """Generate the comprehensive report (JSON + watermarked PNG)."""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        period = request.query_params.get('period', 'all')
        if period not in engine.PERIOD_DAYS:
            period = 'all'
        profile = request.user.profile
        summary, image_url = report_service.generate_report_file(profile, period)

        report = AnalyticsReport.objects.create(
            user=profile, period=period, data=summary, image_url=image_url,
        )
        return Response({
            'success': True, 'data': {'id': str(report.id), 'period': period, 'data': summary, 'image_url': image_url},
            'message': 'Report generated.', 'errors': None, 'pagination': None,
        })


class AnalyticsReportDownloadView(views.APIView):
    """Return the watermarked report PNG as a direct download."""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        report_id = request.query_params.get('id')
        if report_id:
            report = get_object_or_404(AnalyticsReport, id=report_id, user=request.user.profile)
            summary, image_url = report.data, report.image_url
        else:
            period = request.query_params.get('period', 'all')
            if period not in engine.PERIOD_DAYS:
                period = 'all'
            summary, image_url = report_service.generate_report_file(request.user.profile, period)

        return Response({
            'success': True, 'data': {'image_url': image_url},
            'message': 'Report ready.', 'errors': None, 'pagination': None,
        })


class ActivityShareView(views.APIView):
    """Share one walk/run/hike/cycle or workout log as a feed post."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, kind, obj_id):
        from apps.feed.models import Post

        profile = request.user.profile
        if kind == 'activity':
            from .models import ActivityRecord
            obj = ActivityRecord.objects.filter(id=obj_id, user=profile).first()
            if obj is None:
                return Response({'success': False, 'data': None,
                                 'message': 'Activity not found.', 'errors': None, 'pagination': None},
                                status=status.HTTP_404_NOT_FOUND)
            km = round((obj.distance_meters or 0) / 1000, 2)
            mins = round((obj.duration_seconds or 0) / 60)
            body = request.data.get('body', '').strip() or (
                f'🏃 Just finished a {obj.get_activity_type_display().lower()} — '
                f'{km} km in {mins} min.'
            )
            post = Post.objects.create(
                author=profile, post_type='workout_log',
                body=body,
                workout_log_data={
                    'activity_type': obj.activity_type,
                    'distance_km': km,
                    'duration_minutes': mins,
                    'calories': obj.calories_burned,
                    'steps': obj.steps,
                    'source': 'activity_share',
                },
            )
        elif kind == 'workout':
            from .models import WorkoutLog
            obj = WorkoutLog.objects.filter(id=obj_id, user=profile).first()
            if obj is None:
                return Response({'success': False, 'data': None,
                                 'message': 'Workout not found.', 'errors': None, 'pagination': None},
                                status=status.HTTP_404_NOT_FOUND)
            body = request.data.get('body', '').strip() or (
                f'💪 Logged {obj.exercise} — {obj.sets or 0}×{obj.reps or 0}'
                + (f' @ {obj.weight_kg}kg' if obj.weight_kg else '')
            )
            post = Post.objects.create(
                author=profile, post_type='workout_log',
                body=body,
                workout_log_data={
                    'exercise': obj.exercise,
                    'sets': obj.sets,
                    'reps': obj.reps,
                    'weight_kg': obj.weight_kg,
                    'calories': getattr(obj, 'calories_burned', None),
                    'source': 'workout_share',
                },
            )
        else:
            return Response({'success': False, 'data': None,
                             'message': 'kind must be activity or workout.',
                             'errors': None, 'pagination': None},
                            status=status.HTTP_400_BAD_REQUEST)
        visibility = request.data.get('visibility', 'public')
        if visibility in ('public', 'buddies', 'gym_members', 'private'):
            post.visibility = visibility
            post.save(update_fields=['visibility'])
        return Response({'success': True, 'data': {'post_id': str(post.id)},
                         'message': 'Shared to feed.', 'errors': None, 'pagination': None},
                        status=status.HTTP_201_CREATED)


class AnalyticsReportShareView(views.APIView):
    """Share the comprehensive report as a `progress` feed post."""

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        from apps.feed.models import Post

        period = request.data.get('period', 'all')
        if period not in engine.PERIOD_DAYS:
            period = 'all'
        profile = request.user.profile

        summary, image_url = report_service.generate_report_file(profile, period)

        body = request.data.get('body', '').strip()
        if not body:
            body = (
                f"📊 My {period} BuddyUp Fit progress report — "
                f"{summary['workouts']['count']} workouts, "
                f"{summary['activity']['total_distance_km']}km walked/run."
            )

        requested_visibility = request.data.get('visibility', 'public')
        if requested_visibility not in ('public', 'buddies', 'gym_members', 'private'):
            requested_visibility = 'public'

        post = Post.objects.create(
            author=profile,
            post_type='photo',
            body=body,
            media_urls=[image_url] if image_url else [],
            visibility=requested_visibility,
        )

        report, _ = AnalyticsReport.objects.update_or_create(
            user=profile, period=period,
            defaults={'data': summary, 'image_url': image_url, 'feed_post': post},
        )

        return Response({
            'success': True,
            'data': {'report_id': str(report.id), 'post_id': str(post.id), 'image_url': image_url},
            'message': 'Report shared to your feed.', 'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class PrepareShareView(views.APIView):
    """Prepare a share draft from an activity or workout log.

    Creates a feed ``Draft`` pre-filled with the activity/workout data so the
    user can edit caption, attach media, and choose visibility before
    publishing. Nothing is posted to the feed yet.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        from apps.feed.models import Draft
        from .models import ActivityRecord, WorkoutLog

        profile = request.user.profile
        kind = request.data.get('kind')
        obj_id = request.data.get('obj_id')

        if kind not in ('activity', 'workout') or not obj_id:
            return Response({'success': False, 'data': None,
                             'message': 'kind (activity|workout) and obj_id are required.',
                             'errors': None, 'pagination': None},
                            status=status.HTTP_400_BAD_REQUEST)

        draft = Draft(
            author=profile,
            post_type='workout_log',
            visibility=request.data.get('visibility', 'public'),
            source_kind=kind,
        )

        if kind == 'activity':
            obj = get_object_or_404(ActivityRecord, id=obj_id, user=profile)
            draft.source_activity = obj
            km = round((obj.distance_meters or 0) / 1000, 2)
            mins = round((obj.duration_seconds or 0) / 60)
            draft.body = (
                f'🏃 Just finished a {obj.get_activity_type_display().lower()} — '
                f'{km} km in {mins} min.'
            )
            draft.tags = ['activity', obj.activity_type]
        else:
            obj = get_object_or_404(WorkoutLog, id=obj_id, user=profile)
            draft.source_workout = obj
            draft.body = (
                f'💪 Logged {obj.exercise} — {obj.sets or 0}×{obj.reps or 0}'
                + (f' @ {obj.weight_kg}kg' if obj.weight_kg else '')
            )
            draft.tags = ['workout', obj.workout_type]

        if obj.location_lat and obj.location_lng:
            draft.location_lat = obj.location_lat
            draft.location_lng = obj.location_lng
            draft.location_label = obj.notes or ''

        draft.save()
        return Response({
            'success': True,
            'data': {
                'draft_id': str(draft.id),
                'body': draft.body,
                'visibility': draft.visibility,
                'source_kind': draft.source_kind,
                'tags': draft.tags,
            },
            'message': 'Share draft prepared. Edit and publish when ready.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class PublishDraftView(views.APIView):
    """Publish a prepared share draft as a feed Post.

    The user has already edited the draft (caption, media, visibility).
    This converts it into a real Post and clears the source link.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, draft_id):
        from apps.feed.models import Draft, Post

        profile = request.user.profile
        draft = get_object_or_404(Draft, id=draft_id, author=profile)

        body = request.data.get('body', draft.body or '').strip()
        visibility = request.data.get('visibility', draft.visibility or 'public')
        media_urls = request.data.get('media_urls', draft.media_urls or [])
        tags = request.data.get('tags', draft.tags or [])

        if visibility not in ('public', 'buddies', 'gym_members', 'private'):
            visibility = 'public'

        post = Post.objects.create(
            author=profile,
            post_type=draft.post_type or 'workout_log',
            body=body,
            visibility=visibility,
            media_urls=media_urls,
            tags=tags,
            workout_log_data={
                'source': 'share_draft',
                'source_kind': draft.source_kind,
            } if draft.source_kind else None,
            location_label=draft.location_label or '',
            location_lat=draft.location_lat,
            location_lng=draft.location_lng,
        )

        # Clear the draft's source link so it isn't re-published.
        draft.source_activity = None
        draft.source_workout = None
        draft.source_kind = ''
        draft.save(update_fields=['source_activity', 'source_workout', 'source_kind', 'updated_at'])

        return Response({
            'success': True,
            'data': {'post_id': str(post.id), 'draft_id': str(draft.id)},
            'message': 'Published to feed.', 'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class CaptionCorrectView(views.APIView):
    """Correct grammar in a social caption via the AI microservice.

    Keyless / rule-based fallback if the AI service is unavailable.
    """
    permission_classes = [permissions.IsAuthenticated]
    throttle_scope = 'analytics'

    def post(self, request):
        caption = request.data.get('caption', '').strip()
        context = request.data.get('context', 'post')
        if not caption:
            return Response({'success': False, 'data': None,
                             'message': 'caption is required.',
                             'errors': None, 'pagination': None},
                            status=status.HTTP_400_BAD_REQUEST)

        from apps.ai.client import ai_post
        try:
            resp = ai_post(
                f'{settings.AI_SERVICE_URL}/api/v1/feed/correct-caption',
                json={'caption': caption, 'context': context},
                timeout=5.0,
            )
            if resp.status_code == 200:
                data = resp.json()
                return Response({
                    'success': True,
                    'data': data,
                    'message': 'Caption corrected.', 'errors': None, 'pagination': None,
                })
        except Exception:  # noqa: BLE001 — fall back to local correction
            pass

        # Local rule-based fallback (no network, no API key needed)
        from .caption_engine import correct_caption
        result = correct_caption(caption, context)
        return Response({
            'success': True,
            'data': result,
            'message': 'Caption corrected (local fallback).', 'errors': None, 'pagination': None,
        })


class VideoDownloadView(views.APIView):
    """Download a video attached to a post (activity/workout share).

    Returns the watermarked video URL. The first request triggers an async
    ffmpeg watermark job; subsequent requests return the ready watermarked file.
    """
    permission_classes = [permissions.IsAuthenticated]
    throttle_scope = 'analytics'

    def get(self, request, post_id):
        from apps.feed.models import Post

        profile = request.user.profile
        post = get_object_or_404(Post, id=post_id, author=profile)

        video_urls = [
            u for u in (post.media_urls or [])
            if u.lower().endswith(('.mp4', '.mov', '.webm', '.m4v', '.avi'))
        ]
        if not video_urls:
            return Response({'success': False, 'data': None,
                             'message': 'No video attached to this post.',
                             'errors': None, 'pagination': None},
                            status=status.HTTP_404_NOT_FOUND)

        video_url = video_urls[0]

        # Get or create the watermark record.
        vw, created = VideoWatermark.objects.get_or_create(
            post=post, original_video_url=video_url,
            defaults={'status': 'pending'},
        )

        if vw.status == 'ready':
            return Response({
                'success': True,
                'data': {
                    'video_url': vw.watermarked_video_url,
                    'download': True,
                    'watermark': 'BuddyUp Fit',
                    'post_id': str(post.id),
                    'status': 'ready',
                },
                'message': 'Watermarked video ready.', 'errors': None, 'pagination': None,
            })

        if vw.status == 'failed':
            return Response({
                'success': False, 'data': None,
                'message': f'Watermarking failed: {vw.error_message or "unknown error"}',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        # pending or processing: kick off (or re-kick) the async watermark job.
        if created or vw.status == 'pending':
            watermark_video.delay(str(vw.id))

        return Response({
            'success': True,
            'data': {
                'video_url': video_url,
                'download': True,
                'watermark': 'BuddyUp Fit',
                'post_id': str(post.id),
                'status': 'processing',
                'message': 'Watermarking in progress — poll this endpoint for the ready URL.',
            },
            'message': 'Watermarking started.', 'errors': None, 'pagination': None,
            'status_code': status.HTTP_202_ACCEPTED,
        }, status=status.HTTP_202_ACCEPTED)


class ActivityDetectionView(views.APIView):
    """Automatically detect activity type from GPS route or summary stats.

    Keyless, server-side heuristics — no ML model or external API needed.
    Accepts either a full route (list of [lat, lng, timestamp, elevation?])
    or summary stats (duration, distance, avg_speed, elevation_gain).
    """
    permission_classes = [permissions.IsAuthenticated]
    throttle_scope = 'analytics'

    def post(self, request):
        from .activity_detection import detect_activity_type, detect_activity_type_from_summary

        route = request.data.get('route')
        duration_seconds = request.data.get('duration_seconds', 0)
        distance_meters = request.data.get('distance_meters', 0)
        avg_speed_kmh = request.data.get('avg_speed_kmh')
        elevation_gain_m = request.data.get('elevation_gain_m')

        if route:
            detected = detect_activity_type(
                route=route,
                duration_seconds=duration_seconds,
                distance_meters=distance_meters,
                elevation_gain_m=elevation_gain_m,
            )
            method = 'route'
        else:
            detected = detect_activity_type_from_summary(
                duration_seconds=duration_seconds,
                distance_meters=distance_meters,
                avg_speed_kmh=avg_speed_kmh,
                elevation_gain_m=elevation_gain_m,
            )
            method = 'summary'

        # Confidence heuristic: more trackpoints = higher confidence
        confidence = 'high' if route and len(route) >= 10 else (
            'medium' if route else 'low'
        )

        return Response({
            'success': True,
            'data': {
                'activity_type': detected,
                'confidence': confidence,
                'method': method,
            },
            'message': 'Activity detected.', 'errors': None, 'pagination': None,
        })




