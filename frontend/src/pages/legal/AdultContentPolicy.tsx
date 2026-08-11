import LegalPage, { LegalSection, LegalNotice } from './LegalPage';

export default function AdultContentPolicy() {
  return (
    <LegalPage
      title="Adult Content Policy (Mature Category)"
      subtitle="BuddyUp's Mature category hosts adult fitness content — nude or suggestive trainer profiles, adult-only live sessions, adult marketplace items, and nude or adult-themed gyms — for users who meet a country-aware age threshold. Access is restricted and gated."
      updatedAt="August 2026"
    >
      <LegalSection title="1. What Belongs in the Mature Category">
        <p>The Mature category is a separate, hidden-by-default section of BuddyUp for adult fitness content. It includes, without limitation:</p>
        <ul className="list-disc list-inside space-y-1">
          <li>Nude or suggestive trainer and creator profiles</li>
          <li>Adult-only live sessions and recordings</li>
          <li>Adult marketplace items — events, products, training programmes, and the rest</li>
          <li>Nude or adult-themed gyms</li>
        </ul>
        <p className="mt-2">Content is placed in the Mature category by the creator at the time of posting. Adult content that appears anywhere else on the platform is a violation of this policy and the Community Guidelines.</p>
      </LegalSection>

      <LegalSection title="2. Age Gate &amp; Country-Aware Threshold">
        <p>Access to the Mature category requires passing a country-aware age check:</p>
        <ul className="list-disc list-inside space-y-1">
          <li><strong>18+ by default</strong> in every country, including Kenya</li>
          <li><strong>16+ only where local law permits</strong> and the platform has confirmed the threshold by legal review</li>
        </ul>
        <p className="mt-2">The age gate is applied on entry and re-checked periodically. Misrepresenting your age or country to access the category is a serious violation.</p>
        <LegalNotice tone="red">
          The Mature category is never shown to minors. Users who fail the age gate cannot browse, search, or be served Mature content.
        </LegalNotice>
      </LegalSection>

      <LegalSection title="3. Prohibited Content in the Mature Category">
        <p>The Mature category is not an exemption from any other platform rule. The following remain strictly prohibited:</p>
        <ul className="list-disc list-inside space-y-1">
          <li>Depictions of sexual activity or explicit sexual content</li>
          <li>Any content sexualising minors, or CSAM (reported to NCMEC and local law enforcement)</li>
          <li>Non-consensual content, revenge content, or content created without the depicted adults' consent</li>
          <li>Medical or treatment claims, scope-of-practice breaches, and undisclosed sponsorship or gifting</li>
          <li>Violence, hate speech, harassment, or content exploiting vulnerable people</li>
        </ul>
      </LegalSection>

      <LegalSection title="4. Consent &amp; Documentation">
        <p>Everyone depicted in Mature content must be an adult who has freely consented to the content and its publication. Creators must be able to verify the age and consent of everyone depicted when requested by our Trust &amp; Safety team. We may require documentation before approving or reinstating Mature content.</p>
      </LegalSection>

      <LegalSection title="5. Creator Obligations">
        <ul className="list-disc list-inside space-y-1">
          <li>Classify content as mature accurately at the time of posting</li>
          <li>Keep adult content inside the Mature category and its dedicated spaces</li>
          <li>Do not promote Mature content to minors or in general-audience areas</li>
          <li>Continue to comply with sponsorship disclosure, health-claim, and scope-of-practice rules</li>
        </ul>
      </LegalSection>

      <LegalSection title="6. Moderation &amp; Enforcement">
        <p>Our moderation systems detect adult content using a purpose-built NSFW model. Adult content inside the Mature category is gated and permitted; adult content found outside the category is flagged as <strong>adult_ungated</strong>, hidden, and reviewed by a human moderator. Violations follow the enforcement ladder in the Community Guidelines, and repeated or severe violations can lead to suspension or permanent removal.</p>
      </LegalSection>

      <LegalSection title="7. Reporting">
        <p>Report Mature content that is abusive, non-consensual, or outside the category via the Report button or <strong>safety@buddyup.app</strong>. Reports are reviewed within 24 hours; reports of harm are escalated within 1 hour.</p>
      </LegalSection>
    </LegalPage>
  );
}
