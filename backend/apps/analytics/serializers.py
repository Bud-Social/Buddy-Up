from rest_framework import serializers
from .models import ActivityRecord, WorkoutLog, BodyMetric, WORKOUT_TYPE_SPECS

# Type-specific extras that are not model columns. They are accepted as
# top-level write keys and folded into the provenance JSONField so the
# taxonomy can grow without a migration per new field.
PROVENANCE_EXTRAS = ('rounds', 'style', 'focus', 'sport')


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
    """Structured workout entry.

    `category` must belong to the chosen `workout_type` per
    WORKOUT_TYPE_SPECS (blank is always allowed). Type-specific extras
    (rounds/style/focus/sport) are write-only and persist in `provenance`.
    """

    rounds = serializers.IntegerField(required=False, min_value=0, write_only=True)
    style = serializers.CharField(required=False, max_length=60, write_only=True)
    focus = serializers.CharField(required=False, max_length=60, write_only=True)
    sport = serializers.CharField(required=False, max_length=60, write_only=True)

    class Meta:
        model = WorkoutLog
        fields = [
            'id', 'workout_type', 'category', 'source_event_id', 'provenance', 'exercise', 'sets', 'reps', 'weight_kg',
            'duration_minutes', 'calories_burned', 'distance_meters',
            'performed_at', 'notes', 'created_at', 'updated_at',
            *PROVENANCE_EXTRAS,
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def validate(self, attrs):
        # Extras are not model fields: strip them before the base serializer
        # sees the payload, then fold them into provenance.
        extras = {key: attrs.pop(key) for key in PROVENANCE_EXTRAS if key in attrs}

        for field in ('sets', 'reps', 'duration_minutes'):
            if attrs.get(field) is not None and attrs[field] < 0:
                raise serializers.ValidationError({field: 'Value cannot be negative.'})

        attrs = super().validate(attrs)

        workout_type = attrs.get('workout_type')
        if workout_type is None:
            workout_type = getattr(self.instance, 'workout_type', None) or WorkoutLog._meta.get_field('workout_type').default
        spec = WORKOUT_TYPE_SPECS.get(workout_type)
        if spec is None:
            raise serializers.ValidationError({'workout_type': f'Unknown workout_type "{workout_type}".'})

        category = attrs.get('category')
        if category is None:
            category = getattr(self.instance, 'category', '') or ''
        if category and category not in spec['categories']:
            allowed = ', '.join(spec['categories']) or 'none'
            raise serializers.ValidationError({
                'category': f'"{category}" is not a valid category for {workout_type}. Allowed: {allowed}.',
            })

        if extras:
            provenance = dict(attrs.get('provenance') or {})
            provenance.update(extras)
            attrs['provenance'] = provenance

        return attrs


class BodyMetricSerializer(serializers.ModelSerializer):
    class Meta:
        model = BodyMetric
        fields = [
            'id', 'weight_kg', 'body_fat_pct', 'photo_url', 'scale_photo_url',
            'notes', 'measured_at', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
