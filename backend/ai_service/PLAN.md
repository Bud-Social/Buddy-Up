# Buddy-Up AI Service — Implementation Plan (refined)

## 0. Strategy & principles

**Algorithm policy** (per model — the "what to use" answer):

| Model | Approach | RL? |
|---|---|---|
| Workout Form Analyzer | Transfer learning + **attention** (pose backbone → temporal Transformer/ST-GCN over keypoints) | v1: no; later: coaching-cue policy (lane D2) |
| Food Recognition | Fine-tune ViT-B/16 + CLIP zero-shot + GPT-4o vision for portions | No |
| Content Moderation | NudeNet (image) + OpenAI moderation / toxic-bert (text) + HITL | No |
| Feed Ranking | Content score + **LinUCB contextual bandit** | Bandit = the v1 RL component |
| Trainer-Buddy Matching | Contrastive embeddings + FAISS ANN | No |
| Meal Plan | GPT-4o + RAG + JSON-schema | No |
| Workout Log Analysis | Statistical (EWMA/changepoint) + optional small forecast model | No |
| Health Insights NLG | GPT-4o / T5 summarisation, template fallback | No |

**Serving constraints**
- CPU-only inference. Torch → ONNX → INT8 quantization for any served model.
- Latency budgets (p95): image classify ≤ 300ms, text moderation ≤ 800ms, form image ≤ 1s, feed rank ≤ 150ms, embeddings ≤ 500ms.
- **Every route keeps a degradation fallback** (keyword/rule/template) so the product never hard-fails on model absence.
- Additive endpoints only; existing response schemas stay backward compatible.

**Research gating**
- JEPA and RL proceed only after v1 engagement/data proves demand, and each must beat the current baseline in an offline eval before adoption.

---

## 1. Architecture & consumption contract

```
Django (orchestrate, auth, audit via apps.ai.AIPredictionJob)
   │  HTTP + AI_API_KEY   (sync for light routes; Celery 'ai' queue for heavy)
   ▼
FastAPI AI service (backend/ai_service, port 8003)
   ├─ engines        app/*_engine.py
   ├─ routers        app/routers/*.py
   ├─ serving        app/ml/ (ONNX INT8, load_preferred)
   └─ status         app/model_registry.py, app/monitoring.py
   ▼
Artifacts: MinIO bucket buddyup-models  |  Registry: Django ModelMetadata (is_active = canary/rollback)
Tracking: MLflow (C3)                    |  Data: DVC (data/)
```

**Endpoint inventory**

| Route | Status | Latency budget | Fallback |
|---|---|---|---|
| `POST /api/v1/food/recognize` | live | 300ms | keyword/color |
| `POST /api/v1/moderation/image` | live | 800ms | pixel |
| `POST /api/v1/moderation/text` | live | 800ms | toxic-bert → keywords |
| `POST /api/v1/embeddings/text` | live | 500ms | — |
| `POST /api/v1/embeddings/store|match` | live | 200ms | — |
| `POST /api/v1/embeddings/index/build|search` | live | 200ms | brute-force cosine |
| `POST /api/v1/meal-plans/personalise` | live | LLM ~5s | rule-based macros |
| `POST /api/v1/form-analyzer/analyze` | live (img+video) | 1s / 15s video | — |
| `GET  /api/v1/health-insights/analyze` | live | 500ms | template NLG |
| `POST /api/v1/onboarding/personalise` | live | 200ms | map lookup |
| `POST /api/v1/workout/analyze` | live | 300ms | — |
| `POST /api/v1/feed/rank` | live | 150ms | Django rank Case |
| `POST /api/v1/feed/feedback` | live | 100ms | no-op |
| `GET  /api/v1/metrics` | live | 50ms | — |
| `GET  /api/v1/models` | **planned (C2)** | 50ms | — |

---

## 2. Phase A — Foundation fixes · **DONE**

**Exit criteria met:** food label bug fixed, meal-plan LLM live, real NSFW model, video form analysis, config/env plumbing, MLOps scaffolding.

