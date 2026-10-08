import qrcode
import base64
from math import asin, cos, radians, sin, sqrt
from io import BytesIO
from django.utils import timezone
from rest_framework import serializers
from django.core.validators import MinValueValidator
from common.age_gating import CONTENT_RATING_CHOICES
from .models import (
    Shop, ShopMembership, ShopGymLink, ShopVerificationApplication, PushDevice,
    MealPlan, MealPlanPurchase, MealPlanReview,
    TrainingProgramme, TrainingProgrammePurchase, TrainingProgrammeReview,
    ProgrammeActivityProgress,
    Product, MarketplaceEvent, EventMedia, EventTicket, Cart, CartItem, DiscountCode, DiscountUsage,
    Order, OrderItem, OrderFulfillment, OrderCase, CreatorPayoutSetup,
    PickupStation, StationApplication, DeliveryPersonnel, DeliveryPersonnelApplication,
    PaymentIntent,
)
from .models import APPLICATION_STATUS_CHOICES

ARTIFACT_TYPES = ['dumbbell', 'barbell', 'burpee', 'squat', 'sprint', 'pr', 'champion']

ARTIFACT_VALUES = {
    'dumbbell': 0.10,
    'barbell': 0.50,
    'burpee': 1.00,
    'squat': 2.50,
    'sprint': 5.00,
    'pr': 10.00,
    'champion': 25.00,
}

ARTIFACT_LABELS = {
    'dumbbell': 'Dumbbell', 'barbell': 'Barbell', 'burpee': 'Burpee',
    'squat': 'Squat', 'sprint': 'Sprint', 'pr': 'PR', 'champion': 'Champion',
}


def validate_price_artifacts(value):
    if not isinstance(value, dict):
        raise serializers.ValidationError('price_artifacts must be an object.')
    for k, v in value.items():
        if k not in ARTIFACT_TYPES:
            raise serializers.ValidationError(f'Unknown artifact type: {k}')
        if not isinstance(v, int) or v < 1:
            raise serializers.ValidationError(f'Quantity for {k} must be a positive integer.')
    return value


# ---------------------------------------------------------------------------
# Shop serializers
# ---------------------------------------------------------------------------

class ShopMembershipSerializer(serializers.ModelSerializer):
    profile_data = serializers.SerializerMethodField()

    class Meta:
        model = ShopMembership
        fields = ['id', 'profile_id', 'role', 'profile_data', 'created_at']

    def get_profile_data(self, obj):
        return {
            'username': obj.profile.username,
            'display_name': obj.profile.display_name,
            'avatar_url': obj.profile.avatar_url,
        }


class ShopGymLinkSerializer(serializers.ModelSerializer):
    gym_name = serializers.CharField(source='gym.name', read_only=True)
    gym_avatar = serializers.CharField(source='gym.logo_url', read_only=True)

    class Meta:
        model = ShopGymLink
        fields = ['id', 'gym_id', 'gym_name', 'gym_avatar', 'is_primary']


class ShopSerializer(serializers.ModelSerializer):
    """Public-facing shop serializer (list / card view)."""
    member_count = serializers.SerializerMethodField()
    cover_url = serializers.SerializerMethodField()
    logo_resolved_url = serializers.SerializerMethodField()

    class Meta:
        model = Shop
        fields = [
            'id', 'name', 'handle', 'description', 'category',
            'logo_resolved_url', 'cover_url', 'accent_color',
            'website_url', 'social_links',
            'verification_status', 'is_active',
            'member_count', 'created_at',
        ]

    def get_member_count(self, obj):
        return obj.memberships.count()

    def get_cover_url(self, obj):
        # Cloudinary field returns a URL or None
        if obj.banner:
            try:
                return obj.banner.url
            except Exception:  # noqa: BLE001
                pass
        return obj.banner_url or ''

    def get_logo_resolved_url(self, obj):
        if obj.logo:
            try:
                return obj.logo.url
            except Exception:  # noqa: BLE001
                pass
        return obj.logo_url or ''


class ShopDetailSerializer(ShopSerializer):
    """Full shop detail including members, gym links, and stats."""
    members = ShopMembershipSerializer(source='memberships', many=True, read_only=True)
    gym_links = ShopGymLinkSerializer(many=True, read_only=True)
    my_role = serializers.SerializerMethodField()
    product_count = serializers.SerializerMethodField()
    programme_count = serializers.SerializerMethodField()
    meal_plan_count = serializers.SerializerMethodField()
    event_count = serializers.SerializerMethodField()

    class Meta(ShopSerializer.Meta):
        fields = ShopSerializer.Meta.fields + [
            'members', 'gym_links', 'my_role',
            'contact_email', 'contact_phone', 'refund_policy',
            'verification_applied_at', 'verified_at',
            'product_count', 'programme_count', 'meal_plan_count', 'event_count',
        ]

    def get_my_role(self, obj):
        request = self.context.get('request')
        if not request or not request.user.is_authenticated:
            return None
        membership = obj.memberships.filter(profile=request.user.profile).first()
        return membership.role if membership else None

    def get_product_count(self, obj):
        return obj.products.filter(is_active=True).count()

    def get_programme_count(self, obj):
        return obj.programmes.filter(is_published=True).count()

    def get_meal_plan_count(self, obj):
        return obj.meal_plans.filter(is_published=True).count()

    def get_event_count(self, obj):
        return obj.events.filter(is_published=True).count()


class ShopCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Shop
        fields = [
            'name', 'handle', 'description', 'category',
            'accent_color', 'contact_email', 'contact_phone',
            'website_url', 'social_links', 'refund_policy',
        ]

    def validate_handle(self, value):
        value = value.lower().strip()
        if Shop.objects.filter(handle=value).exists():
            raise serializers.ValidationError('This handle is already taken.')
        return value


# ---------------------------------------------------------------------------
# Verification Application serializers
# ---------------------------------------------------------------------------

class ShopVerificationApplicationSerializer(serializers.ModelSerializer):
    class Meta:
        model = ShopVerificationApplication
        fields = [
            'id', 'shop_id', 'status', 'service_type',
            'legal_name', 'business_registration_number', 'country', 'phone',
            'id_document_url', 'professional_cert_url', 'additional_docs',
            'website_url', 'social_proof_links', 'years_of_experience',
            'specializations', 'bio_statement',
            'agreed_to_creator_policy', 'agreed_at',
            'reviewer_notes', 'rejection_reason',
            'created_at', 'reviewed_at',
        ]
        read_only_fields = ['status', 'reviewer_notes', 'rejection_reason', 'reviewed_at']


