"""Turn a ``(content_type, content_id)`` pair into something a moderator can read.

The queue shows a truncated id and a short preview, which is enough to triage
but not to act on: "is this a joke or an advert" needs the post in front of you.
This module resolves the live object and returns a small, uniform shape --
label, a couple of renderable fields, and the in-app route that opens it -- so
the console does not need sixteen special cases.

Deliberately hand-written rather than derived. Six apps own these models and
none may import the others' models at import time, and the fields a moderator
needs are judgement calls ("who posted this and what else have they posted"),
not mechanical.

``None`` from a resolver means the object is gone. That is not an error: content
can be deleted by its creator while a flag sits in the queue.
"""

import logging

from django.core.exceptions import ValidationError
from django.utils import timezone

logger = logging.getLogger(__name__)


def _text(value, limit=500):
    if value is None:
        return ''
    text = str(value)
    return text if len(text) <= limit else f'{text[:limit]}…'


def _profile_ref(profile):
    if profile is None:
        return None
    return {
        'username': getattr(profile, 'username', ''),
        'display_name': getattr(profile, 'display_name', '') or getattr(profile, 'username', ''),
        'avatar_url': getattr(profile, 'avatar_url', '') or '',
    }


def _resolve_post(content_id):
    from apps.feed.models import Post

    obj = Post.objects.select_related('author', 'author__user').filter(pk=content_id).first()
    if obj is None:
        return None
    return {
        'label': 'Feed post',
        'title': _text(obj.body, 300),
        'body': _text(obj.body),
        'author': _profile_ref(obj.author),
        'created_at': obj.created_at,
        'media_count': len(obj.media_urls or []),
        'media_urls': (obj.media_urls or [])[:6],
        # Counts are annotations on the feed querysets, not columns, so they
        # are counted here rather than read off the row.
        'stats': {
            'reactions': obj.reactions.count(),
            'comments': obj.comments.count(),
            'shares': obj.share_count,
            'views': obj.view_count,
        },
        'route': f'/feed?post={obj.id}',
    }


def _resolve_comment(content_id):
    from apps.feed.models import Comment

    obj = Comment.objects.select_related('author', 'post').filter(pk=content_id).first()
    if obj is None:
        return None
    return {
        'label': 'Comment',
        'title': _text(obj.body, 120),
        'body': _text(obj.body),
        'author': _profile_ref(obj.author),
        'created_at': obj.created_at,
        'context': {'post_id': str(obj.post_id), 'post_body': _text(obj.post.body, 200)},
        'route': f'/feed?post={obj.post_id}',
    }


def _resolve_profile(content_id):
    from apps.profiles.models import Profile

    obj = Profile.objects.filter(pk=content_id).first()
    if obj is None:
        return None
    return {
        'label': 'Profile',
        'title': obj.display_name or obj.username,
        'body': _text(obj.bio),
        'author': _profile_ref(obj),
        'created_at': obj.created_at,
        'route': f'/{obj.username}',
    }


def _resolve_buddy_search_profile(content_id):
    from apps.profiles.models import BuddySearchProfile

    obj = BuddySearchProfile.objects.select_related('profile').filter(pk=content_id).first()
    if obj is None:
        return None
    return {
        'label': 'Find-a-buddy profile',
        'title': _profile_ref(obj.profile),
        'body': _text(obj.bio),
        'author': _profile_ref(obj.profile),
        'created_at': obj.created_at,
        'fields': {
            'intent': _text(getattr(obj, 'custom_intent', ''), 200),
            'goals': _text(getattr(obj, 'goals', ''), 200),
        },
        'route': f'/buddies/find/{obj.profile.username}',
    }


def _resolve_community(content_id):
    from apps.messaging.models import Conversation

    obj = Conversation.objects.filter(pk=content_id, is_community=True).first()
    if obj is None:
        return None
    return {
        'label': 'Community',
        'title': obj.group_name or 'Community',
        'body': _text(getattr(obj, 'description', '')),
        'created_at': obj.created_at,
        'stats': {
            'members': obj.participants.count() if hasattr(obj, 'participants') else 0,
        },
        'route': f'/communities/{obj.pk}',
    }


def _resolve_community_post(content_id):
    from apps.messaging.models import CommunityPost

    obj = CommunityPost.objects.select_related('author', 'conversation').filter(pk=content_id).first()
    if obj is None:
        return None
    return {
        'label': 'Community post',
        'title': _text(obj.body, 200),
        'body': _text(obj.body),
        'author': _profile_ref(obj.author),
        'created_at': obj.created_at,
        'route': f'/communities/{obj.conversation_id}',
    }


