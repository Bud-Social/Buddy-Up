from rest_framework import viewsets, mixins
from rest_framework.permissions import IsAdminUser, IsAuthenticated

from .models import AIPredictionJob, ModelMetadata, APIKey
from .serializers import (
    AIPredictionJobSerializer, ModelMetadataSerializer, APIKeySerializer,
)


class AIPredictionJobViewSet(
    mixins.CreateModelMixin,
    mixins.RetrieveModelMixin,
    mixins.ListModelMixin,
    viewsets.GenericViewSet,
):
    queryset = AIPredictionJob.objects.all()
    serializer_class = AIPredictionJobSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['task', 'status']
    search_fields = ['task', 'error_message']


class ModelMetadataViewSet(viewsets.ModelViewSet):
    queryset = ModelMetadata.objects.all()
    serializer_class = ModelMetadataSerializer
    permission_classes = [IsAdminUser]
    filterset_fields = ['name', 'is_active']
    search_fields = ['name', 'description']


class APIKeyViewSet(viewsets.ModelViewSet):
    queryset = APIKey.objects.all()
    serializer_class = APIKeySerializer
    permission_classes = [IsAdminUser]
    search_fields = ['label']
