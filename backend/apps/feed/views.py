import os
import json
import logging
import uuid

from django.conf import settings
from django.core.cache import cache
from django.shortcuts import get_object_or_404
from django.db import IntegrityError, models as db_models, transaction
from django.db.models import F
from django.utils import timezone
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile

from rest_framework import views, permissions, status
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.response import Response

from common.pagination import CursorPagination, PageNumberPagination
from common.age_gating import gate_mature_queryset, can_view_content
from .models import Post, FeedPost, Comment, Reaction, Save, Poll, PollOption, PollVote, Draft, PostMedia, PostShare, Sound, HiddenPost, MutedAuthor
from .media_types import ALLOWED_EXTS, guess_media_type, url_extension
from .serializers import (
    PostSerializer, FeedPostSerializer, PostCreateSerializer, CommentSerializer,
    PollSerializer, DraftSerializer,
    CommentCreateSerializer, ReactionInputSerializer, RepostSerializer,
    SavePostSerializer, PollCreateSerializer, OptionVoteSerializer,
    SoundSerializer, SoundCreateSerializer,
)
from apps.profiles.models import BuddyRelationship, Profile
from apps.ai.audit import audit_ai_call
from . import ai_ranking
from apps.ai.client import ai_post

logger = logging.getLogger(__name__)


def _looks_like_video(url: str) -> bool:
    if not url:
        return False
    lower = url.split('?')[0].lower()
    if lower.rsplit('.', 1)[-1] in ('mp4', 'mov', 'webm', 'm4v', 'mpeg', 'mkv'):
        return True
    return 'video/' in lower or 'videos' in lower


MAX_POST_MEDIA_ITEMS = 12
MAX_TRIM_MS = 180_000  # TikTok-style 3-minute cap, mirrors the client cap.


def _extract_media_items(request):
    """Extract structured `media` from the request (JSON string or list of dicts).

    Returns (items, provided). `items` is a list when the client supplied a
    parseable value, [] when the value could not be parsed, None when the
    field was not supplied. Values that are not str/list (e.g. uploaded
    files sharing the field name) are treated as not supplied.
    """
    if not hasattr(request.data, 'get') or 'media' not in request.data:
        return None, False
    raw = request.data.get('media')
    if isinstance(raw, (list, tuple)):
        return list(raw), True
    if isinstance(raw, str) and raw.strip():
        try:
            parsed = json.loads(raw)
        except (ValueError, TypeError):
            return [], True
        return (parsed if isinstance(parsed, list) else []), True
    return None, False


def _validate_media_items(items):
    """Validate structured media[] items. Returns (clean_items, error_message)."""
    from .media_types import is_allowed_media_host
    if len(items) > MAX_POST_MEDIA_ITEMS:
        return None, f'A post can have at most {MAX_POST_MEDIA_ITEMS} media items.'
    clean = []
    for i, item in enumerate(items):
        if not isinstance(item, dict):
            return None, f'media[{i}] must be an object.'
        url = str(item.get('url') or '').strip()
        if not url:
            return None, f'media[{i}].url is required.'
        if url_extension(url) not in ALLOWED_EXTS:
            return None, f'media[{i}].url file extension is not allowed.'
        if not is_allowed_media_host(url):
            return None, f'media[{i}].url host is not allowed.'
        media_type = item.get('media_type') or guess_media_type(url)
        if media_type not in ('image', 'video', 'audio'):
            return None, f'media[{i}].media_type must be one of image, video, audio.'

        def _int(key):
            value = item.get(key)
            if value in (None, ''):
                return None
            try:
                parsed_int = int(value)
            except (TypeError, ValueError):
                raise ValueError(f'media[{i}].{key} must be an integer.')
            if parsed_int < 0:
                raise ValueError(f'media[{i}].{key} must be >= 0.')
            return parsed_int

        try:
            width = _int('width')
            height = _int('height')
            duration_ms = _int('duration_ms')
            trim_start_ms = _int('trim_start_ms')
            trim_end_ms = _int('trim_end_ms')
        except ValueError as exc:
            return None, str(exc)

        sound = None
        sound_id = str(item.get('sound_id') or '').strip()
        if sound_id:
            sound = Sound.objects.filter(id=sound_id).first()
            if sound is None or not sound.is_active:
                return None, f'media[{i}].sound_id does not reference an active sound.'
        try:
            sound_volume = int(item.get('sound_volume', 100))
        except (TypeError, ValueError):
            return None, f'media[{i}].sound_volume must be an integer between 0 and 100.'
        if not 0 <= sound_volume <= 100:
            return None, f'media[{i}].sound_volume must be between 0 and 100.'

        # Parametric sound placement (start offset + fades for the attached
        # sound). Stored inside edit_meta so no model change is needed.
        sound_placement = {}
        if sound_id and item.get('sound_start_ms') not in (None, ''):
            try:
                sound_placement['start_ms'] = max(0, int(item.get('sound_start_ms') or 0))
            except (TypeError, ValueError):
                return None, f'media[{i}].sound_start_ms must be an integer.'
        for _skey in ('sound_fade_in_ms', 'sound_fade_out_ms'):
            if sound_id and item.get(_skey) not in (None, ''):
                try:
                    sound_placement[_skey.replace('sound_', '')] = max(0, min(10_000, int(item.get(_skey) or 0)))
                except (TypeError, ValueError):
                    return None, f'media[{i}].{_skey} must be an integer.'

        # Studio/in-studio captions travel per video row so they survive the
        # post-publish async transcription pass below.
        captions_raw = item.get('captions') or []
        if not isinstance(captions_raw, list):
            return None, f'media[{i}].captions must be a list.'
        captions = []
        for seg in captions_raw[:500]:
            if not isinstance(seg, dict):
                continue
            text = str(seg.get('text') or '').strip()[:500]
            if not text:
                continue
            try:
                seg_start = max(0, int(seg.get('start_ms') or 0))
                seg_end = max(0, int(seg.get('end_ms') or 0))
            except (TypeError, ValueError):
                continue
            if seg_end <= seg_start:
                continue
            captions.append({'start_ms': seg_start, 'end_ms': seg_end, 'text': text})

        # Creative-studio edit metadata (IG/TikTok-style): filter preset,
        # playback speed, original-audio volume, voice enhance, text overlays,
        # manual adjustments, aspect crop, stickers and additional audio tracks.
        edit_meta_raw = item.get('edit_meta') or {}
        if not isinstance(edit_meta_raw, dict):
            edit_meta_raw = {}
        edit_meta = {}
        _filter_name = str(edit_meta_raw.get('filter') or '').strip()[:32]
        if _filter_name:
            edit_meta['filter'] = _filter_name
            try:
                _fos = int(edit_meta_raw.get('filter_strength', 100))
                if 0 <= _fos <= 100 and _fos != 100:
                    edit_meta['filter_strength'] = _fos
            except (TypeError, ValueError):
                pass
        try:
            _speed = float(edit_meta_raw.get('speed') or 1.0)
        except (TypeError, ValueError):
            _speed = 1.0
        if 0.3 <= _speed <= 3.0 and _speed != 1.0:
            edit_meta['speed'] = round(_speed, 2)
        try:
            _volume = int(edit_meta_raw.get('volume', 100))
        except (TypeError, ValueError):
            _volume = None
        if _volume is not None and 0 <= _volume <= 200:
            edit_meta['volume'] = _volume
        if bool(edit_meta_raw.get('enhance')):
            edit_meta['enhance'] = True

        _VOICE_EFFECTS = ('chipmunk', 'deep', 'robot', 'echo')
        _voice_effect = str(edit_meta_raw.get('voice_effect') or '').strip()
        if _voice_effect in _VOICE_EFFECTS:
            edit_meta['voice_effect'] = _voice_effect

        _adjust_raw = edit_meta_raw.get('adjust')
        if isinstance(_adjust_raw, dict):
            adjust = {}
            for _key in ('brightness', 'contrast', 'saturation'):
                if _key in _adjust_raw:
                    try:
                        adjust[_key] = max(0, min(100, int(_adjust_raw.get(_key) or 50)))
                    except (TypeError, ValueError):
                        pass
            if 'vignette' in _adjust_raw:
                try:
                    adjust['vignette'] = max(0, min(100, int(_adjust_raw.get('vignette') or 0)))
                except (TypeError, ValueError):
                    pass
            if adjust:
                edit_meta['adjust'] = adjust

        _ASPECT_MODES = ('9:16', '1:1', '4:5', '16:9')
        _aspect = str(edit_meta_raw.get('aspect') or '').strip()
        if _aspect in _ASPECT_MODES:
            edit_meta['aspect'] = _aspect
            try:
                edit_meta['focus_y'] = max(0, min(100, int(edit_meta_raw.get('focus_y', 50))))
            except (TypeError, ValueError):
                edit_meta['focus_y'] = 50

        overlays_raw = edit_meta_raw.get('text_overlays')
        if isinstance(overlays_raw, list):
            overlays = []
            for ov in overlays_raw[:50]:
                if not isinstance(ov, dict):
                    continue
                text = str(ov.get('text') or '').strip()[:200]
                if not text:
                    continue
                try:
                    ov_start = max(0, int(ov.get('start_ms') or 0))
                    ov_end = max(0, int(ov.get('end_ms') or 0))
                    ov_y = max(0, min(100, int(ov.get('y') or 80)))
                    ov_size = max(0.0, min(2.0, float(ov.get('size') or 0)))
                except (TypeError, ValueError):
                    continue
                if ov_end <= ov_start:
                    continue
                overlay_out = {
                    'text': text,
                    'start_ms': ov_start,
                    'end_ms': ov_end,
                    'y': ov_y,
                    'size': round(ov_size, 2),
                    'color': str(ov.get('color') or 'white')[:16],
                }
                if ov.get('x') is not None:
                    try:
                        overlay_out['x'] = max(0, min(100, int(ov.get('x') or 50)))
                    except (TypeError, ValueError):
                        pass
                if ov.get('rotation') is not None:
                    try:
                        overlay_out['rotation'] = max(-15, min(15, int(ov.get('rotation') or 0)))
                    except (TypeError, ValueError):
                        pass
                _font = str(ov.get('font') or '').strip()[:24]
                if _font:
                    overlay_out['font'] = _font
                _fx = str(ov.get('effect') or '').strip()
                if _fx in ('outline', 'glow', 'neon', 'bubble', 'highlight', 'shadow'):
                    overlay_out['effect'] = _fx
                _bg = str(ov.get('bg') or '').strip()
                if _bg in ('pill', 'block'):
                    overlay_out['bg'] = _bg
                if ov.get('bg_color'):
                    overlay_out['bg_color'] = str(ov.get('bg_color'))[:32]
                _anim = str(ov.get('animation') or '').strip()
                if _anim in ('fade', 'pop', 'slide', 'karaoke'):
                    overlay_out['animation'] = _anim
                overlays.append(overlay_out)
            if overlays:
                edit_meta['text_overlays'] = overlays

        stickers_raw = edit_meta_raw.get('stickers')
        if isinstance(stickers_raw, list):
            stickers = []
            for st in stickers_raw[:12]:
                if not isinstance(st, dict):
                    continue
                content = str(st.get('content') or '').strip()
                kind = str(st.get('kind') or 'emoji').strip()
                if kind not in ('emoji', 'countdown', 'mention'):
                    continue
                # countdown stickers render a live timer — content optional
                if not content and kind != 'countdown':
                    continue
                try:
                    st_start = max(0, int(st.get('start_ms') or 0))
                    st_end = max(0, int(st.get('end_ms') or 0))
                except (TypeError, ValueError):
                    continue
                if st_end <= st_start:
                    continue
                try:
                    st_x = max(0, min(100, int(st.get('x') or 50)))
                    st_y = max(0, min(100, int(st.get('y') or 50)))
                    st_scale = max(0.5, min(2.0, float(st.get('scale') or 1)))
                except (TypeError, ValueError):
                    st_x, st_y, st_scale = 50, 50, 1
                stickers.append({
                    'kind': kind,
                    'content': content[:8] if kind == 'emoji' else content[:60],
                    'x': st_x, 'y': st_y,
                    'start_ms': st_start, 'end_ms': st_end,
                    'scale': round(st_scale, 2),
                })
            if stickers:
                edit_meta['stickers'] = stickers

        tracks_raw = edit_meta_raw.get('audio_tracks')
        if isinstance(tracks_raw, list):
            tracks = []
            for tr in tracks_raw[:3]:
                if not isinstance(tr, dict):
                    continue
                tr_kind = str(tr.get('kind') or '').strip()
                if tr_kind not in ('sound', 'voiceover', 'url'):
                    continue
                try:
                    tr_volume = max(0, min(200, int(tr.get('volume') or 100)))
                    tr_start = max(0, int(tr.get('start_ms') or 0))
                    tr_duration = int(tr.get('duration_ms', 0) or 0)
                except (TypeError, ValueError):
                    continue
                if tr_duration < 0 or tr_duration > MAX_TRIM_MS:
                    tr_duration = MAX_TRIM_MS
                track_out = {'kind': tr_kind, 'volume': tr_volume, 'start_ms': tr_start}
                if tr_duration > 0:
                    track_out['duration_ms'] = tr_duration
                _src_url = ''
                if tr_kind == 'sound':
                    _sound = Sound.objects.filter(
                        id=str(tr.get('sound_id') or '').strip()
                    ).filter(is_active=True).only('audio_url').first()
                    if _sound is None or not _sound.audio_url:
                        continue
                    _src_url = _sound.audio_url
                else:
                    _src_url = str(tr.get('url') or '').strip()
                    if not _src_url or not is_allowed_media_host(_src_url):
                        continue
                if _src_url:
                    track_out['url'] = _src_url
                _track_effect = str(tr.get('effect') or '').strip()
                if _track_effect in _VOICE_EFFECTS:
                    track_out['effect'] = _track_effect
                for _fade_key in ('fade_in_ms', 'fade_out_ms'):
                    if tr.get(_fade_key) not in (None, ''):
                        try:
                            track_out[_fade_key] = max(0, min(10_000, int(tr.get(_fade_key) or 0)))
                        except (TypeError, ValueError):
                            pass
                if bool(tr.get('ducking')):
                    track_out['ducking'] = True
                _track_label = str(tr.get('label') or '').strip()[:60]
                if _track_label:
                    track_out['label'] = _track_label
                tracks.append(track_out)
            if tracks:
                edit_meta['audio_tracks'] = tracks

        _caps_style_raw = edit_meta_raw.get('captions_style')
        if isinstance(_caps_style_raw, dict):
            caps_style = {}
            _preset = str(_caps_style_raw.get('preset') or 'classic').strip()[:24]
            if _preset:
                caps_style['preset'] = _preset
            if _caps_style_raw.get('font'):
                caps_style['font'] = str(_caps_style_raw['font']).strip()[:24]
            if _caps_style_raw.get('color'):
                caps_style['color'] = str(_caps_style_raw['color']).strip()[:16]
            if _caps_style_raw.get('bg') in ('pill', 'block'):
                caps_style['bg'] = _caps_style_raw['bg']
            if _caps_style_raw.get('size') not in (None, ''):
                try:
                    caps_style['size'] = max(0.8, min(1.6, round(float(_caps_style_raw.get('size')), 2)))
                except (TypeError, ValueError):
                    pass
            if _caps_style_raw.get('placement') in ('top', 'center', 'bottom'):
                caps_style['placement'] = _caps_style_raw['placement']
            if caps_style:
                edit_meta['captions_style'] = caps_style

        if sound_placement:
            edit_meta['sound_placement'] = sound_placement

        clean.append({
            'url': url,
            'media_type': media_type,
            'poster_url': str(item.get('poster_url') or ''),
            'width': width,
            'height': height,
            'duration_ms': duration_ms,
            'trim_start_ms': trim_start_ms,
            'trim_end_ms': trim_end_ms,
            'sound': sound,
            'sound_volume': sound_volume,
            'captions': captions,
            'edit_meta': edit_meta,
            'alt_text': str(item.get('alt_text') or '')[:255],
        })
    return clean, None


