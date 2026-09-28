"""ML dashboard admin endpoints (staff only).

Aggregates model metadata, persisted training runs and system health so the
frontend `/admin` dashboard can render everything from a single request.
Also hosts the data-operations surface (scraper/loader status), the model
promote/rollback control, and the artifact testing proxy.
"""
import json
import shutil
import subprocess
import time
from datetime import timedelta
from pathlib import Path

from django.conf import settings
from django.db.models import Count
from django.utils import timezone
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAdminUser
from rest_framework.response import Response

from .client import ai_post, ai_service_url
from .models import ModelMetadata, TrainingRun
from .serializers import ModelMetadataSerializer, TrainingRunSerializer


def _ai_service_dir() -> Path:
    return settings.BASE_DIR / 'ai_service'


# ai-service routes the testing tab may call, with the model they exercise.
# Anything not listed here is rejected — the proxy must never become an
# open relay into the inference service.
TEST_ROUTES = {
    '/api/v1/moderation/text': {'model': 'toxicity_classifier', 'kind': 'text_form', 'field': 'text'},
    '/api/v1/moderation/image': {'model': 'nsfw_classifier', 'kind': 'image'},
    '/api/v1/embeddings/text': {'model': 'matching_embeddings', 'kind': 'text_query'},
    '/api/v1/embeddings/image': {'model': 'matching_embeddings', 'kind': 'image'},
    '/api/v1/embeddings/clip-text': {'model': 'matching_embeddings', 'kind': 'text_query'},
    '/api/v1/food/recognize': {'model': 'food_calorie_regressor', 'kind': 'image'},
    '/api/v1/form-analyzer/analyze': {'model': 'form_analyzer', 'kind': 'image'},
    '/api/v1/feed/rank': {'model': 'feed_ranker', 'kind': 'json'},
    '/api/v1/workout/analyze': {'model': 'workout_forecast', 'kind': 'json'},
}


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

    @action(detail=False, methods=['get'], url_path='scrapers')
    def scrapers(self, request):
        """GET /api/v1/admin/dashboard/scrapers/ — recent scrape batches.

        Reads data/batches manifests written by data_agent scrape/fetch runs.
        """
        batches_dir = _ai_service_dir() / 'data' / 'batches'
        items = []
        if batches_dir.exists():
            for task_dir in sorted(p for p in batches_dir.iterdir() if p.is_dir()):
                for batch in sorted(p for p in task_dir.iterdir() if p.is_dir()):
                    man = batch / 'manifest.json'
                    meta = {}
                    mtime = 0
                    if man.exists():
                        try:
                            meta = json.loads(man.read_text())
                            mtime = man.stat().st_mtime
                        except (OSError, ValueError):
                            pass
                    else:
                        try:
                            mtime = batch.stat().st_mtime
                        except OSError:
                            pass
                    size_mb = round(sum(
                        f.stat().st_size for f in batch.rglob('*') if f.is_file()
                    ) / 1e6, 1)
                    items.append({
                        'task': task_dir.name, 'batch': batch.name,
                        'mb': size_mb, 'n': meta.get('n'),
                        'source': str(meta.get('source', ''))[:200],
                        'mtime': mtime,
                    })
        items.sort(key=lambda r: r['mtime'] or 0, reverse=True)
        return Response({'success': True, 'data': items, 'message': 'OK',
                         'errors': None, 'pagination': None})

    @action(detail=False, methods=['get'], url_path='loaders')
    def loaders(self, request):
        """GET /api/v1/admin/dashboard/loaders/ — data_agent status + disk.

        Shells out to `data_agent.py status --json` (stdlib-only command).
        Degrades to disk-only info when the agent is unavailable.
        """
        payload: dict = {}
        agent = _ai_service_dir() / 'training' / 'data_agent.py'
        try:
            proc = subprocess.run(
                ['python3', str(agent), 'status', '--json'],
                capture_output=True, text=True, timeout=60,
            )
            if proc.returncode == 0:
                payload = json.loads(proc.stdout or '{}')
        except (OSError, ValueError, subprocess.SubprocessError):
            pass
        if not payload:
            total, used, free = shutil.disk_usage(str(_ai_service_dir() / 'data'))
            payload = {
                'disk': {'total_gb': round(total / 1e9, 1),
                         'used_gb': round(used / 1e9, 1),
                         'free_gb': round(free / 1e9, 1)},
                'sources': [], 'batches': [], 'tasks': [],
                'degraded': True,
            }
        return Response({'success': True, 'data': payload, 'message': 'OK',
                         'errors': None, 'pagination': None})

    @action(detail=False, methods=['post'], url_path='models/register')
    def register_model(self, request):
        """POST /api/v1/admin/dashboard/models/register/ — upsert + promote.

        Body: {name, version, artifact_path?, framework?, description?,
        metrics?, activate?, deactivate_others?}. Mirrors the
        `register_model` management command for dashboard use.
        """
        name = (request.data.get('name') or '').strip()
        version = (request.data.get('version') or '').strip()
        if not name or not version:
            return Response({
                'success': False, 'data': None,
                'message': 'name and version are required.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)
        metrics = request.data.get('metrics') or {}
        if not isinstance(metrics, dict):
            return Response({
                'success': False, 'data': None,
                'message': 'metrics must be an object.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)
        row, _ = ModelMetadata.objects.update_or_create(
            name=name, version=version,
            defaults={
                'artifact_path': request.data.get('artifact_path', ''),
                'framework': request.data.get('framework', 'pytorch'),
                'description': request.data.get('description', ''),
                'metrics': metrics,
            },
        )
        if request.data.get('activate') and not row.is_active:
            row.is_active = True
            row.save(update_fields=['is_active'])
        if request.data.get('deactivate') and row.is_active:
            row.is_active = False
            row.save(update_fields=['is_active'])
        if request.data.get('deactivate_others'):
            ModelMetadata.objects.filter(name=name).exclude(pk=row.pk).update(is_active=False)
        return Response({
            'success': True, 'data': ModelMetadataSerializer(row).data,
            'message': 'Model registered.',
            'errors': None, 'pagination': None,
        }, status=201)

    @action(detail=False, methods=['post'], url_path='models/test')
    def test_model(self, request):
        """POST /api/v1/admin/dashboard/models/test/ — probe the live artifact.

        Body: {route, text?, json?, image? (multipart file)}. Proxies to the
        ai-service route from the TEST_ROUTES allowlist and reports latency
        plus the currently active artifact version for that model.
        """
        route = request.data.get('route', '')
        spec = TEST_ROUTES.get(route)
        if spec is None:
            return Response({
                'success': False, 'data': None,
                'message': f'Unknown route. Allowed: {sorted(TEST_ROUTES)}.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)
        url = ai_service_url() + route
        started = time.perf_counter()
        try:
            if spec['kind'] == 'image':
                upload = request.FILES.get('image')
                if upload is None:
                    return Response({
                        'success': False, 'data': None,
                        'message': 'An image file is required for this route.',
                        'errors': None, 'pagination': None,
                    }, status=status.HTTP_400_BAD_REQUEST)
                resp = ai_post(url, files={
                    'file': (upload.name, upload.read(),
                             upload.content_type or 'image/jpeg'),
                }, timeout=120)
            elif spec['kind'] == 'json':
                payload = request.data.get('json')
                if isinstance(payload, str):
                    try:
                        payload = json.loads(payload)
                    except ValueError:
                        return Response({
                            'success': False, 'data': None,
                            'message': 'json must be valid JSON.',
                            'errors': None, 'pagination': None,
                        }, status=status.HTTP_400_BAD_REQUEST)
                if not isinstance(payload, dict):
                    return Response({
                        'success': False, 'data': None,
                        'message': 'json must be an object.',
                        'errors': None, 'pagination': None,
                    }, status=status.HTTP_400_BAD_REQUEST)
                resp = ai_post(url, json=payload, timeout=120)
            else:
                text = (request.data.get('text') or '').strip()
                if not text:
                    return Response({
                        'success': False, 'data': None,
                        'message': 'text is required for this route.',
                        'errors': None, 'pagination': None,
                    }, status=status.HTTP_400_BAD_REQUEST)
                if spec['kind'] == 'text_form':
                    resp = ai_post(url, data={'text': text}, timeout=120)
                else:  # text_query
                    resp = ai_post(url, params={'text': text}, timeout=120)
        except Exception as exc:  # noqa: BLE001 — report, never 500
            return Response({
                'success': False, 'data': None,
                'message': f'AI service unreachable: {exc}',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_502_BAD_GATEWAY)
        elapsed_ms = round((time.perf_counter() - started) * 1000)
        try:
            body = resp.json()
        except ValueError:
            body = {'raw': resp.text[:4000]}
        active = ModelMetadata.objects.filter(
            name=spec['model'], is_active=True).order_by('-version').first()
        return Response({
            'success': resp.ok,
            'data': {
                'model': spec['model'],
                'route': route,
                'active_version': active.version if active else None,
                'artifact_path': active.artifact_path if active else '',
                'elapsed_ms': elapsed_ms,
                'status_code': resp.status_code,
                'result': body,
            },
            'message': 'OK' if resp.ok else 'Model returned an error.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_200_OK if resp.ok else status.HTTP_502_BAD_GATEWAY)
