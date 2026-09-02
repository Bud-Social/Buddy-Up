from django.urls import path

from . import views

app_name = 'sounds'

urlpatterns = [
    path('', views.SoundListCreateView.as_view(), name='sound_list_create'),
    path('<uuid:sound_id>/use/', views.SoundUseView.as_view(), name='sound_use'),
]
