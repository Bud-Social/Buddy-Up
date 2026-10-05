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


def _load_toxicity_tokenizer():
    """BERT tokenizer matching the 2.0.0 ONNX artifact (30522 x 768).

    Cached in ModelRegistry; prefers unitary/toxic-bert then bert-base-uncased.
    Returns None when offline so callers fall back to the HF pipeline.
    """
    cached = ModelRegistry.get('toxicity_tokenizer')
    if cached is not None:
        return cached
    try:
        from pathlib import Path

        from transformers import BertTokenizerFast

        repo_hf = Path(__file__).resolve().parents[2] / 'models' / 'hf'
        # Prefer a direct snapshot load (no hub cache writes, works offline
        # and without a writable /models mount in dev).
        for model_id in ('unitary/toxic-bert', 'bert-base-uncased'):
            slug = 'models--' + model_id.replace('/', '--')
            for base in (repo_hf / 'hub', Path(settings.model_cache_dir) / 'hf' / 'hub'):
                snap_root = base / slug / 'snapshots'
                if not snap_root.is_dir():
                    continue
                for snap in sorted(snap_root.iterdir()):
                    if (snap / 'vocab.txt').exists() or (snap / 'tokenizer.json').exists():
                        try:
                            tok = BertTokenizerFast.from_pretrained(str(snap))
                            ModelRegistry.register('toxicity_tokenizer', tok)
                            logger.info('Toxicity tokenizer loaded (%s snapshot)', model_id)
                            return tok
                        except Exception as exc:  # noqa: BLE001
                            logger.warning('Snapshot tokenizer failed (%s): %s', snap, exc)
                            break

        last_exc: Exception | None = None
        for model_id in ('unitary/toxic-bert', 'bert-base-uncased'):
            try:
                tok = BertTokenizerFast.from_pretrained(model_id, local_files_only=True)
                ModelRegistry.register('toxicity_tokenizer', tok)
                logger.info('Toxicity tokenizer loaded (%s)', model_id)
                return tok
            except Exception as exc:  # noqa: BLE001
                last_exc = exc
        logger.warning('Toxicity tokenizer unavailable (%s)', last_exc)
    except Exception as exc:  # noqa: BLE001
        logger.warning('transformers tokenizer unavailable (%s)', exc)
    return None


def _load_toxicity_onnx():
    """Load toxicity_classifier ONNX via serving (honours active version)."""
    cached = ModelRegistry.get('toxicity_classifier_onnx')
    if cached is not None:
        return cached
    try:
        from .ml.serving import artifact_path
        from .ml.serving import OnnxModel

        path = artifact_path('toxicity_classifier')
        if path is None:
            return None
        model = OnnxModel(str(path))
        ModelRegistry.register('toxicity_classifier_onnx', model)
        logger.info('Toxicity ONNX loaded (%s)', path)
        return model
    except Exception as exc:  # noqa: BLE001
        logger.warning('Toxicity ONNX unavailable (%s)', exc)
        return None


def _onnx_toxicity(text: str) -> dict | None:
    """Run the 2.0.0 BERT ONNX artifact; None when unavailable."""
    model = _load_toxicity_onnx()
    tok = _load_toxicity_tokenizer()
    if model is None or tok is None:
        return None
    try:
        import numpy as np

        enc = tok(text[:2000], max_length=128, padding='max_length',
                  truncation=True, return_tensors='np')
        inputs = {
            'input_ids': enc['input_ids'].astype(np.int64),
            'attention_mask': enc['attention_mask'].astype(np.int64),
        }
        # Keep only inputs the session expects (fp32 vs int64 variants).
        inputs = {k: v for k, v in inputs.items() if k in set(model.input_names)}
        logits = np.asarray(model.predict_dict(inputs)[0])
        flat = logits.reshape(-1)
        if flat.size == 1:
            score = float(1.0 / (1.0 + np.exp(-flat[0])))
        else:
            shifted = flat - flat.max()
            probs = np.exp(shifted) / np.exp(shifted).sum()
            # BERT 2-class head: index 1 = toxic (index 0 = clean).
            score = float(probs[1]) if probs.size > 1 else float(probs[0])
        is_toxic = score > TOXICITY_THRESHOLD
        return {
            'is_toxic': bool(is_toxic),
            'toxicity_score': round(score, 4),
            'categories': {'toxic': round(score, 4)},
            'label': 'toxic' if is_toxic else 'not_toxic',
            'action': 'flag' if is_toxic else 'approve',
            'method': 'onnx_2.0.0',
        }
    except Exception as exc:  # noqa: BLE001
        logger.warning('Toxicity ONNX inference failed: %s', exc)
        return None


def _keyword_toxicity(text: str) -> dict:
    toxic_keywords = [
        'kill yourself', 'harm yourself', 'hate', 'idiots', 'stupid',
        'nsfw', 'explicit', 'violence', 'idiot',
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

    onnx_result = _onnx_toxicity(text)
    if onnx_result is not None and onnx_result['is_toxic']:
        return onnx_result
    # Weak-model safety: a clean ONNX vote must not suppress the keyword
    # fallback (2.0.0 misses e.g. "you are an idiot" that keywords catch).
    # Fall through so HF/keyword can still flag; keep the ONNX score for
    # observability when everything is clean.
    keyword_result = _keyword_toxicity(text)
    if keyword_result['is_toxic']:
        if onnx_result is not None:
            keyword_result['categories'] = {
                **keyword_result['categories'],
                'onnx_2.0.0': onnx_result['toxicity_score'],
            }
        return keyword_result

    if onnx_result is not None:
        # ONNX + keyword agree: clean. Skip the heavy HF pipeline.
        return onnx_result

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

    if onnx_result is not None:
        # ONNX ran and was clean, keyword was clean: report the ONNX score.
        return onnx_result
    return _keyword_toxicity(text)