def _create_post_media(post, items):
    """Create PostMedia rows for `post` in order and bump sound usage counts.

    `items` are validated dicts (or minimal {url, media_type} for the legacy
    path). Returns the created rows.
    """
    from apps.ai.utils import segments_to_vtt

    rows = []
    for order, item in enumerate(items):
        row_captions = item.get('captions') or []
        rows.append(PostMedia.objects.create(
            post=post,
            order=order,
            media_type=item.get('media_type') or 'image',
            url=item['url'],
            poster_url=item.get('poster_url') or '',
            width=item.get('width'),
            height=item.get('height'),
            duration_ms=item.get('duration_ms'),
            trim_start_ms=item.get('trim_start_ms'),
            trim_end_ms=item.get('trim_end_ms'),
            sound=item.get('sound'),
            sound_volume=item.get('sound_volume') if item.get('sound_volume') is not None else 100,
            captions=row_captions,
            captions_vtt=segments_to_vtt(row_captions),
            edit_meta=item.get('edit_meta') or {},
            alt_text=item.get('alt_text') or '',
        ))
    usage_counts = {}
    for row in rows:
        if row.sound_id:
            usage_counts[row.sound_id] = usage_counts.get(row.sound_id, 0) + 1
    for sound_id, count in usage_counts.items():
        Sound.objects.filter(id=sound_id).update(usage_count=F('usage_count') + count)
    return rows


def _trigger_transcription(media_rows):
    """Fire transcription for each video PostMedia (Bud Press captions)."""
    for row in media_rows:
        if row.media_type != 'video':
            continue
        try:
            from apps.ai.tasks import transcribe_post_media
            transcribe_post_media.delay(str(row.id))
        except Exception:  # noqa: BLE001
            pass


def _auto_captions_requested(request) -> bool:
    """Studio captions toggle. Defaults to true for older clients."""
    raw = request.data.get('auto_captions')
    if raw in (None, ''):
        return True
    return str(raw).strip().lower() in ('1', 'true', 'yes', 'on')


def _audience_q(user_profile):
    """Q-filter matching every post the viewer is allowed to see.

    public            — everyone
    author's own      — always
    buddies           — confirmed buddies (or the author)
    gym_members       — anyone sharing an active gym membership with the author
                        (or, for gym-tagged posts, members of that gym)
    """
    from apps.gyms.models import GymMembership

    buddy_ids = set(
        BuddyRelationship.objects.filter(
            (db_models.Q(from_user=user_profile) | db_models.Q(to_user=user_profile)),
            status='confirmed',
        ).values_list(
            db_models.Case(db_models.When(from_user=user_profile, then='to_user_id'), default='from_user_id'),
            flat=True,
        )
    )
    my_gym_ids = set(
        GymMembership.objects.filter(member=user_profile, subscription_active=True)
        .values_list('gym_id', flat=True)
    )
    shared_gym = GymMembership.objects.filter(
        member=db_models.OuterRef('author_id'),
        subscription_active=True,
        gym_id__in=my_gym_ids,
    )
    return (
        db_models.Q(visibility='public')
        | db_models.Q(author=user_profile)
        | (
            db_models.Q(visibility='buddies')
            & (db_models.Q(author_id__in=buddy_ids) | db_models.Q(author=user_profile))
        )
        | (
            db_models.Q(visibility='gym_members')
            & (
                db_models.Exists(shared_gym)
                | (db_models.Q(gym_tag_id__isnull=False) & db_models.Q(gym_tag_id__in=my_gym_ids))
            )
        )
    )


