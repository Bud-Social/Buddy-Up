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
    from django.db import models as db_models

    user_a = instance.from_user
    user_b = instance.to_user

    # Idempotent check: find any existing 1-to-1 conversation between them
    existing = (
        Conversation.objects
        .filter(is_group=False, participants=user_a)
        .filter(participants=user_b)
        .annotate(pc=db_models.Count('participants'))
        .filter(pc=2)
        .first()
    )

    if existing:
        return  # already exists

    conv = Conversation.objects.create(is_group=False)
    conv.participants.set([user_a, user_b])
