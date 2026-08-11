# BuddyUp — Technical Architecture & Platform Services

> Health & fitness social platform — "find your workout buddy, train together, earn together."
> This document describes the overall system structure, the services the platform exposes,
> and how the major components communicate.

---

## 1. High-Level Architecture

BuddyUp is a **modular monolith** (Django) fronted by a **React (Vite) web client**, with a **FastAPI AI microservice**, real-time infrastructure (**LiveKit** WebRTC, **Redis + Channels**), and an async task layer (**Celery**). All services run together under **Docker Compose** for development.

```
Browser (React/Vite :3002)
   │  REST (axios)                     WS (Django Channels / websockets)
   ▼                                  ▼
┌─────────────────────────┐   ┌──────────────────────────┐
│  Django backend (Daphne)│◄──│ Redis (broker / channel   │
│  REST API :8002         │   │  layer / bandit store)    │
└──────────┬──────────────┘   └───────────┬───────────────┘
           │ HTTPS / internal              │
           ▼                              ▼
┌─────────────────────────┐   ┌──────────────────────────┐
│  AI microservice        │   │  Celery worker + beat     │
│  FastAPI :8003          │   │  (queues: default, high_  │
│  (ML models, HF cache)  │   │   priority, media, ai)    │
└─────────────────────────┘   └──────────────────────────┘
           │
           ▼
┌─────────────────────────┐   ┌──────────────────────────┐
│  PostgreSQL :5432       │   │  LiveKit :7880 (WebRTC)   │
│  (primary datastore)    │   │  Cloudinary / S3 (media)  │
└─────────────────────────┘   └──────────────────────────┘
```

### 1.1 Containers (docker-compose)

| Service | Image / Build | Role | Exposed port |
|---|---|---|---|
| `db` | `postgres:16-alpine` | Primary datastore | 5432 |
| `redis` | `redis:7-alpine` | Broker, Channels layer, feed bandit store | 6379 |
| `ai-service` | `backend/ai_service/Dockerfile` | FastAPI ML microservice | 8003 |
| `backend` | `backend/Dockerfile` (dev target) | Django + Daphne (HTTP + WS) | 8002 |
| `livekit` | `livekit/livekit-server` | Self-hosted WebRTC SFU | 7880/7881, 50000-50100 UDP |
| `celery-worker` | `backend/Dockerfile` | Async tasks (4 queues) | — |
| `celery-beat` | `backend/Dockerfile` | Scheduled jobs (DB scheduler) | — |
| `frontend` | `frontend/Dockerfile` (dev target) | Vite dev server | 3002 |

---

## 2. Backend (Django REST Framework)

### 2.1 Settings & Framework

- **ASGI app**: `config.asgi` (Daphne) — serves both REST and WebSocket/Channels traffic.
- **Settings**: `config/settings/base.py` + `development.py` / `production.py`.
- **Auth**: `AUTH_USER_MODEL = apps.accounts.User` (email-based). JWT via `rest_framework_simplejwt`
  — 15-minute access tokens, 30-day rotating refresh tokens bound to `DeviceSession`, blacklisted on rotation.
- **Auth backends**: Google OAuth2, Apple, plus Django model backend (`social_django`).
- **DRF defaults**: JWT auth, `IsAuthenticatedOrReadOnly`, cursor pagination (`common.pagination.CursorPagination`, default 20),
  Django-filter + search + ordering, JSON renderer, custom exception handler (`common.exceptions`), scoped rate throttling
  (`registration 10/h`, `login 30/h`, `otp 3/h`, `password_reset 3/h`, `upload_attachment 20/h`, `link_preview 30/h`).
- **TOTP**: `django_otp` + `otp_totp` for two-factor.
- **Media storage**: Cloudinary by default (`cloudinary_storage`); falls back to `FileSystemStorage` when no Cloudinary
  credentials are configured. Messaging attachments and live replay recording support self-hosted **S3-compatible** storage
  (MinIO) with presigned URLs and magic-byte validation.
- **API docs**: `drf_spectacular` schema at `/api/schema/` + Swagger UI at `/api/schema/swagger/`.
- **API envelope**: every endpoint returns `{ success, data, message, errors, pagination }`.

### 2.2 Application modules

