"""Content takedown: a registry describing how each content type is hidden.

The old implementation was a single ``if ct == 'feed.post'`` wrapped in
``except Exception: pass``. That combination was the whole bug: a takedown that
raised -- a typo'd id, a dropped column, a database blip -- looked exactly like a
takedown that succeeded, and the flag was still recorded as ``is_actioned=True``.
The moderator's queue said "handled", the content stayed up, and nobody found
out until a user screenshotted it.

So this module inverts the shape:

* **A registry, not an ``if`` chain.** Adding a content type is a new entry, and
  an unknown type is a loud ``UnsupportedContentType`` rather than a no-op that
  reports success.
* **Nothing is swallowed.** Every failure mode raises ``ContentTakedownError``
  with the content type and id in the message, and the caller is expected to
  leave ``is_actioned`` alone.
* **Removal is visibility, not deletion.** A takedown writes a
  ``ContentTakedown`` row; it does not delete the underlying content. Staff and
  the creator keep seeing it, everyone else gets a tombstone, and the content is
  deleted only after the appeal window closes -- see
  ``apps.moderation.tasks.purge_expired_takedowns``.

That last point replaced the old per-type behaviour. Three types used to be
registered ``reversible=False`` because their owning app hard-deletes the row:
comments, gym schedule posts and community posts. A moderator pressing Remove on
a comment destroyed it and its replies, with nothing to appeal against. They are
now reversible like everything else, and the real delete happens later, through
the retention task, where it is auditable.

Model imports are lazy, per handler, on purpose: moderation is loaded during
Django app population and five other apps' model modules import this one
transitively. Importing them here at module scope would close that loop.
"""
import logging

from django.utils import timezone

logger = logging.getLogger(__name__)


class ContentTakedownError(Exception):
    """A takedown could not be completed. Never caught and ignored."""


class UnsupportedContentType(ContentTakedownError):
    """No handler is registered for this ``ContentFlag.content_type``."""


class ContentNotFound(ContentTakedownError):
    """The row named by the flag does not exist."""


