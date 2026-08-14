from django.db import migrations, models


def dedupe_live_attendees(apps, schema_editor):
    """Keep the most recent attendee row per (live, user); drop older duplicates.

    LiveAttendee previously had no uniqueness constraint, so rapid re-joins could
    create duplicate rows and crash `update_or_create` with MultipleObjectsReturned.
    """
    LiveAttendee = apps.get_model('lives', 'LiveAttendee')
    seen = set()
    to_delete = []
    # Oldest first so the surviving row is the most recent join.
    for attendee in LiveAttendee.objects.all().order_by('joined_at', 'id'):
        key = (attendee.live_id, attendee.user_id)
        if key in seen:
            to_delete.append(attendee.pk)
        else:
            seen.add(key)
    if to_delete:
        LiveAttendee.objects.filter(pk__in=to_delete).delete()


class Migration(migrations.Migration):

    dependencies = [
        ('lives', '0008_buddylive_content_rating'),
    ]

    operations = [
        migrations.RunPython(dedupe_live_attendees, migrations.RunPython.noop),
        migrations.AlterUniqueTogether(
            name='liveattendee',
            unique_together={('live', 'user')},
        ),
    ]
