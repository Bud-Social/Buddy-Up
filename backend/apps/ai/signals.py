from django.db.models.signals import post_save
from django.dispatch import receiver

from .models import ModelMetadata
from .tasks import sync_model_metadata


@receiver(post_save, sender=ModelMetadata)
def on_model_metadata_saved(sender, instance, created, **kwargs):
    """Fire-and-forget push to the AI service whenever metadata changes so a
    canary/rollback flip takes effect without redeploying the AI service."""
    try:
        sync_model_metadata.delay()
    except Exception:
        pass
