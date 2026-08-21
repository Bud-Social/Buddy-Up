import LegalPage, { LegalSection, LegalNotice } from './LegalPage';

export default function Terms() {
  return (
    <LegalPage
      title="Terms of Service"
      subtitle="This is not medical, nutritional, legal or professional advice. BuddyUp is a connection and accountability platform. Coaches, trainers and practitioners are independent providers, not employees of BuddyUp."
      updatedAt="August 2026"
    >
      <LegalSection title="1. Acceptance and Eligibility">
        <p>By creating an account you confirm that you are at least 16 years old, that the information you provide is accurate, and that you accept these Terms, the Privacy Policy, and the Community Guidelines. If you do not accept them, do not use the service.</p>
        <p className="mt-2">Users aged 16–17 may only use BuddyUp with a verified parental co-owner (parent or guardian), who is bound by the same Terms and may be contacted by our Trust &amp; Safety team. Accounts found to belong to users under 16 are terminated.</p>
        <LegalNotice>
          You must provide accurate, current registration information. BuddyUp may verify age, identity, and credentials, and may block or suspend accounts that rely on false information.
        </LegalNotice>
      </LegalSection>

      <LegalSection title="2. Account Security">
        <p>You are responsible for your account credentials and for activity under your account. Enable two-factor authentication where available. Notify us immediately at <strong>security@buddyup.app</strong> if you suspect unauthorised access.</p>
      </LegalSection>

      <LegalSection title="3. Service Description">
        <p>BuddyUp combines free social and accountability features (posts, buddy circles, live sessions) with optional paid services: gym subscriptions, session bookings, training programmes, meal plans, and marketplace purchases. Funds for booked services are held in escrow and released on completion of the service.</p>
      </LegalSection>

      <LegalSection title="4. Health, Fitness & Nutrition Information">
        <p>BuddyUp provides a platform for users to share fitness experiences and for verified coaches, trainers and practitioners to offer guidance. The platform does not provide medical advice, diagnosis, or treatment.</p>
        <p className="mt-2"><strong>Scope of practice.</strong> Only verified practitioners (licensed clinicians, dietitians, physiotherapists) may present advice as professional or clinical guidance. All other users and coaches may only share general wellness information. Content that claims to diagnose, treat, cure, or manage a medical condition (e.g. "reverses insulin resistance", "cures PCOS", "treatment for diabetes") is prohibited outside a licensed professional relationship.</p>
        <p className="mt-2"><strong>No guarantees.</strong> Fitness and nutrition outcomes depend on individual factors and are never guaranteed. Meal plans and programmes provided on BuddyUp are general wellness resources, not personalised medical nutrition therapy.</p>
        <LegalNotice tone="red">
          AI-generated recommendations are for informational purposes only and are not a substitute for professional judgement. If you have a medical condition, injury, or persistent symptoms, consult a qualified healthcare professional.
        </LegalNotice>
      </LegalSection>

      <LegalSection title="5. Sponsored Content & Gifting Disclosure">
        <p>Creators, trainers, and members must clearly disclose any material connection to a brand, gym, or programme — including gifted products, free programme access, affiliate arrangements, or paid partnerships. Disclosures must be prominent and placed where they are likely to be seen (for example "#ad", "Sponsored", or "Paid partnership" near the top of the post).</p>
        <p className="mt-2">Hiding a disclosure in a long caption or fine print is treated as non-disclosure. Undisclosed promotional content may be flagged, labelled, or removed, and repeat violations may lead to suspension.</p>
        <p className="mt-2">Sponsored and partner placements are never mixed into organic ranking without a visible label.</p>
      </LegalSection>

      <LegalSection title="6. AI-Generated Content">
        <p>Every AI-generated output on BuddyUp is labelled with its source and a limitation statement. You may not repost AI output as your own advice or present it as professional guidance. Automated moderation flags are reviewed by a human moderator before any removal action is taken.</p>
      </LegalSection>

      <LegalSection title="7. Community Standards &amp; Enforcement">
        <p>All users must comply with the Community Guidelines. Violations are handled through a graduated enforcement process (warning → content removal → suspension → permanent removal). You may appeal an enforcement action through Settings → Help &amp; Safety within 14 days.</p>
      </LegalSection>

      <LegalSection title="8. Verification &amp; Credentials">
        <p>Trainers, practitioners, gyms, and marketplace sellers must complete the relevant verification tier. Verification checks credentials against issuing registries where possible and is subject to periodic re-verification and renewal. Listings that rely on false credentials, or that fail to renew on time, may be suspended.</p>
      </LegalSection>

      <LegalSection title="9. Marketplace Purchases">
        <p>Marketplace listings are governed by the seller's verification tier and their published cancellation/refund policy. BuddyUp is the platform of record and is not the seller of record except for first-party items. Digital products are refundable within 7 days if not more than 25% consumed.</p>
      </LegalSection>

      <LegalSection title="10. Payments, Fees &amp; Refunds">
        <p>Paid services are billed in Kenyan Shillings via M-Pesa, card, or other approved payment rails. Cancellations follow the partner's published policy. Sessions cancelled at least 2 hours before start receive a full refund; later cancellations follow the partner's policy (default 50%). No-shows forfeit the session fee. Refund and dispute procedures are described in Settings → Help.</p>
      </LegalSection>

      <LegalSection title="11. Content Ownership &amp; Licence">
        <p>You retain ownership of content you create. You grant BuddyUp a limited, non-exclusive, royalty-free licence to host, display, distribute, and process that content to operate the service (including ranking, search, and replay where applicable). The licence ends when you delete the content or close your account, subject to legal retention obligations.</p>
      </LegalSection>

      <LegalSection title="12. Suspension &amp; Termination">
        <p>BuddyUp may suspend or terminate accounts that breach these Terms, the Community Guidelines, or applicable law, after a proportionate warning except in cases of imminent harm. You may close your account at any time; closure triggers a 30-day recoverable soft-delete followed by permanent deletion.</p>
      </LegalSection>

      <LegalSection title="13. Disclaimer of Warranties">
        <p>The service is provided "as is" and "as available". BuddyUp does not warrant that fitness outcomes will be achieved and is not responsible for the actions, advice, or conduct of independent coaches, trainers, or practitioners. Users engage these professionals at their own risk.</p>
      </LegalSection>

      <LegalSection title="14. Limitation of Liability">
        <p>To the maximum extent permitted by law, BuddyUp's aggregate liability for any claim is limited to the fees paid by you to BuddyUp in the 12 months preceding the event giving rise to the claim. BuddyUp is not liable for indirect, incidental, special, or consequential damages.</p>
      </LegalSection>

      <LegalSection title="15. Disputes">
        <p>Disputes are resolved through BuddyUp's three-level procedure: (1) Buddy/gym-mediated, (2) Bud Concierge mediation for disputes up to KSh 20,000, and (3) a formal Dispute Panel for larger disputes and fraud/harm allegations. Unresolved disputes are subject to the exclusive jurisdiction of the Kenyan courts and governed by the laws of the Republic of Kenya.</p>
      </LegalSection>

      <LegalSection title="16. Changes to the Service or Terms">
        <p>BuddyUp may add, modify, or remove features with reasonable notice. Material changes affecting your rights (including these Terms and the Privacy Policy) will be communicated by email and in-app at least 30 days before they take effect. Continued use after the effective date constitutes acceptance.</p>
      </LegalSection>

      <LegalSection title="17. Contact">
        <p>BuddyUp Ltd., Nairobi, Kenya. For questions about these Terms, contact <strong>legal@buddyup.app</strong>. For safety concerns, contact <strong>safety@buddyup.app</strong>.</p>
      </LegalSection>
    </LegalPage>
  );
}