class ContentHandler:
    """How one content type is taken down, lifted, and attributed.

    Subclasses implement the two verbs' *content* side only -- what to look up,
    and who is responsible. Hiding and unhiding are handled once, in this base
    class, against the shared ``ContentTakedown`` table, so every type gets
    identical semantics and an identical 90-day appeal window.

    A subclass may additionally set ``on_remove`` / ``on_restore`` to flip a
    marker its own read paths already filter on. That is a deliberate
    denormalisation -- the authoritative record is the ``ContentTakedown`` row --
    and it exists only where the alternative is rewriting a hot query as a join.
    """

    content_type = ''
    label = ''
    #: False only for a type whose own app cannot even be read back, so that
    #: there is nothing to hide and nothing to restore. Every currently
    #: registered type is reversible.
    reversible = True
    #: Optional extra write on removal, for apps whose listings already filter a
    #: marker column (the feed does, on ``moderation_status``).
    on_remove = None
    on_restore = None

    def get_queryset(self):
        raise NotImplementedError

    def get_object(self, content_id):
        obj = self.get_queryset().filter(pk=content_id).first()
        if obj is None:
            raise ContentNotFound(
                f'{self.content_type} {content_id} does not exist; nothing was removed.'
            )
        return obj

    def get_author(self, obj):
        """The responsible ``User``, or None when the type has no single author."""
        raise NotImplementedError

    def get_creator(self, obj):
        """The responsible ``Profile``, used for the "creator still sees it" rule.

        Defaults to the author's own profile, which is right for nearly every
        type; override where responsibility sits with a shop or a gym rather than
        a person.
        """
        author = self.get_author(obj)
        return getattr(author, 'profile', None)

    def remove(self, obj):
        raise NotImplementedError

    def restore(self, obj):
        raise NotImplementedError

    # -- shared plumbing ---------------------------------------------------

    def _update(self, obj, description, **fields):
        """Apply ``fields`` and refuse to claim success on a zero-row write."""
        affected = self.get_queryset().filter(pk=obj.pk).update(**fields)
        if not affected:
            raise ContentNotFound(
                f'{self.content_type} {obj.pk} vanished before the update landed; '
                'nothing was removed.'
            )
        for name, value in fields.items():
            setattr(obj, name, value)
        return description

    def remove_by_id(self, content_id, *, reason='policy_violation', public_note='',
                      moderator=None, action=None):
        obj = self.get_object(content_id)
        from apps.moderation.models import ContentTakedown

        creator = None
        try:
            creator = self.get_creator(obj)
        except Exception:  # noqa: BLE001
            # Attribution is best-effort. A creator we cannot resolve must not
            # stop the takedown -- but it does mean the row keeps no creator and
            # the "author still sees it" rule cannot apply, so log it loudly.
            logger.exception('Could not resolve the creator of %s %s',
                             self.content_type, content_id)

        takedown = ContentTakedown.objects.create(
            content_type=self.content_type,
            content_id=str(obj.pk),
            reason=reason,
            public_note=(public_note or '')[:500],
            taken_down_at=timezone.now(),
            creator=creator,
            action=action,
        )
        takedown.schedule_purge()
        takedown.save(update_fields=['purge_after'])

        if self.on_remove:
            self._update(obj, self.on_remove[0], **self.on_remove[1])

        description = (
            f'{self.label.lower()} hidden from other members (takedown #{takedown.id}); '
            f'still visible to staff and the creator, appealable until '
            f'{takedown.purge_after:%Y-%m-%d}'
        )
        return obj, takedown, description

    def restore_by_id(self, content_id, *, lift_reason=''):
        if not self.reversible:
            raise ContentTakedownError(
                f'{self.label} has no reversible state and cannot be restored.'
            )
        from apps.moderation.models import ContentTakedown

        obj = self.get_object(content_id)
        takedown = (
            ContentTakedown.objects
            .filter(content_type=self.content_type, content_id=str(obj.pk),
                    lifted_at__isnull=True, purged_at__isnull=True)
            .order_by('-taken_down_at')
            .first()
        )
        if takedown is None:
            raise ContentTakedownError(
                f'{self.content_type} {content_id} has no standing takedown, so there '
                'is nothing to restore.'
            )
        takedown.lifted_at = timezone.now()
        takedown.lift_reason = (lift_reason or 'restored')[:100]
        takedown.save(update_fields=['lifted_at', 'lift_reason', 'updated_at'])

        if self.on_restore:
            self._update(obj, self.on_restore[0], **self.on_restore[1])

        return obj, f'{self.label.lower()} restored and visible to everyone again'


class FeedPostHandler(ContentHandler):
    content_type = 'feed.post'
    label = 'Feed post'
    # The feed filters `moderation_status='clean'` on every listing. Rewriting
    # those as joins against the takedown table would put a row-level lookup on
    # the hottest query in the app, so the marker stays as a denormalised index
    # of the authoritative ContentTakedown row. Both are written together here
    # and cleared together in restore_by_id.
    on_remove = ('post marked removed (moderation_status=removed)',
                 {'moderation_status': 'removed'})
    on_restore = ('post marked clean again (moderation_status=clean)',
                  {'moderation_status': 'clean'})

    def get_queryset(self):
        from apps.feed.models import Post
        # The base manager, deliberately: FeedPost/GymPost are proxies that
        # filter on gym_tag, and a takedown must never silently skip a post
        # because it was tagged to a gym.
        return Post.objects.all()

    def get_author(self, obj):
        return obj.author.user

    def get_creator(self, obj):
        return obj.author


class FeedCommentHandler(ContentHandler):
    content_type = 'feed.comment'
    label = 'Feed comment'
    # Previously reversible=False: this hard-deleted the row, taking replies and
    # reactions with it. A moderator pressing Remove destroyed the evidence an
    # appeal would be argued from.
    #
    # Comment has no soft-delete column, and giving it one would change what
    # "delete my comment" means to the person who pressed it. So the takedown
    # table is the whole state here, and apps.feed's comment reads filter
    # against it.

    def get_queryset(self):
        from apps.feed.models import Comment
        return Comment.objects.all()

    def get_author(self, obj):
        return obj.author.user

    def get_creator(self, obj):
        return obj.author


