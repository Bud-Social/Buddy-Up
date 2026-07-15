from django.contrib import admin
from .models import (
    Gym, GymCategory, GymCategoryPricing, GymMembership,
    JoinRequest, GymInvite, GymSchedulePost, ScheduleSlotEnrollment,
    GymReview, GymDonation,
)


@admin.register(GymCategory)
class GymCategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'display_name', 'is_active']
    list_filter = ['is_active']


@admin.register(Gym)
class GymAdmin(admin.ModelAdmin):
    list_display = ['name', 'handle', 'access_type', 'subscription_type', 'member_count', 'is_verified']
    list_filter = ['access_type', 'subscription_type', 'is_verified']
    search_fields = ['name', 'handle', 'location_city']
    readonly_fields = ['id', 'member_count', 'created_at', 'updated_at']


@admin.register(GymMembership)
class GymMembershipAdmin(admin.ModelAdmin):
    list_display = ['gym', 'member', 'role', 'subscription_active', 'subscription_expires_at']
    list_filter = ['role', 'subscription_active']
    search_fields = ['gym__name', 'member__username']
    list_select_related = ['gym', 'member']


@admin.register(GymCategoryPricing)
class GymCategoryPricingAdmin(admin.ModelAdmin):
    list_display = ['gym', 'category', 'is_free']
    list_select_related = ['gym', 'category']


@admin.register(JoinRequest)
class JoinRequestAdmin(admin.ModelAdmin):
    list_display = ['gym', 'requester', 'status', 'created_at']
    list_filter = ['status']
    list_select_related = ['gym', 'requester']


@admin.register(GymInvite)
class GymInviteAdmin(admin.ModelAdmin):
    list_display = ['gym', 'invited_user', 'invited_by', 'status', 'created_at']
    list_filter = ['status']
    list_select_related = ['gym', 'invited_user', 'invited_by']


@admin.register(GymSchedulePost)
class GymSchedulePostAdmin(admin.ModelAdmin):
    list_display = ['title', 'gym', 'author', 'activity_type', 'start_time']
    list_filter = ['activity_type', 'location_mode']
    list_select_related = ['gym', 'author']


@admin.register(ScheduleSlotEnrollment)
class ScheduleSlotEnrollmentAdmin(admin.ModelAdmin):
    list_display = ['schedule_post', 'member', 'recurrence', 'is_active']
    list_select_related = ['schedule_post', 'member']


@admin.register(GymReview)
class GymReviewAdmin(admin.ModelAdmin):
    list_display = ['gym', 'reviewer', 'rating', 'created_at']
    list_filter = ['rating']
    list_select_related = ['gym', 'reviewer']


@admin.register(GymDonation)
class GymDonationAdmin(admin.ModelAdmin):
    list_display = ['gym', 'donor', 'amount', 'created_at']
    list_select_related = ['gym', 'donor']
