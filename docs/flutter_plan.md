# Flutter Conversion Plan — Buddy-Up

## Overview

- **Existing web frontend:** ~22K lines TypeScript/TSX, 142 files, 50 pages, 36 components, 10 hooks, 7 Zustand stores, 12 API modules, 14 WebSocket event types.
- **Backend (unchanged):** Django REST Framework + Channels at `/api/v1/`, OpenAPI schema at `/api/schema/`, JWT auth (access 7d, refresh 30d), WebSocket at `ws/.../?token=`.
- **Target:** Full native Android + iOS app built with Flutter, sharing 0% UI code but reusing the backend identically.

---

## 1. Architecture & Key Packages

| Concern | Package | Rationale |
|---|---|---|
| State management | **Riverpod** (v2) | Less boilerplate than BLoC, compile-safe, testable, no BuildContext dependency |
| Networking | **Dio** + **Retrofit** | Typed API clients from annotations; interceptors for JWT refresh (matching existing Axios pattern) |
| Models | **Freezed** + **JsonSerializable** | Immutable data classes, discriminated unions for `ChatEvent`, JSON codegen |
| Navigation | **go_router** | Declarative, deep linking, redirect guards (replaces `AuthGuard` in `router.tsx`) |
| Local storage | **flutter_secure_storage** (tokens) + **Isar** (offline cache) | Secure token persistence; fast NoSQL for offline conversations, feed cache |
| WebSocket | **web_socket_channel** + custom manager | Reconnect with exponential backoff, multi-handler (same as `wsManager.ts`) |
| Maps | **google_maps_flutter** + **flutter_map** (fallback) | Google Maps key already exists in env; OSM fallback for location messages |
| Video/calls | **agora_rtc_engine** + **livekit_client** | Existing Agora + LiveKit credentials from backend |
| Code generation | **build_runner** | Generates JSON serialization, Retrofit clients, Freezed unions |
| Image picking | **image_picker** | Camera + gallery for posts, avatars, covers |

---

## 2. Project Structure

```
buddy_up_flutter/
├── lib/
│   ├── main.dart
│   ├── app.dart                         # MaterialApp.router + theme + providers
│   ├── router.dart                      # GoRouter config (mirrors router.tsx)
│   ├── core/
│   │   ├── api/
│   │   │   ├── api_client.dart           # Dio instance + JWT interceptor
│   │   │   ├── api_response.dart         # ApiResponse<T> + Pagination models
│   │   │   └── ws_manager.dart           # WebSocket singleton + reconnect
│   │   ├── auth/
│   │   │   └── auth_provider.dart        # Riverpod AuthNotifier (mirrors authStore)
│   │   ├── theme/
│   │   │   └── app_theme.dart            # Mirrors Tailwind dark palette
│   │   └── utils/
│   │       ├── date_format.dart
│   │       ├── validators.dart
│   │       └── constants.dart
│   ├── data/
│   │   ├── models/                       # Freezed models (mirrors src/types/)
│   │   │   ├── user.dart
│   │   │   ├── profile.dart
│   │   │   ├── post.dart
│   │   │   ├── gym.dart
│   │   │   ├── live.dart
│   │   │   ├── conversation.dart
│   │   │   ├── message.dart
│   │   │   ├── wallet.dart
│   │   │   ├── marketplace.dart
│   │   │   ├── session.dart
│   │   │   ├── notification.dart
│   │   │   ├── verification.dart
│   │   │   └── api_response.dart
│   │   └── repositories/                # Retrofit service interfaces
│   │       ├── auth_repository.dart
│   │       ├── profile_repository.dart
│   │       ├── feed_repository.dart
│   │       ├── gym_repository.dart
│   │       ├── live_repository.dart
│   │       ├── messaging_repository.dart
│   │       ├── marketplace_repository.dart
│   │       ├── wallet_repository.dart
│   │       ├── session_repository.dart
│   │       ├── notification_repository.dart
│   │       └── verification_repository.dart
│   ├── features/
│   │   ├── auth/                         # Phase 1
│   │   ├── profile/                      # Phase 1
│   │   ├── feed/                         # Phase 2
│   │   ├── discover/                     # Phase 2
│   │   ├── gym/                          # Phase 3
│   │   ├── live/                         # Phase 3
│   │   ├── messages/                     # Phase 4
│   │   ├── marketplace/                  # Phase 5
│   │   ├── wallet/                       # Phase 5
│   │   ├── sessions/                     # Phase 6
│   │   ├── notifications/                # Phase 6
│   │   └── settings/                     # Phase 6
│   └── shared/
│       └── widgets/                      # Reusable widgets
│           ├── avatar.dart
│           ├── button.dart
│           ├── input.dart
│           ├── badge.dart
│           ├── page_loader.dart
│           ├── error_view.dart
│           ├── empty_state.dart
│           └── toast.dart
├── test/
│   ├── core/
│   ├── data/
│   └── features/
├── pubspec.yaml
├── build.yaml                            # build_runner config
├── analysis_options.yaml
└── .env.example
```

