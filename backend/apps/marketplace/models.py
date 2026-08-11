from uuid import uuid4

from django.db import models
from cloudinary.models import CloudinaryField
from common.models import TimestampedModel, SoftDeleteModel
from common.age_gating import CONTENT_RATING_CHOICES, CONTENT_RATING_DEFAULT


# ---------------------------------------------------------------------------
# Shop ecosystem
# ---------------------------------------------------------------------------

class Shop(TimestampedModel):
    CATEGORY_CHOICES = [
        ('fitness', 'Fitness & Training'),
        ('nutrition', 'Nutrition & Meal Plans'),
        ('wellness', 'Wellness & Recovery'),
        ('coaching', 'Coaching & Mentoring'),
        ('equipment', 'Equipment & Gear'),
        ('mixed', 'Mixed / Multi-Category'),
    ]
    VERIFICATION_STATUS = [
        ('unverified', 'Unverified'),
        ('pending', 'Pending Review'),
        ('verified', 'Verified / Buddy Up Certified'),
        ('rejected', 'Rejected'),
        ('suspended', 'Suspended'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    name = models.CharField(max_length=200)
    handle = models.SlugField(max_length=60, unique=True)
    description = models.TextField(blank=True)
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES, default='mixed')
    logo = CloudinaryField('image', folder='shops/logos', blank=True, null=True)
    banner = CloudinaryField('image', folder='shops/banners', blank=True, null=True)
    logo_url = models.URLField(blank=True)       # fallback / Django media URL
    banner_url = models.URLField(blank=True)
    accent_color = models.CharField(max_length=7, default='#6366f1')
    contact_email = models.EmailField(blank=True)
    contact_phone = models.CharField(max_length=30, blank=True)
    website_url = models.URLField(blank=True)
    social_links = models.JSONField(default=dict)   # {instagram, twitter, tiktok, ...}
    refund_policy = models.TextField(blank=True)
    is_active = models.BooleanField(default=True)
    # Verification
    verification_status = models.CharField(max_length=15, choices=VERIFICATION_STATUS, default='unverified')
    verification_applied_at = models.DateTimeField(null=True, blank=True)
    verified_at = models.DateTimeField(null=True, blank=True)
    rejection_reason = models.TextField(blank=True)

    class Meta:
        db_table = 'marketplace_shop'
        indexes = [
            models.Index(fields=['handle']),
            models.Index(fields=['verification_status']),
            models.Index(fields=['category']),
        ]

    def __str__(self):
        return self.name


class ShopMembership(TimestampedModel):
    """M2M: Shop ↔ Profile with a role. A shop can have multiple owners."""
    ROLE_CHOICES = [
        ('owner', 'Owner'),
        ('manager', 'Manager'),
        ('staff', 'Staff'),
    ]
    shop = models.ForeignKey(Shop, on_delete=models.CASCADE, related_name='memberships')
    profile = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='shop_memberships')
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default='owner')

    class Meta:
        db_table = 'marketplace_shop_membership'
        unique_together = ('shop', 'profile')

    def __str__(self):
        return f'{self.profile.username} → {self.shop.name} ({self.role})'


class ShopGymLink(TimestampedModel):
    """A shop can be linked to one or more gyms."""
    shop = models.ForeignKey(Shop, on_delete=models.CASCADE, related_name='gym_links')
    gym = models.ForeignKey('gyms.Gym', on_delete=models.CASCADE, related_name='shop_links')
    is_primary = models.BooleanField(default=False)

    class Meta:
        db_table = 'marketplace_shop_gym_link'
        unique_together = ('shop', 'gym')


# ---------------------------------------------------------------------------
# Buddy Up Certification application
# ---------------------------------------------------------------------------

