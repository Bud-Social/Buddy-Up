"""Dataset catalog + loaders for Buddy-Up training pipelines.

Datasets live under ``data/`` and are DVC-tracked (see ``data/README.md``).
Loaders prefer the local copy; if missing they raise a clear error pointing at
the source so a Colab/Kaggle notebook can pull it. Raw inputs are never
mutated — processing happens in ``training/process_*.py``.

Usage::

    from buddy_data import require, food_com_recipes, nutrients, nsfw_images, reddit_text

    df = food_com_recipes()          # -> pandas.DataFrame (with calories + ingredients)
    root = require('nsfw_images')    # -> Path(data/nsfw)
"""
import logging
from dataclasses import dataclass
from pathlib import Path
from typing import Callable

logger = logging.getLogger(__name__)

DATA = Path(__file__).resolve().parent.parent / 'data'


@dataclass(frozen=True)
class Dataset:
    key: str
    description: str
    source: str
    license: str
    size: str
    marker: str  # filename whose presence means "downloaded"
    local_dir: str = ''  # subdir under data/ (defaults to key)
    url: str = ''


CATALOG: list[Dataset] = [
    # ── Food / recipes / nutrition ──────────────────────────────────────
    Dataset(
        key='food101',
        description='101 fine-grained food classes, 101k images (75.8k train / 25.2k test)',
        source='https://data.vision.ee.ethz.ch/cvl/datasets_extra/food-101/',
        license='CC BY-NC-SA 3.0 (non-commercial)',
        size='5.0 GB',
        marker='images',
        local_dir='food101',
    ),
    Dataset(
        key='food_com',
        description='Food.com Recipe1M proxy: 267k recipes with ingredients + nutrition '
                    '[calories, fat%DV, sugar%DV, sodium%DV, protein%DV, satfat%DV, carbs%DV]',
        source='Kaggle: shuyangli94/food-com-recipes-and-user-interactions (HF mirror: mbien/recipe_nlg)',
        license='Various (research use)',
        size='294 MB',
        marker='RAW_recipes.csv',
        local_dir='Food and Nutrients data 3 (Food.com)',
    ),
    Dataset(
        key='food_com_interactions',
        description='Food.com user<->recipe interactions (ratings/reviews) for recsys',
        source='Kaggle: shuyangli94/food-com-recipes-and-user-interactions',
        license='Various (research use)',
        size='350 MB',
        marker='RAW_interactions.csv',
        local_dir='Food and Nutrients data 3 (Food.com)',
    ),
    Dataset(
        key='usda_nutrients',
        description='Per-ingredient nutrition table (calories, protein, fat, carbs, fiber)',
        source='Internal / public food composition tables',
        license='Public domain',
        size='2 MB',
        marker='nutrients_csvfile.csv',
        local_dir='Food and Nutrients data 1',
    ),
    Dataset(
        key='fastfood',
        description='Fast-food menu nutrition (McDonald\'s, etc.) incl. calories per item',
        source='Kaggle / public menu data',
        license='Various',
        size='1 MB',
        marker='fastfood.csv',
        local_dir='Food and Nutrients data 2',
    ),
    Dataset(
        key='fastfood_menu',
        description='FastFoodNutritionMenu V2+V3 with per-item macros',
        source='Kaggle / public menu data',
        license='Various',
        size='2 MB',
        marker='FastFoodNutritionMenuV3.csv',
        local_dir='Food and Nutrient data 3',
    ),
    # ── Moderation ──────────────────────────────────────────────────────
    Dataset(
        key='nsfw_images',
        description='NSFW image corpus (train/val/test dirs) for NudeNet replacement',
        source='Internal curated set',
        license='Research use',
        size='~10 GB',
        marker='train',
        local_dir='nsfw',
    ),
    Dataset(
        key='reddit_nsfw',
        description='Reddit post title -> is_nsfw labels (classification baseline)',
        source='Kaggle: reddit-nsfw-classification-data',
        license='Reddit API (research)',
        size='45 MB',
        marker='kaggle_reddit-nsfw-classification-data.csv',
    ),
    Dataset(
        key='profanity',
        description='English profanity lexicon with severity ratings',
        source='Kaggle profanity_en',
        license='Various',
        size='105 KB',
        marker='profanity_en.csv',
    ),
    Dataset(
        key='genz_slang',
        description='2020-2025 Gen-Z slang usage (term, meaning, sentiment, context)',
        source='Internal / social corpus',
        license='Internal',
        size='95 MB',
        marker='genz_slang_usage_2020_2025.csv',
    ),
    Dataset(
        key='reddit_jokes',
        description='One million Reddit jokes (comedy style/toxicity augmentation)',
        source='Kaggle one-million-reddit-jokes',
        license='Reddit API (research)',
        size='301 MB',
        marker='one-million-reddit-jokes.csv',
    ),
    Dataset(
        key='reddit_irl',
        description='Reddit r/IRL comments + posts (2.5GB) — toxicity/insult corpus',
        source='Kaggle the-reddit-irl-dataset',
        license='Reddit API (research)',
        size='2.9 GB',
        marker='the-reddit-irl-dataset-comments.csv',
    ),
    # ── Recipe1M+ (im2recipe lineage) ───────────────────────────────────
    Dataset(
        key='recipe1m_layer1',
        description='Recipe1M layer1.json (id, ingredients, instructions, partitions) — '
                    'requires form access via https://forms.gle/EzYSu8j3D1LJzVbR8',
        source='https://github.com/torralba-lab/im2recipe (MIT)',
        license='Research-only',
        size='~250 MB',
        marker='layer1.json',
        local_dir='recipe1m',
    ),
    Dataset(
        key='recipe1m_images',
        description='Recipe1M food images (train/val/test) + layer2.json image-url map',
        source='http://im2recipe.csail.mit.edu/dataset/download',
        license='Research-only',
        size='~60 GB',
        marker='images',
        local_dir='recipe1m',
    ),
]


