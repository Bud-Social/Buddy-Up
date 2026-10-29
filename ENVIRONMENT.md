# Environment variables you need to fill before publishing

Checked against the running `buddyup_backend` container on 2026-10-16. This is
every variable that is **empty, a placeholder, or set to a development value**
right now — not a full inventory of everything configured.

Values marked **set** are already populated and only need review, not filling.

---

## 1. Blocking — nothing works correctly without these

| Variable | Current | What to put |
|---|---|---|
| `SECRET_KEY` | `change-me-to-a-long-random-string` | `python -c "from django.core.management.utils import get_random_secret_key as k; print(k())"` — at least 50 chars. **Rotating this invalidates every session and JWT.** |
| `DEBUG` | `True` | `False` |
| `DJANGO_SETTINGS_MODULE` | `config.settings.development` | `config.settings.production` |
| `DATABASE_URL` | `…@db:5432/buddyup_dev` | `postgresql://buddyup:<real-password>@<host>:5432/<real-db>` |
| `ALLOWED_HOSTS` | `localhost,127.0.0.1,backend` | Your real hostname(s), comma separated |
| `CORS_ALLOWED_ORIGINS` | `http://localhost:3002,…` | `https://buddyup.app` (your web origin) |
| `REDIS_URL` | `redis://redis:6379/0` | Managed Redis in production — this holds rate limits and Celery queues |

`DEBUG=True` is the single most dangerous line in that table: with it on,
Django serves tracebacks with source, and this is a platform that holds ID
documents, payment intents and gym membership rosters.

---

## 2. Payments — checkout cannot take money

| Variable | Current | Notes |
|---|---|---|
| `FLUTTERWAVE_PUBLIC_KEY` | *(empty)* | Flutterwave dashboard → API Keys. `FLWPUBK_TEST_…` for sandbox |
| `FLUTTERWAVE_SECRET_KEY` | *(empty)* | Same page. Never commit it |
| `FLUTTERWAVE_WEBHOOK_HASH` | *(empty)* | **A random string you invent.** Flutterwave echoes it on every callback; if it mismatches, callbacks are rejected and no order is ever marked paid. This one is not a value you fetch — it is a value you choose |
| `FLUTTERWAVE_ENCRYPTION_KEY` | not set | Only if you use Flutterwave's encrypted payload format |

Without these the payment methods stay behind their feature flags, which is the
correct failure mode — the platform refuses to take money rather than taking it
wrongly.

**M-Pesa** is modelled in the database (`method='mpesa'`) but has **no provider
integration and no env vars**. It is a schema option, not a working feature. Do
not advertise it until it is built.

---

## 3. Email — staff invitations depend on this

| Variable | Current | Notes |
|---|---|---|
| `EMAIL_HOST` | `smtp.gmail.com` | Your provider |
| `EMAIL_HOST_USER` | `hairplacebnsalon@gmail.com` | A Gmail app password is limited to 500/day — fine for invites, not for notifications |
| `EMAIL_HOST_PASSWORD` | *(set)* | Treat as compromised if it has ever been in a shared channel |
| `DEFAULT_FROM_EMAIL` | same address | Use a domain you control so SPF/DKIM pass |

**This is the one that matters for the work just completed.** A staff invitation
is delivered by email. If SMTP is not configured the invitation row is still
created and the API reports "the email could not be sent" — the operator can
resend, but nothing reaches the invitee.

---

## 4. Moderation models (new in this change)

All optional. Defaults are honest and the service degrades cleanly.

| Variable | Default | What it does |
|---|---|---|
| `COLAB_SAFETY_MODEL_DIR` | `<AI_MODEL_CACHE_DIR>/colab_models/safety_model_nononnx` | Point at a retrained checkpoint without a code change |
| `COLAB_SAFETY_LABEL_MAP` | `LABEL_1=unsafe, LABEL_2=benign` | The checkpoint ships generic `LABEL_N` placeholders, so **this mapping is an assumption, not metadata**. If you retrain with different class ordering, set it here |
| `COLAB_BIAS_MODEL_DIR` | *(unset)* | Leave unset. The `production_bias_model.zip` in the deployed directory is degenerate and is ignored on purpose — see below |
| `MODERATION_EXPLAINER_MODEL` | *(unset)* | e.g. `google/flan-t5-base`. Unset = deterministic explanations, which is fine and always available |

