# BuddyUp (Bud) — Regulated Business Model & Platform Analysis

**Version:** 3.0 · **Prepared:** 18 August 2026  
**Working currency:** Kenya shillings (KSh); USD shown where useful  
**Global + Kenya operating lens**  
**Status:** Business-model and compliance analysis grounded in two regulatory research documents; not a legal opinion, medical claim, or audited forecast.

---

## 0. How to read this document

This document updates the BuddyUp business model and operating plan against two regulatory briefs:

1. **The regulation and responsibility for a fitness-based platform that involves meal plans and health fitness programs and shops** — consumer-protection red flags, wellness-vs-medical-nutrition-therapy (MNT) boundary, scope-of-practice safeguards, prohibited wording, responsibility stack, escalation, terms/disclaimer design.
2. **Fitness and fitness products based platform regulations in Kenya, Africa and Globally. Gifting of creators and trainers or fitness program** — influencer/gifting "material connection" disclosure, Kenya Consumer Protection Act (CPA), Kenya Pharmacy & Poisons Board (PPB) health-claims and supplement marketing-authorisation controls, audit-ready documentation, cross-border enforcement.

It also encodes two **platform audits** run against the current codebase:

- **A. Transaction audit** — every money/currency flow reviewed for security and seamlessness.
- **B. Mature-content audit** — end-to-end accommodation of the age-gated Mature category (nude/suggestive trainers, adult-only lives, adult marketplace, nude gyms).
- **C. Feature delivery audit** — mapping of the features shipped since v2.0 to the revenue model and go-to-market, so this document reflects what actually runs today.

The structure of BuddyUp Ltd. is unchanged (see §1), but the operating model has been tightened around the two governing compliance duties that emerge from the regulations: **(1) keep wellness coaching out of medical-nutrition-therapy**, and **(2) make every gifted/sponsored promotion and every money movement transparent, authorised and auditable.**

---

## 1. Company and product summary

Bud is the short customer-facing name for the BuddyUp mobile-first health and fitness community platform. It turns fitness intention into repeated behaviour through mutual **Bud** relationships, gym communities, verified professionals, live/group training, booking and controlled commerce.

**Mission:** make healthy activity easier to start and harder to abandon.

**Repo reality:** a production-shaped system already exists — web/PWA and Flutter clients; Django/DRF + Postgres + Redis + Celery + ASGI backend; LiveKit video; marketplace; booking escrow; wallet/artifacts; moderation; verification; payments integrations; AI services. The business model dials this breadth back to a safe, supportable, regulation-aligned launch.

**Business structure:**

```text
BuddyUp Ltd. (platform operator)
│
├── Consumer community        Free social/accountability experience
├── Partner platform          Gym, coach and practitioner tools
├── Marketplace & bookings    Intermediated transactions; controlled payouts
├── Trust, safety & data      Identity, moderation, consent, risk operations
└── Platform & intelligence   Payments, messaging, video, analytics, APIs
```

### 1.1 Platform capabilities delivered (audit C — what now runs)

Since v2.0 the stack has shipped the following, all live on web (React/PWA) and mobile (Flutter) against the shared Django/DRF core:

- **Commerce / orders.** Checkout now persists a real **Order** (`marketplace_order`) with `OrderItem`, status history (`paid → processing → shipped → out_for_delivery → ready_for_pickup → delivered → completed | cancelled`), fulfillment tracking (`OrderFulfillment` with carrier/tracking/pickup milestones), delivery address and pickup details, and artifact-ledger totals with discount codes. Order history + detail screens exist on web and Flutter. This hardens the **curated marketplace** and **booking/programme fee** revenue lines into an auditable purchase record.
- **Communities.** Beyond gyms, members now belong to **community conversations** with a posts feed (`CommunityPost`, likes, comments, pinned posts) — the accountability/cohort layer of the model now has its own product surface. Web (`Communities`, `CommunityDetail`) and Flutter (`communities_screen`, `community_detail_screen`). This is the on-platform home for **fitness communities** launch segment.
- **Discover & recommendations.** `ProfileRecommendationsView` serves ranked `{profile, match_score}` recommendations; the Flutter Discover surface adds a **"Recommended for you"** rail and **trainer/practitioner badges** on search results, surfacing verified supply. Directly powers the coach/trainer acquisition loop and gifting/sponsorship economics.
- **Profile/media sync (P4).** Avatar and cover uploads on web now update the local profile store immediately; Flutter's edit-profile screen writes the returned `avatar_url` back to the auth provider, so the same image follows the user across sessions instead of only persisting server-side.
- **Settings audit & authentication verification.** Flutter settings now expose **security (2FA/TOTP enable + disable with password)**, **verification status** (identity / trainer / practitioner / shop / gym lanes with a route into the verification flow), and **privacy controls** (public/private profile + active-status visibility). Web settings already carry 2FA, sessions, blocked users, notifications and consent. Both platforms run the age-verification gate (`/verify-age`) and TOTP challenge flows.
- **Addressed v2.0 audit gaps.** With the Mature-category write-path, discover and verification surfaces now in product, the earlier **"no write path in any UI"** gap (old §7.3 items 4–7) is materially closed for profile-edit, discover and settings; the marketplace/live/gym/post create forms remain the outstanding surface (see §7.3).

