# Refined Plan: Gym & Home Feed UX — Reposts, Icons, Avatar Scale

## 0. Constraints & Cross-Check
- **Cannot run tests** in this planning agent — validation plan is for the implementation agent.
- **`Avatar` component** (`frontend/src/components/ui/Avatar.tsx`) only supports `sm|md|lg|xl`. Passing `size="xs"` silently falls back to `md` (40px). This is why reply/repost avatars look too large.
- **Qomrade reference** inspected: `OpinionCard.jsx` (repost dedup + TikTok-style header), `GroupDiscourse.jsx` (small inline action icons with background pills).
- **Repost model** already exists in BuddyUp backend (`Post.is_repost`, `Post.original_post`). The reposter is stored as `repost.author`. No schema changes needed for MVP dedup.

---

## 1. Avatar component — add `xs` size

**File:** `frontend/src/components/ui/Avatar.tsx`

**Change:** Add `xs: 'w-6 h-6'` (24px) to the `sz` map. Keep `sm|md|lg|xl` unchanged.

**Rationale:** Main post avatars stay at `md` (40px). Reply cards and repost ribbon avatars become 24px — ~40% smaller than current invalid `xs` fallback (32px) and "significantly smaller than currently."

---

## 2. PostCard repost ribbon — smaller reposter avatar

**File:** `frontend/src/components/features/feed/PostCard.tsx`

**Change:** In the repost header ribbon, keep existing reposter avatar but now it will render at 24px (`size="xs"` becomes valid). No visual redesign needed for MVP — the ribbon already shows the reposter's avatar + name + "reposted", matching the Qomrade single-reposter pattern.

**Deferred:** Qomrade's multi-reposter overlapping-avatars pattern requires backend support to return a merged `_reposters` array. Defer until backend dedup is confirmed working.

---

## 3. GymDiscoursePost reply card — smaller avatar

**File:** `frontend/src/components/features/gyms/GymDiscoursePost.tsx`

**Change:** `ReplyCard` currently passes `size="xs"` to `Avatar`. After step 1, this becomes 24px.

**Also change:** In `ReplyCard`, the reaction button icon (`ArrowUp size={14}`) should match Qomrade's upvote scale (`w-4 h-4`). Keep `size={14}` — it's already close. Reply icon (`CornerDownRight size={14} scale-x-[-1]`) stays at 14px.

---

## 4. GymDiscoursePost bottom action bar icons — match Qomrade size & style

**File:** `frontend/src/components/features/gyms/GymDiscoursePost.tsx`

**Current:** Icons are 15px, no background pills, text-only labels.

**Target (Qomrade `GroupDiscourse.jsx`):**
- Reply: `w-3.5 h-3.5` (14px) inside `p-2 bg-secondary/5 rounded-lg`
- Upvote: `w-4 h-4` (16px) inside `p-2 rounded-lg` with active `bg-emerald-500/10`
- Smile (emoji): `w-3.5 h-3.5` inside `p-2 hover:bg-secondary/10 rounded-lg`
- Share/Forward: `w-4 h-4` (not shown in GroupDiscourse but keep as-is in BuddyUp)

**Change:**
- Replace current text-label rows (`<CornerDownRight size={15} /> Replies`, `<ArrowUp size={15} /> N Upvotes`) with icon-pill buttons matching Qomrade structure:
  ```jsx
  <div className="flex items-center gap-2">
    <button className="p-2 bg-buddy-surface-raised rounded-lg hover:bg-buddy-green/10 transition-colors">
      <CornerDownRight size={14} />
    </button>
    <button className={`p-2 rounded-lg transition-colors ${userReaction ? 'bg-buddy-green/10 text-buddy-green' : 'bg-buddy-surface-raised hover:bg-buddy-green/10'}`}>
      <ArrowUp size={16} />
    </button>
    <button className="p-2 bg-buddy-surface-raised rounded-lg hover:bg-buddy-green/10 transition-colors">
      <Smile size={14} />
    </button>
  </div>
  ```
- Keep reply count and upvote count as adjacent text labels (not inside buttons), or remove labels entirely if space is too tight — recommend keeping small text labels for counts.

**Leave unchanged:** Share and Forward buttons in the right-side group — they're fine as-is.

---

## 5. Backend feed dedup — hide originals when a repost exists

**File:** `backend/apps/feed/views.py` (`FeedView.get()`)

