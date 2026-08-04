# Model Packaging & Consumption

This is the packaging layer for Buddy-Up's ML models. It follows the plan's
"transfer learning + attention first, RL/JEPA in the research lane" strategy.

## Layout

```
ai_service/
├── app/                  # FastAPI serving code (engines + routers)
├── training/             # Reproducible training scripts (run on Colab/Kaggle GPUs)
├── notebooks/            # One Colab/Kaggle notebook per model
├── model_cards/          # Model card templates (versioned alongside artifacts)
└── data/                 # Data contracts; artifacts versioned via DVC
```

## Model lifecycle

1. **Train** — run the notebook/script for a model on a GPU (Colab/Kaggle).
2. **Log** — track experiments in MLflow (server added to the docker stack).
3. **Export** — produce serving artifacts: ONNX (INT8, CPU) + TFLite (edge) + `.safetensors`.
4. **Package** — upload to the `buddyup-models` bucket (MinIO in prod).
5. **Register** — create/update a Django `apps.ai.ModelMetadata` row:
   `name`, `version`, `artifact_path`, `metrics`, `is_active`.
   Flip `is_active` to roll back or run a canary.
6. **Serve** — the AI service lazy-loads the active artifact into `ModelRegistry`.

## Consumption contract

Every model is consumed through its FastAPI router. Django calls these over HTTP
(`AI_SERVICE_URL`), heavy jobs go through the Celery `ai` queue. Response schemas
are versioned and must stay backward compatible with `backend/apps/*/views.py`.

## Config (AI_ prefixed, see app/config.py)

| Env | Purpose |
|---|---|
| `AI_OPENAI_API_KEY` | Enables GPT-4o meal-plan personalisation |
| `AI_OPENAI_MODEL` | Default `gpt-4o` |
| `AI_MODEL_CACHE_DIR` | Local model artifact cache (`/models`) |
| `AI_NSFW_MODEL` | `nudenet` (default) — purpose-built NSFW detector |
