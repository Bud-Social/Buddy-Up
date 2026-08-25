from django.contrib import admin

from .models import AchievementDefinition, UserAchievement


@admin.register(AchievementDefinition)
class AchievementDefinitionAdmin(admin.ModelAdmin):
    list_display = ('icon', 'title', 'code', 'tier', 'category', 'metric', 'threshold', 'is_active')
    list_filter = ('tier', 'category', 'is_active')
    search_fields = ('title', 'code', 'description')
    ordering = ('sort_order', 'threshold')


@admin.register(UserAchievement)
class UserAchievementAdmin(admin.ModelAdmin):
    list_display = ('profile', 'definition', 'progress', 'earned_at', 'created_at')
    list_filter = ('definition__tier', 'definition__category')
    search_fields = ('profile__username', 'definition__title')
    raw_id_fields = ('profile', 'definition')