# ---------------------------------------------------------------------------
# Push Device serializer
# ---------------------------------------------------------------------------

class PushDeviceSerializer(serializers.ModelSerializer):
    class Meta:
        model = PushDevice
        fields = ['id', 'platform', 'token', 'device_name', 'is_active']


# ---------------------------------------------------------------------------
# Programme Activity Progress serializer
# ---------------------------------------------------------------------------

class ProgrammeActivityProgressSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProgrammeActivityProgress
        fields = ['id', 'activity_key', 'status', 'completed_at', 'notes']


class MealPlanSerializer(serializers.ModelSerializer):
    creator_data = serializers.SerializerMethodField()
    is_purchased = serializers.SerializerMethodField()
    cover = serializers.SerializerMethodField()
    shop_data = serializers.SerializerMethodField()

    class Meta:
        model = MealPlan
        fields = [
            'id', 'creator_id', 'shop_id', 'title', 'description', 'cover',
            'trailer_video_url', 'diet_type', 'duration_weeks', 'meals_per_day',
            'calorie_range', 'macro_targets', 'allergen_flags',
            'content_rating',
            'price_artifacts', 'preview_day', 'purchase_count', 'average_rating',
            'review_count', 'reminder_settings', 'is_published', 'is_draft', 'visibility',
            'creator_data', 'shop_data', 'is_purchased', 'created_at',
        ]

    def get_cover(self, obj):
        if obj.cover_image:
            try:
                return obj.cover_image.url
            except Exception:  # noqa: BLE001
                pass
        return obj.cover_image_url or ''

    def get_creator_data(self, obj):
        return {
            'username': obj.creator.username,
            'display_name': obj.creator.display_name,
            'avatar_url': obj.creator.avatar_url,
            'verification_status': obj.creator.verification_status,
        }

    def get_shop_data(self, obj):
        if not obj.shop:
            return None
        return {'id': str(obj.shop.id), 'name': obj.shop.name, 'handle': obj.shop.handle,
                'verification_status': obj.shop.verification_status}

    def get_is_purchased(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return MealPlanPurchase.objects.filter(meal_plan=obj, buyer=request.user.profile).exists()


class MealPlanFullSerializer(MealPlanSerializer):
    class Meta(MealPlanSerializer.Meta):
        fields = MealPlanSerializer.Meta.fields + ['full_plan', 'shopping_list', 'rest_days']


class MealPlanReviewSerializer(serializers.ModelSerializer):
    buyer_data = serializers.SerializerMethodField()

    class Meta:
        model = MealPlanReview
        fields = ['id', 'rating', 'body', 'buyer_data', 'created_at']

    def get_buyer_data(self, obj):
        return {
            'username': obj.buyer.username,
            'display_name': obj.buyer.display_name,
            'avatar_url': obj.buyer.avatar_url,
        }


class TrainingProgrammeSerializer(serializers.ModelSerializer):
    creator_data = serializers.SerializerMethodField()
    is_purchased = serializers.SerializerMethodField()
    cover = serializers.SerializerMethodField()
    shop_data = serializers.SerializerMethodField()
    average_rating = serializers.SerializerMethodField()
    review_count = serializers.SerializerMethodField()

    class Meta:
        model = TrainingProgramme
        fields = [
            'id', 'creator_id', 'shop_id', 'title', 'description', 'cover',
            'trailer_video_url', 'category', 'difficulty', 'fitness_goals',
            'duration_weeks', 'sessions_per_week', 'equipment_list',
            'content_rating', 'schedule',
            'price_artifacts', 'purchase_count', 'average_rating', 'review_count', 'notification_config',
            'is_published', 'is_draft', 'creator_data', 'shop_data', 'is_purchased', 'created_at',
        ]
        read_only_fields = ['is_purchased']

    def get_average_rating(self, obj):
        reviews = obj.reviews_list.all()
        if not reviews:
            return 0.0
        return round(sum(r.rating for r in reviews) / reviews.count(), 1)

    def get_review_count(self, obj):
        return obj.reviews_list.count()

    def get_cover(self, obj):
        if obj.cover_image:
            try:
                return obj.cover_image.url
            except Exception:  # noqa: BLE001
                pass
        return obj.cover_image_url or ''

    def get_creator_data(self, obj):
        return {
            'username': obj.creator.username,
            'display_name': obj.creator.display_name,
            'avatar_url': obj.creator.avatar_url,
            'verification_status': obj.creator.verification_status,
        }

    def get_shop_data(self, obj):
        if not obj.shop:
            return None
        return {'id': str(obj.shop.id), 'name': obj.shop.name, 'handle': obj.shop.handle,
                'verification_status': obj.shop.verification_status}

    def get_is_purchased(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return TrainingProgrammePurchase.objects.filter(programme=obj, buyer=request.user.profile).exists()


class ProductSerializer(serializers.ModelSerializer):
    recommender_data = serializers.SerializerMethodField()
    shop_data = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = ['id', 'name', 'brand', 'description', 'category', 'content_rating',
                   'image_url', 'affiliate_url', 'price_display',
                   'recommended_by', 'recommender_data', 'shop_data', 'click_count',
                   'stock_quantity', 'stock_tracking_enabled', 'supplement_registration_number',
                   'supplement_registration_expiry', 'supplement_claims_reviewed',
                   'supplement_label_url', 'delivery_modes', 'fulfillment_details',
                   'created_at']

    def to_representation(self, instance):
        data = super().to_representation(instance)
        if not data.get('delivery_modes'):
            data['delivery_modes'] = ['digital']
        return data

    def get_recommender_data(self, obj):
        if obj.recommended_by:
            return {
                'username': obj.recommended_by.username,
                'display_name': obj.recommended_by.display_name,
            }
        return None

    def get_shop_data(self, obj):
        if not obj.shop:
            return None
        return {'id': str(obj.shop.id), 'name': obj.shop.name, 'handle': obj.shop.handle,
                'verification_status': obj.shop.verification_status}


class CreateMealPlanSerializer(serializers.Serializer):
    title = serializers.CharField(max_length=200)
    description = serializers.CharField(required=False, allow_blank=True)
    cover_image_url = serializers.URLField(required=False, allow_blank=True)
    diet_type = serializers.ChoiceField(choices=[c[0] for c in MealPlan.DIET_TYPES])
    duration_weeks = serializers.IntegerField(default=4, validators=[MinValueValidator(1)])
    calorie_range = serializers.CharField(required=False, allow_blank=True, max_length=50)
    price_artifacts = serializers.JSONField(default=dict, validators=[validate_price_artifacts])
    preview_day = serializers.JSONField(default=dict)
    full_plan = serializers.JSONField(default=dict)
    shopping_list = serializers.ListField(child=serializers.CharField(), default=list)
    content_rating = serializers.ChoiceField(choices=CONTENT_RATING_CHOICES, required=False)
    is_published = serializers.BooleanField(default=True)
    shop_id = serializers.UUIDField(required=False, allow_null=True)
    meals_per_day = serializers.IntegerField(default=3, required=False)
    macro_targets = serializers.JSONField(default=dict, required=False)
    reminder_settings = serializers.JSONField(default=dict, required=False)


class UpdateMealPlanSerializer(serializers.Serializer):
    title = serializers.CharField(max_length=200, required=False)
    description = serializers.CharField(required=False, allow_blank=True)
    cover_image_url = serializers.URLField(required=False, allow_blank=True)
    diet_type = serializers.ChoiceField(choices=[c[0] for c in MealPlan.DIET_TYPES], required=False)
    duration_weeks = serializers.IntegerField(validators=[MinValueValidator(1)], required=False)
    meals_per_day = serializers.IntegerField(required=False)
    macro_targets = serializers.JSONField(required=False)
    reminder_settings = serializers.JSONField(required=False)
    calorie_range = serializers.CharField(required=False, allow_blank=True, max_length=50)
    price_artifacts = serializers.JSONField(required=False, validators=[validate_price_artifacts])
    preview_day = serializers.JSONField(required=False)
    full_plan = serializers.JSONField(required=False)
    shopping_list = serializers.ListField(child=serializers.CharField(), required=False)
    content_rating = serializers.ChoiceField(choices=CONTENT_RATING_CHOICES, required=False)
    is_published = serializers.BooleanField(required=False)
    visibility = serializers.ChoiceField(
        choices=['public', 'buddies', 'private'], required=False,
    )


# Unified reminder vocabulary shared by programmes (per-block `timing` +
# global `frequency`) and meal plans (`time_of_day` HH:MM legacy or enum).
TIMING_CHOICES = ['morning', 'midday', 'afternoon', 'evening', 'anytime']
FREQUENCY_CHOICES = ['15m', '30m', '1h']


def validate_timing(value):
    if isinstance(value, dict):
        timing = value.get('timing', value.get('time_of_day', 'anytime'))
        if timing not in TIMING_CHOICES:
            raise serializers.ValidationError(f'Unknown timing: {timing}')
        frequency = value.get('frequency')
        if frequency is not None and frequency not in FREQUENCY_CHOICES:
            raise serializers.ValidationError(f'Unknown frequency: {frequency}')
    return value


class CreateTrainingProgrammeSerializer(serializers.Serializer):
    title = serializers.CharField(max_length=200)
    description = serializers.CharField(required=False, allow_blank=True)
    cover_image_url = serializers.URLField(required=False, allow_blank=True)
    category = serializers.CharField(max_length=50)
    duration_weeks = serializers.IntegerField(default=8, validators=[MinValueValidator(1)])
    sessions_per_week = serializers.IntegerField(required=False)
    schedule = serializers.JSONField(default=dict, required=False)
    notification_config = serializers.JSONField(default=dict, required=False, validators=[validate_timing])
    price_artifacts = serializers.JSONField(default=dict, validators=[validate_price_artifacts])
    content_rating = serializers.ChoiceField(choices=CONTENT_RATING_CHOICES, required=False)
    is_published = serializers.BooleanField(default=True)
    shop_id = serializers.UUIDField(required=False, allow_null=True)


class UpdateTrainingProgrammeSerializer(serializers.Serializer):
    title = serializers.CharField(max_length=200, required=False)
    description = serializers.CharField(required=False, allow_blank=True)
    cover_image_url = serializers.URLField(required=False, allow_blank=True)
    category = serializers.CharField(max_length=50, required=False)
    duration_weeks = serializers.IntegerField(validators=[MinValueValidator(1)], required=False)
    sessions_per_week = serializers.IntegerField(required=False)
    schedule = serializers.JSONField(required=False)
    notification_config = serializers.JSONField(required=False, validators=[validate_timing])
    price_artifacts = serializers.JSONField(required=False, validators=[validate_price_artifacts])
    content_rating = serializers.ChoiceField(choices=CONTENT_RATING_CHOICES, required=False)
    is_published = serializers.BooleanField(required=False)


class CreateProductSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=200)
    brand = serializers.CharField(max_length=100)
    description = serializers.CharField(required=False, allow_blank=True)
    category = serializers.ChoiceField(choices=[c[0] for c in Product.CATEGORIES], default='supplement')
    image_url = serializers.URLField(required=False, allow_blank=True)
    content_rating = serializers.ChoiceField(choices=CONTENT_RATING_CHOICES, required=False)
    affiliate_url = serializers.URLField()
    price_display = serializers.CharField(required=False, allow_blank=True, max_length=50)
    stock_quantity = serializers.IntegerField(min_value=0, required=False, default=0)
    stock_tracking_enabled = serializers.BooleanField(required=False, default=False)
    supplement_registration_number = serializers.CharField(required=False, allow_blank=True, max_length=100)
    supplement_registration_expiry = serializers.DateField(required=False, allow_null=True)
    supplement_claims_reviewed = serializers.BooleanField(required=False, default=False)
    supplement_label_url = serializers.URLField(required=False, allow_blank=True)
    delivery_modes = serializers.ListField(
        child=serializers.ChoiceField(choices=['digital', 'pickup', 'delivery']),
        required=False, default=list,
    )
    fulfillment_details = serializers.DictField(required=False, default=dict)


class UpdateProductSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=200, required=False)
    brand = serializers.CharField(max_length=100, required=False)
    description = serializers.CharField(required=False, allow_blank=True)
    category = serializers.ChoiceField(choices=[c[0] for c in Product.CATEGORIES], required=False)
    image_url = serializers.URLField(required=False, allow_blank=True)
    content_rating = serializers.ChoiceField(choices=CONTENT_RATING_CHOICES, required=False)
    affiliate_url = serializers.URLField(required=False)
    price_display = serializers.CharField(required=False, allow_blank=True, max_length=50)
    is_active = serializers.BooleanField(required=False)
    shop_id = serializers.UUIDField(required=False, allow_null=True)
    stock_quantity = serializers.IntegerField(min_value=0, required=False)
    stock_tracking_enabled = serializers.BooleanField(required=False)
    supplement_registration_number = serializers.CharField(required=False, allow_blank=True, max_length=100)
    supplement_registration_expiry = serializers.DateField(required=False, allow_null=True)
    supplement_claims_reviewed = serializers.BooleanField(required=False)
    supplement_label_url = serializers.URLField(required=False, allow_blank=True)
    delivery_modes = serializers.ListField(
        child=serializers.ChoiceField(choices=['digital', 'pickup', 'delivery']),
        required=False,
    )
    fulfillment_details = serializers.DictField(required=False)


