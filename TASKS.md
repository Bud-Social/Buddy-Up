# Buddy-Up Enhancement Tasks
> Created: 2026-08-21 | Reference: ENHANCEMENT_PLAN.md
> This file tracks granular implementation tasks. Check boxes as you complete each.

---

## Track 1 — PiP Live Window
### Flutter
- [x] T1.1 Add `pip_flutter` (or implement MethodChannel) in `pubspec.yaml`
  - Native PiP uses Agora/LiveKit in-app lifecycle; draggable OverlayEntry fallback implemented
- [x] T1.2 Create `buddy_up_flutter/lib/features/live/widgets/pip_live_overlay.dart`
  - Draggable Positioned widget wrapping video player + mini chat list
  - Controls: close (X), expand (fullscreen), mute toggle, pip-to-room button
- [x] T1.3 In `live_room_screen.dart` — add `WidgetsBindingObserver`
  - `didChangeAppLifecycleState(AppLifecycleState.paused)` → activate PiP
  - `didPopRoute()` / GoRouter `onExit` → activate PiP instead of disposing
- [x] T1.4 Pass live WebSocket/Agora/LiveKit state reference into overlay (don't dispose on nav pop)
- [x] T1.5 Handle PiP resume: tapping overlay → push `/lives/<id>` and close overlay

### Web (React)
- [x] T1.6 In `LiveRoom.tsx` — detect route leave via `useBlocker` or `beforeunload`
- [x] T1.7 Call `videoEl.requestPictureInPicture()` on route leave; catch NotAllowedError
- [x] T1.8 Create `frontend/src/components/live/PipChatPanel.tsx`
  - Fixed bottom-right corner panel, chat message list, input bar
  - Shown as fallback when PiP API not available or video is audio-only
- [x] T1.9 "Expand" button in PipChatPanel navigates back to LiveRoom route

---

## Track 2 — Community Detail Page
### Flutter
- [x] T2.1 Rewrite feed tab in `community_detail_screen.dart`
  - Replace TextField post composer with a floating `+` FAB → push `PostComposerScreen`
  - Replace custom post list items with `PostCard` widget
  - Wire `onLike`, `onComment`, `onRepost`, `onShare` callbacks through community notifier
- [x] T2.2 Add "Invite" bottom sheet in community detail app bar
  - Show invite link with copy button
  - Show 6-char invite code in large monospace text
  - Show QR code (use `qr_flutter` package)
- [x] T2.3 Add "Join" flow
  - Join button on unauthenticated community view
  - Accept invite code field in join dialog
  - On success: call `homeFeedTabsProvider.addCommunityTab()`
- [x] T2.4 Create `community_settings_screen.dart`
  - Upload / change community profile picture (circular image picker)
  - Upload / change community cover photo (banner image picker)
  - Edit name + description
  - Toggle "Create community chat group" switch
  - "Delete Community" danger button (admin only)
- [x] T2.5 Create `community_members_screen.dart`
  - Paginated member list with avatar + name + role chip
  - Search bar (filter by name)
  - Long-press or swipe: promote to admin, remove from community (admin only)
- [x] T2.6 Persist "Communities" home tab
  - `homeFeedTabsProvider`: StateNotifier storing list of joined community slugs
  - Save to SharedPreferences; restore on app start
  - Feed screen renders a tab per joined community

### Web (React)
- [x] T2.7 Update `CommunityDetail.tsx` with PostCard component from Feed
- [x] T2.8 Add invite modal with link + code + QR (use `qrcode.react` library)
- [x] T2.9 Add community settings drawer/modal (profile pic, cover, chat toggle)
- [x] T2.10 Members tab with search + role management for admins
- [x] T2.11 Add "Communities" tab to home sidebar/nav when user has joined communities

### Backend
- [x] T2.12 `GET /communities/<slug>/invite/` → return { link, code }
- [x] T2.13 `POST /communities/join/` with `{ code }` or `{ slug }` body
- [x] T2.14 `PATCH /communities/<slug>/settings/` → update profile_pic, cover, chat_enabled
- [x] T2.15 `GET/DELETE/PATCH /communities/<slug>/members/<user_id>/` → member management

---

## Track 3 — Event Categories
### Shared / Constants
- [x] T3.1 Create `buddy_up_flutter/lib/features/marketplace/utils/event_categories.dart`
  ```dart
  const kEventCategories = [ ... ]; // 25+ categories grouped by section
  ```
- [x] T3.2 Create `frontend/src/config/eventCategories.ts` with same list

### Flutter
- [x] T3.3 In `create_event_screen.dart` — replace `_categories` with `kEventCategories`
  - Add a Step 1 "Category" that shows a searchable chip grid (GridView of FilterChip)
  - Show selected category as a badge in the step header
- [x] T3.4 In `marketplace_screen.dart` — Events tab
  - Add a horizontal `SingleChildScrollView` of `ChoiceChip` above event list
  - "All" chip + one per category (or top 10 + "More" expander)
  - Tapping a chip sets `selectedCategory` state → filters the list

### Web (React)
- [x] T3.5 In `CreateEvent.tsx` — replace categories array with `eventCategories.ts`
  - Add searchable `<Combobox>` or chip grid for category selection
- [x] T3.6 In `Marketplace.tsx` — add horizontal pill row for event category filter
- [x] T3.7 Pass selected category to `useEvents({ category })` hook / API call

### Backend
- [x] T3.8 In `backend/apps/marketplace/models.py` — update `EVENT_CATEGORIES` choices
- [x] T3.9 In `backend/apps/marketplace/views.py` — add `.filter(category=category)` when `?category=` param present
- [x] T3.10 Migration: `python manage.py makemigrations && python manage.py migrate`

---

## Track 4 — Creator Studio
### Flutter — New Screens
- [x] T4.1 Create `creator_orders_screen.dart`
  - ListView of orders with status chips (pending/confirmed/shipped/delivered)
  - Filter row: All / Pending / Active / Completed
  - Tap order → OrderDetailScreen with "Update Status" button (DropdownButton + confirm dialog)
- [x] T4.2 Create `creator_services_screen.dart`
  - List all creator's services (sessions, programmes, meal plans, products)
  - Each item: edit button (→ existing create screens pre-filled), archive toggle, duplicate action
  - "Add Service" FAB → bottom sheet with service type selector
- [x] T4.3 Create `creator_payouts_screen.dart`
  - Balance card: available balance + total earned
  - Transaction history list
  - "Request Payout" button → dialog: amount input + M-Pesa/bank selector
- [x] T4.4 Update `creator_studio_screen.dart`
  - Change TabController length from 4 → 6
  - Add Orders, Payouts tabs; rename/restructure existing tabs
  - Add Settings tab: cancellation policy text field, auto-confirm toggle

### Flutter — Providers
- [x] T4.5 Add `creatorOrdersProvider` (paginated, filterable by status)
- [x] T4.6 Add `updateOrderStatusProvider` (takes orderId + newStatus)
- [x] T4.7 Add `creatorPayoutsProvider` + `requestPayoutProvider`

### Web (React)
- [x] T4.8 Update `CreatorStudio.tsx` to match 6-tab structure
- [x] T4.9 Add Orders management table with status update dropdown
- [x] T4.10 Add Services management panel with edit/archive/duplicate
- [x] T4.11 Add Payouts panel with request payout modal

### Backend
- [x] T4.12 `PATCH /marketplace/orders/<id>/status/` → update order status (creator only)
- [x] T4.13 `GET /marketplace/creator/orders/` → filtered order list for authenticated creator
- [x] T4.14 `POST /wallet/payout-request/` → request payout (amount + method)
- [x] T4.15 `GET /wallet/payout-history/` → list past payouts

---

## Track 5 — Analytics Light-Theme Fix
### Flutter — Theme
- [x] T5.1 In `app_theme.dart` — add `BuddyLightColors` class
  ```dart
  class BuddyLightColors {
    static const surface = Color(0xFFFFFFFF);
    static const surfaceRaised = Color(0xFFF8F8F8);
    static const textPrimary = Color(0xFF111111);
    static const textSecondary = Color(0xFF666666);
    static const border = Color(0xFFE0E0E0);
    // ...
  }
  ```
- [x] T5.2 Add `buildBuddyLightTheme()` using `ColorScheme.light(...)` and `BuddyLightColors`
- [x] T5.3 Wire light theme in `app.dart` based on user settings provider

### Flutter — Analytics Screens (replace hard-coded colours)
- [x] T5.4 `overview_tab.dart` — replace `BuddyColors.surface/black` → `Theme.of(context).colorScheme.surface`
- [x] T5.5 `workouts_tab.dart` — same
- [x] T5.6 `body_tab.dart` — same
- [x] T5.7 `meals_tab.dart` — same
- [x] T5.8 `activity_tab.dart` — same
- [x] T5.9 `report_tab.dart` — same
- [x] T5.10 Any chart card Container decoration → use `Theme.of(context).colorScheme.surfaceContainerHighest`

### Web (React)
- [x] T5.11 In `AnalyticsPage.tsx` — audit all `bg-gray-*` classes in graph sections
  - Replace with `bg-white dark:bg-gray-900` or equivalent Tailwind tokens
- [x] T5.12 Chart tooltip/axis colours: use CSS variables that respect `prefers-color-scheme`

---

## Track 6 — Notifications
### Backend — New Signal Types
- [x] T6.1 Add to `backend/apps/notifications/models.py`:
  `repost`, `community_join_request`, `community_join_approved`,
  `event_ticket_purchased`, `order_status_changed`, `payout_processed`,
  `mention`, `session_reminder` to `NOTIFICATION_TYPE_CHOICES`
- [x] T6.2 In `backend/apps/notifications/signals.py`:
  - `post_save` on Repost model → notify original post author
  - `post_save` on CommunityMembership (status=pending) → notify community admin
  - `post_save` on CommunityMembership (status=approved) → notify user
  - `post_save` on EventTicket → notify buyer
  - `post_save` on Order (status changes) → notify buyer
  - `post_save` on PayoutRequest (status=processed) → notify creator
  - Mention detection in post/comment body → notify mentioned user
- [x] T6.3 Create `backend/apps/notifications/tasks.py` Celery tasks
  - `send_session_reminder`: scheduled 1 hour before session start
  - `batch_notification_cleanup`: archive notifications older than 90 days

### Flutter — UI
- [x] T6.4 In `notifications_screen.dart` — group by date
  - Helper: `_groupByDate(List<BuddyNotification>)` → Map<String, List<...>>
  - Show sticky "Today" / "Yesterday" / "Earlier" headers
- [x] T6.5 Add filter tabs (DefaultTabController): All / Social / Live / Commerce
  - Social: like, comment, follow, buddy_request, mention, repost
  - Live: live_start, live_starting, live_reminder
  - Commerce: event_ticket_purchased, order_status_changed, payout_processed
- [x] T6.6 Add swipe-to-dismiss (`Dismissible` widget, direction: endToStart)
  - On dismiss: call `markRead(n.id)`, optimistically remove from list
- [x] T6.7 Add "Mark all read" `IconButton` in `AppBar.actions`
  - Calls `notificationRepositoryProvider.markAllRead()`
  - Invalidates `notificationsProvider` and `unreadCountProvider`
- [x] T6.8 Update `_notificationIcon()` and add `_notificationRoute()` helper
  - Maps each type to the correct GoRouter path + params
- [x] T6.9 Add new notification type icons:
  `repost` → Icons.repeat, `mention` → Icons.alternate_email, etc.

### Web (React)
- [x] T6.10 In `Notifications.tsx` — add date group headers + filter tabs
- [x] T6.11 Add "Mark all read" button in header

---

## Track 7 — Repost Toggle
### Backend
- [x] T7.1 In `backend/apps/feed/models.py` — add unique constraint
  ```python
  class Meta:
      unique_together = [('author', 'original_post')]
  ```
- [x] T7.2 In `backend/apps/feed/views.py` — refactor repost view
  ```python
  # Toggle logic:
  existing = Post.objects.filter(author=user, original_post=original, is_repost=True).first()
  if existing:
      existing.delete()
      action = 'unreposted'
  else:
      Post.objects.create(author=user, original_post=original, is_repost=True)
      action = 'reposted'
  count = Post.objects.filter(original_post=original, is_repost=True).count()
  return Response({'action': action, 'repost_count': count})
  ```
- [x] T7.3 In `backend/apps/feed/serializers.py` — add `is_reposted_by_me`
  ```python
  is_reposted_by_me = serializers.SerializerMethodField()
  def get_is_reposted_by_me(self, obj):
      user = self.context['request'].user
      return obj.repost_set.filter(author=user).exists()
  ```
- [x] T7.4 Create migration: `python manage.py makemigrations feed`

### Flutter
- [x] T7.5 In `buddy_up_flutter/lib/data/models/post.dart` — add `isRepostedByMe` bool
  - Default `false`; parse from API response `is_reposted_by_me`
- [x] T7.6 In `post_card.dart` — update repost `_ActionButton`
  - Color: `isRepostedByMe ? BuddyColors.green : BuddyColors.textSecondary`
  - Icon: `isRepostedByMe ? Icons.repeat : Icons.repeat` (keep icon, change color)
  - Add a tooltip: "Tap to undo repost" when already reposted
- [x] T7.7 In `feed_provider.dart` — add `toggleRepost(String postId)` method
  - Optimistically update `post.repostCount` ± 1 and `post.isRepostedByMe`
  - Call API; on error: rollback optimistic update + show toast

### Web (React)
- [x] T7.8 Update post type to include `isRepostedByMe: boolean`
- [x] T7.9 In Feed/PostCard component — style repost button green when `isRepostedByMe`
- [x] T7.10 `toggleRepost(postId)` API call with optimistic state update

---

## Regression / QA Checklist
- [x] QA.1 Dark theme: all 7 feature areas render correctly in dark mode
- [x] QA.2 Light theme: analytics, community, feed all look polished
  - Fixed: `analytics_screen.dart` popup menu + TabBar used hardcoded `BuddyColors.textPrimary/textSecondary` → now `Theme.of(context).colorScheme.*`
  - Fixed: `overview_tab.dart` Weight StatCard had hardcoded `BuddyColors.textSecondary` accent → removed (uses default green)
- [x] QA.3 Repost count never goes below 0
  - Fixed: `feed_provider.dart` `toggleRepost()` now uses `.clamp(0, 999999)` on the optimistic count
- [x] QA.4 PiP overlay does not leak memory (stream not duplicated)
  - Verified: `LiveRoomScreen` cleans up Agora / LiveKit engines on pop / dispose; `PipLiveOverlayManager` properly frees overlay and session on close/expand.
- [x] QA.5 Community invite code is always 6 chars, uppercase, unique per community
  - Fixed: `_generate_invite_code()` in `backend/apps/messaging/models.py` generates 6-char uppercase unguessable codes and verifies uniqueness against `Conversation.objects.filter(invite_code=code)`.
- [x] QA.6 Event category filter chip clears correctly with "All" chip
  - Fixed: Flutter `marketplace_screen.dart` and Web `Marketplace.tsx` support selecting "All Categories" and toggling active category chip back to 'all'.
- [x] QA.7 Creator Studio order status update reflects on buyer's Order History page
  - Verified: `OrderFulfillmentView.patch()` validates status transition, saves to DB, triggers buyer notification, and reflects in buyer's `OrderListView` / `OrderDetailView`.
- [x] QA.8 Notification badge count resets to 0 after "Mark all read"
  - Verified: `_markAllRead()` calls `ref.invalidate(unreadCountProvider)` ✓
- [x] QA.9 Deep-link from notification opens correct screen even from cold start
  - Fixed: `push_notification_service.dart` — added `getInitialMessage()` (cold start) + `onMessageOpenedApp` (background tap) with full type→route mapping via `rootNavigatorKey`
- [x] QA.10 All new screens have loading, error, and empty states
  - Verified: `creator_orders_screen.dart`, `creator_services_screen.dart`, `creator_payouts_screen.dart`, `community_members_screen.dart`, `community_settings_screen.dart` all implement complete loading, error (with retry), and empty states.

---

## Notes
- Run `flutter analyze` after each track to catch static issues.
- Run `python manage.py test` for backend after each track.
- Keep `ENHANCEMENT_PLAN.md` updated with checkboxes as items are completed.
