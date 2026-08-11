# Bud (BuddyUp) Business Plan

**Prepared:** 6 August 2026  
**Planning horizon:** Kenya launch, 36 months  
**Working currency:** Kenya shilling (KSh); USD shown only where useful.  
**Document status:** Operating plan and investment discussion draft—not a forecast, legal opinion, or medical claim.

## 1. Executive summary

Bud is the short, customer-facing name for the BuddyUp mobile-first health and fitness community platform. It is designed to turn the intention to exercise into repeat behaviour through a mutual **Buddy Up** relationship, gym communities, verified professionals, live/group training, booking and relevant commerce. Its defining customer promise is simple: *find someone to train with, a trusted coach to guide you, and a community that notices when you disappear.*

The product is already materially more capable than a concept: the codebase contains web and Flutter clients, a Django/DRF platform, real-time messaging, live-video infrastructure, marketplace, scheduling/escrow, moderation, verification, payments integrations, a wallet model and AI services. The launch should nevertheless be deliberately narrower than the system. The recommended beachhead is **Nairobi gym communities and independent coaches**, with a consumer-led free community product and a paid partner operating layer.

The recommended first commercial offer is not “every fitness service in one app.” It is a three-sided network:

1. Members use BuddyUp free to form accountable relationships, find nearby communities and join sessions.
2. Gyms and coaches use it to retain members, schedule and sell classes/programmes, and manage a community.
3. BuddyUp earns recurring SaaS fees and transaction commissions only after it demonstrably improves participation and retention.

This sequencing gives the business a credible service ladder. The social graph and attendance data make coach packages, gym operating tools, employer wellness, local commerce and carefully bounded personalised wellness features more valuable over time. They are adjacent extensions of an existing trust, identity, community and payments foundation—not unrelated features.

**Three decisions determine viability:**

- Prove a weekly accountability loop before spending heavily on content or AI: new member → buddy match → scheduled session → attendance → encouragement → repeat.
- Treat regulated health data, professional advice and stored-value/payment flows as controlled services from day one. Do not sell “unlimited artifacts” or permit cash-like transfer/redemption until specialist Kenyan payments and legal advice confirms the structure.
- Win concentrated communities (10–20 launch partners) before broad national acquisition. A small number of active clusters is more valuable than a large number of inactive installs.

## 2. Business definition

### Mission and customer problem

BuddyUp exists to make healthy activity easier to start and harder to abandon. Fitness consumers usually do not lack videos, apps or information; they lack a dependable social commitment, local access and an affordable path to a qualified coach. Gym operators and coaches, meanwhile, struggle to convert a membership or an enquiry into a persistent, engaged community.

