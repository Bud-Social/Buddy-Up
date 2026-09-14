from django.urls import path
from . import views

app_name = 'feed'
urlpatterns = [
    path('', views.FeedView.as_view(), name='feed'),
    path('create/', views.CreatePostView.as_view(), name='create_post'),
    path('saved/', views.SavedPostsView.as_view(), name='saved_posts'),
    path('creator/insights/', views.CreatorInsightsView.as_view(), name='creator_insights'),
    path('<uuid:post_id>/', views.PostDetailView.as_view(), name='post_detail'),
    path('<uuid:post_id>/comments/', views.CommentsView.as_view(), name='comments'),
    path('<uuid:post_id>/comments/<uuid:comment_id>/', views.CommentDetailView.as_view(), name='comment_detail'),
    path('<uuid:post_id>/comments/<uuid:comment_id>/react/', views.CommentReactionView.as_view(), name='comment_react'),
    path('<uuid:post_id>/react/', views.ReactionView.as_view(), name='react'),
    path('<uuid:post_id>/repost/', views.RepostView.as_view(), name='repost'),
    path('<uuid:post_id>/save/', views.SaveView.as_view(), name='save'),
    path('<uuid:post_id>/share/', views.PostShareView.as_view(), name='share'),
    path('<uuid:post_id>/shares/', views.PostSharesListView.as_view(), name='share_list'),
    path('<uuid:post_id>/hide/', views.PostHideView.as_view(), name='hide'),
    # Bud Press "Don't suggest this creator". Canonical paths are
    # /api/v1/profiles/<username>/mute|unmute/ — remount these two views in
    # apps/profiles/urls.py (2-line follow-up, outside this workstream's
    # owned files). Until then they are served under this feed namespace
    # with identical trailing shapes.
    path('<str:username>/mute/', views.MuteAuthorView.as_view(), name='mute_author'),
    path('<str:username>/unmute/', views.UnmuteAuthorView.as_view(), name='unmute_author'),
    path('<uuid:post_id>/view/', views.PostViewRecordView.as_view(), name='record_view'),
    path('<uuid:post_id>/pin/', views.PostPinView.as_view(), name='pin'),
    path('<uuid:post_id>/poll/vote/', views.PollVoteView.as_view(), name='poll_vote'),
    path('drafts/', views.DraftListCreateView.as_view(), name='draft_list_create'),
    path('drafts/<uuid:draft_id>/', views.DraftDetailView.as_view(), name='draft_detail'),
    path('workout/analyze/', views.WorkoutAnalysisView.as_view(), name='workout_analyze'),
    path('health-insights/', views.HealthInsightsView.as_view(), name='health_insights'),
    path('workout-form/', views.WorkoutFormAnalysisView.as_view(), name='workout_form'),
    path('studio/transcribe/', views.StudioTranscribeView.as_view(), name='studio_transcribe'),
]
