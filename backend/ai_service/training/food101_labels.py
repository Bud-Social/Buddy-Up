"""Food-101 → nutrition-key label map (Phase A patch).

The ViT serving model emits ImageNet-1k category names, NOT Food-101 indices.
For training we patch the 101 fine-grained classes onto the same nutrition keys
used by the serving ``NUTRITION_DB`` (app/food_engine.py) so train and serve
agree on labels. Each class also gets a coarse macro ``bucket`` used to fill
nutrition when no exact key exists.

    mapping = { 'pizza': ('pizza', 'fastfood'), 'greek_salad': ('salad', 'salad'), ... }
"""

Label = tuple[str, str]  # (nutrition_key, bucket)

FOOD101_LABELS: dict[str, Label] = {
    # baked / desserts
    'apple_pie': ('chocolate cake', 'dessert'),
    'baklava': ('chocolate cake', 'dessert'),
    'beignets': ('muffin', 'dessert'),
    'bread_pudding': ('muffin', 'dessert'),
    'cannoli': ('chocolate cake', 'dessert'),
    'carrot_cake': ('chocolate cake', 'dessert'),
    'cheesecake': ('chocolate cake', 'dessert'),
    'chocolate_mousse': ('chocolate cake', 'dessert'),
    'churros': ('muffin', 'dessert'),
    'creme_brulee': ('chocolate cake', 'dessert'),
    'cup_cakes': ('chocolate cake', 'dessert'),
    'donuts': ('muffin', 'dessert'),
    'frozen_yogurt': ('yogurt', 'dairy'),
    'ice_cream': ('ice cream', 'dessert'),
    'macarons': ('chocolate cake', 'dessert'),
    'panna_cotta': ('yogurt', 'dairy'),
    'red_velvet_cake': ('chocolate cake', 'dessert'),
    'strawberry_shortcake': ('chocolate cake', 'dessert'),
    'tiramisu': ('chocolate cake', 'dessert'),
    # breakfast / breads
    'croque_madame': ('sandwich', 'sandwich'),
    'eggs_benedict': ('omelette', 'breakfast'),
    'french_toast': ('pancake', 'breakfast'),
    'garlic_bread': ('bread', 'bread'),
    'huevos_rancheros': ('burrito', 'breakfast'),
    'omelette': ('omelette', 'breakfast'),
    'pancakes': ('pancake', 'breakfast'),
    'waffles': ('waffle', 'breakfast'),
    'breakfast_burrito': ('burrito', 'fastfood'),
    # pizza / burgers / fast food
    'pizza': ('pizza', 'fastfood'),
    'hamburger': ('burger', 'fastfood'),
    'hot_dog': ('hotdog', 'fastfood'),
    'nachos': ('cheese', 'fastfood'),
    'poutine': ('french fries', 'fastfood'),
    'french_fries': ('fried rice', 'fastfood'),
    'onion_rings': ('fried rice', 'fastfood'),
    # seafood
    'clam_chowder': ('soup', 'seafood'),
    'lobster_bisque': ('soup', 'seafood'),
    'miso_soup': ('soup', 'soup'),
    'hot_and_sour_soup': ('soup', 'soup'),
    'fried_calamari': ('fish', 'seafood'),
    'grilled_salmon': ('fish', 'seafood'),
    'fish_and_chips': ('fish', 'seafood'),
    'mussels': ('fish', 'seafood'),
    'oysters': ('fish', 'seafood'),
    'sashimi': ('fish', 'seafood'),
    'scallops': ('fish', 'seafood'),
    'shrimp_and_grits': ('fish', 'seafood'),
    'tuna_tartare': ('fish', 'seafood'),
    # meat
    'baby_back_ribs': ('beef stroganoff', 'meat'),
    'beef_carpaccio': ('steak', 'meat'),
    'beef_tartare': ('steak', 'meat'),
    'chicken_curry': ('rice bowl', 'meat'),
    'chicken_quesadilla': ('burrito', 'fastfood'),
    'chicken_wings': ('fried rice', 'meat'),
    'filet_mignon': ('steak', 'meat'),
    'foie_gras': ('steak', 'meat'),
    'pork_chop': ('meat loaf', 'meat'),
    'prime_rib': ('steak', 'meat'),
    'pulled_pork_sandwich': ('sandwich', 'sandwich'),
    # asian
    'bibimbap': ('rice bowl', 'rice'),
    'dumplings': ('fried rice', 'rice'),
    'edamame': ('broccoli', 'veg'),
    'fried_rice': ('fried rice', 'rice'),
    'gyoza': ('fried rice', 'rice'),
    'pad_thai': ('pasta', 'rice'),
    'paella': ('rice bowl', 'seafood'),
    'peking_duck': ('rice bowl', 'meat'),
    'pho': ('soup', 'soup'),
    'ramen': ('soup', 'soup'),
    'ravioli': ('pasta', 'pasta'),
    'risotto': ('pasta', 'pasta'),
    'spring_rolls': ('fried rice', 'fastfood'),
    'sushi': ('sushi', 'seafood'),
    'takoyaki': ('fried rice', 'fastfood'),
    # salads / vegetables
    'beet_salad': ('salad', 'salad'),
    'caesar_salad': ('salad', 'salad'),
    'caprese_salad': ('salad', 'salad'),
    'greek_salad': ('salad', 'salad'),
    'guacamole': ('salad', 'veg'),
    'hummus': ('salad', 'legume'),
    'seaweed_salad': ('salad', 'salad'),
    'bruschetta': ('bread', 'veg'),
    # pasta
    'gnocchi': ('pasta', 'pasta'),
    'lasagna': ('pasta', 'pasta'),
    'macaroni_and_cheese': ('pasta', 'pasta'),
    'spaghetti_bolognese': ('pasta', 'pasta'),
    'spaghetti_carbonara': ('pasta', 'pasta'),
    # sandwiches
    'club_sandwich': ('sandwich', 'sandwich'),
    'grilled_cheese_sandwich': ('sandwich', 'sandwich'),
    'lobster_roll_sandwich': ('sandwich', 'sandwich'),
    # misc
    'crab_cakes': ('fish', 'seafood'),
    'deviled_eggs': ('omelette', 'breakfast'),
    'escargots': ('mushroom', 'seafood'),
    'falafel': ('burrito', 'legume'),
    'samosa': ('fried rice', 'fastfood'),
    'ceviche': ('fish', 'seafood'),
    'cheese_plate': ('cheese', 'dairy'),
    'chocolate_cake': ('chocolate cake', 'dessert'),
    'steak': ('steak', 'meat'),
    'tacos': ('burrito', 'fastfood'),
    'french_onion_soup': ('soup', 'soup'),
}

