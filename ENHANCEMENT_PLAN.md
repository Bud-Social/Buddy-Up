# Buddy-Up Enhancement Plan
> Created: 2026-08-21 | Status: In Progress

---

## Overview

Seven enhancement tracks spanning the Flutter mobile app (`buddy_up_flutter/`) and React
web frontend (`frontend/`). Each track has a clear owner file list, acceptance criteria,
and implementation strategy.

---

## Enhancement 1 — Picture-in-Picture (PiP) Live Window

**Goal:** When a viewer leaves the live page/app, the live feed (video + chat overlay)
continues as a floating mini-window above all other content — enabling true multitasking.

### Strategy
- **Flutter:** Use the native PictureInPicture via method channel or `pip_flutter` plugin.
  Fall back to an in-app floating draggable `OverlayEntry` window for unsupported devices.
- **Web (React):** Use the W3C Picture-in-Picture API (`video.requestPictureInPicture()`)
  combined with a floating overlay `<div>` for the chat panel.

### Files Affected
| File | Change |
|---|---|
| `buddy_up_flutter/lib/features/live/screens/live_room_screen.dart` | Add LifecycleObserver, trigger PiP on background/route-pop |
| `buddy_up_flutter/lib/features/live/widgets/pip_live_overlay.dart` | NEW — draggable in-app float overlay fallback |
| `buddy_up_flutter/lib/features/live/widgets/live_chat_overlay.dart` | Pass chat state to PiP overlay |
| `buddy_up_flutter/pubspec.yaml` | Add pip_flutter or platform channel dep |
| `frontend/src/pages/app/LiveRoom.tsx` | Call video.requestPictureInPicture() on route leave |
| `frontend/src/components/live/PipChatPanel.tsx` | NEW — floating chat overlay beside PiP window |

### Acceptance Criteria
- [x] Navigating away from live page on mobile retains floating video+chat overlay
- [x] PiP window has: close, expand, mute, fullscreen controls
- [x] Chat messages continue streaming in real-time inside PiP
- [x] Tapping the PiP window returns to full live view
- [x] On web, requestPictureInPicture is attempted; fallback: fixed bottom-right panel
- [x] Works in split-screen / multitasking on Android tablets

---

## Enhancement 2 — Community Detail Page — Full Parity & Settings

**Goal:** Community detail uses same PostCard + PostComposerScreen as home feed.
Gains full membership/invite/settings. Joining auto-pins "Communities" tab on home.

### Strategy
- Replace inline text composer with PostComposerScreen pushed modally.
- Replace basic post list with existing PostCard widget.
- Add Settings bottom-sheet with: cover photo, profile picture upload,
  description edit, toggle community chat group, danger zone.