---

## 3. Phased Build Plan

### Phase 0 — Foundation (2 weeks)
- Scaffold Flutter project, configure linting
- Set up `Dio` + JWT interceptor (refresh on 401, queue concurrent requests — same pattern as existing `client.ts`)
- Implement `ws_manager` (singleton, exponential backoff 1s→30s, multi-handler, disconnectAll on logout)
- Build `ApiResponse<T>` + `Pagination` models
- `go_router` with auth redirect guard (mirrors `router.tsx`)
- Riverpod providers + `build_runner`
- All Freezed models (~93 classes, bootstrapped from OpenAPI schema at `/api/schema/`)
- `flutter_secure_storage` for tokens + Isar setup for offline cache
- App theme (dark mode only, mirroring Tailwind palette: `buddy-black`, `buddy-green`, `buddy-surface`, `buddy-text-primary`, etc.)
- `.env` configuration

**Milestone:** App boots, navigates to login, authenticates, stores tokens, redirects to empty shell.

### Phase 1 — Auth & Profile (2 weeks)
- **Screens:** Login, Register, OTP Verify, TOTP Setup/Challenge, Forgot/Reset Password, Verify Age, Onboarding
- **Widgets:** `Avatar`, `Button`, `Input`, `Badge`, `PageLoader`, `Toast`
- Profile view + edit (mirror `Profile.tsx`, `EditProfile.tsx`, `UserProfile.tsx`)
- Buddy system (send/accept/decline request, buddy list, followers, following)
- Profile search (mirror `Discover.tsx` people tab)
- Theme preference persistence

**Milestone:** User can register, login with OTP, enable TOTP 2FA, edit profile, search users, manage buddy relationships.

### Phase 2 — Feed (3 weeks)
- **Screens:** Feed (for_you/following/nearby tabs), Post Detail, Post Composer (photo/video/text/poll), Comment Sheet
- **Widgets:** `PostCard`, `ReactionBar` (7 types), `PollWidget`, `CommentTile`, `MediaGallery`, `RepostIndicator`
- Post CRUD + poll voting + repost with quote + save/bookmark
- Health Insights screen
- Workout Form (AI analysis)
- Feed offline caching in Isar

**Milestone:** Full feed parity — scroll, create, react, comment, repost, save.

### Phase 3 — Gym & Lives (3 weeks)
- **Screens:** Gym List, Gym Detail (feed/schedule/lives/members/reviews/about/events tabs), Create Gym
- Gym join/leave, membership management, schedule posts, slot enrollment
- Reviews + donations
- **Screens:** Live Browser, Live Room (Agora/LiveKit), Create Live
- Live chat, reactions, gifts, co-host, RSVP, replays
- Random Drop matching flow

**Milestone:** Gym discovery + live streaming.

### Phase 4 — Messaging (3 weeks)
- **Screens:** Conversation List, Chat View, Call Room (audio/video)
- **Widgets:** MessageBubble (all types), AttachmentMenu, VoiceNoteRecorder, TypingIndicator, LinkPreviewCard, LocationCard (Google Maps + OSM fallback)
- Real-time WebSocket messaging, typing, read receipts
- Message reactions, reply, delete, forward
- Link preview scanning
- Voice notes with waveform
- File upload with progress
- WebRTC audio/video calls

