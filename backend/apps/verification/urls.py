from django.urls import path, include
from rest_framework.routers import DefaultRouter

from . import views

router = DefaultRouter()
router.register(r'documents', views.VerificationDocumentViewSet)
router.register(r'submissions', views.VerificationSubmissionViewSet)

app_name = 'verification'
urlpatterns = [
    path('documents/<uuid:pk>/access/', views.VerificationDocumentAccessView.as_view(), name='document_access'),
    path('', include(router.urls)),
]