class TrainingProgrammeReviewSerializer(serializers.ModelSerializer):
    buyer_data = serializers.SerializerMethodField()

    class Meta:
        model = TrainingProgrammeReview
        fields = ['id', 'rating', 'body', 'buyer_data', 'created_at']

    def get_buyer_data(self, obj):
        return {
            'username': obj.buyer.username,
            'display_name': obj.buyer.display_name,
            'avatar_url': obj.buyer.avatar_url,
        }


class PersonaliseMealPlanSerializer(serializers.Serializer):
    meal_plan_id = serializers.UUIDField()


class EventMediaSerializer(serializers.ModelSerializer):
    class Meta:
        model = EventMedia
        fields = ['id', 'media_type', 'url', 'thumbnail_url', 'alt_text', 'sort_order']


class MarketplaceEventSerializer(serializers.ModelSerializer):
    creator_data = serializers.SerializerMethodField()
    gym_data = serializers.SerializerMethodField()
    shop_data = serializers.SerializerMethodField()
    is_registered = serializers.SerializerMethodField()
    spots_remaining = serializers.SerializerMethodField()
    cover_image_url = serializers.SerializerMethodField()
    media = EventMediaSerializer(many=True, read_only=True)

    class Meta:
        model = MarketplaceEvent
        fields = [
            'id', 'creator_data', 'gym_data', 'shop_data', 'shop_id', 'gym_id', 'title', 'description',
            'cover_image_url', 'promo_video_url', 'gallery_urls',
            'event_type', 'location', 'location_lat', 'location_lng', 'online_url',
            'start_datetime', 'end_datetime', 'timezone', 'recurrence',
            'capacity', 'ticket_tiers',
            'ticket_price_artifacts', 'is_free',
            'early_bird_enabled', 'early_bird_deadline', 'early_bird_price_artifacts',
            'agenda', 'cancellation_policy',
            'is_published', 'is_cancelled', 'is_draft',
            'attendee_count', 'tags', 'category', 'content_rating',
            'is_registered', 'spots_remaining',
            'media', 'created_at',
        ]

    def get_creator_data(self, obj):
        return {
            'username': obj.creator.username,
            'display_name': obj.creator.display_name,
            'avatar_url': obj.creator.avatar_url,
            'verification_status': obj.creator.verification_status,
        }

    def get_gym_data(self, obj):
        if not obj.gym:
            return None
        return {'id': str(obj.gym.id), 'name': obj.gym.name, 'handle': obj.gym.handle,
                'logo_url': obj.gym.logo_url, 'is_verified': obj.gym.is_verified}

    def get_shop_data(self, obj):
        if not obj.shop:
            return None
        return {'id': str(obj.shop.id), 'name': obj.shop.name, 'handle': obj.shop.handle,
                'verification_status': obj.shop.verification_status}

    def get_is_registered(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return EventTicket.objects.filter(event=obj, holder=request.user.profile, status='active').exists()

    def get_cover_image_url(self, obj):
        if obj.cover_image:
            try:
                return obj.cover_image.url
            except Exception:  # noqa: BLE001
                pass
        return obj.cover_image_url or ''

    def get_spots_remaining(self, obj):
        if obj.capacity == 0:
            return None  # unlimited
        return max(0, obj.capacity - obj.attendee_count)


class EventTicketSerializer(serializers.ModelSerializer):
    event_data = serializers.SerializerMethodField()
    holder_data = serializers.SerializerMethodField()
    qr_data_uri = serializers.SerializerMethodField()

    class Meta:
        model = EventTicket
        fields = [
            'id', 'ticket_code', 'event_data', 'holder_data',
            'tier', 'price_paid_artifacts', 'status',
            'is_checked_in', 'checked_in_at', 'qr_data_uri', 'created_at',
        ]

    def get_event_data(self, obj):
        cover_url = ''
        if obj.event.cover_image:
            try:
                cover_url = obj.event.cover_image.url
            except Exception:  # noqa: BLE001
                pass
        return {
            'id': str(obj.event.id),
            'title': obj.event.title,
            'start_datetime': obj.event.start_datetime.isoformat(),
            'end_datetime': obj.event.end_datetime.isoformat(),
            'location': obj.event.location,
            'cover_image_url': cover_url or obj.event.cover_image_url or '',
        }

    def get_holder_data(self, obj):
        return {
            'username': obj.holder.username,
            'display_name': obj.holder.display_name,
            'avatar_url': obj.holder.avatar_url,
        }

    def get_qr_data_uri(self, obj):
        if not getattr(obj, '_qr_data_uri', None):
            obj._qr_data_uri = self._make_qr(obj)
        return obj._qr_data_uri

    def _make_qr(self, obj):
        try:
            qr = qrcode.QRCode(box_size=10, border=4)
            qr.add_data(str(obj.ticket_code))
            qr.make(fit=True)
            img = qr.make_image(fill='black', back_color='white')
            buf = BytesIO()
            img.save(buf, format='PNG')
            return 'data:image/png;base64,' + base64.b64encode(buf.getvalue()).decode()
        except Exception:  # noqa: BLE001
            return None


class CreateEventSerializer(serializers.Serializer):
    title = serializers.CharField(max_length=200)
    description = serializers.CharField(required=False, allow_blank=True)
    cover_image_url = serializers.URLField(required=False, allow_blank=True)
    event_type = serializers.ChoiceField(choices=['in_person', 'online', 'hybrid'], default='in_person')
    location = serializers.CharField(required=False, allow_blank=True, max_length=300)
    location_lat = serializers.FloatField(required=False, allow_null=True, default=None)
    location_lng = serializers.FloatField(required=False, allow_null=True, default=None)
    online_url = serializers.URLField(required=False, allow_blank=True)
    start_datetime = serializers.DateTimeField()
    end_datetime = serializers.DateTimeField()
    timezone = serializers.CharField(default='UTC', max_length=60)
    capacity = serializers.IntegerField(default=0, min_value=0)
    ticket_price_artifacts = serializers.JSONField(default=dict)
    is_free = serializers.BooleanField(default=True)
    is_published = serializers.BooleanField(default=True)
    tags = serializers.ListField(child=serializers.CharField(), default=list)
    category = serializers.CharField(required=False, allow_blank=True, max_length=50)
    content_rating = serializers.ChoiceField(choices=CONTENT_RATING_CHOICES, required=False)
    gym_id = serializers.UUIDField(required=False, allow_null=True)
    shop_id = serializers.UUIDField(required=False, allow_null=True)
    agenda = serializers.JSONField(required=False, default=list)
    recurrence = serializers.ChoiceField(choices=['none', 'daily', 'weekly', 'monthly'], required=False, default='none')
    ticket_tiers = serializers.JSONField(required=False, default=list)
    early_bird_enabled = serializers.BooleanField(required=False, default=False)
    early_bird_deadline = serializers.DateTimeField(required=False, allow_null=True)
    early_bird_price_artifacts = serializers.JSONField(required=False, default=dict)
    cancellation_policy = serializers.CharField(required=False, allow_blank=True, max_length=2000, default='')
    is_draft = serializers.BooleanField(required=False, default=False)
    visibility = serializers.ChoiceField(
        choices=['public', 'buddies', 'private'], required=False, default='public',
    )
    gallery_urls = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    promo_video_url = serializers.URLField(required=False, allow_blank=True)


class ReviewInputSerializer(serializers.Serializer):
    rating = serializers.IntegerField(default=5, min_value=1, max_value=5)
    body = serializers.CharField(max_length=500, required=False, allow_blank=True, default='')


class DiscountCodeSerializer(serializers.ModelSerializer):
    qr_code = serializers.SerializerMethodField()
    usage_count = serializers.SerializerMethodField()
    is_expired = serializers.SerializerMethodField()

    class Meta:
        model = DiscountCode
        fields = '__all__'
        read_only_fields = ['id', 'creator', 'times_used', 'is_retired', 'retired_at', 'retired_reason', 'share_count', 'qr_code', 'usage_count', 'is_expired', 'created_at', 'updated_at']

    def get_qr_code(self, obj):
        if obj.code_type == 'qr' and not obj.qr_code:
            self._generate_qr(obj)
        return obj.qr_code if obj.code_type == 'qr' else None

    def get_usage_count(self, obj):
        return obj.usages.count()

    def get_is_expired(self, obj):
        if not obj.is_active:
            return True
        if obj.valid_until and obj.valid_until < timezone.now():
            return True
        if obj.usage_limit > 0 and obj.times_used >= obj.usage_limit:
            return True
        return False

    def _generate_qr(self, obj):
        try:
            qr = qrcode.QRCode(box_size=10, border=4)
            qr.add_data(obj.code)
            qr.make(fit=True)
            img = qr.make_image(fill='black', back_color='white')
            buf = BytesIO()
            img.save(buf, format='PNG')
            obj.qr_code = base64.b64encode(buf.getvalue()).decode()
            obj.save(update_fields=['qr_code'])
        except Exception:  # noqa: BLE001
            pass


class DiscountCodeWriteSerializer(serializers.ModelSerializer):
    class Meta:
        model = DiscountCode
        exclude = ['id', 'creator', 'times_used', 'is_retired', 'retired_at', 'retired_reason', 'share_count']

    def validate_discount_pct(self, value):
        if value < 0 or value > 100:
            raise serializers.ValidationError('discount_pct must be between 0 and 100.')
        return value

    def validate(self, data):
        if data.get('discount_type') == 'fixed_artifacts' and not data.get('discount_artifacts'):
            raise serializers.ValidationError('discount_artifacts is required for fixed_artifacts discount type.')
        if data.get('valid_from') and data.get('valid_until') and data['valid_from'] >= data['valid_until']:
            raise serializers.ValidationError('valid_from must be before valid_until.')
        return data


class DiscountUsageSerializer(serializers.ModelSerializer):
    code = serializers.CharField(source='discount.code', read_only=True)
    user_display = serializers.CharField(source='user.display_name', read_only=True)

    class Meta:
        model = DiscountUsage
        fields = '__all__'
        read_only_fields = ['id', 'discount', 'user', 'cart', 'created_at', 'updated_at']


def resolve_item_price(item):
    """Resolve the artifact price for a CartItem.

    This is the single source of truth for "what does this cart item cost".
    Resolves CartItem.meta['tier'] against the event's ticket_tiers so every
    caller (cart quote, line-item quote, checkout charge, discount minimums)
    agrees on the same amount. Tier names are matched case-insensitively; a
    tier with a missing/empty price_artifacts falls back to the event's base
    ticket_price_artifacts. Free events resolve to {} (nothing to charge),
    and products are free too (Product has no price_artifacts field).
    """
    if item.item_type == 'meal_plan' and item.meal_plan:
        return item.meal_plan.price_artifacts or {}
    if item.item_type == 'programme' and item.programme:
        return item.programme.price_artifacts or {}
    if item.item_type == 'event_ticket' and item.event:
        if item.event.is_free:
            return {}
        tier_name = (getattr(item, 'meta', None) or {}).get('tier')
        if tier_name:
            match = next(
                (t for t in (item.event.ticket_tiers or [])
                 if str(t.get('name', '')).lower() == str(tier_name).lower()),
                None,
            )
            if match and match.get('price_artifacts'):
                return match['price_artifacts']
        return item.event.ticket_price_artifacts or {}
    return {}


class CartItemSerializer(serializers.ModelSerializer):
    meal_plan_detail = MealPlanSerializer(source='meal_plan', read_only=True)
    programme_detail = TrainingProgrammeSerializer(source='programme', read_only=True)
    product_detail = ProductSerializer(source='product', read_only=True)
    event_detail = MarketplaceEventSerializer(source='event', read_only=True)
    item_total_artifacts = serializers.SerializerMethodField()
    item_total_usd = serializers.SerializerMethodField()

    class Meta:
        model = CartItem
        fields = ['id', 'item_type', 'quantity', 'meta',
                  'meal_plan', 'meal_plan_detail',
                  'programme', 'programme_detail',
                  'product', 'product_detail',
                  'event', 'event_detail',
                  'item_total_artifacts', 'item_total_usd']

    def get_item_total_artifacts(self, obj):
        price = self._get_price(obj)
        if not price:
            return {}
        return {k: v * obj.quantity for k, v in price.items()}

    def get_item_total_usd(self, obj):
        total = self.get_item_total_artifacts(obj)
        if not total:
            return 0.0
        return round(sum(ARTIFACT_VALUES.get(k, 0) * v for k, v in total.items()), 2)

    def _get_price(self, obj):
        return resolve_item_price(obj)


class CartSerializer(serializers.ModelSerializer):
    items = CartItemSerializer(many=True, read_only=True)
    discount_code = DiscountCodeSerializer(read_only=True)
    total_artifacts = serializers.SerializerMethodField()
    subtotals = serializers.SerializerMethodField()
    total_usd = serializers.SerializerMethodField()
    total_local_currency = serializers.SerializerMethodField()
    base_currency = serializers.SerializerMethodField()
    local_currency = serializers.SerializerMethodField()
    conversion_rate = serializers.SerializerMethodField()

    class Meta:
        model = Cart
        fields = ['id', 'discount_code', 'items',
                  'total_artifacts', 'subtotals',
                  'total_usd', 'total_local_currency',
                  'base_currency', 'local_currency', 'conversion_rate']

    def get_total_artifacts(self, obj):
        total = {}
        for item in obj.items.all():
            price = self._get_item_price(item)
            for k, v in price.items():
                total[k] = total.get(k, 0) + (v * item.quantity)
        discount = obj.discount_code
        if discount and discount.is_active:
            if discount.discount_type == 'percentage' and discount.discount_pct > 0:
                factor = discount.discount_pct / 100.0
                for k in total:
                    total[k] = max(1, int(total[k] * (1 - factor)))
            elif discount.discount_type == 'fixed_artifacts' and discount.discount_artifacts:
                for k, v in discount.discount_artifacts.items():
                    if k in total:
                        total[k] = max(1, total[k] - v)
        return total

    def get_subtotals(self, obj):
        return [
            CartItemSerializer(item, context=self.context).data
            for item in obj.items.all()
        ]

    def get_total_usd(self, obj):
        total = self.get_total_artifacts(obj)
        return round(sum(ARTIFACT_VALUES.get(k, 0) * v for k, v in total.items()), 2)

    def get_total_local_currency(self, obj):
        ctx = self.context.get('rates', {})
        rate = ctx.get('conversion_rate', 129.5)
        usd = self.get_total_usd(obj)
        return round(usd * rate, 2)

    def get_base_currency(self, obj):
        return self.context.get('rates', {}).get('base_currency', 'USD')

    def get_local_currency(self, obj):
        return self.context.get('rates', {}).get('local_currency', 'KES')

    def get_conversion_rate(self, obj):
        return self.context.get('rates', {}).get('conversion_rate', 129.5)

    def _get_item_price(self, item):
        return resolve_item_price(item)


# ---------------------------------------------------------------------------
# Order serializers
# ---------------------------------------------------------------------------

class OrderFulfillmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderFulfillment
        fields = ['carrier', 'tracking_number', 'tracking_url', 'pickup_location',
                  'notes', 'timeline', 'shipped_at', 'out_for_delivery_at',
                  'ready_for_pickup_at', 'delivered_at']


class OrderItemSerializer(serializers.ModelSerializer):
    price_artifacts = serializers.SerializerMethodField()
    paid_artifacts = serializers.SerializerMethodField()
    creator_name = serializers.CharField(source='creator.display_name', default=None, read_only=True)

    class Meta:
        model = OrderItem
        fields = ['item_type', 'title', 'quantity', 'price_artifacts',
                  'paid_artifacts', 'seller_split_artifacts', 'fulfillment_status',
                  'creator_name', 'created_at']

    def get_price_artifacts(self, obj):
        return obj.price_artifacts or {}

    def get_paid_artifacts(self, obj):
        return obj.paid_artifacts or {}


class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    fulfillment = serializers.SerializerMethodField()
    total_usd = serializers.SerializerMethodField()
    status_label = serializers.SerializerMethodField()
    is_seller = serializers.SerializerMethodField()

    class Meta:
        model = Order
        fields = ['id', 'order_number', 'status', 'status_label', 'fulfillment_type',
                  'delivery_address', 'pickup_details', 'items_total_artifacts',
                  'discount_artifacts', 'total_artifacts', 'total_usd', 'spent_usd',
                  'discount_code', 'status_history', 'items', 'fulfillment',
                  'pickup_station', 'delivery_personnel',
                  'payment_method', 'payment_status', 'payment_reference', 'payment_provider',
                  'is_seller', 'paid_at', 'created_at']

    def get_fulfillment(self, obj):
        try:
            return OrderFulfillmentSerializer(obj.fulfillment_record).data
        except OrderFulfillment.DoesNotExist:
            return None

    def get_total_usd(self, obj):
        return round(sum(ARTIFACT_VALUES.get(k, 0) * v for k, v in (obj.total_artifacts or {}).items()), 2)

    def get_status_label(self, obj):
        return dict(Order.STATUS_CHOICES).get(obj.status, obj.status)

    def get_is_seller(self, obj):
        viewer = self.context.get('viewer')
        if viewer is None:
            return False
        return obj.items.filter(creator=viewer).exists()


class SellerOrderSerializer(OrderSerializer):
    """An order as seen by a *seller* of one of its line items.

    Data minimisation, not cosmetics. ``SellerOrdersView`` used to hand every
    seller the whole order: the other sellers' line items (their titles, prices
    and per-unit paid amounts) and the order-wide money totals, which are the
    sum of every seller's revenue. A seller only ever needs their own lines, so
    both are narrowed here.

    The buyer's ``delivery_address`` is deliberately *kept*: a seller cannot
    fulfil a delivery or pickup order without knowing where it goes, and the
    courier they assign reads the same record. That is the one field where the
    seller's legitimate need is the buyer's private data.
    """

    items = serializers.SerializerMethodField()
    items_total_artifacts = serializers.SerializerMethodField()
    discount_artifacts = serializers.SerializerMethodField()
    total_artifacts = serializers.SerializerMethodField()
    spent_usd = serializers.SerializerMethodField()
    items_count = serializers.SerializerMethodField()

    def _own_items(self, obj):
        """The caller's line items, and only theirs.

        ``SellerOrdersView`` prefetches `items` down to the caller's rows, so
        there the prefetch cache already holds nothing else; the detail
        endpoints do not prefetch, so narrow here as well — otherwise the
        detail view would be a way around the list view's filtering.
        """
        viewer = self.context.get('viewer')
        items = obj.items.all()
        if viewer is None:
            return list(items)
        return [item for item in items if item.creator_id == viewer.pk]

    def get_items(self, obj):
        return OrderItemSerializer(self._own_items(obj), many=True, context=self.context).data

    def get_items_count(self, obj):
        return len(self._own_items(obj))

    class Meta(OrderSerializer.Meta):
        fields = OrderSerializer.Meta.fields + ['items_count']

    @staticmethod
    def _sum_artifacts(items, field):
        totals = {}
        for item in items:
            for artifact_type, qty in (getattr(item, field, None) or {}).items():
                totals[artifact_type] = totals.get(artifact_type, 0) + qty
        return totals

    def get_items_total_artifacts(self, obj):
        return self._sum_artifacts(self._own_items(obj), 'price_artifacts')

    def get_discount_artifacts(self, obj):
        """Per-item discount allocation is not modelled, so a seller sees the
        gap between their gross lines and their net lines instead of the
        order-wide savings figure (which describes other sellers' orders)."""
        items = self._own_items(obj)
        gross = self._sum_artifacts(items, 'price_artifacts')
        net = self._sum_artifacts(items, 'paid_artifacts')
        return {k: gross[k] - net.get(k, 0) for k in gross if gross[k] != net.get(k, 0)}

    def get_total_artifacts(self, obj):
        return self._sum_artifacts(self._own_items(obj), 'paid_artifacts')

    def get_spent_usd(self, obj):
        return round(sum(
            ARTIFACT_VALUES.get(artifact_type, 0) * qty
            for artifact_type, qty in self.get_total_artifacts(obj).items()
        ), 2)


class OrderCaseSerializer(serializers.ModelSerializer):
    requester_name = serializers.CharField(source='requester.display_name', read_only=True)

    class Meta:
        model = OrderCase
        fields = ['id', 'order', 'requester', 'requester_name', 'case_type', 'status',
                  'reason', 'evidence', 'resolution', 'resolved_at', 'created_at']
        read_only_fields = ['id', 'order', 'requester', 'requester_name', 'status',
                            'resolution', 'resolved_at', 'created_at']


class CreatorPayoutSetupSerializer(serializers.ModelSerializer):
    accept_terms = serializers.BooleanField(write_only=True, required=False)

    class Meta:
        model = CreatorPayoutSetup
        fields = ['provider', 'account_reference', 'is_verified', 'terms_accepted_at',
                  'setup_status', 'accept_terms', 'created_at', 'updated_at']
        read_only_fields = ['is_verified', 'terms_accepted_at', 'setup_status',
                            'created_at', 'updated_at']


# ---------------------------------------------------------------------------
# Fulfillment logistics serializers
# ---------------------------------------------------------------------------

def _haversine_km(lat1, lng1, lat2, lng2):
    """Great-circle distance in km between two decimal-degree lat/lng pairs."""
    lat1, lng1, lat2, lng2 = (float(v) for v in (lat1, lng1, lat2, lng2))
    dlat = radians(lat2 - lat1)
    dlng = radians(lng2 - lng1)
    a = sin(dlat / 2) ** 2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlng / 2) ** 2
    return 2 * 6371.0088 * asin(sqrt(a))


