import logging

from celery import shared_task
from django.core.files.storage import default_storage
from django.utils import timezone


logger = logging.getLogger(__name__)


@shared_task
def purge_expired_verification_documents(limit=100):
    """Delete sensitive files after their retention deadline.

    Metadata remains for audit/appeal provenance; the file URL is blanked so
    serializers cannot disclose a stale location.
    """
    from urllib.parse import unquote, urlparse
    from .models import VerificationDocument

    docs = VerificationDocument.objects.filter(
        purge_after__lte=timezone.now(),
        purged_at__isnull=True,
    ).order_by('purge_after')[:limit]
    purged = 0
    for doc in docs:
        url = doc.file_url
        try:
            if url and not url.startswith(('http://', 'https://')):
                # Internal storage reference (server-generated path): delete
                # the stored object directly, never exposing its location.
                if '..' not in url.split('/'):
                    default_storage.delete(url)
            else:
                media_base = urlparse(default_storage.url('')).path.rstrip('/') + '/'
                path = urlparse(url).path
                if path.startswith(media_base):
                    relative = unquote(path[len(media_base):]).lstrip('/')
                    if relative and '..' not in relative.split('/'):
                        default_storage.delete(relative)
            doc.file_url = ''
            doc.purged_at = timezone.now()
            doc.save(update_fields=['file_url', 'purged_at'])
            purged += 1
        except Exception:  # noqa: BLE001
            logger.exception('verification_document_purge_failed document_id=%s', doc.id)
    logger.info('verification_document_purge completed=%s', purged)
    return purged