**Milestone:** Full messaging parity with web.

### Phase 5 — Marketplace & Wallet (3 weeks)
- **Screens:** Marketplace (events/meal_plans/programmes/products tabs), Meal Plan Detail, Programme Detail, Product Detail, Event Detail
- Cart + Checkout (Flutterwave WebView)
- My Tickets
- Creator Studio
- Food Recognition (camera + AI)
- **Screens:** Wallet overview, Buy artifacts, Send tips/gifts, Transaction history, Withdraw

**Milestone:** Complete economic loop — earn, spend, tip, withdraw.

### Phase 6 — Sessions & Polish (2 weeks)
- **Screens:** Trainer List, Trainer Profile, Booking Flow, Session Detail, Review
- Async Programmes (week-by-week content, progress tracking)
- Availability management
- Notifications list + preferences
- Settings: change password, export data, deactivate/delete account
- Verification: document upload + submission
- PWA-like offline: cache feed, conversations, gym data in Isar
- Performance optimization: lazy loading, shimmers, pagination
- Error handling polish, edge cases

**Milestone:** Full feature parity with web app.

---

## 4. Effort Estimate

| Phase | Duration | Person-weeks | Cumulative |
|---|---|---|---|
| 0 — Foundation | 2 weeks | 4 (2 devs) | 4 |
| 1 — Auth & Profile | 2 weeks | 4 | 8 |
| 2 — Feed | 3 weeks | 6 | 14 |
| 3 — Gym & Lives | 3 weeks | 6 | 20 |
| 4 — Messaging | 3 weeks | 6 | 26 |
| 5 — Marketplace & Wallet | 3 weeks | 6 | 32 |
| 6 — Sessions & Polish | 2 weeks | 4 | 36 |
| QA + Buffer | 4 weeks | 8 | 44 |
| **Total** | **22 weeks** | **44 person-weeks** | |

~5.5 months for 2 full-time Flutter developers.

---

## 5. Model Count Breakdown

| Domain | Models | Examples |
|---|---|---|
| Auth | 8 | User, TokenPair, RegisterPayload, LoginPayload, OTPSerializer, TOTPSetupResponse, TOTPChallengeResponse, LoginInitResponse |
| Profile | 4 | Profile, BuddyRequest, BuddyState, OnboardingData |
| Feed | 12 | Post, Comment, Poll, PollOption, ReactionType, Draft, AuthorData, RepostData, SaveData, ReactionInput, CommentCreateInput, FeedFilter |
| Gym | 14 | Gym, GymMembership, JoinRequest, GymInvite, GymSchedulePost, GymReview, GymDonation, GymCategory, GymCategoryPricing, CreateGymPayload, SlotEnrollment, GymEvent, CityResult, MemberData |
| Live | 8 | BuddyLive, LiveCredentials, AgoraCredentials, LiveKitCredentials, AttendeeInfo, CoHost, GiftInfo, RandomDropRequest |
| Messaging | 10 | Conversation, Message, CallLog, ParticipantData, LinkPreviewData, ChatEvent (sealed class), PendingCall, SendMessagePayload, ForwardPayload, MessageReactionPayload |
| Marketplace | 15 | MealPlan, TrainingProgramme, Product, MarketplaceEvent, EventTicket, Cart, CartItem, DiscountCode, MealPlanReview, TrainingProgrammeReview, FoodItem, FoodRecognitionResult, PersonalizedMealPlan, CheckoutPayload, PurchaseResponse |
| Wallet | 8 | ArtifactTransaction, ArtifactBalance, BalanceItem, BundleInfo, BankInfo, BankResolveResult, WithdrawPayload, TipPayload |
| Sessions | 9 | TrainerProfile, BookingSession, Review, Availability, Programme, ProgrammeWeek, ProgrammeEnrollment, CreateBookingPayload, AvailabilitySlot |
| Notifications | 3 | BuddyNotification, NotificationPreference, UnreadCount |
| Verification | 3 | VerificationDocument, VerificationSubmission, DocumentUploadPayload |
| **Total** | **~94** | |

