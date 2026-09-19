from rest_framework import serializers

from .models import WaitlistEntry


class WaitlistEntrySerializer(serializers.ModelSerializer):
    class Meta:
        model = WaitlistEntry
        fields = ['id', 'email', 'name', 'country', 'source', 'created_at']
        read_only_fields = ['id', 'created_at']
        extra_kwargs = {
            'email': {'validators': []},
            # The model needs blank=True/default='' only so rows predating
            # the field stay valid; at the API level country is mandatory.
            'country': {'required': True, 'allow_blank': False},
        }
