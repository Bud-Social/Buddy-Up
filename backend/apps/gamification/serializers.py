from rest_framework import serializers

from .models import AchievementDefinition, UserAchievement


class AchievementDefinitionSerializer(serializers.ModelSerializer):
    metric_label = serializers.SerializerMethodField()

    class Meta:
        model = AchievementDefinition
        fields = [
            'id', 'code', 'title', 'description', 'icon', 'tier',
            'category', 'metric', 'metric_label', 'threshold', 'sort_order',
        ]
        read_only_fields = fields

    def get_metric_label(self, obj) -> str:
        from .services import METRIC_LABELS
        return METRIC_LABELS.get(obj.metric, obj.metric.replace('_', ' '))


class UserAchievementSerializer(serializers.ModelSerializer):
    code = serializers.CharField(source='definition.code', read_only=True)
    title = serializers.CharField(source='definition.title', read_only=True)

    class Meta:
        model = UserAchievement
        fields = ['id', 'code', 'title', 'progress', 'earned_at']
        read_only_fields = fields
