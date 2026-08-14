import logging
from pathlib import Path

import requests
from celery import shared_task
from django.conf import settings
from django.core.files.base import ContentFile
from django.utils import timezone

logger = logging.getLogger(__name__)


@shared_task(ignore_result=True, queue='high_priority')
def log_ai_prediction(
    task: str,
    input_data: dict | None = None,
    output_data: dict | None = None,
    error_message: str = '',
    model_version: str = '',
):
    """Persist an audit row for an AI service call (Sprint C7)."""
    from .models import AIPredictionJob
    try:
        AIPredictionJob.objects.create(
            task=task,
            status='failed' if error_message else 'completed',
            input_data=input_data or {},
            output_data=output_data or {},
            error_message=error_message,
            model_version=model_version,
        )
    except Exception as exc:  # noqa: BLE001
        logger.warning('Failed to log AI prediction audit: %s', exc)


@shared_task(ignore_result=True, queue='ai')
def sync_model_metadata():
    """Push Django's ModelMetadata state to the AI service (Sprint C2)."""
    from .sync import push_model_metadata
    count, result = push_model_metadata()
    logger.info('Model metadata sync: %s rows, response=%s', count, result)
    return count


def _update_job(job_id, *, status=None, output_data=None, error_message='', result_url='', model_version=''):
    from .models import AIPredictionJob

    try:
        job = AIPredictionJob.objects.get(pk=job_id)
        if status == 'processing' and not job.started_at:
            job.started_at = timezone.now()
        if status == 'completed':
            job.completed_at = timezone.now()
        if status:
            job.status = status
        if output_data is not None:
            job.output_data = output_data
        if error_message:
            job.error_message = error_message
        if result_url:
            job.result_url = result_url
        if model_version:
            job.model_version = model_version
        job.save(update_fields=[f.name for f in job._meta.fields if f.name in {
            'status', 'started_at', 'completed_at', 'output_data',
            'error_message', 'result_url', 'model_version'}])
    except AIPredictionJob.DoesNotExist:
        logger.warning('AIPredictionJob %s not found', job_id)


def _retry_or_fail(task, job_id, exc, audit_task, audit_input, model_version=''):
    """Mark the job failed when retries are exhausted, else re-queue.

    Celery's ``Task.retry(exc=exc)`` re-raises the original exception (not
    ``MaxRetriesExceededError``) once the retry budget is spent; the outer
    ``except`` therefore never sees ``MaxRetriesExceededError``. We check the
    retry count explicitly so jobs are always transitioned to ``failed``.
    """
    from .audit import audit_ai_call
    if task.request.retries >= task.max_retries:
        _update_job(job_id, status='failed', error_message=str(exc))
        audit_ai_call(audit_task, audit_input, error_message=str(exc), model_version=model_version)
        return
    raise task.retry(exc=exc)


def _store_audio(media_type: str, wav_bytes: bytes, prefix: str = 'tts') -> str:
    """Persist generated audio to the default storage backend (Cloudinary/media)."""
    from django.core.files.storage import default_storage

    ext = 'mp3' if media_type == 'audio/mpeg' else 'wav'
    name = f'ai/{prefix}/{timezone.now().strftime("%Y%m%d%H%M%S")}.{ext}'
    try:
        path = default_storage.save(name, ContentFile(wav_bytes))
        url = default_storage.url(path)
        if not url.startswith('http'):
            url = f'{settings.MEDIA_URL}{path}'
        return url
    except Exception as exc:  # noqa: BLE001
        logger.warning('Audio storage failed (%s) — saving to media root', exc)
        media = Path(settings.MEDIA_ROOT)
        media.mkdir(parents=True, exist_ok=True)
        dest = media / name
        dest.write_bytes(wav_bytes)
        return f'{settings.MEDIA_URL}{name}'


@shared_task(bind=True, max_retries=3, default_retry_delay=10, queue='ai')
def describe_workout_video(self, job_id: str, video_url: str, exercise: str = 'auto'):
    """Fetch a video and request a caption from the AI service."""
    from .audit import audit_ai_call

    try:
        resp = requests.get(video_url, timeout=60)
        if resp.status_code != 200:
            raise requests.RequestException(f'Video fetch failed: {resp.status_code}')
        _update_job(job_id, status='processing')
        ai_resp = requests.post(
            f'{settings.AI_SERVICE_URL}/api/v1/workout/describe',
            files={'file': ('video.mp4', resp.content, 'video/mp4')},
            data={'exercise': exercise},
            timeout=120,
        )
        ai_resp.raise_for_status()
        result = ai_resp.json()
        _update_job(job_id, status='completed', output_data=result, model_version=result.get('model', ''))
        audit_ai_call('video_description', {'video_url': video_url, 'exercise': exercise},
                      result, model_version=result.get('model', ''))
    except Exception as exc:  # noqa: BLE001
        logger.warning('Video description failed for job %s: %s', job_id, exc)
        _retry_or_fail(self, job_id, exc, 'video_description',
                       {'video_url': video_url, 'exercise': exercise})


