from django.urls import include, path
from rest_framework.routers import DefaultRouter

from . import views

router = DefaultRouter()
router.register(r'', views.WaitlistViewSet, basename='waitlist')
router.register(r'suggestions', views.FeatureSuggestionViewSet, basename='suggestion')
router.register(r'contact', views.ContactInquiryViewSet, basename='contact')

app_name = 'waitlist'
urlpatterns = [
    path('', include(router.urls)),
]
