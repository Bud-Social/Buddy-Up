from django.contrib import admin

from .models import PostMedia, PostTag, Sound, Tag


@admin.register(Sound)
class SoundAdmin(admin.ModelAdmin):
    list_display = ['id', 'name', 'artist', 'source', 'license', 'usage_count', 'is_active', 'created_at']
    list_filter = ['source', 'is_active', 'license']
    search_fields = ['name', 'artist']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(Tag)
class TagAdmin(admin.ModelAdmin):
    list_display = ['name', 'post_count', 'created_at']
    search_fields = ['name']
    readonly_fields = ['created_at', 'updated_at']

    @admin.display(description='Posts')
    def post_count(self, obj):
        return obj.post_links.count()


@admin.register(PostTag)
class PostTagAdmin(admin.ModelAdmin):
    list_display = ['post', 'tag', 'source', 'created_at']
    list_filter = ['source']
    search_fields = ['tag__name', 'post__body']
    readonly_fields = ['created_at', 'updated_at']


@admin.register(PostMedia)
class PostMediaAdmin(admin.ModelAdmin):
    list_display = ['id', 'post', 'order', 'media_type', 'url', 'sound', 'created_at']
    list_filter = ['media_type']
    search_fields = ['url', 'alt_text']
    readonly_fields = ['id', 'created_at', 'updated_at']