> Together these convert several "will build" lines of v2.0 into shipped, revenue-relevant product: orders underpin marketplace commissions, communities underpin retention and the community segment, discover underpins coach supply, and settings/verification underpin the **trust, safety & data** layer the revenue model depends on.

---

## 2. Regulatory landscape (from the two briefs)

### 2.1 Consumer protection & wellness/health-claims (brief 1)

The core regulatory tension for a meal-plan/health-programme platform is that most of what it offers is **general wellness nutrition**, which is low-risk, but the moment messaging drifts into **individualised, condition-directed nutrition**, it becomes **Medical Nutrition Therapy (MNT)** — a regulated activity reserved for Registered Dietitians / licensed professionals.

**Consumer-protection red flags to design out:**
- Quick/simple-result promises and "quick fix" framing.
- Warning of severe danger to create urgency.
- Cure-like assertions for conditions (e.g. "cure PCOS", "reverse insulin resistance") without competent evidence.
- Condition-language implying the plan *treats/manages* diabetes, PCOS, IBS, hypertension, kidney disease.
- Uncredentialed promoters making condition-specific claims at viral scale.
- Pseudo-scientific framing (e.g. desiccated thyroid as a "scientific method" for obesity).

**Scope-of-practice boundary (the line we hold):**

| General wellness (allowed) | Medical Nutrition Therapy (MNT — regulated, not offered) |
|---|---|
| Balanced plates, healthy-eating patterns, activity-supported habits | "Use this meal plan to control blood glucose" |
| Recipe collections, shopping tips, meal-plan **templates** | Individually tailored plans for a diagnosed condition |
| General education, goal-setting, habit change | Diagnosis, treatment, mitigation or management of disease |
| "Supports overall fitness/strength" | "Treats back pain", "reverses insulin resistance", "therapy" |

**The five enforced controls:**
1. **Constrained wording + prohibited-wording checklist** (no "treat/cure/reverse/balance/quick-fix/danger" claims).
2. **Substantiation gate** — any nutrition benefit claim tied to marketing must have evidence backing before publication.
3. **Intake + referral triggers** — onboarding collects wellness goals and health history with a clear non-clinical disclaimer; if a user discloses a diagnosed condition, the platform refers to a clinician/RD instead of giving condition-specific directives.
4. **Credentialing & editorial review** — who may author/approve nutrition content; coaches stay in the wellness lane.
5. **Responsibility stack** (below) + insurance + assumption-of-risk / waivers for offline meetups.

**Responsibility stack (who owns what):**

| Layer | Responsibility |
|---|---|
| Platform (BuddyUp Ltd.) | Content/review workflow controls, prohibited-wording list, escalation paths, terms, disclaimers, escalation SLAs, monitoring |
| Content/brand (meal plans, programmes, shops) | Keeping published guidance in the wellness lane; evidence-backed wording; disclosure compliance |
| Individual coach/trainer/creator | Staying within scope; using consent/wellness-goal forms; documenting communications; referring clinical cases; self-disclosing sponsorships |

### 2.2 Influencer gifting, disclosure & Kenya health-pharma (brief 2)

**Gifting = a "material connection" = advertising that must be disclosed.** Any reward — cash, free product, free programme access, trips, services — given to a creator/trainer in exchange for promotion triggers disclosure obligations. This applies to BuddyUp's own creator-gifting, sponsorship features and any brand-driven promotions on the platform.