class ShopVerificationApplication(TimestampedModel):
    STATUS_CHOICES = [
        ('draft', 'Draft'),
        ('submitted', 'Submitted'),
        ('under_review', 'Under Review'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
        ('more_info_needed', 'More Info Needed'),
    ]
    SERVICE_TYPE_CHOICES = [
        ('fitness_trainer', 'Fitness Trainer / Coach'),
        ('nutritionist', 'Nutritionist / Dietitian'),
        ('wellness_coach', 'Wellness Coach'),
        ('physiotherapist', 'Physiotherapist'),
        ('sports_doctor', 'Sports Doctor'),
        ('gym_owner', 'Gym Owner / Operator'),
        ('content_creator', 'Fitness Content Creator'),
        ('equipment_retailer', 'Equipment Retailer'),
        ('other', 'Other'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    shop = models.ForeignKey(Shop, on_delete=models.CASCADE, related_name='verification_applications')
    submitted_by = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='cert_applications')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='draft')
    service_type = models.CharField(max_length=25, choices=SERVICE_TYPE_CHOICES, blank=True)

    # Step 1: Business details
    legal_name = models.CharField(max_length=200, blank=True)
    business_registration_number = models.CharField(max_length=100, blank=True)
    country = models.CharField(max_length=100, blank=True)
    phone = models.CharField(max_length=30, blank=True)

    # Step 2: Professional documents (Cloudinary + fallback URL)
    id_document = CloudinaryField('raw', folder='certs/id_docs', blank=True, null=True)
    id_document_url = models.URLField(blank=True)
    professional_cert = CloudinaryField('raw', folder='certs/prof_certs', blank=True, null=True)
    professional_cert_url = models.URLField(blank=True)
    additional_docs = models.JSONField(default=list)    # [{url, label}, ...]

    # Step 3: Social proof
    website_url = models.URLField(blank=True)
    social_proof_links = models.JSONField(default=list)   # [url, ...]
    years_of_experience = models.IntegerField(null=True, blank=True)
    specializations = models.JSONField(default=list)
    bio_statement = models.TextField(blank=True)

    # Step 4: Policy agreement
    agreed_to_creator_policy = models.BooleanField(default=False)
    agreed_at = models.DateTimeField(null=True, blank=True)

    # Review fields
    reviewed_by = models.ForeignKey('profiles.Profile', null=True, blank=True,
                                    on_delete=models.SET_NULL, related_name='reviewed_applications')
    reviewed_at = models.DateTimeField(null=True, blank=True)
    reviewer_notes = models.TextField(blank=True)
    rejection_reason = models.TextField(blank=True)

    class Meta:
        db_table = 'marketplace_shop_verification_application'
        ordering = ['-created_at']

    def __str__(self):
        return f'Cert app for {self.shop.name} ({self.status})'


# ---------------------------------------------------------------------------
# Push notification devices
# ---------------------------------------------------------------------------

class PushDevice(TimestampedModel):
    PLATFORM_CHOICES = [
        ('fcm', 'Firebase Cloud Messaging (Android/iOS)'),
        ('web', 'Web Push (Browser / PWA)'),
        ('apns', 'Apple Push Notification (APNS)'),
    ]
    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    profile = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='push_devices')
    platform = models.CharField(max_length=10, choices=PLATFORM_CHOICES)
    token = models.TextField()   # FCM token, web push subscription JSON, or APNS token
    device_name = models.CharField(max_length=100, blank=True)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'marketplace_push_device'
        unique_together = ('profile', 'token')
        indexes = [
            models.Index(fields=['profile', 'platform']),
            models.Index(fields=['is_active']),
        ]


# ---------------------------------------------------------------------------
# Meal Plans
# ---------------------------------------------------------------------------

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
    shop = models.ForeignKey(Shop, null=True, blank=True, on_delete=models.SET_NULL, related_name='meal_plans')
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    cover_image = CloudinaryField('image', folder='marketplace/covers', blank=True, null=True)
    cover_image_url = models.URLField(blank=True)   # fallback (old data or Django media)
    trailer_video_url = models.URLField(blank=True)
    diet_type = models.CharField(max_length=20, choices=DIET_TYPES)
    duration_weeks = models.IntegerField(default=4)
    meals_per_day = models.IntegerField(default=3)
    calorie_range = models.CharField(max_length=50, blank=True)
    macro_targets = models.JSONField(default=dict)   # {protein_pct, carbs_pct, fat_pct}
    allergen_flags = models.JSONField(default=list)  # ['gluten', 'dairy', ...]
    rest_days = models.JSONField(default=list)        # [0, 6] = Sunday+Saturday
    content_rating = models.CharField(
        max_length=10, choices=CONTENT_RATING_CHOICES, default=CONTENT_RATING_DEFAULT,
    )
    price_artifacts = models.JSONField(default=dict)
    preview_day = models.JSONField(default=dict)
    full_plan = models.JSONField(default=dict)        # {week: {day: {meal_slot: {...}}}}
    shopping_list = models.JSONField(default=list)
    # Reminder settings (creator-defined defaults)
    reminder_settings = models.JSONField(default=dict)   # {enabled, time_of_day, message_template}
    is_published = models.BooleanField(default=True)
    is_draft = models.BooleanField(default=False)
    purchase_count = models.IntegerField(default=0)
    average_rating = models.FloatField(default=0.0)
    review_count = models.IntegerField(default=0)

    class Meta:
        db_table = 'marketplace_meal_plan'
        indexes = [
            models.Index(fields=['creator']),
            models.Index(fields=['shop']),
            models.Index(fields=['diet_type']),
            models.Index(fields=['is_published', '-purchase_count']),
        ]


