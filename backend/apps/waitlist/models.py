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
    # Prelaunch lead routing: users, gyms, trainers, companies, event
    # organisers, product suppliers/shops, and equipment distributors.
    interest = models.CharField(
        max_length=20, default='user',
        choices=[('user', 'User'), ('gym', 'Gym'), ('trainer', 'Trainer'),
                 ('corporate', 'Corporate'), ('organiser', 'Event Organiser'),
                 ('supplier', 'Supplier / Shop'),
                 ('distributor', 'Distributor')],
    )
    # Optional lead details (gym name/city/size, trainer specialty, ...).
    metadata = models.JSONField(default=dict, blank=True)

    class Meta:
        db_table = 'waitlist_entry'
        ordering = ['-created_at']

    def __str__(self):
        return self.email


class FeatureSuggestion(TimestampedModel):
    """Public feature suggestion from the landing-page roadmap section."""

    CATEGORY_CHOICES = [
        ('gyms', 'Gyms'),
        ('trainers', 'Trainers'),
        ('events', 'Events'),
        ('programmes', 'Programmes'),
        ('analytics', 'Analytics'),
        ('app', 'App Experience'),
        ('other', 'Other'),
    ]
    STATUS_CHOICES = [
        ('new', 'New'),
        ('reviewing', 'Reviewing'),
        ('planned', 'Planned'),
        ('shipped', 'Shipped'),
        ('declined', 'Declined'),
    ]

    title = models.CharField(max_length=120)
    description = models.TextField(max_length=2000)
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES, default='other')
    email = models.EmailField(blank=True, default='')
    name = models.CharField(max_length=80, blank=True, default='')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='new')

    class Meta:
        db_table = 'waitlist_feature_suggestion'
        ordering = ['-created_at']

    def __str__(self):
        return self.title


class ContactInquiry(TimestampedModel):
    """Public quick-contact message from the landing-page footer."""

    TOPIC_CHOICES = [
        ('general', 'General'),
        ('support', 'Support'),
        ('gyms', 'Gyms & Partnerships'),
        ('trainers', 'Trainers'),
        ('press', 'Press'),
    ]
    STATUS_CHOICES = [
        ('new', 'New'),
        ('in_progress', 'In Progress'),
        ('resolved', 'Resolved'),
    ]

    name = models.CharField(max_length=80)
    email = models.EmailField()
    topic = models.CharField(max_length=20, choices=TOPIC_CHOICES, default='general')
    subject = models.CharField(max_length=120, blank=True, default='')
    message = models.TextField(max_length=2000)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='new')

    class Meta:
        db_table = 'waitlist_contact_inquiry'
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.topic}: {self.email}'
