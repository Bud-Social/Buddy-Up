from django.urls import path, include
from rest_framework.routers import DefaultRouter

from . import views_admin

router = DefaultRouter()
router.register(r'dashboard', views_admin.AdminDashboardViewSet, basename='admin-dashboard')

app_name = 'ai_admin'
urlpatterns = [
    path('', include(router.urls)),
]
