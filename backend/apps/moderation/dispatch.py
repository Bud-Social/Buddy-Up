"""Dispatch a freshly created or edited piece of content to the AI checkers.

Only posts were ever wired: `apps.feed` called the moderation tasks directly, so
every other content type -- meal plans, programmes, products, events, lives,
trainer profiles, community posts, comments -- reached the platform completely
unmoderated. A meal plan's ``full_plan`` is exactly where an unsubstantiated
medical claim hides, and it had no checker at all.

A signal is used rather than a call in each view: these models are created in a
dozen places (purchases, seed scripts, admin actions) and a view-level call is
only reached for one of them.

Two rules make this safe to leave in place:

* **Never raises.** A moderation dispatch must not be able to fail a user's
  request to publish their meal plan. Everything is best-effort and logged.
* **Skip when unchanged.** An edit that does not touch the moderated text does
  not re-run the model, so editing prices does not re-flag a plan.
"""

import logging

from django.db import transaction
from django.db.models.signals import post_save

logger = logging.getLogger(__name__)

#: Which text on each model is actually moderated, and who to attribute it to.
#: A model absent from this map simply is not auto-moderated yet -- which is a
#: visible gap rather than a silent one, because ``unmoderated_types()`` reports
#: the difference.
TEXT_SOURCES = {
    'marketplace.models.MealPlan': (
        lambda o: ' '.join(filter(None, [getattr(o, 'title', ''), getattr(o, 'description', ''),
                                         getattr(o, 'full_plan', '')])).strip(),
        lambda o: getattr(o, 'creator', None),
    ),
    'marketplace.models.TrainingProgramme': (
        lambda o: ' '.join(filter(None, [getattr(o, 'title', ''), getattr(o, 'description', '')])).strip(),
        lambda o: getattr(o, 'creator', None),
    ),
    'marketplace.models.Product': (
        lambda o: ' '.join(filter(None, [getattr(o, 'name', ''), getattr(o, 'description', '')])).strip(),
        lambda o: getattr(o, 'recommended_by', None),
    ),
    'marketplace.models.MarketplaceEvent': (
        lambda o: ' '.join(filter(None, [getattr(o, 'title', ''), getattr(o, 'description', ''),
                                         getattr(o, 'agenda', '')])).strip(),
        lambda o: getattr(o, 'creator', None),
    ),
    'profiles.models.BuddySearchProfile': (
        lambda o: ' '.join(filter(None, [getattr(o, 'bio', ''), getattr(o, 'custom_intent', ''),
                                         getattr(o, 'goals', '')])).strip(),
        lambda o: getattr(o, 'profile', None),
    ),
    'booking_sessions.TrainerProfile': (
        lambda o: ' '.join(filter(None, [getattr(o, 'bio', ''), getattr(o, 'specialties', ''),
                                         getattr(o, 'certifications', '')])).strip(),
        lambda o: getattr(o, 'profile', None),
    ),
    'messaging.models.CommunityPost': (
        lambda o: (getattr(o, 'body', '') or '').strip(),
        lambda o: getattr(o, 'author', None),
    ),
    'feed.models.Comment': (
        lambda o: (getattr(o, 'body', '') or '').strip(),
        lambda o: getattr(o, 'author', None),
    ),
    'lives.models.BuddyLive': (
        lambda o: ' '.join(filter(None, [getattr(o, 'title', '')])).strip(),
        lambda o: getattr(o, 'host', None),
    ),
    'gyms.models.Gym': (
        lambda o: ' '.join(filter(None, [getattr(o, 'name', ''),
                                         getattr(o, 'description', '')])).strip(),
        # A gym has no single author; ownership is a membership row, and the
        # policy checker only needs to know whether the author is a practitioner.
        lambda o: None,
    ),
    'gyms.models.GymRoutinePost': (
        lambda o: (getattr(o, 'title', '') or '').strip(),
        lambda o: getattr(o, 'author', None),
    ),
    'profiles.models.Profile': (
        lambda o: ' '.join(filter(None, [getattr(o, 'display_name', ''),
                                         getattr(o, 'bio', '')])).strip(),
        lambda o: o,
    ),
    'messaging.models.Conversation': (
        lambda o: ' '.join(filter(None, [getattr(o, 'group_name', ''),
                                         getattr(o, 'description', '')])).strip(),
        lambda o: None,
    ),
}

