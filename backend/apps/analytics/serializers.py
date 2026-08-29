from rest_framework import serializers
from .models import ActivityRecord, WorkoutLog, MealLog, BodyMetric


class ActivityRecordSerializer(serializers.ModelSerializer):
    distance_km = serializers.SerializerMethodField()
    pace_display = serializers.SerializerMethodField()
    duration_display = serializers.SerializerMethodField()

    class Meta:
        model = ActivityRecord
        fields = [
            'id', 'activity_type', 'source', 'source_event_id', 'provenance', 'started_at', 'duration_seconds',
            'distance_meters', 'distance_km', 'avg_pace', 'avg_speed_kmh',
            'calories_burned', 'steps', 'elevation_gain_m', 'route', 'notes',
            'pace_display', 'duration_display', 'created_at', 'updated_at',
            'is_paused', 'paused_at', 'total_pause_seconds',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at', 'is_paused', 'paused_at']

    def validate(self, attrs):
        for field in ('duration_seconds', 'distance_meters', 'total_pause_seconds'):
            if attrs.get(field, 0) is not None and attrs.get(field, 0) < 0:
                raise serializers.ValidationError({field: 'Value cannot be negative.'})
        return attrs

    def get_distance_km(self, obj):
        return round(obj.distance_meters / 1000, 2) if obj.distance_meters else 0.0

    def get_pace_display(self, obj):
        if obj.avg_pace:
            mins, secs = divmod(int(obj.avg_pace), 60)
            return f'{mins}:{secs:02d} /km'
        return None

    def get_duration_display(self, obj):
        hours, rem = divmod(int(obj.duration_seconds), 3600)
        mins, secs = divmod(rem, 60)
        if hours:
            return f'{hours}h {mins}m'
        return f'{mins}m {secs}s'


class WorkoutLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkoutLog
        fields = [
            'id', 'workout_type', 'source_event_id', 'provenance', 'exercise', 'sets', 'reps', 'weight_kg',
            'duration_minutes', 'calories_burned', 'distance_meters',
            'performed_at', 'notes', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def validate(self, attrs):
        for field in ('sets', 'reps', 'duration_minutes'):
            if attrs.get(field) is not None and attrs[field] < 0:
                raise serializers.ValidationError({field: 'Value cannot be negative.'})
        return attrs


class MealLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = MealLog
        fields = [
            'id', 'meal_type', 'source_event_id', 'provenance', 'food_name', 'description', 'calories',
            'protein_g', 'carbs_g', 'fat_g', 'photo_url', 'source',
            'logged_at', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def validate(self, attrs):
        for field in ('calories', 'protein_g', 'carbs_g', 'fat_g'):
            if attrs.get(field) is not None and attrs[field] < 0:
                raise serializers.ValidationError({field: 'Value cannot be negative.'})
        return attrs


class BodyMetricSerializer(serializers.ModelSerializer):
    class Meta:
        model = BodyMetric
        fields = [
            'id', 'weight_kg', 'body_fat_pct', 'photo_url', 'scale_photo_url',
            'notes', 'measured_at', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