---

## 6. API Surface

**All REST endpoints:** `https://{host}/api/v1/`

| App | Prefix | Endpoints |
|---|---|---|
| accounts | `/auth/` | register, verify-registration-otp, login, verify-login-otp, token/refresh, forgot-password, reset-password, change-password, totp/setup, totp/verify, totp/disable, totp/challenge, google, logout, deactivate, delete, export-data, sessions, logout-all, activity-log, verify-age |
| profiles | `/profiles/` | me, me/avatar, me/cover, search, onboarding, blocked, pending-requests, buddies/search, recommendations, presence, {username}, {username}/buddy, {username}/follow, {username}/block, {username}/ping, {username}/buddies, {username}/followers, {username}/following, {username}/posts |
| feed | `/feed/` | (list), create, saved, {id}, {id}/comments, {id}/comments/{cid}, {id}/react, {id}/repost, {id}/save, {id}/pin, {id}/poll/vote, drafts, drafts/{id}, workout/analyze, health-insights, workout-form |
| gyms | `/gyms/` | (list), create, check-handle, categories, cities, {slug}, {slug}/join, {slug}/leave, {slug}/members, {slug}/members/{uid}, {slug}/join-requests, {slug}/join-requests/{rid}, {slug}/invite, {slug}/invites/{iid}/{action}, {slug}/schedule-posts, {slug}/schedule-posts/{pid}, {slug}/reviews, {slug}/reviews/{rid}/reply, {slug}/feed, {slug}/donate, {slug}/schedule-posts/{pid}/enroll, {slug}/my-enrollments, {slug}/events |
| lives | `/lives/` | browse, start, {id}, {id}/end, {id}/join, {id}/rsvp, random-drop/start, random-drop/status, {id}/credentials, {id}/refund-gift/{tx}, {id}/co-host, {id}/recording/init, {id}/recording/upload, {id}/recording/complete, {id}/attendees, gym/{gid}/schedule, profile/{username} |
| messaging | `/messaging/` | conversations, conversations/start, conversations/{id}, conversations/{id}/messages, conversations/{id}/read, conversations/{id}/calls, messages/{mid}/react, messages/{mid}/delete, messages/{mid}/serve, messages/{mid}/forward, link-preview, upload, conversations/group |
| marketplace | `/marketplace/` | meal-plans, meal-plans/{id}, meal-plans/{id}/purchase, meal-plans/{id}/personalise, meal-plans/{id}/reviews, programmes, programmes/{id}, programmes/{id}/purchase, programmes/{id}/reviews, products, products/{id}, products/{id}/click, events, events/my-tickets, events/{id}, events/{id}/tickets, events/tickets/{id}, food-recognize, my-services, cart, cart/checkout, cart/discount |
| wallet | `/wallet/` | balance, transactions, purchase/initialize, purchase/confirm, tip, gift, withdraw, withdraw/banks, withdraw/bank-resolve, bundles, exchange-rates, flutterwave-webhook |
| sessions | `/sessions/` | trainers, trainers/{username}, trainers/{username}/availability, trainers/{username}/reviews, my, book/{username}, bookings/{id}, bookings/{id}/review, my-availability, programmes, programmes/{pid}/enroll, programmes/{pid}/weeks, programmes/{pid}/weeks/{wn}/complete, my-enrollments, bookings/{id}/calendar.ics |
| notifications | `/notifications/` | (list), unread-count, preferences, {id}/read |
| moderation | `/moderation/` | reports, content-flags, actions |
| verification | `/verification/` | documents, submissions |
| ai | `/ai/` | predictions, models, api-keys |

**WebSocket endpoints:**
| Path | Events |
|---|---|
| `ws/conversation/{id}/` | message, typing_start, typing_stop, read, react, call_offer/answer/ice/end/decline/ringing |
| `ws/user/{id}/` | presence, new_message, incoming_call |
| `ws/live/{id}/` | live_chat, live_reaction, live_viewer_count, live_gift |
| `ws/random-drop/` | join_pool, match_found |

