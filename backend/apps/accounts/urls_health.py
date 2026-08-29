from django.urls import path
from .views import health_check, metrics

app_name = 'health'
urlpatterns = [
    path('', health_check, name='health_check'),
    path('metrics/', metrics, name='metrics'),
]
