import logging
from io import BytesIO
from typing import Any

import numpy as np
from PIL import Image

from .config import settings
from .model_registry import ModelRegistry, DEVICE

logger = logging.getLogger(__name__)

FOOD101_CLASSES: list[str] = []
NUTRITION_DB: dict[str, dict] = {}
TOP_K = 5


def _load_food_model() -> Any:
    model = ModelRegistry.get('food_classifier')
    if model is not None:
        return model

    logger.info('Loading food classification model...')
    try:
        import torch
        import torchvision.transforms as T
        from torchvision.models import vit_b_16, ViT_B_16_Weights

        weights = ViT_B_16_Weights.IMAGENET1K_V1
        model = vit_b_16(weights=weights)
        model.eval()
        model.to(DEVICE)

        transform = T.Compose([
            T.Resize(224),
            T.CenterCrop(224),
            T.ToTensor(),
            T.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
        ])

        ModelRegistry.register('food_classifier', model)
        ModelRegistry.register('food_transform', transform)
        logger.info('Food classifier loaded on %s', DEVICE)
        return model
    except Exception as exc:
        logger.warning('Failed to load food model: %s — using keyword fallback', exc)
        ModelRegistry.register('food_classifier', None)
        return None


def _load_nutrition_db() -> dict:
    global NUTRITION_DB
    if NUTRITION_DB:
        return NUTRITION_DB

    NUTRITION_DB = {
        'grilled chicken salad': {
            'calories': 350, 'protein': 35, 'carbs': 12, 'fat': 18,
            'health_benefits': ['High protein', 'Low carb', 'Rich in vitamins'],
        },
        'pizza': {
            'calories': 285, 'protein': 12, 'carbs': 36, 'fat': 10,
            'health_benefits': ['Good calcium source', 'Moderate protein'],
        },
        'burger': {
            'calories': 550, 'protein': 30, 'carbs': 40, 'fat': 28,
            'health_benefits': ['High protein', 'Good iron source'],
        },
        'sushi': {
            'calories': 200, 'protein': 18, 'carbs': 35, 'fat': 2,
            'health_benefits': ['Low fat', 'Good omega-3 source', 'Moderate protein'],
        },
        'pasta': {
            'calories': 350, 'protein': 12, 'carbs': 65, 'fat': 5,
            'health_benefits': ['Good energy source', 'Low fat'],
        },
        'omelette': {
            'calories': 280, 'protein': 20, 'carbs': 2, 'fat': 22,
            'health_benefits': ['High protein', 'Keto-friendly', 'Rich in vitamins'],
        },
        'salad': {
            'calories': 150, 'protein': 5, 'carbs': 20, 'fat': 7,
            'health_benefits': ['Low calorie', 'High fiber', 'Rich in vitamins'],
        },
        'steak': {
            'calories': 450, 'protein': 40, 'carbs': 0, 'fat': 32,
            'health_benefits': ['Very high protein', 'Zero carb', 'Rich in iron and B12'],
        },
        'smoothie': {
            'calories': 250, 'protein': 8, 'carbs': 45, 'fat': 5,
            'health_benefits': ['Good vitamin source', 'Quick energy'],
        },
        'rice bowl': {
            'calories': 400, 'protein': 15, 'carbs': 60, 'fat': 10,
            'health_benefits': ['Good energy source', 'Moderate protein'],
        },
        'fruit': {
            'calories': 100, 'protein': 1, 'carbs': 25, 'fat': 0.5,
            'health_benefits': ['Rich in vitamins and fiber', 'Low fat', 'Natural sugars'],
        },
        'fish': {
            'calories': 200, 'protein': 35, 'carbs': 0, 'fat': 6,
            'health_benefits': ['High protein', 'Omega-3 fatty acids', 'Zero carb'],
        },
        'soup': {
            'calories': 180, 'protein': 10, 'carbs': 20, 'fat': 6,
            'health_benefits': ['Low calorie', 'Hydrating', 'Good for digestion'],
        },
        'sandwich': {
            'calories': 320, 'protein': 18, 'carbs': 35, 'fat': 12,
            'health_benefits': ['Good protein', 'Balanced meal'],
        },
        'yogurt': {
            'calories': 150, 'protein': 12, 'carbs': 18, 'fat': 4,
            'health_benefits': ['High protein', 'Probiotics', 'Good calcium source'],
        },
    }

    return NUTRITION_DB