def catalog() -> list[Dataset]:
    return list(CATALOG)


def _dataset(key: str) -> Dataset:
    for d in CATALOG:
        if d.key == key:
            return d
    raise KeyError(f'Unknown dataset {key!r}. Known: {[d.key for d in CATALOG]}')


def data_dir(key: str) -> Path:
    d = _dataset(key)
    return DATA / (d.local_dir or d.key)


def is_present(key: str) -> bool:
    d = _dataset(key)
    return (data_dir(key) / d.marker).exists()


def require(key: str) -> Path:
    """Return the dataset dir, raising a helpful error if missing."""
    d = _dataset(key)
    if not is_present(key):
        raise FileNotFoundError(
            f'Dataset {key!r} not found at {data_dir(key)}. '
            f'Source: {d.source} ({d.license}). Run: dvc pull (see data/README.md).'
        )
    return data_dir(key)


# --- Food / nutrition loaders -------------------------------------------


def food_com_recipes():
    """Food.com Recipe1M-proxy recipes as a DataFrame (adds parsed nutrition cols).

    nutrition vector = [calories, total_fat(%DV), sugar(%DV), sodium(%DV),
                        protein(%DV), saturated_fat(%DV), carbohydrates(%DV)].
    """
    import ast

    import pandas as pd

    root = require('food_com')
    df = pd.read_csv(root / 'RAW_recipes.csv')
    nutrition = df['nutrition'].apply(ast.literal_eval)
    df['calories'] = nutrition.str[0]
    df['total_fat_pdv'] = nutrition.str[1]
    df['sugar_pdv'] = nutrition.str[2]
    df['sodium_pdv'] = nutrition.str[3]
    df['protein_pdv'] = nutrition.str[4]
    df['sat_fat_pdv'] = nutrition.str[5]
    df['carbs_pdv'] = nutrition.str[6]
    df['ingredients_list'] = df['ingredients'].apply(ast.literal_eval)
    return df


def food_com_interactions():
    import pandas as pd

    root = require('food_com_interactions')
    df = pd.read_csv(root / 'RAW_interactions.csv')
    return df


def nutrients():
    """Per-ingredient nutrition (nutrients_csvfile.csv) with kcal + macros."""
    import pandas as pd

    root = require('usda_nutrients')
    df = pd.read_csv(root / 'nutrients_csvfile.csv')
    df.columns = [c.strip().replace('.', '_') for c in df.columns]
    return df


def fastfood():
    import pandas as pd

    root = require('fastfood')
    return pd.read_csv(root / 'fastfood.csv')


# --- Moderation loaders ---------------------------------------------------


def nsfw_images():
    """NSFW image corpus root (train/val/test subdirs)."""
    return require('nsfw_images')


def reddit_nsfw():
    import pandas as pd

    return pd.read_csv(DATA / 'kaggle_reddit-nsfw-classification-data.csv')


def profanity():
    import pandas as pd

    return pd.read_csv(DATA / 'profanity_en.csv')


def genz_slang():
    import pandas as pd

    return pd.read_csv(DATA / 'genz_slang_usage_2020_2025.csv')


def reddit_jokes():
    import pandas as pd

    return pd.read_csv(DATA / 'one-million-reddit-jokes.csv')


def reddit_irl_comments():
    import pandas as pd

    return pd.read_csv(DATA / 'the-reddit-irl-dataset-comments.csv', low_memory=False)


# --- Hugging Face loaders (fall back to local where possible) ------------


def hf_recipe_nlg():
    """RecipeNLG (1.1M recipes; Recipe1M+ lineage) — ingredients + directions,
    no calories. Used to enrich the ingredient vocabulary and for meal-plan
    personalisation training. Requires `pip install datasets` + HF Hub access."""
    from datasets import load_dataset

    return load_dataset('mbien/recipe_nlg', split='train')


def hf_food101():
    """Food-101 images straight from the HF Hub."""
    from datasets import load_dataset

    return load_dataset('ethz/food101', split='train')


def hf_toxicity():
    """Jigsaw toxic-comment classification from the HF Hub."""
    from datasets import load_dataset

    return load_dataset('oxford-ds/toxicity', split='train')
