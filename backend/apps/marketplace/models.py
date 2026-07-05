from uuid import uuid4

from django.db import models
from common.models import TimestampedModel, SoftDeleteModel


class MealPlan(TimestampedModel):
    DIET_TYPES = [
        ('vegan', 'Vegan'), ('keto', 'Keto'), ('balanced', 'Balanced'),
        ('high_protein', 'High Protein'), ('weight_loss', 'Weight Loss'),
        ('muscle_gain', 'Muscle Gain'), ('diabetic', 'Diabetic-Friendly'),
        ('vegetarian', 'Vegetarian'), ('paleo', 'Paleo'),
        ('gluten_free', 'Gluten-Free'), ('other', 'Other'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    creator = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='meal_plans')
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    diet_type = models.CharField(max_length=20, choices=DIET_TYPES)
    duration_weeks = models.IntegerField(default=4)
    calorie_range = models.CharField(max_length=50, blank=True)
    price_artifacts = models.JSONField(default=dict)
    preview_day = models.JSONField(default=dict)
    full_plan = models.JSONField(default=dict)
    shopping_list = models.JSONField(default=list)
    is_published = models.BooleanField(default=True)
    purchase_count = models.IntegerField(default=0)
    average_rating = models.FloatField(default=0.0)
    review_count = models.IntegerField(default=0)

    class Meta:
        db_table = 'marketplace_meal_plan'
        indexes = [
            models.Index(fields=['creator']),
            models.Index(fields=['diet_type']),
            models.Index(fields=['is_published', '-purchase_count']),
        ]


class MealPlanPurchase(TimestampedModel):
    meal_plan = models.ForeignKey(MealPlan, on_delete=models.CASCADE, related_name='purchases')
    buyer = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='meal_plan_purchases')
    tx_id = models.CharField(max_length=100, blank=True)
    is_personalised = models.BooleanField(default=False)
    personalised_data = models.JSONField(null=True, blank=True)

    class Meta:
        db_table = 'marketplace_meal_plan_purchase'
        unique_together = ('meal_plan', 'buyer')


class MealPlanReview(TimestampedModel):
    purchase = models.OneToOneField(MealPlanPurchase, on_delete=models.CASCADE, related_name='review')
    buyer = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='meal_plan_reviews')
    meal_plan = models.ForeignKey(MealPlan, on_delete=models.CASCADE, related_name='reviews_list')
    rating = models.IntegerField()
    body = models.TextField(blank=True, max_length=500)

    class Meta:
        db_table = 'marketplace_meal_plan_review'
        unique_together = ('purchase', 'buyer')


class TrainingProgramme(TimestampedModel):
    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    creator = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='marketplace_programmes')
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    category = models.CharField(max_length=50)
    duration_weeks = models.IntegerField(default=8)
    price_artifacts = models.JSONField(default=dict)
    is_published = models.BooleanField(default=True)
    purchase_count = models.IntegerField(default=0)

    class Meta:
        db_table = 'marketplace_programme'
        indexes = [
            models.Index(fields=['creator']),
            models.Index(fields=['category']),
            models.Index(fields=['is_published', '-purchase_count']),
        ]


class TrainingProgrammePurchase(TimestampedModel):
    programme = models.ForeignKey(TrainingProgramme, on_delete=models.CASCADE, related_name='purchases')
    buyer = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='programme_purchases')
    tx_id = models.CharField(max_length=100, blank=True)

    class Meta:
        db_table = 'marketplace_programme_purchase'
        unique_together = ('programme', 'buyer')


class TrainingProgrammeReview(TimestampedModel):
    purchase = models.OneToOneField(TrainingProgrammePurchase, on_delete=models.CASCADE, related_name='review')
    buyer = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='programme_reviews')
    programme = models.ForeignKey(TrainingProgramme, on_delete=models.CASCADE, related_name='reviews_list')
    rating = models.IntegerField()
    body = models.TextField(blank=True, max_length=500)

    class Meta:
        db_table = 'marketplace_programme_review'
        unique_together = ('purchase', 'buyer')


class Product(TimestampedModel):
    CATEGORIES = [
        ('supplement', 'Supplement'),
        ('equipment', 'Equipment'),
        ('gear', 'Gear'),
        ('other', 'Other'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    name = models.CharField(max_length=200)
    brand = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    category = models.CharField(max_length=20, choices=CATEGORIES, default='supplement')
    image_url = models.URLField(blank=True)
    affiliate_url = models.URLField()
    price_display = models.CharField(max_length=50, blank=True)
    recommended_by = models.ForeignKey('profiles.Profile', null=True, blank=True,
        on_delete=models.SET_NULL, related_name='recommended_products')
    is_active = models.BooleanField(default=True)
    click_count = models.IntegerField(default=0)

    class Meta:
        db_table = 'marketplace_product'
        indexes = [
            models.Index(fields=['category']),
            models.Index(fields=['is_active']),
        ]


class MarketplaceEvent(TimestampedModel):
    EVENT_TYPES = [
        ('in_person', 'In Person'),
        ('online', 'Online'),
        ('hybrid', 'Hybrid'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    creator = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='created_events')
    gym = models.ForeignKey('gyms.Gym', null=True, blank=True, on_delete=models.SET_NULL, related_name='events')
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    cover_image_url = models.URLField(blank=True)
    event_type = models.CharField(max_length=15, choices=EVENT_TYPES, default='in_person')
    location = models.CharField(max_length=300, blank=True)
    online_url = models.URLField(blank=True)
    start_datetime = models.DateTimeField()
    end_datetime = models.DateTimeField()
    timezone = models.CharField(max_length=60, default='UTC')
    capacity = models.IntegerField(default=0)  # 0 = unlimited
    ticket_price_artifacts = models.JSONField(default=dict)
    is_free = models.BooleanField(default=True)
    is_published = models.BooleanField(default=True)
    is_cancelled = models.BooleanField(default=False)
    attendee_count = models.IntegerField(default=0)
    tags = models.JSONField(default=list)
    category = models.CharField(max_length=50, blank=True)

    class Meta:
        db_table = 'marketplace_event'
        ordering = ['start_datetime']
        indexes = [
            models.Index(fields=['creator']),
            models.Index(fields=['gym']),
            models.Index(fields=['start_datetime', 'is_published']),
        ]

    def __str__(self):
        return self.title


class EventTicket(TimestampedModel):
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('cancelled', 'Cancelled'),
        ('refunded', 'Refunded'),
        ('used', 'Used'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    event = models.ForeignKey(MarketplaceEvent, on_delete=models.CASCADE, related_name='tickets')
    holder = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='event_tickets')
    ticket_code = models.UUIDField(default=uuid4, unique=True, editable=False)
    tier = models.CharField(max_length=50, default='Standard')
    price_paid_artifacts = models.JSONField(default=dict)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='active')
    is_checked_in = models.BooleanField(default=False)
    checked_in_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'marketplace_event_ticket'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['holder']),
            models.Index(fields=['event', 'holder']),
            models.Index(fields=['ticket_code']),
        ]

    def __str__(self):
        return f'Ticket {self.ticket_code} for {self.event.title}'