| Task | Artifact | Status |
|---|---|---|
| Fix `FOOD101_CLASSES` (ViT = 1000 ImageNet logits → category map → nutrition DB; 63 categories, ~40 foods) | `app/food_engine.py` | done |
| GPT-4o meal-plan personalisation + RAG + deterministic fallback | `app/meal_plan_engine.py`, `routers/meal_plans.py` | done |
| Replace bogus ResNet18-ImageNet NSFW with NudeNet + pixel fallback | `app/moderation_engine.py` | done |
| Video mode + bicep curl / push-up / plank / lunge analyzers | `app/form_analyzer_engine.py`, `routers/form_analyzer.py` | done |
| Config + docker-compose pass-through (`AI_OPENAI_API_KEY`, `AI_OPENAI_MODEL`) | `app/config.py`, `docker-compose*.yml` | done |
| MLOps scaffolding | `training/`, `notebooks/`, `model_cards/` | done |

**Notable gaps to revisit** (carry into B/C): food nutrition DB is static in-code; form analyzer is rule-based (no learned scorer yet); moderation HITL queue not wired to `apps.moderation`.

---

## 3. Phase B — Retrieval, ranking & moderation · **IN PROGRESS**

### B1 · Feed ranking (priority: HIGH)

**Objective:** personalize `for_you` with content score + LinUCB bandit; keep Django fallback.

| Task | Artifact | Effort | Status |
|---|---|---|---|
| Feed ranking engine (features, prefs, LinUCB, blend) | `app/feed_ranking_engine.py` | S | done |
| `POST /feed/rank` + `POST /feed/feedback` routers | `app/routers/feed.py` | S | done |
| **Django integration** — `for_you` tab calls `/feed/rank`; on failure fall back to existing rank Case | `backend/apps/feed/views.py` | M | open |
| **Feedback pipeline** — reaction/comment/save/repost events → `POST /feed/feedback` (via feed signals or views), idempotent, sampled | `backend/apps/feed/signals.py` (new), `views.py` | M | open |
| **Persistence** — move bandit/prefs from in-memory to Redis (survives restarts, multi-worker safe) | `app/feed_ranking_engine.py` | M | open |
| Online evals: A/B (AI rank vs baseline) via query param / ML experiment | `backend/apps/feed/views.py` | S | open |

**Exit criteria:** `for_you` served by ML rank with verified fallback; feedback flows; bandit state survives service restart; offline sim shows exploration lifts CTR proxy (likes/view) ≥ baseline.

**Dependencies:** none blocked.

### B2 · Embeddings & matching (priority: MEDIUM)

| Task | Artifact | Effort | Status |
|---|---|---|---|
| FAISS index build/search/list + brute-force fallback | `app/embedding_engine.py`, `routers/embeddings.py` | M | done |
| **Index refresh cadence** — Celery task rebuilds `trainer_embeddings` index (weekly + on-demand) | `backend/apps/profiles/tasks.py`, `routers/embeddings.py` | M | open |
| **Contrastive fine-tune** of all-MiniLM on preference/booking data | `notebooks/matching_embeddings.ipynb` | M | open |
| Switch `/match` to query the FAISS index when present | `routers/embeddings.py` | S | open |

**Exit criteria:** trainer/buddy match p95 ≤ 200ms with ANN; recall@20 within 1% of brute force on a held-out set; index refresh automated.

### B3 · Moderation hardening (priority: MEDIUM)

| Task | Artifact | Effort | Status |
|---|---|---|---|
| LLM-as-judge (OpenAI moderation) → toxic-bert → keywords | `app/moderation_engine.py` | S | done |
| **HITL queue** — flagged content surfaces in `apps.moderation` admin with model label + confidence; appeal updates training labels | `backend/apps/moderation/*`, `backend/apps/feed/tasks.py` | M | open |
| **Threshold tuning** from HITL outcomes (false-positive rate target < 2%) | `app/moderation_engine.py` | S | open |
| Drift: monitor NSFW score distribution shift (feed into C8) | `app/monitoring.py` | S | open |

