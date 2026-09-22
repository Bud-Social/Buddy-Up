from common.models import TimestampedModel
from django.db import models


class WaitlistEntry(TimestampedModel):
    """Marketing waitlist signup from the landing page (public, no account)."""

    email = models.EmailField(unique=True)
    name = models.CharField(max_length=80, blank=True)
    # Full country name from the signup form (e.g. "Kenya"); required at the
    # API layer (blank only as a DB default for rows predating the field).
    country = models.CharField(max_length=56, default='', blank=True)
    source = models.CharField(max_length=40, default='landing')
    # Prelaunch lead routing: general users, gym founders, or trainers.
    interest = models.CharField(
        max_length=20, default='user',
        choices=[('user', 'User'), ('gym', 'Gym'), ('trainer', 'Trainer')],
    )
    # Optional lead details (gym name/city/size, trainer specialty, ...).
    metadata = models.JSONField(default=dict, blank=True)

    class Meta:
        db_table = 'waitlist_entry'
        ordering = ['-created_at']

    def __str__(self):
        return self.email
