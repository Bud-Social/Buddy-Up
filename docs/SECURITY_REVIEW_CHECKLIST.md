# BuddyUp — Security Review Checklist (for Charles Githinji & Team)

| Owner | Review date | Status |
|---|---|---|
| Charles Githinji (Head of Security) + Security Team | 2026-09-19 | Active — companion to `docs/ARCHITECTURE_AND_SECURITY_REVIEW.md` |

> Use this as the day-to-day working checklist. The full write-up explains the *why* and *how*; this file is the *what to check*. Tick boxes in PR reviews, pre-prod gates, and pen-tests.

## 0. Pre-prod Gate (must be green or risk-accepted in writing)

- [ ] `python manage.py validate_deploy` passes (SECRET_KEY≥32, DATABASE/REDIS/METRICS set, CORS/CSRF/WEBAUTHN sane, webhook hash present)
- [ ] `python manage.py migrate --noinput` + `schema_status --strict` clean
- [ ] `GET /api/v1/health/` 200 `{database,cache,migrations ok=true}`
- [ ] `scripts/smoke_production.sh` passes (public + authed probes, non-staff token, no real PII/funds)
- [ ] `python manage.py reconcile_wallet --fail-on-mismatch` zero mismatches/errors
- [ ] CI backend/frontend/android green
- [ ] P0 findings (§11 in main doc: F-01–F-08 + F-15) closed or formally risk-accepted with monitoring

## 1. Identity & Sessions

- [ ] Refresh rotation + blacklist + DeviceSession revocation tested (concurrent reuse, revoked refresh, deleted-user refresh)
- [ ] OTPs hashed, constant-time compare, no OTP in logs, 3-strikes + 60s resend verified
- [ ] `dob_hash` HMAC-peppered (not plain SHA-256); VerifyAge returns booleans only
- [ ] Short default session (not 30d) unless remember-me; JWTs out of localStorage (HttpOnly refresh + memory access)
- [ ] Password-reset does not disable 2FA on email alone (step-up or delayed recovery + alert)
- [ ] Google `aud`+skew, Apple fail-closed (`RS256/aud/iss`), key cache verified
- [ ] WebAuthn RP ID/origin pinned per env, challenges single-use 300s, sign-count tracked, step-up for revoke
- [ ] Throttles load-tested (`registration 10/h`, `login 30/h`, `otp 10/h`, `password_reset 3/h`, `webauthn 10/h`); proxy IP gating via TRUSTED_PROXY_IPS (fix verification XFF trust)
- [ ] Admin APIs pen-tested with non-staff tokens (frontend AdminGuard is cosmetic)

## 2. Verification & Age Gating

- [ ] Uploads: 10MB, ext whitelist, UUID paths, never public URLs, both steps required, IsAdminUser review only
- [ ] Face-match never auto-rejects (→ manual review); threshold 80.0 verified; backlog SLA defined
- [ ] Every doc read audited (actor/purpose/request_id/IP); 300s presigned/grant; purge 90d / 30d post-review verified (file blanked)
- [ ] Mature gate defaults 18+; 16–17 guardian flow tested; onboarding `?step=age` enforced server-side

## 3. Payments & Wallet

- [ ] Webhook: fail-closed on missing hash, compare_digest, amount/currency/ref match, pending-gate, replay = no-op, DoesNotExist = silent ok
- [ ] Body HMAC + timestamp window + nonce log added (or scheduled); 403-spike alerting
- [ ] All money POSTs idempotent (Idempotency-Key / tx_ref UUID); double-click/retry storm tested; tip ref collision fixed; direct-buy mp_* replay fixed
- [ ] Fee math correct (no 100% micro-tip cut); receipts show fee breakdown
- [ ] Marketplace disputes post compensating ledger reversals (no delete); dual-approval above threshold; refund SLA published
- [ ] Session escrow: escrow→platform directly (fix refund-then-charge oddity); cancel tiers (>24h 100%, <24h 50/50, trainer-cancel 100%) tested
- [ ] Withdrawals: KYC gate, $10 min, bank pre-validation before debit, bank_transfer only, exactly-once refund, M-Pesa path stays pending without provider
- [ ] Velocity caps + step-up auth above threshold; KES_PER_USD refresh job live; FX alerts
- [ ] Raw card fields never wired/logged (`card_details` removed or staff-only); PCI reassessment if touched
- [ ] `reconcile_wallet` weekly in staging; no direct JSON balance edits (reversal rows only); `tx_ref` unique enforced
- [ ] `.env` never committed (gitleaks + push protection + `git log -p` audit)

