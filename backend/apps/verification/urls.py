from django.urls import path, include
from rest_framework.routers import DefaultRouter

from . import views

router = DefaultRouter()
router.register(r'documents', views.VerificationDocumentViewSet)
router.register(r'submissions', views.VerificationSubmissionViewSet)

app_name = 'verification'
urlpatterns = [
    path('', include(router.urls)),
]