class PickupStationSerializer(serializers.ModelSerializer):
    """Public read + shop/gym-owner create/update for a collection point.

    ``distance_km`` is computed *only* against an ``origin_latitude`` /
    ``origin_longitude`` the caller sends in this request. The server never
    infers a buyer's location (no IP, header or timezone sniffing), so without
    an explicit origin the key is *omitted from the payload entirely* rather
    than sent as ``null`` — clients switch on its presence, and a permanently
    ``null`` field would make "no distance was measured" indistinguishable from
    "the distance is zero".
    """

    owner_name = serializers.SerializerMethodField()
    distance_km = serializers.SerializerMethodField()
    origin_latitude = serializers.DecimalField(max_digits=9, decimal_places=6,
                                               required=False, write_only=True)
    origin_longitude = serializers.DecimalField(max_digits=9, decimal_places=6,
                                                required=False, write_only=True)

    class Meta:
        model = PickupStation
        fields = ['id', 'name', 'description', 'address', 'city', 'country',
                  'latitude', 'longitude', 'opening_hours', 'phone', 'instructions',
                  'is_active', 'is_primary', 'owner_type', 'shop', 'gym',
                  'owner_name', 'distance_km', 'origin_latitude', 'origin_longitude',
                  'created_at', 'updated_at']
        read_only_fields = ['id', 'owner_type', 'created_at', 'updated_at']

    def get_owner_name(self, obj):
        if obj.shop_id:
            return obj.shop.name
        return obj.gym.name if obj.gym_id else None

    # origin_* are write-only and are not model fields, so they must be stripped
    # before validated_data reaches Model(**...).
    @staticmethod
    def _strip_origin(data):
        return {k: v for k, v in data.items()
                if k not in ('origin_latitude', 'origin_longitude')}

    def create(self, validated_data):
        return super().create(self._strip_origin(validated_data))

    def update(self, instance, validated_data):
        return super().update(instance, self._strip_origin(validated_data))

    def to_representation(self, instance):
        data = super().to_representation(instance)
        # Only report a distance when one was actually measured: no origin was
        # sent, or this station has no coordinates of its own.
        if data.get('distance_km') is None:
            data.pop('distance_km', None)
        return data

    def get_distance_km(self, obj):
        initial = getattr(self, 'initial_data', None)
        if isinstance(initial, dict):
            origin_lat = initial.get('origin_latitude')
            origin_lng = initial.get('origin_longitude')
        else:
            # List/detail views pass the origin through the serializer context
            # instead: there is no per-request `initial_data` for a queryset.
            context = getattr(self, 'context', None) or {}
            origin_lat = context.get('origin_latitude')
            origin_lng = context.get('origin_longitude')
        if origin_lat is None or origin_lng is None:
            return None
        if obj.latitude is None or obj.longitude is None:
            return None
        return round(_haversine_km(origin_lat, origin_lng, obj.latitude, obj.longitude), 3)

    def _resolved_owner(self, data):
        shop = data.get('shop', getattr(self.instance, 'shop', None))
        gym = data.get('gym', getattr(self.instance, 'gym', None))
        return shop, gym

    def validate(self, data):
        shop, gym = self._resolved_owner(data)
        if bool(shop) == bool(gym):
            raise serializers.ValidationError(
                'A station must belong to exactly one owner: provide a shop or a gym, not both.'
            )
        if data.get('is_primary'):
            clashes = PickupStation.objects.filter(is_primary=True)
            if self.instance is not None:
                clashes = clashes.exclude(pk=self.instance.pk)
            clashes = clashes.filter(shop=shop) if shop else clashes.filter(gym=gym)
            if clashes.exists():
                owner = 'shop' if shop else 'gym'
                raise serializers.ValidationError(
                    {'is_primary': f'This {owner} already has a primary pickup station.'}
                )
        return data


