# BuddyUp — Architectural Design & Security Review

| Field | Value |
|---|---|
| Prepared for | Charles Githinji, Head of Security + Security Team |
| Prepared by | Engineering (CEO / Engineering: Peter Mbugua) |
| Date | 2026-09-19 |
| Status | Maintained — security review input requested |
| Companion docs | `docs/technical_architecture.md`, `docs/OPERATIONS.md`, `docs/API_CONTRACT.md`, `docs/CLIENT_PARITY.md` |
| Quick-action version | `docs/SECURITY_REVIEW_CHECKLIST.md` |

> **How to use this document:** Sections 1–3 give you the mental model of what BuddyUp is and how it fits together. Sections 4–9 go domain by domain: how it works today, where the trust boundaries are, and **“Notes & Tips for Security Review”** boxes with exactly what to check, what to ask for, and what good looks like. Section 10 is the threat model. Section 11 is the prioritised remediation backlog. Section 12 tells you how to work with engineering (access, audit evidence, incident handling).

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Platform Overview](#2-platform-overview)
3. [Component Architecture Deep Dive](#3-component-architecture-deep-dive)
4. [Identity, Authentication, Sessions, Age Gating & Verification](#4-identity-authentication-sessions-age-gating--verification)
5. [Payments & the Artifact Economy](#5-payments--the-artifact-economy)
6. [Data Privacy, PII, Export/Delete & Health Data](#6-data-privacy-pii-exportdelete--health-data)
7. [Content Moderation & Safety](#7-content-moderation--safety)
8. [Messaging, Real-time & Media Security](#8-messaging-real-time--media-security)
9. [Infrastructure, Deployment, Network & Observability](#9-infrastructure-deployment-network--observability)
10. [Trust Boundaries & Threat Model](#10-trust-boundaries--threat-model)
11. [Findings & Remediation Roadmap](#11-findings--remediation-roadmap)
12. [Working With Engineering](#12-working-with-engineering)
- [Appendix A: Secret / Env Inventory](#appendix-a-secret--env-inventory-non-secret-names-only)
- [Appendix B: Key API Surfaces](#appendix-b-key-api-surfaces)
- [Appendix C: Key Source Files](#appendix-c-key-source-files)
- [Appendix D: Glossary](#appendix-d-glossary)

---

## 1. Executive Summary

**BuddyUp** is a health & fitness social platform — “Who’s working out with me today?” It combines:

- Social graph (follow + mutual “Buddy Up” + gym memberships),
- Feed (9 post types, reactions, comments, reposts, Moments/stories),
- Live training (“Buddy Lives” incl. Random Drop matching) on self-hosted **LiveKit** WebRTC,
- 1:1 trainer bookings with **artifact escrow**,
- Marketplace (meal plans, training programmes, products, events, cart/checkout),
- Virtual currency (“fitness artifacts” — dumbbell/barbell/burpee/squat/sprint/PR/champion) settled in USD display / KES settlement via **Flutterwave**,
- AI microservice (FastAPI) for food recognition, moderation, embeddings/visual search, meal-plan personalisation, workout analysis, feed ranking, TTS/summarisation,
- Analytics (activity/workout/meal/body tracking + Pillow-rendered reports).

**Architectural style:** modular Django monolith (DRF + Daphne ASGI) + React/Vite SPA + FastAPI AI sidecar + Redis (broker/cache/Channels) + PostgreSQL 16 + Celery (4 queues) + LiveKit SFU + Cloudinary/S3-compatible (MinIO) media. Production runs on **Railway, one container per service**; `docker-compose.prod.yml` is a staging/local reference only.

**Security posture in one page (for Charles):**

| Strong today | Needs hardening (see §11) |
|---|---|
| JWT 15-min access + rotating 30-day refresh bound to `DeviceSession` with row-locked rotation; TOTP + WebAuthn passkeys; Google/Apple OAuth fail-closed | `dob_hash` is unsalted SHA-256 of `YYYY-MM-DD` (~40k space, brute-forceable); OTP codes stored plaintext; OTP compare not constant-time except reset-confirm |
| Throttled auth (`registration 10/h`, `login 30/h`, `otp 10/h`, `password_reset 3/h`, `webauthn 10/h`) + 3-strikes OTP lock + 60s resend cooldown | `remember_me=False` still yields 30-day refresh (no short session); JWTs in `localStorage` (XSS exfil) — migrate to HttpOnly cookies or document acceptance |
| Double-entry ledger (`JournalEntry`/`JournalLine` + idempotency keys) shadowing JSON balances; atomic `select_for_update` transfers; webhook fail-closed (`503` if `FLUTTERWAVE_WEBHOOK_HASH` empty, `hmac.compare_digest`) | Marketplace `OrderCase` has no artifact refund settlement (request-only); direct-buy endpoints lack cart idempotency; repeat-tip `reference_id` collision returns “Already processed” without moving funds |
| Verification docs: private storage refs, 300s presigned URLs, per-read audit (`actor/purpose/request_id/IP`), 90-day purge + 30-day post-review purge, face-match never auto-rejects (→ manual review) | No field-level PII encryption at rest (transport-only); `X-Forwarded-For` trusted unconditionally in verification IP logging; admin allowlist is `allow all` (TODO); no E2E encryption despite legacy business-plan claim — messages are server-readable plaintext |
| Prod hardening: `SECURE_SSL_REDIRECT`, HSTS 1yr + preload, `Secure/HttpOnly/Lax` cookies, `X-Frame-Options: DENY`, tight CSP, `CORS_ALLOW_CREDENTIALS=False`, `METRICS_TOKEN`-gated metrics (404 masquerade), `validate_deploy` fail-closed gate, wallet reconciliation gate | Static `verif-hash` compare (not body HMAC), no webhook nonce/timestamp log; `KES_PER_USD` static (FX drift); single $10 withdrawal floor, no velocity caps / step-up auth for large withdrawals; raw card fields exist in serializer (`card_details: DictField`) — must never be wired to client |

**Bottom line for sign-off:** launch-core (auth, profiles/buds, gyms, sessions escrow, notifications) is reviewable; controlled-beta (marketplace, LiveKit, AI food recognition) needs the P0 items in §11 closed or formally risk-accepted; held items (creator cash payouts, paid artifact expansion, clinical AI advice, broad supplements without PPB workflow) must stay disabled — see `docs/OPERATIONS.md` Service launch status.

---

## 2. Platform Overview

### 2.1 What the user sees

```
buddyup.app/
├── Landing (public)
├── Auth (/signup, /login, /verify-age, /onboarding, /forgot-password)
├── Main app (authed): /feed, /discover, /lives, /gyms, /trainers,
│   /marketplace, /sessions, /messages, /wallet, /notifications,
│   /profile, /settings
├── Public profiles (/:username) + legal pages
```

Signature primitives: **Buddy Up** (mutual follow → DM unlock), **Rep Ring** (activity streak avatar), **Random Drop** (spontaneous matched lives), **Artifacts** (themed currency).

Minimum age **16**, enforced by DOB gate + `BUDDYUP_MINIMUM_AGE=16` + mature-content gate defaulting to **18+** (`MATURE_MIN_AGE_16_COUNTRIES` empty — see `backend/common/age_gating.py`).

### 2.2 System context

```
 Browser (React/Vite :3002)
   │ REST (axios → :8002/api/v1)      WS (Channels → ws://:8002)
   ▼                                   ▼
┌─────────────────────────┐   ┌──────────────────────────┐
│ Django + Daphne :8002   │◄──│ Redis :6379 (broker /    │
│ REST + WS + Admin       │   │  cache / Channels /      │
└──────────┬──────────────┘   │  bandit store)           │
           │ internal HTTP    └───────────┬──────────────┘
           │ (X-API-Key)                  │
           ▼                              ▼
┌─────────────────────────┐   ┌──────────────────────────┐
│ FastAPI AI :8003        │   │ Celery worker + beat     │
│ /api/v1/* (ML models)   │   │ default, high_priority,  │
└─────────────────────────┘   │ media, ai                │
           │                  └──────────────────────────┘
           ▼
┌─────────────────────────┐   ┌──────────────────────────┐
│ PostgreSQL :5432        │   │ LiveKit :7880 (SFU)      │
│ (primary store)         │   │ Cloudinary / MinIO S3    │
└─────────────────────────┘   └──────────────────────────┘
           │
           ▼ (outbound only)
 Flutterwave │ Africa's Talking SMS │ SendGrid SMTP │
 Google/Apple OAuth │ FCM/WebPush │ Smile Identity KYC │
 AWS Rekognition (optional face-match) │ OpenAI (AI fallback) │
```

### 2.3 Containers

| Service | Build | Role | Ports (dev / prod-ref) |
|---|---|---|---|
| `db` | `postgres:16-alpine` | Primary datastore | 5432 (dev only; internal in prod) |
| `redis` | `redis:7-alpine` | Broker, cache, Channels, LiveKit state, bandit store | 6379 (dev only; authed + internal in prod) |
| `ai-service` | `backend/ai_service/Dockerfile` | FastAPI ML | 8003 (dev; internal in prod) |
| `backend` | `backend/Dockerfile` dev/prod targets | Django + Daphne HTTP+WS | 8002 (dev; `$PORT` on Railway) |
| `livekit` | `livekit/livekit-server:v1.8` | WebRTC SFU | 7880/7881, 3478/udp, 5349/tcp, 50000–50100/udp |
| `livekit-egress` | `egress:v1.6` | Recording → MinIO | internal |
| `minio` | MinIO | S3-compatible replays | internal (`/replays/` via nginx) |
| `celery-worker` | backend image | Async tasks, 4 queues | — |
| `celery-beat` | backend image | DB-scheduled jobs | — |
| `frontend` | `frontend/Dockerfile` dev/prod | Vite dev / nginx SPA | 3002 (dev; 80/443 via nginx/prod) |
| `nginx` | custom | TLS, reverse proxy (prod-ref) | 80/443 |

> Dev `docker-compose.yml` publishes everything + bind-mounts source. Prod-ref `docker-compose.prod.yml` publishes only `nginx 80/443` + LiveKit ports; everything else on `buddyup_internal:bridge`. Canonical prod is Railway (see §9).

---

## 3. Component Architecture Deep Dive

### 3.1 Frontend (React 18 + TS + Vite)

`frontend/src/`:

| Dir | Contents |
|---|---|
| `api/` | Axios modules per domain (`client.ts`, `auth.ts`, `feed.ts`, `gyms.ts`, `lives.ts`, `messaging.ts`, `marketplace.ts`, `wallet.ts`, `profiles.ts`, `sessions.ts`, `notifications.ts`, `verification.ts`, `analytics.ts`, `activity.ts`, `admin.ts`) |
| `components/` | `ui/` primitives, `layout/` (AppShell/BottomNav/Sidebar), `features/` composites |
| `pages/` | `app/` authed screens, `auth/` (login/register/OTP/TOTP), `legal/`, `Landing.tsx` |
| `store/` | Zustand: `authStore`, `notificationStore`, `presenceStore`, `callStore`, `chatPreferencesStore`, `artifactStore`, `sidebarStore`, `themeStore` |
| `hooks/` | `useAuth`, `useChatSocket`, `useVoiceRecorder` |
| `router.tsx` | `createBrowserRouter` + `AuthGuard` + `AdminGuard` + lazy pages |
| `lib/`, `utils/`, `styles/` | Device ID, helpers, Tailwind tokens (`buddy-green`, `buddy-black`, etc.) |

Conventions security should know:

- `api/client.ts`: attaches `Bearer` + `X-Device-Id` (`lib/device`), single-flight 401 refresh with failed-request queue; never refreshes on auth-flow URLs; 403 `consent_required` → `/onboarding`.
- `store/authStore.ts`: `zustand/persist` key `buddyup-auth` in **`localStorage`** (access + refresh + user + profile) — XSS exfil risk (see §11 P0).
- `router.tsx:AuthGuard` forces `onboarding_completed==False` → `/onboarding` (`?step=age` if `is_adult==False`); `AdminGuard` is **client-only** `is_staff` check — backend `IsAdminUser` is the real gate.
- PWA service worker caches static + `/api/*` NetworkFirst — verify no sensitive GETs are cached (auth headers vary; review `vite-plugin-pwa` runtime caching).
- Maps: `@vis.gl/react-google-maps` with SVG fallback until `VITE_GOOGLE_MAPS_KEY` set — no key committed.

### 3.2 Backend (Django 5 + DRF + Daphne)

- ASGI `config.asgi` (Daphne serves REST + Channels).
- Settings `config/settings/base.py` + `development.py` / `production.py`.
- `AUTH_USER_MODEL = apps.accounts.User` (email-based).
- DRF defaults: JWT auth, `IsAuthenticatedOrReadOnly`, cursor pagination (default 20), django-filter/search/ordering, JSON-only renderer, `common.exceptions` envelope `{success,data,message,errors,pagination,request_id}` (readiness is documented flat-payload exception — see `docs/API_CONTRACT.md`).
- Docs: `drf_spectacular` at `/api/schema/` + Swagger `/api/schema/swagger/`.
- Storage: Cloudinary default; `FileSystemStorage` fallback; messaging attachments + live replays support self-hosted S3 (MinIO) presigned URLs + magic-byte validation.
- TOTP: `django_otp` + `otp_totp` + `pyotp` + recovery codes.

Domain apps:

| App | Purpose | Key models |
|---|---|---|
| `accounts` | Auth, OTP, sessions, export/delete | `User`, `OTPToken`, `DeviceSession`, `AccountEvent` |
| `guardians` | Teen co-owner invites | invite `token_urlsafe(32)` hashed |
| `profiles` | Profiles, buddies/follows/blocks/pings/goals | `Profile`, `BuddyRelationship`, `FollowRelationship`, `BlockRelationship`, `AccountabilityPing`, `SharedGoal` |
| `feed` | 9 post types, comments/reactions/polls/drafts/save/repost/pin | `Post` (+`FeedPost`/`GymPost`), `Comment`, `Reaction`, `Poll`, `Draft` |
| `gyms` | Discovery, memberships, schedule posts, events, donations | `Gym`, `GymMembership`, `GymSchedulePost`, `ScheduleSlotEnrollment`, `GymReview`, `GymDonation` |
| `lives` | LiveKit lives, RSVP, co-host, recording/replays, gifts | `BuddyLive`, `LiveRSVP`, `LiveAttendee` |
| `sessions` | Trainer bookings, availability, async programmes | `TrainerProfile`, `Availability`, `BookingSession`, `Review`, `AsyncProgramme`, `ProgrammeWeek`, `ProgrammeEnrollment` |
| `messaging` | DM/group chat, media, voice, calls, link previews | `Conversation`, `Message`, `MessageReaction`, `CallLog` |
| `marketplace` | Shops, meal plans, programmes, products, events, discounts, cart/checkout | `Shop`, `MealPlan`, `TrainingProgramme`, `Product`, `MarketplaceEvent`, `EventTicket`, `DiscountCode`, `Cart`, `CartItem`, `Order`, `InventoryReservation`, `OrderCase` |
| `wallet` | Artifacts, tips/gifts, purchases, withdrawals, Flutterwave | `LedgerAccount`, `JournalEntry`, `JournalLine`, `ArtifactTransaction` |
| `notifications` | In-app + FCM/WebPush + email | `Notification`, `NotificationPreference` |
| `moderation` | Reports, flags, HITL actions | `ModerationReport`, `ContentFlag`, `ModerationAction`, `ModerationAppeal` |
| `verification` | ID/creator verification | `VerificationDocument`, `VerificationSubmission`, `VerificationDocumentAccess` |
| `ai` | AI orchestration, model registry, API keys | `AIPredictionJob`, `ModelMetadata`, `TrainingRun`, `APIKey` |
| `analytics` | Activity/workouts/meals/body/reports | `ActivityRecord`, `WorkoutLog`, `MealLog`, `BodyMetric`, `AnalyticsReport`, `AnalyticsEvent` |

Common (`backend/common/`): `TimestampedModel`, `SoftDeleteModel`, cursor pagination, permission classes, exception envelope, `utils.py` (`hash_dob`, `calculate_age`, magic bytes), `s3_utils.py`, `authentication.py` (`SafeJWTAuthentication`), `age_gating.py`, `middleware.py` (`RequestIdMiddleware`).

Channels/WS: `CHANNEL_LAYERS` Redis (`channels_redis`); consumers `apps/messaging/consumers.py`, `routing.py`; live presence/chat over ASGI; dev WS `ws://localhost:8002` (`VITE_WS_BASE_URL`).

Celery: Redis broker, `django-db` results; queues `default, high_priority, media, ai`; per-app routing (lives→`media`, ai→`ai`, feed/notifications/marketplace reminders→`high_priority`); Beat DB scheduler (meal reminders hourly, visual-search rebuild weekly, moments expiry hourly, streaks midnight, wallet 5-min, verification purge daily, live reminders 60s, drop-pool 30s, replay-retry 30m).

### 3.3 AI Microservice (FastAPI :8003)

`backend/ai_service/`, internal `AI_SERVICE_URL=http://ai-service:8003` + `X-API-Key: AI_API_KEY` (401 otherwise). Weights under `/models` volume; heavy models unload after 900s idle.

| Router | Endpoints | Purpose |
|---|---|---|
| `food` | `POST /food/recognize` | Food photo → nutrition |
| `moderation` | `POST /moderation/image`, `POST /moderation/text` | NSFW/text safety |
| `policy` | `POST /policy/health-claims`, `/policy/sponsorship` | Medical-claim + disclosure detection |
| `embeddings` | text/image/CLIP store/match/index | Visual search |
| `meal_plans` | `POST /meal-plans/personalise` | Personalised plans |
| `workout` / `form_analyzer` | `POST /workout/analyze`, `/form-analyzer/analyze` | Workout + pose analysis |
| `onboarding` / `health_insights` | personalise / analyze | Onboarding + insights |
| `feed` | `POST /feed/rank`, `/feed/feedback` | ML ranking |
| `video_caption` / `summarize` / `tts` | describe / summarize / synthesize | Florence-2, T5, SpeechT5 |
| `models` / `metrics` | list/sync/reload; metrics | Registry + observability |

Models: `gpt-4o`, `nudenet`, `Florence-2-base`, `CLIP ViT-B/32`, `Falconsai T5`, `SpeechT5 + HiFiGAN`. CPU-viable INT8 path; GPU optional.

### 3.4 Data layer

- PostgreSQL 16 primary; Redis 7 (broker/cache/Channels/bandit store/LiveKit); `/models` volume for AI weights; Cloudinary (default media) + MinIO S3 (replays/attachments) + local fallback.
- Migrations run in API `preDeploy` + `startCommand` (never worker/beat); `schema_status --strict` gate blocks drifted deploys.

---

## 4. Identity, Authentication, Sessions, Age Gating & Verification

### 4.1 How it works today

**Password auth:** Django validators (min 8, similarity/common/numeric); `LoginSerializer` supports reactivation flow.

**Email-first 2-step login (always on):** `LoginView` → 6-digit `secrets.randbelow` OTP via Celery email + 5-min `login_token` (`purpose=login`); `VerifyLoginOTPView` → JWT pair. Registration mirrors with 10-min `purpose=registration`. `channel=phone` exists (Africa’s Talking) but `503` if `AFRICASTALKING_*` unset.

**TOTP:** `pyotp`; setup returns `secret + provisioning_uri + qr_b64`; verify enables + 10× SHA-256 hashed recovery codes (upper-normalised); challenge accepts code **or** single-use recovery code; disable needs password; regen needs fresh TOTP code.

**OAuth:** Google verifies `id_token` (`verify_oauth2_token`, 60s skew) or access-token via `tokeninfo` + `aud==GOOGLE_CLIENT_ID`; Apple fail-closed (requires `APPLE_CLIENT_ID`, fetches `appleid.apple.com/auth/keys` cached 3600s, verifies `RS256/aud/iss`). Both atomic-provision + TOTP challenge if enabled.

**Passkeys/WebAuthn (`py-webauthn`):** `WEBAUTHN_RP_ID/ORIGIN` (default `buddyup.app`), `require_user_verification=True`, server-side single-use challenges (cache 300s), sign-count tracking, 365-day expiry default; revoke/reverify needs step-up (password **or** TOTP **or** recovery code).

**Tokens:** `ACCESS 15 min`, `REFRESH 30 days`, `ROTATE + BLACKLIST_AFTER_ROTATION`. Temp JWTs: registration 10 min, login 5 min, totp_challenge 5 min. OTP rows: 10 min (auth), 30 min (reset); `is_valid = not used AND attempts<3 AND not expired`. WebAuthn challenge 300s; doc access grant 300s; presigned S3 300s. Cleanup crons: OTP 03:45, inactive sessions (>90d) 04:00, verification purge daily.

**Throttles (`base.py:303` + view scopes):** `registration 10/h`, `login 30/h` (incl. Google/Apple/passkey-finish), `otp 10/h`, `password_reset 3/h`, `webauthn 10/h`, `guardian_invite 10/h`, plus `checkout 10/h`, `upload_attachment 20/h`, `link_preview 30/h`, `post_create 30/h`. OTP: 3 wrong → `429`, 60s resend cooldown, generic password-reset response (no enumeration).

**Sessions (`DeviceSession`):** `refresh_token_hash` SHA-256 unique, `device_id` from `X-Device-Id` (≤64), `device_name=User-Agent`, `ip`, `last_active`. Refresh uses `select_for_update` row-lock + double-check (concurrent-reuse safe), rejects inactive/deleted users. Logout/revoke/logout-all + change/set-password/delete/deactivate/reset-confirm all deactivate + blacklist; reset also clears TOTP.

**Age gating:** `BUDDYUP_MINIMUM_AGE=16`; `is_16_plus` must be true; `dob<16` rejected; 16–17 needs guardian contact + `requires_parental_coowner`; `dob_hash=SHA256(isoformat)` **unsalted** (see finding F-01); raw DOB never stored. Social logins default `is_adult=False` + `require_age_setup`; `VerifyAgeView` returns age flags + hash (oracle risk). Mature content: single source `common/age_gating.py`, defaults 18+ everywhere. Frontend `AuthGuard` forces onboarding/`?step=age`; `AdminGuard` cosmetic.

**Verification (`apps/verification`):** types `id/trainer/practitioner/shop/gym`; states `draft→submitted→under_review→approved/rejected/expired`. ID wizard `id_document→selfie_liveness→face_match→review→done`. Upload: 10 MB, ext whitelist, server UUID filename `verification/<profile>/<step>/<hex><ext>`, never public URL. `submit` needs both steps; review `IsAdminUser`-only sets `profile.verification_status`. Face-match `auto|manual`: Rekognition `CompareFaces` ≥80 if `AWS_*` present else `manual_review`; **never auto-rejects**. Privacy: masked `file_url` → `/documents/<id>/`, streamed via 300s presigned or `FileResponse inline; nosniff`; every read audited; retention 90d default, 30d post-review, purge blanks file but keeps metadata.

> **Note — Guardians:** only adults invite; teen provisioning + hashed `token_urlsafe(32)`; public `FamilyAccept` page — review for enumeration/acceptance abuse.

### 4.2 Notes & Tips for Security Review — Identity

- [ ] **Token theft model:** confirm refresh-token rotation + blacklist + `DeviceSession` revocation actually invalidate stolen tokens (test concurrent reuse, revoked-session refresh, deleted-user refresh). Verify `X-Device-Id` binding is enforced, not advisory.
- [ ] **OTP storage & compare:** OTPs are plaintext in DB and compared with `!=` (not `compare_digest`) except reset-confirm. Ask for: hashed OTPs (or encrypted), constant-time compare everywhere, no OTP in logs (dev console backend logs OTP — gate behind `DEBUG` + remove in prod).
- [ ] **`dob_hash` pepper:** unsalted SHA-256 of `YYYY-MM-DD` is brute-forceable. Require HMAC-SHA256 with server pepper (or Argon2id) + remove `VerifyAgeView` hash oracle (return booleans only).
- [ ] **Session lifetimes:** `remember_me=False` still 30 days — decide: short (24h–7d) default vs explicit acceptance. Move JWTs from `localStorage` to HttpOnly `Secure/SameSite` cookies (or split: HttpOnly refresh + memory access) + CSP hardening.
- [ ] **2FA reset:** password-reset disables 2FA on email proof alone — require step-up (TOTP/recovery/passkey) or staff-assisted recovery with delay + alert; keep the existing alert but add delay/cool-down.
- [ ] **OAuth:** verify `aud`, `iss`, `exp` + skew, key caching, and that `tokeninfo` path cannot be confused with `id_token` path. Apple must stay fail-closed (no fallback if keys unset).
- [ ] **WebAuthn:** verify RP ID/origin pinning per environment, challenge single-use + expiry, sign-count anomaly alerting, and that `allow_credentials=[]` (discoverable) flow is intentional.
- [ ] **Rate limits:** load-test `login 30/h` per-IP vs per-account; confirm CAPTCHA/hCaptcha plan after 3 failures (vision doc) is implemented or scheduled; check `TRUSTED_PROXY_IPS` gating for IP extraction (accounts gates correctly; verification `_client_ip` trusts `XFF` unconditionally — fix).
- [ ] **Double-parse:** `SafeJWTAuthentication` + `ConsentEnforcementMiddleware` both parse JWT — consolidate to avoid drift.
- [ ] **Admin:** `AdminGuard` is cosmetic — pen-test admin APIs directly with non-staff tokens; confirm `IsAdminUser` on every admin viewset.

---

## 5. Payments & the Artifact Economy

### 5.1 How money moves

Artifact values (`wallet/serializers.py`): dumbbell $0.10, barbell $0.50, burpee $1.00, squat $2.50, sprint $5.00, PR $10.00, champion $25.00. Bundles override (e.g. squat_10 $3.50). Display USD, settle KES via `KES_PER_USD=129.5` (static — FX drift risk).

**Inflow (purchase `views.py:227-398`):** `POST /wallet/purchase/initialize/` → `ArtifactTransaction(purchase, pending, tx_ref=bp-*)` + M-Pesa STK push (KES) or hosted card (`public_key`, USD). No credit yet. Credit only via `POST /wallet/purchase/confirm/` (`verify_transaction` + amount/currency/ref match) **or** `charge.completed` webhook → `credit_artifacts()` + `post_entry(idempotency=purchase:{tx_ref})` under `select_for_update`; re-checks `status != completed` (replay-safe).

**Internal (tips/gifts/fees):** `POST /wallet/tip/` (20% cut), `gift/` (no fee), `creator/transfer/` (self, `Idempotency-Key` supported), live fees (20%), marketplace/sessions (15% via `PLATFORM_CUTS`). All through `transfer_artifacts()` → single balanced `JournalEntry` + dual JSON mutation in one `atomic()` with ordered locking; `ledger.py` enforces ≥2 lines, debit==credit per artifact type, `IdempotencyConflict` on payload change.

**Outflow (withdraw `views.py:713-846`):** `bank_transfer` only. KYC gate → $10 min → bank pre-validation **before** debit → `reserve_withdrawal()` (balance→escrow, `withdrawal/pending`, `withdrawal_reservation` idempotent on `Idempotency-Key`/`tx_ref=bw-*`) → synchronous `create_transfer_recipient + initiate_transfer(KES)`. Initiation failure → immediate refund; success → `pending` + `process_withdrawal.delay()`. `POST /wallet/payout-request/` **disabled `503`** (legacy amount-only closed) — ops confirms creator cash payouts held.

**Marketplace checkout (`views.py:1812-2175`):** `Cart/CartItem` → `CheckoutCartView` (throttle `checkout`, 5-min `cache.add` idempotency, guardian spend-block): validate (cancelled/self/duplicate, capacity, `select_for_update` stock + `reserved` sum) → totals + discount (validity, usage limits, min purchase, not own code) → `deduct_artifacts` + `purchase/debit` → proportional allocation + `Order(paid)` + fulfillment → `get_or_create` purchases/tickets, `stock-=`, `InventoryReservation(consumed)`, creator credit + platform cut (`clearance_at=now`) → clear cart. Direct single-item buys use older path: regular (not creator) credit, `reference_id=mp_*` not unique per buyer, no cart idempotency.

**Sessions escrow:** `BookingCreateView` → `hold_artifacts` (balance→`locked_balance`, `escrow_hold`, `session_fee held`); children hold separately. Trainer complete → `process_escrow_release` (15% cut, `release_held_to_party` net + `release_held_refund` cut — accounting oddity, see F-08). Client cancel >24h 100%, <24h 50/50; trainer cancel 100%. `clear_locked_balance` auto-refunds expired `held`.

**Webhooks (`views.py:448-542`, `flutterwave.py`):** `POST /wallet/flutterwave-webhook/` (`csrf_exempt`, `AllowAny`). Fail-closed: empty `FLUTTERWAVE_WEBHOOK_HASH` → `503`; `verif-hash` via `hmac.compare_digest` else `403`. `charge.completed` needs `successful` + `select_for_update().get(tx_ref, pending)` + amount (<0.01 float) + currency match; `DoesNotExist` → silent `ok` (anti-oracle). `transfer.*` → complete (escrow→platform) or exactly-once refund (escrow→buyer/seller, `{id}:refund`).

**KYC:** withdrawal/payout needs `verification_status ∈ {id,trainer,practitioner,shop,gym}`; `email/none` can buy/tip but not cash out. Publishing needs approved shop verification + `CreatorPayoutSetup(ready + terms)`. No tiered limits — flat $10 floor only.

**Reconciliation:** launch gate `reconcile_wallet --fail-on-mismatch` must be zero; `reconcile_flutterwave_transactions` (30d, ≤500, verify each, count matched/pending/mismatched/errors, no balance mutation); ops rule: never edit JSON directly, use reversal rows; `tx_ref` unique where non-blank; admin `JournalEntry` read-only.

### 5.2 Notes & Tips for Security Review — Payments

- [ ] **Webhook authenticity:** today static `verif-hash` equality, no body signature/nonce/timestamp. Ask for: raw-body HMAC verification (if provider supports), timestamp window, nonce log, alert on `403` spikes; keep `pending`-gate + idempotency as defence-in-depth. Test replay of a completed webhook (must be no-op) and mismatched amount/currency (must be `400`, no credit).
- [ ] **`ConfirmPurchase` enumeration:** client supplies `flutterwave_id` — verify owner-check + amount/ref match cannot be abused to credit another user’s transaction; fuzz with чужой IDs.
- [ ] **Idempotency gaps:** direct-buy `mp_*` refs reused across buyers (double-POST → double-charge); repeat-tip `reference_id` collision silently drops second tip. Require per-request idempotency (`Idempotency-Key` or `tx_ref` UUID) on all money-moving POSTs; test double-click/retry storms.
- [ ] **`platform_cut` micro-overcharge:** `max(1, int(qty*rate))` takes 100% of a 1-token tip. Require `ceil` with min-fee disclosure or 0-fee micro tier + receipt showing fee math.
- [ ] **Marketplace refunds:** `OrderCase` is request-only — no ledger reversal. Require: refund/dispute state machine that posts compensating `JournalEntry` (never deletes), admin dual-approval above threshold, and customer-visible refund SLA. Until then, keep manual-ops runbook + audit.
- [ ] **Session escrow accounting:** fee path refunds cut to client then charges trainer without matching platform ledger credit — reconcile `Journal` vs JSON balances in staging; fix to escrow→platform directly.
- [ ] **Velocity & KYC tiers:** only $10 floor today. Ask for: daily/weekly caps, per-transaction step-up (TOTP/passkey) above threshold, enhanced DD above AML threshold, `KES_PER_USD` refresh job (remove `TODO`), and FX mismatch alerting.
- [ ] **PCI scope:** `charge_card()` + `card_details: DictField` exist — verify raw PAN/CVV never hits backend (hosted/redirect flow only), never logged, and the serializer field is removed or staff-only. Any change here triggers PCI reassessment.
- [ ] **Race conditions:** non-tracked products + `attendee_count +=` non-atomic (oversell); verify `select_for_update` + `F()` expressions under concurrency tests (e.g. `locust -u 50` checkout same SKU).
- [ ] **Secrets hygiene:** `.env`, `backend/.env`, `frontend/.env` exist locally — verify real `FLWSECK_/whsec_/atsk_` never committed (`git log -p -- .env`, GitHub push protection, `gitleaks` in CI). `.env.example` placeholders are correct — keep them placeholders.
- [ ] **Reconciliation:** run `reconcile_wallet --fail-on-mismatch` in staging weekly; alert on any `mismatched/errors`; verify no direct JSON balance edits (DB trigger or app-level guard + audit).

---

## 6. Data Privacy, PII, Export/Delete & Health Data

### 6.1 How it works today

**Identity minimisation:** `User{email, phone, dob_hash, guardian_*, consent_log{}, deleted_at/hard_delete_at, DeviceSession{device_id, ip, location}}`; `hash_dob()=SHA256(isoformat)` (unsalted — F-01); raw DOB never stored. Consent versions logged (`terms1.2, privacy1.1, guidelines1.2, cookie1.1, medical_disclaimer1.1, sponsorship1.1, adult1.0`).

**Verification (most sensitive):** `VerificationDocument{profile, document_type, file_url, status, purge_after, purged_at}` + per-read `VerificationDocumentAccess`; purge 90d default / 30d post-review blanks file, keeps metadata/audit. Subject + staff scope only; face-match assistive.

**Analytics/health:** `AnalyticsEvent` contract: **never store bodies, raw search, GPS, health values, tokens, emails — metadata only**. Ingest requires `consent.analytics==true`, name regex, 200/batch cap. Tracking models (`ActivityRecord{route:[lat,lng,ts]}`, `WorkoutLog`, `MealLog`, `BodyMetric{weight, fat%, photos}`) FK `Profile CASCADE`.

**Encryption:** transport-only (prod HSTS/SSL, email TLS, JWT). No field-level / at-rest / message encryption. Only “encrypt” hit is `FLUTTERWAVE_ENCRYPTION_KEY`.

**Export:** `POST /api/v1/auth/export-data/` → Celery JSON `{user, profile, posts, comments, messages, transactions, sessions, notifications(prefs+500), activity_events, device_sessions(metadata only, never tokens), analytics, achievements}` → `exports/<username>/YYYYMMDD-HHMMSS-data-export.json` + emailed link (valid while active) + failure email.

**Delete:** deactivate (`is_active=False`, `deleted_at=now`, `hard_delete_at=+30d`, sessions revoked, `delete_user_data(countdown=30d)`); login cancels; sweeper catches lost ETA. Hard delete anonymises `Post/Comment→[Deleted Account]`, deletes buddy/follow/block, deletes `Message.sender=profile`, deletes `Profile+User`. Does **not** purge `Conversation` rows, stored media, verification files (outside purge job).

**Moments:** 24h soft-delete + 7d media cleanup with `TODO Delete from Cloudinary` — verify completion.

### 6.2 Notes & Tips for Security Review — Privacy

- [ ] **At-rest encryption:** require a decision: AES-256-GCM (or KMS envelope) for `email/phone/guardian_*` + verification metadata, or documented risk acceptance with compensating DB access controls + audit. Verify backups are encrypted + retention defined.
- [ ] **Export hardening:** export link must be short-lived, single-use (or few-use), authed, logged; verify no tokens/secrets in export (test explicitly); rate-limit exports; alert on repeated exports (account-takeover signal).
- [ ] **Delete completeness:** produce a deletion matrix (Postgres rows × media × verification files × exports × backups × logs × AI embeddings) with owner + SLA; verify Cloudinary/MinIO deletes actually execute (the Moments TODO is evidence they sometimes don’t); define backup purge window (e.g. 30–90d) in privacy policy.
- [ ] **Health-data posture:** enforce the “not a medical platform” boundary — AI outputs carry `safety_notice`, practitioner content flagged unless `verification_status==practitioner`, broad supplements held without PPB workflow (ops). Require DPIA for Kenya DPA + processor register + retention schedule; confirm clinical notes field is practitioner-private and never used for training/ranking.
- [ ] **GPS/routes:** `ActivityRecord.route` is precise location — require explicit consent, auto-expiry, no precise GPS in logs/analytics events, and coarse-graining for Nearby feed.
- [ ] **Logging:** enforce `OPERATIONS.md:64` (never OTP/JWT/passkey/ID-selfie/bank/card) via log redaction tests + pre-commit secret scan; verify Sentry `send_default_pii=False` stays off.
- [ ] **Consent:** verify `consent_log` records version + timestamp + IP and that withdrawing `analytics` consent stops ingest (`event_ingest` gate) + deletes prior events on request.

---

## 7. Content Moderation & Safety

### 7.1 How it works today

**Ingest (`feed/tasks.py:moderate_content`):** `POST /moderation/text` → flagged; `moderate_policy_text` (practitioner exemption if `verification_status==practitioner`); per-`media_urls` `ai_get(url)` + `POST /moderation/image`; sets `Post.moderation_status: clean/flagged/removed/reviewed`; creates `ContentFlag adult_ungated/nsfw(gated_mature)` + notification.

**Workers (`moderation/tasks.py`):** `moderate_image_url` (mature→nsfw/low/actioned else adult_ungated medium/high), `moderate_text_content` (toxic>0.9 critical, >0.7 high), `moderate_policy_text` (health-claims + sponsorship), `auto_flag_expired_reports` (7d open→dismissed).

**AI (`ai_service/moderation_engine.py`, `policy_engine.py`, `routers/moderation.py`, `routers/policy.py`):** NudeNet (`HIGH≥0.5, MED≥0.65` else skin-ratio>0.35); text OpenAI/moderations → `toxic-bert>0.5` → keyword; policy: `TREATMENT_VERBS+CONDITION_TERMS+RED_FLAG-WELLNESS_SAFE→medical_claim high/medium`; `PROMOTIONAL vs DISCLOSURE (#ad/paid partnership; thanks-to/link-in-bio=weak→flag)`.

**HITL (`apps/moderation`):** `ModerationReport` + ≥3 reports/same target/15 min → `ContentFlag toxic/high`; `ContentFlagViewSet queue(severity+confidence top100)/stats/act(approve/remove/escalate)` updates post; immutable `ModerationAction` audit; `ModerationAppeal` own-actions-only, one appeal, approved suspension/ban reactivates account (content restore needing manual evidence stays explicit). SLA: critical 4h, other 24h, `sla_due_at/sla_breached` exposed.

**Coverage gap:** no auto-moderation in `messaging/consumers.py` (live/gym/DM) — reports only.

### 7.2 Notes & Tips for Security Review — Moderation

- [ ] **Pre-publish vs post-publish:** map which post types are blocked pre-publish vs flagged-post-publish; verify flagged media is blurred until reviewed and cannot be unblurred by URL guessing (signed URLs, no predictable paths).
- [ ] **Health misinformation:** test the practitioner exemption — non-practitioner medical claims must flag; practitioner claims must still flag for red-flag phrases (dosage, cure, diagnosis). Review `WELLNESS_SAFE` allowlist for over-breadth.
- [ ] **Under-16 in content:** face age-estimation flag path (vision doc) — verify implemented or scheduled; define handling (blur + review + takedown SLA).
- [ ] **Live/chat:** DM/group/live chat has no auto-scan — decide: server-side scan with privacy notice (current server-readable store makes this possible) **or** user-report-only with fast SLA; do not claim E2E if scanning (see §8). CSAM `PhotoDNA`-equivalent (vision doc) — verify wired for message media or scheduled.
- [ ] **Appeals & audit:** verify `ModerationAction` immutability (no update/delete API), appeal-once enforcement, and that `sla_breached` alerts fire (not just displayed).
- [ ] **AI fallback:** if OpenAI moderation unavailable, verify `toxic-bert`/keyword fallback still blocks critical categories; test AI-service-down behaviour (fail-closed for NSFW, fail-open with flag for low-risk? — decide and document).
- [ ] **Stress test:** ≥3 reports/15 min auto-flag — test brigading (false-flag) vs under-reporting; add reporter-reputation or staff review before auto-remove.

---

## 8. Messaging, Real-time & Media Security

### 8.1 How it works today (and one correction)

**Correction for prior docs:** `business_model_strategy.md` / `Bud_Master_Business_Plan_2026.md` claim “End-to-end encryption (Signal Protocol-based)” for group chat. **Not true in code.** `Message{body, media_url, metadata}` is **plaintext Postgres**, relayed via Redis; zero `cipher/decrypt/signal/e2e` code. Treat DMs as **server-readable** until E2E ships. Do not promise E2E to users, regulators, or partners.

**Actual controls (`apps/messaging`):** JWT `4001/4003` on WS connect; `Conversation.participants` check; `_allowed_to_message()` (buddy-or-trainer/practitioner); `guardian_blocks_new_dms`; sliding-window `_RateLimiter`; `MAX_BODY_LEN 4000 / metadata 8k / SDP 32k`; same-conversation `reply_to` check; server-overwritten identity; `ServeMessageFileView` prefix/traversal guard + `nosniff/DENY/CSP`; `LinkPreviewView` SSRF/DNS private-IP reject + no-redirect handler; call sessions LiveKit 600s tokens `room=convo_<id>`.

**Uploads:** DMs 50 MB, ext whitelist (images/video/audio/docs), `validate_file_signature` (512-byte magic) + MIME prefix, `messaging/<uuid>.<ext>`. Feed: `_validate_media_items` + `CloudinarySignView` + `is_allowed_media_host` (allowlist + https-only prod, anti-SSRF server fetch), max items, signed `buddyup/posts/<user>/<YYYYMM>` + eager transcode.

**LiveKit:** Django mints room creds (`lives/credentials`); client connects via SDK; replays via egress or chunked S3 upload; final URL on live. Presence/chat over Channels/Redis.

### 8.2 Notes & Tips for Security Review — Messaging & Media

- [ ] **Fix the E2E claim:** remove “Signal Protocol” from business/pitch docs or scope real E2E (key management, recovery, report-decryption-with-consent, metadata minimisation). Until then, privacy policy + in-app copy must say server-readable + report-decryption behaviour.
- [ ] **Spam/abuse:** verify new-buddy 5-msg/hour limit (vision doc) is implemented; test mention-spam, group invite spam, and broadcast-only bypass.
- [ ] **SSRF/link preview:** fuzz `LinkPreviewView` with private-IP, redirect-chain, DNS-rebind, and `file://`/gopher payloads; verify timeouts + size caps + no credential forwarding.
- [ ] **Media validation:** upload polyglots (e.g. GIF+JS, MP4+zip), extension/MIME mismatches, oversized, HEIC edge cases; verify magic-byte check runs **before** storage + that served files use `nosniff` + non-executable disposition.
- [ ] **LiveKit tokens:** verify short TTL (600s calls; lives similar), room-name binding (`convo_<id>` / live ID), role (publisher vs subscriber) least-privilege, and thatjoin-fee is checked server-side before minting (not client-claimed).
- [ ] **Call SDP:** 32k cap is good — verify SDP parsing cannot inject ICE servers (force TURN allowlist) and that `turn.buddyup.app` creds are ephemeral.
- [ ] **Read receipts/presence:** verify online-status toggle is honoured (no presence leak via WS or `Active now` after opt-out).

---

## 9. Infrastructure, Deployment, Network & Observability

### 9.1 How it works today

**Topology (canonical — `docs/OPERATIONS.md:7-27` + `backend/railway.json`):** Railway, one container/service, same images: `buddyup-api` (Daphne `$PORT`), `buddyup-worker` (`-Q default,high_priority,media,ai`), `buddyup-beat` (DB scheduler), `buddyup-web` (Vite build-args + bundled nginx), `buddyup-ai` (`uvicorn --workers 1`); managed Postgres + Redis, Cloudinary/S3, LiveKit cloud/separate, Sentry. Migrations in `preDeploy`, never worker/beat.

**Nginx (prod-ref):** `80→301 https`; `443 ssl http2` (`buddyup.app/www`, `rtc.buddyup.app`); `TLSv1.2+`, `HIGH:!aNULL:!MD5`; certs `ro` mount; `client_max_body_size 60m`; `limit_req api 60r/m + auth 10r/m (burst 5)`; `/api/ /ws/ /admin/` proxy with `X-Forwarded-Proto`, 86400s WS timeout; `/ai/` **not proxied** (internal only); `/replays/` → MinIO bucket (never direct). AI internal `X-API-Key`.

**Headers (`security_headers.conf` + `production.py`):** `X-Frame-Options SAMEORIGIN` (nginx) / `DENY` (Django — reconcile to `DENY` + allowlist Google popup via `frame-src`), `nosniff`, `XSS-Protection`, `Referrer strict-origin-when-cross-origin`, `COOP same-origin-allow-popups` (Google), tight CSP (self + gstatic/accounts.google + Cloudinary + OSM/CARTO/Esri + nominatim + `wss://rtc`), HSTS 1yr + subdomains (+preload in Django). `admin_allowlist.conf` is `allow all` — TODO office/VPN CIDRs + `deny all`.

**Django prod:** `SECURE_SSL_REDIRECT` (+ exempt `^api/v1/health/$` for Railway probe), `HSTS 1yr+preload`, `PROXY_SSL_HEADER`, `SESSION/CSRF Secure+HttpOnly+Lax`, `X-Frame DENY`, `CORS_ALLOW_CREDENTIALS=False`, hardcoded `buddyup.app/www + buddy-up-tan.vercel.app` + sanitised env origins (never crash `E013`), `CSRF_TRUSTED` default `buddyup.app + *.railway + *.vercel`, `ALLOWED_HOSTS` always localhost + railway/vercel/buddyup + env.

**Secrets:** `.env.example` canonical; prod injects via env; `SECRET_KEY=os.environ['SECRET_KEY']` (KeyError if missing); `validate_deploy` fail-closed (SECRET_KEY≥32 not placeholder, `DATABASE_URL/REDIS_URL/METRICS_TOKEN` when not DEBUG, CORS/CSRF/WEBAUTHN/PUBLIC_API checks, warns on `*`/missing webhook/Sentry). Dev fallbacks only in compose/development/livekit.dev. `AI_API_KEY` shared Django→AI (401 otherwise). No secret values logged.

**Launch gate:** `validate_deploy + migrate + schema_status --strict` (preDeploy **and** startCommand) → `/health/ 200 {database,cache,migrations ok}` → `smoke_production.sh` (public + authed probes, short-lived non-staff token) → `reconcile_wallet --fail-on-mismatch==0` → CI green. Rollback code-only, schema-compat check, maintenance-mode payments/writes, re-run health/schema/wallet/smoke + postmortem.

**Health/metrics:** `GET /api/v1/health/` (`AllowAny`) live `SELECT 1` + cache probe + migration plan (60s cache) → `{status, service, release, commit, request_id}` 200/503. `GET /health/metrics/` needs `X-Metrics-Token==METRICS_TOKEN` else `404` masquerade; unset → `404` unless `DEBUG`. Prometheus `buddyup_http_*` per-worker low-cardinality (aggregate at platform).

**Logging:** `verbose` (`request_id name module:lineno`), stdout INFO + `django.request` stderr ERROR, `X-Request-ID` in/out (sanitised alnum-64 else uuid), `method path status duration` only; API errors include `request_id`; Sentry `send_default_pii=False`, traces 0.1. Verification reads audited (actor/purpose/request_id/IP), purge 90/30d.

**LiveKit/TURN:** `livekit.yaml`: 7880, `rtc tcp 7881 + udp 50000-50100 use_external_ip:true`, Redis + password, `${KEY:SECRET}`, TURN udp 3478 + tls 5349 `${TURN_DOMAIN}` + certs, ingress false egress true. Dev: `use_external_ip:false, devkey:secret, TURN off`. Egress: `${INTERNAL_URL} insecure:true`, Redis db1, MinIO `buddyup-replays force_path_style`. Pinned `server:v1.8 + egress:v1.6`, `./livekit.yaml:ro + ./nginx/ssl:/certs:ro`.

**Celery/Redis/Postgres:** Postgres internal-only, `pg_isready`, volume, env creds. Redis `appendonly + requirepass + maxmemory 512m allkeys-lru` (dev 256m no auth), internal-only, authed healthcheck, Channels/cache/LiveKit/broker (`REDIS_URL=redis://:pass@redis:6379/0`). Worker `concurrency 8, warning, max-tasks 1000, -Q …`; beat DB scheduler; routes + schedules as §3.2.

### 9.2 Notes & Tips for Security Review — Infra

- [ ] **TLS/certs:** verify wildcard (or dual-name `rtc`+`turn`) cert validity + auto-renewal + private-key permissions (`ro` mount, 0600, no key in image); test `curl -vI https://buddyup.app` (HSTS, CSP, `nosniff`, `SAMEORIGIN/DENY`) + `testssl.sh` (TLS 1.2+ only, no weak ciphers).
- [ ] **Admin allowlist:** close `allow all` before any prod traffic — office/VPN CIDRs + `deny all` + MFA + audit; verify `/admin/` not exposed via `vercel.json`/Railway preview URLs.
- [ ] **Rate limits at edge:** nginx `auth 10r/m` + DRF throttles must compose (not double-count health/smoke); load-test login/OTP/purchase under NAT (per-IP limits vs shared-office false positives).
- [ ] **Secrets:** rotate all `change-me/devpassword/devkey` defaults; verify `SECRET_KEY≥32` + unique per env, `METRICS_TOKEN` high-entropy, `FLUTTERWAVE_WEBHOOK_HASH` random, LiveKit/MinIO creds unique; add `gitleaks` + push protection + `git log -p` audit for `.env`.
- [ ] **CORS/CSRF:** verify `CORS_ALLOW_CREDENTIALS=False` stays false with Bearer model; fuzz `Origin` (null, subdomain, `*.vercel.app` preview hijack); confirm `CSRF_TRUSTED` cannot be widened via env typo (sanitiser drops malformed, warns).
- [ ] **Health/metrics:** verify metrics 404-masquerade (no `401` oracle), `METRICS_TOKEN` required in prod, per-worker cardinality bounded (no user IDs in labels); health must not leak version/commit to unauthed if policy says otherwise (currently returns `release/commit` — confirm accepted).
- [ ] **Logs:** grep staging logs for `otp|Bearer|passkey|BEGIN PRIVATE|FLWSECK|whsec_|atsk_` — must be zero; verify `X-Request-ID` cannot inject log newlines (sanitised) and that Sentry never captures PII (test with `send_default_pii=False`).
- [ ] **Redis/Postgres:** verify `requirepass`, no public ports in prod, `allkeys-lru` eviction cannot evict Channels/OTP correctness (separate DBs or eviction-exempt keys); confirm backups encrypted + restore tested.
- [ ] **LiveKit/TURN:** verify firewall `80/443/tcp, 7881/tcp, 3478/udp, 5349/tcp, 50000-50100/udp` only; TURN creds ephemeral + domain-pinned; egress writes only to private bucket via `/replays/` proxy (no direct MinIO).
- [ ] **Deploy gate:** run `validate_deploy + migrate + schema_status --strict + smoke_production.sh + reconcile_wallet` in staging and require green CI before prod; verify dashboard command overrides cannot skip migrations (railway.json dual-gate covers this — test it).
- [ ] **PWA cache:** verify authed `/api/*` responses are not served stale to wrong user (auth-aware cache keys, `Vary: Authorization`, short TTL).

---

## 10. Trust Boundaries & Threat Model

### 10.1 Trust zones

```
[0] Attacker (internet) ──TLS──▶ [1] nginx/CDN edge ──▶ [2] SPA (untrusted client)
                                            │
                                            ▼
                              [3] Django API (authenticated, throttled)
                              ├──▶ [4] Postgres (trusted, private net)
                              ├──▶ [4] Redis (trusted, authed, private net)
                              ├──▶ [5] Celery workers (trusted, same image)
                              ├──▶ [5] AI sidecar (semi-trusted, X-API-Key, no inbound from internet)
                              ├──▶ [6] LiveKit SFU (semi-trusted, ephemeral creds)
                              └──▶ [7] Third parties (Flutterwave, Google/Apple, Smile, AWS, SendGrid, FCM — outbound only, verify signatures/issuers)
Media: Cloudinary (signed uploads) / MinIO (private bucket via /replays/ proxy)
```

Every arrow is a boundary: validate + authenticate + authorise + throttle + log (request_id, no secrets).

### 10.2 STRIDE per domain (top risks)

| Domain | Spoofing | Tampering | Repudiation | Info Disclosure | DoS | Elevation |
|---|---|---|---|---|---|---|
| Auth/sessions | OAuth `aud/iss` confusion; `X-Device-Id` spoof | OTP plaintext; refresh reuse race (mitigated by row-lock) | Missing login-anomaly log | JWT in localStorage; `dob_hash` brute-force | Login/OTP throttle bypass via IP rotation | Pwd-reset → 2FA disable; cosmetic AdminGuard |
| Verification | Selfie liveness spoof | Doc ext-whitelist bypass (polyglot) | Missing read-audit | Presigned URL leak; XFF-spoofed IP logs | Review-queue backlog (manual fallback) | Non-staff doc retrieve |
| Wallet | Webhook forgery (static secret) | Amount/currency mismatch; `mp_*` replay | No refund ledger for disputes | `flutterwave_response` fiat/PII in tx rows | Checkout oversell race | `card_details` PCI scope creep |
| Feed/moderation | Practitioner impersonation | Health-claim bypass (synonyms) | Mutable moderation history (mitigated: immutable rows) | Flagged media URL guess | Report brigading | Moderator → arbitrary remove |
| Messaging | Identity spoof (mitigated: server-overwritten) | SDP ICE injection | Deleted-message retention unclear | **Server-readable DMs** (E2E misclaim) | WS flood (mitigated: limiter) | Trainer-chat auto-open abuse |
| Infra | Preview-URL CORS hijack | Env typo widens CORS (mitigated: sanitiser) | Missing request_id on async tasks | Metrics/health version leak | Redis eviction; LiveKit UDP flood | Admin `allow all` |

### 10.3 Attack surfaces to pen-test first

1. Auth: login/OTP/TOTP/passkey/OAuth/age-setup/guardian-accept.
2. Money: initialize/confirm/webhook/tip/gift/withdraw/cart-checkout/direct-buys/refund.
3. Docs: verification upload/submit/review/retrieve/access-grant.
4. Chat/live: WS auth, attachment upload, link preview, LiveKit creds, replay URLs.
5. Edge: nginx auth limits, admin allowlist, CORS/CSRF, CSP, metrics masquerade.

---

## 11. Findings & Remediation Roadmap

Severity: **P0** = block/schedule before prod or risk-accept in writing. **P1** = fix in next hardening sprint. **P2** = defence-in-depth.

| ID | Finding | Impact | Fix | Severity |
|---|---|---|---|---|
| F-01 | `dob_hash` unsalted SHA-256 of `YYYY-MM-DD` + `VerifyAgeView` oracle | Identity linkage / age-bypass recon | HMAC-SHA256 with pepper (or Argon2id); return booleans only; backfill | **P0** |
| F-02 | OTP plaintext + `!=` compare (non-constant-time) + dev log | OTP theft / timing oracle | Hash OTPs, `compare_digest` everywhere, remove dev log in prod | **P0** |
| F-03 | JWT in `localStorage` + 30-day refresh even when `remember_me=False` | XSS → long-lived theft | HttpOnly refresh + memory access (or documented acceptance) + short default session | **P0** |
| F-04 | Pwd-reset disables 2FA on email proof alone | Email-takeover → 2FA bypass | Step-up or delayed recovery + alert + cool-down | **P0** |
| F-05 | E2E claim false (DMs plaintext) | Regulatory / trust / disclosure | Remove claim or ship real E2E; update policy/copy | **P0** |
| F-06 | Marketplace `OrderCase` no settlement | Dispute fund loss / manual error | Compensating ledger reversals + dual-approval + SLA | **P0** |
| F-07 | Direct-buy no idempotency; tip `reference_id` collision | Double-charge / dropped tip | Per-request `Idempotency-Key`/`tx_ref` UUID on all money POSTs | **P0** |
| F-08 | Session fee ledger oddity (cut via refund then charge) | Reconciliation mismatch | escrow→platform directly; add ledger invariant test | **P0** |
| F-09 | Webhook static compare, no nonce/timestamp | Forgery/replay (mitigated by pending-gate) | Body HMAC + window + nonce log + alerting | **P1** |
| F-10 | `platform_cut` min-1 overcharges micro-tips | User harm / dispute | Fix fee math + receipt disclosure | **P1** |
| F-11 | No velocity caps / step-up for withdrawals; static FX | Fraud / FX loss | Daily caps, step-up above threshold, FX refresh + alerts | **P1** |
| F-12 | `card_details: DictField` + `charge_card()` raw PAN path | PCI scope | Remove/ staff-gate + never log; reassess if wired | **P1** |
| F-13 | No at-rest PII encryption | DB/backup disclosure | KMS envelope for email/phone/guardian/verification meta or acceptance | **P1** |
| F-14 | Verification `_client_ip` trusts XFF | Audit poisoning | Gate by `TRUSTED_PROXY_IPS` like accounts | **P1** |
| F-15 | Admin allowlist `allow all` | Admin exposure | Office/VPN CIDRs + deny-all + MFA | **P0** (infra) |
| F-16 | Delete incomplete (conversations/media/verification/backups) + Moments Cloudinary TODO | GDPR/Kenya DPA breach | Deletion matrix + purge jobs + backup window + policy update | **P1** |
| F-17 | Inventory/`attendee_count` non-atomic | Oversell | `select_for_update` + `F()` + concurrency test | **P1** |
| F-18 | Live/chat/media no auto-scan; PhotoDNA unwired | CSAM / abuse | Wire scan or document report-only + SLA; fix copy | **P1** |
| F-19 | Double JWT parse (auth + middleware) | Drift / bypass | Single auth path | **P2** |
| F-20 | Per-worker metrics need aggregation; health leaks release/commit | Ops blind / version oracle | Platform aggregation + confirm disclosure accepted | **P2** |

**Suggested order:** F-15 + F-01–F-08 (pre-prod gate) → F-09–F-14 (hardening sprint) → F-16–F-20 (privacy/robustness).

---

## 12. Working With Engineering

### 12.1 What to ask for in review

- Staging access (non-staff smoke account, no real PII/funds) + `SMOKE_ACCESS_TOKEN` handling per `docs/OPERATIONS.md`.
- `X-Request-ID` for every finding (response header + error `request_id`) — engineering traces via Railway/Sentry.
- Read-only audit queries: `VerificationDocumentAccess`, `ModerationAction`, `JournalEntry/Line`, `ArtifactTransaction`, `AccountEvent`, `reconcile_wallet` output.
- Threat-model walkthrough (60 min): demo auth → tip → checkout → withdraw → verify → moderate → delete.

### 12.2 Evidence engineering can provide

- `validate_deploy`, `migrate`, `schema_status --strict`, `/health/`, `smoke_production.sh`, `reconcile_wallet --fail-on-mismatch`, CI backend/frontend/android green.
- Webhook `403` rate, OTP `429` rate, moderation `sla_breached` count, 5xx/p95 by path, Celery queue age, LiveKit join/TURN/replay failure.

### 12.3 Incident handling (align with `docs/OPERATIONS.md` Rollback)

1. Preserve `request_id`s + timeline; maintenance-mode payments/writes if money involved.
2. Roll back code only (check schema compat); re-run health/schema/wallet/smoke.
3. Finance incidents: never edit JSON balances — reviewed reversal rows only.
4. Postmortem with request IDs + remediation owner + date.

### 12.4 Launch-gate recommendation (for Charles’s sign-off)

- **Approve launch-core** when F-01–F-05 + F-15 remediated or risk-accepted with compensating monitoring.
- **Approve controlled-beta** (marketplace/lives/AI) when F-06–F-08 + F-09–F-12 closed or feature-flagged off.
- **Keep held** (cash payouts, artifact expansion, clinical AI, broad supplements) until double-entry settlement + PPB workflow + DPIA complete.

---

## Appendix A: Secret / Env Inventory (non-secret names only)

`DB_*`, `SECRET_KEY`, `DEBUG`, `ALLOWED_HOSTS`, `CORS_ALLOWED_ORIGINS`, `CSRF_TRUSTED_ORIGINS`, `GOOGLE_CLIENT_ID/SECRET`, `APPLE_CLIENT_ID/TEAM_ID/KEY_ID/PRIVATE_KEY`, `REDIS_PASSWORD`, `CLOUDINARY_URL`, `SENDGRID_API_KEY`, `AFRICASTALKING_*`, `MPESA_*`, `STRIPE_*` (legacy), `FLUTTERWAVE_SECRET/PUBLIC/ENCRYPTION/WEBHOOK_HASH`, `KES_PER_USD`, `LIVEKIT_URL/INTERNAL_URL/TURN_DOMAIN/API_KEY/API_SECRET`, `MINIO_*`, `LIVE_RECORDING_S3_*`, `LIVE_REPLAY_BASE_URL`, `OPENAI_API_KEY/MODEL`, `AI_SERVICE_URL/API_KEY`, `AI_MODEL_CACHE_DIR/HF_HOME`, `HF_TOKEN`, `AGORA_*`/`MUX_*`/`MESSAGING_S3_*` (legacy/unused), `AWS_*`, `FIREBASE/FCM/VAPID_*`, `SMILE_IDENTITY_*`, `FACE_MATCH_BACKEND`, `VERIFICATION_*_RETENTION_DAYS`, `SENTRY_DSN`, `RELEASE_VERSION/COMMIT`, `METRICS_TOKEN`, `VITE_*`, `PUBLIC_API_URL/FRONTEND_URL`, `WEBAUTHN_RP_ID/ORIGIN`, `EMAIL_LOGO_URL`, `BUDDY_SCALE`, `KAGGLE_API_TOKEN`.

> Tip: audit with `gitleaks`, GitHub push protection, and `python manage.py validate_deploy` (fail-closed). Never commit `.env` / `backend/.env` / `frontend/.env`.

## Appendix B: Key API Surfaces

| Action | Endpoint |
|---|---|
| Auth/OTP/2FA/passkeys | `/api/v1/auth/*` |
| Health / metrics | `/api/v1/health/`, `/api/v1/health/metrics/` (X-Metrics-Token) |
| Feed | `/api/v1/feed/?tab=&cursor=`, `POST /feed/create/` |
| Lives | `/api/v1/lives/*` (browse/start/join/credentials/recording) |
| Messaging | `/api/v1/messaging/*` + WS channels |
| Marketplace | `/api/v1/marketplace/*` (cart/discount/checkout/orders/cases) |
| Wallet | `/api/v1/wallet/*` (`purchase/*`, `tip`, `gift`, `withdraw`, `flutterwave-webhook`) |
| Sessions | `/api/v1/sessions/*` (+ `.ics` export) |
| Gyms | `/api/v1/gyms/*` (schedule, donations, reviews) |
| Verification | `/api/v1/verification/*` (`documents/<id>/`, `documents/<id>/access/`) |
| Moderation | `/api/v1/moderation/*` (`reports`, `content-flags`, `actions`, appeals) |
| Notifications | `/api/v1/notifications/*` (FCM/WebPush/email) |
| Analytics | `/api/v1/analytics/*` (summary/activities/workouts/meals/body/report) |
| AI proxy | `/api/v1/ai/*` → FastAPI `:8003` |
| Schema | `/api/schema/`, `/api/schema/swagger/` |

Envelope: `{success, data, message, errors, pagination, request_id}` (readiness flat-payload exception).

## Appendix C: Key Source Files

- Auth: `backend/apps/accounts/views.py|models.py|serializers.py|urls.py|tasks.py|policy_versions.py`, `backend/common/authentication.py|permissions.py|age_gating.py|middleware.py|utils.py`, `backend/apps/guardians/`, `frontend/src/api/auth.ts|client.ts`, `frontend/src/router.tsx`, `frontend/src/store/authStore.ts`
- Verification: `backend/apps/verification/views.py|models.py|services.py|serializers.py|tasks.py`
- Wallet: `backend/apps/wallet/views.py|models.py|ledger.py|utils.py|tasks.py|serializers.py|flutterwave.py`, `management/commands/reconcile_wallet.py`, `backend/apps/marketplace/views.py` (checkout), `backend/apps/sessions/views.py|tasks.py` (escrow), `backend/apps/lives/views.py` (fees/gifts)
- Privacy/moderation/messaging: `backend/apps/accounts/tasks.py` (export/delete), `backend/apps/analytics/models.py|engine.py|event_ingest.py`, `backend/apps/moderation/models.py|views.py|tasks.py`, `backend/apps/messaging/models.py|views.py|consumers.py|auth.py|routing.py`, `backend/apps/feed/tasks.py|views.py|uploads.py|media_types.py`, `backend/ai_service/app/moderation_engine.py|policy_engine.py`, `backend/ai_service/app/routers/moderation.py|policy.py`
- Infra: `docker-compose.yml`, `docker-compose.prod.yml`, `nginx/nginx.conf|security_headers.conf|admin_allowlist.conf`, `backend/Dockerfile`, `frontend/Dockerfile|nginx.frontend.conf`, `backend/config/settings/base.py|production.py|development.py`, `backend/config/celery.py`, `backend/railway.json`, `backend/common/middleware.py|observability.py|management/commands/validate_deploy.py`, `livekit.yaml|livekit.dev.yaml|livekit-egress.yaml`, `.env.example`, `vercel.json`, `scripts/smoke_production.sh`, `docs/OPERATIONS.md`

## Appendix D: Glossary

- **Artifact:** in-app currency unit (dumbbell … champion). **Tip/gift/fee:** internal transfers with platform cut. **Escrow:** held balance for sessions (`locked_balance`) / withdrawals (ledger escrow).
- **Buddy Up:** mutual follow → DM unlock (vs one-way follow, vs gym membership).
- **Random Drop:** spontaneous matched live (2–15, no host).
- **HITL:** human-in-the-loop moderation. **SLA:** critical 4h / other 24h.
- **DeviceSession:** refresh-token binding (device_id/IP/UA). **Idempotency-Key:** replay-safe money POSTs.
- **P0/P1/P2:** blocker / next-sprint / defence-in-depth.

---
*End of document — questions to Engineering with `X-Request-ID`s; findings mapped to §11 IDs.*