| App | Purpose | Key models |
|---|---|---|
| `accounts` | Auth, registration (OTP), login, sessions, data export | `User`, `OTPToken`, `DeviceSession`, `AccountEvent` |
| `profiles` | Profiles, buddies, follows, blocks, pings, shared goals | `Profile`, `BuddyRelationship`, `FollowRelationship`, `BlockRelationship`, `AccountabilityPing`, `SharedGoal` |
| `feed` | Social feed, posts (9 types), comments, reactions, polls, drafts, save/repost/pin | `Post` (+`FeedPost`/`GymPost`), `Comment`, `Reaction`, `Poll`, `PollOption`, `PollVote`, `Draft` |
| `gyms` | Gym discovery, memberships, classes (schedule posts), events, donations | `Gym`, `GymCategory`, `GymMembership`, `GymSchedulePost`, `ScheduleSlotEnrollment`, `GymReview`, `GymDonation` |
| `lives` | Live streaming (LiveKit), RSVP, co-hosting, recording/replays, gifts/refunds | `BuddyLive`, `LiveRSVP`, `LiveAttendee` |
| `sessions` | 1:1 trainer bookings, availability, async programmes | `TrainerProfile`, `Availability`, `BookingSession`, `Review`, `AsyncProgramme`, `ProgrammeWeek`, `ProgrammeEnrollment` |
| `messaging` | Direct & group chat, media, voice notes, calls, link previews | `Conversation`, `Message`, `MessageReaction`, `CallLog` |
| `marketplace` | Shops, meal plans, training programmes, products, events, discounts, cart/checkout | `Shop`, `MealPlan`, `TrainingProgramme`, `Product`, `MarketplaceEvent`, `EventTicket`, `DiscountCode`, `Cart`, `CartItem` |
| `wallet` | In-app artifacts currency, tips/gifts, purchases, withdrawal, Flutterwave | `ArtifactTransaction` |
| `notifications` | In-app + push (FCM/WebPush) + email notifications | `Notification`, `NotificationPreference` |
| `moderation` | Reports, content flags, human-in-the-loop moderation actions | `ModerationReport`, `ContentFlag`, `ModerationAction` |
| `verification` | Identity / creator verification documents | `VerificationDocument`, `VerificationSubmission` |
| `ai` | AI task orchestration, model registry, admin API keys | `AIPredictionJob`, `ModelMetadata`, `TrainingRun`, `APIKey` |
| `analytics` | User analytics: activity tracker, workouts, meals, body metrics, report | `ActivityRecord`, `WorkoutLog`, `MealLog`, `BodyMetric`, `AnalyticsReport` |

### 2.3 Common infrastructure (`backend/common/`)

- `models.py` — `TimestampedModel` (created/updated at), `SoftDeleteModel` (deleted-at flag).
- `pagination.py` — cursor pagination.
- `permissions.py` — shared DRF permission classes.
- `exceptions.py` — uniform error envelope.
- `utils.py`, `s3_utils.py` — helpers and S3-compatible upload helpers.

### 2.4 Real-time (Channels / WebSocket)

- `CHANNEL_LAYERS` uses Redis (`channels_redis`). Consumers live in `apps.messaging/consumers.py`,
  `apps/messaging/routing.py`; live rooms, presence, and chat all flow over the ASGI layer.
- WebSocket base URL in dev: `ws://localhost:8002` (`VITE_WS_BASE_URL`).

### 2.5 Async & scheduled jobs

- **Celery** with Redis broker; result backend is the DB (`django-db`).
- Four queues: `default`, `high_priority`, `media`, `ai` with per-app routing
  (lives → `media`, ai → `ai`, feed/notifications/marketplace reminders → `high_priority`).
- **Beat schedule** (DB scheduler): hourly meal-plan reminders, weekly visual-search index rebuild.

---

## 3. AI Microservice (FastAPI)

A standalone Python service (`backend/ai_service/`) exposing `/api/v1/*` routes on :8003.
Called by Django over internal HTTP (`AI_SERVICE_URL`). Model weights persist under a `/models` volume.

| Router | Endpoints | Purpose |
|---|---|---|
| `food` | `POST /food/recognize` | Food photo → recognition + nutrition |
| `moderation` | `POST /moderation/image`, `POST /moderation/text` | NSFW / text safety checks |
| `embeddings` | text/image/CLIP embedding, store, match, index build/search | Visual search (marketplace) |
| `meal_plans` | `POST /meal-plans/personalise` | Personalised meal-plan generation |
| `workout` | `POST /workout/analyze` | Workout analysis |
| `onboarding` | `POST /onboarding/personalise` | Personalised onboarding |
| `health_insights` | `POST /health-insights/analyze` | Health insight generation |
| `form_analyzer` | `POST /form-analyzer/analyze` | Exercise form analysis (pose landmarker) |
| `feed` | `POST /feed/rank`, `POST /feed/feedback` | ML feed ranking |
| `video_caption` | `POST /workout/describe` | Video captioning (Florence-2) |
| `summarize` | `POST /summarize` | Text summarisation (T5) |
| `tts` | `POST /tts/synthesize`, `GET /tts/speakers` | Speech synthesis (SpeechT5) |
| `models` | list/sync/active/reload | Model registry management |
| `metrics` | `/api/v1/*` | Service metrics |

