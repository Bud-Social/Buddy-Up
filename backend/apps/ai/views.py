from apps.ai.client import ai_post
from django.utils import timezone
from rest_framework import viewsets, mixins, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAdminUser, IsAuthenticated
from rest_framework.response import Response

from .models import AIPredictionJob, ModelMetadata, APIKey
from .serializers import (
    AIPredictionJobSerializer, ModelMetadataSerializer, APIKeySerializer,
)


class AIPredictionJobViewSet(
    mixins.CreateModelMixin,
    mixins.RetrieveModelMixin,
    mixins.ListModelMixin,
    viewsets.GenericViewSet,
):
    queryset = AIPredictionJob.objects.all()
    serializer_class = AIPredictionJobSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['task', 'status']
    search_fields = ['task', 'error_message']

    @action(detail=False, methods=['post'], url_path='video-describe')
    def video_describe(self, request):
        """Queue an async workout-video captioning job."""
        from django.core.files.storage import default_storage
        from .tasks import describe_workout_video

        upload = request.FILES.get('file')
        if not upload:
            return Response({'detail': 'file is required'}, status=status.HTTP_400_BAD_REQUEST)
        exercise = request.POST.get('exercise', 'auto')

        name = f'ai/videos/{timezone.now().strftime("%Y%m%d%H%M%S")}_{upload.name}'
        path = default_storage.save(name, upload)
        url = default_storage.url(path)
        if not url.startswith('http'):
            url = f'{request.build_absolute_uri("/")[:-1]}{url}'

        job = AIPredictionJob.objects.create(
            task='video_description',
            status='pending',
            input_data={'video_url': url, 'exercise': exercise},
        )
        describe_workout_video.delay(str(job.pk), url, exercise)
        return Response(
            {'job_id': job.pk, 'status': job.status, 'poll_url': f'/api/v1/ai/predictions/{job.pk}/'},
            status=status.HTTP_202_ACCEPTED,
        )

    @action(detail=False, methods=['post'], url_path='summarize')
    def summarize(self, request):
        """Queue an async text-summarization job."""
        from .tasks import run_summarization

        text = request.data.get('text', '')
        if not text or not text.strip():
            return Response({'detail': 'text is required'}, status=status.HTTP_400_BAD_REQUEST)

        job = AIPredictionJob.objects.create(
            task='summarization',
            status='pending',
            input_data={'text_chars': len(text)},
        )
        run_summarization.delay(str(job.pk), text)
        return Response(
            {'job_id': job.pk, 'status': job.status, 'poll_url': f'/api/v1/ai/predictions/{job.pk}/'},
            status=status.HTTP_202_ACCEPTED,
        )

    @action(detail=False, methods=['post'], url_path='tts')
    def tts(self, request):
        """Queue an async text-to-speech job; result WAV URL lands on the job."""
        from .tasks import synthesize_speech

        text = request.data.get('text', '')
        if not text or not text.strip():
            return Response({'detail': 'text is required'}, status=status.HTTP_400_BAD_REQUEST)
        speaker = request.data.get('speaker', '')

        job = AIPredictionJob.objects.create(
            task='text_to_speech',
            status='pending',
            input_data={'text_chars': len(text), 'speaker': speaker},
        )
        synthesize_speech.delay(str(job.pk), text, speaker)
        return Response(
            {'job_id': job.pk, 'status': job.status, 'poll_url': f'/api/v1/ai/predictions/{job.pk}/'},
            status=status.HTTP_202_ACCEPTED,
        )


class VisualSearchViewSet(viewsets.GenericViewSet):
    """Sync CLIP visual search over the marketplace image index."""

    permission_classes = [IsAuthenticated]

    def list(self, request):
        query = request.query_params.get('q', '')
        top_k = min(int(request.query_params.get('top_k', 10)), 50)
        if not query or not query.strip():
            return Response({'detail': 'q is required'}, status=status.HTTP_400_BAD_REQUEST)

        from django.conf import settings

        try:
            embed_resp = ai_post(
                f'{settings.AI_SERVICE_URL}/api/v1/embeddings/clip-text',
                params={'text': query},
                timeout=30,
            )
            embed_resp.raise_for_status()
            vector = embed_resp.json()['vector']
            search_resp = ai_post(
                f'{settings.AI_SERVICE_URL}/api/v1/embeddings/index/search',
                json={'index_name': 'visual_search', 'query': vector, 'top_k': top_k},
                timeout=30,
            )
            search_resp.raise_for_status()
            matches = search_resp.json().get('matches', [])
        except Exception as exc:  # noqa: BLE001
            return Response(
                {'detail': f'Visual search unavailable: {exc}'},
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )

        return Response({'query': query, 'matches': matches})


