from django.contrib import admin
from .models import Profile, BuddyRelationship, FollowRelationship, BlockRelationship


@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ['username', 'display_name', 'role', 'verification_status', 'streak_days', 'created_at']
    list_filter = ['role', 'verification_status', 'privacy_level']
    search_fields = ['username', 'display_name']


@admin.register(BuddyRelationship)
class BuddyRelationshipAdmin(admin.ModelAdmin):
    list_display = ['from_user', 'to_user', 'status', 'created_at']
    list_filter = ['status']


@admin.register(FollowRelationship)
class FollowRelationshipAdmin(admin.ModelAdmin):
    list_display = ['follower', 'followee', 'created_at']


@admin.register(BlockRelationship)
class BlockRelationshipAdmin(admin.ModelAdmin):
    list_display = ['blocker', 'blocked', 'created_at']