class StationApplicationSerializer(serializers.ModelSerializer):
    """Applicant-facing view of a shop/gym station application.

    Deliberately mirrors ShopVerificationApplicationSerializer: the review
    fields are staff-owned, so a buyer cannot POST their way to 'approved'.
    """

    class Meta:
        model = StationApplication
        fields = ['id', 'shop', 'gym', 'submitted_by', 'status',
                  'business_registration_number', 'contact_phone',
                  'address', 'city', 'country', 'latitude', 'longitude',
                  'opening_hours', 'documents',
                  'agreed_to_policy', 'agreed_at',
                  'reviewer_notes', 'rejection_reason', 'reviewed_at', 'created_at']
        read_only_fields = ['id', 'status', 'reviewer_notes', 'rejection_reason',
                            'reviewed_at', 'created_at']

    def validate(self, data):
        shop = data.get('shop', getattr(self.instance, 'shop', None))
        gym = data.get('gym', getattr(self.instance, 'gym', None))
        if bool(shop) == bool(gym):
            raise serializers.ValidationError(
                'An application must name exactly one applicant: a shop or a gym, not both.'
            )
        return data

    def validate_documents(self, value):
        if not isinstance(value, list):
            raise serializers.ValidationError('documents must be a list of {url, label} objects.')
        for doc in value:
            if not isinstance(doc, dict) or not doc.get('url'):
                raise serializers.ValidationError('Each document needs a url.')
        return value