**Authentication:** JWT Bearer in `Authorization` header (access 7d, refresh 30d, rotation enabled). WebSocket: `?token=` query param.

---

## 7. State Management Mapping

| Zustand Store | Riverpod Provider | Notes |
|---|---|---|
| `useAuthStore` | `authProvider` (Notifier) | Persists tokens to secure storage, holds User + Profile |
| `useCallStore` | `callProvider` (Notifier) | In-memory only, holds PendingCall |
| `useSidebarStore` | N/A | Mobile has no sidebar — use BottomNavigationBar instead |
| `useThemeStore` | `themeProvider` (Notifier) | Persist to SharedPreferences |
| `useNotificationStore` | `unreadCountProvider` (StateProvider) | Updated via WebSocket |
| `usePresenceStore` | `presenceProvider` (Notifier) | Updated via UserConsumer WebSocket |
| `useChatSocket` | `chatSocketProvider` (StreamProvider.family) | Keyed by conversation ID |

---

## 8. Key Technical Decisions

| Decision | Choice | Alternative considered | Why |
|---|---|---|---|
| State management | Riverpod 2 | BLoC, Provider | Less boilerplate than BLoC; compile-safe; no BuildContext needed; .family/.autoDispose built-in |
| Models | Freezed + JsonSerializable | plain Dart classes | Immutable, copyWith, sealed unions for ChatEvent; JSON codegen avoids manual serialization |
| API client | Retrofit (on Dio) | plain Dio calls | Typed interfaces from annotations; generates all boilerplate from Freezed models |
| API bootstrap | openapi-generator | hand-write all | Schema at /api/schema/; can generate ~80% of models + Retrofit services automatically |
| Navigation | go_router | auto_route, Navigator 2.0 | Declarative, deep linking, redirect guards, ShellRoute for bottom nav |
| Local DB | Isar | Drift, Hive | Fast NoSQL for document data; great query DSL; supports offline sync patterns |
| Payments | Flutterwave Flutter SDK + WebView fallback | Stripe only | Flutterwave has a native Flutter package; WebView handles edge cases |
| Maps | google_maps_flutter + flutter_map (OSM) | Only Google Maps | Google key may be unset; flutter_map provides OSM fallback with same API pattern |
| WebRTC | agora_rtc_engine + livekit_client | Only Agora | Backend serves both Agora and LiveKit credentials; support both |

---

## 9. Risk Factors

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| **WebRTC Flutter SDKs differ from web** | Medium | High | Test audio/video calls early in Phase 4; fall back to platform channels if needed |
| **OpenAPI schema gaps** | Medium | Medium | Hand-write complex models (ChatEvent, Post union); use codegen for standard CRUD models |
| **Tailwind → Flutter theme translation** | Low | Medium | Map CSS variables 1:1 to ThemeData extensions; maintain same visual design guide |
| **Offline/optimistic sync complexity** | Medium | Medium | Start online-only; add Isar caching in Phase 6; use same temp-ID pattern as web |
| **Flutterwave Flutter SDK maturity** | Low | Low | WebView fallback already proven in web app |
| **Platform-specific behavior** | Medium | Low | iOS keyboard handling, Android back button, permissions model; test on both platforms per phase |

---

## 10. Coexistence Strategy

The web app remains the primary platform throughout Flutter development. The Flutter app targets **Phase 2 (Feed)** as the first beta milestone — highest-engagement surface. Once Feed is complete, the Flutter app can be TestFlight/Play Store beta-tested while remaining phases continue in parallel.

Deployment cadence:
- **Phase 1 & 2:** Internal testing (Firebase App Distribution)
- **Phase 3:** Closed beta (TestFlight + Play Store internal track)
- **Phase 4+:** Open beta → Production launch at Phase 6 completion

---

## Phase 1 — Auth & Profile: Implementation Prep