- Generate invite link (buddyup://join/community/<slug>) + 6-char code.
- Add Members tab: search, role badges, remove/promote actions.
- On join → call ref.read(homeFeedTabsProvider.notifier).addCommunityTab(community).

### Files Affected
| File | Change |
|---|---|
| `buddy_up_flutter/lib/features/community/screens/community_detail_screen.dart` | Full rewrite — PostCard feed + PostComposer modal |
| `buddy_up_flutter/lib/features/community/screens/community_settings_screen.dart` | NEW — profile pic, cover, chat toggle, invite code |
| `buddy_up_flutter/lib/features/community/screens/community_members_screen.dart` | NEW — members list, roles, remove/promote |
| `buddy_up_flutter/lib/features/community/providers/community_provider.dart` | Add joinCommunity, invite, settings actions |
| `buddy_up_flutter/lib/features/feed/screens/feed_screen.dart` | Listen to joined-communities to render tab |
| `frontend/src/pages/app/CommunityDetail.tsx` | Port same changes to web |

### Acceptance Criteria
- [x] Post composer in community is full PostComposerScreen (media, polls, etc.)
- [x] Post cards match home-feed PostCard design exactly
- [x] "Invite" sheet shows: copy link, display invite code, QR code
- [x] "Join" accepts an invite code / deep-link
- [x] Community settings: upload profile picture, cover, toggle group chat
- [x] "Communities" tab appears on home page after first join (persisted)
- [x] Members tab: searchable, roles shown, admin can remove/promote

---

## Enhancement 3 — Marketplace Events — Categorised Filters & Creation

**Goal:** Events have rich, searchable categories with filter chips on browse and
category pickers during creation.

### Event Category Taxonomy
```
Fitness: Workout, HIIT, Weight Lifting, Powerlifting, CrossFit, Calisthenics,
         Boxing/MMA, Cycling, Running/Race
Outdoor: Park Yoga, Park Workout, Hiking, Trail Run, Beach Workout
Social:  Cookout/BBQ, Nutrition Workshop, Meal Prep Class
Wellness: Meditation, Recovery/Mobility, Health Talk, Mental Wellness
Competition: Weight Lifting Competition, Fitness Challenge, Obstacle Course
Other: Seminar, Workshop, Community Meet-Up, Other
```

### Files Affected
| File | Change |
|---|---|
| `buddy_up_flutter/lib/features/marketplace/screens/create_event_screen.dart` | Replace _categories, add chip-grid step |
| `buddy_up_flutter/lib/features/marketplace/screens/marketplace_screen.dart` | Add horizontal filter-chip row for event categories |
| `buddy_up_flutter/lib/features/marketplace/providers/marketplace_provider.dart` | Pass category filter param to events API |
| `frontend/src/pages/app/CreateEvent.tsx` | Expand categories, add searchable dropdown |
| `frontend/src/pages/app/Marketplace.tsx` | Add category filter pills to events tab |
| `backend/apps/marketplace/models.py` | Expand EVENT_CATEGORIES choices |
| `backend/apps/marketplace/views.py` | Add ?category= filter to events list endpoint |

### Acceptance Criteria
- [x] 25+ categories available in creation wizard with search/filter
- [x] Category displayed as chip badge on event cards
- [x] Marketplace events tab has horizontal scrollable category filter chips
- [x] Selecting a category chip filters the event list instantly
- [x] Web and mobile share same taxonomy (sourced from backend choices)

---

## Enhancement 4 — Creator Studio — Full Management Suite

**Goal:** Complete back-office: order management, service CRUD, content calendar,
payout dashboard, advanced settings.

### New Tabs / Screens
| Tab | Description |
|---|---|
| Dashboard | KPI cards: revenue, orders, customers, conversion |
| Orders | Paginated list, status filter, per-order detail + status update |
| Services | CRUD for sessions, meal plans, programmes, products |
| Content | Scheduled posts, lives calendar |
| Payouts | Payout history, request payout, bank/M-Pesa config |
| Settings | Creator profile, policies, cancellation rules |

### Files Affected
| File | Change |
|---|---|
| `buddy_up_flutter/lib/features/marketplace/screens/creator_studio_screen.dart` | Expand to 6 tabs |
| `buddy_up_flutter/lib/features/marketplace/screens/creator_orders_screen.dart` | NEW — order list + filter + status update |
| `buddy_up_flutter/lib/features/marketplace/screens/creator_services_screen.dart` | NEW — service CRUD with edit/archive/duplicate |
| `buddy_up_flutter/lib/features/marketplace/screens/creator_payouts_screen.dart` | NEW — payout dashboard |
| `buddy_up_flutter/lib/features/marketplace/providers/marketplace_provider.dart` | Add creator order/payout providers |
| `frontend/src/pages/app/CreatorStudio.tsx` | Mirror all tabs on web |
| `backend/apps/marketplace/views.py` | Add order status update, payout request endpoints |

### Acceptance Criteria
- [x] Creator can view all orders with status filter
- [x] Order status can be updated with single tap + confirmation
- [x] Creator can edit any service without leaving Studio
- [x] Payout balance + history visible; "Request Payout" triggers flow
- [x] Advanced settings: cancellation policy, service availability windows
- [x] All actions provide toast/snack-bar feedback

---

## Enhancement 5 — Analytics Light-Theme Fix

**Goal:** On light theme, graph/data section backgrounds are grey (#F5F5F5) which
looks jarring. Fix to proper light-mode surface with elevated cards.

### Root Cause
Analytics tab widgets hard-code BuddyColors.surface (#1C1C1C) ignoring Theme tokens.

### Fix Strategy
Replace hard-coded BuddyColors.surface/black in analytics widgets with
Theme.of(context).colorScheme.surface tokens. Add BuddyLightColors palette
and buildBuddyLightTheme() function.

### Files Affected
| File | Change |
|---|---|
| `buddy_up_flutter/lib/core/theme/app_theme.dart` | Add BuddyLightColors, buildBuddyLightTheme() |
| `buddy_up_flutter/lib/features/analytics/screens/overview_tab.dart` | Use Theme.of(context) surface tokens |
| `buddy_up_flutter/lib/features/analytics/screens/workouts_tab.dart` | Same |
| `buddy_up_flutter/lib/features/analytics/screens/body_tab.dart` | Same |
| `buddy_up_flutter/lib/features/analytics/screens/meals_tab.dart` | Same |
| `buddy_up_flutter/lib/features/analytics/screens/activity_tab.dart` | Same |
| `buddy_up_flutter/lib/features/analytics/screens/report_tab.dart` | Same |
| `frontend/src/pages/app/AnalyticsPage.tsx` | Fix Tailwind dark: classes for graph sections |

### Acceptance Criteria
- [x] Light theme: graph cards have white/light-grey background (not dark grey)
- [x] Dark theme: unchanged
- [x] Chart text/axis labels readable in both themes
- [x] No hard-coded colour values remain in analytics screens

---

## Enhancement 6 — Notifications — Complete Coverage & Consistent UI

**Goal:** Every key user action fires a notification. Notification centre is polished,
grouped by type, with quick actions.

### Missing Notification Types
| Event | Title | CTA |
|---|---|---|
| Post reposted | @user reposted your post | Open post |
| Community join request | @user wants to join <community> | Approve/Deny |
| Community join approved | You're now in <community> | Open community |
| Event ticket purchased | Ticket confirmed for <event> | View ticket |
| Order status changed | Order #xx is now <status> | View order |
| Creator payout processed | KES xxx sent to M-Pesa | View wallet |
| Mention in post/comment | @user mentioned you | Open post |
| Session reminder | <session> starts in 1 hour | Open session |

### UI Improvements
- Group notifications by date (Today / Yesterday / Earlier)
- Swipe-to-dismiss (marks read)
- "Mark all read" button in app bar
- Filter tabs: All / Social / Live / Commerce
- Badge count updates in real-time via WebSocket/FCM
- Tapping deep-links to the correct screen

### Files Affected
| File | Change |
|---|---|
| `buddy_up_flutter/lib/features/notifications/screens/notifications_screen.dart` | Add grouping, tabs, swipe-dismiss, mark-all-read |
| `buddy_up_flutter/lib/features/notifications/providers/notification_provider.dart` | Add markAllRead, filter providers |
| `backend/apps/notifications/signals.py` | Add signals for repost, community, order, payout, mention |
| `backend/apps/notifications/models.py` | Add new notification_type choices |
| `backend/apps/notifications/tasks.py` | Async Celery tasks for batch notifications |
| `frontend/src/pages/app/Notifications.tsx` | Mirror grouping + tabs on web |

### Acceptance Criteria
- [x] All 8 new notification types fire correctly end-to-end
- [x] Notifications are grouped (Today / Yesterday / Earlier)
- [x] Filter tabs work (All / Social / Live / Commerce)
- [x] Swipe-to-dismiss marks notification read
- [x] "Mark all read" clears badge count instantly
- [x] Deep-link tapping opens exact screen/resource
- [x] Real-time badge update without full app refresh

---

## Enhancement 7 — Repost Toggle (Idempotent) + Accurate Count

**Goal:** A user can only repost once. A second tap undoes the repost (removes from
profile + decrements count). Count updates atomically.

### Strategy
- Backend: Unique constraint (user, original_post) on Repost. Toggle endpoint:
  POST /posts/<id>/repost/ returns { "action": "reposted"|"unreposted", "repost_count": N }
- Flutter: PostCard reads post.isRepostedByMe. If true, icon highlighted green.
  Tapping calls toggle → optimistic count update.
- Web: Same approach in Feed.tsx.

### Files Affected
| File | Change |
|---|---|
| `backend/apps/feed/models.py` | Add unique_together = ('author', 'original_post') |
| `backend/apps/feed/views.py` | Convert repost endpoint to toggle, return new count |
| `backend/apps/feed/serializers.py` | Add is_reposted_by_me SerializerMethodField |
| `buddy_up_flutter/lib/data/models/post.dart` | Add isRepostedByMe bool field |
| `buddy_up_flutter/lib/features/feed/widgets/post_card.dart` | Highlight icon if isRepostedByMe, handle toggle |
| `buddy_up_flutter/lib/features/feed/providers/feed_provider.dart` | toggleRepost() — optimistic count update |
| `frontend/src/pages/app/Feed.tsx` | Wire repost toggle + UI state |

### Acceptance Criteria
- [x] Tapping "Repost" once: adds repost, increments count, turns icon green
- [x] Tapping "Repost" again: removes repost, decrements count, icon returns to default
- [x] User's name in reposters list exactly once (or not at all)
- [x] Count always accurate after app restart
- [x] Optimistic UI — count changes instantly before server confirms
- [x] Web and mobile behave identically

---

## Cross-Cutting Concerns

### Theme Token Usage
All new/modified widgets must use Theme.of(context).colorScheme tokens, never
raw BuddyColors constants, so dark/light theme switching works universally.

### State Management
Use Riverpod AsyncNotifier + optimistic updates for all interactive features.

### Backend API Contract
New endpoints follow existing DRF pattern: authenticated, paginated,
consistent { results, count, next, previous } envelopes.

### Testing
Each enhancement: at least one widget/unit test (Flutter) or component test (web).
Backend: one DRF test per new endpoint.

---

## Delivery Order (Recommended)

| Priority | Enhancement | Reason |
|---|---|---|
| 1 | #7 Repost Toggle | Small, self-contained, high UX value |
| 2 | #5 Analytics Theme | Pure frontend fix, no backend |
| 3 | #6 Notifications | Adds missing signals, high discoverability |
| 4 | #2 Community Detail | Reuses existing components, sets foundation |
| 5 | #3 Event Categories | Expand data model + UI filter |
| 6 | #4 Creator Studio | Larger scope, builds on order system |
| 7 | #1 PiP Live | Requires native platform integration, highest complexity |
