"""Digital scale display -> weight reading (Florence-2 `<OCR>`, CPU INT8).

Given a photo of a smart/bathroom scale display, extract the on-screen weight
via Florence-2's `<OCR>` task and parse it into a numeric weight (kg or lb).
Degrades gracefully: if the vision model is unavailable or no digit can be
confidently parsed, it returns an empty result so callers can fall back to
manual entry.
"""
import logging
import re
from io import BytesIO

from PIL import Image

from .config import settings
from .model_registry import ModelRegistry, DEVICE
from .ml.hf_utils import load_preferred_hf

logger = logging.getLogger(__name__)

MODEL_NAME = settings.caption_model or 'florence-community/Florence-2-base'

# Accept common digital-scale formats: "72.5", "72,5", "160 lb", "72.5 kg".
_WEIGHT_PATTERNS = [
    re.compile(r'(\d{2,3})[.,](\d)\s*(?:kg|kgs?|kilo|kilograms)?\b', re.IGNORECASE),
    re.compile(r'(\d{2,3})\s*(?:kg|kgs?|kilo|kilograms)\b', re.IGNORECASE),
    re.compile(r'(\d{2,3})[.,](\d)\s*(?:lb|lbs|pounds)?\b', re.IGNORECASE),
    re.compile(r'(\d{2,3})\s*(?:lb|lbs|pounds)\b', re.IGNORECASE),
]
# Only trust readings inside a sane human-weight range.
MIN_KG, MAX_KG = 25.0, 350.0
LB_TO_KG = 0.45359237


def _get_model():
    cached = ModelRegistry.get(MODEL_NAME)
    if cached is not None:
        return cached

    from transformers import Florence2ForConditionalGeneration
    import torch

    def factory():
        return Florence2ForConditionalGeneration.from_pretrained(
            MODEL_NAME,
            dtype=torch.float32,
            device_map={'': str(DEVICE)},
        )

    model = load_preferred_hf(MODEL_NAME, factory)
    ModelRegistry.register(f'{MODEL_NAME}-processor', _get_processor())
    return model


def _get_processor():
    processor = ModelRegistry.get(f'{MODEL_NAME}-processor')
    if processor is None:
        from transformers import AutoProcessor

        processor = AutoProcessor.from_pretrained(MODEL_NAME)
        ModelRegistry.register(f'{MODEL_NAME}-processor', processor)
    return processor


def _ocr_text(image: Image.Image) -> str:
    model = _get_model()
    processor = _get_processor()
    prompt = '<OCR>'
    inputs = processor(text=prompt, images=image, return_tensors='pt').to(DEVICE)
    generated_ids = model.generate(
        input_ids=inputs['input_ids'],
        pixel_values=inputs['pixel_values'],
        max_new_tokens=64,
        do_sample=False,
        num_beams=3,
    )
    text = processor.batch_decode(generated_ids, skip_special_tokens=False)[0]
    parsed = processor.post_process_generation(text, task=prompt, image_size=(image.width, image.height))
    result = parsed.get(prompt, '')
    if not result:
        result = text.replace('<pad>', '').replace('</s>', '').replace('<unk>', '').strip()
    return result.strip()


def _parse_weight(raw: str) -> dict:
    """Parse OCR text into {weight_kg, weight_lb, unit, confidence} or None."""
    if not raw:
        return {'weight_kg': None, 'weight_lb': None, 'unit': 'kg', 'confidence': 0.0, 'raw_text': ''}

    for pattern in _WEIGHT_PATTERNS:
        match = pattern.search(raw)
        if not match:
            continue
        groups = match.groups()
        if len(groups) == 2:
            value = float(f'{groups[0]}.{groups[1]}')
        else:
            value = float(groups[0])
        suffix = match.group(0).lower()
        unit = 'lb' if ('lb' in suffix or 'pound' in suffix) else 'kg'
        if unit == 'lb':
            kg = value * LB_TO_KG
        else:
            kg = value

        if MIN_KG <= kg <= MAX_KG:
            confidence = 0.9 if unit == 'kg' else 0.8
            return {
                'weight_kg': round(kg, 1),
                'weight_lb': round(value if unit == 'lb' else kg / LB_TO_KG, 1),
                'unit': unit,
                'confidence': confidence,
                'raw_text': raw[:200],
            }
        logger.info('OCR weight %s out of plausible range — ignoring', value)

    logger.info('No plausible weight parsed from OCR text: %r', raw)
    return {'weight_kg': None, 'weight_lb': None, 'unit': 'kg', 'confidence': 0.0, 'raw_text': raw[:200]}


def read_scale_weight(image_bytes: bytes) -> dict:
    """Return the weight shown on a scale display photo, or an empty result."""
    try:
        image = Image.open(BytesIO(image_bytes))
        image.load()
    except Exception as exc:
        logger.warning('Weight image decode failed: %s', exc)
        return {'weight_kg': None, 'weight_lb': None, 'unit': 'kg', 'confidence': 0.0, 'raw_text': '', 'method': 'error'}

    try:
        raw = _ocr_text(image)
        parsed = _parse_weight(raw)
        parsed['method'] = 'florence-2'
        return parsed
    except Exception as exc:
        logger.warning('Weight OCR failed (%s) — returning empty', exc)
        return {'weight_kg': None, 'weight_lb': None, 'unit': 'kg', 'confidence': 0.0, 'raw_text': '', 'method': 'error'}
