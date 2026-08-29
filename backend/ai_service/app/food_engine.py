import json
import logging
from io import BytesIO
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image

from .model_registry import ModelRegistry, DEVICE
from .ml.serving import load_preferred, OnnxModel

logger = logging.getLogger(__name__)

NUTRITION_DB: dict[str, dict] = {}
TOP_K = 5

# Maps normalized ImageNet-1k category names (ViT outputs 1000 ImageNet logits,
# NOT Food-101 indices) to keys in NUTRITION_DB.
FOOD_IMAGENET_MAP: dict[str, str] = {
    'hamburger': 'burger',
    'cheeseburger': 'burger',
    'hotdog': 'hotdog',
    'hot dog': 'hotdog',
    'pizza': 'pizza',
    'burrito': 'burrito',
    'taco': 'burrito',
    'guacamole': 'salad',
    'mashed potato': 'mashed potato',
    'ice cream': 'ice cream',
    'icecream': 'ice cream',
    'chocolate sauce': 'chocolate cake',
    'chocolate cake': 'chocolate cake',
    'bagel': 'bagel',
    'pretzel': 'pretzel',
    'popcorn': 'popcorn',
    'fried rice': 'fried rice',
    'pancake': 'pancake',
    'pancakes': 'pancake',
    'waffle': 'waffle',
    'waffles': 'waffle',
    'carbonara': 'pasta',
    'spaghetti': 'pasta',
    'beef stroganoff': 'beef stroganoff',
    'meat loaf': 'meat loaf',
    'meatloaf': 'meat loaf',
    'grilled salmon': 'fish',
    'salmon': 'fish',
    'baklava': 'chocolate cake',
    'corn': 'corn',
    'cauliflower': 'broccoli',
    'broccoli': 'broccoli',
    'mushroom': 'mushroom',
    'strawberry': 'strawberry',
    'orange': 'orange',
    'lemon': 'fruit',
    'fig': 'fruit',
    'pineapple': 'fruit',
    'banana': 'banana',
    'jackfruit': 'fruit',
    'custard apple': 'fruit',
    'pomegranate': 'fruit',
    'apple': 'apple',
    'green salad': 'salad',
    'grocery store': 'fruit',
    'espresso': 'smoothie',
    'potpie': 'soup',
    'chocolate milk': 'smoothie',
    'eggnog': 'smoothie',
    'dough': 'bread',
    'muffin': 'muffin',
    'croissant': 'muffin',
    'baguette': 'bread',
    'french loaf': 'bread',
    'sandwich': 'sandwich',
    'submarine sandwich': 'sandwich',
    'club sandwich': 'sandwich',
    'cheese': 'cheese',
    'cheddar': 'cheese',
    'eggs': 'omelette',
    'fried egg': 'omelette',
    'omelet': 'omelette',
    'egg': 'omelette',
}


def _normalise_category(category: str) -> str:
    return category.strip().lower().replace('-', ' ').replace('_', ' ')


def _imagenet_to_food(category: str) -> str | None:
    return FOOD_IMAGENET_MAP.get(_normalise_category(category))


def _load_imagenet_categories(model: Any) -> list[str] | None:
    """Extract the 1000 ImageNet-1k category names for the loaded model."""
    weights = getattr(model, 'weights', None)
    meta = getattr(weights, 'meta', None) or {}
    categories = meta.get('categories')
    if isinstance(categories, list) and len(categories) == 1000:
        return categories
    try:
        from torchvision.models import ViT_B_16_Weights
        meta = ViT_B_16_Weights.IMAGENET1K_V1.meta
        categories = meta.get('categories')
        if isinstance(categories, list) and len(categories) == 1000:
            return categories
    except Exception:  # noqa: BLE001
        pass
    return None


def _read_artifact_metadata(artifact: Path, name: str) -> dict:
    """metadata.json shipped next to an exported ONNX artifact (tf_utils.export).

    Checks the namespaced copy first (shared flat dirs), then the plain
    metadata.json; the `name` field must match to avoid cross-model mixups.
    """
    for cand in (artifact.parent / f'{name}.metadata.json',
                 artifact.parent / 'metadata.json'):
        try:
            if not cand.exists():
                continue
            data = json.loads(cand.read_text())
            if data.get('name') == name:
                return data
        except Exception:  # noqa: BLE001
            continue
    return {}


