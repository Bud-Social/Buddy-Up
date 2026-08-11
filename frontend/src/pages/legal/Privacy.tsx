import LegalPage, { LegalSection, LegalNotice } from './LegalPage';

export default function Privacy() {
  return (
    <LegalPage
      title="Privacy Policy"
      subtitle="BuddyUp processes your personal data in accordance with the Kenya Data Protection Act 2019 and applicable law. This policy explains what we collect, why, how long we keep it, and your rights."
      updatedAt="August 2026"
    >
      <LegalSection title="1. Data We Collect">
        <h3 className="font-medium text-buddy-text-primary mt-4 mb-2">Identity Data</h3>
        <p>Name, username, email address, phone number, date of birth (stored hashed), profile photo, and government-issued ID (for verified users, sellers, and users receiving payouts above KSh 50,000 in a rolling 30-day period).</p>
        <h3 className="font-medium text-buddy-text-primary mt-4 mb-2">Health & Fitness Data</h3>
        <p>Fitness goals, activity level, dietary preferences, workout logs, meal data, body measurements, and progress photos. <strong>Health data is sensitive personal data under the Kenya Data Protection Act</strong> and is processed only with your explicit consent, for the specific purpose you provide it, and with enhanced security controls.</p>
        <h3 className="font-medium text-buddy-text-primary mt-4 mb-2">Parental Co-Owner Data</h3>
        <p>For users aged 16–17, we collect the name, email, and/or phone of a verified parent or guardian co-owner so they can supervise the account and be contacted by Trust &amp; Safety if needed.</p>
        <h3 className="font-medium text-buddy-text-primary mt-4 mb-2">Device & Usage Data</h3>
        <p>IP address, device type, operating system, browser type, approximate location (from IP), pages visited, features used, and session duration.</p>
        <h3 className="font-medium text-buddy-text-primary mt-4 mb-2">Payment Data</h3>
        <p>Payment method tokens (no raw card data is stored — handled by M-Pesa, Stripe, and Flutterwave). Purchase history and transaction records.</p>
        <h3 className="font-medium text-buddy-text-primary mt-4 mb-2">Biometric Data</h3>
        <p>We do not build facial recognition profiles. Where used for identity or CSAM-screening purposes, it is via automated tools that process images transiently.</p>
      </LegalSection>

      <LegalSection title="2. What We Do NOT Collect">
        <ul className="list-disc list-inside space-y-1">
          <li>Health records outside of the opt-in data you explicitly provide</li>
          <li>Religious, political, or sexual-orientation data — never</li>
          <li>Children's data — the platform is strictly 16+</li>
        </ul>
      </LegalSection>

      <LegalSection title="3. How We Use Your Data (Lawful Bases)">
        <p>Under the Kenya Data Protection Act 2019, we process personal data on the following bases:</p>
        <ul className="list-disc list-inside space-y-1">
          <li><strong>Consent</strong> — default for non-essential processing (marketing, personalisation, sensitive health data)</li>
          <li><strong>Contract</strong> — to provide the service you signed up for</li>
          <li><strong>Legal obligation</strong> — tax, anti-fraud, and retention requirements</li>
          <li><strong>Legitimate interest</strong> — safety, security, and abuse prevention, with a documented balancing test</li>
        </ul>
        <p className="mt-2">Specifically, we use your data to: provide and improve the platform; personalise content and AI recommendations; verify identity and credentials; process payments and prevent fraud; enforce Community Guidelines; communicate service updates (with consent for marketing); and comply with legal obligations.</p>
        <LegalNotice>
          We never sell personal data and never use it for targeted advertising on sensitive categories (health, religion, political views).
        </LegalNotice>
      </LegalSection>

      <LegalSection title="4. Data Sharing & Processors">
        <p>We share data only with vetted processors and only as needed to operate the service:</p>
        <ul className="list-disc list-inside space-y-1">
          <li><strong>Payment processors</strong> — Safaricom M-Pesa (Daraja API), Stripe, Flutterwave</li>
          <li><strong>Cloud & storage</strong> — AWS/GCP, S3-compatible storage</li>
          <li><strong>Content moderation</strong> — automated image/text moderation models and services</li>
          <li><strong>Verification services</strong> — KYC and credential verification providers</li>
          <li><strong>Analytics</strong> — privacy-compliant analytics (no advertising trackers)</li>
          <li><strong>Legal authorities</strong> — when required by law or to protect rights and safety</li>
        </ul>
        <p className="mt-2">A sub-processor list is published and updated on this page. All processors are contractually bound to process data only per our instructions and applicable data protection law.</p>
      </LegalSection>

      <LegalSection title="5. Cross-Border Transfers">
        <p>User data is processed in-region where possible. Where cross-border transfer is necessary (e.g. model infrastructure), we ensure protections equivalent to the Kenya Data Protection Act. Personal health information is only transferred cross-border where the Digital Health Act 2023 permits (e.g. health tourism or comparable exception) or with your explicit consent.</p>
      </LegalSection>

      <LegalSection title="6. Data Retention">
        <ul className="list-disc list-inside space-y-1">
          <li><strong>Account data</strong> — active account + 30-day soft-delete window, then permanent deletion</li>
          <li><strong>Safety records</strong> — 7 years (audit and regulatory inquiry)</li>
          <li><strong>Financial records</strong> — per KRA requirements (currently 7 years)</li>
          <li><strong>Operational logs</strong> — 90 days</li>
          <li><strong>Backups</strong> — 30 days rolling</li>
        </ul>
      </LegalSection>

      <LegalSection title="7. Your Rights">
        <p>You have the right to:</p>
        <ul className="list-disc list-inside space-y-1">
          <li><strong>Access</strong> — request a copy of your data (downloadable JSON archive)</li>
          <li><strong>Rectification</strong> — correct inaccurate or incomplete data</li>
          <li><strong>Erasure</strong> — request deletion (30-day grace period applies)</li>
          <li><strong>Portability</strong> — receive your data in a machine-readable format</li>
          <li><strong>Restriction & Objection</strong> — restrict processing or object to marketing</li>
          <li><strong>Complain</strong> — lodge a complaint with the Kenya Office of the Data Protection Commissioner (ODPC)</li>
        </ul>
        <p className="mt-2">Use Settings → Your Data to export or delete, or email <strong>privacy@buddyup.app</strong>. We respond within the statutory window.</p>
      </LegalSection>

      <LegalSection title="8. Security">
        <p>We protect data with TLS in transit, encryption at rest, password hashing (Argon2id), role-based access control, intrusion monitoring, and an incident-response plan. Personal data breach notifications are provided within the statutory window.</p>
      </LegalSection>

      <LegalSection title="9. Children's Privacy">
        <p>BuddyUp is not directed to users under 16. Users aged 16–17 may use the service only with a verified parental co-owner. If we learn that we have collected data from a user under 16, we will delete it promptly and terminate the account.</p>
      </LegalSection>

      <LegalSection title="10. Automated Decisions & AI">
        <p>Some decisions are partly automated: safety triage, feed ranking, discovery, and buddy suggestions. Significant decisions (account suspension, payment holds, dispute outcomes) always have a human review path. You may request human review of any automated decision that affects you via Settings → Help &amp; Safety.</p>
      </LegalSection>

      <LegalSection title="11. Cookies & Local Storage">
        <p>BuddyUp uses only strictly necessary cookies by default. Functional and analytics cookies require your consent and can be changed at any time from the cookie banner or Settings. No advertising, cross-site tracking, or fingerprinting.</p>
      </LegalSection>

      <LegalSection title="12. Changes to This Policy">
        <p>Material changes are notified by email and in-app at least 30 days before they take effect and may require re-consent. Non-material changes are posted here with a revised effective date.</p>
      </LegalSection>

      <LegalSection title="13. Contact">
        <p>Data Protection Officer, BuddyUp Ltd., Nairobi, Kenya. Email: <strong>dpo@buddyup.app</strong>. Postal address to be registered with ODPC.</p>
      </LegalSection>
    </LegalPage>
  );
}