class MarketplaceProductHandler(ContentHandler):
    content_type = 'marketplace.product'
    label = 'Marketplace product'
    # Product has no moderation column, so the takedown table is the only state.
    # `is_active` is the shop's own commercial switch and is deliberately NOT
    # touched: delisting someone's product as a side effect of moderation would
    # destroy a business signal that means something else.
    def get_queryset(self):
        from apps.marketplace.models import Product
        return Product.objects.all()

    def get_author(self, obj):
        if obj.recommended_by_id:
            return obj.recommended_by.user
        # A shop-listed product has no `author`; the nearest responsible party is
        # whoever owns the shop. Ordered by pk so the answer is stable when a
        # shop has two owners.
        membership = obj.shop.memberships.filter(role__in=('owner', 'manager')).order_by('pk').first() \
            if obj.shop_id else None
        return membership.profile.user if membership else None

    def get_creator(self, obj):
        if obj.recommended_by_id:
            return obj.recommended_by
        membership = obj.shop.memberships.filter(role__in=('owner', 'manager')).order_by('pk').first() \
            if obj.shop_id else None
        return membership.profile if membership else None


class MarketplaceMealPlanHandler(ContentHandler):
    content_type = 'marketplace.meal_plan'
    label = 'Meal plan'

    def get_queryset(self):
        from apps.marketplace.models import MealPlan
        return MealPlan.objects.all()

    def get_author(self, obj):
        return obj.creator.user

    def get_creator(self, obj):
        return obj.creator


class MarketplaceProgrammeHandler(ContentHandler):
    content_type = 'marketplace.programme'
    label = 'Training programme'

    def get_queryset(self):
        from apps.marketplace.models import TrainingProgramme
        return TrainingProgramme.objects.all()

    def get_author(self, obj):
        return obj.creator.user

    def get_creator(self, obj):
        return obj.creator


class MarketplaceEventHandler(ContentHandler):
    content_type = 'marketplace.event'
    label = 'Marketplace event'
    # `is_published` is the marketplace's own visibility switch and event
    # listings gate on it, so it is a real marker -- unlike a product's
    # `is_active`, unpublishing is exactly what "hidden" means for an event.
    on_remove = ('event unpublished (is_published=False)', {'is_published': False})
    on_restore = ('event published again (is_published=True)', {'is_published': True})

    def get_queryset(self):
        from apps.marketplace.models import MarketplaceEvent
        return MarketplaceEvent.objects.all()

    def get_author(self, obj):
        return obj.creator.user

    def get_creator(self, obj):
        return obj.creator


class GymHandler(ContentHandler):
    content_type = 'gym'
    label = 'Gym'
    on_remove = ('gym soft-deleted (is_deleted=True)',
                 {'is_deleted': True, 'deleted_at': timezone.now()})
    on_restore = ('gym restored (is_deleted=False)',
                  {'is_deleted': False, 'deleted_at': None})

    def get_queryset(self):
        from apps.gyms.models import Gym
        return Gym.objects.all()

    def get_author(self, obj):
        membership = obj.memberships.filter(role__in=('owner', 'co_owner')).order_by('pk').first()
        return membership.member.user if membership else None

    def get_creator(self, obj):
        membership = obj.memberships.filter(role__in=('owner', 'co_owner')).order_by('pk').first()
        return membership.member if membership else None


class GymRoutinePostHandler(ContentHandler):
    content_type = 'gyms.routine_post'
    label = 'Gym schedule post'
    # Previously reversible=False: the gym app's own delete hard-deletes the
    # row. Hidden now instead, so a takedown can be lifted. No soft-delete
    # column on this model, so the takedown table is the whole state.

    def get_queryset(self):
        from apps.gyms.models import GymRoutinePost
        return GymRoutinePost.objects.all()

    def get_author(self, obj):
        return obj.author.user

    def get_creator(self, obj):
        return obj.author


