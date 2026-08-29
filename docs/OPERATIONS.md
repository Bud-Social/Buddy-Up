# BuddyUp Operations Runbook

| Owner | Review date | Status |
|---|---|---|
| Peter Mbugua (CEO / Engineering) | 2026-09-30 | Maintained |

## Deployment topology (canonical)

Production runs on **Railway with one Docker container per service**, built from
the same images used locally:

| Railway service | Image / build | Command |
|---|---|---|
| `buddyup-api` | `backend/Dockerfile` (production target) | `daphne -b 0.0.0.0 -p $PORT config.asgi:application` |
| `buddyup-worker` | same backend image | `celery -A config.celery worker -Q default,high_priority,media,ai` |
| `buddyup-beat` | same backend image | `celery -A config.celery beat` |
| `buddyup-web` | `frontend/Dockerfile` (production target, VITE_* build args) | serves the SPA via its bundled nginx |
| `buddyup-ai` | `backend/ai_service/Dockerfile` | `uvicorn app.main:app --workers 1` (scale workers only with a memory budget) |

Managed companions: Railway PostgreSQL, Railway Redis, Cloudinary (or S3) for
media, LiveKit (cloud or separately managed), Sentry. Migrations run in the API
pre-deploy step (`railway.json`), never inside worker/beat startup.

`docker-compose.prod.yml` is the **staging/local reference** for this same
topology — it is not deployed as a single unit to production. Keep it bootable
(`docker compose -f docker-compose.prod.yml config`) and in sync with the
Railway variable set.

## Launch gate

Production traffic is allowed only when all checks pass:

1. `python manage.py validate_deploy`
2. `python manage.py migrate --noinput`
3. `python manage.py schema_status --strict`
4. `/api/v1/health/` returns HTTP 200 with database/cache/migrations `ok=true`
5. `scripts/smoke_production.sh` passes public and authenticated probes
6. `python manage.py reconcile_wallet --fail-on-mismatch` reports zero mismatches/errors
7. CI backend/frontend/android jobs are green

Railway runs the first three commands in both `preDeploy` and `startCommand`
so dashboard command overrides cannot silently skip migrations.

## Post-deploy smoke

```bash
BASE_URL=https://buddy-up-production.up.railway.app/api/v1 \
SMOKE_ACCESS_TOKEN='<short-lived test-user token>' \
./scripts/smoke_production.sh
```

The token should belong to a non-staff smoke-test account containing no real
personal or financial data. Keep it in the CI/deploy secret store only.

## Request tracing

Every HTTP response includes `X-Request-ID`; API errors include `request_id`.
Ask users/support for this ID, then search Railway or Sentry logs for:

```text
request_id=<value>
```

Never log OTPs, JWTs, passkeys, ID/selfie contents, bank accounts or full card data.

The readiness response includes `release` and `commit` markers from
`RELEASE_VERSION` and `RELEASE_COMMIT` (Railway's commit SHA is used only as a
fallback). Production requires a high-entropy `METRICS_TOKEN` to protect
`/api/v1/health/metrics/` and scrape it with `X-Metrics-Token: ...`.
Metrics are low-cardinality counters local to each application worker; use
the platform's aggregation for fleet totals. If the token is unset, the
endpoint is intentionally available without a token for local development only.

## Health and alerts

- Railway health: `/api/v1/health/`
- Alert immediately on health 503, schema drift, Redis/cache failure, or DB failure.
- Track API 5xx rate and p95 latency by path using the request logs.
- Track `buddyup_http_requests_total`, `buddyup_http_errors_total`, and
  `buddyup_http_duration_ms_total` from the metrics endpoint.
- Track Celery queue age for `high_priority`, `media` and `ai`.
- Track LiveKit join failure, TURN relay use, replay/egress failure and peak rooms.

## Wallet and payouts

Creator amount-only payouts are disabled until double-entry settlement is
complete. `/wallet/withdraw/` supports verified bank transfers only:

- artifact deduction + pending ledger creation is atomic;
- provider initiation stays `pending`;
- only signed provider webhooks/reconciliation mark `completed`;
- failed/cancelled/reversed provider states refund artifacts exactly once;
- `tx_ref` is unique when nonblank.

Daily:

```bash
python manage.py reconcile_wallet --fail-on-mismatch
```

Any mismatch is a finance incident. Do not repair it by directly editing JSON
balances; use a reviewed reversal operation with a ledger row.

## Verification evidence

- Document access is restricted to the subject and staff via existing viewset scope.
- Detail retrieval is audited with actor, purpose, request ID and IP.
- ID/selfie files receive a purge deadline (90 days by default; 30 days after review).
- The scheduled purge task deletes files while retaining minimal metadata/audit history.
- Face match remains assistive: low/unknown confidence routes to manual review.

## Moderation SLA and appeals

- Critical report categories: target review within 4 hours.
- Other reports: target review within 24 hours.
- API payloads expose `sla_due_at` and `sla_breached`.
- Affected users may appeal moderation actions once.
- Staff review decisions create immutable `ModerationAction` audit rows.
- Approved suspension/ban appeals reactivate the account; content restoration
  requiring manual evidence stays an explicit operator action.

## Rollback

1. Roll back application code only; do not blindly reverse data migrations.
2. Confirm the older code can read the newer schema.
3. Keep payment and write endpoints in maintenance mode during rollback.
4. Re-run health, schema status, wallet reconciliation and smoke probes.
5. Record the incident timeline and request IDs in a postmortem.

## Service launch status

### Launch core

- authentication/onboarding/verification
- profiles/Buds/communities
- planned activities and basic tracking
- gym/coach onboarding
- notifications

### Controlled beta

- marketplace products, meal plans and programmes
- LiveKit live video and recordings
- creator tools
- AI food recognition

### Held

- creator cash payouts (disabled)
- paid/cash-like artifact expansion
- clinical-sounding AI health advice
- broad supplement marketplace without PPB evidence workflow