**Exit criteria:** every flag has a review path; review decisions logged back as labeled data; FP rate tracked and below target.

### B4 · Edge path — real-time form analysis (priority: MEDIUM)

| Task | Artifact | Effort | Status |
|---|---|---|---|
| Export helper: pose model → TFLite/MediaPipe Tasks | `training/train_template.py` (extend) | S | done |
| **Flutter integration** — on-device pose + lightweight form scoring (video capture path), server for batch/replay | `buddy_up_flutter/**` | L | open |
| Sync strategy: edge score ≈ server score (calibrate thresholds) | docs + eval notebook | M | open |

**Exit criteria:** app runs form analysis at ≥ 24fps on mid-range Android/iOS without network; server still authoritative for stored replays.

---

## 4. Phase C — Packaging & MLOps · **IN PROGRESS**

### C1 · ONNX serving layer (DONE)
`app/ml/export.py` + `serving.py` (`load_preferred`), wired into food classifier. Add `onnxruntime`, `faiss-cpu`. **Extend** to moderation + form models as artifacts land.

### C2 · Model registry ↔ serving (priority: HIGH)

| Task | Artifact | Effort | Status |
|---|---|---|---|
| `GET /api/v1/models` — expose `ModelRegistry.list_models()` + versions/active | `app/routers/models.py` (new) | S | open |
| Sync flow: Django `ModelMetadata` (active versions) → AI service cache (`/models`) at startup + refresh endpoint | `backend/apps/ai/*`, `app/model_registry.py` | M | open |
| Canary A/B: `is_active` + per-model traffic split header; rollback = flip flag | `app/ml/serving.py`, `backend/apps/ai/views.py` | M | open |

**Exit criteria:** promoting a model = upload artifact + flip `is_active`; rollback ≤ 1 min; `/models` reflects reality.

### C3 · Experiment tracking + artifact store (priority: MEDIUM)

| Task | Artifact | Effort | Status |
|---|---|---|---|
| MLflow service in docker stack (Postgres + MinIO backends) | `docker-compose.yml`, `docker-compose.prod.yml` | M | open |
| Training logs scalars/metrics to MLflow (default off if not deployed) | `training/train_template.py` | S | open |
| Artifact upload step (training → MinIO `buddyup-models`, keyed name/version) | `training/` helper | M | open |

**Exit criteria:** any training run is reproducible + tracked; artifact path resolvable by serving layer.

### C4 · Model CI/CD (DONE)
`.github/workflows/model-ci.yml` — compile, import checks, model-card validation, `model-v*` tag gate. **Extend** with real training-in-CI (GPU runner) for smoke training on small slices.

### C5 · Data versioning (DONE)
`data/` contracts + `dvc.yaml`. **Extend** with actual dataset ingestion + privacy rules (no PII in `data/`).

### C6 · Monitoring & alerting (core DONE)

| Task | Artifact | Effort | Status |
|---|---|---|---|
| Latency middleware + `/metrics` (p95, errors, loaded models, indexes) | `app/monitoring.py`, `routers/metrics.py` | S | done |
| Scrape into Prometheus/Grafana + Sentry alerts (thresholds per latency budget) | infra | M | open |
| Drift endpoints: embedding distance, class-distribution shift per model | `app/monitoring.py` | M | open |

### C7 · Prediction audit & feedback loop (priority: HIGH)

| Task | Artifact | Effort | Status |
|---|---|---|---|
| Django writes `AIPredictionJob` (task, input, output, model_version, latency) for each AI call; async via Celery | `backend/apps/ai/*`, callers in `feed/`, `marketplace/`, `profiles/` | M | open |
| Corrections (food edits, moderation appeals, trainer ratings) become labeled data (`data/user/`) for retrain | `data/`, ingest scripts | M | open |
| AIPredictionJob admin already exists — add export/filtering by model_version | `backend/apps/ai/admin.py` | S | open |

