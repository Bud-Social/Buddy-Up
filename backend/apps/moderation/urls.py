from django.urls import path, include
from rest_framework.routers import DefaultRouter

from . import views

router = DefaultRouter()
router.register(r'reports', views.ModerationReportViewSet)
router.register(r'content-flags', views.ContentFlagViewSet)
router.register(r'actions', views.ModerationActionViewSet)

app_name = 'moderation'
urlpatterns = [
    path('', include(router.urls)),
]
