from django.urls import path
from . import views

app_name = 'feed'
urlpatterns = [
    path('', views.FeedView.as_view(), name='feed'),
    path('create/', views.CreatePostView.as_view(), name='create_post'),
    path('saved/', views.SavedPostsView.as_view(), name='saved_posts'),
    path('<uuid:post_id>/', views.PostDetailView.as_view(), name='post_detail'),
    path('<uuid:post_id>/comments/', views.CommentsView.as_view(), name='comments'),
    path('<uuid:post_id>/comments/<uuid:comment_id>/', views.CommentDetailView.as_view(), name='comment_detail'),
    path('<uuid:post_id>/comments/<uuid:comment_id>/react/', views.CommentReactionView.as_view(), name='comment_react'),
    path('<uuid:post_id>/react/', views.ReactionView.as_view(), name='react'),
    path('<uuid:post_id>/repost/', views.RepostView.as_view(), name='repost'),
    path('<uuid:post_id>/save/', views.SaveView.as_view(), name='save'),
    path('<uuid:post_id>/pin/', views.PostPinView.as_view(), name='pin'),
    path('<uuid:post_id>/poll/vote/', views.PollVoteView.as_view(), name='poll_vote'),
    path('drafts/', views.DraftListCreateView.as_view(), name='draft_list_create'),
    path('drafts/<uuid:draft_id>/', views.DraftDetailView.as_view(), name='draft_detail'),
    path('workout/analyze/', views.WorkoutAnalysisView.as_view(), name='workout_analyze'),
    path('health-insights/', views.HealthInsightsView.as_view(), name='health_insights'),
    path('workout-form/', views.WorkoutFormAnalysisView.as_view(), name='workout_form'),
]