def _load_artifact_classes() -> list[str] | None:
    """Class names for the loaded ONNX food_classifier from its metadata.json."""
    model = ModelRegistry.get('food_classifier')
    path = getattr(model, 'path', None)
    if not path:
        return None
    classes = _read_artifact_metadata(Path(path), 'food_classifier').get('classes')
    if isinstance(classes, list) and classes and all(isinstance(c, str) for c in classes):
        return classes
    return None


def _load_food_model() -> Any:
    model = ModelRegistry.get('food_classifier')
    if model is not None:
        return model

    def _torch_factory():
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
        ModelRegistry.register('food_transform', transform)
        logger.info('Food classifier loaded on %s', DEVICE)
        return model

    logger.info('Loading food classification model...')
    try:
        model = load_preferred('food_classifier', _torch_factory)
        ModelRegistry.register('food_classifier', model)
        return model
    except Exception as exc:  # noqa: BLE001
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
        'hotdog': {
            'calories': 290, 'protein': 11, 'carbs': 24, 'fat': 17,
            'health_benefits': ['Quick energy', 'Moderate protein'],
        },
        'burrito': {
            'calories': 450, 'protein': 18, 'carbs': 55, 'fat': 17,
            'health_benefits': ['High fiber', 'Good energy source'],
        },
        'mashed potato': {
            'calories': 210, 'protein': 4, 'carbs': 35, 'fat': 8,
            'health_benefits': ['Good carbohydrate source', 'Potassium rich'],
        },
        'ice cream': {
            'calories': 270, 'protein': 4, 'carbs': 32, 'fat': 14,
            'health_benefits': ['Calcium source', 'Good energy source'],
        },
        'chocolate cake': {
            'calories': 420, 'protein': 5, 'carbs': 60, 'fat': 19,
            'health_benefits': ['Good energy source', 'Antioxidants'],
        },
        'bagel': {
            'calories': 280, 'protein': 11, 'carbs': 56, 'fat': 2,
            'health_benefits': ['Good carbohydrate source', 'Low fat'],
        },
        'pretzel': {
            'calories': 380, 'protein': 10, 'carbs': 79, 'fat': 3,
            'health_benefits': ['Low fat', 'Good energy source'],
        },
        'popcorn': {
            'calories': 380, 'protein': 12, 'carbs': 77, 'fat': 4,
            'health_benefits': ['High fiber', 'Low fat', 'Whole grain'],
        },
        'fried rice': {
            'calories': 330, 'protein': 9, 'carbs': 55, 'fat': 9,
            'health_benefits': ['Good energy source', 'Moderate protein'],
        },
        'pancake': {
            'calories': 310, 'protein': 8, 'carbs': 55, 'fat': 8,
            'health_benefits': ['Good energy source', 'Calcium source'],
        },
        'waffle': {
            'calories': 290, 'protein': 8, 'carbs': 45, 'fat': 11,
            'health_benefits': ['Good energy source', 'Calcium source'],
        },
        'beef stroganoff': {
            'calories': 380, 'protein': 28, 'carbs': 30, 'fat': 16,
            'health_benefits': ['High protein', 'Good iron source'],
        },
        'meat loaf': {
            'calories': 260, 'protein': 22, 'carbs': 12, 'fat': 14,
            'health_benefits': ['High protein', 'Good iron source'],
        },
        'corn': {
            'calories': 90, 'protein': 3, 'carbs': 20, 'fat': 1,
            'health_benefits': ['High fiber', 'Vitamins', 'Low fat'],
        },
        'broccoli': {
            'calories': 35, 'protein': 2, 'carbs': 7, 'fat': 0.5,
            'health_benefits': ['High fiber', 'Rich in vitamins', 'Low calorie'],
        },
        'mushroom': {
            'calories': 22, 'protein': 3, 'carbs': 3, 'fat': 0.5,
            'health_benefits': ['Low calorie', 'Rich in minerals', 'Low fat'],
        },
        'strawberry': {
            'calories': 32, 'protein': 1, 'carbs': 8, 'fat': 0.5,
            'health_benefits': ['Rich in vitamin C', 'Low calorie', 'Antioxidants'],
        },
        'orange': {
            'calories': 47, 'protein': 1, 'carbs': 12, 'fat': 0.2,
            'health_benefits': ['Rich in vitamin C', 'Hydrating', 'Low calorie'],
        },
        'banana': {
            'calories': 89, 'protein': 1, 'carbs': 23, 'fat': 0.5,
            'health_benefits': ['Rich in potassium', 'Quick energy'],
        },
        'apple': {
            'calories': 52, 'protein': 0.5, 'carbs': 14, 'fat': 0.2,
            'health_benefits': ['High fiber', 'Rich in vitamins', 'Low calorie'],
        },
        'muffin': {
            'calories': 320, 'protein': 5, 'carbs': 55, 'fat': 11,
            'health_benefits': ['Good energy source', 'Quick breakfast option'],
        },
        'cheese': {
            'calories': 400, 'protein': 25, 'carbs': 3, 'fat': 33,
            'health_benefits': ['High protein', 'Good calcium source'],
        },
        'bread': {
            'calories': 265, 'protein': 9, 'carbs': 49, 'fat': 3,
            'health_benefits': ['Good carbohydrate source', 'Low fat'],
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


def _match_food_by_text(text: str) -> tuple[str | None, dict]:
    """Return (food_name, nutrition) for text, searching NUTRITION_DB keys."""
    db = _load_nutrition_db()
    words = [w for w in text.lower().split() if w]
    for food_name, nutrition in db.items():
        if any(word in food_name for word in words):
            return food_name, nutrition
    return None, {}


def _keyword_food_match(image_bytes: bytes) -> list[dict]:
    try:
        img = Image.open(BytesIO(image_bytes))
    except Exception:  # noqa: BLE001
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

        if isinstance(model, OnnxModel):
            input_tensor = transform(img).unsqueeze(0)
            logits = model.predict(input_tensor.detach().numpy())
            output = torch.from_numpy(logits)
            device_out = output
        else:
            input_tensor = transform(img).unsqueeze(0).to(DEVICE)
            with torch.no_grad():
                output = model(input_tensor)
            device_out = output

        probs = torch.softmax(device_out, dim=1)
        top_probs, top_indices = torch.topk(probs, TOP_K, dim=1)

        # Exported Food-101 artifacts carry their class list in metadata.json;
        # the raw torchvision fallback decodes via ImageNet-1k labels.
        categories = _load_artifact_classes() or (_load_imagenet_categories(model) or [])
        results = []
        for i in range(TOP_K):
            idx = top_indices[0, i].item()
            conf = round(float(top_probs[0, i].item()), 4)
            category = categories[idx] if idx < len(categories) else ''

            # Food-101 metadata classes use underscores ('apple_pie'); ImageNet
            # categories use spaces ('hot dog') — match on the spaced form.
            match_key = category.replace('_', ' ')
            food_name = _imagenet_to_food(match_key) if match_key else None
            if food_name is None and match_key:
                food_name, _ = _match_food_by_text(match_key)

            display_name = food_name.replace('_', ' ').title() if food_name else (
                category.replace('_', ' ').title() if category else 'Unknown Food'
            )
            nutrition = _load_nutrition_db().get(food_name) if food_name else {}
            results.append({
                'item': display_name,
                'confidence': conf,
                'nutrition': nutrition or {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0, 'health_benefits': []},
            })

        if results and all(not r['nutrition'].get('calories') for r in results):
            logger.info('No food categories matched — using keyword fallback')
            return _keyword_food_match(image_bytes)

        return results
    except Exception as exc:  # noqa: BLE001
        logger.warning('Food model inference failed: %s — using fallback', exc)
        return _keyword_food_match(image_bytes)
