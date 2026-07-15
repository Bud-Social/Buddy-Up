from django.contrib import admin

from .models import VerificationDocument, VerificationSubmission


@admin.register(VerificationDocument)
class VerificationDocumentAdmin(admin.ModelAdmin):
    list_display = ['id', 'profile', 'document_type', 'file_url', 'status',
                    'reviewed_by', 'reviewed_at', 'expires_at', 'created_at']
    list_filter = ['document_type', 'status']
    search_fields = ['profile__username', 'profile__display_name']
    list_select_related = ['profile', 'reviewed_by']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(VerificationSubmission)
class VerificationSubmissionAdmin(admin.ModelAdmin):
    list_display = ['id', 'profile', 'verification_type', 'status',
                    'reviewed_by', 'reviewed_at', 'submitted_at', 'created_at']
    list_filter = ['verification_type', 'status']
    search_fields = ['profile__username', 'profile__display_name']
    list_select_related = ['profile', 'reviewed_by']
    readonly_fields = ['id', 'created_at', 'updated_at']
    filter_horizontal = ['documents']
