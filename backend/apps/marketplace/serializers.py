from rest_framework import serializers
from django.core.validators import MinValueValidator, MaxValueValidator
from rest_framework.exceptions import ValidationError
from .models import (
    MealPlan, MealPlanPurchase, MealPlanReview,
    TrainingProgramme, TrainingProgrammePurchase, TrainingProgrammeReview,
    Product, MarketplaceEvent, EventTicket,
)

ARTIFACT_TYPES = ['dumbbell', 'barbell', 'burpee', 'squat', 'sprint', 'pr', 'champion']


def validate_price_artifacts(value):
    if not isinstance(value, dict):
        raise serializers.ValidationError('price_artifacts must be an object.')
    for k, v in value.items():
        if k not in ARTIFACT_TYPES:
            raise serializers.ValidationError(f'Unknown artifact type: {k}')
        if not isinstance(v, int) or v < 1:
            raise serializers.ValidationError(f'Quantity for {k} must be a positive integer.')
    return value


class MealPlanSerializer(serializers.ModelSerializer):
    creator_data = serializers.SerializerMethodField()
    is_purchased = serializers.SerializerMethodField()

    class Meta:
        model = MealPlan
        fields = ['id', 'creator_id', 'title', 'description', 'diet_type',
                   'duration_weeks', 'calorie_range', 'price_artifacts',
                   'preview_day', 'purchase_count', 'average_rating',
                   'review_count', 'creator_data', 'is_purchased', 'created_at']

    def get_creator_data(self, obj):
        return {
            'username': obj.creator.username,
            'display_name': obj.creator.display_name,
            'avatar_url': obj.creator.avatar_url,
            'verification_status': obj.creator.verification_status,
        }

    def get_is_purchased(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return MealPlanPurchase.objects.filter(meal_plan=obj, buyer=request.user.profile).exists()


class MealPlanFullSerializer(MealPlanSerializer):
    class Meta(MealPlanSerializer.Meta):
        fields = MealPlanSerializer.Meta.fields + ['full_plan', 'shopping_list']


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

    class Meta:
        model = TrainingProgramme
        fields = ['id', 'creator_id', 'title', 'description', 'category',
                   'duration_weeks', 'price_artifacts', 'purchase_count',
                   'is_published', 'creator_data', 'is_purchased', 'created_at']
        read_only_fields = ['is_purchased']

    def get_creator_data(self, obj):
        return {
            'username': obj.creator.username,
            'display_name': obj.creator.display_name,
            'avatar_url': obj.creator.avatar_url,
            'verification_status': obj.creator.verification_status,
        }

    def get_is_purchased(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return TrainingProgrammePurchase.objects.filter(programme=obj, buyer=request.user.profile).exists()


class ProductSerializer(serializers.ModelSerializer):
    recommender_data = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = ['id', 'name', 'brand', 'description', 'category',
                   'image_url', 'affiliate_url', 'price_display',
                   'recommended_by', 'recommender_data', 'click_count', 'created_at']

    def get_recommender_data(self, obj):
        if obj.recommended_by:
            return {
                'username': obj.recommended_by.username,
                'display_name': obj.recommended_by.display_name,
            }
        return None


class CreateMealPlanSerializer(serializers.Serializer):
    title = serializers.CharField(max_length=200)
    description = serializers.CharField(required=False, allow_blank=True)
    diet_type = serializers.ChoiceField(choices=[c[0] for c in MealPlan.DIET_TYPES])
    duration_weeks = serializers.IntegerField(default=4, validators=[MinValueValidator(1)])
    calorie_range = serializers.CharField(required=False, allow_blank=True, max_length=50)
    price_artifacts = serializers.JSONField(default=dict, validators=[validate_price_artifacts])
    preview_day = serializers.JSONField(default=dict)
    full_plan = serializers.JSONField(default=dict)
    shopping_list = serializers.ListField(child=serializers.CharField(), default=list)
    is_published = serializers.BooleanField(default=True)


class UpdateMealPlanSerializer(serializers.Serializer):
    title = serializers.CharField(max_length=200, required=False)
    description = serializers.CharField(required=False, allow_blank=True)
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
    category = serializers.CharField(max_length=50)
    duration_weeks = serializers.IntegerField(default=8, validators=[MinValueValidator(1)])
    price_artifacts = serializers.JSONField(default=dict, validators=[validate_price_artifacts])
    is_published = serializers.BooleanField(default=True)


class UpdateTrainingProgrammeSerializer(serializers.Serializer):
    title = serializers.CharField(max_length=200, required=False)
    description = serializers.CharField(required=False, allow_blank=True)
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


class MarketplaceEventSerializer(serializers.ModelSerializer):
    creator_data = serializers.SerializerMethodField()
    gym_data = serializers.SerializerMethodField()
    is_registered = serializers.SerializerMethodField()
    spots_remaining = serializers.SerializerMethodField()

    class Meta:
        model = MarketplaceEvent
        fields = [
            'id', 'creator_data', 'gym_data', 'title', 'description',
            'cover_image_url', 'event_type', 'location', 'online_url',
            'start_datetime', 'end_datetime', 'timezone', 'capacity',
            'ticket_price_artifacts', 'is_free', 'is_published', 'is_cancelled',
            'attendee_count', 'tags', 'category', 'is_registered', 'spots_remaining',
            'created_at',
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

    def get_is_registered(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return EventTicket.objects.filter(event=obj, holder=request.user.profile, status='active').exists()

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
        return {
            'id': str(obj.event.id),
            'title': obj.event.title,
            'start_datetime': obj.event.start_datetime.isoformat(),
            'end_datetime': obj.event.end_datetime.isoformat(),
            'location': obj.event.location,
            'cover_image_url': obj.event.cover_image_url,
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


class ReviewInputSerializer(serializers.Serializer):
    rating = serializers.IntegerField(default=5, min_value=1, max_value=5)
    body = serializers.CharField(max_length=500, required=False, allow_blank=True, default='')
