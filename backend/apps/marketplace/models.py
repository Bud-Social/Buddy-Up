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

    id = models.UUIDField(primary_key=True, editable=False)
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
    id = models.UUIDField(primary_key=True, editable=False)
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


class Product(TimestampedModel):
    CATEGORIES = [
        ('supplement', 'Supplement'),
        ('equipment', 'Equipment'),
        ('gear', 'Gear'),
        ('other', 'Other'),
    ]

    id = models.UUIDField(primary_key=True, editable=False)
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