def _can_view_post(post, user_profile) -> bool:
    """Object-level visibility check used by detail/comments surfaces."""
    if not post.visibility or post.visibility == 'public':
        return True
    if not user_profile:
        return False
    if post.author_id == user_profile.user_id:
        return True
    if post.visibility == 'private':
        return False
    if post.visibility == 'buddies':
        return BuddyRelationship.objects.filter(
            (db_models.Q(from_user=user_profile) | db_models.Q(to_user=user_profile)),
            status='confirmed',
        ).filter(
            db_models.Q(from_user_id=post.author_id) | db_models.Q(to_user_id=post.author_id)
        ).exists()
    if post.visibility == 'gym_members':
        from apps.gyms.models import GymMembership
        my_gym_ids = set(
            GymMembership.objects.filter(member=user_profile, subscription_active=True)
            .values_list('gym_id', flat=True)
        )
        if post.gym_tag_id and post.gym_tag_id in my_gym_ids:
            return True
        return GymMembership.objects.filter(
            profile_id=post.author_id, subscription_active=True, gym_id__in=my_gym_ids,
        ).exists()
    return False


# Bud Press engagement counters.
# Views are throttled to one counted view per viewer per post per 24h so
# refresh loops and re-opens don't inflate creator insights. Shares are
# counted on every POST — each share is a deliberate outbound action.
POST_VIEW_THROTTLE_SECONDS = 24 * 60 * 60


def _post_view_cache_key(post_id, user_id) -> str:
    return f'feed:post_view:{post_id}:{user_id}'


def _record_post_view(post, viewer_profile):
    """Count a view for `post`, throttled per viewer (24h window).

    Shared by PostDetailView (implicit view on read) and PostViewRecordView
    (explicit view ping) so both surfaces stay consistent. Returns
    (view_count, counted).
    """
    if viewer_profile is None:
        return post.view_count, False
    key = _post_view_cache_key(post.id, viewer_profile.user_id)
    try:
        first_in_window = cache.add(key, 1, timeout=POST_VIEW_THROTTLE_SECONDS)
    except Exception:  # noqa: BLE001 — cache outage must not break reads
        first_in_window = True
    if not first_in_window:
        return post.view_count, False
    Post.objects.filter(id=post.id).update(view_count=F('view_count') + 1)
    post.refresh_from_db(fields=['view_count'])
    return post.view_count, True


def _handle_media_uploads(request_files):
    """Save uploaded files to media storage and return list of public URLs.

    Raises RuntimeError if any file fails to store so callers can surface a
    real error instead of silently dropping photos from the post.
    """
    urls = []
    for f in request_files:
        ext = os.path.splitext(f.name)[1].lower()
        filename = f'posts/{uuid.uuid4().hex}{ext}'
        try:
            saved_name = default_storage.save(filename, ContentFile(f.read()))
            url = default_storage.url(saved_name)
        except Exception as exc:  # noqa: BLE001
            logger.exception('Media upload failed for %s: %s', f.name, exc)
            raise RuntimeError(f'Failed to store uploaded file {f.name!r}.') from exc
        urls.append(url)
    return urls


def _dedupe_reposts_for_viewer(posts, viewer_profile):
    """TikTok-style repost/original collapse, viewer-aware.

    For each original with repost rows in the page: viewers who follow (or
    are) the reposter keep the repost row(s) and lose the plain original;
    everyone else keeps the original (with its repost count) and never sees
    a stranger's repost row.
    """
    try:
        followed_ids = set(viewer_profile.following.values_list('followee_id', flat=True))
    except Exception:  # noqa: BLE001 — fall back to showing originals
        followed_ids = set()
    followed_ids.add(viewer_profile.user_id)
    by_original: dict = {}
    for p in posts:
        if p.is_repost and p.original_post_id:
            by_original.setdefault(p.original_post_id, []).append(p)
    keep_repost_ids = set()
    drop_original_ids = set()
    for orig_id, reposts in by_original.items():
        kept = [r for r in reposts if r.author_id in followed_ids]
        if kept:
            keep_repost_ids.update(r.id for r in kept)
            drop_original_ids.add(orig_id)
    return [
        p for p in posts
        if p.id in keep_repost_ids
        or (not p.is_repost and p.id not in drop_original_ids)
        or (p.is_repost and not p.original_post_id)
    ]


def _apply_hide_mute_exclusions(queryset, user_profile):
    """Exclude viewer-hidden posts and muted authors from a discovery queryset.

    Applied to every FeedView discovery tab (for_you, following, videos,
    videos_following, nearby) AND the ranked pool (which is
    built from the same gated queryset). Subquery-based so it composes with
    the existing audience/age-gating filters without extra round trips.
    """
    return queryset.exclude(
        id__in=HiddenPost.objects.filter(viewer=user_profile).values('post_id')
    ).exclude(
        author_id__in=MutedAuthor.objects.filter(muter=user_profile).values('muted_id')
    )


def _next_link(request, cursor):
    """Build a pagination URL for the ranked feed, preserving other query params."""
    from urllib.parse import parse_qsl, urlencode, urlparse, urlunparse
    params = [(k, v) for k, v in parse_qsl(urlparse(request.get_full_path()).query) if k != 'cursor']
    params.append(('cursor', cursor))
    query = urlencode(params)
    return urlunparse(urlparse(request.build_absolute_uri())._replace(query=query))


def _rank_for_you(request, user_profile, queryset, buddy_ids, followed_ids, gym_ids):
    """Sprint B1: personalised ML ranking of the `for_you` tab.

    Returns a Response, or None so the caller falls back to DB ranking if the
    AI service is unavailable or the pool is empty.
    """
    pool = list(queryset[:ai_ranking.POOL_SIZE].annotate(
        reaction_count=db_models.Subquery(
            Reaction.objects.filter(post=db_models.OuterRef('pk'))
            .values('post').annotate(c=db_models.Count('pk')).values('c'),
            output_field=db_models.IntegerField(),
        ),
        comment_count=db_models.Subquery(
            Comment.objects.filter(post=db_models.OuterRef('pk'))
            .values('post').annotate(c=db_models.Count('pk')).values('c'),
            output_field=db_models.IntegerField(),
        ),
        save_count=db_models.Subquery(
            Save.objects.filter(post=db_models.OuterRef('pk'))
            .values('post').annotate(c=db_models.Count('pk')).values('c'),
            output_field=db_models.IntegerField(),
        ),
    ))
    if not pool:
        return None

    candidates = ai_ranking.build_candidates(pool, user_profile, buddy_ids, followed_ids, gym_ids)
    ranked = ai_ranking.rank_candidates(str(user_profile.user_id), candidates)
    if ranked is None:
        return None

    score_by_id = {c['post_id']: c for c in ranked}
    ordered = sorted(
        pool,
        key=lambda p: (-int(p.is_pinned), -score_by_id.get(str(p.id), {}).get('ml_score', 0.0)),
    )

    deduped = _dedupe_reposts_for_viewer(ordered, user_profile)

    # Persist rank + algorithm context per user for a short window so
    # engagement feedback can be attributed to the impression that earned it.
    feed_request_id = str(uuid.uuid4())
    try:
        cache.set(
            f'feed_rank_ctx:{user_profile.user_id}',
            {
                'feed_request_id': feed_request_id,
                'algorithm_version': 'linucb-v1',
                'ranks': {str(p.id): i for i, p in enumerate(deduped, start=1)},
            },
            timeout=600,
        )
    except Exception:  # noqa: BLE001 — attribution is best-effort
        pass

    paginator = CursorPagination()
    page_size = paginator.get_page_size(request)
    cursor = request.query_params.get('cursor')
    try:
        page_window = ai_ranking.paginate_ranked(deduped, cursor, page_size + 1)
    except ValueError as exc:
        return Response({
            'success': False, 'data': None, 'message': str(exc),
            'errors': {'cursor': [str(exc)]}, 'pagination': None,
        }, status=status.HTTP_400_BAD_REQUEST)
    page_posts = page_window[:page_size]
    has_next = len(page_window) > page_size

    serializer = FeedPostSerializer(page_posts, many=True, context={'request': request})
    next_cursor = str(page_posts[-1].id) if page_posts and has_next else None
    return Response({
        'success': True,
        'data': serializer.data,
        'ranking': {
            'feed_request_id': feed_request_id,
            'algorithm_version': 'linucb-v1',
            'source': 'ai',
        },
        'message': 'OK',
        'errors': None,
        'pagination': {
            'count': len(page_posts),
            'next': _next_link(request, next_cursor) if next_cursor else None,
            'previous': None,
        },
    })


