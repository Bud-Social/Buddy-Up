from rest_framework import serializers

from .models import CareerApplication, ContactInquiry, FeatureSuggestion, WaitlistEntry


class WaitlistEntrySerializer(serializers.ModelSerializer):
    class Meta:
        model = WaitlistEntry
        fields = ['id', 'email', 'name', 'country', 'source', 'interest',
                  'metadata', 'created_at']
        read_only_fields = ['id', 'created_at']
        extra_kwargs = {
            'email': {'validators': []},
            # The model needs blank=True/default='' only so rows predating
            # the field stay valid; at the API level country is mandatory.
            'country': {'required': True, 'allow_blank': False},
            'metadata': {'required': False},
        }

    # Per-interest required metadata so gym/trainer leads carry analysable
    # intent (not just an email address).
    REQUIRED_METADATA = {
        'gym': ['gym_name', 'city', 'gym_type'],
        'trainer': ['role', 'city'],
        'corporate': ['company_name', 'city'],
        'organiser': ['brand', 'city'],
        'supplier': ['business', 'city'],
        'distributor': ['business', 'city'],
    }

    def validate(self, attrs):
        interest = attrs.get(
            'interest', getattr(self.instance, 'interest', 'user'),
        ) or 'user'
        metadata = attrs.get(
            'metadata', getattr(self.instance, 'metadata', None),
        ) or {}
        if not isinstance(metadata, dict):
            raise serializers.ValidationError(
                {'metadata': 'Must be an object of lead details.'},
            )
        missing = [
            key for key in self.REQUIRED_METADATA.get(interest, [])
            if not str(metadata.get(key) or '').strip()
        ]
        if missing:
            raise serializers.ValidationError(
                {'metadata': f"Missing required details: {', '.join(missing)}."},
            )
        return attrs


class FeatureSuggestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = FeatureSuggestion
        fields = ['id', 'title', 'description', 'category', 'email', 'name',
                  'status', 'created_at']
        read_only_fields = ['id', 'status', 'created_at']


class ContactInquirySerializer(serializers.ModelSerializer):
    class Meta:
        model = ContactInquiry
        fields = ['id', 'name', 'email', 'topic', 'subject', 'message',
                  'status', 'created_at']
        read_only_fields = ['id', 'status', 'created_at']


class CareerApplicationSerializer(serializers.ModelSerializer):
    class Meta:
        model = CareerApplication
        fields = ['id', 'name', 'email', 'role', 'portfolio_url', 'message',
                  'status', 'created_at']
        read_only_fields = ['id', 'status', 'created_at']
