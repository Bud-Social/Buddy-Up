from django.db import models


class RealtimeWebhookEvent(models.Model):
    """Durable idempotency record for signed SFU webhook deliveries."""

    event_id = models.CharField(max_length=180, primary_key=True)
    event_type = models.CharField(max_length=80, blank=True)
    room_name = models.CharField(max_length=120, blank=True, db_index=True)
    payload_hash = models.CharField(max_length=64)
    received_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'realtime_webhook_event'
        indexes = [models.Index(fields=['event_type', '-received_at'])]

    def __str__(self):
        return f'{self.event_type}:{self.event_id}'