class ApplicationReviewSerializer(serializers.Serializer):
    """Staff-only transition payload shared by every application model.

    Split out from the applicant serializers so "who may change the status" is
    enforced by the view choosing this class, not by a field the client can
    simply not bother sending.
    """

    status = serializers.ChoiceField(choices=APPLICATION_STATUS_CHOICES)
    reviewer_notes = serializers.CharField(required=False, allow_blank=True, default='')
    rejection_reason = serializers.CharField(required=False, allow_blank=True, default='')

    def validate(self, data):
        if data.get('status') == 'rejected' and not (data.get('rejection_reason') or '').strip():
            raise serializers.ValidationError(
                {'rejection_reason': 'A rejection reason is required when rejecting an application.'}
            )
        return data


class DeliveryPersonnelSerializer(serializers.ModelSerializer):
    """Read-mostly courier view.

    ``profile`` and ``rating`` are read-only: a courier does not mint their own
    record (an approved application does) and does not write their own rating.
    """

    username = serializers.CharField(source='profile.username', read_only=True)
    display_name = serializers.CharField(source='profile.display_name', read_only=True)
    avatar_url = serializers.URLField(source='profile.avatar_url', read_only=True)
    vehicle_label = serializers.CharField(source='get_vehicle_type_display', read_only=True)

    class Meta:
        model = DeliveryPersonnel
        fields = ['id', 'profile', 'username', 'display_name', 'avatar_url',
                  'vehicle_type', 'vehicle_label', 'service_zones', 'is_active',
                  'rating', 'bio', 'created_at', 'updated_at']
        read_only_fields = ['id', 'profile', 'rating', 'created_at', 'updated_at']

    def validate_service_zones(self, value):
        if not isinstance(value, list) or any(not isinstance(zone, str) for zone in value):
            raise serializers.ValidationError('service_zones must be a list of area names.')
        return value