## 4. Privacy & Data

- [ ] At-rest encryption decision recorded (KMS envelope for email/phone/guardian/verification meta) or risk-accepted; backups encrypted + restore tested
- [ ] Export: short-lived authed single-use link, logged, rate-limited, no tokens in payload, repeat-export alerting
- [ ] Deletion matrix complete (rows × media × verification × exports × backups × logs × embeddings) + Cloudinary/MinIO deletes verified (close Moments TODO) + backup window in policy
- [ ] Health boundary enforced (safety_notice, practitioner-only exemption, held supplements/ اله clinical AI); Kenya DPIA + processor register + retention schedule filed
- [ ] GPS routes: explicit consent, auto-expiry, no precise GPS in logs/events, coarse Nearby
- [ ] Logs: `grep -r otp|Bearer|passkey|FLWSECK|whsec_|atsk_` = 0; Sentry PII off; request_id sanitised

## 5. Moderation & Safety

- [ ] Pre- vs post-publish map documented; flagged media blurred + unguessable URLs until reviewed
- [ ] Practitioner exemption tested (non-practitioner medical claims flag; red-flag phrases always flag)
- [ ] Under-16-in-content path implemented or scheduled with takedown SLA
- [ ] Live/DM/group scan decision recorded (server-scan with notice vs report-only + fast SLA); PhotoDNA-equivalent wired or scheduled
- [ ] ModerationAction immutable; appeal-once enforced; sla_breached alerting (not just display)
- [ ] AI-down behaviour defined (fail-closed NSFW); brigading (3-reports/15min) tested for false-flags

## 6. Messaging & Media

- [ ] E2E claim removed from business/pitch docs OR real E2E scoped; policy + in-app copy says server-readable + report-decryption
- [ ] New-buddy rate limits, mention-spam, broadcast-only bypass tested
- [ ] Link preview fuzzed (private-IP, redirect-chain, DNS-rebind, file://); timeouts + size caps + no creds forwarded
- [ ] Upload polyglots rejected (magic-byte before storage, nosniff, safe disposition)
- [ ] LiveKit tokens short-TTL, room-bound, least-privilege role; join-fee checked server-side before mint
- [ ] SDP cannot inject ICE servers (TURN allowlist); TURN creds ephemeral
- [ ] Presence/online toggle honoured everywhere (no leak via WS or `Active now`)

## 7. Infra & Edge

- [ ] TLS 1.2+ only, strong ciphers, wildcard/dual-name cert auto-renewed, key 0600 ro-mounted, HSTS+CSP+nosniff verified (`curl -vI`, `testssl.sh`)
- [ ] Admin allowlist closed (office/VPN CIDRs + deny-all + MFA); no exposure via preview URLs
- [ ] Edge + DRF rate limits compose under NAT; login/OTP/purchase load-tested
- [ ] Secrets rotated (no defaults); METRICS_TOKEN high-entropy; webhook/LiveKit/MinIO unique per env
- [ ] CORS credentials false; Origin fuzzed (null/subdomain/preview hijack); CSRF env sanitiser verified
- [ ] Metrics 404-masquerade (no oracle); cardinality bounded; health release/commit disclosure accepted
- [ ] Redis authed, internal-only, eviction-safe for Channels/OTP; Postgres internal-only, backed up
- [ ] Firewall: 80/443/tcp, 7881/tcp, 3478/udp, 5349/tcp, 50000–50100/udp only; egress → private bucket via /replays/ proxy
- [ ] Deploy dual-gate (preDeploy + startCommand) tested — dashboard overrides cannot skip migrations
- [ ] PWA: authed API not served stale cross-user (`Vary: Authorization`, short TTL)

## 8. Evidence to Collect per Review

- [ ] X-Request-IDs for every finding
- [ ] `validate_deploy` + `schema_status` + `/health/` + smoke + `reconcile_wallet` outputs
- [ ] Webhook 403 rate, OTP 429 rate, `sla_breached` count, 5xx/p95 by path, Celery queue age, LiveKit join/TURN/replay failures
- [ ] `VerificationDocumentAccess`, `ModerationAction`, `JournalEntry/Line`, `ArtifactTransaction`, `AccountEvent` samples

---
*Questions to Engineering with request IDs; map findings to main-doc §11 IDs (F-01–F-20).*
