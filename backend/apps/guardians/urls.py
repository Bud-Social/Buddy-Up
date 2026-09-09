from django.urls import path

from . import views

app_name = 'guardians'
urlpatterns = [
    path('invite/', views.GuardianInviteView.as_view(), name='guardian_invite'),
    path('links/', views.GuardianLinksListView.as_view(), name='guardian_links'),
    path('links/<int:link_id>/accept/', views.GuardianLinkAcceptView.as_view(), name='guardian_link_accept'),
    path('links/<int:link_id>/permissions/', views.GuardianLinkPermissionsView.as_view(), name='guardian_link_permissions'),
    path('links/<int:link_id>/', views.GuardianLinkDeleteView.as_view(), name='guardian_link_delete'),
    path('dashboard/', views.GuardianDashboardView.as_view(), name='guardian_dashboard'),
    path('accept-invite/', views.GuardianAcceptInviteView.as_view(), name='guardian_accept_invite'),
]