**Kenya-specific controls:**
- **Consumer Protection Act (CPA)** — non-disclosure of a material connection can attract penalties; enforcement includes public naming.
- **Pharmacy & Poisons Board (PPB)** — regulates advertising of medicines/medical devices; any supplement/health product promoted must have **marketing authorisation / be registered with the PPB** before manufacture, importation, distribution or marketing. Promoting unregistered products via "wellness" framing is a cross-border compliance failure.
- **Wellness vs treatment threshold** — even gifted content must stay in general-active-lifestyle guidance, not imply prevention/diagnosis/treatment of conditions.

**Audit-ready documentation requirements (recorded per campaign):**
1. Written creator/endorsement contracts with explicit disclosure format & placement obligations.
2. **Material-connection documentation** describing the support (gifted product / free programme / sponsorship / affiliate) and the exact deliverables.
3. **Approval gates / pre-publication review** with legal/compliance sign-off, including PPB authorisation check for regulated products.
4. **Recordkeeping** — screenshots/exports of the disclosure **as posted**, with timestamps proving it predated/co-presented the endorsement.
5. **Traceability** — campaign IDs / tracking links connecting each post/video to its contract, authorisation check and stored disclosure evidence.

---

## 3. What regulators and this analysis change in the business model

| Area | Prior model | Updated model (regulation-led) |
|---|---|---|
| Meal plans & nutrition | "Personalised meal plans" as a feature | **Framed as general-wellness meal-plan templates, recipes and habits**; condition-specific personalisation is out of scope; intake + referral triggers |
| Practitioner content | Consultation workflow | Scoped to approved professional relationships; non-credentialed content disclaimed as education only |
| Health claims | AI-driven insights | **Prohibited-wording list + editorial/substantiation review** before any nutrition/benefit claim publishes |
| Gifting/sponsorship | Gifting & tipping as engagement | **Disclosure + material-connection tracking + creator contracts + audit trail** built into the feature |
| Supplements/shop | Broad supplement marketplace | **Only PPB-registered products; authorisation check + disclosure; vet before listing** |
| Artifacts/stored value | Purchasable balance | **Re-confirmed controlled**: non-cash, non-transferable demo/loyalty tokens or licensed vouchers; no cash-out/transferable currency without specialist review (see §6) |
| Mature category | Add-on | **Full 18+/16+ age gate on browse AND detail; creators can set rating; moderation gates in-category and flags out-of-category** (see §7) |
| Money movement | Several flows | **Atomicity, idempotency, ledger completeness, refund/dispute paths and audit rows** (see §8) |

---

## 4. Market and go-to-market (unchanged core, updated rationale)

### 4.1 Beachhead
Kenya, beginning in Nairobi. Mobile-native market: CA of Kenya reported **83.5% smartphone penetration (June 2025)**; Safaricom reported **KSh 38.29 trillion** in M-PESA transaction value (FY2025). Payments lead with M-PESA/card, in KSh — BuddyUp does not require a proprietary currency as a gate.

### 4.2 Launch segments
| Segment | Need | Entry offer | Monetisation |
|---|---|---|---|
| Accountability seekers (18+) | Consistency, solo-training loneliness | Bud match, nearby groups, weekly commitments | Plus, events, programmes |
| Gym members | Community + attendance motivation | Gym community, schedules, check-ins, Bud cohorts | Gym SaaS, renewals |
| Independent coaches | Leads, payments, follow-through | Verification, booking, programme delivery | Subscription + commission |
| Fitness communities | Coordination + safety | Group spaces, events, moderation | Partner plans |
| Employers (later) | Credible benefit without clinical exposure | Opt-in challenges, partner access | Per-eligible-member contract |

### 4.3 Competitive position
Own the **accountability + partner-community + trusted-commerce workflow** that Strava (tracking/community), ClassPass (transactional discovery), Trainerize (B2B coaching tools) and WhatsApp/Instagram (informal local coordination) each serve only partially. Moat is earned: dense consented local graph + verified supply + retention-proof partner data + reconciled payment/dispute ops + **the compliance operating system regulators now expect**.

---

## 5. Revenue model & pricing (updated)

Revenue sequence is unchanged: partner SaaS → completed-booking/programme commissions → member Plus → curated commerce/workplace. **Advertising is not an early dependency** — it conflicts with the trust proposition and complicates the health-data posture.

