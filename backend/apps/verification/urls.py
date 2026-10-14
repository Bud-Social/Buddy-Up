from django.urls import path, include
from rest_framework.routers import DefaultRouter

from . import views

router = DefaultRouter()
router.register(r'documents', views.VerificationDocumentViewSet)
router.register(r'submissions', views.VerificationSubmissionViewSet)

app_name = 'verification'
urlpatterns = [
    path('documents/<uuid:pk>/access/', views.VerificationDocumentAccessView.as_view(), name='document_access'),
    # Named routes, so RegisterSerializer's rejection message can point at a
    # path that exists rather than one a reader has to guess at.
    path(
        'category-applications/',
        views.CategoryApplicationView.as_view(),
        name='category_applications',
    ),
    path('my-applications/', views.MyApplicationsView.as_view(), name='my_applications'),
    path('', include(router.urls)),
]
