# Plan — Confirm Every Service Is Complete & Well Secured

Approved decisions: **comprehensive** /cso depth · **fix + verify** mode · **fix** the 4 pre-existing backend test failures.

## Services in scope

| Service | Stack | Size |
|---|---|---|
| Django API | 21 apps (`backend/apps/`), Channels WS, Celery | 1520 tests |
| AI service | FastAPI (`backend/ai_service/`) | own suite |
| Web client | React/Vite (`frontend/`) | ~95 routes, 807 tests |
| Flutter client | `buddy_up_flutter/` | 20 admin screens, 526 tests |

## Recon findings (already verified this session)

- **Prod posture good**: DEBUG off/HSTS preload/secure cookies/CORS allowlist/scoped throttles (`config/settings/production.py`).
- **Flutterwave webhook fail-closed + idempotent** (`apps/wallet/views.py:454-546`).
- **All 5 WS consumers authenticate** (JWT via `Sec-WebSocket-Protocol`, object-level checks, rate-limited) (`apps/messaging/consumers.py`).
- **No `.raw()` SQL**; LiveKit mint is always caller's own identity (`apps/lives/views.py`).
- **Web/Flutter token hygiene correct** (memory + httpOnly refresh cookie / secure storage); zero TODO stubs.
- **On-disk `.env` files hold live-looking secrets** (root `.env`: Cloudinary creds, Agora cert, Google client secret, Gmail app password; `frontend/.env`: Agora/LiveKit IDs, secret-shaped Cloudinary name). Git-ignored — scan history for ever-committed copies, classify for rotation.

### Confirmed gaps (fix targets)

1. **`FoodRecognizeView`** (`apps/marketplace/views.py:2729-2754`): `content_type` check only — no magic bytes, no size cap, raw forward to AI service.
2. **`ai_service` fails open** without `AI_API_KEY`, even in prod (`backend/ai_service/app/main.py:36-43`); CORS `allow_headers=['*']` worth reviewing (`main.py:29`).
3. **4 failing backend tests** (baseline re-confirmed: `1516 passed, 8 skipped, 4 failed`):
   - `apps/sessions/tests.py::TrainerDiscoveryFilterTests` ×3 — `session_types` is a `JSONField` (`apps/sessions/models.py:13`); `__contains` lookup unsupported on SQLite (test DB), fine on Postgres. Error: `NotSupportedError` at `apps/sessions/views.py:84`.
   - `apps/messaging/tests.py::LiveConsumerRelayTests::test_gift_events_are_rate_limited` — `_settle_gift` runs via `database_sync_to_async` on a second thread-connection; SQLite write lock held by TestCase transaction → `database table is locked: profiles_profile`. Sibling `LiveConsumerCohostAuthorizationTests`/`LiveGiftSettlementTests` already use `TransactionTestCase` for exactly this reason.

## Phase 1 — Completeness gauntlet

- [x] Backend full pytest — **1516 pass / 4 fail** (root causes above diagnosed)
- [ ] `ruff check backend`
- [ ] `makemigrations --check`
- [ ] ai_service suite (`backend/ai_service/tests`)
- [ ] Web: `tsc -b`, `eslint`, full `vitest` (was 807/807 after the Sessions rename)
- [ ] Flutter: `analyze` + `test` (was clean / 526)

## Phase 2 — /cso comprehensive audit

- Secrets archaeology: full-history scan for ever-committed keys; classification + rotation list for on-disk `.env` values.
- Dependency supply chain: `pip-audit` (backend + ai_service requirements), `npm audit` (frontend).
- OWASP spot-checks: the 35 `AllowAny` public views (IDOR/object-level), moderation/verification admin surfaces, guardian spend-blocks, analytics exports.
- Re-verify payments/LiveKit/WS fail-closed paths (largely confirmed; document as pass with refs).

## Phase 3 — Fixes (atomic, verify each)

### 3a. Pre-existing test failures

**Sessions (`apps/sessions/views.py::TrainerListView.get`)** — vendor-aware filtering; SQL path unchanged on Postgres, Python predicate on SQLite:

```python
from django.db import connection, models as db_models, transaction  # add `connection`

# JSONField `contains` lookups exist only on PostgreSQL/MySQL; the
# SQLite test database must fall back to in-Python filtering.
json_contains = connection.vendor in ('postgresql', 'mysql')
offers_remote = offers_mobile = None   # closures set below when needs be
if virtual_only:
    remote_types = ['1on1_live', 'group_live', 'async', 'nutrition']
    virtual_sql = db_models.Q(is_virtual=True)
    for remote_type in remote_types:
        virtual_sql |= db_models.Q(session_types__contains=[remote_type])
    if json_contains:
        qs = qs.filter(virtual_sql)
    else:
        offers_remote = lambda t: t.is_virtual or any(vt in (t.session_types or []) for vt in remote_types)
if mobile_only:
    mobile_sql = db_models.Q(is_mobile=True) | db_models.Q(session_types__contains=['in_person'])
    if json_contains:
        qs = qs.filter(mobile_sql)
    else:
        offers_mobile = lambda t: t.is_mobile or 'in_person' in (t.session_types or [])
# ... gym_handle block unchanged ...
qs = qs.order_by('-average_rating', '-review_count')
if offers_remote:
    qs = [t for t in qs if offers_remote(t)]
if offers_mobile:
    qs = [t for t in qs if offers_mobile(t)]
if specialty:
    qs = [t for t in qs if specialty in (t.specialties or [])]
```

**Messaging (`apps/messaging/tests.py`)** — move `test_gift_events_are_rate_limited` out of `LiveConsumerRelayTests` into a new `class LiveConsumerGiftRateLimitTests(TransactionTestCase)` (the gift path DOES touch the DB via `_settle_gift`; the cohost and settlement classes already use `TransactionTestCase`). The relay's other 4 tests stay `TestCase` (no DB access).

### 3b. FoodRecognizeView hardening

Reuse the existing `common.utils.validate_file_signature` + size cap (mirroring `messaging/views.py:542-624`): reject >5MB images, verify magic bytes for the image types, keep `IsAuthenticated` + existing throttle. Add tests: bad magic bytes → 400, oversized → 400.

### 3c. ai_service fail-closed + CORS

- `require_api_key`: when `AI_API_KEY` unset AND an env/`--prod` flag marks production → refuse startup (fail closed) instead of silently open. Local dev stays open.
- Confirm/tighten CORS in `app/main.py` (explicit frontend origin only).
- Add/extend tests for 401 on missing key when key configured.

### 3d. Dependency audit findings

Fix/add pins for anything confirmed-exploitable by pip-audit/npm-audit at the comprehensive bar; document anything that needs a major bump instead.

### 3e. Untracked tooling scan

Scan `tools/` + `backend/ai_service/training/*.py` for embedded credentials or real user data before they're ever staged (they stay uncommitted unless clean + you say so).

## Phase 4 — Verdict report

Per-service scorecard (backend, ai_service, web, Flutter): tests, lint/type, security posture highlights and fixed gaps, ship-readiness summary. Final suites re-run green.

## Execution notes

- Never commit: `backend/ai_service/training/*` + `tools/` (per standing rule) unless Phase 3e clears them and you approve.
- Known warnings to note in report (not blockers): 29-byte HMAC test keys (InsecureKeyLengthWarning — test-only), Django 6.0 deprecations in marketplace models.