class ModelMetadataViewSet(viewsets.ModelViewSet):
    queryset = ModelMetadata.objects.all()
    serializer_class = ModelMetadataSerializer
    permission_classes = [IsAdminUser]
    filterset_fields = ['name', 'is_active']
    search_fields = ['name', 'description']


class BandedViewSet(viewsets.GenericViewSet):
    """Sync inference through the six banded-ensemble research models.

    Each action fans out to the AI service ``/api/v1/banded/*`` endpoints
    (ONNX artifacts trained by notebooks/banded_*.ipynb on real batches)
    and records an auditable AIPredictionJob. 503 when the artifact or the
    AI service is unavailable — callers must treat these as assistive,
    never authoritative (see moderation fallbacks).
    """

    permission_classes = [IsAuthenticated]

    def _run_job(self, request, task, service_path, input_data,
                 payload=None, files=None, confidence_key='confidence'):
        from django.conf import settings

        job = AIPredictionJob.objects.create(
            task=task, status='pending', input_data=input_data,
        )
        try:
            resp = ai_post(
                f'{settings.AI_SERVICE_URL}{service_path}',
                json=payload, files=files, timeout=60,
            )
            resp.raise_for_status()
            output = resp.json()
        except Exception as exc:  # noqa: BLE001
            job.status = 'failed'
            job.error_message = str(exc)[:500]
            job.save(update_fields=['status', 'error_message'])
            return Response(
                {'detail': f'Banded model unavailable: {exc}', 'job_id': job.pk},
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )
        job.status = 'completed'
        job.output_data = output
        job.confidence = output.get(confidence_key)
        job.completed_at = timezone.now()
        job.save(update_fields=['status', 'output_data', 'confidence', 'completed_at'])
        return Response({**output, 'job_id': job.pk})

    @action(detail=False, methods=['post'], url_path='nlp-classify')
    def nlp_classify(self, request):
        text = request.data.get('text', '')
        if not text or not text.strip():
            return Response({'detail': 'text is required'},
                            status=status.HTTP_400_BAD_REQUEST)
        return self._run_job(request, 'banded_nlp', '/api/v1/banded/nlp/classify',
                             {'text_chars': len(text)}, payload={'text': text})

    @action(detail=False, methods=['post'], url_path='vision-classify')
    def vision_classify(self, request):
        upload = request.FILES.get('file')
        if not upload:
            return Response({'detail': 'file is required'},
                            status=status.HTTP_400_BAD_REQUEST)
        return self._run_job(
            request, 'banded_vision', '/api/v1/banded/vision/classify',
            {'filename': upload.name, 'size': upload.size},
            files={'file': (upload.name, upload.read(),
                            upload.content_type or 'image/jpeg')},
        )

    @action(detail=False, methods=['post'], url_path='multimodal-score')
    def multimodal_score(self, request):
        embeddings = request.data.get('embeddings', [])
        if not embeddings:
            return Response({'detail': 'embeddings is required'},
                            status=status.HTTP_400_BAD_REQUEST)
        return self._run_job(request, 'banded_multimodal',
                             '/api/v1/banded/multimodal/score',
                             {'n': len(embeddings)}, payload={'embeddings': embeddings},
                             confidence_key='confidence')

    @action(detail=False, methods=['post'], url_path='recsys-embed')
    def recsys_embed(self, request):
        item_ids = request.data.get('item_ids', [])
        if not item_ids:
            return Response({'detail': 'item_ids is required'},
                            status=status.HTTP_400_BAD_REQUEST)
        return self._run_job(request, 'banded_recsys', '/api/v1/banded/recsys/embed',
                             {'n_items': len(item_ids)}, payload={'item_ids': item_ids},
                             confidence_key='confidence')

    @action(detail=False, methods=['post'], url_path='rl-nlp-act')
    def rl_nlp_act(self, request):
        text = request.data.get('text', '')
        if not text or not text.strip():
            return Response({'detail': 'text is required'},
                            status=status.HTTP_400_BAD_REQUEST)
        return self._run_job(request, 'banded_rl_text', '/api/v1/banded/rl-nlp/act',
                             {'text_chars': len(text)}, payload={'text': text},
                             confidence_key='confidence')

    @action(detail=False, methods=['post'], url_path='rl-jepa-act')
    def rl_jepa_act(self, request):
        obs = request.data.get('obs', [])
        if not obs:
            return Response({'detail': 'obs is required'},
                            status=status.HTTP_400_BAD_REQUEST)
        return self._run_job(request, 'banded_rl_traj', '/api/v1/banded/rl-jepa/act',
                             {'obs_dim': len(obs)}, payload={'obs': obs},
                             confidence_key='confidence')


class APIKeyViewSet(viewsets.ModelViewSet):
    queryset = APIKey.objects.all()
    serializer_class = APIKeySerializer
    permission_classes = [IsAdminUser]
    search_fields = ['label']
