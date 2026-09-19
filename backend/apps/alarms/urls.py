from django.urls import include, path
from rest_framework.routers import DefaultRouter

from . import views

router = DefaultRouter()
# NOTE: the empty-prefix alarms registration must come LAST — its
# ^(?P<pk>...)/$ detail route would otherwise swallow sounds/, etc.
router.register(r'sounds', views.AlarmSoundViewSet)
router.register(r'shares', views.AlarmShareViewSet)
router.register(r'suggestions', views.AlarmSuggestionViewSet)
# Alarms live at the app root (/alarms/) to match the frontend client.
router.register(r'', views.AlarmViewSet, basename='alarm')

app_name = 'alarms'
urlpatterns = [
    path('', include(router.urls)),
]