class MealPlanPurchase(TimestampedModel):
    meal_plan = models.ForeignKey(MealPlan, on_delete=models.CASCADE, related_name='purchases')
    buyer = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='meal_plan_purchases')
    tx_id = models.CharField(max_length=100, blank=True)
    is_personalised = models.BooleanField(default=False)
    personalised_data = models.JSONField(null=True, blank=True)
    # Subscriber-specific reminder overrides
    reminder_settings = models.JSONField(default=dict)  # {enabled, time_of_day, message}

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


# ---------------------------------------------------------------------------
# Training Programmes
# ---------------------------------------------------------------------------

class TrainingProgramme(TimestampedModel):
    DIFFICULTY_CHOICES = [
        ('beginner', 'Beginner'),
        ('intermediate', 'Intermediate'),
        ('advanced', 'Advanced'),
        ('all_levels', 'All Levels'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    creator = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='marketplace_programmes')
    shop = models.ForeignKey(Shop, null=True, blank=True, on_delete=models.SET_NULL, related_name='programmes')
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    cover_image = CloudinaryField('image', folder='marketplace/covers', blank=True, null=True)
    cover_image_url = models.URLField(blank=True)
    trailer_video_url = models.URLField(blank=True)
    category = models.CharField(max_length=50)
    difficulty = models.CharField(max_length=15, choices=DIFFICULTY_CHOICES, default='all_levels')
    fitness_goals = models.JSONField(default=list)       # ['weight_loss', 'muscle_gain', ...]
    duration_weeks = models.IntegerField(default=8)
    sessions_per_week = models.IntegerField(default=3)
    rest_days_pattern = models.JSONField(default=list)   # [0, 6]
    equipment_list = models.JSONField(default=list)      # ['resistance bands', 'dumbbells', ...]
    prerequisites = models.TextField(blank=True)
    content_rating = models.CharField(
        max_length=10, choices=CONTENT_RATING_CHOICES, default=CONTENT_RATING_DEFAULT,
    )
    # Structured activity schedule: [{week, day, time_of_day, duration_min, activity:{...}}, ...]
    schedule = models.JSONField(default=list)
    # Default notification config (creators set defaults; subscribers can override)
    notification_config = models.JSONField(default=dict)  # {remind_30min, remind_15min, custom_msg}
    price_artifacts = models.JSONField(default=dict)
    is_published = models.BooleanField(default=True)
    is_draft = models.BooleanField(default=False)
    purchase_count = models.IntegerField(default=0)

    class Meta:
        db_table = 'marketplace_programme'
        indexes = [
            models.Index(fields=['creator']),
            models.Index(fields=['shop']),
            models.Index(fields=['category']),
            models.Index(fields=['is_published', '-purchase_count']),
        ]


class TrainingProgrammePurchase(TimestampedModel):
    programme = models.ForeignKey(TrainingProgramme, on_delete=models.CASCADE, related_name='purchases')
    buyer = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='programme_purchases')
    tx_id = models.CharField(max_length=100, blank=True)
    # Subscriber-level notification preferences (overrides programme defaults)
    notification_config = models.JSONField(default=dict)  # {remind_30min, remind_15min, custom_msg}

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


class ProgrammeActivityProgress(TimestampedModel):
    """Tracks subscriber progress on individual activities within a programme."""
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('in_progress', 'In Progress'),
        ('completed', 'Completed'),
        ('skipped', 'Skipped'),
    ]
    purchase = models.ForeignKey(TrainingProgrammePurchase, on_delete=models.CASCADE, related_name='activity_progress')
    activity_key = models.CharField(max_length=50)   # e.g., "w1_d3_morning_0" (week/day/slot/index)
    status = models.CharField(max_length=15, choices=STATUS_CHOICES, default='pending')
    completed_at = models.DateTimeField(null=True, blank=True)
    notes = models.TextField(blank=True)

    class Meta:
        db_table = 'marketplace_programme_activity_progress'
        unique_together = ('purchase', 'activity_key')
        indexes = [
            models.Index(fields=['purchase', 'status']),
        ]


# ---------------------------------------------------------------------------
# Products
# ---------------------------------------------------------------------------

