from django.contrib import admin

from .models import Conversation, ConversationMembership, CommunityPost


@admin.register(Conversation)
class ConversationAdmin(admin.ModelAdmin):
    """Read-mostly and deliberately without a participant roster column.

    The roster is exposed through the API, where privacy gating lives
    (``participants_data`` on the messaging serializers). Printing member
    emails into an admin list page would bypass that gate, so the admin shows
    only the conversation's own shape and its origin.
    """

    list_display = ['group_name', 'origin', 'is_group', 'is_community', 'is_public',
                    'last_message_at', 'created_at']
    list_filter = ['origin', 'is_group', 'is_community', 'is_public']
    search_fields = ['group_name', 'description', 'invite_code']
    list_select_related = ['group_gym', 'created_by']
    readonly_fields = ['invite_code', 'call_in_progress', 'last_message_text',
                       'last_message_at', 'created_at', 'updated_at']

    @admin.display(boolean=True, description='Group')
    def is_group(self, obj):
        return obj.is_group

    @admin.display(boolean=True, description='Community')
    def is_community(self, obj):
        return obj.is_community

    @admin.display(boolean=True, description='Public')
    def is_public(self, obj):
        return obj.is_public


@admin.register(ConversationMembership)
class ConversationMembershipAdmin(admin.ModelAdmin):
    list_display = ['conversation', 'profile', 'role', 'created_at']
    list_filter = ['role']
    search_fields = ['profile__username', 'profile__display_name', 'conversation__group_name']
    list_select_related = ['conversation', 'profile']


@admin.register(CommunityPost)
class CommunityPostAdmin(admin.ModelAdmin):
    list_display = ['__str__', 'conversation', 'author', 'is_pinned', 'like_count',
                    'comment_count', 'created_at']
    list_filter = ['is_pinned']
    search_fields = ['body', 'author__username', 'conversation__group_name']
    list_select_related = ['conversation', 'author']
    readonly_fields = ['like_count', 'comment_count', 'created_at', 'updated_at']