class DeliveryPersonnelApplicationSerializer(serializers.ModelSerializer):
    """Applicant-facing view of a courier application; review fields read-only."""

    class Meta:
        model = DeliveryPersonnelApplication
        fields = ['id', 'profile', 'vehicle_type', 'service_zones',
                  'id_document_url', 'licence_document_url', 'phone', 'bio',
                  'status', 'reviewer_notes', 'rejection_reason', 'reviewed_at',
                  'created_at']
        read_only_fields = ['id', 'status', 'reviewer_notes', 'rejection_reason',
                            'reviewed_at', 'created_at']

    def validate_service_zones(self, value):
        if not isinstance(value, list) or any(not isinstance(zone, str) for zone in value):
            raise serializers.ValidationError('service_zones must be a list of area names.')
        return value


class PaymentIntentSerializer(serializers.ModelSerializer):
    """Read-mostly view of a real-money payment attempt.

    ``status``, ``provider_reference`` and ``raw_response`` are read-only
    because only the provider callback may write them — a checkout request must
    not be able to declare its own payment successful. Creating an intent
    always lands on ``status='initiated'``.
    """

    order_number = serializers.CharField(source='order.order_number', read_only=True)
    method_label = serializers.CharField(source='get_method_display', read_only=True)

    class Meta:
        model = PaymentIntent
        fields = ['id', 'order', 'order_number', 'provider', 'method', 'method_label',
                  'amount', 'currency', 'provider_reference', 'status',
                  'raw_response', 'created_by', 'created_at', 'updated_at']
        read_only_fields = ['id', 'provider', 'provider_reference', 'status',
                            'raw_response', 'created_by', 'created_at', 'updated_at']

    def validate_amount(self, value):
        if value <= 0:
            raise serializers.ValidationError('amount must be greater than zero.')
        return value