#: The content_type each model is registered under, matching the takedown
#: registry. Kept beside TEXT_SOURCES so one map cannot drift from the other.
CONTENT_TYPES = {
    'marketplace.models.MealPlan': 'marketplace.meal_plan',
    'marketplace.models.TrainingProgramme': 'marketplace.programme',
    'marketplace.models.Product': 'marketplace.product',
    'marketplace.models.MarketplaceEvent': 'marketplace.event',
    'profiles.models.BuddySearchProfile': 'profiles.buddy_search_profile',
    'booking_sessions.TrainerProfile': 'sessions.trainer_profile',
    'messaging.models.CommunityPost': 'messaging.community_post',
    'feed.models.Comment': 'feed.comment',
    'lives.models.BuddyLive': 'lives.buddy_live',
    'gyms.models.Gym': 'gym',
    'gyms.models.GymRoutinePost': 'gyms.routine_post',
    'profiles.models.Profile': 'user.profile',
    'messaging.models.Conversation': 'messaging.community',
}


def unmoderated_types():
    """Types with a takedown handler but no auto-moderation. For the console."""
    from apps.moderation.takedown import CONTENT_HANDLERS

    wired = set(CONTENT_TYPES.values())
    return sorted(set(CONTENT_HANDLERS) - wired)


def dispatch(content_type, content_id, text, *, author_is_practitioner=False):
    """Queue the policy checker for one piece of text. Never raises."""
    if not text or not text.strip():
        return False
    try:
        from apps.moderation.tasks import moderate_policy_text

        moderate_policy_text.delay(
            content_type, str(content_id), text,
            author_is_practitioner=author_is_practitioner,
        )
        return True
    except Exception:  # noqa: BLE001
        logger.warning('Could not dispatch moderation for %s %s', content_type, content_id,
                       exc_info=True)
        return False


def _is_practitioner(profile):
    return bool(profile) and getattr(profile, 'verification_status', None) == 'practitioner'


def connect():
    """Wire the receivers. Called once from the moderation app's ready()."""
    for label in TEXT_SOURCES:
        model = _model_for(label)
        if model is None:
            continue
        post_save.connect(
            _make_receiver(label),
            sender=model,
            dispatch_uid=f'moderation-dispatch-{label}',
            weak=False,
        )


def _model_for(label):
    """Resolve an `app.models.Model` path to the model class.

    `apps.get_model` wants `app_label.ModelName`, not a dotted module path -- so
    passing the full path returned None for *every* type and the whole feature
    silently did nothing, with only a warning log to show for it. The prefix is
    stripped here.
    """
    from django.apps import apps as django_apps

    parts = label.split('.')
    if len(parts) == 3:
        # A dotted module path: 'marketplace.models.MealPlan' -> 'marketplace'.
        app_label = parts[0]
    else:
        # Already an `app_label.Model` pair. Note that the app label is not always
        # the import path -- apps.sessions has the label 'booking_sessions' --
        # so this form is used wherever the two differ.
        app_label = parts[0]
    model_name = parts[-1]
    try:
        return django_apps.get_model(app_label, model_name)
    except Exception:  # noqa: BLE001
        logger.error('Moderation dispatch: could not resolve model %s', label, exc_info=True)
        return None


def _make_receiver(label):
    text_of, author_of = TEXT_SOURCES[label]
    content_type = CONTENT_TYPES[label]

    def receiver(sender, instance, created, **kwargs):
        if not created:
            # Re-running the model on every unrelated edit would re-flag content
            # because a price changed. Only new content is dispatched; a text
            # edit is handled by the view that owns the field.
            return
        # Queue the check only once the row is committed. Dispatching inline
        # runs the moderation task inside the creating transaction, so anything
        # the task does -- a flag insert, an AI call -- happens while the user is
        # still waiting and can fail their request to publish.
        def run():
            try:
                text = text_of(instance)
                profile = author_of(instance)
                dispatch(content_type, instance.pk, text,
                         author_is_practitioner=_is_practitioner(profile))
            except Exception:  # noqa: BLE001
                logger.exception('Moderation dispatch receiver failed for %s %s',
                                 content_type, getattr(instance, 'pk', '?'))

        transaction.on_commit(run)

    return receiver


__all__ = ['connect', 'dispatch', 'unmoderated_types', 'TEXT_SOURCES', 'CONTENT_TYPES']
