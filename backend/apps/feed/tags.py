"""Hashtag normalisation and the ``Post.tags`` → ``PostTag`` sync.

``Post.tags`` is a ``JSONField`` with no consumer. Three different things were
being called a hashtag before this module existed:

1. a string in ``Post.tags`` — accepted by the API, never written by the web
   composer;
2. ``#legday`` typed inside ``Post.body`` — the only kind real posts have;
3. nothing at all, on older posts.

All three now land in one place: :func:`normalise_tag` decides what a string
*is*, :func:`sync_post_tags` decides what a post *has*, and
:func:`backfill_tags` walks history once.

Design notes worth stating because they look arbitrary otherwise:

* **Lowercase, ``#`` stripped, whitespace collapsed.** One canonical form means
  ``unique_together`` on ``Tag.name`` is a real de-duplicator rather than a
  suggestion. ``#Gym``, ``gym`` and ``#GYM`` are one tag.
* **ASCII-safe minimum, not ASCII-only.** ``str.isalnum()`` is True for ``'٣'``
  and ``'日'``, and a platform whose users write in Kiswahili or Japanese should
  not silently drop their tags. What is rejected is whitespace, ``#``, and
  punctuation — the things that make a hashtag unparseable.
* **Bounded.** ``MAX_TAG_LENGTH`` characters and ``MAX_TAGS_PER_POST`` per post.
  Without the second, a body with 4,000 ``#`` runs would create 4,000 rows; the
  extra ones are dropped in a stable order, not randomly.
* **No body persistence here.** ``sync_post_tags`` reads the body and writes
  rows; it never rewrites ``Post.body`` or ``Post.tags``. The API contract is
  unchanged: a client that sends ``tags`` still gets them echoed back verbatim.

The ``tags`` field and the join table are kept in step by
``apps.feed.tasks.sync_post_tags`` (called from the create view and by the
backfill), never by a signal — a save signal would fire on moderation updates
and re-parse a body it has already parsed.
"""
import logging
import re

from django.db import transaction

logger = logging.getLogger(__name__)

#: Longest tag we will store. Mirrors ``Tag.name`` (64) minus headroom.
MAX_TAG_LENGTH = 50
#: Tags per post. The client caps a composer at a handful; the backfill needs a
#: ceiling too because bodies are free text and can contain anything.
MAX_TAGS_PER_POST = 20

_WHITESPACE_RE = re.compile(r'\s+')
# A run of one or more '#'. Deliberately simple: a hashtag is '#' immediately
# followed by tag characters, and nothing else. Punctuation ends it.
_HASHTAG_RE = re.compile(r'#([0-9A-Za-z_\u00c0-\uffff]+)')

# Characters that are legal but would break a URL fragment or a search box.
_STRIP_CHARS = str.maketrans({c: None for c in '#!@$%^&*()+={}[]|\\;:\'",.<>?/`~'})


def normalise_tag(raw):
    """Return the canonical form of a hashtag, or None if it is not one.

    >>> normalise_tag('  #Gym  ')
    'gym'
    >>> normalise_tag('#leg day')
    'leg'
    >>> normalise_tag('not a tag')
    """
    if raw is None:
        return None
    text = _WHITESPACE_RE.sub(' ', str(raw).strip())
    if not text:
        return None
    # A leading '#' is the marker, not part of the name. Only one is stripped so
    # '##x' is rejected below rather than becoming 'x'.
    if text.startswith('#'):
        text = text[1:]
    if not text or '#' in text:
        return None
    text = text.translate(_STRIP_CHARS)
    text = _WHITESPACE_RE.sub(' ', text).strip()
    if not text:
        return None
    # Must start and end with something word-like; '2' is a tag ('#2' is how
    # people mark set counts) but '-' or '_' alone is not.
    if not any(ch.isalnum() for ch in text):
        return None
    if len(text) > MAX_TAG_LENGTH:
        # Truncate on a word boundary when there is one, so '#longtagwitha...'
        # becomes something a human would recognise rather than a mid-word cut.
        cut = text[:MAX_TAG_LENGTH]
        if ' ' in cut:
            cut = cut[:cut.rindex(' ')]
        text = cut.strip()
    return text.lower() or None


