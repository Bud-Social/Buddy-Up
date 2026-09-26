from django.contrib import admin

from .models import CareerApplication, ContactInquiry, FeatureSuggestion, WaitlistEntry


@admin.register(WaitlistEntry)
class WaitlistEntryAdmin(admin.ModelAdmin):
    list_display = ('email', 'name', 'country', 'interest', 'source', 'created_at')
    list_filter = ('interest', 'source')
    search_fields = ('email', 'name')
    readonly_fields = ('created_at',)


@admin.register(FeatureSuggestion)
class FeatureSuggestionAdmin(admin.ModelAdmin):
    list_display = ('title', 'category', 'status', 'email', 'created_at')
    list_filter = ('category', 'status')
    search_fields = ('title', 'description', 'email')
    readonly_fields = ('created_at',)


@admin.register(ContactInquiry)
class ContactInquiryAdmin(admin.ModelAdmin):
    list_display = ('email', 'name', 'topic', 'status', 'created_at')
    list_filter = ('topic', 'status')
    search_fields = ('email', 'name', 'subject', 'message')
    readonly_fields = ('created_at',)


@admin.register(CareerApplication)
class CareerApplicationAdmin(admin.ModelAdmin):
    list_display = ('email', 'name', 'role', 'status', 'created_at')
    list_filter = ('role', 'status')
    search_fields = ('email', 'name', 'role', 'message')
    readonly_fields = ('created_at',)