| Revenue stream | Price | Legal/compliance condition |
|---|---|---|
| Gym Core / Growth | KSh 4,000 / 12,000 per location/mo + 5% in-app paid events | Partner data-processing + content-scope agreement; no % on off-platform membership revenue |
| Coach Pro | KSh 1,500/mo | Coach won't drift into MNT; wellness-lane content contract |
| Booking/programme fee | 10% of completed GMV | Refund, cancellation, payout and dispute policies; commission recognised only on completed non-refunded services |
| BuddyUp Plus | KSh 300/mo / 2,990/yr | Tangible features; **no "unlimited currency" promise** |
| Workplace | KSh 150–300/eligible employee/mo | Participation aggregates only; explicit employee opt-in; no health surveillance |
| Curated marketplace | 8–15% of completed GMV | **PPB-registered products only; vet + disclosure** |
| Gifting/sponsorship | platform cut (20% tips) or partner fee | **Disclosure + creator contract + audit trail** mandatory |

### 5.1 Wellness-meal-plan business model (new, regulation-shaped)
- Sell **recipe collections, meal-plan templates and habit-coaching** — not condition treatment.
- Onboarding **intake form** collects wellness goals + health history with a prominent non-clinical disclaimer.
- If a user indicates a **diagnosed condition / complex symptoms**, the platform **refers** to a clinician/RD and restricts coaching claims.
- Nutrition content passes a **prohibited-wording + editorial review** before publishing; creators require a credential check to author nutrition content.

---

## 6. Wallet, artifacts & payments — controlled-value policy (updated by the audits)

### 6.1 Policy
The business model is: **direct M-PESA/card in KSh for real value; artifacts are a non-cash engagement/loyalty token, not a stored-value wallet.** This preserves gamification while avoiding CBK stored-value, AML/KYC, consumer-protection and revenue-recognition obligations. No cash-out/transferable artifact release without specialist Kenyan payments + legal advice.

### 6.2 Transaction design standard (from the audit)
Every money movement must be:
1. **Atomic** (deduct → move → ledger in one database transaction; **raise, never `return`, inside `transaction.atomic`**).
2. **Idempotent** (a `tx_ref`/`reference_id` with a unique constraint so replay/double-submit cannot double-charge).
3. **Authorised** (correct permissions, ownership/self-block, scope-of-relationship checks, amount re-verification).
4. **Ledgered** (an `ArtifactTransaction` row for *every* debit, credit, platform cut, hold, release and refund — in statuses/directions that exist in the model choices).
5. **Reversible/disputable** (a defined refund/dispute path for marketplace, tickets, gym subscriptions and bookings; escrow released on both no-show handling and dispute resolution).
6. **Held correctly** — `locked_balance` escrow must be released on completion OR refunded on cancel/no-show/dispute; `clearance_at` holds must actually be enforced by a task.

---

## 7. Mature category — accommodation & age-gating (audit B)

### 7.1 Intended design
A dedicated, age-gated **Mature** content category (18+ by default, 16+ only where local law permits and legal review confirms) surfacing:
- Nude or suggestive trainer / creator profiles
- Adult-only live sessions and recordings
- Adult marketplace items (events, products, meal plans, training programmes)
- Nude gyms

**Governing rule:** adult content is *permitted only inside* the Mature category. Adult content anywhere else is flagged **`adult_ungated`** and gated/removed. `general` = all ages. Both the backend (`MATURE_MIN_AGE_16_COUNTRIES`) and the frontend 16+ override sets default to **empty** — so the real-world threshold is 18+ everywhere until legal review confirms otherwise.

### 7.2 Audit result — what is solid
| Capability | Status |
|---|---|
| Model `content_rating` on Profile, Gym, BuddyLive, MealPlan, TrainingProgramme, Product, MarketplaceEvent, Post | ✅ |
| Serializers expose/write `content_rating` (most) | ✅/⚠️ (Post missing; Live drops on create) |
| DB migrations | ✅ |
| Age-gating util + `CanAccessMatureContent` permission (`common/age_gating.py`, `common/permissions.py`) | ✅ |
| Browse/list gating (`gate_mature_queryset`) across lives, gyms, marketplace, profiles, feed | ✅ |
| Moderation: `adult_ungated` reason + gate-mature-vs-flag | ✅ |
| Flutter models + `AgeGating` util + VerifyAge eligibility | ✅ |
| Adult Content Policy page (web + Flutter) | ✅ |