### 11.1 Prerequisites from Phase 0
Before Phase 1 UI work begins, Phase 0 must deliver:
1. Flutter project scaffold with Riverpod, go_router, Dio, Freezed, build_runner configured
2. `ApiClient` with JWT interceptor (token refresh, request queuing)
3. `WsManager` singleton with reconnect logic
4. All Freezed models generated (or hand-written stubs for auth + profile at minimum)
5. `ApiResponse<T>` + `Pagination` generic models
6. GoRouter with auth redirect guard and route definitions for all auth routes
7. Theme data matching the Tailwind palette
8. `flutter_secure_storage` wrapper for token persistence
9. `.env` loading for API base URL, WS URL, Google Maps key

### 11.2 Screens to Build

| Screen | Web Source | Key Widgets | Notes |
|---|---|---|---|
| Login | `Login.tsx` | `EmailInput`, `PasswordInput`, `Button`, `GoogleSignInButton` | 3-step flow: credentials → OTP → TOTP |
| Register | `Register.tsx` | All form fields from `RegisterSerializer` | Includes age verification gate |
| Verify Registration OTP | `VerifyRegistrationOtp.tsx` | `OtpInput`, `Timer`, `ResendButton` | |
| Verify Login OTP | integrated in `Login.tsx` | `OtpInput` | |
| TOTP Setup | `TotpSetup.tsx` | QR code display, `OtpInput` | Show secret + QR + verify step |
| TOTP Challenge | `TotpChallenge.tsx` | `OtpInput` | |
| TOTP Verify | integrated | `OtpInput` | |
| Forgot Password | `ForgotPassword.tsx` | `EmailInput`, `Button` | |
| Reset Password | `ResetPasswordConfirm.tsx` | `PasswordInput`, `ConfirmPasswordInput` | |
| Verify Age | `VerifyAge.tsx` | Date picker, `Button` | Gate before registration |
| Onboarding | `Onboarding.tsx` | Multi-step quiz, chip selectors | Goals, activity level, preferences |
| Profile View | `Profile.tsx` | Avatar, stats grid, post/live/gym/achievement tabs | |
| Edit Profile | `EditProfile.tsx` | Form fields from `ProfileUpdateSerializer` | Avatar + cover upload |
| User Profile (other) | `UserProfile.tsx` | Same as Profile but with buddy/follow/block actions | |
| Discover (people tab) | `Discover.tsx` | Search bar, user cards, filter by role | Only the people tab |

### 11.3 Widgets to Build

| Widget | Web Source | Props/Parameters |
|---|---|---|
| `Avatar` | `Avatar.tsx` | src, size (xs/sm/md/lg/xl), verificationStatus, online dot |
| `Button` | `Button.tsx` | variant (primary/secondary/outline/ghost/destructive), size, isLoading, fullWidth |
| `Input` | shared pattern | label, error, prefixIcon, suffixIcon, obscureText, validator |
| `Badge` | `Badge.tsx` | variant (blue/silver/green/gold/orange/red), count |
| `PageLoader` | shared pattern | fullScreen, message |
| `ErrorView` | shared pattern | message, onRetry |
| `EmptyState` | shared pattern | icon, title, subtitle |
| `Toast` | `Toast.tsx` | type (success/error/info), message, duration |
| `OtpInput` | shared pattern | length (6), onCompleted |
| `TabBar` | shared pattern | tabs, selectedIndex, onChanged |
| `StatsGrid` | `Profile.tsx` | items (label + value pairs) |
| `UserCard` | `Discover.tsx` | avatar, name, role, location, onTap, onBuddyTap |

### 11.4 Data Models Needed (Phase 1)

From OpenAPI bootstrap + hand-written overrides:
- `ApiResponse<T>`, `Pagination`
- `User`, `TokenPair`, `RegisterPayload`, `LoginPayload`, `LoginInitResponse`, `LoginOTPResponse`, `TOTPSetupResponse`, `TOTPChallengeInitResponse`, `TOTPChallengeResponse`
- `Profile`, `ProfileUpdatePayload`, `OnboardingData`, `OnboardingPayload`
- `BuddyRequest`, `BuddyStatus`, `PingPayload`, `BlockPayload`

### 11.5 API Repositories Needed (Phase 1)

