from common.models import TimestampedModel
from django.db import models


class WaitlistEntry(TimestampedModel):
    """Marketing waitlist signup from the landing page (public, no account)."""

    email = models.EmailField(unique=True)
    name = models.CharField(max_length=80, blank=True)
    source = models.CharField(max_length=40, default='landing')

    class Meta:
        db_table = 'waitlist_entry'
        ordering = ['-created_at']

    def __str__(self):
        return self.email