class FeedView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        tab = request.query_params.get('tab', 'for_you')
        post_type = request.query_params.get('post_type')

        user_profile = request.user.profile

        if tab in ('videos', 'videos_following'):
            # TikTok-style video feed. DB-level filtering (post_type) keeps it
            # paginated; legacy photo posts carrying video URLs still match.
            base = FeedPost.objects.filter(
                moderation_status='clean',
                visibility='public',
            ).exclude(
                db_models.Q(media_urls=[]) | db_models.Q(media_urls__isnull=True),
            )
            if tab == 'videos_following':
                followed_ids = list(user_profile.following.values_list('followee_id', flat=True))
                base = base.filter(author_id__in=followed_ids)

            buddy_ids = set(
                BuddyRelationship.objects.filter(
                    (db_models.Q(from_user=user_profile) | db_models.Q(to_user=user_profile)),
                    status='confirmed',
                ).values_list(
                    db_models.Case(db_models.When(from_user=user_profile, then='to_user_id'), default='from_user_id'),
                    flat=True,
                )
            )
            gym_ids = set(user_profile.gym_memberships.filter(subscription_active=True).values_list('gym_id', flat=True))
            followed_set = set(user_profile.following.values_list('followee_id', flat=True))

            queryset = base.select_related('author', 'gym_tag').annotate(
                rank=db_models.Case(
                    db_models.When(author_id__in=buddy_ids, then=db_models.Value(100)),
                    db_models.When(author_id__in=followed_set, then=db_models.Value(50)),
                    db_models.When(gym_tag_id__in=gym_ids, then=db_models.Value(75)),
                    default=db_models.Value(10),
                ),
            ).order_by('-rank', '-created_at')
            queryset = _apply_hide_mute_exclusions(queryset, user_profile)
            queryset = gate_mature_queryset(request, queryset)
            # Video-ness is verified in Python over the pool only — the pool
            # itself is already narrowed by post_type below.
            video_types = ['short_video', 'long_video']
            typed_pool = queryset.filter(post_type__in=video_types)
            videos = [p for p in list(typed_pool[:200]) if any(_looks_like_video(u) for u in (p.media_urls or []))]

            # Cursor pagination over the ranked video pool (same pattern as
            # the for_you tab: opaque post-id cursor + _next_link builder).
            paginator = CursorPagination()
            page_size = paginator.get_page_size(request)
            cursor = request.query_params.get('cursor')
            if cursor:
                start = next((i for i, p in enumerate(videos) if str(p.id) == cursor), None)
                if start is None:
                    return Response({
                        'success': False, 'data': None,
                        'message': 'Invalid or expired feed cursor.',
                        'errors': {'cursor': ['Invalid or expired feed cursor.']},
                        'pagination': None,
                    }, status=status.HTTP_400_BAD_REQUEST)
                videos = videos[start + 1:]
            page_posts = videos[:page_size]
            has_next = len(videos) > page_size
            next_cursor = str(page_posts[-1].id) if page_posts and has_next else None

            serializer = FeedPostSerializer(page_posts, many=True, context={'request': request})
            return Response({
                'success': True,
                'data': serializer.data,
                'message': 'OK',
                'errors': None,
                'pagination': {
                    'count': len(page_posts),
                    'next': _next_link(request, next_cursor) if next_cursor else None,
                    'previous': None,
                },
            })

        if tab == 'following':
            followed_ids = user_profile.following.values_list('followee_id', flat=True)
            queryset = FeedPost.objects.filter(
                author_id__in=followed_ids,
                moderation_status='clean',
            ).filter(_audience_q(user_profile)).select_related('author', 'gym_tag').order_by('-is_pinned', '-created_at')
        elif tab == 'nearby':
            queryset = FeedPost.objects.filter(
                moderation_status='clean',
            ).filter(_audience_q(user_profile))
            if user_profile.location_city:
                queryset = queryset.filter(location_label__icontains=user_profile.location_city)
            queryset = queryset.select_related('author', 'gym_tag').order_by('-is_pinned', '-created_at')
        else:  # for_you
            buddy_ids = set(
                BuddyRelationship.objects.filter(
                    (db_models.Q(from_user=user_profile) | db_models.Q(to_user=user_profile)),
                    status='confirmed',
                ).values_list(
                    db_models.Case(db_models.When(from_user=user_profile, then='to_user_id'), default='from_user_id'),
                    flat=True,
                )
            )
            followed_ids = set(user_profile.following.values_list('followee_id', flat=True))
            gym_ids = set(user_profile.gym_memberships.filter(subscription_active=True).values_list('gym_id', flat=True))

            queryset = FeedPost.objects.filter(
                moderation_status='clean',
            ).filter(_audience_q(user_profile))
            if post_type and post_type in dict(Post.POST_TYPES):
                queryset = queryset.filter(post_type=post_type)
            exclude_raw = request.query_params.get('exclude_post_types', '')
            exclude_types = [t.strip() for t in exclude_raw.split(',') if t.strip() in dict(Post.POST_TYPES)]
            if exclude_types:
                queryset = queryset.exclude(post_type__in=exclude_types)
            queryset = queryset.select_related('author', 'gym_tag').annotate(
                rank=db_models.Case(
                    db_models.When(author_id__in=buddy_ids, then=db_models.Value(100)),
                    db_models.When(author_id__in=followed_ids, then=db_models.Value(50)),
                    db_models.When(gym_tag_id__in=gym_ids, then=db_models.Value(75)),
                    default=db_models.Value(10),
                ),
            ).order_by('-is_pinned', '-rank', '-created_at')

            queryset = _apply_hide_mute_exclusions(queryset, user_profile)

            # Sprint B1: personalised ML ranking (additive; falls back to DB ranking)
            gated_queryset = gate_mature_queryset(request, queryset)
            ranked_response = _rank_for_you(
                request, user_profile, gated_queryset, buddy_ids, followed_ids, gym_ids,
            )
            if ranked_response is not None:
                return ranked_response

        # following / nearby land here (for_you only falls
        # through when the ranked pool is empty; its exclusions are already
        # applied above, re-applying is a harmless no-op).
        queryset = _apply_hide_mute_exclusions(queryset, user_profile)
        queryset = gate_mature_queryset(request, queryset)

        paginator = CursorPagination()
        paginator.ordering = '-created_at'
        page = paginator.paginate_queryset(queryset, request)
        page_posts = list(page)

        deduped_posts = _dedupe_reposts_for_viewer(page_posts, user_profile)

        serializer = FeedPostSerializer(deduped_posts, many=True, context={'request': request})

        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': {
                'count': len(deduped_posts),
                'next': paginator.get_next_link(),
                'previous': paginator.get_previous_link(),
            },
        })


