"""ML dashboard admin endpoints (staff only).

Aggregates model metadata, persisted training runs and system health so the
frontend `/admin` dashboard can render everything from a single request.
"""
import shutil
from datetime import timedelta

from django.conf import settings
from django.db.models import Count
from django.utils import timezone
from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAdminUser
from rest_framework.response import Response

from .models import ModelMetadata, TrainingRun
from .serializers import ModelMetadataSerializer, TrainingRunSerializer


class AdminDashboardViewSet(viewsets.ViewSet):
    permission_classes = [IsAdminUser]

    def list(self, request):
        """GET /api/v1/admin/dashboard/ — aggregated ML status."""
        models = ModelMetadata.objects.all().order_by('name', '-version')
        runs = TrainingRun.objects.all()[:50]

        run_counts = TrainingRun.objects.values('status').order_by().annotate(count=Count('id'))
        status_counts = {row['status']: row['count'] for row in run_counts}

        last_run = TrainingRun.objects.order_by('-created_at').first()
        last_by_model = (
            TrainingRun.objects.order_by('model_name', '-created_at')
            .distinct('model_name')
            .values('model_name', 'created_at')
        )

        disk = shutil.disk_usage(settings.BASE_DIR)
        artifact_dir = settings.BASE_DIR / 'ai_service' / 'models'

        return Response({
            'success': True,
            'data': {
                'models': ModelMetadataSerializer(models, many=True, context={'request': request}).data,
                'runs': TrainingRunSerializer(runs, many=True).data,
                'health': {
                    'models': {
                        'total': models.count(),
                        'active': models.filter(is_active=True).count(),
                    },
                    'runs': {
                        'total': TrainingRun.objects.count(),
                        'completed': status_counts.get('completed', 0),
                        'failed': status_counts.get('failed', 0),
                        'running': status_counts.get('running', 0),
                        'last_24h': TrainingRun.objects.filter(
                            created_at__gte=timezone.now() - timedelta(hours=24)
                        ).count(),
                    },
                    'last_training': last_run.created_at.isoformat() if last_run else None,
                    'last_training_by_model': list(last_by_model),
                    'disk': {
                        'path': str(settings.BASE_DIR),
                        'total_bytes': disk.total,
                        'used_bytes': disk.used,
                        'free_bytes': disk.free,
                        'percent': round(disk.used / disk.total * 100, 1),
                    },
                    'artifact_dir': {
                        'path': str(artifact_dir),
                        'exists': artifact_dir.exists(),
                    },
                    'ai_service_url': settings.AI_SERVICE_URL,
                    'mlflow_tracking_uri': getattr(settings, 'MLFLOW_TRACKING_URI', '') or '',
                },
            },
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })

    @action(detail=False, methods=['post'], url_path='log-training')
    def log_training(self, request):
        """POST /api/v1/admin/dashboard/log-training/ — persist a training run."""
        serializer = TrainingRunSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({
                'success': False, 'data': None,
                'message': 'Invalid training run payload.',
                'errors': serializer.errors, 'pagination': None,
            }, status=400)
        run = serializer.save()
        return Response({
            'success': True,
            'data': TrainingRunSerializer(run).data,
            'message': 'Training run logged.',
            'errors': None, 'pagination': None,
        }, status=201)
