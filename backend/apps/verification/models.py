from uuid import uuid4

from django.db import models
from django.conf import settings

from common.models import TimestampedModel


class VerificationDocument(TimestampedModel):
    DOCUMENT_TYPES = [
        ('id_card', 'ID Card'),
        ('passport', 'Passport'),
        ('drivers_license', "Driver's License"),
        ('certification', 'Professional Certification'),
        ('proof_of_address', 'Proof of Address'),
        ('selfie', 'Selfie'),
        ('other', 'Other'),
    ]
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
        ('expired', 'Expired'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    profile = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE,
        related_name='verification_documents',
    )
    document_type = models.CharField(max_length=25, choices=DOCUMENT_TYPES)
    file_url = models.URLField()
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')
    rejection_reason = models.TextField(blank=True, max_length=500)
    reviewed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL,
        null=True, blank=True, related_name='document_reviews',
    )
    reviewed_at = models.DateTimeField(null=True, blank=True)
    expires_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'verification_document'
        indexes = [
            models.Index(fields=['profile', 'document_type']),
            models.Index(fields=['status']),
        ]
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.document_type} — {self.status}'


class VerificationSubmission(TimestampedModel):
    VERIFICATION_TYPES = [
        ('id', 'ID Verification'),
        ('trainer', 'Trainer Certification'),
        ('practitioner', 'Health Practitioner'),
    ]
    STATUS_CHOICES = [
        ('draft', 'Draft'),
        ('submitted', 'Submitted'),
        ('under_review', 'Under Review'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
        ('expired', 'Expired'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    profile = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE,
        related_name='verification_submissions',
    )
    verification_type = models.CharField(max_length=20, choices=VERIFICATION_TYPES)
    status = models.CharField(max_length=12, choices=STATUS_CHOICES, default='draft')
    documents = models.ManyToManyField(VerificationDocument, related_name='submissions')
    notes = models.TextField(blank=True, max_length=1000)
    reviewed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL,
        null=True, blank=True, related_name='verification_reviews',
    )
    reviewed_at = models.DateTimeField(null=True, blank=True)
    submitted_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'verification_submission'
        indexes = [
            models.Index(fields=['profile', 'status']),
            models.Index(fields=['verification_type']),
            models.Index(fields=['-created_at']),
        ]
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.verification_type} — {self.status}'