class PostDetailView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, post_id):
        post = get_object_or_404(Post, id=post_id)

        if post.moderation_status == 'removed':
            return Response({
                'success': False, 'data': None,
                'message': 'This post has been removed.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_410_GONE)

        viewer_profile = request.user.profile if request.user.is_authenticated else None
        # Enforce the full audience scope (private / buddies / gym_members),
        # not just private. Unauthenticated viewers only ever see public.
        if not _can_view_post(post, viewer_profile):
            return Response({
                'success': False, 'data': None,
                'message': 'Not found.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_404_NOT_FOUND)

        if post.author_id != (request.user.profile.user_id if request.user.is_authenticated else None) and not can_view_content(request, post):
            return Response({
                'success': False, 'data': None,
                'message': 'Not found.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_404_NOT_FOUND)

        if request.user.is_authenticated:
            _record_post_view(post, request.user.profile)

        serializer = PostSerializer(post, context={'request': request})
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })

    def delete(self, request, post_id):
        if not request.user.is_authenticated:
            return Response(status=status.HTTP_401_UNAUTHORIZED)

        post = get_object_or_404(Post, id=post_id)
        if post.author_id != request.user.profile.user_id:
            return Response({
                'success': False, 'data': None,
                'message': 'You can only delete your own posts.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)

        post.soft_delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Post deleted.',
            'errors': None, 'pagination': None,
        })


class CreatePostView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]
    throttle_scope = 'post_create'

    def post(self, request):
        client_request_id = (
            request.headers.get('Idempotency-Key') or request.data.get('client_request_id') or ''
        ).strip()
        if len(client_request_id) > 128:
            return Response({
                'success': False, 'data': None,
                'message': 'Idempotency key must be 128 characters or fewer.',
                'errors': {'client_request_id': ['Too long.']}, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)
        if client_request_id:
            existing_post = Post.objects.filter(
                author=request.user.profile, client_request_id=client_request_id,
            ).first()
            if existing_post:
                output = PostSerializer(existing_post, context={'request': request})
                return Response({
                    'success': True, 'data': output.data,
                    'message': 'Post already created.', 'errors': None, 'pagination': None,
                }, status=status.HTTP_200_OK)

        # Handle file uploads — build media_urls from uploaded files
        if hasattr(request.FILES, 'getlist'):
            uploaded_files = request.FILES.getlist('media')
        else:
            uploaded_files = [request.FILES['media']] if request.FILES.get('media') else []

        media_urls = []
        if uploaded_files:
            try:
                media_urls = _handle_media_uploads(uploaded_files)
            except RuntimeError as exc:
                return Response({
                    'success': False, 'data': None,
                    'message': str(exc),
                    'errors': str(exc), 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)

        # Merge uploaded URLs with any pre-existing media_urls (e.g. from mobile).
        # Uploaded-file URLs are server-generated (safe); client-supplied
        # media_urls go through the same host allowlist as structured media.
        from .media_types import is_allowed_media_host
        existing_urls = request.data.getlist('media_urls') if hasattr(request.data, 'getlist') else (request.data.get('media_urls') or [])
        if isinstance(existing_urls, str):
            # Clients may send a JSON array in a single form field.
            try:
                parsed = json.loads(existing_urls)
                existing_urls = parsed if isinstance(parsed, list) else [existing_urls]
            except (ValueError, TypeError):
                existing_urls = [existing_urls]
        elif isinstance(existing_urls, list) and len(existing_urls) == 1 and isinstance(existing_urls[0], str):
            try:
                parsed = json.loads(existing_urls[0])
                if isinstance(parsed, list):
                    existing_urls = parsed
            except (ValueError, TypeError):
                pass
        client_urls = [str(u) for u in existing_urls if u]
        for u in client_urls:
            if not is_allowed_media_host(u):
                return Response({
                    'success': False, 'data': None,
                    'message': 'media_urls host is not allowed.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)
        all_media_urls = client_urls + media_urls

        # Bud Press structured media[] (JSON string or list of dicts).
        media_items, media_provided = _extract_media_items(request)
        clean_media = []
        if media_provided:
            clean_media, media_error = _validate_media_items(media_items)
            if media_error:
                return Response({
                    'success': False, 'data': None,
                    'message': media_error,
                    'errors': {'media': [media_error]}, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)
            # Dedupe: structured media[] wins over legacy media_urls.
            post_media_urls = [item['url'] for item in clean_media]
        else:
            post_media_urls = all_media_urls

        # Build mutable data dict
        data = request.data.dict() if hasattr(request.data, 'dict') else dict(request.data)
        data['media_urls'] = post_media_urls

        serializer = PostCreateSerializer(data=data)
        serializer.is_valid(raise_exception=True)
        validated = serializer.validated_data
        validated['media_urls'] = post_media_urls

        try:
            with transaction.atomic():
                post = Post.objects.create(
                    author=request.user.profile,
                    client_request_id=client_request_id or None,
                    **validated,
                )
                if clean_media:
                    media_rows = _create_post_media(post, clean_media)
                elif post.media_urls:
                    # Legacy path (media_urls / multipart files) also gets
                    # structured PostMedia rows so both representations exist.
                    media_rows = _create_post_media(
                        post,
                        [{'url': url, 'media_type': guess_media_type(url)} for url in post.media_urls],
                    )
                else:
                    media_rows = []
        except IntegrityError:
            if not client_request_id:
                raise
            post = Post.objects.get(
                author=request.user.profile, client_request_id=client_request_id,
            )
            output = PostSerializer(post, context={'request': request})
            return Response({
                'success': True, 'data': output.data,
                'message': 'Post already created.', 'errors': None, 'pagination': None,
            }, status=status.HTTP_200_OK)

        # Kick off transcription for videos without studio/manual captions.
        # Studio captions are already timed to the uploaded snippet; the async
        # pass must not overwrite them.
        if _auto_captions_requested(request):
            _trigger_transcription([
                row for row in media_rows
                if row.media_type == 'video' and not (row.captions or [])
            ])

        # Handle poll creation
        poll_serializer = PollCreateSerializer(data=request.data)
        poll_serializer.is_valid(raise_exception=True)
        poll_data = poll_serializer.validated_data
        poll_question = poll_data.get('poll_question', '').strip()
        try:
            poll_options_raw = json.loads(poll_data.get('poll_options_json', '[]'))
        except Exception:  # noqa: BLE001
            poll_options_raw = request.data.getlist('poll_options') if hasattr(request.data, 'getlist') else (request.data.get('poll_options') or [])
            if isinstance(poll_options_raw, str):
                poll_options_raw = [poll_options_raw]

        if poll_question and len(poll_options_raw) >= 2:
            closes_at = poll_data.get('poll_closes_at') or None
            allow_multiple = poll_data.get('poll_allow_multiple', False)
            try:
                min_sel = int(poll_data.get('poll_min_selections') or 1)
                max_sel = int(poll_data.get('poll_max_selections') or 1)
            except (TypeError, ValueError):
                min_sel, max_sel = 1, 1
            option_count = min(len([o for o in poll_options_raw if o.strip()]), 10)
            if not allow_multiple:
                min_sel = max_sel = 1
            else:
                max_sel = max(2, min(max_sel, option_count))
                min_sel = max(1, min(min_sel, max_sel))
            poll = Poll.objects.create(
                post=post,
                question=poll_question,
                closes_at=closes_at,
                allow_multiple=allow_multiple,
                min_selections=min_sel,
                max_selections=max_sel,
            )
            for i, opt_text in enumerate(poll_options_raw[:10]):
                if opt_text.strip():
                    PollOption.objects.create(poll=poll, text=opt_text.strip(), order=i)

        # Handle @mentions — store and send notifications
        mentioned_user_ids = request.data.getlist('mentioned_users') if hasattr(request.data, 'getlist') else (request.data.get('mentioned_users') or [])
        if isinstance(mentioned_user_ids, str):
            mentioned_user_ids = [mentioned_user_ids]
        if mentioned_user_ids:
            from apps.profiles.models import Profile
            profiles = Profile.objects.filter(user_id__in=mentioned_user_ids)
            post.mentioned_profiles.set(profiles)

            # Fire mention notifications asynchronously
            try:
                from .tasks import send_mention_notifications
                send_mention_notifications.delay(str(post.id), str(request.user.profile.user_id))
            except Exception:  # noqa: BLE001
                pass

        try:
            from .tasks import moderate_content
            moderate_content.delay(str(post.id))
        except Exception:  # noqa: BLE001
            pass

        # Notify buddies + followers about the new public post
        try:
            from apps.notifications.tasks import send_post_notification
            send_post_notification.delay(str(post.id), str(request.user.profile.user_id))
        except Exception:  # noqa: BLE001
            pass

        output = PostSerializer(post, context={'request': request})
        return Response({
            'success': True,
            'data': output.data,
            'message': 'Post created.',
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_201_CREATED)


class PollVoteView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, post_id):
        post = get_object_or_404(Post, id=post_id, post_type='poll')
        try:
            poll = post.poll
        except Poll.DoesNotExist:
            return Response({'success': False, 'message': 'Poll not found.'}, status=404)

        if poll.is_closed:
            return Response({'success': False, 'message': 'This poll has closed.'}, status=400)

        serializer = OptionVoteSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        option_ids = serializer.validated_data.get('option_ids', [])
        if not option_ids:
            option_id = serializer.validated_data.get('option_id')
            if option_id:
                option_ids = [option_id]

        if not option_ids:
            return Response({'success': False, 'message': 'No option selected.'}, status=400)

        # Deduplicate while preserving order.
        seen_ids = set()
        option_ids = [oid for oid in option_ids if not (oid in seen_ids or seen_ids.add(oid))]

        max_sel = max(1, int(poll.max_selections or 1))
        min_sel = max(1, int(poll.min_selections or 1))
        if not poll.allow_multiple:
            min_sel = max_sel = 1

        if len(option_ids) > max_sel:
            return Response({
                'success': False,
                'message': f'You can select at most {max_sel} option{"s" if max_sel != 1 else ""} in this poll.',
            }, status=400)
        if len(option_ids) < min_sel:
            return Response({
                'success': False,
                'message': f'Select at least {min_sel} option{"s" if min_sel != 1 else ""} to vote in this poll.',
            }, status=400)

        # Each submission is the voter's full ballot: replace whatever was
        # stored before so unchecking an option actually removes the vote.
        with transaction.atomic():
            PollVote.objects.filter(poll=poll, voter=request.user.profile).delete()
            for option_id in option_ids:
                option = get_object_or_404(PollOption, id=option_id, poll=poll)
                PollVote.objects.create(poll=poll, option=option, voter=request.user.profile)

        serializer = PollSerializer(poll, context={'request': request})
        return Response({'success': True, 'data': serializer.data, 'message': 'Vote recorded.', 'errors': None, 'pagination': None})


class CommentsView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, post_id):
        post = get_object_or_404(Post, id=post_id)
        viewer_profile = request.user.profile if request.user.is_authenticated else None
        # Comments inherit the parent post's audience scope.
        if not _can_view_post(post, viewer_profile):
            return Response({
                'success': False, 'data': None, 'message': 'Not found.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_404_NOT_FOUND)
        sort = request.query_params.get('sort', 'newest')

        comments = post.comments.filter(parent__isnull=True).select_related('author')
        if sort == 'oldest':
            comments = comments.order_by('created_at')
        elif sort == 'top':
            comments = sorted(comments, key=lambda c: c.reactions.count(), reverse=True)
        else:
            comments = comments.order_by('-created_at')

        serializer = CommentSerializer(comments, many=True, context={'request': request})
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })

    def post(self, request, post_id):
        if not request.user.is_authenticated:
            return Response(status=status.HTTP_401_UNAUTHORIZED)

        post = get_object_or_404(Post, id=post_id)
        if not _can_view_post(post, request.user.profile):
            return Response({
                'success': False, 'data': None, 'message': 'Not found.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_404_NOT_FOUND)
        if post.comments_disabled:
            return Response({
                'success': False, 'data': None,
                'message': 'Comments are turned off for this post.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)
        serializer = CommentCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        body = data['body'][:500]
        parent_id = data.get('parent_id')

        parent = None
        if parent_id:
            parent = get_object_or_404(Comment, id=parent_id, post_id=post_id)

        comment = Comment.objects.create(
            post=post,
            author=request.user.profile,
            body=body,
            parent=parent,
            is_anonymous=data.get('is_anonymous', False),
        )
        ai_ranking.send_feedback(str(request.user.profile.user_id), post, 1.0)

        serializer = CommentSerializer(comment, context={'request': request})
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'Comment added.',
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_201_CREATED)


class CommentDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request, post_id, comment_id):
        comment = get_object_or_404(Comment, id=comment_id, post_id=post_id)
        if comment.author_id != request.user.profile.user_id:
            return Response({
                'success': False, 'data': None,
                'message': 'You can only delete your own comments.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)
        comment.delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Comment deleted.',
            'errors': None, 'pagination': None,
        })


class ReactionView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, post_id):
        post = get_object_or_404(Post, id=post_id)
        serializer = ReactionInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        reaction_type = serializer.validated_data['reaction_type']

        profile = request.user.profile
        Reaction.objects.filter(post=post, author=profile).delete()
        Reaction.objects.create(post=post, author=profile, reaction_type=reaction_type)
        ai_ranking.send_feedback(str(profile.user_id), post, 1.0)

        serializer = PostSerializer(post, context={'request': request})
        return Response({
            'success': True,
            'data': serializer.data.get('reaction_counts', {}),
            'message': 'Reaction saved.',
            'errors': None,
            'pagination': None,
        })

    def delete(self, request, post_id):
        post = get_object_or_404(Post, id=post_id)
        Reaction.objects.filter(
            post=post,
            author=request.user.profile,
        ).delete()

        serializer = PostSerializer(post, context={'request': request})
        return Response({
            'success': True,
            'data': serializer.data.get('reaction_counts', {}),
            'message': 'Reaction removed.',
            'errors': None,
            'pagination': None,
        })


class CommentReactionView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, post_id, comment_id):
        comment = get_object_or_404(Comment, id=comment_id, post_id=post_id)
        serializer = ReactionInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        reaction_type = serializer.validated_data['reaction_type']

        profile = request.user.profile
        Reaction.objects.filter(comment=comment, author=profile).delete()
        Reaction.objects.create(comment=comment, author=profile, reaction_type=reaction_type)

        serializer = CommentSerializer(comment, context={'request': request})
        return Response({
            'success': True,
            'data': serializer.data.get('reaction_counts', {}),
            'message': 'Reaction saved.',
            'errors': None,
            'pagination': None,
        })

    def delete(self, request, post_id, comment_id):
        comment = get_object_or_404(Comment, id=comment_id, post_id=post_id)
        Reaction.objects.filter(comment=comment, author=request.user.profile).delete()
        serializer = CommentSerializer(comment, context={'request': request})
        return Response({
            'success': True,
            'data': serializer.data.get('reaction_counts', {}),
            'message': 'Reaction removed.',
            'errors': None,
            'pagination': None,
        })


class RepostView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, post_id):
        original = get_object_or_404(Post, id=post_id, visibility='public', moderation_status='clean')
        serializer = RepostSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        quote_body = serializer.validated_data.get('quote_body', '')

        # Resolve the ROOT original so reposting a repost still points at the
        # real source post. This keeps reposters stacked on one original and
        # avoids "empty repost" cards whose original is itself a repost.
        root = original
        while root.is_repost and root.original_post_id:
            root = root.original_post
        original = root

        # Toggle logic
        existing = Post.objects.filter(author=request.user.profile, original_post=original, is_repost=True).first()
        
        if existing:
            existing.delete()
            action = 'unreposted'
        else:
            _repost = Post.objects.create(
                author=request.user.profile,
                post_type='text',
                body='',
                is_repost=True,
                original_post=original,
                quote_body=quote_body[:500],
                visibility='public',
            )
            action = 'reposted'

            # Notify the original author their post was reposted
            try:
                from apps.notifications.tasks import send_repost_notification
                send_repost_notification.delay(str(request.user.profile.user_id), str(original.id))
            except Exception:  # noqa: BLE001
                pass

            ai_ranking.send_feedback(str(request.user.profile.user_id), original, 1.0)

        count = Post.objects.filter(original_post=original, is_repost=True).count()
        return Response({
            'success': True,
            'action': action,
            'repost_count': count,
            'message': 'OK',
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_200_OK if action == 'unreposted' else status.HTTP_201_CREATED)


class SaveView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, post_id):
        serializer = SavePostSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        collection = serializer.validated_data.get('collection', '')
        Save.objects.get_or_create(
            user=request.user.profile,
            post_id=post_id,
            defaults={'collection': collection},
        )
        post = Post.objects.filter(id=post_id).first()
        if post:
            ai_ranking.send_feedback(str(request.user.profile.user_id), post, 1.0)
        return Response({
            'success': True, 'data': None,
            'message': 'Post saved.',
            'errors': None, 'pagination': None,
        })

    def delete(self, request, post_id):
        Save.objects.filter(user=request.user.profile, post_id=post_id).delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Post unsaved.',
            'errors': None, 'pagination': None,
        })


class SavedPostsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        collection = request.query_params.get('collection')
        saves = Save.objects.filter(user=request.user.profile).select_related('post__author')
        if collection:
            saves = saves.filter(collection=collection)

        post_ids = saves.values_list('post_id', flat=True)
        posts = Post.objects.filter(
            id__in=post_ids,
        ).exclude(moderation_status='removed').select_related('author').order_by('-created_at')

        count = posts.count()
        paginator = CursorPagination()
        page = paginator.paginate_queryset(posts, request)
        serializer = PostSerializer(page, many=True, context={'request': request})

        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': {
                'count': count,
                'next': paginator.get_next_link(),
                'previous': paginator.get_previous_link(),
            },
        })


class PostPinView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, post_id):
        post = get_object_or_404(Post, id=post_id)
        if post.gym_tag:
            from apps.gyms.models import GymMembership
            is_admin = GymMembership.objects.filter(
                gym=post.gym_tag, member=request.user.profile,
                role__in=['owner', 'co_owner', 'moderator']
            ).exists()
            if not is_admin and post.author != request.user.profile:
                return Response({'success': False, 'message': 'Not authorized to pin this post.'}, status=403)
        else:
            if post.author != request.user.profile:
                return Response({'success': False, 'message': 'Not authorized.'}, status=403)

        post.is_pinned = not post.is_pinned
        post.save(update_fields=['is_pinned'])
        return Response({'success': True, 'data': {'is_pinned': post.is_pinned}, 'message': 'Pin toggled.', 'errors': None, 'pagination': None})


