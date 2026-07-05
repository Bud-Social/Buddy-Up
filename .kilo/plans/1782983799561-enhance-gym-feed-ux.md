# Plan: Enhance Gym & Home Feed UX

## Scope
Enhance the BuddyUp feed experience by adding visual double-click-to-like feedback in both the home feed (`PostCard`) and gym discourse (`GymDiscoursePost`), while verifying media autoplay behavior.

---

## Task 1: Add heart-pop overlay to `PostCard.tsx`

**File:** `frontend/src/components/features/feed/PostCard.tsx`

### Changes
1. Add state for the visual feedback:
   - `showHeartPop: boolean`
   - `heartPopPos: { x: number; y: number } | null`
   
2. Update the existing `handleDoubleClick` (line 249) to:
   - If `userReaction !== 'pump'`, call `handleReact('pump')`
   - Capture click `clientX/clientY` relative to the card body element
   - Set `showHeartPop = true` and position state
   - After 700ms, hide the pop

3. Add a conditional absolutely-positioned overlay inside the body container that renders:
   - The pump emoji 💪 at the recorded coordinates
   - CSS animation (keyframe or inline style transition): scale 0 → 1.3 over 200ms, then fade out over 500ms

---

## Task 2: Add double-click-to-like with heart-pop to `GymDiscoursePost.tsx`

**File:** `frontend/src/components/features/gyms/GymDiscoursePost.tsx`

### Changes
1. Add the same state (`showHeartPop`, `heartPopPos`) as PostCard

2. Create a new `handleDoubleClick` similar to PostCard:
   - If `userReaction !== 'pump'`, call `handleReact('pump')`
   - Compute position relative to the post content area (the `flex-1 min-w-0 p-4` div)
   - Trigger the pop with timeout cleanup

3. Add the conditional absolutely-positioned emoji overlay inside the main content div

4. Ensure double-clicking only triggers on the content area (not on reply input or reaction picker)

---

## Task 3: Verify media autoplay behavior

**Files:** 
- `frontend/src/components/features/feed/PostCard.tsx` (line ~156)
- `frontend/src/components/features/gyms/GymDiscoursePost.tsx` (line ~37)

### Rationale
Both components already contain `autoPlay muted loop` on `<video>` elements. No code change is required here **unless**:
- Browser autoplay policies block the media when off-screen. If observed in QA, consider adding a `loadeddata` event listener or IntersectionObserver to trigger play only when visible. This is **out of scope unless failure is reproduced in testing.**

---

## Task 4: Confirm composer differentiation is correct

**Files:**
- `frontend/src/pages/app/Feed.tsx` (line ~91) — home feed composer: does **not** pass `hideVisibility` (visibility shown)
- `frontend/src/pages/app/GymDetail.tsx` (line ~258) — gym detail composer: passes `hideVisibility` (visibility hidden)

**Verdict:** Already correct. No changes needed.

---

## Testing / Validation

### Manual
- Double-click on home feed post body → heart pop appears at click location, 'pump' reaction counts up
- Double-click on already-liked post → no pop, no duplicate reaction
- Double-click on gym discourse post body → same behavior
- Double-click on action bars or reaction picker → no pop (event should be contained)
- Post with image/video/audio in both feeds → media renders with autoplay on scroll

### Automated (if test infra permits)
- Unit test `handleDoubleClick` logic in both components (verify reaction is added, position capture works)

---

## Dependencies
- None — all changes are self-contained in existing components.
- No API or backend changes required.

---

## Risks / Edge Cases
- Rapid double-clicks: guard with `showHeartPop` boolean to prevent overlapping animations
- Clicking inside the sidebar action bar on PostCard: article-level `onDoubleClick` must not fire the heart pop; only the body area handler should. Block via `e.stopPropagation()` or by using separate handlers per zone.
- Mobile Safari: `dblclick` event is unreliable on touch; out of scope unless user selects "enable mobile" as a follow-up.
