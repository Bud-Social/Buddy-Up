"""Personalised feed ranking (Sprint B1).

Calls the AI service `/api/v1/feed/rank` (content score + LinUCB bandit) for the
`for_you` tab, with a hard fallback to the existing DB ranking if the AI service
is down or times out. Also sends engagement feedback so the bandit + preference
vector can learn.
"""
import logging
import threading

from django.conf import settings

logger = logging.getLogger(__name__)

POOL_SIZE = 150
AI_RANK_TIMEOUT = 3.0


def build_candidates(
    posts,
    user_profile,
    buddy_ids: set,
    followed_ids: set,
    gym_ids: set,
) -> list[dict]:
    """Build feature dicts for the ranking engine from a post queryset."""
    now = __import__('django.utils.timezone', fromlist=['now']).now()
    candidates = []
    for post in posts:
        age_hours = max((now - post.created_at).total_seconds() / 3600.0, 0.001)
        if post.author_id in buddy_ids:
            relationship = 'buddy'
        elif post.author_id in followed_ids:
            relationship = 'following'
        elif post.gym_tag_id in gym_ids:
            relationship = 'gym'
        else:
            relationship = 'none'

        candidates.append({
            'post_id': str(post.id),
            'author_id': str(post.author_id),
            'relationship': relationship,
            'reactions': getattr(post, 'reaction_count', 0) or 0,
            'comments': getattr(post, 'comment_count', 0) or 0,
            'saves': getattr(post, 'save_count', 0) or 0,
            'is_repost': bool(post.is_repost),
            'age_hours': round(age_hours, 3),
            'has_media': bool(post.media_urls),
            'is_video': any(
                u.split('?')[0].lower().rsplit('.', 1)[-1] in ('mp4', 'mov', 'webm', 'm4v', 'mpeg', 'mkv')
                for u in (post.media_urls or [])
            ) if post.media_urls else False,
            'post_type': post.post_type,
            'author_trust': 0.5,
            'is_pinned': bool(post.is_pinned),
        })
    return candidates


def rank_candidates(user_id: str, candidates: list[dict]) -> list[dict] | None:
    """POST candidates to the AI ranker. Returns re-ranked list or None on failure."""
    if not candidates:
        return candidates

    try:
        import requests
        resp = requests.post(
            f'{settings.AI_SERVICE_URL}/api/v1/feed/rank',
            json={'user_id': user_id, 'candidates': candidates, 'bandit': True},
            timeout=AI_RANK_TIMEOUT,
        )
        resp.raise_for_status()
        ranked = resp.json().get('ranked', [])
        return ranked if isinstance(ranked, list) else None
    except Exception as exc:  # noqa: BLE001
        logger.warning('AI feed ranking unavailable: %s — using DB ranking', exc)
        return None


def paginate_ranked(candidates: list[dict], cursor: str | None, page_size: int):
    """In-memory cursor pagination over the ranked candidate list."""
    if cursor:
        start = next(
            (i for i, c in enumerate(candidates) if c.get('post_id') == cursor),
            None,
        )
        if start is not None:
            candidates = candidates[start + 1:]
    return candidates[:page_size]


def send_feedback(user_id: str, post, reward: float):
    """Fire-and-forget engagement feedback to the AI bandit (non-blocking)."""
    if reward == 0:
        return
    try:
        context = {
            'author_id': str(post.author_id or ''),
            'reactions': 1,
            'comments': 0,
            'saves': 0,
            'is_repost': bool(post.is_repost),
            'age_hours': 24.0,
            'has_media': bool(post.media_urls),
            'is_video': False,
            'post_type': post.post_type or 'text',
            'author_trust': 0.5,
        }
    except Exception:  # noqa: BLE001
        return

    def _call():
        try:
            import requests
            requests.post(
                f'{settings.AI_SERVICE_URL}/api/v1/feed/feedback',
                json={
                    'user_id': user_id,
                    'arm_key': str(post.author_id or post.id),
                    'reward': float(reward),
                    'context': context,
                },
                timeout=2.0,
            )
        except Exception:  # noqa: BLE001
            pass

    threading.Thread(target=_call, daemon=True).start()
