# Dataset layout (DVC-tracked)

Training datasets live here and are versioned with DVC (https://dvc.org).
Datasets come from public sources (Food-101, Nutrition5k, USDA FoodData Central,
Jigsaw/HateXplain, NSFW corpora, exercise-form keypoint sets) plus Kaggle datasets
added by the team, plus de-identified live user data (see below).

```
data/
├── raw/            # immutable downloaded sources (never edited)
├── processed/      # cleaned, split, indexed artifacts (DVC-tracked)
└── user/           # de-identified feedback data for fine-tuning
```

## Commands

```bash
pip install dvc[s3]
dvc remote add -d models s3://buddyup-models   # or minio endpoint
dvc add data/raw data/processed
dvc push
```

## Per-model data contracts

| Model | Dataset | Fields required |
|---|---|---|
| food_classifier | Food-101 + Nutrition5k + user-corrected logs | image_path, food_label, (optional) calories/protein/carbs/fat |
| form_analyzer | keypoint sequences + trainer labels | video/image_path, exercise, per-joint quality label |
| nsfw_classifier | NSFW corpus | image_path, nsfw_label |
| toxicity_classifier | Jigsaw / HateXplain | text, toxic_labels |
| matching_embeddings | preference/booking/rating data | user_id, item_id, interacted(bool) |
| feed_ranker | engagement signals | user_id, post_id, reward(like/view/save) |

## Privacy note

Never commit raw PII. Live user data is de-identified before landing in
`data/user/`. See `docs/` for the platform privacy policy.
