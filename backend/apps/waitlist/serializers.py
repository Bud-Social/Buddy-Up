from rest_framework import serializers

from .models import WaitlistEntry


class WaitlistEntrySerializer(serializers.ModelSerializer):
    class Meta:
        model = WaitlistEntry
        fields = ['id', 'email', 'name', 'source', 'created_at']
        read_only_fields = ['id', 'created_at']
        extra_kwargs = {'email': {'validators': []}}
