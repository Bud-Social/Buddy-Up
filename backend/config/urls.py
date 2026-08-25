from django.contrib import admin
from django.conf import settings
from django.conf.urls.static import static
from django.urls import path, include
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/health/', include('apps.accounts.urls_health')),
    path('api/v1/auth/', include('apps.accounts.urls')),
    path('api/v1/profiles/', include('apps.profiles.urls')),
    path('api/v1/feed/', include('apps.feed.urls')),
    path('api/v1/gyms/', include('apps.gyms.urls')),
    path('api/v1/lives/', include('apps.lives.urls')),
    path('api/v1/sessions/', include('apps.sessions.urls')),
    path('api/v1/messaging/', include('apps.messaging.urls')),
    path('api/v1/marketplace/', include('apps.marketplace.urls')),
    path('api/v1/wallet/', include('apps.wallet.urls')),
    path('api/v1/notifications/', include('apps.notifications.urls')),
    path('api/v1/moderation/', include('apps.moderation.urls')),
    path('api/v1/verification/', include('apps.verification.urls')),
    path('api/v1/ai/', include('apps.ai.urls')),
    path('api/v1/analytics/', include('apps.analytics.urls')),
    path('api/v1/', include('apps.gamification.urls')),
    path('api/v1/admin/', include('apps.ai.urls_admin')),
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/schema/swagger/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('auth/social/', include('social_django.urls', namespace='social')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += [path('__debug__/', include('debug_toolbar.urls'))]
