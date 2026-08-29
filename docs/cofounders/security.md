# Cofounder Agreement — Security

| Document owner | Review date |
|---|---|
| Peter Mbugua (CEO); incoming Security cofounder on appointment | 2026-09-30 |

**BuddyUp Ltd.** — Founding Team Heads of Terms (pre-shareholders' agreement)

| | |
|---|---|
| Candidate | [Full legal name], ID/Passport No. [●] |
| Role | Cofounder — Security Engineering & Trust |
| Proposed equity | **16%** of fully-diluted share capital at grant, subject to the vesting terms in Annex A |
| Commitment | Part-time — minimum **10 hours per week** (Clause 4) |
| Vesting | 4 years monthly, 1-year cliff (Annex A) |
| Start date | [●] |
| Reporting line | CEO / Board of BuddyUp Ltd. |

> **Status:** This is an invitation to join the founding team and a summary of proposed
> terms. It is not a shareholders' agreement, not an employment contract, and not legal
> advice. It becomes binding only when superseded by the executed Founders'
> Shareholders' Agreement (Kenyan law) that all founders will sign together.

---

## Founding team & ownership

The founding team holds 80% of BuddyUp Ltd. at incorporation, with a **20%
unallocated reserve** for future hires and the option pool. All five founder
seats hold an **equal 16%** — the YC-recommended structure — split as follows:

| Seat | Holder | Equity |
|---|---|---|
| Cofounder & CEO — Engineering | Peter Mbugua | **16%** |
| Cofounder — Security Engineering & Trust | *(this offer — [Full legal name])* | **16%** |
| Cofounder — Marketing, Sales & Partnerships | [●] | 16% |
| Cofounder — Finance, Strategy & Controller | [●] | 16% |
| Cofounder — Legal, Compliance & Research | [●] | 16% |
| Unallocated reserve (future hires / option pool) | held for unanimous founder decision | **20%** |
| **Total** | | **100%** |

The reserve is set at **20%** — the market range for an early-stage option pool —
and is created **at incorporation** so that future hires and stock options are
funded from the reserve instead of diluting founders later. Any top-up beyond 20%
requires unanimous founder consent (Annex A, clause 5). Equal equity reflects the
work done *after* the start date; the CEO's pre-founding build is acknowledged
through role and casting-vote authority, not extra equity. Percentages above are
indicative pending the Founders' Shareholders' Agreement.

All founder equity vests on identical terms (Annex A). No seat carries special
voting or economic rights beyond the shareholders' agreement.

## 1. Why this seat exists

BuddyUp's differentiator is trust: age controls, identity verification, mutual
messaging, payment integrity, moderation. Trust that gets broken once — a leaked
verification document, a drained wallet flow, a hijacked live stream — ends the
company in this market.

The stack is real and live: Django/DRF + Postgres + Redis/Celery behind nginx,
Flutter + React clients, self-hosted LiveKit media with TURN, Flutterwave/M-PESA
payment rails, JWT auth with TOTP, WebAuthn passkeys, recovery codes, device sessions,
rate-limited WebSocket consumers, Cloudinary storage with validated uploads.
Security here is not a checklist to add later; it is a system to operate daily.

## 2. Mandate

Own security end-to-end — as an engineer who ships, not a policy author:

1. **Application & platform security**
   - Own the threat model for every feature before launch (STRIDE-level thinking on
     messaging, calls, marketplace, wallets, verification documents).
   - Enforce secure defaults in CI: lint gates, dependency scanning, secret hygiene,
     migration review.
   - Run the hardening backlog: rate limits, object-level authorization audits,
     upload validation, webhook signature verification (Flutterwave et al.), session
     lifecycle, admin surface exposure.
2. **Payments & fraud**
   - Co-own reconciliation integrity with the Finance cofounder; webhook replay/
     tampering resistance; anti-double-credit locks; refund-abuse controls.
   - Define fraud rules for artifact economy abuse without turning artifacts into
     regulated stored value.
3. **Data protection engineering**
   - Jointly own breach detection/notification runbooks with the Legal cofounder;
     encryption at rest/in transit posture; verification-document handling
     (shortest-lived access, audit logs).
4. **Incident response**
   - Write and rehearse the IR plan (who calls whom in the first hour); lead the
     on-call rotation; publish post-mortems internally without blame.
5. **Assurance**
   - Quarterly internal review + annual third-party assessment when revenue allows.
   - Maintain the security section of partner/due-diligence documentation for sales
     and fundraising.

## 3. Decision rights

- **Veto (with written reasons):** any launch that processes payments, verification
  documents or minors' data without meeting the agreed security baseline.
- **Owns:** security tooling budget within plan, incident declarations,
  emergency mitigation actions (including taking a feature offline), secrets policy.
- **Joint sign-off:** new third-party processors handling user data (with Legal),
  production infrastructure changes affecting data residency.

You will be measured on shipped protections and incident outcomes — never on
bureaucracy. The veto exists so you can say "not yet" and be thanked for it.

### Deadlocks & the CEO casting vote

Each founder decides their own domain (above). For cross-domain or company-level
decisions that deadlock after genuine discussion:

1. Each position is written down with reasons and evidence (one page max).
2. A 48-hour cool-off follows; most disagreements dissolve here.
3. If not, the **CEO casts the deciding vote**, with written reasons within five
   working days.
4. The decision is recorded in writing and everyone **disagrees and commits** —
   no relitigating.
5. The CEO is recused from casting on decisions that directly affect the CEO's
   own equity, role or removal.
6. **Reserved matters** are never settled by the casting vote alone — selling or
   dissolving the company, removing or adding a cofounder, changing the equity
   split, or removing the CEO follow the Founders' Shareholders' Agreement.

Rationale and options analysis: [`README.md`](README.md) — "Decision-making & the
CEO casting vote". The mechanism becomes binding in the shareholders' agreement.

## 4. Commitment

- **Part-time founding role:** you commit a minimum of **10 hours per week** on
  average, scheduled flexibly around existing commitments. This is a
  build-the-company seat with real deliverables, not an advisory arrangement.
  You still carry the pager from day one.
- Commitment is measured by **outcomes** — the mandate in clause 2 and the
  deliverables in clause 6 — not hours logged. Where an incident, launch or
  hardening push needs a focused effort, you make reasonable additional time
  available by prior agreement.
- Commitment level is reviewed together after the foundations period; moving to
  full-time later is by mutual agreement as the company grows.
- **Foundations period (first 90 days):** mutual trial. Either side may part ways
  before day 90 with no vested equity and no ongoing obligations beyond confidentiality.
- Directorship is expected once the shareholders' agreement is signed, and only
  after director protections are in place (D&O insurance and/or an indemnity to
  the fullest extent permitted by the Companies Act 2015 — clause 8).

## 5. Equity — summary

Grant of **16%** fully-diluted at grant — equal across all five founder seats —
alongside a 20% unallocated reserve created at incorporation; vesting and leaver
terms per Annex A (bad-leaver buy-back at fair market value). Equity subject to
IP assignment (clause 7) and execution of the shareholders' agreement.

## 6. First 90 days — success looks like

1. Threat model v2 documented for messaging/calls, marketplace+wallet, and
   verification flows — with top-10 risks triaged into the backlog.
2. CI security gates live: dependency scanning, secret scanning, ruff/eslint
   security profiles blocking merges.
3. Incident response plan v1 written and tabletop-exercised once with the founders.
4. External attack-surface review completed (nginx/TLS headers, LiveKit/TURN
   exposure, admin routes, webhook endpoints); findings fixed or scheduled.
5. Security one-pager published for partner due-diligence use.

**How the 90 days are measured — deliberately realistic:**

- Your obligation is to take each listed action with all reasonable skill and
  care, keep the founding team informed, and escalate blockers early.
- Where a step depends on a third party (hosting providers, auditors, assessors,
  payment providers) and that party's processing exceeds its stated timeline,
  the deadline extends day-for-day **without the deliverable being treated as
  failed** — provided you engaged or prompted promptly and can evidence it.
- At a day-60 checkpoint you and the CEO may re-scope the list by mutual written
  agreement, without stigma or effect on vesting.
- This flexibility does not absolve the obligations: unexplained stalls with no
  third-party cause remain a legitimate concern under the foundations period.

## 7. IP, confidentiality & declaration of interests

- All security tooling, runbooks, configurations and fixes belong to BuddyUp Ltd.
  from creation.
- Confidentiality is indefinite and starts now; disclosure of company security
  posture to third parties requires CEO co-approval except under legal compulsion.
- **Declaration of interests (not a blanket conflicts bar):**
  - Before signature you complete a written declaration of interests covering
    current employment, businesses, directorships, significant investments,
    ongoing bug-bounty participation and other security engagements.
  - Outside work is **permitted** and is not, by itself, a conflict. What must be
    disclosed is anything that could materially impair impartiality, divert
    BuddyUp's security work elsewhere, or place you opposite the company (e.g.
    testing a competitor's platform in a way that overlaps BuddyUp scope, or an
    engagement with a party in dispute with BuddyUp). Testing systems outside
    BuddyUp scope during the engagement continues to require board consent.
  - If a declared interest later becomes a genuine conflict in a specific matter,
    it is managed case by case — recusal, an information barrier, or re-scoping —
    rather than by prohibiting the outside work.
  - The declaration is a living document: refreshed on material change and at
    least every six months, with the company keeping a simple register.
    Good-faith disclosure is always safe; only concealment of a known, material
    interest is a breach.