### 7.3 Audit result — gaps to close (so it is *completely* accommodated)
1. **Post (feed):** `PostSerializer` and `PostCreateSerializer` do not expose `content_rating` → a creator cannot post mature content via API, and clients never receive the flag. *(Open the field in both; carry it through `Post.objects.create`.)*
2. **Live create:** `StartLiveView` builds `BuddyLive.objects.create(...)` without `content_rating`, silently dropping a mature value the serializer accepts. *(Persist it.)*
3. **Detail endpoints bypass the gate:** `UserProfileView`, `LiveDetailView`, `PostDetailView`, `GymDetailView`, and all marketplace detail views do **not** apply `CanAccessMatureContent`. A minor could still fetch a mature item by direct detail URL. *(Apply the gate to detail reads too.)*
4. **No write path in most create/edit UIs (web or Flutter):** profile-edit now writes `content_rating` through the profile store (P4) and settings surfaces verification state, but the **gym, live, post, meal plan, product, programme and event create/edit forms still do not send `content_rating`**. Creators **cannot actually classify most content as mature** even though the backend sometimes accepts it. *(Add a "Content rating" control to every remaining create/edit form.)*
5. **Gym update** omits `content_rating` from allowed fields.
6. **Web types** for gym/live/post and all four marketplace items lack `content_rating` (only `types/user.ts` has it) → no client can render a badge or gate display.
7. **Flutter** carries the field in models but no screen consumes `canAccessMature` / `contentRating` locally to blur/gate/badge (Discover surfaces trainer **badges** but not the mature gate).

**Conclusion:** the data layer, migrations, moderation and age-gating plumbing are well-orchestrated and consistent. Full accommodation requires closing the **remaining create-write forms, Post serializer, Live create persistence, detail-endpoint gating, and web/Flutter type+UI** gaps above (7.3 items 1–3, 5–7).

### 7.4 Nude gyms — operating & compliance design

"Nude gyms" are physical member venues (or venue-listed programs) that train in the nude or minimal attire, surfaced on the platform as **Gym records with `content_rating='mature'`** and a clothing/nudity policy. They are a **hybrid digital-physical offer**: the platform is the booking/payment/verification layer; the venue owns the space, liability and operating licence.

**What the platform must provide for a nude gym listing:**
1. **Age + identity gate, end-to-end.** Entry requires a **verified adult** (18+, via the verification pipeline and age gate) on both the **browse/listing page and the booking panel** — the detail endpoint must apply `CanAccessMatureContent` (§7.3 item 3), and on-site check-in should re-confirm identity against the booker.
2. **Explicit venue policy upfront.** A mandatory, plainly worded **nudity/clothing policy, photography ban, consent ground rules and grievance/exit path** must be attached to the listing before booking is enabled. No photo/video capture inside nudity zones.
3. **Written consent + assumption-of-risk.** Every booking must capture participant consent to the nudity policy and an assumption-of-risk / waiver, stored auditably alongside the order or booking record (mirrors §6 transaction standard: ledgered, reversible).
4. **Compliance-by-venue.** The venue must hold its own **business licence and premises classification** under local law (many jurisdictions treat nude fitness as a distinct licensed activity from a standard gym) and its own insurance; the platform contractually requires both, plus its own verified-child/no-minors policy and staff vetting.
5. **Local-law threshold per §7.1.** 18+ default; 16+ only where local law permits **and** the venue's premises classification and legal review confirm it. No cross-border override.
6. **Moderation + reporting.** In-category moderation (same as §7.1) plus a venue-specific **report flow** for policy breaches, with the adult-ungated / flag path reused for anything posted outside the Mature category.

**Monetisation:** nudity-policy gyms can price through the standard gym SaaS (Gym Core/Growth), plus in-app paid events and any programme sales — consistent with §5, with the same commission/payout rules and the disclosure + PPB checks whenever products ride along (supplements, meal plans, programmes). No separate margins are assumed; the venue economics belong to the venue operator.

**Open items to close before nudity-policy venues list:** the §7.3 create-write UI and gym-update `content_rating` gap (items 4–5), the detail-endpoint gate on `GymDetailView` (item 3), venue licence/consent document fields on the gym record, and a booking consent step.

---

## 8. Transaction audit — findings & required fixes (audit A)