**Models** (`config.py`): `gpt-4o` (LLM), `nudenet` (NSFW), `florence-community/Florence-2-base` (captioning),
`openai/clip-vit-base-patch32` (CLIP embeddings), `Falconsai/text_summarization` (T5), `microsoft/speecht5_tts` + `speecht5_hifigan` (TTS).
Heavy models unload after an idle TTL (`model_idle_ttl = 900s`) to free RAM.

---

## 4. Frontend (React / Vite / TypeScript)

### 4.1 Structure (`frontend/src/`)

| Directory | Contents |
|---|---|
| `api/` | Axios service modules per domain (`client.ts`, `auth.ts`, `feed.ts`, `gyms.ts`, `lives.ts`, `messaging.ts`, `marketplace.ts`, `wallet.ts`, `profiles.ts`, `sessions.ts`, `notifications.ts`, `verification.ts`, `analytics.ts`, `activity.ts`, `admin.ts`) |
| `components/` | Reusable UI (`ui/`), layout (`layout/`), feature components (`features/`) |
| `pages/` | Route pages: `app/` (authenticated app screens), `auth/` (login/register/OTP/TOTP), `legal/`, `Landing.tsx` |
| `store/` | Zustand stores: `authStore`, `notificationStore`, `presenceStore`, `callStore`, `chatPreferencesStore`, `artifactStore`, `sidebarStore`, `themeStore` |
| `hooks/` | `useAuth`, `useChatSocket`, `useVoiceRecorder`, `useWebRTC`, etc. |
| `router.tsx` | Route tree with `AuthGuard`, `AdminGuard`, lazy-loaded pages |
| `types/` | Domain TypeScript types |
| `lib/`, `utils/`, `styles/` | Helpers, constants, global styles (Tailwind theme tokens) |

### 4.2 Conventions

- **API client**: `api/client.ts` — axios instance pointing at `VITE_API_BASE_URL` (default `http://localhost:8002/api/v1`),
  attaches JWT access tokens, and transparently refreshes on 401 (with a failed-request queue).
- **Routing**: `createBrowserRouter`; protected pages wrapped in `AuthGuard` + `AppShell` (sidebar / bottom nav).
  Routes such as `/feed`, `/analytics`, `/marketplace`, `/lives`, `/sessions`, `/messages`, `/wallet`, `/profile`.
- **Styling**: Tailwind with BuddyUp design tokens (`buddy-green`, `buddy-black`, `buddy-surface`, etc.),
  a dark-first visual identity; lucide-react icons; `@radix-ui/*` primitives.
- **Charts**: `recharts`; **maps**: `@vis.gl/react-google-maps` with an SVG fallback (`SvgRouteMap`) until
  `VITE_GOOGLE_MAPS_KEY` is configured.
- **Real-time**: chat via WebSocket hook (`useChatSocket`); live streaming via Agora/LiveKit hooks; presence via `presenceStore`.
- **Progressive Web App**: Vite PWA plugin with service-worker caching for static assets, fonts, images, and `/api/*` (NetworkFirst).

---

## 5. Real-Time & Streaming Services

### 5.1 Live streaming (LiveKit)
- Rooms hosted by a self-hosted LiveKit SFU (`:7880`). Django issues room credentials
  (`lives/credentials`), and the client connects via the LiveKit SDK.
- **Replays/recording**: LiveKit egress (`lives/recording.py`) or client-side chunked recording
  (`lives/recording/upload`) that streams chunks to S3-compatible storage; final replay URL stored on the live.

### 5.2 Chat (Django Channels + Redis)
- Direct/group conversations, message reactions, read receipts, voice notes (uploaded attachments),
  polls, location sharing, and call logs — all over authenticated WebSocket channels.

### 5.3 Agora (legacy RTC)
- `AGORA_APP_ID` / certificate configured for older WebRTC flows (callStore + `useWebRTC`).

---

## 6. Payments & Monetisation

- **In-app currency**: artifacts (`wallet.ArtifactTransaction` with types: gift/tip/live_fee/session_fee/gym_subscription/marketplace, status `completed`).
- **Flutterwave** (`wallet/flutterwave.py`): top-up purchases (`purchase/initialize` → `purchase/confirm`),
  webhooks (`flutterwave-webhook`), encryption key, bank transfer withdrawals (`withdraw`, `bank-resolve`).
