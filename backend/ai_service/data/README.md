# Dataset layout (DVC-tracked)

Training datasets live here and are versioned with DVC (https://dvc.org).
Files are excluded from git (repo `.gitignore`) — use `dvc add` to track and
`dvc push` to a remote (MinIO `buddyup-models`). Loaders live in
`../training/buddy_data.py` and never mutate raw inputs.

## Current contents

| Path | Dataset | Used by |
|---|---|---|
| `Food and Nutrients data 3 (Food.com)/RAW_recipes.csv` | 231k recipes, **calories** + ingredients + steps (Recipe1M proxy) | food_recognition, meal_plan |
| `Food and Nutrients data 3 (Food.com)/RAW_interactions.csv` | user↔recipe ratings/reviews | matching_embeddings |
| `Food and Nutrients data 3 (Food.com)/PP_recipes.csv` | tokenised recipes + `ingr_map.pkl` | food_recognition vocab |
| `Food and Nutrients data 1/nutrients_csvfile.csv` | per-ingredient kcal/macros | food nutrition lookup |
| `Food and Nutrients data 2/fastfood.csv` | fast-food menu nutrition | food nutrition lookup |
| `Food and Nutrient data 3/FastFoodNutritionMenuV*.csv` | per-item macros | food nutrition lookup |
| `nsfw/{train,val,test}` | NSFW image corpus | image moderation |
| `kaggle_reddit-nsfw-classification-data.csv` | Reddit title→nsfw labels | image/text moderation prior |
| `the-reddit-irl-dataset-{comments,posts}.csv` | toxicity/insult corpus (2.9 GB) | text moderation |
| `one-million-reddit-jokes.csv` | comedy style | text moderation aug |
| `profanity_en.csv` | profanity lexicon + severity | text moderation labels |
| `genz_slang_usage_2020_2025.csv` | slang terms + sentiment | text moderation (slang-aware) |
| `user/` | de-identified engagement/workout exports (Django `export_ai_training_data`) | feed_ranking, workout_ts |
| `recipe1m/` | Recipe1M+ `layer1.json` + images (requires im2recipe access form) | food_recognition (optional) |
| `food101/` | Food-101 images | food_recognition |

## Hugging Face

Where a local copy is not present, notebooks fall back to HF Hub:
`ethz/food101`, `mbien/recipe_nlg` (Recipe1M+ lineage), Jigsaw toxicity. See
`../training/buddy_data.py::hf_*`.

## Commands

```bash
pip install dvc[s3]
dvc remote add -d models s3://buddyup-models   # or minio endpoint
dvc add data/<dir>
dvc push
```

## Privacy note

Never commit raw PII. Live user data is de-identified before landing in
`data/user/` via `python manage.py export_ai_training_data`. See `docs/` for
the platform privacy policy.