| Repository | Key Methods |
|---|---|
| `AuthRepository` | register, verifyRegistrationOtp, login, verifyLoginOtp, totpSetup, totpVerify, totpDisable, totpChallenge, forgotPassword, resetPassword, changePassword, logout, deactivate, deleteAccount, exportData, verifyAge, refreshToken, googleLogin |
| `ProfileRepository` | getMyProfile, updateProfile, uploadAvatar, uploadCover, getProfile(username), searchProfiles, getOnboarding, saveOnboarding, getPresence, getBlockedList, getPendingBuddyRequests, getBuddyRecommendations |
| `BuddyRepository` | sendBuddyRequest, acceptBuddyRequest, declineBuddyRequest, followUser, unfollowUser, blockUser, unblockUser, pingUser, getBuddies(username), getFollowers(username), getFollowing(username), getUserPosts(username) |

### 11.6 Routes to Define

```dart
GoRouter(
  initialLocation: '/feed',
  redirect: (context, state) {
    final isAuthenticated = ref.read(authProvider).isAuthenticated;
    final isAuthRoute = publicRoutes.contains(state.matchedLocation);
    if (!isAuthenticated && !isAuthRoute) return '/login';
    if (isAuthenticated && isAuthRoute && state.matchedLocation != '/onboarding') return '/feed';
    return null;
  },
  routes: [
    // Public
    GoRoute(path: '/login', ...),
    GoRoute(path: '/signup', ...),
    GoRoute(path: '/verify-registration-otp', ...),
    GoRoute(path: '/verify-age', ...),
    GoRoute(path: '/forgot-password', ...),
    GoRoute(path: '/reset-password', ...),
    GoRoute(path: '/totp-setup', ...),
    GoRoute(path: '/totp-challenge', ...),
    GoRoute(path: '/onboarding', ...),
    GoRoute(path: '/terms', ...),
    GoRoute(path: '/privacy', ...),
    GoRoute(path: '/cookie-policy', ...),
    GoRoute(path: '/community-guidelines', ...),
    // Protected (inside ShellRoute with BottomNavigationBar)
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/feed', ...),
        GoRoute(path: '/discover', ...),
        GoRoute(path: '/profile', ...),
        GoRoute(path: '/profile/edit', ...),
        GoRoute(path: '/:username', ...),
        GoRoute(path: '/buddies', ...),
        GoRoute(path: '/settings', ...),
        // Future phases add their routes here
      ],
    ),
  ],
);
```

### 11.7 Auth State Flow

```
App start
  → Read tokens from flutter_secure_storage
  → If tokens exist, validate by calling /api/v1/auth/token/refresh/
    → Success: set authenticated → redirect to /feed
    → 401: clear tokens → redirect to /login
  → No tokens: redirect to /login

Login flow:
  credentials → POST /login → login_token → OTP screen
  OTP → POST /verify-login-otp → JWT pair
  If totp_enabled → POST /totp/challenge → temp_token → TOTP screen
  TOTP → POST /totp/challenge (with code) → JWT pair
  Store tokens in secure storage
  Redirect to /feed

Register flow:
  form → POST /register → registration_token → OTP screen
  OTP → POST /verify-registration-otp → JWT pair
  Redirect to /onboarding → POST /onboarding → redirect to /feed

Token refresh (Dio interceptor):
  On 401 → acquire lock → POST /token/refresh/ → if success, retry original request
  Queue concurrent 401s while refreshing (same pattern as web client.ts)
  On refresh failure → clear tokens → logout → redirect to /login
```

### 11.8 Phase 1 Estimation

| Task | Days |
|---|---|
| Scaffold auth screens (Login, Register, OTP, TOTP, Forgot/Reset, VerifyAge) | 5 |
| Onboarding multi-step flow | 2 |
| Profile view + edit + avatar upload | 3 |
| User profile (other) + buddy system | 2 |
| Discover people tab + search | 2 |
| Shared widgets (Avatar, Button, Input, Badge, PageLoader, Toast, OtpInput, TabBar) | 2 |
| Auth provider + token persistence + Dio interceptor | 1 |
| Route definitions + auth guard | 1 |
| **Total** | **18 days (~3.5 weeks)** |

Can be parallelized across 2 devs to fit 2-week calendar target.