def _resolve_product(content_id):
    from apps.marketplace.models import Product

    obj = Product.objects.filter(pk=content_id).first()
    if obj is None:
        return None
    return {
        'label': 'Product',
        'title': obj.name,
        'body': _text(obj.description),
        'created_at': obj.created_at,
        'fields': {'brand': obj.brand, 'category': obj.category, 'is_active': obj.is_active},
        'route': f'/marketplace/products/{obj.pk}',
    }


def _resolve_meal_plan(content_id):
    from apps.marketplace.models import MealPlan

    obj = MealPlan.objects.select_related('creator').filter(pk=content_id).first()
    if obj is None:
        return None
    return {
        'label': 'Meal plan',
        'title': obj.title,
        'body': _text(obj.description),
        'author': _profile_ref(obj.creator),
        'created_at': obj.created_at,
        # A meal plan's `description` is marketing copy; the plan body is where
        # an unsubstantiated medical claim actually hides.
        'fields': {
            'diet_type': obj.diet_type,
            'duration_weeks': obj.duration_weeks,
            'plan_preview': _text(getattr(obj, 'full_plan', ''), 600),
            'is_published': obj.is_published,
        },
        'route': f'/marketplace/meal-plans/{obj.pk}',
    }


def _resolve_programme(content_id):
    from apps.marketplace.models import TrainingProgramme

    obj = TrainingProgramme.objects.select_related('creator').filter(pk=content_id).first()
    if obj is None:
        return None
    return {
        'label': 'Training programme',
        'title': obj.title,
        'body': _text(obj.description),
        'author': _profile_ref(obj.creator),
        'created_at': obj.created_at,
        'fields': {'difficulty': obj.difficulty, 'is_published': obj.is_published},
        'route': f'/marketplace/programmes/{obj.pk}',
    }


def _resolve_event(content_id):
    from apps.marketplace.models import MarketplaceEvent

    obj = MarketplaceEvent.objects.select_related('creator').filter(pk=content_id).first()
    if obj is None:
        return None
    return {
        'label': 'Event',
        'title': obj.title,
        'body': _text(obj.description),
        'author': _profile_ref(obj.creator),
        'created_at': obj.created_at,
        'fields': {
            'starts_at': obj.start_datetime,
            'is_published': obj.is_published,
            'is_cancelled': getattr(obj, 'is_cancelled', None),
        },
        'route': f'/marketplace/events/{obj.pk}',
    }


def _resolve_gym(content_id):
    from apps.gyms.models import Gym

    obj = Gym.objects.filter(pk=content_id).first()
    if obj is None:
        return None
    return {
        'label': 'Gym',
        'title': obj.name,
        'body': _text(obj.description),
        'created_at': obj.created_at,
        'fields': {'is_deleted': obj.is_deleted, 'handle': obj.handle},
        'route': f'/gyms/{obj.handle}',
    }


def _resolve_gym_schedule_post(content_id):
    from apps.gyms.models import GymSchedulePost

    obj = GymSchedulePost.objects.select_related('author', 'gym').filter(pk=content_id).first()
    if obj is None:
        return None
    return {
        'label': 'Gym schedule post',
        'title': obj.title,
        'body': _text(getattr(obj, 'description', '')),
        'author': _profile_ref(obj.author),
        'created_at': obj.created_at,
        'route': f"/gyms/{obj.gym.handle}/schedule-posts/{obj.pk}",
    }


def _resolve_live(content_id):
    from apps.lives.models import BuddyLive

    obj = BuddyLive.objects.select_related('host').filter(pk=content_id).first()
    if obj is None:
        return None
    return {
        'label': 'Live',
        'title': obj.title,
        'body': _text(getattr(obj, 'description', '')),
        'author': _profile_ref(obj.host),
        'created_at': obj.created_at,
        # Recording and transcript are the two things a moderator most needs
        # for a live and neither is reachable anywhere in the console today.
        'fields': {
            'status': obj.status,
            'scheduled_for': getattr(obj, 'scheduled_for', None),
            'replay_url': getattr(obj, 'replay_url', '') or '',
            'mux_playback_id': getattr(obj, 'mux_playback_id', '') or '',
            # Generated after the replay exists (lives.tasks). Surfaced as a
            # key even when empty so the console can distinguish "still
            # transcribing" from "this live has no transcript field".
            'transcript': _text(getattr(obj, 'transcript', ''), 20000),
            'transcript_available': bool(getattr(obj, 'transcript', '')),
        },
        'route': f'/lives/{obj.pk}',
    }


