# Cofounder Agreement — Security

**BuddyUp Ltd.** — Founding Team Heads of Terms (pre-shareholders' agreement)

| | |
|---|---|
| Candidate | [Full legal name], ID/Passport No. [●] |
| Role | Cofounder — Security Engineering & Trust |
| Proposed equity | [●]% of fully-diluted share capital at grant, subject to the vesting terms in Annex A |
| Vesting | 4 years monthly, 1-year cliff (Annex A) |
| Start date | [●] |
| Reporting line | CEO / Board of BuddyUp Ltd. |

> **Status:** This is an invitation to join the founding team and a summary of proposed
> terms. It is not a shareholders' agreement, not an employment contract, and not legal
> advice. It becomes binding only when superseded by the executed Founders'
> Shareholders' Agreement (Kenyan law) that all founders will sign together.

---

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

## 4. Commitment

- Full-time from the start date; you build alongside the founding engineers and carry
  a pager from day one.
- **Foundations period (first 90 days):** mutual trial per Annex A.
- Directorship expected once the shareholders' agreement is signed.

## 5. Equity — summary

Grant [●]% fully-diluted at grant; vesting and leaver terms per Annex A.
Equity subject to IP assignment (clause 7) and execution of the shareholders'
agreement.

## 6. First 90 days — success looks like

1. Threat model v2 documented for messaging/calls, marketplace+wallet, and
   verification flows — with top-10 risks triaged into the backlog.
2. CI security gates live: dependency scanning, secret scanning, ruff/eslint
   security profiles blocking merges.
3. Incident response plan v1 written and tabletop-exercised once with the founders.
4. External attack-surface review completed (nginx/TLS headers, LiveKit/TURN
   exposure, admin routes, webhook endpoints); findings fixed or scheduled.
5. Security one-pager published for partner due-diligence use.

## 7. IP, confidentiality & conflicts

- All security tooling, runbooks, configurations and fixes belong to BuddyUp Ltd.
  from creation.
- Confidentiality is indefinite and starts now; disclosure of company security
  posture to third parties requires CEO co-approval except under legal compulsion.
- Prior commitments and bug-bounty side activity must be declared; testing systems
  outside BuddyUp scope during the engagement requires board consent.

## 8. Conditions precedent

1. Executed Founders' Shareholders' Agreement (Kenyan advocate drafted).
2. Board appointment paperwork filed.
3. Declaration of conflicts; background check consent (standard for the role).

## Signatures

| For BuddyUp Ltd. | Candidate |
|---|---|
| Name: [●] | Name: [Full legal name] |
| Title: Founder/CEO | ID/Passport: [●] |
| Signature: ________________ Date: ______ | Signature: ________________ Date: ______ |

---

## Annex A — Vesting schedule

*(Identical across all founder agreements.)*

1. Grant of [●]% fully-diluted at grant, recorded in the share register.
2. 12-month cliff (25% retroactive), then monthly vesting over 36 months.
3. Good leaver / bad leaver provisions per the shareholders' agreement;
   unvested shares cancel on departure.
4. No single-trigger acceleration; double-trigger = 50% acceleration of unvested shares.
5. Pro-rata dilution in future rounds; option-pool changes require unanimous founder consent.
6. Founder share transfers restricted by pre-emption rights in the shareholders' agreement.