**Change:** After cursor pagination materializes the page, deduplicate in Python:

```python
page_posts = list(paginator.paginate_queryset(queryset, request))

# Dedup: if a repost of a post exists on this page, hide the original
reposted_ids = {p.original_post_id for p in page_posts if p.is_repost and p.original_post_id}
deduped_posts = [p for p in page_posts if not (not p.is_repost and p.id in reposted_ids)]
```

**Return:** Serialize `deduped_posts` (not `page`). Update count to `len(deduped_posts)`.

**Risk:** Cursor pagination may behave slightly off if an original is removed (cursor positions shift by 1). For MVP this is acceptable — each page still returns ~N-1 posts at most. Alternative is a DB-level annotate+filter (see Risk Mitigation below).

---

## 5a. Risk Mitigation — DB-level dedup (optional but recommended)

If the post-pagination approach causes cursor issues, instead annotate the queryset:

```python
from django.db.models import Exists, OuterRef, Case, When, Value, BooleanField

reposts_qs = Post.objects.filter(
    original_post=OuterRef('pk'),
    is_repost=True,
    visibility='public',
    moderation_status='clean',
)
queryset = queryset.annotate(
    has_visible_repost=Exists(reposts_qs)
).filter(
    db_models.Q(is_repost=True) | db_models.Q(has_visible_repost=False)
)
```

**Caveat:** This subquery doesn't mirror all tab-specific filters (e.g. `following` tab filters by followed IDs). A repost by a non-followed user would still hide the original. Post-pagination dedup is more accurate for tab-specific visibility.

**Recommendation:** Use post-pagination dedup (step 5) for MVP. Switch to annotated queryset only if cursor pagination breaks in QA.

---

## 6. Backend serializer — expose reposters list on repost entries

**File:** `backend/apps/feed/serializers.py`

**Change:** Add a `reposters` field to `PostSerializer`:

```python
reposters = serializers.SerializerMethodField()

def get_reposters(self, obj):
    if not obj.is_repost or not obj.original_post_id:
        return []
    reposts = Post.objects.filter(
        original_post_id=obj.original_post_id,
        is_repost=True,
    ).select_related('author')[:20]
    return [
        {
            'user_id': str(r.author.user_id),
            'display_name': r.author.display_name,
            'avatar_url': r.author.avatar_url,
        }
        for r in reposts
    ]
```

**Rationale:** Frontend uses this to render the TikTok-style overlapping avatar header. Limit to 20 for perf. Return empty list for originals.

**Deferred for MVP:** The Qomrade-style multi-reposter header is nice-to-have. The basic repost ribbon already works without it. If included, the frontend in step 2 would render overlapping `-space-x-2` avatars from this list.

---

## 7. Frontend — repost ribbon overlapping avatars (conditional)

**File:** `frontend/src/components/features/feed/PostCard.tsx`

**Change:** If `post._reposters` or `post.reposters` array exists and has > 1 entry, render overlapping avatars instead of the single reposter avatar. This is conditional so it gracefully falls back if the backend field isn't there yet.

```jsx
{isRepost && repostersToShow.length > 0 && (
  <div className="flex items-center -space-x-2">
    {repostersToShow.slice(0, 3).map((reposter, idx) => (
      <Avatar key={reposter.user_id || idx} src={reposter.avatar_url} alt={reposter.display_name} size="xs" className="ring-2 ring-buddy-surface" />
    ))}
    {repostersToShow.length > 3 && (
      <div className="w-6 h-6 rounded-full bg-buddy-surface-raised text-[10px] font-bold flex items-center justify-center ring-2 ring-buddy-surface">
        +{repostersToShow.length - 3}
      </div>
    )}
  </div>
)}
```

**Deferred:** Only build if step 6 is implemented. Otherwise keep the simple single-avatar ribbon.

---

## 7a. Alternative: Single repost ribbon summary (always build)

If multi-reposter avatars are deferred, update the existing ribbon to be more Qomrade-like even with a single avatar:

```jsx
<div className="flex items-center gap-2 px-4 py-2.5 bg-buddy-green/10 text-xs">
  <Avatar src={post.author_data?.avatar_url} alt={post.author_data?.display_name || ''} size="xs" className="ring-2 ring-buddy-green/20" />
  <span className="font-semibold text-buddy-green">{post.author_data?.display_name} reposted</span>
  {post.quote_body && (
    <span className="text-buddy-text-primary truncate border-l border-buddy-green/40 pl-2 italic">
      "{post.quote_body}"
    </span>
  )}
</div>
```