The public-health need is material: WHO reported that nearly **1.8 billion adults (31%)** did not meet recommended physical-activity levels in 2022. [WHO, 2024](https://www.who.int/news/item/26-06-2024-nearly-1.8-billion-adults-at-risk-of-disease-from-not-doing-enough-physical-activity)

### Positioning

**For urban, mobile-first adults who want consistency, BuddyUp is the fitness community and partner platform that combines mutual accountability, trusted local services and participation-led commerce.** It differs from a tracker by starting with the relationship; from a content network by driving a planned activity; and from a class aggregator by giving each gym and coach a persistent community.

BuddyUp is not a healthcare provider, insurer, diagnostic device, medical-record system or a general social network. It should facilitate discovery and access to appropriately verified professionals, while advice, diagnosis, prescriptions and clinical records remain within professional and legal boundaries.

### The business structure

```text
BuddyUp Ltd. (platform operator)
│
├── Consumer community        Free social/accountability experience
├── Partner platform          Gym, coach and practitioner tools
├── Marketplace & bookings    Intermediated transactions; controlled payouts
├── Trust, safety & data      Identity, moderation, consent, risk operations
└── Platform & intelligence   Payments, messaging, video, analytics, APIs
```

The company should be organised around these five operating capabilities, not around individual app screens. Product and engineering provide the shared platform; Partner Success owns supply quality and activation; Trust & Safety owns eligibility, moderation and disputes; Finance/Operations owns settlement and reconciliation; Growth owns cluster activation.

## 3. System and service-scope audit

### What the current system supports

Repository review shows a React/PWA frontend and Flutter application supported by Django 5/DRF, PostgreSQL, Redis, Celery and ASGI/WebSockets. Production configuration includes self-hosted LiveKit, recording and object storage, plus payment, messaging and notification integrations. The service domains below are present in the application architecture.

| Service domain | Existing scope | Commercial role | Launch disposition |
|---|---|---|---|
| Identity and profiles | Age gate, OTP, sessions, roles, privacy, public profiles and verification states | Trust foundation | Launch core |
| Buddy accountability | Mutual buddy requests, shared goals/streaks, pings and DMs | Primary retention loop | Launch core |
| Community and feed | Fitness posts, reactions, local/discovery feeds, group features | Member engagement and creator supply | Launch core, tightly moderated |
| Gyms | Community pages, roles, member management, schedules, subscriptions and analytics concepts | B2B2C distribution and retention | Launch core for selected partners |
| Coaches and practitioners | Profiles, availability, booking, programmes, reviews and consultation workflow | High-value supply and transaction revenue | Coaches at launch; practitioners only after compliance controls |
| Live sessions | Group/live rooms, chat, co-hosting, scheduling, replay recording | Habit formation and paid experience | Pilot with selected partners |
| Marketplace | Programmes, meal plans, equipment/supplement listings and cart | Commerce take rate | Digital programmes first; physical goods later |
| Wallet/artifacts | Token denominations, gifting, fees, balances and withdrawal concepts | Potential monetisation/engagement mechanic | Redesign before public launch |
| AI features | Food recognition, meal-plan personalisation, moderation, ranking, form/health insights | Personalisation and operations support | Keep human-reviewed/clearly non-clinical; stage after core loop |

### Scope boundary and priority

The platform contains more surface area than an early operating company can support. The initial scope should be: community onboarding, buddy matching, partner communities, events/sessions, coach bookings, local payment collection and a small digital-programme catalogue. Everything else is a controlled pilot.

The following must **not** be marketed as launch promises until validated: medical consultations, prescription sales, diagnostic or injury claims, broad supplement marketplace, AI coaching/form diagnosis, cash-out wallet functionality, anonymous interactions in private communities, and a large-scale open live-streaming network. These are risk, quality or liquidity multipliers.

### Service scope by customer

| Customer | Core job | Included service | Paid expansion |
|---|---|---|---|
| Member | Stay consistent | Profile, buddies, groups, discovery, check-ins and selected free events | BuddyUp Plus: deeper plans, session credits/priority, insights and partner benefits |
| Coach | Find and retain clients | Verified profile, availability, booking, programme delivery and client chat | Coach Pro: CRM-lite, recurring plans, analytics, branded offers and lower transaction fee |
| Gym/studio | Retain members and fill classes | Branded community, schedule, member communication and check-in/event tools | Gym Growth: payments, multi-location controls, retention dashboard, campaigns and integrations |
| Employer | Support workforce wellbeing | Curated activity challenges and partner access | Workplace: administrator controls, aggregate reporting and wellbeing campaigns—never employee health surveillance |
| Approved merchant | Reach relevant buyers | Curated listing and fulfilment rules | Partner campaigns, affiliate reporting and bundles |

## 4. Why the service stack compounds into packages

BuddyUp’s defensibility is the compounding connection between identity, social commitment, participation evidence and local supply. A user who joins a gym community, confirms two buddies and attends a live session has created useful context for every later offer—without needing to turn personal data into an advertising product.

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

The expansion must respect user choice: social and activity data may improve in-product recommendations only under transparent consent; it must not be sold, shared with employers, or used to infer health status.

### Package roadmap

| Package | Customer and timing | What it packages | Why the foundation matters |
|---|---|---|---|
| **BuddyUp Community** | Members, launch | Buddy relationships, group challenges, events and basic discovery | Establishes the activity graph and repeat habit |
| **Coach Launch / Pro** | Coaches, months 3–9 | Booking, payments, programmes, client community and analytics | Uses verified identity, chat and attendance as a lightweight operating system |
| **Gym Core / Growth** | Gyms, months 3–12 | Branded community, class/events, check-in, messaging, member offers and retention insights | Converts a venue into an always-on member relationship |
| **Digital Transformation Bundle** | Members + coaches, months 6–12 | Structured programme, scheduled group sessions, coach check-ins and accountability cohort | Bundles services already proven separately into a higher-LTV outcome product |
| **Workplace Wellness** | Employers, year 2 | Opt-in teams, challenges, partner benefits and anonymised aggregate engagement reporting | Reuses groups, partners and event mechanics while preserving employee privacy |
| **Local wellness benefits** | Partners, year 2 | Curated goods, nutrition/physio referrals and member discounts | Builds only after verified supply, fulfilment rules and clear consumer trust |
| **Platform/API integrations** | Larger gyms and ecosystem partners, year 3 | Membership/check-in and wearable integrations | Requires stable identity, consent, partner data model and support capability |

## 5. Market analysis

### Beachhead: Kenya, beginning in Nairobi

Kenya is a sensible beachhead because the core behavioural moments—messaging, mobile payments and community coordination—already happen on the phone. The Communications Authority reported **83.5% smartphone penetration by June 2025**, and 76.16 million SIM subscriptions in the March 2025 quarter. [Communications Authority of Kenya](https://www.ca.go.ke/mobile-internet-and-tech-services-surge-kenya-digital-shift-accelerates) These are distribution enablers, not proof of willingness to pay; price, connectivity and trust still shape adoption.

Payments must be locally native. Safaricom reported KSh **38.29 trillion** in M-PESA transaction value for FY2025 and M-PESA revenue growth of 15.2%, evidence that small, routine digital transactions are familiar to the market. [Safaricom FY2025 results](https://www.safaricom.co.ke/images/Downloads/FY25-Press-Release_May-9-2025.pdf) BuddyUp should therefore lead with M-PESA and card flows; it should not require a proprietary currency to create an additional step for users.

The initial target is not “all Kenyans.” It is smartphone-owning adults in Nairobi (then Mombasa, Kisumu and selected university/office clusters) who already show an exercise or wellness intent but need accountability or better access. The supply wedge is independent coaches, boutique studios, gyms with active WhatsApp communities, run clubs and fitness creators. Partners provide concentrated acquisition and credible local content.

### Segmentation and initial beachhead

| Segment | Need and behaviour | Entry offer | Monetisation potential |
|---|---|---|---|
| Accountability seekers (18+) | Wants consistency, often trains alone | Buddy match, nearby small groups and weekly activity commitments | Plus conversion, events, programmes |
| Gym members | Pays for access but needs community and attendance motivation | Gym community, schedules, check-ins and buddy cohorts | Gym SaaS, renewals, partner offers |
| Independent coaches | Needs leads, payments and client follow-through | Verification, booking and programme delivery | Subscription + booking commission |
| Fitness communities | Needs coordination and safe membership | Group spaces, events and volunteer/moderation tools | Partner plans, sponsored challenges |
| Employers (later) | Needs a credible benefit without clinical-data exposure | Opt-in challenges and partner access | Per-eligible-member contract |

### Market sizing approach

Public data does not establish a reliable Kenya-specific “fitness-app TAM”; presenting a large purchased-market number would create false precision. Instead, BuddyUp should use a bottom-up, serviceable-market model tied to attainable partners and active users.

**Illustrative Nairobi serviceable market (to validate):** 150 partner gyms/studios × 300 reachable members = 45,000 reachable members; 1,000 verified coaches/creators × 30 reachable prospects per year = 30,000 additional prospects. These are planning inputs, not measured market facts. At 25% activated monthly participation, the first operating market is approximately 18,750 MAU. Expanding to four Kenyan cities and partner categories can multiply this only after partner conversion, cohort retention and payment acceptance are observed.

The governing market metric is therefore **active partner-community members**, not registrations. Each quarter, replace these inputs with CRM partner data, activation cohorts and payment data.

### Demand and buyer insights to test

- Does a member return at least twice in the first 14 days when they make two confirmed buddy connections?
- Do partners see a measurable lift in class attendance, membership renewal intent or coach enquiry conversion against a comparable baseline?
- Will a user pay KSh 300–600/month for a concrete bundle of accountability and benefits, rather than a generic “premium” badge?
- What price and cancellation policy lets a coach sell a reliable online/hybrid programme?
- Which locally relevant activities (strength, running, dance/HIIT, football, yoga, rehabilitation) produce the densest repeat communities?

## 6. Competitive audit

Competition is fragmented by job-to-be-done. BuddyUp must avoid claiming that no competitor has community, tracking or video. Its opportunity is to integrate local partner community, mutual accountability and commerce in a Kenya-first operating model.

### Global and category competitors

| Competitor/category | Strongest customer value | Gap BuddyUp can address | Strategic response |
|---|---|---|---|
| Strava | Deep activity tracking, global community and device ecosystem; its listing says 180M+ active people | Strong outdoor/endurance brand; not a Kenya-local gym operating system | Integrate/share where useful; own accountability cohorts and local partner workflows, not GPS-tracking parity. [Strava listing](https://play.google.com/store/apps/details?hl=en_US&id=com.strava) |
| Nike Training Club / FitOn / YouTube fitness | Large, polished on-demand content libraries | Content abundance does not guarantee local relationships or trusted booking | Curate partner-led programmes; do not fund a content-volume war |
| Peloton | Premium instruction, hardware and subscription experience | Expensive, hardware-led model is mismatched to a broad Kenyan beachhead | Offer device-agnostic group accountability and local prices |
| ClassPass | Discovery and credit-based booking across facilities | Transactional demand marketplace, not persistent gym community; credits are only for eligible bookings | Give partners community and retention tools; introduce cross-partner discovery only where supply economics work. [ClassPass credits](https://help.classpass.com/hc/en-us/articles/360002359832-What-are-credits) |
| Trainerize / TrueCoach | Coach programming and client-management workflows | Strong B2B coaching tools, but not a local social acquisition/community network | Win with discovery + community; partner/integrate rather than recreate mature back-office depth early. [Trainerize 2025 report](https://resources.trainerize.com/hubfs/State%20of%20the%20Personal%20Training%20Industry%20Report%202025.pdf) |
| Instagram/TikTok/WhatsApp | Discovery, creators and habit-forming communication | No fitness-specific trust, attendance, scheduling or controlled transactions | Use them as acquisition channels; offer the action layer they lack |

### Local competition and substitutes

The immediate local competitors are often not branded apps. They are gym front desks, WhatsApp groups, Instagram coach pages, M-PESA till payments, spreadsheets and informal referrals. Their advantages are familiarity and zero switching cost. BuddyUp must import member data/events quickly, work well on low-to-mid-range phones, make M-PESA payment simple, and show a gym an early retention result. International platforms and generic booking tools remain relevant indirect competitors as they enter or acquire local supply.

### Competitive advantage—earned, not assumed

Potential moats are: (1) a dense, consented local buddy/community graph; (2) verified, well-rated supply; (3) partner operating data that proves retention; (4) payment/reconciliation and dispute operations; and (5) locally relevant service design. None is a moat at launch. It becomes one only when the platform reaches repeated participation and partners would lose a meaningful community workflow by leaving.

## 7. Revenue model and pricing architecture

### Recommended revenue sequence

1. **Partner SaaS** creates predictable gross profit and aligns BuddyUp with partner retention.
2. **Booking/programme commissions** monetise transactions where BuddyUp provides discovery, payment and support.
3. **Member Plus** sells a clear outcome bundle after the free loop is valuable.
4. **Curated commerce and workplace contracts** follow verified supply and operational capability.

Avoid advertising as an early dependency. It conflicts with the trust proposition and makes the value of intimate health/community data ambiguous.

| Revenue stream | Indicative Kenya pricing | Recognition and economics | Guardrail |
|---|---:|---|---|
| Gym Core | KSh 4,000/month/location | Recurring SaaS | Pilot free for 60–90 days only against activation commitments |
| Gym Growth | KSh 12,000/month/location + 5% on in-app paid events | SaaS + transaction commission | Do not charge a percentage on membership revenue outside BuddyUp |
| Coach Pro | KSh 1,500/month | Recurring SaaS | Offer a low-friction verified launch cohort |
| Booking/programme fee | 10% of completed paid booking/digital programme GMV | Net commission; payment fees deducted from gross margin | Clear refund, cancellation and payout policies |
| BuddyUp Plus | KSh 300/month or KSh 2,990/year | Subscription | Include tangible features/benefits; no “unlimited currency” promise |
| Workplace | KSh 150–300/eligible employee/month, annual commitment | Contracted recurring revenue | Report participation aggregates only; explicit employee opt-in |
| Curated marketplace | 8–15% of completed GMV | Net commission or affiliate fee | Start with digital goods; vet physical merchants and claims |

### Payment and wallet design

The existing artifacts concept is creatively aligned to fitness. But a purchasable balance that can be transferred, used widely and withdrawn may trigger payment, stored-value, consumer-protection, AML/KYC, tax and accounting obligations. It also makes revenue recognition materially different from cash collection.

**Recommended launch design:** accept M-PESA/cards directly in KSh; use non-transferable, non-redeemable “Rep Points” only as free loyalty rewards; settle coach/gym earnings from completed KSh transactions through a licensed payment partner. Any stored balance should be a restricted, non-cash voucher with explicit expiry/refund terms only after specialist advice. This preserves gamification while removing an avoidable regulatory and liquidity risk. The Central Bank of Kenya and payments counsel should confirm the final structure before release.

## 8. Go-to-market plan

### Phase 0 — validation (0–3 months)

Recruit 10 design partners: 5 gyms/studios, 20 coaches and 3–5 community leaders. Run a concierge-assisted pilot in two Nairobi neighbourhood clusters. Success is not a press launch; it is evidence that members form connections and return to activities.

Deliver a partner onboarding kit: data-import template, branded community setup, staff training, event calendar, safety/moderation contact and 30-day activation campaign. Let a partner use a QR join flow at reception and at classes.

### Phase 1 — repeatable cluster (3–9 months)

Add 30 paying partners only once 60% of pilots meet the activation threshold. Build ambassador/referral loops around pairs and small groups, creator-led “starter cohorts,” university/office partnerships and coach bundles. Use paid digital acquisition sparingly and measure activation, not installs.

### Phase 2 — city/country expansion (9–24 months)

Expand only to cities where at least five anchor partners can launch together. Add workplace pilots through existing gym/coach relationships. Localise payment/support before entering another country; each country needs its own tax, payments, consumer and data-protection review.

### North-star metric and operating KPIs

**North-star metric:** weekly active members who complete a meaningful activity with a buddy, group or verified partner (WAAP).

| Area | Metric | Initial target to validate |
|---|---|---:|
| Activation | New users with 2 buddies + 1 planned activity in 14 days | ≥35% |
| Engagement | WAAP / MAU | ≥30% |
| Retention | Week-4 retained activated members | ≥35% |
| Partner value | Partner members active monthly | ≥25% by month 3 |
| Supply quality | Completed booking rate | ≥90% |
| Unit economics | Blended 90-day contribution margin after acquisition | Positive by month 12 |
| Safety | Critical reports actioned within 24 hours | ≥95% |

Targets are hypotheses and must be replaced by cohort data after the pilot.

## 9. Operations, trust, compliance and risk

### Operating model

| Function | Launch accountability |
|---|---|
| Product/engineering | Reliability, performance on common Android devices, privacy-by-design, release quality |
| Partner success | Vetting, onboarding, training, supply quality, partner adoption and renewal |
| Trust & safety | Age assurance, verification, moderation, incidents, complaints and appeals |
| Finance/operations | Payment reconciliation, refunds, payouts, tax records and dispute controls |
| Growth/community | Cluster activation, ambassadors, programming and lifecycle messaging |

### Compliance requirements

BuddyUp processes profile, location, behavioural and potentially health-related information. Kenya’s Data Protection Act requires a lawful basis for processing; health data receives special treatment and may only be processed under specified conditions, including by/under the responsibility of a health-care provider or a person bound by professional secrecy. [Kenya Data Protection Act](https://new.kenyalaw.org/akn/ke/act/2019/24/eng%402019-11-15) The ODPC has also issued health-data guidance. [ODPC guidance](https://www.odpc.go.ke/wp-content/uploads/2024/02/ODPC-Guidance-Note-on-Processing-of-Health-Data.pdf)

Before launch, obtain Kenyan legal advice and implement: data mapping; documented lawful bases and granular consent; a data-protection impact assessment; processor/vendor contracts and cross-border transfer controls; retention/deletion schedules; access/export/deletion flows; incident response; role-based controls; encryption and audit logging. Confirm whether data controller/processor registration, a data protection officer and any further health-sector obligations apply.

Professional verification needs a local registry/credential process, an explicit scope-of-practice policy and indemnity/terms review. Practitioner content must be labelled education, not individual medical advice, unless delivered within an approved professional relationship. AI output must carry appropriate limitations, allow correction/escalation and never be the sole basis for health or safety decisions.

### Top risks and mitigations

| Risk | Why it matters | Mitigation |
|---|---|---|
| Marketplace cold start | Members need activity and supply at the same time | Launch dense partner clusters; do not open every category nationwide |
| Safety/harassment | Offline meetups, DMs and live video increase harm exposure | Mutual messaging, blocking/reporting, verified partners, moderation SLAs and emergency escalation guidance |
| Payment/stored-value regulation | Wallet/cash-out can be regulated and creates settlement risk | Direct KSh payments first; licensed partners; legal review before wallet release |
| Medical misinformation | Health claims can harm users and damage trust | Verified credentials, clear scopes, review pathways and restrictive content policy |
| Unit economics of video/AI | Live/video and model calls can outpace early revenue | Cap/price premium live features, recording retention limits, usage monitoring and fallback paths |
| Partner churn | Gyms will retain familiar WhatsApp/spreadsheet processes | Fast onboarding, measurable retention dashboard, human partner support and month-to-month early contracts |
| Data breach/reputation | The platform holds sensitive relationships and health-adjacent data | Minimise data, secure defaults, testing, incident plan and vendor control |

## 10. Financial plan

### Planning assumptions

This is a conservative operating model, not a prediction. It assumes a partner-led Kenya launch, direct KSh payments, no advertising revenue and no cash-out wallet. Revenue is net of refunds but **before** payment processing cost. GMV is not revenue. Amounts are rounded, exclude VAT/tax treatment and need finance review.

| Input | Year 1 | Year 2 | Year 3 |
|---|---:|---:|---:|
| End-of-year paying gym/studio partners | 20 | 70 | 180 |
| End-of-year Coach Pro accounts | 80 | 250 | 650 |
| End-of-year MAU | 6,000 | 24,000 | 75,000 |
| Member Plus conversion (average MAU) | 3% | 5% | 7% |
| Completed bookings/programme GMV | KSh 7.0m | KSh 30.0m | KSh 85.0m |
| Transaction take rate | 10% | 10% | 10% |

The model intentionally assumes a smaller launch than earlier internal aspirational estimates. It prioritises enough density to observe retention and partner ROI before pursuing scale.

### Illustrative profit-and-loss view (KSh millions)

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

The table does not claim break-even in three years. That is a purposeful result: a marketplace/community business should not hide the cost of partner operations, safe moderation, payment support and reliable live infrastructure. The base case needs approximately **KSh 41m** of operating funding across the first 24 months plus a contingency buffer; the exact raise should follow a monthly cash-flow model, founder compensation policy and vendor quotes.

### Path to break-even

Illustratively, at a 65% gross margin and KSh 60m annual operating cost, BuddyUp needs roughly KSh **92m annual revenue** to cover operating costs. The path is not simply more free users. It is increasing paying-partner density, coach programme GMV, Plus conversion and workplace contracts while maintaining service quality. Do not accelerate paid acquisition until a 90-day activated cohort has positive contribution margin.

### Financial controls

- Separate customer funds/partner settlement from company operating cash.
- Reconcile payment-provider settlements, completed services, refunds and partner payouts daily.
- Recognise commission only on completed, non-refunded services; defer subscription revenue across the service period.
- Maintain a refund/dispute reserve; do not use a customer wallet balance as operating capital.
- Track CAC by channel, partner onboarding cost, contribution margin by service, partner retention and cohort LTV monthly.

## 11. Product, service and commercial roadmap

| Period | Product/service outcome | Commercial gate |
|---|---|---|
| Months 0–3 | Secure onboarding, Buddy Up, groups, events, selected gym/coach pages, M-PESA/card payments and moderation operations | 10 design partners live; clear incident/refund processes |
| Months 3–6 | Partner dashboard, booking, digital programmes, referrals and basic partner insights | ≥35% activation and ≥25% partner member MAU in pilots |
| Months 6–12 | Coach Pro, Gym Growth, repeat cohorts, selective paid live sessions and Plus bundle | 30 paying partners; verified retention/ROI case studies |
| Year 2 | Workplace pilots, curated local offers, wearables/integrations and deeper localisation | Positive 90-day contribution margin in primary cluster |
| Year 3 | Multi-location partner tools, API/integrations and carefully selected regional expansion | Five anchor partners committed in each new city/country |

AI should serve operational and customer outcomes, not become a feature catalogue. Early uses with the best fit are safety triage, discovery/ranking with human oversight and clearly bounded meal/workout suggestions. Form analysis, medical-adjacent recommendations and automated coaching should remain controlled pilots with accuracy, fairness, consent and escalation criteria.

## 12. Decisions requested and next actions

1. Adopt the Nairobi partner-community beachhead and the narrower launch scope.
2. Approve direct KSh payments plus non-cash loyalty points; pause cash-out/transferable artifacts pending legal and payment-provider review.
3. Fund a 90-day design-partner pilot and measure the activation/retention gates in this plan.
4. Complete a Kenya privacy, payments, consumer, professional-verification and tax workstream before accepting money or health-related submissions.
5. Convert this document’s assumptions into a monthly operating model after partner price discovery and vendor quotations.

## Sources and methodology

This plan combines repository inspection with desk research completed on 6 August 2026. External figures are used as context, not as a substitute for primary customer research. Core sources are:

- World Health Organization, [physical activity update, 2024](https://www.who.int/news/item/26-06-2024-nearly-1.8-billion-adults-at-risk-of-disease-from-not-doing-enough-physical-activity).
- Communications Authority of Kenya, [mobile, internet and technology services update](https://www.ca.go.ke/mobile-internet-and-tech-services-surge-kenya-digital-shift-accelerates).
- Safaricom, [FY2025 audited-results release](https://www.safaricom.co.ke/images/Downloads/FY25-Press-Release_May-9-2025.pdf).
- Kenya Law, [Data Protection Act, 2019](https://new.kenyalaw.org/akn/ke/act/2019/24/eng%402019-11-15), and the Office of the Data Protection Commissioner, [health-data processing guidance](https://www.odpc.go.ke/wp-content/uploads/2024/02/ODPC-Guidance-Note-on-Processing-of-Health-Data.pdf).
- Strava, [Google Play listing](https://play.google.com/store/apps/details?hl=en_US&id=com.strava); ClassPass, [credits explanation](https://help.classpass.com/hc/en-us/articles/360002359832-What-are-credits); Trainerize, [2025 personal-training industry report](https://resources.trainerize.com/hubfs/State%20of%20the%20Personal%20Training%20Industry%20Report%202025.pdf).
