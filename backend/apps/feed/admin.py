from django.contrib import admin

from .models import PostMedia, Sound


@admin.register(Sound)
class SoundAdmin(admin.ModelAdmin):
    list_display = ['id', 'name', 'artist', 'source', 'license', 'usage_count', 'is_active', 'created_at']
    list_filter = ['source', 'is_active', 'license']
    search_fields = ['name', 'artist']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(PostMedia)
class PostMediaAdmin(admin.ModelAdmin):
    list_display = ['id', 'post', 'order', 'media_type', 'url', 'sound', 'created_at']
    list_filter = ['media_type']
    search_fields = ['url', 'alt_text']
    readonly_fields = ['id', 'created_at', 'updated_at']