Change "reposted" → "reposted" (Qomrade-style) and add `ring-2` to avatar.

---

## 8. Double-click visual — refine overlay styling

**Files:** `frontend/src/components/features/feed/PostCard.tsx`, `frontend/src/components/features/gyms/GymDiscoursePost.tsx`

**Current:** 🏋️ emoji centered on click, scales up and floats over 700ms.

**Refinement:** Use the same animation duration as the click handler timeout (700ms). The emoji should:
1. Appear at click coordinates (absolute, `translate(-50%, -50%)`)
2. Scale from 0 → 1.2 in first 150ms
3. Float up 60px while fading over remaining 550ms

The `animate-heart-pop` keyframe in `globals.css` already does this. Keep as-is.

**Guard against rapid double-clicks:** Reset `heartPop` to `null` immediately before setting new position:
```tsx
setHeartPop(null);
requestAnimationFrame(() => setHeartPop({ show: true, x, y }));
```

Add this refinement to both components.

---

## 9. Media autoplay — already correct

Both `PostCard.tsx` and `GymDiscoursePost.tsx` already have `autoPlay muted loop` on `<video>`. No changes needed unless QA reveals mobile Safari blocking. Out of scope.

---

## 10. Composer differentiation — already correct

- `Feed.tsx`: renders `PostComposer` **with** visibility (no `hideVisibility` prop)
- `GymDetail.tsx`: renders `PostComposer` with `hideVisibility`

No changes needed.

---

## Scope Summary

| # | Task | File(s) | Type |
|---|------|---------|------|
| 1 | Add `xs` avatar size (24px) | `Avatar.tsx` | Frontend |
| 2 | Update PostCard repost ribbon avatar | `PostCard.tsx` | Frontend |
| 3 | GymDiscoursePost ReplyCard smaller avatar | `GymDiscoursePost.tsx` | Frontend |
| 4 | GymDiscoursePost action bar icons → Qomrade size + pills | `GymDiscoursePost.tsx` | Frontend |
| 5 | Backend feed dedup (post-pagination filter) | `views.py` | Backend |
| 6 | Backend serializer `reposters` field | `serializers.py` | Backend (optional) |
| 7 | Frontend multi-reposter overlapping header | `PostCard.tsx` | Frontend (optional) |
| 7a | Single repost ribbon Qomrade-style refinement | `PostCard.tsx` | Frontend (always do) |
| 8 | Double-click overlay rapid-click guard | `PostCard.tsx`, `GymDiscoursePost.tsx` | Frontend |

Tasks 6 and 7 are optional enhancements. Tasks 1–5 and 7a–8 are the core implementation.

---

## Validation Plan

### Manual QA Checklist
- [ ] Repost a post → original is removed from feed, only repost entry remains
- [ ] Multiple users repost same post → repost header shows merged avatar stack or single recent reposter
- [ ] Reply cards show 24px avatars (visibly smaller than 40px main avatar)
- [ ] PostCard repost ribbon shows 24px reposter avatar with ring
- [ ] GymDiscoursePost action bar: Reply/Upvote/Emoji icons are 14-16px inside background pills
- [ ] Double-click on PostCard body → 💪 pop at click position, reaction fires (700ms)
- [ ] Double-click on GymDiscoursePost body → same behavior
- [ ] Double-click on action bar buttons or reaction picker → no pop (stopPropagation works)
- [ ] Rapid double-clicks → no animation glitches (state resets cleanly)
- [ ] Posts with image/video/audio render and autoplay in both feeds

### Type-check
- Run `npm run type-check` in `frontend/` — no new errors introduced
- Run backend tests (if any) for feed views

---

## Open Questions / Out of Scope
- **Cursor pagination edge case:** Post-pagination dedup may cause 1-item cursor drift per page. Monitor in QA. Fix via DB annotate if needed.
- **Mobile double-tap:** Qomrade has touch double-tap fallback. Out of scope unless requested.
- **Multi-reposter header:** Optional (task 7). Can ship without it.
- **Reaction bubbles vs picker:** Qomrade shows inline pill-shaped reaction bubbles. BuddyUp uses a picker popup. Leave as-is unless user requests redesign.