def _resolve_booking(content_id):
    from apps.sessions.models import BookingSession

    obj = BookingSession.objects.select_related('client', 'trainer').filter(pk=content_id).first()
    if obj is None:
        return None
    return {
        'label': 'Session',
        'title': f'Session with {getattr(obj.trainer, "display_name", "trainer")}',
        'author': _profile_ref(obj.client),
        'created_at': obj.created_at,
        'fields': {
            'status': obj.status,
            'scheduled_for': getattr(obj, 'scheduled_for', None)
            or getattr(obj, 'start_time', None),
        },
        'route': f'/sessions/{obj.pk}',
    }


def _resolve_trainer_profile(content_id):
    from apps.sessions.models import TrainerProfile

    obj = TrainerProfile.objects.select_related('profile').filter(pk=content_id).first()
    if obj is None:
        return None
    return {
        'label': 'Trainer profile',
        'title': _profile_ref(obj.profile),
        'body': _text(getattr(obj, 'bio', '')),
        'author': _profile_ref(obj.profile),
        'created_at': obj.created_at,
        'fields': {
            'specialties': _text(getattr(obj, 'specialties', ''), 300),
            'certifications': _text(getattr(obj, 'certifications', ''), 300),
            'intro_video_url': getattr(obj, 'intro_video_url', '') or '',
        },
        'route': f"/sessions/trainers/{obj.profile.username}",
    }


def _resolve_availability(content_id):
    from apps.sessions.models import Availability

    obj = Availability.objects.select_related('trainer').filter(pk=content_id).first()
    if obj is None:
        return None
    return {
        'label': 'Schedule slot',
        'title': f'{getattr(obj, "day_of_week", "")} {getattr(obj, "start_time", "")}',
        'author': _profile_ref(obj.trainer),
        'created_at': obj.created_at,
        'fields': {'is_active': obj.is_active},
        'route': f"/sessions/trainers/{obj.trainer.username}",
    }


RESOLVERS = {
    'feed.post': _resolve_post,
    'feed.comment': _resolve_comment,
    'user.profile': _resolve_profile,
    'profiles.buddy_search_profile': _resolve_buddy_search_profile,
    'messaging.community': _resolve_community,
    'messaging.community_post': _resolve_community_post,
    'marketplace.product': _resolve_product,
    'marketplace.meal_plan': _resolve_meal_plan,
    'marketplace.programme': _resolve_programme,
    'marketplace.event': _resolve_event,
    'gym': _resolve_gym,
    'gyms.schedule_post': _resolve_gym_schedule_post,
    'lives.buddy_live': _resolve_live,
    'sessions.booking': _resolve_booking,
    'sessions.trainer_profile': _resolve_trainer_profile,
    'sessions.availability': _resolve_availability,
}


def resolve_content(content_type, content_id):
    """Resolve to a uniform dict, or None when the content is gone.

    Raises for an unregistered content type -- an unknown type is a bug in the
    flag producers, not a moderation state.
    """
    resolver = RESOLVERS.get(content_type)
    if resolver is None:
        raise KeyError(
            f'No resolver for content type {content_type!r}. '
            f'Known: {", ".join(sorted(RESOLVERS))}.'
        )
    try:
        resolved = resolver(content_id)
    except (ValueError, TypeError, ValidationError) as exc:
        # Not every model is keyed by UUID -- Gym uses an integer pk -- so a
        # malformed id raises at the filter rather than returning nothing. A
        # flag carrying a bad id is a data problem, not a server error, so it
        # reads as "gone" and the moderator moves on.
        logger.info('moderation_resolve bad id %s %s: %s', content_type, content_id, exc)
        return None
    if resolved is None:
        logger.info('moderation_resolve missing %s %s', content_type, content_id)
    return resolved


def describe_resolvers():
    """content_type -> human label, for the console's filter chips."""
    labels = {}
    for content_type, resolver in sorted(RESOLVERS.items()):
        labels[content_type] = resolver.__name__.replace('_resolve_', '').replace('_', ' ').title()
    return labels


# Re-exported so callers building a preview can stamp it without importing
# timezone from two places.
def now():
    return timezone.now()
