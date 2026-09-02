from django.urls import path

from .uploads import CloudinarySignView

app_name = 'uploads'

urlpatterns = [
    path('sign/', CloudinarySignView.as_view(), name='sign'),
]