19 money flows were reviewed: artifact purchase (Flutterwave), withdrawal, tip, gift, creator-wallet transfer, live entry fee, live RSVP, in-live gift (websocket), gift refund, gym join, gym subscription, gym donation, meal-plan purchase, programme purchase, event ticket, cart checkout, booking escrow, async programme enrolment, ping (non-monetary).

### 8.1 Security gaps (fix before public launch)
| # | Finding | Location |
|---|---|---|
| S1 | **In-live gift input is unvalidated** (raw artifact_type/quantity from client into deduct/cut) | `messaging/consumers.py:573,592` |
| S2 | **Event ticket direct purchase: no self-buy check, no audit row** | `marketplace/views.py:1174` |
| S3 | **Gym "amount"-only donation bypasses deduction** (user-supplied amount, quantity=None skips deduct → inflates gym wallet without paying) | `gyms/views.py:1156-1173` |
| S4 | **Flutterwave webhook trusts `charge.completed` without amount/currency re-verification** | `wallet/views.py:440-451` |
| S5 | **No input bounds on many quantity paths** (`int(quantity)` with no ceiling) | `lives/views.py:427,436`; websocket gift |
| S6 | **Double-spend/race** on un-locked multi-artifact balances; event/cart oversell other than per-deduct locks | `marketplace` checkout; event capacity |
| S7 | **Refund-gift host can refund arbitrary transactions** (not scoped to their live/gifts) | `lives/views.py:466` |

### 8.2 Seamlessness / correctness gaps (fix before scale)
| # | Finding |
|---|---|
| C1 | **`process_withdrawal` is a stub** — marks withdrawals `completed` without moving funds; no async-reversal path |
| C2 | **Currency mismatch** — ledger `fiat_currency='USD'` but Flutterwave calls hardcode `KES` |
| C3 | **Partial-commit-on-failure** — failure paths `return Response` inside `transaction.atomic` (meal plan, programme, ticket, cart) commit an earlier partial deduct |
| C4 | **No order/transaction idempotency keys** on most flows (cart `co_{cart.id}`, gifts, tips, live fees, donations) |
| C5 | **No refund paths** for marketplace (meal plans, programmes, tickets) despite `refunded` statuses/policies existing |
| C6 | **No dispute resolution** implementation despite `BookingSession` having a `disputed` status |
| C7 | **No-show sessions strand escrow** — `no_show` never releases `locked_balance` |
| C8 | **Recurring booking children never charged** (escrow_tx_id='') |
| C9 | **Trainer proceeds have no `credit` ledger row** on escrow release (only platform-cut row + balance delta) |
| C10 | **Platform cuts inconsistently/missing from ledger** (live entry fees, gym subscriptions) |
| C11 | **Gym join/subscription fees record no ledger at all** (opaque `gym.wallet_balance` JSON) |
| C12 | **`clearance_at` holds not enforced** — tips/marketplace "held" credited immediately |
| C13 | **Async programmes are priced but never charged** (`AsyncProgramme.price_artifacts` unused) |
| C14 | **`live_rsvp` ledger type not in model choices**; RSVP fees debited with no destination credit/escrow (lost unless cancelled) |
| C15 | **Gym wallet JSON race** — unlocked `.update()/save()` on `gym.wallet_balance` |
| C16 | **Strong typed data drift**: `clearance_at` decorative; platform cut uses `max(1, int(qty*rate))` → 100% cut on single small units |

### 8.3 Correctness of the credited account (verification)
The demo/support credit to **`jmbngugimbugua@gmail.com`** was applied through the official wallet utilities and is fully ledgered:
- **regular wallet:** 960 champion + 12 squat + 200 of each of the other five artifacts
- **creator wallet:** 40 champion
- **Result:** every artifact type ≥ 200; total fiat-equivalent ≈ **USD 28,820**; 9 audited `bonus` credit `ArtifactTransaction` rows (verified via `_get_total_balance` + `calculate_fiat`).

> **Compliance note (the user asked for "25030 balance + artifacts"):** this is recorded as a **`bonus` / demo-support grant**, not a real purchase, and is consistent with §6 policy (non-cash, no cash-out). If this were real stored value, it would need to be backed by a licensed payment flow and financial review rather than a direct ledger credit.

---

## 9. Governance, terms & operational playbook (mapped to regulations)

