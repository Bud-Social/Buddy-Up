"""Content takedown: one table describing how each content type is hidden.

The old implementation was a single ``if ct == 'feed.post'`` wrapped in
``except Exception: pass``. That combination was the whole bug: a takedown that
raised — a typo'd id, a dropped column, a database blip — looked exactly like a
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
* **Remove and restore are declared together.** ``reversible`` is data, not a
  guess, so the reversal endpoint can honestly say "this cannot be undone"
  instead of silently half-restoring something.

Three of the seven types (``feed.comment``, ``gyms.schedule_post``,
``messaging.community_post``) have no state column in their owning app and no
soft-delete mixin; each app's own delete path hard-deletes the row. Those are
registered with ``reversible=False`` and the removal says so out loud. The
other four carry a real marker column and round-trip.

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
    """How one content type is removed, restored, and attributed.

    Subclasses only implement the three verbs. ``remove`` / ``restore`` return a
    human-readable description of the write they performed; that string is what
    the API hands back so the moderator sees *what happened* rather than a
    generic "done".
    """

    content_type = ''
    label = ''
    #: False when the owning app hard-deletes the row, so there is nothing to
    #: put back. Surfaced by the reversal endpoint as a 409.
    reversible = True

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

    def remove_by_id(self, content_id):
        obj = self.get_object(content_id)
        # Resolved BEFORE the removal: for the hard-deleting types the row is
        # gone a line later, and the responsible user is exactly who the
        # notification has to go to.
        try:
            author = self.get_author(obj)
        except Exception:  # noqa: BLE001
            logger.exception('Could not resolve the author of %s %s',
                             self.content_type, content_id)
            author = None
        description = self.remove(obj)
        return author, description

    def restore_by_id(self, content_id):
        if not self.reversible:
            raise ContentTakedownError(
                f'{self.label} has no reversible state — the owning app deletes '
                'the row outright, so a takedown of this type cannot be undone.'
            )
        obj = self.get_object(content_id)
        return obj, self.restore(obj)


class FeedPostHandler(ContentHandler):
    content_type = 'feed.post'
    label = 'Feed post'

    def get_queryset(self):
        from apps.feed.models import Post
        # The base manager, deliberately: FeedPost/GymPost are proxies that
        # filter on gym_tag, and a takedown must never silently skip a post
        # because it was tagged to a gym.
        return Post.objects.all()

    def get_author(self, obj):
        return obj.author.user

    def remove(self, obj):
        return self._update(obj, 'post hidden from the feed (moderation_status=removed)',
                            moderation_status='removed')

    def restore(self, obj):
        return self._update(obj, 'post restored to the feed (moderation_status=clean)',
                            moderation_status='clean')


class FeedCommentHandler(ContentHandler):
    content_type = 'feed.comment'
    label = 'Feed comment'
    reversible = False

    def get_queryset(self):
        from apps.feed.models import Comment
        return Comment.objects.all()

    def get_author(self, obj):
        return obj.author.user

    def remove(self, obj):
        author = obj.author.user_id
        # Matches ``feed.views.CommentDetailView.delete``: the owning app's own
        # semantics for "this comment is gone". Replies and reactions cascade,
        # which is correct — a removed comment does not leave its replies
        # standing in a hole.
        self.get_queryset().filter(pk=obj.pk).delete()
        return f'comment deleted (author {author}); this type cannot be restored'

    def restore(self, obj):  # pragma: no cover - guarded by reversible=False
        raise ContentTakedownError('Comments are hard-deleted and cannot be restored.')


class MarketplaceProductHandler(ContentHandler):
    content_type = 'marketplace.product'
    label = 'Marketplace product'

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

    def remove(self, obj):
        return self._update(obj, 'product delisted (is_active=False)', is_active=False)

    def restore(self, obj):
        return self._update(obj, 'product relisted (is_active=True)', is_active=True)


class GymHandler(ContentHandler):
    content_type = 'gym'
    label = 'Gym'

    def get_queryset(self):
        from apps.gyms.models import Gym
        return Gym.objects.all()

    def get_author(self, obj):
        membership = obj.memberships.filter(role__in=('owner', 'co_owner')).order_by('pk').first()
        return membership.member.user if membership else None

    def remove(self, obj):
        # Gym has no `is_active`; SoftDeleteModel is this repo's "deactivate"
        # idiom and every gym listing filters it out.
        return self._update(
            obj, 'gym soft-deleted (is_deleted=True)',
            is_deleted=True, deleted_at=timezone.now(),
        )

    def restore(self, obj):
        return self._update(obj, 'gym restored (is_deleted=False)',
                            is_deleted=False, deleted_at=None)


class GymSchedulePostHandler(ContentHandler):
    content_type = 'gyms.schedule_post'
    label = 'Gym schedule post'
    reversible = False

    def get_queryset(self):
        from apps.gyms.models import GymSchedulePost
        return GymSchedulePost.objects.all()

    def get_author(self, obj):
        return obj.author.user

    def remove(self, obj):
        # ``GymSchedulePostDetailView.delete`` hard-deletes; so does moderation.
        author = obj.author.user_id
        self.get_queryset().filter(pk=obj.pk).delete()
        return f'schedule post deleted (author {author}); this type cannot be restored'

    def restore(self, obj):  # pragma: no cover - guarded by reversible=False
        raise ContentTakedownError('Gym schedule posts are hard-deleted and cannot be restored.')


class CommunityPostHandler(ContentHandler):
    content_type = 'messaging.community_post'
    label = 'Community post'
    reversible = False

    def get_queryset(self):
        from apps.messaging.models import CommunityPost
        return CommunityPost.objects.all()

    def get_author(self, obj):
        return obj.author.user

    def remove(self, obj):
        author = obj.author.user_id
        self.get_queryset().filter(pk=obj.pk).delete()
        return f'community post deleted (author {author}); this type cannot be restored'

    def restore(self, obj):  # pragma: no cover - guarded by reversible=False
        raise ContentTakedownError('Community posts are hard-deleted and cannot be restored.')


class MarketplaceEventHandler(ContentHandler):
    content_type = 'marketplace.event'
    label = 'Marketplace event'

    def get_queryset(self):
        from apps.marketplace.models import MarketplaceEvent
        return MarketplaceEvent.objects.all()

    def get_author(self, obj):
        return obj.creator.user

    def remove(self, obj):
        # `is_published` is the marketplace's own visibility switch; event
        # listings and detail reads both gate on it, so this is a real takedown
        # rather than a marker nobody reads.
        return self._update(obj, 'event unpublished (is_published=False)', is_published=False)

    def restore(self, obj):
        return self._update(obj, 'event re-published (is_published=True)', is_published=True)


_HANDLERS = [
    FeedPostHandler(),
    FeedCommentHandler(),
    MarketplaceProductHandler(),
    GymHandler(),
    GymSchedulePostHandler(),
    CommunityPostHandler(),
    MarketplaceEventHandler(),
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


def remove_content(content_type, content_id):
    """Remove content. Returns ``(author, description)``.

    Raises on anything that goes wrong. A caller that catches
    ``ContentTakedownError`` must not record the flag as actioned.
    """
    handler = get_handler(content_type)
    return handler.remove_by_id(content_id)


def restore_content(content_type, content_id):
    handler = get_handler(content_type)
    _, description = handler.restore_by_id(content_id)
    return description


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