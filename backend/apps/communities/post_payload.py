"""Convert messaging ``CommunityPost`` rows into the feed ``Post`` payload shape.

The communities API surfaces messaging community posts to clients that render
the regular feed card, so the payload must match ``apps.feed.serializers.PostSerializer``
field-for-field. Keeping the mapping in one place stops the list endpoints and
the saved-posts endpoint from drifting apart.
"""


def author_payload(cp):
    """Author block shared by every serialised community post."""
    author = cp.author
    if not author:
        return {}
    return {
        'user_id': str(author.user_id),
        'username': author.username or '',
        'display_name': author.display_name or '',
        'avatar_url': author.avatar_url or '',
        'verification_status': 'verified',
    }


def community_post_payload(
    cp,
    *,
    reaction_counts=None,
    user_reaction=None,
    is_saved=False,
    is_reposted_by_me=False,
    reposters=None,
    is_member=None,
):
    """Build the feed-compatible payload for one community post.

    ``reaction_counts``/``user_reaction``/``reposters`` can be precomputed by the
    caller for list views; when omitted they are derived for this post only,
    which is fine for small collections such as the saved list.
    """
    if reaction_counts is None:
        reaction_counts = {}
        if cp.like_count:
            reaction_counts['💪'] = cp.like_count
        from django.db.models import Count
        for row in cp.reactions.values('reaction_type').annotate(c=Count('pk')):
            reaction_counts[row['reaction_type']] = reaction_counts.get(row['reaction_type'], 0) + row['c']

    if reposters is None:
        reposters = [{
            'user_id': str(rp.profile.user_id),
            'username': rp.profile.username or '',
            'display_name': rp.profile.display_name or '',
            'avatar_url': rp.profile.avatar_url or '',
            'verification_status': rp.profile.verification_status or 'verified',
        } for rp in cp.reposts.select_related('profile').order_by('created_at')]

    conversation = cp.conversation
    data = {
        'id': str(cp.id),
        'post_type': 'text',
        'body': cp.body or '',
        'is_anonymous': False,
        'gym_tag_id': None,
        'gym_tag_name': None,
        'visibility': 'public',
        'location_label': '',
        'location_lat': None,
        'location_lng': None,
        'workout_log_data': None,
        'media_urls': [cp.media_url] if cp.media_url else [],
        'media': [],
        'tags': [],
        'view_count': cp.view_count,
        'share_count': cp.share_count,
        'moderation_status': 'clean',
        'content_rating': 'safe',
        'comments_disabled': False,
        'author_data': author_payload(cp),
        'reaction_counts': reaction_counts,
        'user_reaction': user_reaction,
        'comment_count': cp.comment_count or 0,
        'repost_count': cp.repost_count,
        'save_count': cp.save_count,
        'is_saved': is_saved,
        'is_reposted_by_me': is_reposted_by_me,
        'is_repost': bool(cp.is_repost),
        'original_post_data': None,
        'is_pinned': cp.is_pinned,
        'poll': None,
        'reposters': reposters,
        'created_at': cp.created_at.isoformat() if cp.created_at else None,
        'updated_at': cp.updated_at.isoformat() if cp.updated_at else None,
        'ai_analysis': {},
        'community_id': str(cp.conversation_id),
        'community_name': conversation.group_name if conversation else '',
        'community_cover_url': (conversation.cover_url or '') if conversation else '',
    }
    if is_member is not None:
        data['is_member'] = bool(is_member)
    return data
