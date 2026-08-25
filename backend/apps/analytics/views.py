import os
import uuid

from django.core.files.storage import default_storage
from django.db import models as db_models
from django.core.files.base import ContentFile
from django.shortcuts import get_object_or_404

from rest_framework import views, permissions, status
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.response import Response

from .models import ActivityRecord, WorkoutLog, MealLog, BodyMetric, AnalyticsReport
from .serializers import (
    ActivityRecordSerializer, WorkoutLogSerializer,
    MealLogSerializer, BodyMetricSerializer,
)
from . import engine
from . import report as report_service


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

    def post(self, request):
        serializer = ActivityRecordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        obj = serializer.save(user=request.user.profile)
        return Response({
            'success': True, 'data': ActivityRecordSerializer(obj).data,
            'message': 'Activity recorded.', 'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class WorkoutLogView(BaseOwnedView):
    model = WorkoutLog
    serializer_class = WorkoutLogSerializer
    date_field = 'performed_at'

    def post(self, request):
        serializer = WorkoutLogSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        obj = serializer.save(user=request.user.profile)
        return Response({
            'success': True, 'data': WorkoutLogSerializer(obj).data,
            'message': 'Workout logged.', 'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class MealLogView(BaseOwnedView):
    model = MealLog
    serializer_class = MealLogSerializer
    date_field = 'logged_at'
    parser_classes = (MultiPartParser, FormParser)

    def post(self, request):
        data = request.data.copy()
        photo = request.FILES.get('photo')
        if photo:
            ext = os.path.splitext(photo.name)[1].lower() or '.jpg'
            filename = f'meal_snaps/{uuid.uuid4().hex}{ext}'
            saved = default_storage.save(filename, ContentFile(photo.read()))
            data['photo_url'] = request.build_absolute_uri(default_storage.url(saved))

        # Auto-analyze the meal photo if nutrition wasn't provided manually.
        if not data.get('calories') and photo:
            photo.seek(0)
            analyzed = engine.analyze_meal_photo(request, photo)
            if analyzed:
                for key in ('calories', 'protein_g', 'carbs_g', 'fat_g'):
                    if not data.get(key) and analyzed.get(key) is not None:
                        data[key] = analyzed[key]
                if not data.get('food_name') and analyzed.get('food_name'):
                    data['food_name'] = analyzed['food_name']

        serializer = MealLogSerializer(data=data)
        serializer.is_valid(raise_exception=True)
        obj = serializer.save(user=request.user.profile)
        return Response({
            'success': True, 'data': MealLogSerializer(obj).data,
            'message': 'Meal logged.', 'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


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


class MealAnalyzeView(views.APIView):
    """Proxies a meal photo to the AI service and returns nutrition details."""

    permission_classes = [permissions.IsAuthenticated]
    parser_classes = (MultiPartParser, FormParser)

    def post(self, request):
        photo = request.FILES.get('photo')
        if not photo:
            return Response({
                'success': False, 'data': None,
                'message': 'No meal photo provided.',
                'errors': 'photo field is required.', 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        analyzed = engine.analyze_meal_photo(request, photo)
        if analyzed is None:
            return Response({
                'success': False, 'data': None,
                'message': 'Meal analysis service unavailable.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        return Response({
            'success': True, 'data': analyzed,
            'message': 'Meal analysis complete.', 'errors': None, 'pagination': None,
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
                f"📊 My {period} BuddyUp progress report — "
                f"{summary['workouts']['count']} workouts, "
                f"{summary['activity']['total_distance_km']}km walked/run, "
                f"{summary['nutrition']['total_calories']:.0f} kcal logged."
            )

        requested_visibility = request.data.get('visibility', 'public')
        if requested_visibility not in ('public', 'buddies', 'gym_members', 'private'):
            requested_visibility = 'public'

        post = Post.objects.create(
            author=profile,
            post_type='progress',
            body=body,
            media_urls=[image_url] if image_url else [],
            progress_data={'report_period': period, 'summary': summary},
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


class AchievementsView(views.APIView):
    """GET /analytics/achievements/?period=weekly

    Returns the achievement catalog with live progress for the requesting
    user. Progress is computed on request from real activity — nothing is
    stored, so values can never go stale or be written directly.
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        import datetime
        from django.db.models import Count, Sum
        from django.utils import timezone
        from .models import Achievement

        period = request.query_params.get('period', 'weekly')
        if period not in ('daily', 'weekly', 'monthly', 'quarterly', 'yearly'):
            period = 'weekly'

        now = timezone.now()
        today = now.date()
        starts = {
            'daily': datetime.datetime.combine(today, datetime.time.min, tzinfo=timezone.utc),
            'weekly': now - timezone.timedelta(days=today.weekday()),
            'monthly': datetime.datetime(today.year, today.month, 1, tzinfo=timezone.utc),
            'quarterly': datetime.datetime(
                today.year, ((today.month - 1) // 3) * 3 + 1, 1, tzinfo=timezone.utc),
            'yearly': datetime.datetime(today.year, 1, 1, tzinfo=timezone.utc),
        }
        window_start = starts[period]
        profile = request.user.profile

        workouts = WorkoutLog.objects.filter(user=profile)
        meals = MealLog.objects.filter(user=profile)
        activities = ActivityRecord.objects.filter(user=profile)

        def metric_value(metric: str):
            if metric == 'workouts_logged':
                return self._count_in(workouts, 'performed_at', window_start, period)
            if metric == 'meals_logged':
                return self._count_in(meals, 'logged_at' if hasattr(MealLog, 'logged_at') else 'created_at', window_start, period)
            if metric == 'activities_distance_km':
                qs = self._in(activities, 'started_at', window_start, period) \
                    .aggregate(total=Sum('distance_meters'))
                return round((qs['total'] or 0) / 1000.0, 1)
            if metric == 'posts_shared':
                try:
                    from apps.feed.models import Post
                    return self._in(Post.objects.filter(author=profile), 'created_at', window_start, period).count()
                except Exception:  # noqa: BLE001
                    return 0
            if metric == 'streak_days':
                return profile.streak_days or 0
            if metric == 'buddies_made':
                try:
                    from apps.profiles.models import BuddyRelationship
                    return BuddyRelationship.objects.filter(
                        (db_models.Q(from_user=profile) | db_models.Q(to_user=profile)),
                        status='confirmed',
                        created_at__gte=window_start,
                    ).count()
                except Exception:  # noqa: BLE001
                    return 0
            return 0

        # Pre-compute per-metric once per request.
        metrics_needed = set(Achievement.objects.values_list('metric', flat=True))
        values = {m: metric_value(m) for m in metrics_needed}

        out = []
        for ach in Achievement.objects.all():
            if ach.period != period:
                continue
            value = int(values.get(ach.metric, 0))
            earned = value >= ach.threshold
            pct = min(100, round((value / ach.threshold) * 100)) if ach.threshold else 0
            out.append({
                'key': ach.key,
                'title': ach.title,
                'description': ach.description,
                'icon': ach.icon,
                'period': ach.period,
                'threshold': ach.threshold,
                'value': value,
                'earned': earned,
                'progress_pct': pct,
            })

        out.sort(key=lambda a: (not a['earned'], -a['progress_pct']))
        return Response({
            'success': True,
            'data': {'period': period, 'achievements': out},
            'message': 'OK', 'errors': None, 'pagination': None,
        })

    @staticmethod
    def _in(qs, field, window_start, _period):
        db_models = __import__('django.db').db.models
        return qs.filter(**{f'{field}__gte': window_start})

    @staticmethod
    def _count_in(qs, field, window_start, _period):
        return AchievementsView._in(qs, field, window_start, _period).count()