class CommunityPostHandler(ContentHandler):
    content_type = 'messaging.community_post'
    label = 'Community post'
    # Previously reversible=False for the same reason as the two above. No
    # soft-delete column here either, so the takedown table is the whole state.

    def get_queryset(self):
        from apps.messaging.models import CommunityPost
        return CommunityPost.objects.all()

    def get_author(self, obj):
        return obj.author.user

    def get_creator(self, obj):
        return obj.author


class CommunityHandler(ContentHandler):
    content_type = 'messaging.community'
    label = 'Community'

    def get_queryset(self):
        from apps.messaging.models import Conversation
        return Conversation.objects.filter(is_community=True)

    def get_author(self, obj):
        membership = obj.memberships.filter(role__in=('owner', 'admin')).order_by('pk').first()
        return membership.profile.user if membership else None

    def get_creator(self, obj):
        membership = obj.memberships.filter(role__in=('owner', 'admin')).order_by('pk').first()
        return membership.profile if membership else None


class BuddyLiveHandler(ContentHandler):
    content_type = 'lives.buddy_live'
    label = 'Live'
    # BuddyLive has no moderation column and no soft-delete mixin -- `status` is
    # the broadcast lifecycle (scheduled/live/ended) and must not be repurposed.
    # The takedown table is the state; `apps.lives` read paths consult it.

    def get_queryset(self):
        from apps.lives.models import BuddyLive
        return BuddyLive.objects.all()

    def get_author(self, obj):
        return obj.host.user

    def get_creator(self, obj):
        return obj.host


class BookingSessionHandler(ContentHandler):
    content_type = 'sessions.booking'
    label = 'Session'
    # `status` is transactional (confirmed/cancelled/completed) and is not a
    # moderation signal.

    def get_queryset(self):
        from apps.sessions.models import BookingSession
        return BookingSession.objects.all()

    def get_author(self, obj):
        return obj.client.user

    def get_creator(self, obj):
        return obj.client


class TrainerProfileHandler(ContentHandler):
    content_type = 'sessions.trainer_profile'
    label = 'Trainer profile'

    def get_queryset(self):
        from apps.sessions.models import TrainerProfile
        return TrainerProfile.objects.all()

    def get_author(self, obj):
        return obj.user

    def get_creator(self, obj):
        return obj.profile


class AvailabilityHandler(ContentHandler):
    content_type = 'sessions.availability'
    label = 'Schedule slot'

    def get_queryset(self):
        from apps.sessions.models import Availability
        return Availability.objects.all()

    def get_author(self, obj):
        return obj.trainer.user

    def get_creator(self, obj):
        return obj.trainer


class ProfileHandler(ContentHandler):
    content_type = 'user.profile'
    label = 'Profile'

    def get_queryset(self):
        from apps.profiles.models import Profile
        return Profile.objects.all()

    def get_author(self, obj):
        return obj.user

    def get_creator(self, obj):
        return obj


class BuddySearchProfileHandler(ContentHandler):
    content_type = 'profiles.buddy_search_profile'
    label = 'Find-a-buddy profile'

    def get_queryset(self):
        from apps.profiles.models import BuddySearchProfile
        return BuddySearchProfile.objects.all()

    def get_author(self, obj):
        return obj.profile.user

    def get_creator(self, obj):
        return obj.profile


_HANDLERS = [
    FeedPostHandler(),
    FeedCommentHandler(),
    MarketplaceProductHandler(),
    MarketplaceMealPlanHandler(),
    MarketplaceProgrammeHandler(),
    MarketplaceEventHandler(),
    GymHandler(),
    GymRoutinePostHandler(),
    CommunityPostHandler(),
    CommunityHandler(),
    BuddyLiveHandler(),
    BookingSessionHandler(),
    TrainerProfileHandler(),
    AvailabilityHandler(),
    ProfileHandler(),
    BuddySearchProfileHandler(),
]

