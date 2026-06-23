from rest_framework import serializers
from .models import MealPlan, MealPlanPurchase, MealPlanReview, TrainingProgramme, Product


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

    class Meta:
        model = TrainingProgramme
        fields = ['id', 'creator_id', 'title', 'description', 'category',
                   'duration_weeks', 'price_artifacts', 'purchase_count',
                   'creator_data', 'created_at']

    def get_creator_data(self, obj):
        return {
            'username': obj.creator.username,
            'display_name': obj.creator.display_name,
            'avatar_url': obj.creator.avatar_url,
            'verification_status': obj.creator.verification_status,
        }


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


class PersonaliseMealPlanSerializer(serializers.Serializer):
    meal_plan_id = serializers.UUIDField()
