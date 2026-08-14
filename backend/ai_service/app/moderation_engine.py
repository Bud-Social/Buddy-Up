import logging
import os
import tempfile
from io import BytesIO

from PIL import Image

from .config import settings
from .model_registry import ModelRegistry

logger = logging.getLogger(__name__)

TOXICITY_THRESHOLD = 0.5

# NudeNet categories that warrant flagging, grouped by sensitivity.
HIGH_SENSITIVITY = {
    'EXPOSED_GENITALIA_F', 'EXPOSED_GENITALIA_M',
    'FEMALE_GENITALIA_EXPOSED', 'MALE_GENITALIA_EXPOSED',
    'EXPOSED_ANUS', 'SEXUAL_ACTIVITY',
}
MEDIUM_SENSITIVITY = {
    'EXPOSED_BREAST_F', 'EXPOSED_BUTTOCKS',
    'FEMALE_BREAST_EXPOSED', 'BUTTOCKS_EXPOSED',
}
HIGH_THRESHOLD = 0.5
MEDIUM_THRESHOLD = 0.65


def _load_nudenet():
    """Load the NudeNet ONNX detector (purpose-built NSFW model)."""
    model = ModelRegistry.get('nsfw_classifier')
    if model is not None:
        return model or None

    try:
        from nudenet import NudeDetector
        detector = NudeDetector()
        ModelRegistry.register('nsfw_classifier', detector)
        logger.info('NudeNet NSFW detector loaded')
        return detector
    except Exception as exc:  # noqa: BLE001
        logger.warning('NudeNet unavailable (%s) — falling back to pixel analysis', exc)
        ModelRegistry.register('nsfw_classifier', None)
        return None


def _classify_detections(detections: list[dict]) -> dict:
    if not detections:
        return {'is_nsfw': False, 'confidence': 0.0, 'labels': ['clean'], 'method': 'nudenet'}

    high = [d for d in detections if d.get('class', '').upper() in HIGH_SENSITIVITY]
    med = [d for d in detections if d.get('class', '').upper() in MEDIUM_SENSITIVITY]

    high_max = max((float(d.get('score', 0)) for d in high), default=0.0)
    med_max = max((float(d.get('score', 0)) for d in med), default=0.0)

    is_nsfw = high_max >= HIGH_THRESHOLD or med_max >= MEDIUM_THRESHOLD
    labels = [d['class'].replace('_', ' ').title() for d in (high + med) if float(d.get('score', 0)) > 0.3]
    confidence = max(high_max, med_max)

    return {
        'is_nsfw': is_nsfw,
        'confidence': round(confidence, 4),
        'labels': labels or (['nsfw'] if is_nsfw else ['clean']),
        'action': 'flag' if is_nsfw else 'approve',
        'method': 'nudenet',
    }


def _pixel_analysis(image: Image.Image) -> dict:
    rgb = image.convert('RGB')
    pixels = list(rgb.getdata())
    total = len(pixels)
    if total == 0:
        return {'skin_ratio': 0.0, 'avg_brightness': 0, 'is_likely_nude': False}

    skin_pixels = sum(
        1 for r, g, b in pixels
        if r > 95 and g > 40 and b > 20
        and max(r, g, b) - min(r, g, b) > 15
        and abs(r - g) > 15
        and r > g and r > b
    )

    avg_brightness = sum(r + g + b for r, g, b in pixels) // (3 * total)
    skin_ratio = skin_pixels / total

    return {
        'skin_ratio': skin_ratio,
        'avg_brightness': avg_brightness,
        'is_likely_nude': skin_ratio > 0.35,
    }


def _nudenet_analyze(image_bytes: bytes) -> dict | None:
    detector = _load_nudenet()
    if detector is None:
        return None

    fd, path = tempfile.mkstemp(suffix='.jpg')
    try:
        with os.fdopen(fd, 'wb') as fh:
            fh.write(image_bytes)
        detections = detector.detect(path)
        return _classify_detections(detections)
    except Exception as exc:  # noqa: BLE001
        logger.warning('NudeNet inference failed: %s — falling back to pixel analysis', exc)
        return None
    finally:
        try:
            os.remove(path)
        except OSError:
            pass