# Coarse macro estimates (kcal / protein / carbs / fat) per bucket, used when a
# class has no exact nutrition key. Matches serving DB magnitudes.
BUCKET_MACROS: dict[str, dict] = {
    'dessert': {'calories': 380, 'protein': 5, 'carbs': 55, 'fat': 15},
    'breakfast': {'calories': 300, 'protein': 12, 'carbs': 40, 'fat': 10},
    'fastfood': {'calories': 500, 'protein': 20, 'carbs': 50, 'fat': 25},
    'sandwich': {'calories': 320, 'protein': 18, 'carbs': 35, 'fat': 12},
    'seafood': {'calories': 250, 'protein': 30, 'carbs': 10, 'fat': 10},
    'meat': {'calories': 420, 'protein': 35, 'carbs': 8, 'fat': 26},
    'rice': {'calories': 330, 'protein': 10, 'carbs': 58, 'fat': 7},
    'pasta': {'calories': 350, 'protein': 12, 'carbs': 65, 'fat': 5},
    'soup': {'calories': 160, 'protein': 8, 'carbs': 18, 'fat': 6},
    'salad': {'calories': 150, 'protein': 5, 'carbs': 20, 'fat': 7},
    'veg': {'calories': 60, 'protein': 3, 'carbs': 12, 'fat': 1},
    'legume': {'calories': 250, 'protein': 13, 'carbs': 35, 'fat': 8},
    'dairy': {'calories': 220, 'protein': 15, 'carbs': 20, 'fat': 9},
    'bread': {'calories': 265, 'protein': 9, 'carbs': 49, 'fat': 3},
}

# Guarantee all 101 classes are covered (assert in process_food_data.py).
ALL_FOOD101_CLASSES = {
    'apple_pie', 'baby_back_ribs', 'baklava', 'beef_carpaccio', 'beef_tartare',
    'beet_salad', 'beignets', 'bibimbap', 'bread_pudding', 'breakfast_burrito',
    'bruschetta', 'caesar_salad', 'cannoli', 'caprese_salad', 'carrot_cake',
    'ceviche', 'cheese_plate', 'cheesecake', 'chicken_curry',
    'chicken_quesadilla', 'chicken_wings', 'chocolate_cake', 'chocolate_mousse',
    'churros', 'clam_chowder', 'club_sandwich', 'crab_cakes', 'creme_brulee',
    'croque_madame', 'cup_cakes', 'deviled_eggs', 'donuts', 'dumplings',
    'edamame', 'eggs_benedict', 'escargots', 'falafel', 'filet_mignon',
    'fish_and_chips', 'foie_gras', 'french_fries', 'french_onion_soup',
    'french_toast', 'fried_calamari', 'fried_rice', 'frozen_yogurt',
    'garlic_bread', 'gnocchi', 'greek_salad', 'grilled_cheese_sandwich',
    'grilled_salmon', 'guacamole', 'gyoza', 'hamburger', 'hot_and_sour_soup',
    'hot_dog', 'huevos_rancheros', 'hummus', 'ice_cream', 'lasagna',
    'lobster_bisque', 'lobster_roll_sandwich', 'macaroni_and_cheese',
    'macarons', 'miso_soup', 'mussels', 'nachos', 'omelette', 'onion_rings',
    'oysters', 'pad_thai', 'paella', 'pancakes', 'panna_cotta', 'peking_duck',
    'pho', 'pizza', 'pork_chop', 'poutine', 'prime_rib',
    'pulled_pork_sandwich', 'ramen', 'ravioli', 'red_velvet_cake', 'risotto',
    'samosa', 'sashimi', 'scallops', 'seaweed_salad', 'shrimp_and_grits',
    'spaghetti_bolognese', 'spaghetti_carbonara', 'spring_rolls', 'steak',
    'strawberry_shortcake', 'sushi', 'tacos', 'takoyaki', 'tiramisu',
    'tuna_tartare', 'waffles',
}


def label_for_class(cls: str) -> Label:
    """Return (nutrition_key, bucket). Falls back to a generic fruit key."""
    return FOOD101_LABELS.get(cls, ('salad', 'salad'))


def macros_for_class(cls: str) -> dict:
    """Nutrition estimate for a class using its bucket fallback."""
    key, bucket = label_for_class(cls)
    return BUCKET_MACROS.get(bucket, BUCKET_MACROS['salad'])
