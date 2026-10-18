"""Backfill ``ModerationReport.content_type`` / ``content_id`` from ``content_url``.

Reports used to carry nothing but a free-text ``content_url``, which made
"show me every reported community" unexpressible -- there was no type to filter
on and no id to open. Existing rows have to keep working, so the path is parsed
once here.

Paths we recognise are the ones the clients actually send. Anything unrecognised
is left blank rather than guessed: a wrong content_type would make a report
appear under a filter it does not belong to, which is worse than appearing under
none.
"""

from django.db import migrations


#: ``(content_type, [path fragments])`` in priority order. Longest/most specific
#: first, because ``/feed/`` and ``/feed/:id`` both start with ``/feed``.
_KNOWN_PATHS = [
    ('feed.post', ['/feed/post/', '/feed/posts/']),
    ('profiles.buddy_search_profile', ['/buddies/find/']),
    ('user.profile', ['/profile/']),
    ('marketplace.event', ['/marketplace/events/']),
    ('marketplace.product', ['/marketplace/products/']),
    ('marketplace.meal_plan', ['/marketplace/meal-plans/']),
    ('marketplace.programme', ['/marketplace/programmes/']),
    ('messaging.community', ['/communities/']),
]

#: Client paths of this shape carry no object id after them.
_ID_LESS = {'feed.post'}


def _split_path(url):
    """Return ``(content_type, content_id)`` for a stored URL, or ``(None, None)``."""
    if not url:
        return None, None
    # Strip scheme/host so both absolute and relative paths parse.
    path = url
    if '://' in path:
        path = '/' + path.split('://', 1)[1].split('/', 1)[1] if '/' in path.split('://', 1)[1] else '/'
    for content_type, fragments in _KNOWN_PATHS:
        for fragment in fragments:
            if fragment in path:
                tail = path.split(fragment, 1)[1].split('?', 1)[0].split('#', 1)[0].strip('/')
                if not tail and content_type not in _ID_LESS:
                    return content_type, ''
                return content_type, tail
    return None, None


def forwards(apps, schema_editor):
    Report = apps.get_model('moderation', 'ModerationReport')
    db_alias = schema_editor.connection.alias
    pending = Report.objects.using(db_alias).filter(content_type='').exclude(content_url='')
    updates = []
    for report in pending.iterator(chunk_size=500):
        content_type, content_id = _split_path(report.content_url)
        if content_type:
            report.content_type = content_type
            report.content_id = content_id
            updates.append(report)
        if len(updates) >= 500:
            Report.objects.using(db_alias).bulk_update(updates, ['content_type', 'content_id'])
            updates = []
    if updates:
        Report.objects.using(db_alias).bulk_update(updates, ['content_type', 'content_id'])


def backwards(apps, schema_editor):
    """Nothing to undo: the new columns are additive and the old URL is intact."""


class Migration(migrations.Migration):
    dependencies = [
        ('moderation', '0007_contenttakedown_moderationreport_content_id_and_more'),
    ]

    operations = [
        migrations.RunPython(forwards, backwards),
    ]