**Exit criteria:** every prediction retrievable by job id; correction-to-retrain loop demonstrated end-to-end.

---

## 5. Phase D — Research lane (gated on v1 data)

### D1 · JEPA pose representation (skeleton DONE)
Tasks: raw-video keypoint extraction → pretrain I-JEPA/VICReg → linear-probe eval (exercise detection + per-joint form error) vs supervised baseline → **decision gate** (adopt backbone only if probe wins). Effort: L.

### D2 · RL coaching/programming policy
PPO/SAC over adaptive workout progression + coaching-cue selection. Needs: engagement/retention data (≥ 3 months), offline sim, safety guardrails (medical/disclaimer). Effort: XL.

### D3 · Open-ended / curiosity exploration
World-model + intrinsic-reward goal generation (POET-style). Documented research; no code before D2 results. Effort: XL.

**Gates:** D1 needs labeled or unlabeled form video (public + user). D2/D3 need v1 telemetry proving the feature drives retention.

---

## 6. Execution order & dependency graph

```
A (done) ──► B1 ──► C2 ──► C7          (highest value path)
        └──► B2 ──► C3
        └──► B3 ──► C6/C8
        └──► B4 (edge, independent)
C1/C4/C5 done ──► C6 alerting
D1 gated on data ──► D2 gated on D1 + telemetry ──► D3
```

Recommended sprint slicing:
1. **Sprint B1/C2/C7** — feed ML + registry + audit (P0).
2. **Sprint B2/B3/C3** — matching scale + moderation HITL + MLflow (P1).
3. **Sprint B4/C6** — edge form analysis + alerting (P1).
4. **Research** — D1 when data available.

---

## 7. Cross-cutting concerns

- **Security:** internal AI API authenticated via `AI_API_KEY` (both compose files); keys via env only; LLM prompts constrain output schema (no prompt injection surface from user text into system prompt).
- **Privacy:** moderation/meal-plan inputs transient; never log raw media; de-identify before `data/user/`.
- **Cost:** CPU-only + INT8 keeps serving cheap; cap LLM spend (meal-plan cache by profile hash, moderation only on flagged-entropy text); batch/nightly retrain on Colab/Kaggle not on prod GPU.
- **Performance:** heavy inference on Celery `ai` queue (already routed); Redis caches per-request results (food, moderation, meal-plan).

---

## 8. Risk register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| In-memory bandit/prefs lost on restart | High | Low | B1 Redis persistence |
| Moderation false positives erode trust | Med | High | B3 HITL + FP rate target |
| LLM cost/instability on meal-plan | Med | Med | Fallback macros + cache + retries |
| ONNX artifacts drift from torch eval | Med | Med | CI eval gate compares torch vs ONNX logits |
| Feed ML performs no better than baseline | Med | Med | A/B from day one (B1) |
| Edge/server form scores diverge | Med | Med | Calibration eval (B4) |
| JEPA/RL effort without payoff | Med | High | Decision gates + offline evals before prod |

---

## 9. Decision log

| # | Decision | Rationale |
|---|---|---|
| 1 | Transfer learning + attention for all perception; RL only as bandit for feed | 7/8 models are perception/retrieval/generation; sequential RL not required by v1 |
| 2 | NudeNet over fine-tuned CLIP for NSFW | Purpose-built, ONNX, CPU-friendly, no training data needed |
| 3 | OpenAI moderation before toxic-bert | Better coverage + zero deps when key present; falls back cleanly |
| 4 | LinUCB bandit, not PPO, for feed | Exploration-exploitation is the actual problem; PPO adds infra without v1 benefit |
| 5 | GPT-4o + RAG + JSON-schema for meal-plan | Structured, controllable output; deterministic fallback |
| 6 | ONNX INT8 CPU serving | Compose stack is CPU-only; quantization meets latency budgets |
| 7 | Lightweight dependency-free monitoring | CPU-only service stays light; scrape into Prometheus later |
| 8 | JEPA/RL in research lane, gated | Not production-mature for MVP; decisions deferred to data |