### About the two `.zip` files in `colab_models/`

`production_safety_model.zip` and `production_bias_model.zip` look finished and
are **not usable**:

- the safety zip predicts `LABEL_0` at ~100% for every input, toxic or not;
- the bias zip's scores barely move off 0.5.

Both are ignored by the code. The bias one especially would be worse than
nothing — it manufactures a finding on every post, which is how a moderation
queue stops being trusted. **Set `COLAB_BIAS_MODEL_DIR` only when you have a
bias model that has actually been validated.** Until then the console states
"Bias was not assessed for this flag" rather than implying bias was checked.

---

## 5. Third-party services

| Variable | Current | Needed for |
|---|---|---|
| `OPENAI_API_KEY` | `sk-xxxxx` **(placeholder)** | Primary moderation. With it invalid the chain falls back to ONNX + keywords, so the platform still moderates — just less well |
| `AI_API_KEY` | *(empty)* | The internal AI service's own auth |
| `CLOUDINARY_URL` | **set, and it is a live credential** | All media. Rotate if it has been shared |
| `LIVEKIT_URL` / `LIVEKIT_API_KEY` / `LIVEKIT_API_SECRET` | set | Live sessions. **Rotate — these are in the environment listing** |
| `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` | set | Google sign-in. The redirect URI must be added in the Google console or it fails silently |
| `AGORA_APP_ID` / `AGORA_APP_CERTIFICATE` | set | Voice/video |
| `MUX_TOKEN_ID` / `MUX_TOKEN_SECRET` | set | Video playback |
| `SENDGRID_API_KEY` | `SG.xxxxx` **(placeholder)** | Transactional email. Falls back to SMTP if unset |
| `SENTRY_DSN` | placeholder | Error reporting. Unset means production errors are invisible |
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` | `xxxxx` | Object storage. Unused unless configured |

---

## 6. Public URLs (new in this change)

| Variable | Current | Notes |
|---|---|---|
| `PUBLIC_FRONTEND_URL` | *(empty)* | **Defaults to `https://buddyup.app`** so this is safe to leave empty. Set it if staging on another domain |
| `FRONTEND_BASE_URL` | not set | The staff-invitation accept links use this. Defaults to `PUBLIC_FRONTEND_URL`. If it is ever set to empty, invites send with no link at all |
| `PUBLIC_API_URL` | *(empty)* | Public API origin for served media |
| `VITE_API_BASE_URL` / `VITE_WS_BASE_URL` | dev | Build-time, baked into the frontend bundle |

---

## 7. Mobile build configuration (`buddy_up_flutter/.env`)

`flutter_dotenv` bundles `.env` **verbatim into the APK/AAB**. Every value in it
ships to every user and can be extracted in seconds. That is unavoidable and
also correct for the values that live here — an Agora app id, a Google *client*
id, a LiveKit URL and a Cloudinary cloud name are public identifiers, and a
mobile app cannot hide them. What matters is the rule:

> Never put a secret in `buddy_up_flutter/.env`. No API secret, no private key,
> no service-account JSON with a private key. It is a shipped artifact, not a
> config file.

CI does `cp .env.example .env`, so **the release artifact GitHub builds is
configured entirely from `.env.example`.** That file is currently correct where
it matters most — `API_BASE_URL`, `WS_BASE_URL` and `LIVEKIT_URL` all have
hardcoded production fallbacks in `lib/core/env/env.dart`, so an empty value
degrades to production rather than to localhost. Good.

Five keys have **no fallback and are empty in `.env.example`**, so a CI-built
release currently ships with these features non-functional:

| Key | Consequence when empty |
|---|---|
| `AGORA_APP_ID` | Voice and video calls do not start |
| `GOOGLE_SERVER_CLIENT_ID` | Google sign-in fails on Android (no `google-services.json` in CI) |
| `CLOUDINARY_CLOUD_NAME` | Media uploads fail |
| `FIREBASE_CONFIG` | Push notifications never register |
| `GOOGLE_MAPS_KEY` | Maps render blank |