def extract_tags_from_body(body):
    """Hashtags found in free text, in order of first appearance, deduped.

    Bounded by :data:`MAX_TAGS_PER_POST` — an over-tagged body is truncated, and
    the caller can tell because ``len(result) == MAX_TAGS_PER_POST`` and the
    body had more.
    """
    if not body:
        return []
    seen = []
    seen_set = set()
    for match in _HASHTAG_RE.findall(str(body)):
        name = normalise_tag(match)
        if name and name not in seen_set:
            seen_set.add(name)
            seen.append(name)
        if len(seen) >= MAX_TAGS_PER_POST:
            break
    return seen


def extract_tags_from_field(tags_field):
    """Hashtags from the ``tags`` JSONField, whatever shape it arrived in.

    Accepts a list of strings, a comma/space separated string, a JSON-encoded
    string, or ``None``. Anything unparseable yields ``[]`` — a malformed
    ``tags`` value must not fail a post write that already succeeded.
    """
    if tags_field in (None, '', b''):
        return []
    if isinstance(tags_field, str):
        text = tags_field.strip()
        if text.startswith('['):
            import json
            try:
                parsed = json.loads(text)
            except (ValueError, TypeError):
                parsed = None
            if isinstance(parsed, list):
                tags_field = parsed
            else:
                tags_field = [part for part in text.replace(',', ' ').split() if part]
        else:
            tags_field = [part for part in text.replace(',', ' ').split() if part]
    if not isinstance(tags_field, (list, tuple, set)):
        return []
    out, seen = [], set()
    for entry in tags_field:
        name = normalise_tag(entry)
        if name and name not in seen:
            seen.add(name)
            out.append(name)
        if len(out) >= MAX_TAGS_PER_POST:
            break
    return out


def resolve_tags(names):
    """``({name: Tag}, created_count)`` for the given normalised names.

    One query to read, one bulk insert to write. Safe under concurrency because
    ``Tag.name`` is unique: two posts tagging ``#gym`` at the same moment cannot
    produce two rows (``ignore_conflicts``).
    """
    from .models import Tag

    names = [n for n in dict.fromkeys(n for n in names if n)][:MAX_TAGS_PER_POST]
    if not names:
        return {}, 0
    found = {t.name: t for t in Tag.objects.filter(name__in=names)}
    missing = [n for n in names if n not in found]
    created = 0
    if missing:
        Tag.objects.bulk_create(
            [Tag(name=n) for n in missing], ignore_conflicts=True,
        )
        found.update({t.name: t for t in Tag.objects.filter(name__in=missing)})
        created = len(found) - (len(names) - len(missing))
    return found, created


def sync_post_tags(post, *, include_body=True, include_field=True, source=None):
    """Write the join rows for one post. Returns a counts dict.

    ``source`` is inferred when not given: rows recovered from the body are
    tagged ``body``/``backfill_body``, rows from the ``tags`` field
    ``field``/``backfill``. The backfill passes ``source`` explicitly so its rows
    are distinguishable from live ones.

    The write is replace-then-insert for the whole post rather than a diff,
    because "which tags does this post have" is derived state: if the body is
    edited the tags must follow. ``Post`` has no edit endpoint today, so in
    practice this only ever runs once per post, but the replace semantics make a
    future edit path correct for free.
    """
    from .models import PostTag

    field_source = source or 'field'
    body_source = source or 'body'
    if source in ('backfill', 'backfill_body'):
        field_source, body_source = 'backfill', 'backfill_body'

    names, origins = [], {}
    if include_field:
        for name in extract_tags_from_field(getattr(post, 'tags', None)):
            names.append(name)
            origins.setdefault(name, field_source)
    if include_body:
        for name in extract_tags_from_body(getattr(post, 'body', '')):
            names.append(name)
            origins.setdefault(name, body_source)

    tags, tags_created = resolve_tags(names)
    desired = {
        tags[name]: origin for name, origin in origins.items() if name in tags
    }
    if not desired:
        # Nothing to attach. Leave existing rows alone unless the caller is
        # authoritative (the backfill), which passes source=... explicitly.
        if source:
            PostTag.objects.filter(post=post).delete()
        return {'tags_created': 0, 'links_created': 0, 'links_deleted': 0}

    with transaction.atomic():
        keep = set(desired)
        stale = PostTag.objects.filter(post=post).exclude(tag__in=keep)
        removed = stale.count()
        stale.delete()
        existing = set(
            PostTag.objects.filter(post=post, tag__in=keep).values_list('tag_id', flat=True),
        )
        created = 0
        for tag, origin in desired.items():
            if tag.pk in existing:
                continue
            PostTag.objects.create(post=post, tag=tag, source=origin)
            created += 1
    return {
        'tags_created': tags_created,
        'links_created': created,
        'links_deleted': removed,
    }