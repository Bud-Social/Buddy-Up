# Bud (BuddyUp) — Master Business Plan

**Prepared:** 6 August 2026
**Planning horizon:** Kenya (months 0–36) → Pan-Africa (years 3–5) → Global (years 5–8)
**Working currency:** Kenya shilling (KSh) for the Kenya horizon; USD shown where useful. Pan-African and global horizons are denominated in USD.
**Document status:** Consolidated operating plan and investment discussion draft—not a forecast, legal opinion, or medical claim. This document merges and expands the 2026 business plan, strategy, funding pitch and business-model strategy documents into a single authoritative reference.

---

## Table of contents

1. Executive summary
2. Business definition and mission
3. Business structure
4. Service scope: what the platform is today
5. The services catalog (detail by domain)
6. How the service foundation compounds into packages
7. Market analysis: Kenya → Pan-Africa → Global
8. Competitive audit: local, Pan-African and global
9. Revenue model and pricing architecture
10. Go-to-market plan
11. Operations, trust, compliance and risk
12. Financial plan
13. Product, service and commercial roadmap
14. Decisions requested and next actions
15. Sources and methodology

---

## 1. Executive summary

Bud is the short, customer-facing name for the BuddyUp mobile-first health and fitness community platform. It turns the intention to exercise into repeat behaviour through a mutual **Buddy Up** relationship, gym communities, verified professionals, live/group training, booking and relevant commerce. Its defining customer promise: *find someone to train with, a trusted coach to guide you, and a community that notices when you disappear.*

The product is materially more capable than a concept. The codebase contains web (React) and Flutter clients, a Django/DRF platform, real-time messaging, live-video infrastructure, a marketplace, scheduling/escrow, moderation, verification, payment integrations, a wallet model and AI services. The launch is deliberately narrower than the system. The beachhead is **Nairobi gym communities and independent coaches**, with a consumer-led free community product and a paid partner operating layer.

The commercial offer is a three-sided network:

1. **Members** use Bud free to form accountable relationships, find nearby communities and join sessions.
2. **Gyms and coaches** use it to retain members, schedule and sell classes/programmes, and manage a community.
3. **Bud earns** recurring SaaS fees and transaction commissions only after it demonstrably improves participation and retention.

The business is structured to grow through three horizons with one compounding foundation:

| Horizon | Market | Focus |
|---|---|---|
| **H1 (months 0–36)** | Kenya (Nairobi → 4+ cities) | Prove the accountability loop, convert 10 design partners → 180+ paying partners, establish unit economics |
| **H2 (years 3–5)** | Pan-Africa (Nigeria, South Africa, Ghana + others) | Replicate the Kenya playbook in 3–5 countries, localise payments/support/compliance per market |
| **H3 (years 5–8)** | Global | Export the partner-community operating layer where emerging-market dynamics apply; pursue regional partnerships |

**Three decisions determine viability:**

- Prove a weekly accountability loop before spending heavily on content or AI: new member → buddy match → scheduled session → attendance → encouragement → repeat.
- Treat regulated health data, professional advice and stored-value/payment flows as controlled services from day one. Do not sell "unlimited artifacts" or permit cash-like transfer/redemption until specialist Kenyan (and then per-market) payments and legal advice confirms the structure.
- Win concentrated communities (10–20 launch partners) before broad national acquisition. A small number of active clusters is more valuable than a large number of inactive installs.

---

## 2. Business definition and mission

### 2.1 Mission and customer problem

Bud exists to make healthy activity easier to start and harder to abandon. Fitness consumers do not lack videos, apps or information; they lack a dependable social commitment, local access and an affordable path to a qualified coach. Gym operators and coaches struggle to convert a membership or enquiry into a persistent, engaged community.

