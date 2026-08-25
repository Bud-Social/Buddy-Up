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
        ('shop', 'Shop / Seller Verification'),
        ('gym', 'Gym Verification'),
    ]
    STATUS_CHOICES = [
        ('draft', 'Draft'),
        ('submitted', 'Submitted'),
        ('under_review', 'Under Review'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
        ('expired', 'Expired'),
    ]
    # Wizard steps — only used by the multistep 'id' flow.
    STEPS = [
        ('id_document', 'ID Document'),
        ('selfie_liveness', 'Selfie / Liveness Check'),
        ('face_match', 'Face Match'),
        ('review', 'Review & Submit'),
        ('done', 'Done'),
    ]
    FACE_MATCH_STATUSES = [
        ('pending', 'Pending'),
        ('auto_matched', 'Auto Matched'),
        ('manual_review', 'Manual Review'),
        ('failed', 'Failed'),
        ('skipped', 'Skipped'),
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

    # ── Multistep wizard state (type='id') ────────────────────────────────
    current_step = models.CharField(max_length=20, choices=STEPS, blank=True)
    completed_steps = models.JSONField(default=list, blank=True)
    face_match_status = models.CharField(
        max_length=15, choices=FACE_MATCH_STATUSES, default='pending',
    )
    face_match_score = models.FloatField(
        null=True, blank=True, help_text='Similarity confidence from the face-match backend (0-100)',
    )
    reviewed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL,
        null=True, blank=True, related_name='verification_reviews',
    )
    reviewed_at = models.DateTimeField(null=True, blank=True)
    submitted_at = models.DateTimeField(null=True, blank=True)

    # Credential + scope-of-practice fields (trainers / practitioners / shops).
    credential_title = models.CharField(max_length=120, blank=True)
    credential_issuer = models.CharField(max_length=200, blank=True)
    credential_id = models.CharField(max_length=120, blank=True)
    issued_date = models.DateField(null=True, blank=True)
    scope_of_practice = models.CharField(max_length=30, blank=True, choices=[
        ('general_fitness', 'General Fitness Coaching'),
        ('nutrition_wellness', 'General Wellness Nutrition'),
        ('meal_planning', 'Meal Planning (General Wellness)'),
        ('medical_nutrition', 'Medical Nutrition Therapy'),
        ('physical_therapy', 'Physiotherapy / Rehab'),
        ('clinical', 'Clinical Practice'),
    ])

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