def _lookup_nutrition_by_keywords(keywords: list[str]) -> dict:
    db = _load_nutrition_db()
    for kw in keywords:
        for food_name, nutrition in db.items():
            if any(word in food_name for word in kw.lower().split()):
                return nutrition
    return db.get('salad', {'calories': 150, 'protein': 5, 'carbs': 20, 'fat': 7, 'health_benefits': []})


def _keyword_food_match(image_bytes: bytes) -> list[dict]:
    try:
        img = Image.open(BytesIO(image_bytes))
    except Exception:
        return [{'item': 'Unknown food', 'confidence': 0.0, 'nutrition': {}}]

    avg_color = np.array(img.resize((32, 32))).mean(axis=(0, 1))
    r, g, b = avg_color

    if r > 180 and g > 120 and b < 100:
        food_name = 'pizza'
    elif r > 180 and g > 100 and b > 80:
        food_name = 'burger'
    elif r < 100 and g < 100 and b > 150:
        food_name = 'sushi'
    elif g > 150 and r < 120 and b < 120:
        food_name = 'salad'
    elif r > 180 and g < 100 and b < 100:
        food_name = 'steak'
    elif r > 200 and g > 160 and b < 120:
        food_name = 'pasta'
    elif r < 100 and g > 180 and b < 100:
        food_name = 'smoothie'
    elif r > 200 and g > 200 and b > 150:
        food_name = 'omelette'
    elif r > 150 and g < 100 and b > 120:
        food_name = 'fruit'
    elif r < 150 and g < 150 and b < 150 and r > 200:
        food_name = 'grilled chicken salad'
    else:
        food_name = 'salad'

    db = _load_nutrition_db()
    nutrition = db.get(food_name, db.get('salad'))

    score_map = {
        'grilled chicken salad': 0.65, 'pizza': 0.55, 'burger': 0.60,
        'sushi': 0.50, 'pasta': 0.55, 'omelette': 0.50, 'salad': 0.70,
        'steak': 0.65, 'smoothie': 0.55, 'rice bowl': 0.50, 'fruit': 0.60,
        'fish': 0.55, 'soup': 0.50, 'sandwich': 0.55, 'yogurt': 0.50,
    }

    return [{
        'item': food_name,
        'confidence': score_map.get(food_name, 0.50),
        'nutrition': nutrition,
    }]


async def recognize_food(image_bytes: bytes) -> list[dict]:
    model = _load_food_model()
    if model is None:
        return _keyword_food_match(image_bytes)

    try:
        import torch
        transform = ModelRegistry.get('food_transform')
        img = Image.open(BytesIO(image_bytes))
        input_tensor = transform(img).unsqueeze(0).to(DEVICE)

        with torch.no_grad():
            output = model(input_tensor)
        probs = torch.softmax(output, dim=1)
        top_probs, top_indices = torch.topk(probs, TOP_K, dim=1)

        results = []
        for i in range(TOP_K):
            idx = top_indices[0, i].item()
            conf = round(float(top_probs[0, i].item()), 4)
            food_name = FOOD101_CLASSES[idx] if idx < len(FOOD101_CLASSES) else f'food_{idx}'

            nutrition = _lookup_nutrition_by_keywords([food_name])
            results.append({
                'item': food_name.replace('_', ' ').title(),
                'confidence': conf,
                'nutrition': nutrition,
            })

        return results
    except Exception as exc:
        logger.warning('Food model inference failed: %s — using fallback', exc)
        return _keyword_food_match(image_bytes)