All five are public client identifiers, so they belong in CI as repository
variables and can be committed to `.env.example` without exposing anything.
This is the single highest-value thing left to fix before a store submission.

Note `FIREBASE_CONFIG` in the local `.env` is redacted placeholder JSON
(`{"apiKey":"...", ...}`) — replace it with the real config, not the literal
ellipses.

---

## 8. Moderation recording & S3 archive

This change makes the platform **moderation-first**: every live is recorded
server-side (LiveKit egress → a durable S3 master) so staff always have
something to review, regardless of host action.

- `LIVE_MODERATION_RECORDING` (default `true`) is the master switch. Set `false`
  only on ephemeral dev stacks where nothing must persist.
- `LIVE_ARCHIVE_BUCKET` / `LIVE_RECORDING_S3_BUCKET` hold the durable master.
  Staff **mint a fresh presigned URL on every request**
  (`GET /api/v1/lives/<id>/recording/`), so a recording never expires for a
  moderator even though the *public* replay URL does (see `LIVE_REPLAY_TTL`).
- `LIVE_ARCHIVE_TTL` is the staff-link lifetime (default 1 day; 7 days in
  production via env).
- Public replays are published only for `recording_consent == 'auto_record'`
  lives whose host opted in at end-of-stream. Opt-out lives are still archived
  for staff review, just not published.
- Mux HLS is **best-effort / non-blocking**: a Mux failure is recorded on
  `mux_status` / `mux_processing_error` but the master MP4 stays live as the
  fallback. `finalize_mux_status` upgrades the public `replay_url` to HLS
  asynchronously once Mux reports `ready`.

| Variable | Default | Notes |
|---|---|---|
| `LIVEKIT_*` | — | Egress requires a LiveKit `EGRESS` role + valid API key/secret |
| `MUX_TOKEN_ID` / `MUX_TOKEN_SECRET` | empty | Required only for HLS distribution; empty = MP4-only fallback |
| `LIVE_ARCHIVE_BUCKET` | `LIVE_RECORDING_S3_BUCKET` | A dedicated long-retention bucket is recommended |
| `LIVE_ARCHIVE_TTL` | `86400` (1 day) | Staff-presigned URL lifetime |
| `LIVE_REPLAY_TTL` | `604800` (7 days) | Public replay URL lifetime before Mux upgrades it |
| `LIVE_MODERATION_RECORDING` | `true` | Master switch for server-side recording |

Staff endpoints (admin JWT only):

- `GET /api/v1/lives/<id>/recording/` — statuses + a **fresh** `archive_url`.
- `GET /api/v1/lives/<id>/recording/download/` — `302` redirect to a fresh presigned URL.
- `GET /api/v1/lives/<id>/` (credentials) — now also returns `recording_status`,
  `mux_status` and `mux_playback_id` so the client can render the right player.

---

## 9. Before you publish — the non-environment checklist

These are not env vars and no amount of configuration substitutes for them.

1. **Android release signing — the only thing left before a store upload.**
   `flutter build apk --release` and `flutter build appbundle --release` both
   build and verify, but with no `android/key.properties` the Gradle config
   falls back to the **debug keystore** (`CN=Android Debug`, verified with
   apksigner). Google Play rejects that. Create a keystore, write
   `android/key.properties` with `storeFile` / `storePassword` / `keyAlias` /
   `keyPassword`, and **do not commit it** — add it to `.gitignore` if it is not
   already there. `keystore.properties` is already gated behind a
   `hasSigningConfig()` check, so no code change is needed.
2. **iOS signing — cannot be checked from Linux at all.** The project is
   configured to build without a team so CI passes, but there is no Xcode here,
   so nothing about a real archive has been verified. On a Mac you still need
   `DEVELOPMENT_TEAM` and a provisioning profile in
   `ios/Runner.xcodeproj/project.pbxproj` (or set in Xcode). Treat the iOS
   release path as unverified until someone runs it on macOS.
3. **The two-person approval queue.** Now workable — four administrator accounts
   exist. Verify two *different* people can actually raise and approve, because
   with a single person holding all four accounts the rule is satisfied only on
   paper.
4. **Rotate the credentials in this list that are already populated** if this
   environment has ever been shared or logged.