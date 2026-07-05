# Enhancements (Future Phases)

## 1. Real Payment Gateway Integration
**Files affected:** `backend/apps/wallet/views.py`, `frontend/src/pages/app/Wallet.tsx`

- Replace simulated artifact purchase with real Stripe (cards) and M-Pesa (mobile money) calls
- Add Stripe webhook handler for payment confirmation
- Integrate M-Pesa API (Daraja) for Kenyan mobile money payments
- Update withdrawal flow to actually disburse funds via M-Pesa/Bank Transfer
- Add payment intent creation, webhook secret validation, and failure handling

## 2. Verification System (ID Upload + Approval)
**Files affected:** `backend/apps/verification/`, `frontend/src/pages/`

- Build document upload endpoint (ID/passport/certificate photos)
- Add admin review queue with approve/reject actions
- Wire `Profile.verification_status` to update on approval
- Frontend: verification request page, status badges, upload UI
- Block withdrawals until `verification_status != 'none'`

## 3. Moderation Dashboard & Content Flagging
**Files affected:** `backend/apps/moderation/`, `frontend/src/pages/admin/`

- Add flag/report endpoint on posts, comments, profiles, lives
- Build admin dashboard with review queue, bulk actions, user sanctions
- Wire `Post.moderation_status` to hide flagged content from feed
- Auto-flag threshold: if N users flag within M minutes, remove temporarily
- Notify content authors of removal with appeal mechanism

## 4. Discover / Global Search Page
**Files affected:** `frontend/src/pages/app/Discover.tsx`, `backend/apps/profiles/views.py`

- Replace the 10-line Placeholder with a unified search UI
- Search across: users, trainers, gyms, posts, meal plans, lives
- Optional backend endpoint: `GET /search/?q=&type=` aggregating results
- Filters by category, location, role
- Trending / recommended section on empty query

## 5. AI-Powered Personalization
**Files affected:** `backend/apps/ai/`, `backend/apps/marketplace/tasks.py`

- Wire `backend/apps/ai/urls.py` with real endpoints
- Implement GPT-4o (or equivalent) call in the meal plan personalisation task
- Add AI recommendation engine for feed content, workout plans, buddy matching
- Rate-limit AI calls with per-user daily quota
- Frontend loading state + regenerate button on personalised results