class Product(TimestampedModel):
    CATEGORIES = [
        ('supplement', 'Supplement'),
        ('equipment', 'Equipment'),
        ('gear', 'Gear'),
        ('apparel', 'Apparel'),
        ('book', 'Book / Guide'),
        ('digital', 'Digital Product'),
        ('other', 'Other'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    name = models.CharField(max_length=200)
    brand = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    highlights = models.JSONField(default=list)   # bullet-point feature list
    category = models.CharField(max_length=20, choices=CATEGORIES, default='supplement')
    cover_image = CloudinaryField('image', folder='marketplace/products', blank=True, null=True)
    image_url = models.URLField(blank=True)       # fallback / old data
    gallery_urls = models.JSONField(default=list)  # additional images
    content_rating = models.CharField(
        max_length=10, choices=CONTENT_RATING_CHOICES, default=CONTENT_RATING_DEFAULT,
    )
    variants = models.JSONField(default=list)      # [{size, color, sku, price_display}, ...]
    affiliate_url = models.URLField()
    price_display = models.CharField(max_length=50, blank=True)
    shop = models.ForeignKey(Shop, null=True, blank=True, on_delete=models.SET_NULL, related_name='products')
    recommended_by = models.ForeignKey('profiles.Profile', null=True, blank=True,
        on_delete=models.SET_NULL, related_name='recommended_products')
    is_active = models.BooleanField(default=True)
    click_count = models.IntegerField(default=0)

    class Meta:
        db_table = 'marketplace_product'
        indexes = [
            models.Index(fields=['category']),
            models.Index(fields=['shop']),
            models.Index(fields=['is_active']),
        ]


# ---------------------------------------------------------------------------
# Events
# ---------------------------------------------------------------------------

class MarketplaceEvent(TimestampedModel):
    EVENT_TYPES = [
        ('in_person', 'In Person'),
        ('online', 'Online'),
        ('hybrid', 'Hybrid'),
    ]
    RECURRENCE_CHOICES = [
        ('none', 'One-Time'),
        ('daily', 'Daily'),
        ('weekly', 'Weekly'),
        ('monthly', 'Monthly'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    creator = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='created_events')
    shop = models.ForeignKey(Shop, null=True, blank=True, on_delete=models.SET_NULL, related_name='events')
    gym = models.ForeignKey('gyms.Gym', null=True, blank=True, on_delete=models.SET_NULL, related_name='events')
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    cover_image = CloudinaryField('image', folder='marketplace/events', blank=True, null=True)
    cover_image_url = models.URLField(blank=True)
    promo_video_url = models.URLField(blank=True)
    gallery_urls = models.JSONField(default=list)
    event_type = models.CharField(max_length=15, choices=EVENT_TYPES, default='in_person')
    location = models.CharField(max_length=300, blank=True)
    location_lat = models.FloatField(null=True, blank=True)
    location_lng = models.FloatField(null=True, blank=True)
    online_url = models.URLField(blank=True)
    start_datetime = models.DateTimeField()
    end_datetime = models.DateTimeField()
    timezone = models.CharField(max_length=60, default='UTC')
    recurrence = models.CharField(max_length=10, choices=RECURRENCE_CHOICES, default='none')
    agenda = models.JSONField(default=list)   # [{time, title, description, speaker}, ...]
    capacity = models.IntegerField(default=0)  # 0 = unlimited
    ticket_tiers = models.JSONField(default=list)  # [{name, price_artifacts, capacity, description}, ...]
    ticket_price_artifacts = models.JSONField(default=dict)
    is_free = models.BooleanField(default=True)
    early_bird_enabled = models.BooleanField(default=False)
    early_bird_deadline = models.DateTimeField(null=True, blank=True)
    early_bird_price_artifacts = models.JSONField(default=dict)
    cancellation_policy = models.TextField(blank=True)
    is_published = models.BooleanField(default=True)
    is_draft = models.BooleanField(default=False)
    is_cancelled = models.BooleanField(default=False)
    attendee_count = models.IntegerField(default=0)
    tags = models.JSONField(default=list)
    category = models.CharField(max_length=50, blank=True)
    content_rating = models.CharField(
        max_length=10, choices=CONTENT_RATING_CHOICES, default=CONTENT_RATING_DEFAULT,
    )

    class Meta:
        db_table = 'marketplace_event'
        ordering = ['start_datetime']
        indexes = [
            models.Index(fields=['creator']),
            models.Index(fields=['shop']),
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


# ---------------------------------------------------------------------------
# Event carousel media
# ---------------------------------------------------------------------------

class EventMedia(TimestampedModel):
    MEDIA_TYPES = [
        ('image', 'Image'),
        ('video', 'Video'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    event = models.ForeignKey(MarketplaceEvent, on_delete=models.CASCADE, related_name='media')
    media_type = models.CharField(max_length=10, choices=MEDIA_TYPES)
    file = CloudinaryField('file', folder='marketplace/events/media', blank=True, null=True)
    url = models.URLField(blank=True)
    thumbnail_url = models.URLField(blank=True)
    alt_text = models.CharField(max_length=200, blank=True)
    sort_order = models.IntegerField(default=0)

    class Meta:
        db_table = 'marketplace_event_media'
        ordering = ['sort_order', '-created_at']
        indexes = [
            models.Index(fields=['event', 'sort_order']),
        ]

    def __str__(self):
        return f'{self.media_type} for {self.event.title}'


# ---------------------------------------------------------------------------
# Discount codes
# ---------------------------------------------------------------------------

class DiscountCode(TimestampedModel):
    DISCOUNT_TYPES = [
        ('percentage', 'Percentage'),
        ('fixed_artifacts', 'Fixed Artifacts'),
    ]
    CODE_TYPES = [
        ('text', 'Text Code'),
        ('qr', 'QR Code'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    creator = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='discount_codes')
    code = models.CharField(max_length=50, unique=True)
    discount_type = models.CharField(max_length=20, choices=DISCOUNT_TYPES, default='percentage')
    discount_pct = models.IntegerField(default=0)
    discount_artifacts = models.JSONField(default=dict)
    code_type = models.CharField(max_length=10, choices=CODE_TYPES, default='text')
    qr_code = models.TextField(blank=True)
    description = models.TextField(blank=True, max_length=500)
    campaign = models.CharField(max_length=100, blank=True)
    valid_from = models.DateTimeField(null=True, blank=True)
    valid_until = models.DateTimeField(null=True, blank=True)
    usage_limit = models.IntegerField(default=0)
    max_uses_per_user = models.IntegerField(default=0)
    times_used = models.IntegerField(default=0)
    min_purchase_artifacts = models.JSONField(default=dict)
    is_active = models.BooleanField(default=True)
    is_retired = models.BooleanField(default=False)
    retired_at = models.DateTimeField(null=True, blank=True)
    retired_reason = models.CharField(max_length=200, blank=True)
    share_count = models.IntegerField(default=0)

    class Meta:
        db_table = 'marketplace_discount_code'
        indexes = [
            models.Index(fields=['code']),
            models.Index(fields=['creator']),
            models.Index(fields=['campaign']),
            models.Index(fields=['valid_until']),
        ]

    def __str__(self):
        return self.code


class DiscountUsage(TimestampedModel):
    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    discount = models.ForeignKey(DiscountCode, on_delete=models.CASCADE, related_name='usages')
    user = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='discount_usages')
    cart = models.ForeignKey('Cart', null=True, blank=True, on_delete=models.SET_NULL, related_name='discount_usages')
    order_artifacts = models.JSONField(default=dict)
    discount_pct_applied = models.IntegerField(default=0)
    discount_artifacts_applied = models.JSONField(default=dict)
    savings_artifacts = models.JSONField(default=dict)
    savings_usd = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    was_successful = models.BooleanField(default=True)

    class Meta:
        db_table = 'marketplace_discount_usage'
        indexes = [
            models.Index(fields=['discount']),
            models.Index(fields=['user']),
            models.Index(fields=['created_at']),
        ]

    def __str__(self):
        return f'{self.discount.code} - {self.user.display_name}'


class Cart(TimestampedModel):
    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    buyer = models.OneToOneField('profiles.Profile', on_delete=models.CASCADE, related_name='marketplace_cart')
    discount_code = models.ForeignKey(DiscountCode, null=True, blank=True, on_delete=models.SET_NULL)

    class Meta:
        db_table = 'marketplace_cart'


class CartItem(TimestampedModel):
    ITEM_TYPES = [
        ('meal_plan', 'Meal Plan'),
        ('programme', 'Training Programme'),
        ('product', 'Product'),
        ('event_ticket', 'Event Ticket'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    cart = models.ForeignKey(Cart, on_delete=models.CASCADE, related_name='items')
    item_type = models.CharField(max_length=20, choices=ITEM_TYPES)

    # Target item foreign keys
    meal_plan = models.ForeignKey(MealPlan, null=True, blank=True, on_delete=models.CASCADE)
    programme = models.ForeignKey(TrainingProgramme, null=True, blank=True, on_delete=models.CASCADE)
    product = models.ForeignKey(Product, null=True, blank=True, on_delete=models.CASCADE)
    event = models.ForeignKey(MarketplaceEvent, null=True, blank=True, on_delete=models.CASCADE)

    quantity = models.IntegerField(default=1)

    class Meta:
        db_table = 'marketplace_cart_item'
        unique_together = ('cart', 'item_type', 'meal_plan', 'programme', 'product', 'event')