The public-health need is material: the WHO reported that nearly **1.8 billion adults (31%)** did not meet recommended physical-activity levels in 2022. [WHO, 2024](https://www.who.int/news/item/26-06-2024-nearly-1.8-billion-adults-at-risk-of-disease-from-not-doing-enough-physical-activity)

### 2.2 Positioning

**For urban, mobile-first adults who want consistency, Bud is the fitness community and partner platform that combines mutual accountability, trusted local services and participation-led commerce.** It differs from a tracker by starting with the relationship; from a content network by driving a planned activity; and from a class aggregator by giving each gym and coach a persistent community.

Bud is not a healthcare provider, insurer, diagnostic device, medical-record system or a general social network. It facilitates discovery and access to appropriately verified professionals; advice, diagnosis, prescriptions and clinical records remain within professional and legal boundaries.

### 2.3 Design philosophy (guiding policy)

**"Make fitness social by design, not as an afterthought."** Every feature, interaction and economic mechanic is designed to create, reinforce or reward mutual accountability. The policy manifests in four principles:

1. **Mutual consent is the default social primitive** — messaging, goals and accountability require an explicit confirmed Buddy relationship; this is the opposite of one-directional follow.
2. **Doing together beats watching alone** — live sessions and planned group activity are the engagement core; passive consumption is secondary.
3. **The economy rewards participation, not just creation** — reputation, streaks and rewards accrue through consistency, not virality.
4. **Gyms are communities, not listings** — a gym on Bud is a social hub with shared goals, member feeds and collective accountability, not a venue directory.

### 2.4 Strategic refusals

Bud will not:

- build a general-purpose social network or pay to compete on influencer content volume;
- make diagnosis, treatment or individual medical claims through AI;
- expand nationally or internationally before a city cluster has density and positive cohort economics;
- treat GMV, wallet deposits or registrations as revenue; or
- monetise member trust through targeted advertising based on sensitive data.

---

## 3. Business structure

### 3.1 Legal and operating structure

Bud operates as **BuddyUp Ltd.** (platform operator) organised around five operating capabilities—not individual app screens.

```text
BuddyUp Ltd. (platform operator)
│
├── Consumer community        Free social/accountability experience
├── Partner platform          Gym, coach and practitioner tools
├── Marketplace & bookings    Intermediated transactions; controlled payouts
├── Trust, safety & data      Identity, moderation, consent, risk operations
└── Platform & intelligence   Payments, messaging, video, analytics, APIs
```

### 3.2 Operating accountability

| Function | Launch accountability |
|---|---|
| Product/engineering | Reliability, performance on common Android devices, privacy-by-design, release quality |
| Partner success | Vetting, onboarding, training, supply quality, partner adoption and renewal |
| Trust & safety | Age assurance, verification, moderation, incidents, complaints and appeals |
| Finance/operations | Payment reconciliation, refunds, payouts, tax records and dispute controls |
| Growth/community | Cluster activation, ambassadors, programming and lifecycle messaging |

### 3.3 Structure by geography

Each new country operates as a locally incorporated entity or subsidiary under BuddyUp Ltd., because payments, tax, data protection and consumer law are country-specific. The Pan-African and global structure is:

```text
BuddyUp Ltd. (Group / platform technology owner)
├── BuddyUp Kenya Ltd.     (H1 beachhead)
├── BuddyUp Nigeria Ltd.   (H2, subject to country review)
├── BuddyUp South Africa Ltd. (H2, subject to country review)
├── BuddyUp Ghana Ltd.     (H2, subject to country review)
└── (future markets, H3)
```

The group owns the shared platform, brand, AI and data-model IP; each country entity owns local supply, compliance, payments and operations. Expansion into a country is gated on: five+ anchor partners committed, local legal/payments/data review complete, and proven contribution margin in the primary cluster.

---

## 4. Service scope: what the platform is today

### 4.1 System architecture

Repository review shows a React/PWA and Flutter front end supported by Django 5/DRF, PostgreSQL, Redis, Celery and ASGI/WebSockets, with self-hosted LiveKit (production live media), recording and object storage, plus payment, messaging and notification integrations. Thirteen Django application domains are present.

| Service domain | Existing scope | Commercial role | Launch disposition |
|---|---|---|---|
| Identity and profiles | Age gate, OTP, sessions, roles, privacy, public profiles, verification states | Trust foundation | Launch core |
| Buddy accountability | Mutual buddy requests, shared goals/streaks, pings, DMs | Primary retention loop | Launch core |
| Community and feed | Fitness posts, reactions, local/discovery feeds, group features | Member engagement and creator supply | Launch core, tightly moderated |
| Gyms | Community pages, roles, member management, schedules, subscriptions, analytics concepts | B2B2C distribution and retention | Launch core for selected partners |
| Coaches and practitioners | Profiles, availability, booking, programmes, reviews, consultation workflow | High-value supply and transaction revenue | Coaches at launch; practitioners only after compliance controls |
| Live sessions | Group/live rooms, chat, co-hosting, scheduling, replay recording | Habit formation and paid experience | Pilot with selected partners |
| Marketplace | Programmes, meal plans, equipment/supplement listings, cart | Commerce take rate | Digital programmes first; physical goods later |
| Wallet/artifacts | Token denominations, gifting, fees, balances, withdrawal concepts | Potential monetisation/engagement mechanic | Redesign before public launch (see §9.4) |
| AI services | Food recognition, meal-plan personalisation, moderation, ranking, form/health insights | Personalisation and operations support | Keep human-reviewed/clearly non-clinical; stage after core loop |

### 4.2 Scope boundary and priority

The platform contains more surface area than an early operating company can support. The initial scope: community onboarding, buddy matching, partner communities, events/sessions, coach bookings, local payment collection and a small digital-programme catalogue. Everything else is a controlled pilot.

The following must **not** be marketed as launch promises until validated: medical consultations, prescription sales, diagnostic or injury claims, broad supplement marketplace, AI coaching/form diagnosis, cash-out wallet functionality, anonymous interactions in private communities, and a large-scale open live-streaming network. These are risk, quality or liquidity multipliers.

### 4.3 Service scope by customer

| Customer | Core job | Included service | Paid expansion |
|---|---|---|---|
| Member | Stay consistent | Profile, buddies, groups, discovery, check-ins, selected free events | Bud Plus: deeper plans, session credits/priority, insights, partner benefits |
| Coach | Find and retain clients | Verified profile, availability, booking, programme delivery, client chat | Coach Pro: CRM-lite, recurring plans, analytics, branded offers, lower transaction fee |
| Gym/studio | Retain members and fill classes | Branded community, schedule, member communication, check-in/event tools | Gym Growth: payments, multi-location controls, retention dashboard, campaigns, integrations |
| Employer | Support workforce wellbeing | Curated activity challenges and partner access | Workplace: administrator controls, aggregate reporting, wellbeing campaigns—never employee health surveillance |
| Approved merchant | Reach relevant buyers | Curated listing and fulfilment rules | Partner campaigns, affiliate reporting, bundles |

---

## 5. The services catalog (detail by domain)

The following catalog is the detailed inventory of what the platform already builds. It is the basis for every package in §6 and every revenue stream in §9.

### 5.1 Accounts — authentication and security

- Email/phone + password registration with strength meter; age verification (DOB check, hard block under 16, hashed storage)
- OTP email/phone verification (6-digit, 10-min expiry, 3-attempt lockout); JWT auth with HttpOnly cookies; device session management with "sign out all devices"
- Google OAuth 2.0 and Apple Sign In; TOTP 2FA; rate limiting on login/OTP/registration
- Account soft-delete (30-day recoverable) and hard-delete pipeline; async data export (Celery, JSON/ZIP); consent logging for GDPR and Kenya Data Protection Act

### 5.2 Profiles — identity, buddies and reputation

- Public profile (username, display name, bio, avatar, cover); role selection (Regular / Trainer / Health Practitioner)
- Verification badge system (none → email → ID → trainer → practitioner)
- Buddy relationship system (two-way confirmed connections; three tiers: Follow, Buddy Up, Gym Membership); request accept/decline/ignore
- Accountability pings, shared goals, streak cheers; follow/block/unfollow; privacy settings; anonymous posting toggle
- Streak tracking with Rep Ring (circular progress arc); workout schedule sharing

### 5.3 Feed — community and content

- 7 post types (Text, Photo, BuddyClip, BuddySession, Workout Log, Meal, Progress) + 24h Moments + polls
- 3 feed tabs: For You (algorithmic/ML-ranked), Following (chronological), Nearby (geo-based)
- 7 fitness reactions (Pump, Fire, Respect, Grind, Let's Go, Haha, Too Hard); nested comments with pinning/sorting; repost (simple + quote); save to private collections
- Visibility: public, buddies-only, gym members, private; auto-flagging + human review queue

### 5.4 Lives — live training sessions

- 6 session types: Open Sweat, Buddy Circle, Gym Live, PT Session Live, Random Drop, Practitioner Live
- **Random Drop**: spontaneous matching into group live sessions by activity, timezone, experience level
- Pre-live setup (title, category, access, fee, duration, co-hosts, scheduling); host controls (camera/mic, screen share, music/timer overlay, rep counter, exercise labels)
- Viewer experience (live comments, emoji reactions, artifact gifting, Do-It-With-Me, PiP, quality selection); live chat moderation
- Replays stored to S3-compatible storage; LiveKit Egress recording; WebRTC for small groups, Agora-style for large audiences

### 5.5 Gyms — partner communities

- Public/private/secret gyms; single or multiple ownership (up to 5 co-founders); free/member-only/paid/tiered subscription models
- Roles: Owner, Co-owner, Trainer, Moderator, Member, Guest + custom roles; gym page (header, feed, lives, members, trainers, about)
- Gym wallet with platform split; co-owner revenue splits; member management (join queue, search, remove, ban); reviews, donations, categories, equipment tracking; weekly live schedule publishing

### 5.6 Sessions — trainers and practitioners

- Trainer profiles (specialties, certifications, years experience, languages, session types); availability calendar with drag-and-drop time blocks, buffers, session caps
- Session booking with escrow payments; cancellation/no-show policies; dispute resolution
- Async training programmes (week-by-week plans, progress, client comments); practitioner consultation notes, referral system, prescription/recommendation generation; reviews only from completed sessions

### 5.7 Marketplace — commerce

- 5 storefronts: Meal Plans, Training Programmes, Supplements, Prescribed Products, Equipment & Gear
- Meal Plans: 11 diet types, preview day, full purchase, shopping lists, reviews
- AI Meal Plan Personalisation (fine-tuned LLM, USDA database, dietary adjustments)
- Supplements: third-party listings with vetting, affiliate links, practitioner recommendations; wearable integration (Apple Health, Google Fit, Fitbit, Garmin, MyFitnessPal)

### 5.8 Messaging — real-time communication

- Real-time DMs via Django Channels + Redis (WebSocket); DMs only between confirmed buddies; session chat threads (auto-open during booking, auto-archive after 7 days)
- 12 message types (text, photo, video, voice, documents, location, workout logs, meal plans, artifact tips, accountability pings, call logs)
- Group chat for gyms (up to 1,000 members) with sub-channels; read receipts, typing indicators, reactions; per-user soft delete, reply threading; end-to-end encryption (Signal Protocol-based); spam protection

### 5.9 Wallet — the virtual economy

- 7 Fitness Artifact types at fixed USD rates: Dumbbell ($0.10), Barbell ($0.50), Burpee ($1.00), Squat ($2.50), Sprint ($5.00), PR ($10.00), Champion ($25.00)
- Purchase via Stripe, M-Pesa (Daraja API), Flutterwave, PayPal; bundle pricing; spend on tips, live entry, gym subs, PT sessions, marketplace, boosting; earn via tips, fees, sales, referrals
- Transaction history with search/filter/export; escrow/hold periods, locked balances, clearance pipeline; KYC/AML compliance (purchase limits >$50/month)
- **Launch disposition:** redesigned before public launch (see §9.4)

### 5.10 Notifications, moderation and trust

- Multi-channel: push (Firebase), in-app bell, email (SendGrid), SMS (Africa's Talking); 20+ notification types
- Content flagging with auto-flag thresholds (AI-assisted); 3-strikes system (warn → remove → suspend); NSFW detection, profanity filter, health-misinformation flagging
- Human-in-the-loop moderation queue with severity ordering, stats and approve/remove/escalate actions (§6.4)

### 5.11 AI and intelligence

- AI microservice (FastAPI) with model pipeline for ranking, retrieval, moderation, MLOps and packaging
- Feed ranking: ML + multi-armed bandit (LinUCB) with Redis-backed state; moderation models (NSFW, toxic, spam, misinformation); food recognition; form/health insights (pilot)
- Training notebooks, model cards, DVC stages; model metadata sync and prediction audit
- **Operational uses first:** safety triage, discovery/ranking with human oversight, bounded meal/workout suggestions. Form analysis, medical-adjacent recommendations and automated coaching remain controlled pilots.

### 5.12 Infrastructure

- Docker Compose dev + prod (13 services); CI pipeline (GitHub Actions); Sentry error monitoring; rate limiting at Nginx level; PostgreSQL 16, Redis 7, Celery worker/beat

---

## 6. How the service foundation compounds into packages

Bud's defensibility is the compounding connection between identity, social commitment, participation evidence and local supply. A user who joins a gym community, confirms two buddies and attends a live session creates useful context for every later offer—without turning personal data into an advertising product.

```text
Verified identity + consent
          ↓
Buddy/community relationship → scheduled activity → attendance & streak evidence
          ↓                                      ↓
Trustworthy coach/gym discovery              retention insight
          ↓                                      ↓
Bookings and digital programmes  →  partner packages / workplace challenges
          ↓
Curated commerce and benefit bundles
```

The expansion respects user choice: social and activity data may improve in-product recommendations only under transparent consent; it must never be sold, shared with employers, or used to infer health status.

### 6.1 The package ladder

Every package below reuses proven platform services—identity, buddy graph, attendance, payments, moderation and messaging. This is why packages are cheap to launch and compounding rather than disconnected features.

| Package | Customer and timing | What it packages | Why the foundation matters |
|---|---|---|---|
| **Bud Community** | Members, launch | Buddy relationships, group challenges, events, basic discovery | Establishes the activity graph and repeat habit |
| **Coach Launch / Pro** | Coaches, months 3–9 | Booking, payments, programmes, client community, analytics | Uses verified identity, chat and attendance as a lightweight operating system |
| **Gym Core / Growth** | Gyms, months 3–12 | Branded community, class/events, check-in, messaging, member offers, retention insights | Converts a venue into an always-on member relationship |
| **Digital Transformation Bundle** | Members + coaches, months 6–12 | Structured programme, scheduled group sessions, coach check-ins, accountability cohort | Bundles separately proven services into a higher-LTV outcome product |
| **Workplace Wellness** | Employers, year 2 | Opt-in teams, challenges, partner benefits, anonymised aggregate engagement reporting | Reuses groups, partners and event mechanics while preserving employee privacy |
| **Local wellness benefits** | Partners, year 2 | Curated goods, nutrition/physio referrals, member discounts | Builds only after verified supply, fulfilment rules and clear consumer trust |
| **Platform/API integrations** | Larger gyms and ecosystem partners, year 3 | Membership/check-in and wearable integrations | Requires stable identity, consent, partner data model and support capability |

### 6.2 Services → packages → new services (recursive growth)

The service catalog and package ladder feed each other in a loop that opens new service markets:

1. **Bud Community** (social graph + attendance data) → enables **Gym Growth** (retention insight) and **Coach Pro** (client ops).
2. **Gym Growth/Coach Pro** (partner operating data) → enables **Digital Transformation Bundle** (outcome-selling) and **Workplace** (employer contracts).
3. **Workplace + partner data** (aggregate, consented) → enables **Local wellness benefits** and **curated commerce** (supply-quality-gated).
4. **Curated commerce + supply data** → enables **Platform/API integrations** (ecosystem reach) and, in H2/H3, **Pan-African and global expansion** where the same ladder replays in each country.

Each rung requires the trust, identity, payments and moderation foundation of the rung below it. This is the structural reason the business can add packages without building new platforms—the services are already in the catalog (§5).

### 6.3 The core loop (north-star mechanism)

```text
Join a trusted local community
        ↓
Confirm two Bud connections
        ↓
Plan or book an activity
        ↓
Attend, check in and encourage one another
        ↓
Earn a streak/reputation and plan again
```

Every product and commercial decision strengthens this loop. A user who watches content but does not form a relationship, make a plan or attend is not yet receiving Bud's core value.

### 6.4 AI as an enabling service for packages

AI is an operational input to the packages, not a feature catalogue. Three deployments matter most:

- **Safety triage** (NSFW, toxic, spam, misinformation) feeds the moderation queue that underpins every community package.
- **Discovery/ranking** (ML + multi-armed bandit with human oversight) powers For You feeds and coach/gym recommendation inside Bud Community and Coach Pro.
- **Bounded meal/workout suggestions** with explicit limitations, correction/escalation paths, and never as the sole basis for health or safety decisions.

All AI outputs carry limitations and escalation controls; accuracy, fairness, consent and cost are monitored per model (§11).

---

## 7. Market analysis: Kenya → Pan-Africa → Global

### 7.1 Horizon 1 — Kenya beachhead (Nairobi first)

Kenya is a sensible beachhead because the core behavioural moments—messaging, mobile payments and community coordination—already happen on the phone. The Communications Authority reported **83.5% smartphone penetration by June 2025** and 76.16 million SIM subscriptions in the March 2025 quarter. [Communications Authority of Kenya](https://www.ca.go.ke/mobile-internet-and-tech-services-surge-kenya-digital-shift-accelerates) These are distribution enablers, not proof of willingness to pay; price, connectivity and trust still shape adoption.

Payments must be locally native. Safaricom reported KSh **38.29 trillion** in M-PESA transaction value for FY2025 and 15.2% M-PESA revenue growth—evidence that small, routine digital transactions are familiar. [Safaricom FY2025 results](https://www.safaricom.co.ke/images/Downloads/FY25-Press-Release_May-9-2025.pdf) Bud leads with M-PESA and card flows and does not require a proprietary currency as an additional step.

The initial target is not "all Kenyans." It is smartphone-owning adults in Nairobi (then Mombasa, Kisumu and selected university/office clusters) with exercise or wellness intent who need accountability or better access. Supply wedge: independent coaches, boutique studios, gyms with active WhatsApp communities, run clubs and fitness creators.

#### Segmentation (H1)

| Segment | Need and behaviour | Entry offer | Monetisation potential |
|---|---|---|---|
| Accountability seekers (18+) | Wants consistency, often trains alone | Buddy match, nearby small groups, weekly commitments | Plus conversion, events, programmes |
| Gym members | Pays for access but needs community and motivation | Gym community, schedules, check-ins, buddy cohorts | Gym SaaS, renewals, partner offers |
| Independent coaches | Needs leads, payments and client follow-through | Verification, booking, programme delivery | Subscription + booking commission |
| Fitness communities | Needs coordination and safe membership | Group spaces, events, volunteer/moderation tools | Partner plans, sponsored challenges |
| Employers (later) | Needs a credible benefit without clinical-data exposure | Opt-in challenges and partner access | Per-eligible-member contract |

#### Market sizing approach (H1)

Public data does not establish a reliable Kenya-specific "fitness-app TAM"; a large purchased-market number would create false precision. Bud uses a bottom-up, serviceable-market model tied to attainable partners and active users.

**Illustrative Nairobi serviceable market (to validate):** 150 partner gyms/studios × 300 reachable members = 45,000 reachable members; 1,000 verified coaches/creators × 30 reachable prospects per year = 30,000 additional prospects. At 25% activated monthly participation, the first operating market is approximately 18,750 MAU. Expanding to four Kenyan cities and partner categories multiplies this only after partner conversion, cohort retention and payment acceptance are observed.

The governing metric is **active partner-community members**, not registrations. Each quarter these inputs are replaced with CRM partner data, activation cohorts and payment data.

### 7.2 Horizon 2 — Pan-Africa (years 3–5)

The Kenya playbook transfers where four conditions hold: mobile-first population, growing fitness spend, a dominant mobile-money or card rail, and fragmented informal supply (WhatsApp groups, gym front desks, coach Instagram pages).

**Priority markets and their distribution/payment rails (to validate locally):**

| Market | Population-scale | Mobile payments | Partner wedge | Localisation gate |
|---|---|---|---|---|
| Nigeria | Africa's largest population; strong fitness-creator scene | Paga/OPay/Kuda, card rails | Gyms, coaches, run clubs in Lagos/Abuja | Country entity, payments/legal review, Naira pricing |
| South Africa | High smartphone ownership; large gym chains | Card + EFT, mobile wallets | Established gym chains, studios | Country entity, data-protection (POPIA), ZAR pricing |
| Ghana | Mobile-money strong (MTN MoMo) | MTN MoMo | Coaches, studios in Accra/Kumasi | Country entity, GHS pricing |
| Other | Rwanda, Uganda, Tanzania, Ethiopia (later) | Mobile money native | Community-first clusters | Gated on anchors + compliance |

Pan-African expansion is **country-by-country**, not "regional." Each market requires its own payments, tax, consumer and data-protection review before launch (§3.3). Bud does not "go live in Africa"; it goes live in a city where five anchor partners have committed.

**Pan-African market signals (to validate):** Africa's fitness-app and wellness spend is growing faster than global averages; smartphone penetration is rising across the continent; mobile-money ecosystems make digital collection native. These support the wedge but do not replace partner-led validation.

### 7.3 Horizon 3 — Global (years 5–8)

Global expansion is opportunistic and partner-operating-led rather than consumer-app-led. Bud exports the **partner community operating layer**—gym/coach community, attendance, booking, payments and moderation—to regions where emerging-market dynamics apply (e.g., parts of the Middle East, Southeast Asia, Latin America) or where a partner network invites Bud in.

Bud does not attempt to out-spend Strava, Nike Training Club or Peloton on content or hardware. It competes on the accountability-and-partner-community workflow and on local operating density (§8).

**Global market context:** the global digital fitness market is large and contested; Bud's defensible segment is "local accountability infrastructure," not "content library." Global entry is gated on: proven 90-day contribution margin in the primary cluster, a licensed/partnered payments path, and local compliance review.

### 7.4 Demand and buyer insights to test

- Does a member return at least twice in the first 14 days when they make two confirmed buddy connections?
- Do partners see a measurable lift in class attendance, membership renewal intent or coach enquiry conversion versus a comparable baseline?
- Will a user pay KSh 300–600/month (or local equivalent) for a concrete bundle of accountability and benefits, rather than a generic "premium" badge?
- What price and cancellation policy lets a coach sell a reliable online/hybrid programme?
- Which locally relevant activities (strength, running, dance/HIIT, football, yoga, rehabilitation) produce the densest repeat communities?

---

## 8. Competitive audit: local, Pan-African and global

Competition is fragmented by job-to-be-done. Bud does not claim that no competitor has community, tracking or video. Its opportunity is to integrate local partner community, mutual accountability and commerce—first in Kenya, then Pan-Africa, then selected global markets.

### 8.1 Global and category competitors

| Competitor/category | Strongest customer value | Gap Bud can address | Strategic response |
|---|---|---|---|
| Strava | Deep activity tracking, global community, device ecosystem (180M+ active people) | Strong outdoor/endurance brand; not a Kenya-local gym operating system | Integrate/share where useful; own accountability cohorts and local partner workflows, not GPS parity |
| Nike Training Club / FitOn / YouTube fitness | Large, polished on-demand content libraries | Content abundance does not guarantee local relationships or trusted booking | Curate partner-led programmes; do not fund a content-volume war |
| Peloton | Premium instruction, hardware, subscription | Expensive, hardware-led model mismatched to a broad African beachhead | Offer device-agnostic group accountability at local prices |
| ClassPass | Discovery and credit-based booking | Transactional demand marketplace, not persistent gym community | Give partners community and retention tools; add cross-partner discovery only where supply economics work |
| Trainerize / TrueCoach | Coach programming and client-management workflows | Strong B2B tools but not a local social acquisition/community network | Win with discovery + community; partner/integrate rather than recreate mature back-office depth early |
| Instagram/TikTok/WhatsApp | Discovery, creators, habit-forming communication | No fitness-specific trust, attendance, scheduling or controlled transactions | Use as acquisition channels; offer the action layer they lack |
| Fitbit / Apple Health / MyFitnessPal | Tracking, wearables, nutrition | Personal dashboards with no accountability layer | Integrate wearables; do not compete on solo tracking |
| Twitch (fitness category) | Live streaming + chat | Not purpose-built for fitness; no accountability or commerce | Reference for live engagement, not a direct competitor |

### 8.2 Pan-African and local competition

The immediate local competitors are often not branded apps: gym front desks, WhatsApp groups, Instagram coach pages, M-PESA till payments, spreadsheets and informal referrals. Their advantages are familiarity and zero switching cost. Bud must import member data/events quickly, work on low-to-mid-range phones, make mobile-money payment simple, and show a gym an early retention result.

Pan-African competitors of note (to monitor as they scale): regional fitness and gym-management SaaS, mobile-wallet-adjacent wellness products, and global platforms entering via acquisition of local supply. The defensive posture is partner density and operating proof, not brand spend.

| Local substitute | Advantage | Bud response |
|---|---|---|
| WhatsApp groups | Familiar, free, zero switching cost | Offer attendance, scheduling, payments and safety the group lacks; import/export events |
| Gym front desk + spreadsheets | Trusted, in-person | QR join, member management, retention dashboard, check-in |
| Instagram coach pages | Distribution and trust via social | Verified profiles, booking, payments, client follow-through |
| M-PESA till + informal payments | Ubiquitous | Native M-PESA collection with reconciliation and payouts |

### 8.3 Competitive advantage—earned, not assumed

Potential moats: (1) a dense, consented local buddy/community graph; (2) verified, well-rated supply; (3) partner operating data that proves retention; (4) payment/reconciliation and dispute operations; (5) locally relevant service design. None is a moat at launch. It becomes one only when the platform reaches repeated participation and partners would lose a meaningful community workflow by leaving.

**Differentiators versus global apps:** mutual-consent accountability (vs one-directional follow); live Random Drop matching (vs solo tracking); participation-rewarding economy (vs content-virality economy); gym-as-community (vs venue listing); African-native payments from day one (vs North America/Europe-first); an integrated catalog (social + live + marketplace + community + booking in one).

---

## 9. Revenue model and pricing architecture

### 9.1 Recommended revenue sequence

1. **Partner SaaS** creates predictable gross profit and aligns Bud with partner retention.
2. **Booking/programme commissions** monetise transactions where Bud provides discovery, payment and support.
3. **Member Plus** sells a clear outcome bundle after the free loop is valuable.
4. **Curated commerce and workplace contracts** follow verified supply and operational capability.

Bud does not depend on advertising early; it conflicts with the trust proposition and makes the value of intimate health/community data ambiguous.

### 9.2 Pricing architecture (H1 — Kenya)

| Revenue stream | Indicative Kenya pricing | Recognition and economics | Guardrail |
|---|---:|---|---|
| Gym Core | KSh 4,000/month/location | Recurring SaaS | Pilot free 60–90 days only against activation commitments |
| Gym Growth | KSh 12,000/month/location + 5% on in-app paid events | SaaS + transaction commission | Do not charge a percentage on membership revenue outside Bud |
| Coach Pro | KSh 1,500/month | Recurring SaaS | Offer a low-friction verified launch cohort |
| Booking/programme fee | 10% of completed paid booking/digital programme GMV | Net commission; payment fees deducted from gross margin | Clear refund, cancellation and payout policies |
| Bud Plus | KSh 300/month or KSh 2,990/year | Subscription | Include tangible features/benefits; no "unlimited currency" promise |
| Workplace | KSh 150–300/eligible employee/month, annual commitment | Contracted recurring revenue | Report participation aggregates only; explicit employee opt-in |
| Curated marketplace | 8–15% of completed GMV | Net commission or affiliate fee | Start with digital goods; vet physical merchants and claims |

### 9.3 Pricing architecture (H2/H3 — Pan-Africa and Global)

Country entities localise pricing to local rails and willingness-to-pay using the same structure (SaaS tiers, commission, Plus, workplace). Indicative anchors: Nigeria (₦), South Africa (R), Ghana (GH₵). Global partner-tier pricing is set per region and gated on local cost-of-sale review. Bud does not apply Kenya prices elsewhere; it applies the Kenya *structure*.

### 9.4 Payment and wallet design

The existing artifacts concept is creatively aligned to fitness, but a purchasable balance that can be transferred, used widely and withdrawn may trigger payment, stored-value, consumer-protection, AML/KYC, tax and accounting obligations—and makes revenue recognition materially different from cash collection.

**Recommended launch design:** accept M-PESA/cards directly in KSh (and local rails per country); use non-transferable, non-redeemable "Rep Points" only as free loyalty rewards; settle coach/gym earnings from completed KSh transactions through a licensed payment partner. Any stored balance is a restricted, non-cash voucher with explicit expiry/refund terms only after specialist advice. The Central Bank of Kenya and payments counsel confirm the final structure before release; each new country repeats this review.

---

## 10. Go-to-market plan

### 10.1 Phase 0 — validation (0–3 months)

Recruit 10 design partners (5 gyms/studios, ~20 coaches, 3–5 community leaders). Run a concierge-assisted pilot in two Nairobi neighbourhood clusters. Success is evidence that members form connections and return to activities—not a press launch.

Deliver a partner onboarding kit: data-import template, branded community setup, staff training, event calendar, safety/moderation contact, 30-day activation campaign. Partner QR join flow at reception and classes.

### 10.2 Phase 1 — repeatable cluster (3–9 months)

Add 30 paying partners once 60% of pilots meet the activation threshold. Build ambassador/referral loops around pairs and small groups, creator-led "starter cohorts," university/office partnerships and coach bundles. Use paid acquisition sparingly; measure activation, not installs.

### 10.3 Phase 2 — city/country expansion (9–24 months)

Expand only to cities where at least five anchor partners launch together. Add workplace pilots through existing gym/coach relationships. Localise payment/support before entering another country.

### 10.4 Phase 3 — Pan-Africa (years 3–5)

Country-by-country replication: five+ anchor partners, local entity, local compliance review, local pricing. Prioritise Nigeria and South Africa, then Ghana and others, gated on the Kenya playbook's evidence.

### 10.5 Phase 4 — Global (years 5–8)

Export the partner-operating layer to selected regions through partner-led density and regional partnerships; never consumer-app-land in a saturated market without a density wedge.

### 10.6 North-star metric and operating KPIs

**North-star metric:** weekly active members who complete a meaningful activity with a buddy, group or verified partner (WAAP).

| Area | Metric | Initial target to validate |
|---|---:|---:|
| Activation | New users with 2 buddies + 1 planned activity in 14 days | ≥35% |
| Engagement | WAAP / MAU | ≥30% |
| Retention | Week-4 retained activated members | ≥35% |
| Partner value | Partner members active monthly | ≥25% by month 3 |
| Supply quality | Completed booking rate | ≥90% |
| Unit economics | Blended 90-day contribution margin after acquisition | Positive by month 12 |
| Safety | Critical reports actioned within 24 hours | ≥95% |

Targets are hypotheses and are replaced by cohort data after the pilot.

---

## 11. Operations, trust, compliance and risk

### 11.1 Operating model

See §3.2 for function-level accountability. Two additional operational commitments underpin all horizons:

- **Partner success is a service, not a support ticket.** Onboarding, training, activation and retention dashboards are how Bud converts free pilots into paying partners.
- **Safety is an operating budget line, not a feature.** Moderation, verification, incidents and disputes are funded and staffed from day one.

### 11.2 Compliance requirements

Bud processes profile, location, behavioural and potentially health-related information. Kenya's Data Protection Act requires a lawful basis for processing; health data receives special treatment and may only be processed under specified conditions, including by/under the responsibility of a health-care provider or a person bound by professional secrecy. [Kenya Data Protection Act](https://new.kenyalaw.org/akn/ke/act/2019/24/eng%402019-11-15) The ODPC has issued health-data guidance. [ODPC guidance](https://www.odpc.go.ke/wp-content/uploads/2024/02/ODPC-Guidance-Note-on-Processing-of-Health-Data.pdf)

Before launch, obtain Kenyan legal advice and implement: data mapping; documented lawful bases and granular consent; a data-protection impact assessment; processor/vendor contracts and cross-border transfer controls; retention/deletion schedules; access/export/deletion flows; incident response; role-based controls; encryption and audit logging. Confirm whether data controller/processor registration, a data protection officer and further health-sector obligations apply.

Each H2/H3 country repeats a localised compliance workstream (e.g., Nigeria NDPR/NITDA, South Africa POPIA, Ghana Data Protection Act).

Professional verification needs a local registry/credential process, an explicit scope-of-practice policy and indemnity/terms review. Practitioner content is labelled education, not individual medical advice, unless delivered within an approved professional relationship. AI output carries limitations, allows correction/escalation and is never the sole basis for health or safety decisions.

### 11.3 Top risks and mitigations

| Risk | Why it matters | Mitigation |
|---|---|---|
| Marketplace cold start | Members need activity and supply at the same time | Launch dense partner clusters; do not open every category nationwide |
| Safety/harassment | Offline meetups, DMs and live video increase harm exposure | Mutual messaging, blocking/reporting, verified partners, moderation SLAs, emergency escalation guidance |
| Payment/stored-value regulation | Wallet/cash-out can be regulated and creates settlement risk | Direct local-currency payments first; licensed partners; legal review before wallet release |
| Medical misinformation | Health claims can harm users and damage trust | Verified credentials, clear scopes, review pathways, restrictive content policy |
| Unit economics of video/AI | Live/video and model calls can outpace early revenue | Cap/price premium live features, recording retention limits, usage monitoring, fallback paths |
| Partner churn | Gyms retain familiar WhatsApp/spreadsheet processes | Fast onboarding, measurable retention dashboard, human partner support, month-to-month early contracts |
| Data breach/reputation | The platform holds sensitive relationships and health-adjacent data | Minimise data, secure defaults, testing, incident plan, vendor control |
| Regulatory divergence across countries | Compliance is not one-size-fits-all in Pan-Africa | Country entities, local legal review as a launch gate, shared group playbooks |

---

## 12. Financial plan

### 12.1 Planning assumptions

This is a conservative operating model, not a prediction. It assumes a partner-led Kenya launch, direct local-currency payments, no advertising revenue and no cash-out wallet. Revenue is net of refunds but **before** payment processing cost. GMV is not revenue. Amounts are rounded, exclude VAT/tax treatment and need finance review.

### 12.2 Horizon 1 (Kenya, years 1–3) — planning inputs

| Input | Year 1 | Year 2 | Year 3 |
|---|---:|---:|---:|
| End-of-year paying gym/studio partners | 20 | 70 | 180 |
| End-of-year Coach Pro accounts | 80 | 250 | 650 |
| End-of-year MAU | 6,000 | 24,000 | 75,000 |
| Member Plus conversion (average MAU) | 3% | 5% | 7% |
| Completed bookings/programme GMV | KSh 7.0m | KSh 30.0m | KSh 85.0m |
| Transaction take rate | 10% | 10% | 10% |

The model intentionally assumes a smaller launch than earlier internal aspirational estimates. It prioritises density sufficient to observe retention and partner ROI before pursuing scale.

### 12.3 Horizon 1 — illustrative P&L (KSh millions)

| KSh m | Year 1 | Year 2 | Year 3 |
|---|---:|---:|---:|
| Partner SaaS (gyms + coaches) | 1.9 | 8.3 | 23.6 |
| Member Plus subscriptions | 0.3 | 2.2 | 8.8 |
| Booking/programme commissions | 0.7 | 3.0 | 8.5 |
| Workplace and curated commerce | 0.0 | 1.5 | 6.0 |
| **Net revenue** | **2.9** | **15.0** | **46.9** |
| Payment, support and service delivery | (0.6) | (2.7) | (7.5) |
| **Gross profit** | **2.3** | **12.3** | **39.4** |
| Team (lean core + contractors) | (14.0) | (21.0) | (32.0) |
| Cloud/video/AI/security | (2.4) | (4.2) | (7.0) |
| Sales, partner success and marketing | (3.0) | (6.0) | (11.0) |
| Legal, compliance and G&A | (2.1) | (3.0) | (4.2) |
| **Operating result** | **(19.2)** | **(21.9)** | **(14.8)** |

The table does not claim break-even in three years—a purposeful result: a marketplace/community business should not hide the cost of partner operations, safe moderation, payment support and reliable live infrastructure. The base case needs approximately **KSh 41m** of operating funding across the first 24 months plus a contingency buffer; the exact raise follows a monthly cash-flow model, founder compensation policy and vendor quotes.

### 12.4 Horizon 2 (Pan-Africa, years 4–5) — indicative

The Pan-African horizon is indicative and gated on H1 evidence. Assumes the Kenya model replicated in 3–4 countries (Nigeria, South Africa, Ghana, +1) at 30–50% of Kenya's relative partner density:

| USD m (indicative) | Year 4 | Year 5 |
|---|---:|---:|
| Net revenue (all countries) | 1.8 | 5.5 |
| Gross profit | 1.2 | 3.7 |
| Country operating costs (teams, compliance, marketing) | (4.2) | (6.5) |
| **Operating result** | **(3.0)** | **(2.8)** |

Country funding is separately ring-fenced; the group does not cross-subsidise unproven markets from the Kenya entity beyond approved pilots.

### 12.5 Horizon 3 (Global, years 6–8) — direction of travel

Global entry is selected and partner-led. The model targets positive contribution margin before entering new regions and uses the Kenya/Pan-Africa proof as the platform asset. Directional targets: 5–8 countries total, with the operating layer contributing the majority of recurring revenue and local entities carrying their own cost structures.

### 12.6 Path to break-even

Illustratively, at a 65% gross margin and KSh 60m annual operating cost, Bud needs roughly KSh **92m annual revenue** to cover operating costs. The path is not more free users; it is increasing paying-partner density, coach programme GMV, Plus conversion and workplace contracts while maintaining service quality. Bud does not accelerate paid acquisition until a 90-day activated cohort has positive contribution margin.

### 12.7 Financial controls

- Separate customer funds/partner settlement from company operating cash.
- Reconcile payment-provider settlements, completed services, refunds and partner payouts daily.
- Recognise commission only on completed, non-refunded services; defer subscription revenue across the service period.
- Maintain a refund/dispute reserve; do not use a customer wallet balance as operating capital.
- Track CAC by channel, partner onboarding cost, contribution margin by service, partner retention and cohort LTV monthly.

---

## 13. Product, service and commercial roadmap

| Period | Product/service outcome | Commercial gate |
|---|---|---|
| Months 0–3 | Secure onboarding, Buddy Up, groups, events, selected gym/coach pages, M-PESA/card payments, moderation operations | 10 design partners live; clear incident/refund processes |
| Months 3–6 | Partner dashboard, booking, digital programmes, referrals, basic partner insights | ≥35% activation and ≥25% partner member MAU in pilots |
| Months 6–12 | Coach Pro, Gym Growth, repeat cohorts, selective paid live sessions, Plus bundle | 30 paying partners; verified retention/ROI case studies |
| Year 2 | Workplace pilots, curated local offers, wearables/integrations, deeper localisation | Positive 90-day contribution margin in primary cluster |
| Year 3 | Multi-location partner tools, API/integrations, second Kenyan city cluster, Pan-African readiness dossier | Five anchor partners committed in each new city/country |
| Years 4–5 | Nigeria + South Africa entities live; Ghana +1 pilot; country-localised payments/support | Per-country legal/payments review and anchor commitment; positive contribution margin in primary cluster |
| Years 6–8 | Global partner-operating layer, regional partnerships, API ecosystem | Positive contribution margin before region entry; local compliance complete |

AI serves operational and customer outcomes, not a feature catalogue. Early uses with the best fit: safety triage, discovery/ranking with human oversight, and clearly bounded meal/workout suggestions. Form analysis, medical-adjacent recommendations and automated coaching remain controlled pilots with accuracy, fairness, consent and escalation criteria.

---

## 14. Decisions requested and next actions

1. Adopt the Nairobi partner-community beachhead and the narrower launch scope (§4.2).
2. Approve direct local-currency payments plus non-cash loyalty points; pause cash-out/transferable artifacts pending legal and payment-provider review (§9.4).
3. Fund a 90-day design-partner pilot and measure the activation/retention gates in §10.6.
4. Complete a Kenya privacy, payments, consumer, professional-verification and tax workstream before accepting money or health-related submissions (§11.2).
5. Convert this document's assumptions into a monthly operating model after partner price discovery and vendor quotations (§12).
6. Stand up the Pan-African readiness track (entity selection, market dossiers) in year 3, gated on H1 evidence (§3.3, §7.2).

---

## 15. Sources and methodology

This plan combines repository inspection with desk research completed on 6 August 2026. External figures are used as context, not as a substitute for primary customer research. Core sources:

- World Health Organization, [physical activity update, 2024](https://www.who.int/news/item/26-06-2024-nearly-1.8-billion-adults-at-risk-of-disease-from-not-doing-enough-physical-activity).
- Communications Authority of Kenya, [mobile, internet and technology services update](https://www.ca.go.ke/mobile-internet-and-tech-services-surge-kenya-digital-shift-accelerates).
- Safaricom, [FY2025 audited-results release](https://www.safaricom.co.ke/images/Downloads/FY25-Press-Release_May-9-2025.pdf).
- Kenya Law, [Data Protection Act, 2019](https://new.kenyalaw.org/akn/ke/act/2019/24/eng%402019-11-15), and the Office of the Data Protection Commissioner, [health-data processing guidance](https://www.odpc.go.ke/wp-content/uploads/2024/02/ODPC-Guidance-Note-on-Processing-of-Health-Data.pdf).
- Strava, [Google Play listing](https://play.google.com/store/apps/details?hl=en_US&id=com.strava); ClassPass, [credits explanation](https://help.classpass.com/hc/en-us/articles/360002359832-What-are-credits); Trainerize, [2025 personal-training industry report](https://resources.trainerize.com/hubfs/State%20of%20the%20Personal%20Training%20Industry%20Report%202025.pdf).

Pan-African and global market claims are directional planning inputs pending country-level validation; they are explicitly not presented as measured market facts.
