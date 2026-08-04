import logging

from celery import shared_task

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
    except Exception as exc:
        logger.warning('Failed to log AI prediction audit: %s', exc)


@shared_task(ignore_result=True, queue='ai')
def sync_model_metadata():
    """Push Django's ModelMetadata state to the AI service (Sprint C2)."""
    from .sync import push_model_metadata
    count, result = push_model_metadata()
    logger.info('Model metadata sync: %s rows, response=%s', count, result)
    return count
