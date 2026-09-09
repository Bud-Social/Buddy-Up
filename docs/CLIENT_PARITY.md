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
| Bud Press creation studio | `/uploads/sign/`, `/sounds/`, `/feed/create/` (structured `media` JSON) | `frontend/src/pages/app/CreateStudio.tsx`, `frontend/src/lib/uploader.ts`, `frontend/src/lib/createStudio.ts` | `lib/features/feed/screens/video_studio_screen.dart`, `lib/core/upload/cloudinary_uploader.dart` | Fixture-checked prefix | TikTok flow: local copy on pick → edit offline → finalize → upload with percentage → publish. Web uses IndexedDB drafts; Flutter persists media paths locally. Both clients have trim/sound/audience steps and photo-mode carousels; auto-captions generate server-side (faster-whisper) post-publish |
| Behavioral event tracking | `/analytics/events/` | `frontend/src/lib/analytics.ts` | `lib/core/analytics/analytics_service.dart` | Fixture-checked prefix | Consent-gated batched events on both clients |
| Settings (routed sub-pages) | `/profiles/me/`, `/notifications/preferences/`, `/auth/sessions/`, `/auth/delete/`, `/auth/export-data/` | `frontend/src/pages/settings/` (hub + `/settings/:section` routes), `frontend/src/api/` clients | `lib/features/settings/screens/` | Full: both clients ship the same section set | Web sections live at `/settings/<id>` (account, verifications, privacy, notifications, security, blocked, activity, content, billing, appearance, family, help, data); invalid ids redirect to the hub. Login reactivation prompt is on both clients |
| Family / guardians | `/guardians/invite/`, `/guardians/links/`, `/guardians/dashboard/`, `/guardians/accept-invite/` | `frontend/src/api/guardians.ts`, `frontend/src/pages/settings/Family.tsx`, `FamilyAccept.tsx` | `lib/data/repositories/guardian_repository.dart`, `lib/features/settings/screens/family_screen.dart` | Full: web and Flutter | Both roles covered (guardian invite/dashboard/permissions/unlink; teen pending invites). Web public accept page at `/settings/family/accept?token=`. Note: Flutter repository paths still say `/auth/guardians/` — backend mounts at `/api/v1/guardians/` |
| Passkeys and recovery codes | `/auth/passkeys/`, `/auth/passkeys/<id>/rename/`, `/auth/passkeys/<id>/revoke/`, `/auth/recovery-codes/regenerate/` | `frontend/src/components/settings/SecurityExtras.tsx`, `frontend/src/pages/settings/Security.tsx` | Not shipped | Web-only | Flutter records no passkey UI yet; platform authenticators behind WebView are a follow-up |
| Device identity | `X-Device-Id` header on all API calls | `frontend/src/lib/device.ts`, `frontend/src/api/client.ts` | `lib/core/device/` | Full: both clients | Backends mark the current session via this header |
| Admin and operations | `/admin/`, `/health/` | Staff/API only | Not shipped | Operator-only, out of client parity scope | Health is a flat readiness exception |

## Updating The Matrix

When adding or changing an API route:

1. Update both client repository modules or explicitly mark the cell partial.
2. Update this table and add a focused client test where behavior differs.
3. Run `scripts/check_openapi.sh`, `python scripts/check_api_contract.py`, backend tests, and both client checks.

“Implemented” is not a substitute for evidence. If a client has no repository
for a route, mark the row `Partial` and name the missing follow-up. Do not
create a generated client unless code generation is deliberately configured.
