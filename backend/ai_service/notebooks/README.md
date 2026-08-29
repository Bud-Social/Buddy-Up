# Training Notebooks

One notebook per model, following the shared template:

> DVC-pull data → splits → train (GPU) → evaluate → export (ONNX INT8 + TFLite +
> safetensors) → MLflow log → upload to `buddyup-models` bucket → register a
> `ModelMetadata` row (name, version, artifact_path, metrics, is_active).

**Framework: TensorFlow/Keras preferred.** The training harness
(`../training/tf_utils.py`) builds TF models and exports to the ONNX (INT8 CPU)
artifacts the AI service lazy-loads. PyTorch is used only in the JEPA research
lane. Run in Colab or Kaggle (GPU).

## Shared bootstrap (`../training/bootstrap.py`)

Every notebook's first code cell now runs:

```python
from training.bootstrap import *   # sets thread env BEFORE TF loads
CFG = init()                       # seeds RNGs, ensures output dirs
SCALE = CFG.get('scale', ...)      # resolved BUDDY_SCALE
```

It reads the `BUDDY_*` env vars, caps CPU threads (before TensorFlow is
imported), seeds python/numpy/TF/torch, and exposes the resolved run paths:

| Env var | Default (local) | Default (Kaggle) |
|---|---|---|
| `BUDDY_ENV` | `local` | `kaggle` (auto-detected via `/kaggle`) |
| `BUDDY_SCALE` | `smoke` (`smoke` / `demo` / `full`) | same |
| `BUDDY_SEED` | `42` | same |
| `BUDDY_DETERMINISTIC` | `1` (TF deterministic ops on) | same |
| `BUDDY_DATA_ROOT` | `<ai_service>/data` | `/kaggle/input/buddy-up-data` when present |
| `BUDDY_OUTPUT_ROOT` | `<ai_service>/outputs` | `/kaggle/working/buddyup-output` (writable) |
| `BUDDY_MODEL_ROOT` | `<ai_service>/models` | `<output_root>/models` |

`/kaggle/input` mounts are read-only — put datasets in a Kaggle dataset named
`buddy-up-data` and write all artifacts under `/kaggle/working/buddyup-output`.
`bootstrap.environment()` snapshots platform/library versions and
`bootstrap.save_run_metadata(extra)` persists `environment.json` +
`run-metadata.json` under `OUTPUT_ROOT` (the model-ci promotion gate accepts a
`run-metadata.json` next to the artifact as the metric source).

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

## Pipelines

Every notebook is a real, runnable pipeline: **data → splits → train → evaluate
→ export ONNX (INT8) + MLflow model card**. A `BUDDY_SCALE` env knob picks the
run size (`smoke` = fast CPU check, `demo` = default, `full` = GPU-sized):

```bash
BUDDY_SCALE=demo jupyter nbconvert --execute --inplace --to notebook \
  --ExecutePreprocessor.kernel_name=buddyup-ml moderation_text.ipynb
```

| Notebook | Data | Trains | Evaluates | Exports |
|---|---|---|---|---|
| `moderation_text` | Reddit IRL (chunked) + profanity + Gen-Z slang | BiLSTM toxicity | AUC / AP / P / R / F1 + threshold calibration | `toxicity_classifier` ONNX + `toxicity_vectorizer.json` |
| `moderation_image` | `data/nsfw/out/{train,val,test}` | MobileNetV3Small head + fine-tune, class-weighted | test AUC / AP / confusion | `nsfw_classifier` ONNX INT8 |
| `matching_embeddings` | Food.com `RAW_interactions.csv` (rating ≥ 4) | two-tower, user-level split (held-out users; val negatives filtered against known positives) | HR@10 / MRR | user-tower ONNX + `matching_items.faiss` + ID maps |
| `feed_ranking` | `../data/user/engagement.csv` or synthetic fallback | two-tower + LinUCB alpha sweep | CTR by alpha | `feed_ranker` ONNX INT8 |
| `workout_time_series` | `../data/user/workouts.csv` or synthetic progression | LSTM forecast | MAE / MAPE | `workout_forecast` ONNX INT8 |
| `food_recognition` | Food-101 images (gated) + 231k Food.com recipes | MobileNet fine-tune (gated) + ingredient→calorie regressor | calorie MAE / median AE | `food_classifier` (gated) + `food_calorie_regressor` ONNX + vectorizer JSON |

