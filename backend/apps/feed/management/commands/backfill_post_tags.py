"""Recover hashtags from existing posts.

Why a command and not a data migration: this walks every post body and writes
rows whose correctness depends on runtime code (``apps.feed.tags``). A migration
freezes that code forever — the next fix to the parser could never reach the
backfilled rows, and a migration that parses a million rows holds a transaction
open for the length of it. The command is idempotent (``unique(post, tag)`` plus
a replace-per-post write) so it can be re-run as often as you like.

Usage::

    python manage.py backfill_post_tags                  # every post
    python manage.py backfill_post_tags --batch 500
    python manage.py backfill_post_tags --since 2026-01-01
    python manage.py backfill_post_tags --dry-run

It reports, separately, how many links came from the ``tags`` JSONField and how
many were recovered from the post body, because those are different claims: the
first is data that existed and was never indexed, the second is a guess about
what a human typed.
"""
import time

from django.core.management.base import BaseCommand
from django.db.models import Count, Q

from apps.feed.models import Post, PostTag, Tag
from apps.feed.tags import extract_tags_from_body, extract_tags_from_field, resolve_tags


class Command(BaseCommand):
    help = 'Populate feed.Tag / feed.PostTag from Post.tags and post bodies.'

    def add_arguments(self, parser):
        parser.add_argument(
            '--batch', type=int, default=200,
            help='Rows per query (default 200). Keeps the working set small.',
        )
        parser.add_argument(
            '--since', default='',
            help='Only posts created on/after this YYYY-MM-DD date.',
        )
        parser.add_argument(
            '--dry-run', action='store_true',
            help='Report what would be written without writing.',
        )

    def handle(self, *args, **options):
        batch = max(1, int(options['batch']))
        dry_run = bool(options['dry_run'])
        qs = Post.objects.all().order_by('created_at', 'id')
        if options['since']:
            qs = qs.filter(created_at__date__gte=options['since'])

        started = time.monotonic()
        posts = 0
        posts_with_tags = 0
        from_field = 0     # links recovered from Post.tags
        from_body = 0      # links only recoverable by parsing Post.body
        tags_before = Tag.objects.count()
        links_before = PostTag.objects.count()

        # Keyset pagination on (created_at, id): offset pagination would re-walk
        # the same rows as the table grows underneath it.
        cursor = None
        while True:
            page = qs if cursor is None else qs.filter(cursor_q(cursor))
            batch_rows = list(page[:batch])
            if not batch_rows:
                break
            for post in batch_rows:
                posts += 1
                field_names = extract_tags_from_field(post.tags)
                body_names = extract_tags_from_body(post.body)
                field_set = set(field_names)
                if field_names or body_names:
                    posts_with_tags += 1
                from_field += len(field_names)
                from_body += len([n for n in body_names if n not in field_set])
                if not dry_run:
                    _write(post, field_names, body_names)
            cursor = (batch_rows[-1].created_at, batch_rows[-1].id)

        elapsed = time.monotonic() - started
        summary = (
            f'posts scanned={posts} with_tags={posts_with_tags} '
            f'links_from_tags_field={from_field} links_recovered_from_body={from_body}'
        )
        if dry_run:
            self.stdout.write(f'[dry-run] {summary} in {elapsed:.1f}s')
            return

        tags_after = Tag.objects.count()
        links_after = PostTag.objects.count()
        self.stdout.write(
            f'{summary} in {elapsed:.1f}s | '
            f'Tag rows {tags_before} -> {tags_after} (+{tags_after - tags_before}) | '
            f'PostTag rows {links_before} -> {links_after} (+{links_after - links_before})'
        )
        self.stdout.write(str(PostTag.objects.aggregate(
            field=Count('id', filter=Q(source='field')),
            body=Count('id', filter=Q(source='body')),
            backfill_field=Count('id', filter=Q(source='backfill')),
            backfill_body=Count('id', filter=Q(source='backfill_body')),
        )))
        self.stdout.write(str(Tag.objects.aggregate(total=Count('id'))))


def cursor_q(cursor):
    created_at, pk = cursor
    return Q(created_at__gt=created_at) | Q(created_at=created_at, id__gt=pk)


def _write(post, field_names, body_names):
    """Attach the tags, recording which source each association came from.

    Replace-per-post, so re-running converges. ``unique(post, tag)`` plus
    ``ignore_conflicts`` makes the insert safe even if two runs overlap.
    """
    names = list(dict.fromkeys(field_names + body_names))
    tags, _ = resolve_tags(names)
    if not tags:
        PostTag.objects.filter(post=post).delete()
        return
    field_set = set(field_names)
    keep = {
        tags[name]: ('backfill' if name in field_set else 'backfill_body')
        for name in names
    }
    PostTag.objects.filter(post=post).exclude(tag__in=list(keep)).delete()
    existing = set(PostTag.objects.filter(post=post).values_list('tag_id', flat=True))
    PostTag.objects.bulk_create(
        [
            PostTag(post=post, tag=tag, source=source)
            for tag, source in keep.items()
            if tag.pk not in existing
        ],
        ignore_conflicts=True,
    )