# Client Parity Matrix

| Owner | Review date | Evidence rule |
|---|---|---|
| Peter Mbugua (CEO / Engineering) | 2026-09-30 | Route source plus client test or explicit exception |

This is the checked-in release checklist for the React web client and Flutter
client. “Shared API” means both clients use the same versioned Django route;
it does not imply identical screens or platform-specific capabilities.

| Domain | Representative backend routes | Web evidence | Flutter evidence | Contract status | Notes |
|---|---|---|---|---|
| Authentication and onboarding | `/auth/login/`, `/auth/token/refresh/`, `/profiles/onboarding/` | `frontend/src/api/auth.ts` | `lib/data/repositories/auth_repository.dart` | Fixture-checked routes | JWT refresh and age gating are client-owned flows |
| Profiles and Buds | `/profiles/me/`, `/profiles/<username>/` | `frontend/src/api/profiles.ts` | `lib/data/repositories/profile_repository.dart` | Fixture-checked prefix | |
| Feed and reactions | `/feed/`, `/feed/create/` | `frontend/src/api/feed.ts` | `lib/data/repositories/feed_repository.dart` | Fixture-checked prefix | |
| Gyms and communities | `/gyms/`, `/messaging/communities/` | `frontend/src/api/gyms.ts`, `messaging.ts` | `lib/data/repositories/gym_repository.dart`, `lib/features/community/providers/community_provider.dart` | Partial: separate backend domains | |
| Live sessions | `/lives/browse/`, `/lives/start/` | `frontend/src/api/lives.ts` | `lib/data/repositories/live_repository.dart` | Fixture-checked prefix | LiveKit is the production transport |
| Bookings | `/sessions/` | `frontend/src/api/sessions.ts` | `lib/data/repositories/session_repository.dart` | Fixture-checked prefix | |
| Messaging | `/messaging/conversations/` | `frontend/src/api/messaging.ts` | `lib/data/repositories/messaging_repository.dart` | REST fixture-checked | WebSocket clients are separate implementations |
| Marketplace | `/marketplace/` | `frontend/src/api/marketplace.ts` | `lib/data/repositories/marketplace_repository.dart` | Fixture-checked prefix | |
| Wallet | `/wallet/balance/`, `/wallet/transactions/` | `frontend/src/api/wallet.ts` | `lib/data/repositories/wallet_repository.dart` | Fixture-checked routes | |
| Notifications | `/notifications/`, `/notifications/preferences/` | `frontend/src/api/notifications.ts` | `lib/data/repositories/notification_repository.dart` | Fixture-checked prefix | Push delivery is platform-specific |
| Moderation and verification | `/moderation/`, `/verification/` | `frontend/src/api/moderation.ts`, `verification.ts` | `lib/data/repositories/verification_repository.dart` | Partial: Flutter moderation coverage must be recorded before launch | |
| Analytics and achievements | `/analytics/`, `/achievements/` | `frontend/src/api/analytics.ts`, `achievements.ts` | `lib/data/repositories/analytics_repository.dart` | Fixture-checked prefixes | |
| Admin and operations | `/admin/`, `/health/` | Staff/API only | Not shipped | Operator-only, out of client parity scope | Health is a flat readiness exception |

## Updating The Matrix

When adding or changing an API route:

1. Update both client repository modules or explicitly mark the cell partial.
2. Update this table and add a focused client test where behavior differs.
3. Run `scripts/check_openapi.sh`, `python scripts/check_api_contract.py`, backend tests, and both client checks.

“Implemented” is not a substitute for evidence. If a client has no repository
for a route, mark the row `Partial` and name the missing follow-up. Do not
create a generated client unless code generation is deliberately configured.
