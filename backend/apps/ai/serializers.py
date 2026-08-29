from rest_framework import serializers

from .models import AIPredictionJob, ModelMetadata, APIKey, TrainingRun


class AIPredictionJobSerializer(serializers.ModelSerializer):
    class Meta:
        model = AIPredictionJob
        fields = ['id', 'task', 'status', 'input_data', 'output_data',
                   'error_message', 'model_version', 'result_url',
                   'started_at', 'completed_at', 'created_at', 'confidence', 'correction',
                   'fallback_used', 'fallback_reason', 'cost_usd', 'latency_ms', 'safety_notice']
        read_only_fields = ['id', 'status', 'output_data', 'error_message',
                            'model_version', 'result_url', 'started_at',
                             'completed_at', 'created_at', 'confidence', 'correction', 'fallback_used',
                             'fallback_reason', 'cost_usd', 'latency_ms', 'safety_notice']


class ModelMetadataSerializer(serializers.ModelSerializer):
    class Meta:
        model = ModelMetadata
        fields = ['id', 'name', 'version', 'description', 'framework',
                   'input_schema', 'output_schema', 'metrics', 'artifact_path',
                   'is_active', 'created_at']
        read_only_fields = ['id', 'created_at']


class APIKeySerializer(serializers.ModelSerializer):
    class Meta:
        model = APIKey
        fields = ['id', 'key_hash', 'label', 'is_active', 'last_used_at',
                   'expires_at', 'created_at']
        read_only_fields = ['id', 'key_hash', 'last_used_at', 'created_at']


class TrainingRunSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrainingRun
        fields = ['id', 'model_name', 'version', 'scenario', 'framework',
                  'artifact_path', 'metrics', 'n_classes', 'status', 'source',
                  'duration_seconds', 'gpu', 'error', 'created_at']
        read_only_fields = ['id', 'created_at']
