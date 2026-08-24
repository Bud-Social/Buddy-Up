from django.urls import path
from . import views

app_name = 'messaging'
urlpatterns = [
    path('conversations/', views.ConversationListView.as_view(), name='conversations'),
    path('conversations/start/', views.StartConversationView.as_view(), name='start_conversation'),
    path('conversations/<uuid:conversation_id>/', views.ConversationDetailView.as_view(), name='conversation_detail'),
    path('conversations/<uuid:conversation_id>/messages/', views.MessageListView.as_view(), name='messages'),
    path('conversations/<uuid:conversation_id>/read/', views.MarkReadView.as_view(), name='mark_read'),
    path('conversations/<uuid:conversation_id>/calls/', views.CallLogView.as_view(), name='call_logs'),
    path('conversations/<uuid:conversation_id>/calls/session/', views.ConversationCallSessionView.as_view(), name='call_session'),
    path('messages/<uuid:message_id>/react/', views.MessageReactionView.as_view(), name='message_react'),
    path('messages/<uuid:message_id>/delete/', views.DeleteMessageView.as_view(), name='message_delete'),
    path('messages/<uuid:message_id>/serve/', views.ServeMessageFileView.as_view(), name='serve_message_file'),
    path('messages/<uuid:message_id>/forward/', views.ForwardMessageView.as_view(), name='forward_message'),
    path('link-preview/', views.LinkPreviewView.as_view(), name='link_preview'),
    path('upload/', views.UploadAttachmentView.as_view(), name='upload_attachment'),
    path('conversations/group/', views.CreateGroupConversationView.as_view(), name='create_group'),
    # Communities
    path('communities/', views.CommunityListView.as_view(), name='communities'),
    path('communities/join/', views.CommunityJoinByCodeView.as_view(), name='community_join_code'),
    path('communities/<uuid:community_id>/', views.CommunityDetailView.as_view(), name='community_detail'),
    path('communities/<uuid:community_id>/join/', views.CommunityJoinView.as_view(), name='community_join'),
    path('communities/<uuid:community_id>/leave/', views.CommunityLeaveView.as_view(), name='community_leave'),
    path('communities/<uuid:community_id>/members/', views.CommunityMemberManagementView.as_view(), name='community_members'),
    path('communities/<uuid:community_id>/members/<uuid:user_id>/', views.CommunityMemberManagementView.as_view(), name='community_member_delete'),
    path('communities/<uuid:community_id>/members/<uuid:user_id>/role/', views.CommunityRoleView.as_view(), name='community_role'),
    path('communities/<uuid:community_id>/transfer/', views.CommunityTransferOwnershipView.as_view(), name='community_transfer'),
    path('communities/<uuid:community_id>/invite/', views.CommunityInviteView.as_view(), name='community_invite'),
    path('communities/<uuid:community_id>/posts/', views.CommunityPostListView.as_view(), name='community_posts'),
    path('communities/<uuid:community_id>/posts/<uuid:post_id>/', views.CommunityPostDetailView.as_view(), name='community_post_detail'),
    path('communities/<uuid:community_id>/posts/<uuid:post_id>/like/', views.CommunityPostLikeView.as_view(), name='community_post_like'),
    path('communities/<uuid:community_id>/posts/<uuid:post_id>/comments/', views.CommunityPostCommentView.as_view(), name='community_post_comments'),
    path('communities/<uuid:community_id>/posts/<uuid:post_id>/comments/<uuid:comment_id>/', views.CommunityPostCommentView.as_view(), name='community_post_comment_delete'),
]
