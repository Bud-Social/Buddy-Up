from django.urls import path, include
from rest_framework.routers import DefaultRouter

from . import views

router = DefaultRouter()
router.register(r'predictions', views.AIPredictionJobViewSet)
router.register(r'visual-search', views.VisualSearchViewSet, basename='visual-search')
router.register(r'models', views.ModelMetadataViewSet)
router.register(r'api-keys', views.APIKeyViewSet)

app_name = 'ai'
urlpatterns = [
    path('', include(router.urls)),
]
