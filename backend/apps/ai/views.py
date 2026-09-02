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


class APIKeyViewSet(viewsets.ModelViewSet):
    queryset = APIKey.objects.all()
    serializer_class = APIKeySerializer
    permission_classes = [IsAdminUser]
    search_fields = ['label']