#: ``content_type`` -> handler. Public so the queue endpoint can tell a moderator
#: what is actually supported instead of discovering it by failing.
CONTENT_HANDLERS = {handler.content_type: handler for handler in _HANDLERS}

SUPPORTED_CONTENT_TYPES = tuple(sorted(CONTENT_HANDLERS))


def get_handler(content_type):
    """The handler for ``content_type``, or raise ``UnsupportedContentType``."""
    try:
        return CONTENT_HANDLERS[content_type]
    except KeyError:
        raise UnsupportedContentType(
            f'Content type {content_type!r} has no takedown handler. '
            f'Supported: {", ".join(SUPPORTED_CONTENT_TYPES)}.'
        )


def remove_content(content_type, content_id, *, reason='policy_violation',
                   public_note='', moderator=None, action=None):
    """Take content down. Returns ``(author, takedown, description)``.

    Raises on anything that goes wrong. A caller that catches
    ``ContentTakedownError`` must not record the flag as actioned.
    """
    handler = get_handler(content_type)
    obj, takedown, description = handler.remove_by_id(
        content_id, reason=reason, public_note=public_note,
        moderator=moderator, action=action,
    )
    try:
        author = handler.get_author(obj)
    except Exception:  # noqa: BLE001
        logger.exception('Could not resolve the author of %s %s', content_type, content_id)
        author = None
    return author, takedown, description


def restore_content(content_type, content_id, *, lift_reason=''):
    """Lift a standing takedown. Returns the description."""
    handler = get_handler(content_type)
    _, description = handler.restore_by_id(content_id, lift_reason=lift_reason)
    return description


def active_takedown_for(content_type, content_id):
    """The standing takedown on this content, or None."""
    from apps.moderation.models import ContentTakedown

    return (
        ContentTakedown.objects
        .filter(content_type=content_type, content_id=str(content_id),
                lifted_at__isnull=True, purged_at__isnull=True)
        .order_by('-taken_down_at')
        .first()
    )


def hard_delete_content(content_type, content_id):
    """Delete content outright. Only the retention task may call this.

    Separate from ``remove_content`` on purpose: an accidental call here is
    unrecoverable, and the appeal window is the thing standing between a
    moderator's bad morning and someone's deleted post.
    """
    handler = get_handler(content_type)
    obj = handler.get_object(content_id)
    handler.get_queryset().filter(pk=obj.pk).delete()
    return f'{handler.label.lower()} deleted permanently'


def clear_flag(content_type, content_id):
    """Undo the *flag* marker without undoing a takedown (the approve path).

    Only ``feed.post`` carries a reversible flag marker (``moderation_status``).
    For every other type a flag is a row in this app, not a column on the
    content, so there is nothing to clear on the content side — and saying so
    beats pretending a write happened.
    """
    if content_type != 'feed.post':
        return f'no flag marker on {content_type}; only the flag record was closed'
    from apps.feed.models import Post
    affected = Post.objects.filter(pk=content_id, moderation_status='flagged').update(
        moderation_status='clean',
    )
    if not affected:
        raise ContentTakedownError(
            f'Feed post {content_id} is not in the flagged state, so there is no '
            'flag marker to clear.'
        )
    return 'post flag cleared (moderation_status=clean)'


def resolve_content_author(content_type, content_id):
    """The ``User`` responsible for this content, or None.

    Used by the queue before a decision is taken, so a moderator can see who
    they are about to act against.
    """
    try:
        handler = get_handler(content_type)
        obj = handler.get_object(content_id)
        return handler.get_author(obj)
    except ContentTakedownError:
        return None
    except Exception:  # noqa: BLE001
        logger.exception('Could not resolve the author of %s %s', content_type, content_id)
        return None


def describe_registry():
    """Machine-readable summary for the queue endpoint."""
    return {
        ct: {
            'label': h.label,
            'reversible': h.reversible,
        }
        for ct, h in sorted(CONTENT_HANDLERS.items())
    }