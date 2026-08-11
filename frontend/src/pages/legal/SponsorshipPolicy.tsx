import LegalPage, { LegalSection, LegalNotice } from './LegalPage';

export default function SponsorshipPolicy() {
  return (
    <LegalPage
      title="Sponsorship & Disclosure Policy"
      subtitle="BuddyUp is built on trust. When creators are compensated or gifted in exchange for content, that connection must be disclosed clearly and prominently."
      updatedAt="August 2026"
    >
      <LegalSection title="1. What Counts as a Material Connection">
        <p>A material connection exists when a creator receives anything of value in connection with content they post. This includes, without limitation:</p>
        <ul className="list-disc list-inside space-y-1">
          <li>Gifted products, supplements, or fitness equipment</li>
          <li>Free or discounted programme access, memberships, or services</li>
          <li>Cash payments or performance-based bonuses</li>
          <li>Affiliate commissions or referral benefits</li>
          <li>Trips, event invitations, or other non-monetary perks</li>
          <li>Personal or family relationships with a brand</li>
        </ul>
        <p className="mt-2">Even if the brand did not ask for or control the content, a material connection still exists and must be disclosed.</p>
      </LegalSection>

      <LegalSection title="2. How to Disclose">
        <p>Disclosures must be <strong>clear, prominent, and unambiguous</strong>:</p>
        <ul className="list-disc list-inside space-y-1">
          <li>Place the disclosure at the <strong>start</strong> of the caption or as an on-screen label, not buried in fine print</li>
          <li>Use unmistakable language: "<em>#ad</em>", "<em>Sponsored</em>", "<em>Paid partnership</em>", "<em>Gifted by [Brand]</em>"</li>
          <li>A disclosure that is easily missed, requires scrolling, or uses vague language ("<em>thanks to my friends at…</em>") does not comply</li>
          <li>Disclose in the primary language of the audience</li>
        </ul>
        <LegalNotice tone="orange">
          Hiding a disclosure, placing it only in a comment, or omitting it entirely is treated as non-disclosure and may result in the content being flagged, labelled, or removed, and further enforcement action.
        </LegalNotice>
      </LegalSection>

      <LegalSection title="3. What Cannot Be Sponsored">
        <p>The following are prohibited in sponsored or gifted content:</p>
        <ul className="list-disc list-inside space-y-1">
          <li>Medical claims — no product or plan may be presented as treating, curing, or managing a condition</li>
          <li>Claims about licensed professionals or therapies outside their verified scope</li>
          <li>Unregistered supplements, medicines, or banned substances</li>
          <li>Endorsements from users who have not genuinely used the product</li>
          <li>Testimonials implying results the creator did not actually experience</li>
        </ul>
      </LegalSection>

      <LegalSection title="4. Platforms for Disclosure">
        <p>When a BuddyUp content link is shared on external platforms, the disclosure obligation applies there too. Creators must comply with the advertising disclosure rules of the country where the audience is located, including Kenya's Consumer Protection Act.</p>
      </LegalSection>

      <LegalSection title="5. Detection & Enforcement">
        <p>Our moderation systems automatically detect promotional patterns (gifting language, brand mentions with affiliate markers) and check for the presence of a disclosure. Content that is promotional without a compliant disclosure is flagged for human review and may be:</p>
        <ul className="list-disc list-inside space-y-1">
          <li>Labelled as undisclosed sponsorship</li>
          <li>Removed, with the account subject to the enforcement ladder in the Community Guidelines</li>
          <li>Reported to relevant authorities where required by law</li>
        </ul>
      </LegalSection>

      <LegalSection title="6. Creators &amp; Trainers Obligations">
        <p>Creators, coaches, and trainers who accept gifting or sponsorship remain responsible for the truthfulness of their content. Paid promotional content must not include undisclosed claims, fake testimonials, or results the creator has not experienced. Repeated violations can result in loss of creator and verification benefits.</p>
        <p className="mt-2"><strong>Mature category is not exempt.</strong> Sponsorship and gifting disclosure rules apply in full to the Mature (18+/16+) category. Gifted adult content must still carry a clear, prominent disclosure, and all medical-claim prohibitions continue to apply.</p>
      </LegalSection>

      <LegalSection title="7. Questions">
        <p>For questions about this policy or a specific disclosure, contact <strong>safety@buddyup.app</strong>.</p>
      </LegalSection>
    </LegalPage>
  );
}
