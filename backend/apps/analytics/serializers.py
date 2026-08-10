from rest_framework import serializers
from .models import ActivityRecord, WorkoutLog, MealLog, BodyMetric


class ActivityRecordSerializer(serializers.ModelSerializer):
    distance_km = serializers.SerializerMethodField()
    pace_display = serializers.SerializerMethodField()
    duration_display = serializers.SerializerMethodField()

    class Meta:
        model = ActivityRecord
        fields = [
            'id', 'activity_type', 'source', 'started_at', 'duration_seconds',
            'distance_meters', 'distance_km', 'avg_pace', 'avg_speed_kmh',
            'calories_burned', 'steps', 'elevation_gain_m', 'route', 'notes',
            'pace_display', 'duration_display', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

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
            'id', 'workout_type', 'exercise', 'sets', 'reps', 'weight_kg',
            'duration_minutes', 'calories_burned', 'distance_meters',
            'performed_at', 'notes', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class MealLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = MealLog
        fields = [
            'id', 'meal_type', 'food_name', 'description', 'calories',
            'protein_g', 'carbs_g', 'fat_g', 'photo_url', 'source',
            'logged_at', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class BodyMetricSerializer(serializers.ModelSerializer):
    class Meta:
        model = BodyMetric
        fields = [
            'id', 'weight_kg', 'body_fat_pct', 'photo_url', 'scale_photo_url',
            'notes', 'measured_at', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