- **Marketplace checkout**: cart → discount codes → checkout (`cart/discount`, `cart/checkout`);
  shop certification (`shop/certification`), creator analytics (`my-services/analytics`), discount-code analytics.
- **Exchange rates** endpoint (`exchange-rates`) for artifact↔fiat conversions.

---

## 7. Moderation & Safety

- Dual path: **automated** moderation via the AI service (`moderation/image`, `moderation/text`; NSFW via NudeNet)
  plus **human-in-the-loop** (HITL): `moderation/reports`, `content-flags`, `actions` view sets
  (approve / remove / escalate), with the moderator fallback chain (content author → moderator) for action targets.
- Content lifecycle states: `clean → flagged → reviewed / removed`; flagged media is blurred in the UI until reviewed.
- Rate limiting, OTP (registration + login + 2FA TOTP), minimum age (16), GDPR-style account export/delete flows.

---

## 8. Analytics (recent feature)

New app `apps.analytics` mounted at `/api/v1/analytics/`:

| Endpoint | Purpose |
|---|---|
| `GET /summary/?period=` | Aggregated analytics across workouts, activity, nutrition, body, lives, spending, programmes (period: week/month/quarter/year/all) |
| `GET/POST /activities/` (+`/<pk>/`) | Walking/running/hiking/cycling tracker records with GPS route |
| `GET/POST /workouts/` (+`/<pk>/`) | Workout logging |
| `GET/POST /meals/` (+`/<pk>/`) | Meal logging with macros |
| `GET/POST /body/` (+`/<pk>/`) | Weight / body-composition check-ins (multipart `photo` → body snap) |
| `GET /report/` | Generate comprehensive report (JSON + watermarked PNG via Pillow) |
| `GET /report/download/` | Download the report image URL |
| `POST /report/share/` | Share the report as a `progress` feed post |

Engine (`engine.py`) pulls from dedicated tracking models plus existing platform data
(feed workout/meal posts, `LiveAttendee`, completed `ArtifactTransaction`s, programme/meal-plan purchases, enrolments).
Report images render at 1080×1560 via Pillow with a `BUDDY-UP` watermark and are stored under `/media/reports/`.

---

## 9. Integration Summary (Web → API)

| Client action | REST endpoint | Real-time / async |
|---|---|---|
| Auth / register / OTP / 2FA | `/api/v1/auth/*` | — |
| Feed (for_you/following/videos) | `/api/v1/feed/?tab=&cursor=` | AI rank via `/feed/rank` |
| Create post (text/photo/poll/meal/workout/progress) | `POST /api/v1/feed/create/` | media upload; moderation async |
| Live browse/start/join | `/api/v1/lives/*` | LiveKit room creds; recording via S3 |
| Chat | `/api/v1/messaging/*` | WebSocket channel |
| Marketplace browse/buy | `/api/v1/marketplace/*` | cart/checkout via wallet |
| Wallet top-up/transfer | `/api/v1/wallet/*` | Flutterwave webhook |
| Sessions / trainers | `/api/v1/sessions/*` | .ics calendar export |
| Gyms | `/api/v1/gyms/*` | schedule posts, donations |
| Notifications | `/api/v1/notifications/*` | FCM / WebPush / email |
| Analytics | `/api/v1/analytics/*` | report render (Pillow) |
| Health / food / form / insights AI | `/api/v1/ai/*` (proxy) | FastAPI :8003 |

---

## 10. Env / Configuration Keys (non-secret notes)

- `VITE_API_BASE_URL`, `VITE_WS_BASE_URL` — API + WebSocket base (dev: localhost:8002).
- `VITE_GOOGLE_MAPS_KEY` — Google Maps key for `RouteMap` (placeholder `xxxxx` → SVG fallback used).
- `AI_SERVICE_URL` — internal FastAPI address (`http://ai-service:8003`).
- `LIVEKIT_URL` / `LIVEKIT_INTERNAL_URL` / keys — WebRTC SFU.
- `CLOUDINARY_*` / `MESSAGING_S3_*` / `LIVE_RECORDING_S3_*` — media storage backends.
- `FLUTTERWAVE_*` — payments. `FCM_*` / `VAPID_*` — push. `AFRICASTALKING_*` — SMS.
- `GOOGLE_PLACES_API_KEY` — places search for gym/city lookups.

---

## 11. Future / Roadmap Notes

- **Flutter mobile client** (`buddy_up_flutter`) planned but deferred — backend + web prioritised first.
- Google Maps key to be supplied later to activate real map rendering on the analytics Activity/RouteMap.
- AI service supports GPU-accelerated serving but runs CPU-viable INT8 path for development.