async def analyze_image(image_bytes: bytes) -> dict:
    try:
        img = Image.open(BytesIO(image_bytes))
    except Exception:  # noqa: BLE001
        return {'is_nsfw': False, 'confidence': 0.0, 'labels': ['error'], 'action': 'approve', 'method': 'error'}

    result = _nudenet_analyze(image_bytes)
    if result is not None:
        return result

    pixel_result = _pixel_analysis(img)
    is_nsfw = pixel_result['is_likely_nude']
    return {
        'is_nsfw': is_nsfw,
        'confidence': round(pixel_result['skin_ratio'], 4),
        'labels': ['nsfw'] if is_nsfw else ['clean'],
        'action': 'flag' if is_nsfw else 'approve',
        'method': 'pixel_fallback',
    }


async def _openai_moderate(text: str) -> dict | None:
    """LLM-as-judge via the OpenAI moderation endpoint (returns None if not configured)."""
    if not settings.openai_api_key:
        return None
    import httpx

    url = f'{settings.openai_base_url.rstrip("/")}/moderations'
    headers = {
        'Authorization': f'Bearer {settings.openai_api_key}',
        'Content-Type': 'application/json',
    }
    try:
        async with httpx.AsyncClient(timeout=20) as client:
            resp = await client.post(url, headers=headers, json={'input': text[:4000]})
            resp.raise_for_status()
            data = resp.json()
        result = data['results'][0]
        scores = result.get('category_scores', {})
        flagged = result.get('flagged', False)
        max_score = max(scores.values(), default=0.0)
        return {
            'is_toxic': bool(flagged),
            'toxicity_score': round(float(max_score), 4),
            'categories': {k: round(float(v), 4) for k, v in scores.items()},
            'label': 'toxic' if flagged else 'not_toxic',
            'action': 'flag' if flagged else 'approve',
            'method': 'openai_moderation',
        }
    except Exception as exc:  # noqa: BLE001
        logger.warning('OpenAI moderation failed: %s', exc)
        return None


async def analyze_text(text: str) -> dict:
    if not text or not text.strip():
        return {
            'is_toxic': False,
            'toxicity_score': 0.0,
            'categories': {},
            'label': 'not_toxic',
            'action': 'approve',
            'method': 'empty',
        }

    openai_result = await _openai_moderate(text)
    if openai_result is not None:
        return openai_result

    classifier = ModelRegistry.get('toxicity_classifier')
    if classifier is None:
        try:
            from transformers import pipeline
            import torch
            device = 0 if torch.cuda.is_available() else -1
            classifier = pipeline(
                'text-classification',
                model='unitary/toxic-bert',
                device=device,
            )
            ModelRegistry.register('toxicity_classifier', classifier)
            logger.info('Toxicity classifier loaded')
        except Exception as exc:  # noqa: BLE001
            logger.warning('Failed to load toxicity model: %s — using keyword fallback', exc)

    if classifier is not None:
        try:
            result = classifier(text[:512])[0]
            label = result['label']
            score = result['score']
            is_toxic = score > TOXICITY_THRESHOLD and label.lower() != 'not_toxic'
            return {
                'is_toxic': is_toxic,
                'toxicity_score': round(score, 4),
                'categories': {label.lower(): score},
                'label': label,
                'action': 'flag' if is_toxic else 'approve',
                'method': 'model',
            }
        except Exception as exc:  # noqa: BLE001
            logger.warning('Toxicity inference failed: %s — using keyword fallback', exc)

    toxic_keywords = [
        'kill yourself', 'harm yourself', 'hate', 'idiots', 'stupid',
        'nsfw', 'explicit', 'violence',
    ]
    text_lower = text.lower()
    matched = [kw for kw in toxic_keywords if kw in text_lower]
    is_toxic = len(matched) > 0

    return {
        'is_toxic': is_toxic,
        'toxicity_score': 0.5 if is_toxic else 0.0,
        'categories': {kw: 0.5 for kw in matched} if is_toxic else {},
        'label': 'toxic' if is_toxic else 'not_toxic',
        'action': 'flag' if is_toxic else 'approve',
        'method': 'keyword_fallback',
    }