## 8. Conditions precedent

1. Executed Founders' Shareholders' Agreement (Kenyan advocate drafted).
2. Declaration of interests (clause 7); background check consent (standard for
   the role).
3. Director protections in place: D&O insurance bound (or a written company
   indemnity to the fullest extent permitted by the Companies Act 2015), before
   board appointment paperwork is filed.

**External counsel costs.** The advocate for the Founders' Shareholders'
Agreement is jointly retained and instructed by **the company**, and those fees
are an **operational expense of BuddyUp Ltd.** — not a founder personal cost.
The engagement letter (scope, fee estimate and any cap) will be confirmed in
writing and shared with all founders **before** instruction. Any separate
personal-review advocate a founder chooses to engage for their own side review is
at that founder's own cost.

## Signatures

| For BuddyUp Ltd. | Candidate |
|---|---|
| Name: Peter Mbugua | Name: [Full legal name] |
| Title: Cofounder & CEO | ID/Passport: [●] |
| Signature: ________________ Date: ______ | Signature: ________________ Date: ______ |

---

## Annex A — Vesting schedule

*(Identical across all founder agreements.)*

1. **Grant:** 16% of the fully-diluted capital of BuddyUp Ltd. as at the start
   date, recorded in the share register. Identical for every founder seat.
2. **Cliff:** no shares vest before the 12-month anniversary of the start date.
   On passing the cliff, 25% vests retroactively; the remainder vests monthly
   over the following 36 months.
