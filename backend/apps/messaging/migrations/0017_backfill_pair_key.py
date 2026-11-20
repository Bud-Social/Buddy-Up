"""Backfill pair_key for 1:1 main/buddy conversations, collapse duplicates,
then add the uniqueness constraint."""

from django.db import migrations


def _pair_key_for(a_id, b_id):
    return '|'.join(sorted([str(a_id), str(b_id)]))


def backfill_and_dedupe(apps, schema_editor):
    Conversation = apps.get_model('messaging', 'Conversation')
    Message = apps.get_model('messaging', 'Message')
    ConversationMembership = apps.get_model('messaging', 'ConversationMembership')
    CallLog = apps.get_model('messaging', 'CallLog')
    CallSession = apps.get_model('messaging', 'CallSession')
    ConversationPromotion = apps.get_model('messaging', 'ConversationPromotion')
    CommunityPost = apps.get_model('messaging', 'CommunityPost')

    # Only 1:1 main/buddy conversations are eligible for dedup. Groups,
    # communities and gym threads keep whatever rows they have today.
    candidates = (
        Conversation.objects
        .filter(is_group=False, is_community=False, kind__in=['main', 'buddy'])
        .prefetch_related('participants')
    )

    # Compute keys and attach in memory first.
    entries = []
    for conv in candidates:
        participants = list(conv.participants.all())
        if len(participants) != 2:
            continue
        entries.append((_pair_key_for(participants[0].user_id, participants[1].user_id), conv))

    # Sort by (created_at) so the oldest conversation for each key wins.
    entries.sort(key=lambda item: (item[0], item[1].created_at))

    by_key = {}
    for key, conv in entries:
        by_key.setdefault(key, []).append(conv)

    for key, group in by_key.items():
        canonical = group[0]
        canonical.pair_key = key
        canonical.save(update_fields=['pair_key'])
        if len(group) == 1:
            continue
        for losing in group[1:]:
            Message.objects.filter(conversation=losing).update(conversation=canonical)
            # A member of both convs would violate unique_together on
            # (conversation, profile) after the move — drop the loser's copy.
            ConversationMembership.objects.filter(
                conversation=losing,
                profile__in=canonical.participants.all(),
            ).delete()
            ConversationMembership.objects.filter(conversation=losing).update(conversation=canonical)
            CallLog.objects.filter(conversation=losing).update(conversation=canonical)
            CallSession.objects.filter(conversation=losing).update(conversation=canonical)
            ConversationPromotion.objects.filter(conversation=losing).update(conversation=canonical)
            CommunityPost.objects.filter(conversation=losing).update(conversation=canonical)
            losing.delete()


def rollback_dedupe(apps, schema_editor):
    Conversation = apps.get_model('messaging', 'Conversation')
    Conversation.objects.all().update(pair_key='')


class Migration(migrations.Migration):

    dependencies = [
        ('messaging', '0016_add_pair_key'),
    ]

    operations = [
        migrations.RunPython(backfill_and_dedupe, rollback_dedupe),
    ]