| Regulation requirement | BuddyUp response |
|---|---|
| Terms limit medical interpretation | Health/medical disclaimer + assumption-of-risk in Terms; platform states it is not a medical provider |
| Wellness shopping-list vs prescribing meal plans | Nutrition content framed as templates/recipes/education; condition-specific personalisation out of scope |
| Intake + consent forms | Wellness-goal + health-history intake; consent forms; documented coach ↔ participant communications |
| Escalation when needs look clinical | Written triggers, response timelines, responsible-party, referral tracking |
| Coach credentialing + CPD | Verification pipeline; scope-of-practice policy; continuing-education expectation in coach contract |
| Gifting disclosure | Creator/endorsement contracts; material-connection records; prominent disclosure placement; approval gates |
| PPB supplement control | Only registered products; authorisation check; disclosure; pre-publication review |
| Audit-ready records | Campaign IDs + tracking links + timestamped disclosure screenshots + contract/authorisation evidence |
| Responsibility stack | Platform / brand / coach accountability layers with escalation + insurance + waivers |

### Operating KPIs (updated)
North-star: **weekly active members completing a meaningful activity with a buddy, group or verified partner (WAAP).**
- Activation: ≥35% (2 buds + 1 planned activity in 14 days)
- Engagement: WAAP/MAU ≥30%
- Retention: week-4 ≥35%
- Partner value: ≥25% partner-member MAU by month 3
- **Compliance ops: critical reports actioned ≤24h (≥95%); 100% of gifted/sponsored content carries a timestamped disclosure + PPB authorisation check**
- **Financial ops: 100% of money movements ledgered, atomic and idempotent; disputes resolved ≤48h**

---

## 10. Financial plan (summarised; unchanged conservatism)

| KSh m | Yr 1 | Yr 2 | Yr 3 |
|---|---:|---:|---:|
| Partner SaaS (gyms + coaches) | 1.9 | 8.3 | 23.6 |
| Member Plus subscriptions | 0.3 | 2.2 | 8.8 |
| Booking/programme commissions | 0.7 | 3.0 | 8.5 |
| Workplace & curated commerce | 0.0 | 1.5 | 6.0 |
| **Net revenue** | **2.9** | **15.0** | **46.9** |
| **Operating result** | **(19.2)** | **(21.9)** | **(14.8)** |

The plan does not assume three-year break-even. A trust-, content-scope- and payment-operations-heavy marketplace should not hide those costs. Approval funding ≈ **KSh 41m** over 24 months + contingency. Seed ask: **KSh 50m / 18-month runway** (see pitch).

---

## 11. Decisions requested
1. Adopt the regulation-shaped **wellness-lane meal-plan model** and **disclosure + PPB-ready gifting/supplement workflow** as launch scope.
2. Approve **direct KSh payments + non-cash artifacts**; keep cash-out/transferable value paused pending specialist review.
3. Fund the **compliance + financial-hardening backlog** from §7.3 and §8 before public money or mature content.
4. Fund a **90-day design-partner pilot** with the activation/retention and compliance gates above.
5. Close the **mature-content accommodation gaps (§7.3)** so the Mature category — including **nude gyms (§7.4)** — is fully and safely live, and the **transaction gaps (§8)** so every movement is secure and seamless.
6. Ship the remaining **create/edit `content_rating` write-forms** and detail-endpoint gating (§7.3 items 1–3, 5–7) as part of the mature-category go-live, and add the **nude-gym venue-license/consent booking step** (§7.4) before listing nudity-policy venues.
7. Treat the features delivered since v2.0 (§1.1) — **orders/fulfillment, communities, discover recommendations, profile-media sync, settings/2FA/verification/privacy** — as launch scope, and align the design-partner pilot to measure their activation/retention impact.

---

## 12. Sources
- The two regulation briefs (referenced in §0) — fitness-platform consumer protection/wellness-vs-MNT; Kenya/Africa/global fitness & gifting, CPA and PPB requirements.
- Repository transaction audit (§8) and mature-content audit (§7) of the BuddyUp codebase.
- Feature delivery audit (§1.1) of the BuddyUp codebase — orders, communities, discover, settings/2FA/verification, profile-media sync.
- Prior BuddyUp business-plan and funding-pitch working papers (2026), WHO physical-activity data, CA Kenya digital adoption, Safaricom FY2025 results.