Notes:
- Artifacts land in `../models/` — dev compose bind-mounts that dir to the AI
  service's `/models` (`AI_MODEL_CACHE_DIR`), so
  `app/ml/serving.py::load_preferred(name)` picks up the best artifact on
  reload. **Artifact naming contract** (see `app/ml/serving.py::artifact_path`):
  exports are versioned (`<name>-<semver>.onnx` + dynamic-INT8
  `<name>-<semver>_int8.onnx`); serving prefers the highest version (INT8 over
  plain within a version), then the versioned-dir layout
  `<model_root>/<name>/<version>/model[_int8].onnx`, then the legacy
  unversioned `<name>_int8.onnx` / `<name>.onnx` aliases. Every export also
  writes a `metadata.json` (+ `<name>.metadata.json`) next to the artifact:
  `{name, version, classes, input_shape, preprocessing, artifact_sha256}` —
  `food_engine` decodes class indices from it when a `classes` list is present.
  `feed_ranking` / `workout_time_series` print a banner and fall back to
  deterministic synthetic data when `export_ai_training_data` hasn't been run;
  `food_recognition`'s image branch needs Food-101 (`dvc pull` or
  `BUDDY_FOOD_IMAGES=1` for a tiny HF sample) and otherwise runs the local
  calorie-regression path.
- `workout_time_series` epoch defaults are now `{'smoke': 1, 'demo': 30,
  'full': 120}` with `EarlyStopping(patience=5, restore_best_weights=True)` +
  `ReduceLROnPlateau` — the old 700/2500-epoch sweeps just overfit CPU smoke
  boxes.
- **Form notebook caveat**: `form_analyzer` trains on `normalised.json`, whose
  labels are the extraction placeholder `good` — the current data is
  exercise-class, **not** form-quality. Real form scoring needs trainer labels
  (`good` / `slight_misalignment` / `bad`); `process_form_data.py` warns when
  only placeholders are present.
- `../data/` is DVC-tracked (see `../data/README.md`); `ml-env` itself lives in
  `~/Desktop/ml-env` and is not part of the repo. Rebuild it anytime with the
  same script (pins live in `backend/ai_service/requirements-training.txt`).
- MLflow is available offline; `tf_utils.mlflow_log()` prints model-card JSON
  when no tracking URI is set. HF datasets need network access.

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
- **Patching scripts**: `../training/process_food_data.py` (Food-101 label
  patch; loads Food-101 from HF `ethz/food101` and materialises split images +
  manifests under `data/processed/food`) and `../training/process_form_data.py`
  (validates the processed keypoint sequences from
  `process_workout_videos.py` and republishes the manifest views). These are
  the DVC stages declared in `../dvc.yaml`.

## Notebook status

| # | Notebook | Status | Model | Algorithm | Data |
|---|---|---|---|---|---|
| 1 | `food_recognition.ipynb` | implemented (image gated) | 2 | MobileNet fine-tune + ingredient→calorie regression | Food-101 (gated) + Food.com recipes |
| 2 | `form_analyzer.ipynb` | template only | 1 | Pose keypoint-sequence temporal attention | Exercise-form keypoints (needs DVC data) |
| 3 | `moderation_image.ipynb` | implemented | 3 | MobileNetV3 NSFW fine-tune | `data/nsfw/out` |
| 4 | `moderation_text.ipynb` | implemented | 3 | BiLSTM toxicity (lexicon-labelled) | Reddit IRL + profanity/slang |
| 5 | `matching_embeddings.ipynb` | implemented | 5 | Two-tower + FAISS | Food.com `RAW_interactions.csv` |
| 6 | `feed_ranking.ipynb` | implemented | 4 | Two-tower + LinUCB | engagement CSV or synthetic |
| 7 | `workout_time_series.ipynb` | implemented | 7 | LSTM 1RM forecast | workouts CSV or synthetic |
| 8 | `jepa_pose_representation.ipynb` | research lane | 1 | I-JEPA / VICReg on unlabelled form video | Raw workout video |

## Research lane

- **JEPA** (`jepa_pose_representation.ipynb`): self-supervised representation
  learning over unlabelled form video. Decision gate: does it beat the supervised
  baseline for exercise detection / form scoring?
- **RL** (roadmap, not v1): contextual bandit (LinUCB) is already the v1 approach
  for feed ranking. PPO/SAC for adaptive workout programming + coaching-cue
  selection only after v1 engagement data justifies it. Curiosity-based exploration
  and open-ended goal generation remain documented research.
