# Training Notebooks

One notebook per model, following the shared template:

> DVC-pull data → splits → train (GPU) → evaluate → export (ONNX INT8 + TFLite +
> safetensors) → MLflow log → upload to `buddyup-models` bucket → register a
> `ModelMetadata` row (name, version, artifact_path, metrics, is_active).

**Framework: TensorFlow/Keras preferred.** The training harness
(`../training/tf_utils.py`) builds TF models and exports to the ONNX (INT8 CPU)
artifacts the AI service lazy-loads. PyTorch is used only in the JEPA research
lane. Run in Colab or Kaggle (GPU).

## Running locally

The cell-1 bootstrap of every notebook is kernel-location independent: it walks
up from the current working directory to find `ai_service/`, puts `training/` on
`sys.path`, and `os.chdir()`s into `notebooks/` so the legacy `../data`,
`../models` relative paths keep working. The leading `%pip install` is guarded —
it only installs a dependency when it isn't already importable, so it's a no-op
inside the shared ML environment and still auto-installs on Colab/Kaggle.

This machine uses one shared Python 3.13 environment for all ML work, registered
as a Jupyter kernel so VS Code sees it in every project:

```bash
bash scripts/setup_ml_env.sh     # idempotent: creates ~/Desktop/ml-env +
                                  # installs backend/ai_service/requirements-training.txt
                                  # (CPU torch from the PyTorch CPU index) +
                                  # registers the "buddyup-ml" kernel
```

Then in VS Code open any notebook and pick the **Python 3.13 (ML)** kernel from
the kernel picker. GPU training still happens in Colab/Kaggle; this machine is
CPU-only (4 cores / 23 GB RAM), good for data work and small runs.

Notes:
- `../data/` is DVC-tracked (see `../data/README.md`); `ml-env` itself lives in
  `~/Desktop/ml-env` and is not part of the repo. Rebuild it anytime with the
  same script (pins live in `backend/ai_service/requirements-training.txt`).
- MLflow is available offline; `tf_utils.mlflow_log()` prints model-card JSON
  when no tracking URI is set. HF datasets + `food_recognition`'s HF fallback
  need network access.

## Getting data

- **Local DVC data** (`../data/`, see `../data/README.md`): Food.com Recipe1M-proxy
  recipes with calories (`RAW_recipes.csv`, 231k rows), USDA-style nutrient table,
  fast-food menus, NSFW image corpus + Reddit NSFW titles, Reddit IRL text corpus,
  profanity + Gen-Z slang lexicons. Load via `../training/buddy_data.py`.
- **Hugging Face**: `ethz/food101` (images), `mbien/recipe_nlg` (Recipe1M+ lineage,
  ingredients/directions), Jigsaw toxicity. Load via `datasets.load_dataset(...)`
  helpers in `../training/buddy_data.py`.
- **Recipe1M+** (torralba-lab im2recipe): `layer1.json` + images require the
  access form (https://forms.gle/EzYSu8j3D1LJzVbR8). The Food.com recipes are the
  calorie-rich proxy used by the food notebook.
- **First-party data**: Django command `export_ai_training_data` writes
  de-identified `engagement.csv` + `workouts.csv` into `../data/user/`.
- **Patching scripts**: `../training/process_food_data.py` (Food-101 label patch)
  and `../training/process_form_data.py` (keypoint normalisation). These are the
  DVC stages declared in `../dvc.yaml`.

## Planned notebooks

| # | Notebook | Model | Algorithm | Data |
|---|---|---|---|---|
| 1 | `food_recognition.ipynb` | 2 | Fine-tune ViT-B/16 + CLIP zero-shot | Food-101, Nutrition5k, USDA, Kaggle food sets |
| 2 | `form_analyzer.ipynb` | 1 | Pose keypoint-sequence temporal attention (Transformer/ST-GCN) | Exercise-form keypoint datasets + trainer-labeled video |
| 3 | `moderation_image.ipynb` | 3 | Fine-tune NSFW classifier (replace NudeNet baseline) | NSFW corpora, Kaggle |
| 4 | `moderation_text.ipynb` | 3 | Multilingual toxicity fine-tune | Jigsaw / HateXplain |
| 5 | `matching_embeddings.ipynb` | 5 | Contrastive sentence embeddings + FAISS index build | Preference/booking/rating data |
| 6 | `feed_ranking.ipynb` | 4 | Two-tower + LambdaRank → LinUCB bandit sim | Live engagement signals |
| 7 | `workout_time_series.ipynb` | 7 | Changepoint / 1RM forecasting | `Post.workout_log_data` |
| 8 | `jepa_pose_representation.ipynb` | 1 (research lane) | I-JEPA / VICReg on unlabelled form video | Raw workout video |

## Research lane

- **JEPA** (`jepa_pose_representation.ipynb`): self-supervised representation
  learning over unlabelled form video. Decision gate: does it beat the supervised
  baseline for exercise detection / form scoring?
- **RL** (roadmap, not v1): contextual bandit (LinUCB) is already the v1 approach
  for feed ranking. PPO/SAC for adaptive workout programming + coaching-cue
  selection only after v1 engagement data justifies it. Curiosity-based exploration
  and open-ended goal generation remain documented research.
