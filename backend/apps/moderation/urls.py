from django.urls import include, path
from rest_framework.routers import DefaultRouter

from . import views

router = DefaultRouter()
router.register(r'reports', views.ModerationReportViewSet)
router.register(r'content-flags', views.ContentFlagViewSet)
router.register(r'actions', views.ModerationActionViewSet)
router.register(r'appeals', views.ModerationAppealViewSet)
router.register(r'commendations', views.CommendationViewSet)

app_name = 'moderation'
urlpatterns = [
    path('', include(router.urls)),
]