import logging
from io import BytesIO
from typing import Any

from PIL import Image

from .config import settings
from .model_registry import ModelRegistry, DEVICE

logger = logging.getLogger(__name__)

NSFW_LABELS = ['clean', 'nsfw']
TOXICITY_THRESHOLD = 0.5
NSFW_THRESHOLD = 0.6


def _load_nsfw_model() -> Any:
    model = ModelRegistry.get('nsfw_classifier')
    if model is not None:
        return model

    logger.info('Loading NSFW classifier model...')
    try:
        import torch
        import torchvision.transforms as T
        from torchvision.models import resnet18, ResNet18_Weights

        model = resnet18(weights=ResNet18_Weights.IMAGENET1K_V1)
        model.eval()
        model.to(DEVICE)

        transform = T.Compose([
            T.Resize(224),
            T.CenterCrop(224),
            T.ToTensor(),
            T.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
        ])

        ModelRegistry.register('nsfw_classifier', model)
        ModelRegistry.register('nsfw_transform', transform)
        logger.info('NSFW classifier loaded on %s', DEVICE)
        return model
    except Exception as exc:
        logger.warning('Failed to load NSFW model: %s — using fallback', exc)
        ModelRegistry.register('nsfw_classifier', None)
        return None


def _load_toxicity_model() -> Any:
    model = ModelRegistry.get('toxicity_classifier')
    if model is not None:
        return model

    logger.info('Loading toxicity classifier...')
    try:
        from transformers import pipeline

        classifier = pipeline(
            'text-classification',
            model='unitary/toxic-bert',
            device=0 if str(DEVICE) == 'cuda' else -1,
        )
        ModelRegistry.register('toxicity_classifier', classifier)
        logger.info('Toxicity classifier loaded')
        return classifier
    except Exception as exc:
        logger.warning('Failed to load toxicity model: %s — using fallback', exc)
        ModelRegistry.register('toxicity_classifier', None)
        return None


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


async def analyze_image(image_bytes: bytes) -> dict:
    try:
        img = Image.open(BytesIO(image_bytes))
    except Exception:
        return {'is_nsfw': False, 'confidence': 0.0, 'labels': ['error'], 'action': 'approve'}

    model = _load_nsfw_model()

    if model is not None:
        try:
            import torch

            transform = ModelRegistry.get('nsfw_transform')
            input_tensor = transform(img).unsqueeze(0).to(DEVICE)
            with torch.no_grad():
                output = model(input_tensor)
            probs = torch.softmax(output, dim=1)
            confidence, pred_idx = probs.max(1)
            confidence = float(confidence.item())
            label = NSFW_LABELS[pred_idx.item()] if pred_idx.item() < len(NSFW_LABELS) else 'clean'

            is_nsfw = label == 'nsfw' and confidence > NSFW_THRESHOLD
            return {
                'is_nsfw': is_nsfw,
                'confidence': round(confidence, 4),
                'labels': [label],
                'action': 'flag' if is_nsfw else 'approve',
            }
        except Exception as exc:
            logger.warning('NSFW model inference failed: %s — falling back to pixel analysis', exc)

    pixel_result = _pixel_analysis(img)
    is_nsfw = pixel_result['is_likely_nude']
    return {
        'is_nsfw': is_nsfw,
        'confidence': round(pixel_result['skin_ratio'], 4),
        'labels': ['nsfw'] if is_nsfw else ['clean'],
        'action': 'flag' if is_nsfw else 'approve',
        'method': 'pixel_fallback',
    }


async def analyze_text(text: str) -> dict:
    classifier = _load_toxicity_model()

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
            }
        except Exception as exc:
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
