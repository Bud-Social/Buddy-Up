import qrcode
import base64
from io import BytesIO
from uuid import uuid4
from django.utils import timezone
from rest_framework import serializers
from django.core.validators import MinValueValidator, MaxValueValidator
from rest_framework.exceptions import ValidationError
from .models import (
    Shop, ShopMembership, ShopGymLink, ShopVerificationApplication, PushDevice,
    MealPlan, MealPlanPurchase, MealPlanReview,
    TrainingProgramme, TrainingProgrammePurchase, TrainingProgrammeReview,
    ProgrammeActivityProgress,
    Product, MarketplaceEvent, EventMedia, EventTicket, Cart, CartItem, DiscountCode, DiscountUsage
)

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
            except Exception:
                pass
        return obj.banner_url or ''

    def get_logo_resolved_url(self, obj):
        if obj.logo:
            try:
                return obj.logo.url
            except Exception:
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
            'price_artifacts', 'preview_day', 'purchase_count', 'average_rating',
            'review_count', 'reminder_settings', 'is_published', 'is_draft',
            'creator_data', 'shop_data', 'is_purchased', 'created_at',
        ]

    def get_cover(self, obj):
        if obj.cover_image:
            try:
                return obj.cover_image.url
            except Exception:
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

    class Meta:
        model = TrainingProgramme
        fields = [
            'id', 'creator_id', 'shop_id', 'title', 'description', 'cover',
            'trailer_video_url', 'category', 'difficulty', 'fitness_goals',
            'duration_weeks', 'sessions_per_week', 'equipment_list',
            'price_artifacts', 'purchase_count', 'notification_config',
            'is_published', 'is_draft', 'creator_data', 'shop_data', 'is_purchased', 'created_at',
        ]
        read_only_fields = ['is_purchased']

    def get_cover(self, obj):
        if obj.cover_image:
            try:
                return obj.cover_image.url
            except Exception:
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
        fields = ['id', 'name', 'brand', 'description', 'category',
                   'image_url', 'affiliate_url', 'price_display',
                   'recommended_by', 'recommender_data', 'shop_data', 'click_count', 'created_at']

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
    calorie_range = serializers.CharField(required=False, allow_blank=True, max_length=50)
    price_artifacts = serializers.JSONField(required=False, validators=[validate_price_artifacts])
    preview_day = serializers.JSONField(required=False)
    full_plan = serializers.JSONField(required=False)
    shopping_list = serializers.ListField(child=serializers.CharField(), required=False)
    is_published = serializers.BooleanField(required=False)


class CreateTrainingProgrammeSerializer(serializers.Serializer):
    title = serializers.CharField(max_length=200)
    description = serializers.CharField(required=False, allow_blank=True)
    cover_image_url = serializers.URLField(required=False, allow_blank=True)
    category = serializers.CharField(max_length=50)
    duration_weeks = serializers.IntegerField(default=8, validators=[MinValueValidator(1)])
    price_artifacts = serializers.JSONField(default=dict, validators=[validate_price_artifacts])
    is_published = serializers.BooleanField(default=True)


class UpdateTrainingProgrammeSerializer(serializers.Serializer):
    title = serializers.CharField(max_length=200, required=False)
    description = serializers.CharField(required=False, allow_blank=True)
    cover_image_url = serializers.URLField(required=False, allow_blank=True)
    category = serializers.CharField(max_length=50, required=False)
    duration_weeks = serializers.IntegerField(validators=[MinValueValidator(1)], required=False)
    price_artifacts = serializers.JSONField(required=False, validators=[validate_price_artifacts])
    is_published = serializers.BooleanField(required=False)


class CreateProductSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=200)
    brand = serializers.CharField(max_length=100)
    description = serializers.CharField(required=False, allow_blank=True)
    category = serializers.ChoiceField(choices=[c[0] for c in Product.CATEGORIES], default='supplement')
    image_url = serializers.URLField(required=False, allow_blank=True)
    affiliate_url = serializers.URLField()
    price_display = serializers.CharField(required=False, allow_blank=True, max_length=50)


class UpdateProductSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=200, required=False)
    brand = serializers.CharField(max_length=100, required=False)
    description = serializers.CharField(required=False, allow_blank=True)
    category = serializers.ChoiceField(choices=[c[0] for c in Product.CATEGORIES], required=False)
    image_url = serializers.URLField(required=False, allow_blank=True)
    affiliate_url = serializers.URLField(required=False)
    price_display = serializers.CharField(required=False, allow_blank=True, max_length=50)
    is_active = serializers.BooleanField(required=False)
    shop_id = serializers.UUIDField(required=False, allow_null=True)


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
            'id', 'creator_data', 'gym_data', 'shop_data', 'shop_id', 'title', 'description',
            'cover_image_url', 'promo_video_url', 'gallery_urls',
            'event_type', 'location', 'online_url',
            'start_datetime', 'end_datetime', 'timezone', 'recurrence',
            'capacity', 'ticket_tiers',
            'ticket_price_artifacts', 'is_free',
            'early_bird_enabled', 'early_bird_deadline', 'early_bird_price_artifacts',
            'agenda', 'cancellation_policy',
            'is_published', 'is_cancelled', 'is_draft',
            'attendee_count', 'tags', 'category', 'is_registered', 'spots_remaining',
            'media', 'created_at',
        ]

    def get_creator_data(self, obj):
        return {
            'username': obj.creator.username,
            'display_name': obj.creator.display_name,
            'avatar_url': obj.creator.avatar_url,
        }

    def get_gym_data(self, obj):
        if not obj.gym:
            return None
        return {'id': str(obj.gym.id), 'name': obj.gym.name, 'handle': obj.gym.handle, 'logo_url': obj.gym.logo_url}

    def get_shop_data(self, obj):
        if not obj.shop:
            return None
        return {'id': str(obj.shop.id), 'name': obj.shop.name, 'handle': obj.shop.handle}

    def get_is_registered(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return EventTicket.objects.filter(event=obj, holder=request.user.profile, status='active').exists()

    def get_cover_image_url(self, obj):
        if obj.cover_image:
            try:
                return obj.cover_image.url
            except Exception:
                pass
        return obj.cover_image_url or ''

    def get_spots_remaining(self, obj):
        if obj.capacity == 0:
            return None  # unlimited
        return max(0, obj.capacity - obj.attendee_count)


class EventTicketSerializer(serializers.ModelSerializer):
    event_data = serializers.SerializerMethodField()
    holder_data = serializers.SerializerMethodField()

    class Meta:
        model = EventTicket
        fields = [
            'id', 'ticket_code', 'event_data', 'holder_data',
            'tier', 'price_paid_artifacts', 'status',
            'is_checked_in', 'checked_in_at', 'created_at',
        ]

    def get_event_data(self, obj):
        cover_url = ''
        if obj.event.cover_image:
            try:
                cover_url = obj.event.cover_image.url
            except Exception:
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


class CreateEventSerializer(serializers.Serializer):
    title = serializers.CharField(max_length=200)
    description = serializers.CharField(required=False, allow_blank=True)
    cover_image_url = serializers.URLField(required=False, allow_blank=True)
    event_type = serializers.ChoiceField(choices=['in_person', 'online', 'hybrid'], default='in_person')
    location = serializers.CharField(required=False, allow_blank=True, max_length=300)
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
        except Exception:
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


class CartItemSerializer(serializers.ModelSerializer):
    meal_plan_detail = MealPlanSerializer(source='meal_plan', read_only=True)
    programme_detail = TrainingProgrammeSerializer(source='programme', read_only=True)
    product_detail = ProductSerializer(source='product', read_only=True)
    event_detail = MarketplaceEventSerializer(source='event', read_only=True)
    item_total_artifacts = serializers.SerializerMethodField()
    item_total_usd = serializers.SerializerMethodField()

    class Meta:
        model = CartItem
        fields = ['id', 'item_type', 'quantity',
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
        if obj.item_type == 'meal_plan' and obj.meal_plan:
            return obj.meal_plan.price_artifacts
        if obj.item_type == 'programme' and obj.programme:
            return obj.programme.price_artifacts
        if obj.item_type == 'event_ticket' and obj.event:
            return obj.event.ticket_price_artifacts
        if obj.item_type == 'product' and obj.product:
            return {}
        return {}


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
        if item.item_type == 'meal_plan' and item.meal_plan:
            return item.meal_plan.price_artifacts
        if item.item_type == 'programme' and item.programme:
            return item.programme.price_artifacts
        if item.item_type == 'event_ticket' and item.event:
            return item.event.ticket_price_artifacts
        if item.item_type == 'product' and item.product:
            return {}
        return {}

