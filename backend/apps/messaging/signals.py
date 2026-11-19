"""
Signals for the messaging app.
Auto-creates a conversation when two users become buddies.
"""
from django.db.models.signals import post_save
from django.dispatch import receiver


@receiver(post_save, sender='profiles.BuddyRelationship')
def create_buddy_conversation(sender, instance, created, **kwargs):
    """
    When a BuddyRelationship transitions to 'confirmed', automatically
    create a 1-to-1 Conversation between the two buddies if one
    doesn't already exist.
    """
    if instance.status != 'confirmed':
        return

    from .models import Conversation

    user_a = instance.from_user
    user_b = instance.to_user

    # Idempotent: fetch or create the canonical 1-to-1 thread; the DB
    # constraint on pair_key guarantees no duplicates even if two signals
    # raced on the same pair.
    conv, _ = Conversation.get_or_create_1to1(user_a, user_b, origin='buddy', kind='buddy')
