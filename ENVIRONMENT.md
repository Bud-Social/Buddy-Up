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

## 7. Before you publish — the non-environment checklist

These are not env vars and no amount of configuration substitutes for them.

1. **iOS signing.** The build was fixed to not require a team, so CI passes, but
   an actual App Store build needs `DEVELOPMENT_TEAM` and a provisioning
   profile in `ios/Runner.xcodeproj/project.pbxproj` (or set in Xcode).
2. **Android release signing.** `flutter build apk --release` uses the debug
   keystore unless you provide a release key. A Play Store upload needs a real
   one, and `android/key.properties` must not be committed.
3. **The two-person approval queue.** Now workable — four administrator accounts
   exist. Verify two *different* people can actually raise and approve, because
   with a single person holding all four accounts the rule is satisfied only on
   paper.
4. **Rotate the credentials in this list that are already populated** if this
   environment has ever been shared or logged.