@shared_task(bind=True, max_retries=3, default_retry_delay=10, queue='ai')
def run_summarization(self, job_id: str, text: str):
    """Summarize text via the AI service."""
    from .audit import audit_ai_call

    try:
        _update_job(job_id, status='processing')
        ai_resp = requests.post(
            f'{settings.AI_SERVICE_URL}/api/v1/summarize',
            json={'text': text},
            timeout=60,
        )
        ai_resp.raise_for_status()
        result = ai_resp.json()
        _update_job(job_id, status='completed', output_data=result, model_version=result.get('model', ''))
        audit_ai_call('summarization', {'text_chars': len(text)}, result, model_version=result.get('model', ''))
    except Exception as exc:  # noqa: BLE001
        logger.warning('Summarization failed for job %s: %s', job_id, exc)
        _retry_or_fail(self, job_id, exc, 'summarization',
                       {'text_chars': len(text)})


@shared_task(bind=True, max_retries=3, default_retry_delay=10, queue='ai')
def synthesize_speech(self, job_id: str, text: str, speaker: str = ''):
    """Synthesize TTS audio via the AI service and store the WAV."""
    from .audit import audit_ai_call

    try:
        _update_job(job_id, status='processing')
        payload = {'text': text}
        if speaker:
            payload['speaker'] = speaker
        ai_resp = requests.post(
            f'{settings.AI_SERVICE_URL}/api/v1/tts/synthesize',
            json=payload,
            timeout=120,
        )
        ai_resp.raise_for_status()
        url = _store_audio(ai_resp.headers.get('content-type', 'audio/wav'), ai_resp.content)
        _update_job(
            job_id,
            status='completed',
            result_url=url,
            output_data={'speaker': ai_resp.headers.get('x-speaker', ''),
                         'sample_rate': ai_resp.headers.get('x-sample-rate', '')},
            model_version=ai_resp.headers.get('x-model', ''),
        )
        audit_ai_call('text_to_speech', {'text_chars': len(text), 'speaker': speaker},
                      {'result_url': url}, model_version=ai_resp.headers.get('x-model', ''))
    except Exception as exc:  # noqa: BLE001
        logger.warning('TTS failed for job %s: %s', job_id, exc)
        _retry_or_fail(self, job_id, exc, 'text_to_speech',
                       {'text_chars': len(text), 'speaker': speaker})


def _image_url(obj) -> str:
    """Resolve a Cloudinary/media URL from a marketplace content object."""
    if getattr(obj, 'cover_image', None):
        try:
            return obj.cover_image.url
        except Exception:  # noqa: BLE001
            pass
    return getattr(obj, 'cover_image_url', '') or getattr(obj, 'image_url', '')


@shared_task(bind=True, max_retries=3, default_retry_delay=15, queue='ai')
def embed_and_index_images(self, index_name: str = 'visual_search'):
    """Embed marketplace product + meal-plan images and rebuild a FAISS index."""
    from .audit import audit_ai_call

    vectors = []
    sources = []
    try:
        from apps.marketplace.models import MealPlan, Product
        sources = list(MealPlan.objects.filter(is_published=True).only('id', 'cover_image', 'cover_image_url')) \
            + list(Product.objects.filter(is_active=True).only('id', 'cover_image', 'image_url'))
    except Exception as exc:  # noqa: BLE001
        logger.warning('Could not enumerate marketplace images: %s', exc)

    for obj in sources:
        url = _image_url(obj)
        if not url:
            continue
        try:
            img_resp = requests.get(url, timeout=20)
            if img_resp.status_code != 200:
                continue
            ai_resp = requests.post(
                f'{settings.AI_SERVICE_URL}/api/v1/embeddings/image',
                files={'file': ('image.jpg', img_resp.content, 'image/jpeg')},
                timeout=30,
            )
            ai_resp.raise_for_status()
            vectors.append({'id': f'{type(obj).__name__}:{obj.pk}', 'vector': ai_resp.json()['vector']})
        except Exception as exc:  # noqa: BLE001
            logger.warning('Image embedding failed for %s %s: %s', type(obj).__name__, obj.pk, exc)

    if not vectors:
        logger.warning('No image embeddings produced for index %s', index_name)
        return

    try:
        ai_resp = requests.post(
            f'{settings.AI_SERVICE_URL}/api/v1/embeddings/index/build',
            json={'index_name': index_name, 'vectors': vectors},
            timeout=30,
        )
        ai_resp.raise_for_status()
        result = ai_resp.json()
        audit_ai_call('visual_search_embedding', {'index_name': index_name, 'n_sources': len(sources)},
                      result, model_version='clip-vit-base-patch32')
        logger.info('Visual search index %s rebuilt with %d vectors', index_name, len(vectors))
    except Exception as exc:  # noqa: BLE001
        logger.warning('Index build failed for %s: %s', index_name, exc)
        _retry_or_fail(self, '', exc, 'visual_search_embedding',
                       {'index_name': index_name, 'n_sources': len(sources)},
                       model_version='clip-vit-base-patch32')