class PaymentIntentCreateSerializer(serializers.Serializer):
    """Body of POST /orders/payment-intents/.

    Deliberately *not* a ModelSerializer on PaymentIntent: an intent is created
    from the order, never from client-supplied money. The amount, currency,
    provider, status and every provider-derived field are server-owned, so
    there is nothing here a client could set to mark itself paid.
    """

    order_id = serializers.UUIDField()
    method = serializers.ChoiceField(choices=['mpesa', 'card'])
    phone = serializers.CharField(required=False, allow_blank=True, max_length=30)
    # Card details are accepted only for the direct-charge path and are never
    # persisted: they go straight into the provider call and are dropped. The
    # hosted-checkout path (no card fields) is the default because it keeps PAN
    # out of this service entirely.
    card_number = serializers.CharField(required=False, allow_blank=True, max_length=30)
    cvv = serializers.CharField(required=False, allow_blank=True, max_length=8)
    expiry_month = serializers.CharField(required=False, allow_blank=True, max_length=4)
    expiry_year = serializers.CharField(required=False, allow_blank=True, max_length=4)

    def validate(self, data):
        if data['method'] == 'mpesa' and not (data.get('phone') or '').strip():
            raise serializers.ValidationError(
                {'phone': 'An M-Pesa phone number is required to start an STK push.'}
            )
        card_fields = ('card_number', 'cvv', 'expiry_month', 'expiry_year')
        provided = [f for f in card_fields if (data.get(f) or '').strip()]
        if provided and len(provided) != len(card_fields):
            raise serializers.ValidationError(
                'Provide all four card fields (card_number, cvv, expiry_month, expiry_year) '
                'or none of them.'
            )
        return data