3. **Leavers:**
   - **Good leaver** — by default, every departure that is not a bad leaver is
     treated as a good leaver. Explicit examples: death or serious illness,
     mutual agreement, role eliminated, resignation for good reason (material
     reduction in agreed role/commitment, unpaid equity terms, or a change the
     founder did not consent to). Treatment: vested shares retained; unvested
     cancelled or partly accelerated at board discretion.
   - **Bad leaver** — only the following, determined by majority of the
     non-affected founders (or the board where independent):
     (a) gross misconduct or fraud;
     (b) conviction of an offence involving dishonesty;
     (c) material breach of this agreement or the shareholders' agreement
         (including concealment of a known, material interest declared under
         clause 7, or breach of confidentiality/IP assignment);
     (d) resignation **without good reason** within the first 24 months after
         the cliff;
     (e) persistent failure to meet the agreed commitment after written warning
         and a 30-day cure period; or
     (f) conduct that seriously damages the company's reputation or regulatory
         standing.
     Treatment: unvested shares cancel; vested shares are **bought back at fair
     market value** — determined by an independent valuator jointly appointed by
     the company and the leaver, or, if an arm's-length financing or valuation
     occurred within the preceding 12 months, at that round's price per share.
     Proceeds are payable within 60 days of the valuation. Anything not listed
     above cannot be treated as bad-leaver conduct.
4. **Acceleration:** single-trigger acceleration is not offered; **double-trigger
   (change of control + termination without cause, or resignation for good
   reason following a change of control) accelerates 100% of unvested shares.**
   A change of control alone does not accelerate anything.
5. **Dilution:** a **20% unallocated reserve** (future hires / option pool) is
   created at incorporation, so future option grants are funded from the reserve
   rather than by further diluting founders. Future investment rounds dilute all
   holders pro rata. Any top-up of the pool beyond 20%, or any pool creation from
   founder holdings, requires unanimous founder consent.
6. **Lock-in:** founders may not transfer shares other than per the shareholders'
   agreement (pre-emption rights apply).