def _engagement_post_or_error_response(request, post_id):
    """Shared lookup + permission gate for share/view engagement endpoints.

    Returns (post, None) on success or (None, Response) with the 410/404
    envelope matching PostDetailView.
    """
    post = get_object_or_404(Post, id=post_id)
    if post.moderation_status == 'removed':
        return None, Response({
            'success': False, 'data': None,
            'message': 'This post has been removed.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_410_GONE)
    viewer_profile = request.user.profile
    if not _can_view_post(post, viewer_profile):
        return None, Response({
            'success': False, 'data': None,
            'message': 'Not found.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_404_NOT_FOUND)
    if post.author_id != viewer_profile.user_id and not can_view_content(request, post):
        return None, Response({
            'success': False, 'data': None,
            'message': 'Not found.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_404_NOT_FOUND)
    return post, None


class PostShareView(views.APIView):
    """POST /api/v1/feed/<post_id>/share/ — count an outbound share.

    Every POST increments share_count: each share is a deliberate user
    action (unlike passive views), so repeats are counted, not deduped.
    Accepts an optional `channel` (native/copy/whatsapp/x/facebook/
    telegram/other) and returns the sharer's stable referral `code` so the
    client can build a tracked link (`…?ref=<code>`).
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, post_id):
        post, error = _engagement_post_or_error_response(request, post_id)
        if error is not None:
            return error
        channel = str(request.data.get('channel') or 'other').strip().lower()[:20]
        valid_channels = {c for c, _ in PostShare.CHANNEL_CHOICES}
        if channel not in valid_channels:
            channel = 'other'
        record, _ = PostShare.objects.get_or_create(
            post=post,
            sharer=request.user.profile,
            defaults={'channel': channel},
        )
        if record.channel != channel:
            record.channel = channel
            record.save(update_fields=['channel'])
        Post.objects.filter(id=post.id).update(share_count=F('share_count') + 1)
        post.refresh_from_db(fields=['share_count'])
        return Response({
            'success': True,
            'data': {'share_count': post.share_count, 'code': record.code},
            'message': 'Post shared.',
            'errors': None,
            'pagination': None,
        })


class PostSharesListView(views.APIView):
    """GET /api/v1/feed/<post_id>/shares/ — who shared this post.

    Recent sharers first, with accounts the viewer follows floated to the
    top so recipients see familiar faces ("Shared by people you follow").
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, post_id):
        post, error = _engagement_post_or_error_response(request, post_id)
        if error is not None:
            return error
        from common.utils import absolute_media_url
        followed_ids = set(
            request.user.profile.following.values_list('followee_id', flat=True)
        ) if hasattr(request.user.profile, 'following') else set()
        records = list(
            PostShare.objects.filter(post=post)
            .select_related('sharer')
            .order_by('-created_at')[:20]
        )
        records.sort(key=lambda r: (r.sharer_id not in followed_ids, -r.created_at.timestamp()))
        return Response({
            'success': True,
            'data': [{
                'username': r.sharer.username,
                'display_name': r.sharer.display_name,
                'avatar_url': absolute_media_url(request, r.sharer.avatar_url),
                'channel': r.channel,
                'shared_at': r.created_at.isoformat(),
                'followed_by_viewer': r.sharer_id in followed_ids,
            } for r in records],
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class ShareOpenView(views.APIView):
    """POST /api/v1/s/<code>/open/ — attribute a tracked-link open.

    Public (recipients may be logged out). Returns the target post so the
    client can route, and increments the link's click counter.
    """
    permission_classes = [permissions.AllowAny]

    def post(self, request, code):
        record = PostShare.objects.filter(code=str(code).strip()[:16]).select_related('post').first()
        if record is None:
            return Response({
                'success': False, 'data': None,
                'message': 'Unknown share link.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_404_NOT_FOUND)
        PostShare.objects.filter(id=record.id).update(clicks=F('clicks') + 1)
        return Response({
            'success': True,
            'data': {'post_id': str(record.post_id), 'post_type': record.post.post_type},
            'message': 'OK',
            'errors': None, 'pagination': None,
        })


class PostViewRecordView(views.APIView):
    """POST /api/v1/feed/<post_id>/view/ — explicit view ping (Bud Press).

    Uses the same throttled helper as PostDetailView: one counted view per
    viewer per post per 24h. Repeat pings inside the window return the
    current count with success=True and a 'View already counted.' message.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, post_id):
        post, error = _engagement_post_or_error_response(request, post_id)
        if error is not None:
            return error
        view_count, counted = _record_post_view(post, request.user.profile)
        return Response({
            'success': True,
            'data': {'view_count': view_count},
            'message': 'View recorded.' if counted else 'View already counted.',
            'errors': None,
            'pagination': None,
        })


class PostHideView(views.APIView):
    """POST hide / DELETE unhide a post for the viewer (Bud Press menu).

    Toggle semantics: POST hides idempotently ({hidden: true}), DELETE
    unhides idempotently ({hidden: false}). Uses the shared engagement gate
    so hides on removed posts 410 like share/view. Hidden posts vanish from
    every FeedView discovery tab for this viewer only.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, post_id):
        post, error = _engagement_post_or_error_response(request, post_id)
        if error is not None:
            return error
        HiddenPost.objects.get_or_create(viewer=request.user.profile, post=post)
        return Response({
            'success': True,
            'data': {'hidden': True},
            'message': 'Post hidden.',
            'errors': None,
            'pagination': None,
        })

    def delete(self, request, post_id):
        post, error = _engagement_post_or_error_response(request, post_id)
        if error is not None:
            return error
        HiddenPost.objects.filter(viewer=request.user.profile, post=post).delete()
        return Response({
            'success': True,
            'data': {'hidden': False},
            'message': 'Post unhidden.',
            'errors': None,
            'pagination': None,
        })


class MuteAuthorView(views.APIView):
    """POST .../<username>/mute/ — "Don't suggest this creator".

    Mirrors BlockUserView conventions (400 on self, standard envelope) but
    is deliberately lighter than block: no buddy/follow relationship is
    deleted — the muted author's posts are only excluded from the muter's
    FeedView discovery tabs.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, username):
        target = get_object_or_404(Profile, username=username)
        if target == request.user.profile:
            return Response({
                'success': False, 'data': None,
                'message': 'You cannot mute yourself.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)
        MutedAuthor.objects.get_or_create(
            muter=request.user.profile,
            muted=target,
        )
        return Response({
            'success': True, 'data': None,
            'message': f'@{target.username} muted.',
            'errors': None, 'pagination': None,
        })


class UnmuteAuthorView(views.APIView):
    """DELETE .../<username>/unmute/ — undo a MuteAuthorView mute."""
    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request, username):
        target = get_object_or_404(Profile, username=username)
        MutedAuthor.objects.filter(
            muter=request.user.profile,
            muted=target,
        ).delete()
        return Response({
            'success': True, 'data': None,
            'message': f'@{target.username} unmuted.',
            'errors': None, 'pagination': None,
        })


class CreatorInsightsView(views.APIView):
    """GET /api/v1/feed/creator/insights/ — per-post aggregates for the author.

    Returns engagement aggregates (views/likes/comments/reposts/saves/shares)
    plus attention metrics derived from the `feed.post_focus` behavioral
    events: per-post focus sessions, total focus/watch time and average focus
    duration. For video posts the in-view focus duration is the watch-time
    signal (the fullscreen Bud Press player emits focus events while playing),
    so `watch_ms` is the focus-time sum on video posts. All attention fields
    are additive and defensive — absent events simply yield zeros.
    """

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        from apps.analytics.models import AnalyticsEvent

        profile = request.user.profile
        posts = (
            Post.objects.filter(author=profile, is_deleted=False)
            .annotate(
                likes_agg=db_models.Count('reactions', distinct=True),
                comments_agg=db_models.Count('comments', distinct=True),
                reposts_agg=db_models.Count('reposts', distinct=True),
                saves_agg=db_models.Count('saves', distinct=True),
            )
            .order_by('-created_at')
        )

        # Aggregate focus/watch-time events for all of the author's posts in
        # one query. object_id is stored as the post UUID string.
        post_ids = [str(p.id) for p in posts]
        focus_rows = (
            AnalyticsEvent.objects.filter(
                event_name='feed.post_focus',
                object_id__in=post_ids,
            )
            .values_list('object_id', 'properties')
            if post_ids else []
        )
        focus_by_post: dict[str, dict[str, int]] = {}
        for object_id, props in focus_rows:
            duration = 0
            if isinstance(props, dict):
                raw = props.get('duration_ms')
                if isinstance(raw, (int, float)) and raw > 0:
                    duration = int(raw)
            if duration <= 0:
                # Malformed/zero-duration rows are not real focus sessions.
                continue
            bucket = focus_by_post.setdefault(object_id, {'sessions': 0, 'total_ms': 0})
            bucket['sessions'] += 1
            bucket['total_ms'] += duration

        # Playback heartbeats (feed.video_watch, emitted every few seconds of
        # actual video playback) are the precise watch-time signal.
        heartbeat_rows = (
            AnalyticsEvent.objects.filter(
                event_name='feed.video_watch',
                object_id__in=post_ids,
            )
            .values_list('object_id', 'properties')
            if post_ids else []
        )
        watch_by_post: dict[str, dict[str, int]] = {}
        for object_id, props in heartbeat_rows:
            delta = 0
            if isinstance(props, dict):
                raw = props.get('delta_ms')
                if isinstance(raw, (int, float)) and raw > 0:
                    delta = int(raw)
            if delta <= 0:
                continue
            bucket = watch_by_post.setdefault(object_id, {'beats': 0, 'total_ms': 0})
            bucket['beats'] += 1
            bucket['total_ms'] += delta

        items = []
        totals = {
            'views': 0, 'likes': 0, 'comments': 0, 'reposts': 0,
            'saves': 0, 'shares': 0, 'interactions': 0,
            'focus_sessions': 0, 'watch_ms': 0, 'total_focus_ms': 0,
            'watch_heartbeats': 0,
        }
        for p in posts:
            pid = str(p.id)
            focus = focus_by_post.get(pid, {'sessions': 0, 'total_ms': 0})
            sessions = focus['sessions']
            total_ms = focus['total_ms']
            avg_ms = int(round(total_ms / sessions)) if sessions > 0 else 0
            # Watch time prefers precise playback heartbeats; falls back to the
            # focus-time sum for video posts viewed before the heartbeat landed.
            is_video = p.post_type in ('short_video', 'long_video')
            beats = watch_by_post.get(pid, {'beats': 0, 'total_ms': 0})
            if beats['total_ms'] > 0:
                watch_ms = beats['total_ms']
            elif is_video:
                watch_ms = total_ms
            else:
                watch_ms = 0
            interactions = (
                p.likes_agg + p.comments_agg + p.reposts_agg
                + p.saves_agg + (p.share_count or 0)
            )

            totals['views'] += p.view_count
            totals['likes'] += p.likes_agg
            totals['comments'] += p.comments_agg
            totals['reposts'] += p.reposts_agg
            totals['saves'] += p.saves_agg
            totals['shares'] += p.share_count or 0
            totals['interactions'] += interactions
            totals['focus_sessions'] += sessions
            totals['total_focus_ms'] += total_ms
            totals['watch_ms'] += watch_ms
            totals['watch_heartbeats'] += beats['beats']

            items.append(
                {
                    'post_id': pid,
                    'views': p.view_count,
                    'likes': p.likes_agg,
                    'comments': p.comments_agg,
                    'reposts': p.reposts_agg,
                    'saves': p.saves_agg,
                    'shares': p.share_count,
                    'interactions': interactions,
                    'focus_sessions': sessions,
                    'total_focus_ms': total_ms,
                    'avg_focus_ms': avg_ms,
                    'watch_ms': watch_ms,
                    'watch_heartbeats': beats['beats'],
                    'created_at': p.created_at.isoformat(),
                    'visibility': p.visibility,
                }
            )

        total_posts = len(items)
        summary = {
            'posts': total_posts,
            'views': totals['views'],
            'likes': totals['likes'],
            'comments': totals['comments'],
            'reposts': totals['reposts'],
            'saves': totals['saves'],
            'shares': totals['shares'],
            'interactions': totals['interactions'],
            'focus_sessions': totals['focus_sessions'],
            'total_focus_ms': totals['total_focus_ms'],
            # Average focus duration across all focus sessions (ms), 0 when none.
            'avg_focus_ms': (
                int(round(totals['total_focus_ms'] / totals['focus_sessions']))
                if totals['focus_sessions'] > 0 else 0
            ),
            'watch_ms': totals['watch_ms'],
            'watch_heartbeats': totals['watch_heartbeats'],
            'engagement_rate_pct': (
                round(100 * totals['interactions'] / totals['views'], 1)
                if totals['views'] > 0 else 0.0
            ),
        }
        return Response({
            'success': True,
            'data': {'items': items, 'summary': summary},
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class DraftListCreateView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        drafts = Draft.objects.filter(author=request.user.profile).order_by('-updated_at')
        serializer = DraftSerializer(drafts, many=True)
        return Response({
            'success': True, 'data': serializer.data,
            'message': 'OK', 'errors': None, 'pagination': None,
        })

    def post(self, request):
        data = request.data.copy() if hasattr(request.data, 'copy') else dict(request.data)
        data['author'] = request.user.profile.user_id

        existing_id = data.pop('id', None)
        if existing_id:
            try:
                draft = Draft.objects.get(id=existing_id, author=request.user.profile)
                serializer = DraftSerializer(draft, data=data, partial=True)
                serializer.is_valid(raise_exception=True)
                serializer.save()
                return Response({
                    'success': True, 'data': serializer.data,
                    'message': 'Draft updated.', 'errors': None, 'pagination': None,
                })
            except Draft.DoesNotExist:
                pass

        serializer = DraftSerializer(data=data)
        serializer.is_valid(raise_exception=True)
        serializer.save(author=request.user.profile)
        return Response({
            'success': True, 'data': serializer.data,
            'message': 'Draft saved.', 'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class DraftDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self, draft_id, user_profile):
        return get_object_or_404(Draft, id=draft_id, author=user_profile)

    def delete(self, request, draft_id):
        draft = self.get_object(draft_id, request.user.profile)
        draft.delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Draft deleted.', 'errors': None, 'pagination': None,
        })


class WorkoutAnalysisView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        import requests as http_requests
        profile = request.user.profile
        posts = Post.objects.filter(
            author=profile, post_type='workout_log',
            workout_log_data__isnull=False,
        ).order_by('created_at').values('workout_log_data', 'created_at')

        history = []
        for p in posts:
            entry = p['workout_log_data']
            if isinstance(entry, dict):
                entry['date'] = p['created_at'].isoformat()
                history.append({'workout_log_data': entry})

        if not history:
            return Response({
                'success': True, 'data': None,
                'message': 'No workout logs found.',
                'errors': None, 'pagination': None,
            })

        ai_url = f'{settings.AI_SERVICE_URL}/api/v1/workout/analyze'
        try:
            resp = ai_post(ai_url, json={'history': history}, timeout=30)
            resp.raise_for_status()
            audit_ai_call('workout_analysis', input_data={'history': history}, output_data=resp.json())
            return Response({
                'success': True, 'data': resp.json(),
                'message': 'Workout analysis complete.',
                'errors': None, 'pagination': None,
            })
        except http_requests.RequestException as e:
            audit_ai_call('workout_analysis', input_data={'history': history}, error_message=str(e))
            return Response({
                'success': False, 'data': None,
                'message': 'Workout analysis service unavailable.',
                'errors': str(e), 'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)


class HealthInsightsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        import requests as http_requests
        profile = request.user.profile
        period = request.query_params.get('period', 'weekly')

        cutoff = timezone.now() - timezone.timedelta(days=7 if period == 'weekly' else 30)
        workout_posts = Post.objects.filter(
            author=profile, post_type='workout_log',
            workout_log_data__isnull=False, created_at__gte=cutoff,
        ).order_by('created_at').values('workout_log_data', 'created_at')

        workouts = []
        for p in workout_posts:
            entry = dict(p['workout_log_data'])
            entry['date'] = p['created_at'].isoformat()
            workouts.append({'workout_log_data': entry})

        meals = []

        streak = {
            'days': profile.streak_days,
            'longest_streak': profile.streak_days,
        }

        payload = {
            'workouts': workouts,
            'meals': meals,
            'streak': streak,
            'period': period,
        }

        ai_url = f'{settings.AI_SERVICE_URL}/api/v1/health-insights/analyze'
        try:
            resp = ai_post(ai_url, json=payload, timeout=30)
            resp.raise_for_status()
            audit_ai_call('health_insights', input_data=payload, output_data=resp.json())
            return Response({
                'success': True, 'data': resp.json(),
                'message': 'Health insights generated.',
                'errors': None, 'pagination': None,
            })
        except http_requests.RequestException as e:
            audit_ai_call('health_insights', input_data=payload, error_message=str(e))
            return Response({
                'success': False, 'data': None,
                'message': 'Health insights service unavailable.',
                'errors': str(e), 'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)


class WorkoutFormAnalysisView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request):
        import requests as http_requests
        file = request.FILES.get('image')
        exercise = request.data.get('exercise', 'auto')

        if not file:
            return Response({
                'success': False, 'data': None,
                'message': 'No image provided.',
                'errors': 'image field is required.', 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        ai_url = f'{settings.AI_SERVICE_URL}/api/v1/form-analyzer/analyze'
        try:
            resp = ai_post(
                ai_url,
                files={'file': (file.name, file.read(), file.content_type)},
                data={'exercise': exercise},
                timeout=30,
            )
            resp.raise_for_status()
            audit_ai_call('form_analyzer', input_data={'exercise': exercise}, output_data=resp.json())
            return Response({
                'success': True, 'data': resp.json(),
                'message': 'Form analysis complete.',
                'errors': None, 'pagination': None,
            })
        except http_requests.RequestException as e:
            audit_ai_call('form_analyzer', input_data={'exercise': exercise}, error_message=str(e))
            return Response({
                'success': False, 'data': None,
                'message': 'Form analysis service unavailable.',
                'errors': str(e), 'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)


_STUDIO_TRANSCRIBE_MAX_BYTES = 150 * 1024 * 1024


class StudioTranscribeView(views.APIView):
    """POST /api/v1/feed/studio/transcribe/ — in-studio auto-captions.

    The create studio uploads the picked video while the user is still
    editing. Django validates the upload and streams it to the AI service
    over the internal network (no public URL needed), returning whisper
    segments so captions can be generated mid-session instead of only
    after publish.
    """

    permission_classes = [permissions.IsAuthenticated]
    throttle_scope = 'uploads'

    def post(self, request):
        import requests as http_requests
        file = request.FILES.get('media')
        if not file:
            return Response({
                'success': False, 'data': None,
                'message': 'No media provided.',
                'errors': 'media field is required.', 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)
        if file.size > _STUDIO_TRANSCRIBE_MAX_BYTES:
            return Response({
                'success': False, 'data': None,
                'message': 'Media is too large for in-studio transcription.',
                'errors': 'media must be 150 MB or smaller.', 'pagination': None,
            }, status=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE)

        ai_url = f'{settings.AI_SERVICE_URL}/api/v1/transcribe-file'
        try:
            resp = ai_post(
                ai_url,
                files={'file': (file.name, file.read(), file.content_type or 'application/octet-stream')},
                timeout=240,
            )
            if resp.status_code >= 400:
                detail = ''
                try:
                    detail = resp.json().get('detail', '')
                except (ValueError, AttributeError):
                    pass
                return Response({
                    'success': False, 'data': None,
                    'message': detail or 'Transcription unavailable.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_502_BAD_GATEWAY if resp.status_code >= 500 else status.HTTP_422_UNPROCESSABLE_ENTITY)
            audit_ai_call('studio_transcribe', input_data={'filename': file.name}, output_data={'segments': len(resp.json().get('segments', []))})
            return Response({
                'success': True, 'data': resp.json(),
                'message': 'Transcription complete.',
                'errors': None, 'pagination': None,
            })
        except http_requests.RequestException as e:
            audit_ai_call('studio_transcribe', input_data={'filename': file.name}, error_message=str(e))
            return Response({
                'success': False, 'data': None,
                'message': 'Transcription service unavailable.',
                'errors': str(e), 'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)


class SoundListCreateView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]
    throttle_scope = 'sounds_write'

    def get(self, request):
        sounds = Sound.objects.filter(is_active=True)
        q = request.query_params.get('q')
        if q:
            sounds = sounds.filter(db_models.Q(name__icontains=q) | db_models.Q(artist__icontains=q))
        ordering = request.query_params.get('ordering', 'recent')
        if ordering == 'trending':
            sounds = sounds.order_by('-usage_count', '-created_at')
        else:  # recent
            sounds = sounds.order_by('-created_at')

        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(sounds, request)
        serializer = SoundSerializer(page, many=True, context={'request': request})
        return Response({
            'success': True,
            'data': {'results': serializer.data},
            'message': 'OK',
            'errors': None,
            'pagination': {
                'count': paginator.page.paginator.count,
                'next': paginator.get_next_link(),
                'previous': paginator.get_previous_link(),
            },
        })

    def post(self, request):
        serializer = SoundCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        audio_url = data.get('audio_url') or ''
        sound = Sound.objects.create(
            name=data['name'],
            artist=data.get('artist') or '',
            audio_url=audio_url,
            duration_ms=data.get('duration_ms'),
            source='original',
            original_post=data.get('original_post'),
            is_active=bool(audio_url),
        )
        output = SoundSerializer(sound, context={'request': request})
        return Response({
            'success': True, 'data': output.data,
            'message': 'Sound created.', 'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class SoundUseView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]
    throttle_scope = 'sounds_write'

    def post(self, request, sound_id):
        sound = get_object_or_404(Sound, id=sound_id)
        Sound.objects.filter(id=sound.id).update(usage_count=F('usage_count') + 1)
        sound.refresh_from_db(fields=['usage_count'])
        return Response({
            'success': True,
            'data': {'id': str(sound.id), 'usage_count': sound.usage_count},
            'message': 'Sound usage recorded.',
            'errors': None,
            'pagination': None,
        })
