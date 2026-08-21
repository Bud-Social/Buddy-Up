import LegalPage, { LegalSection, LegalNotice } from './LegalPage';

export default function CommunityGuidelines() {
  return (
    <LegalPage
      title="Community Guidelines"
      subtitle="BuddyUp exists to help people find their fitness family. These guidelines keep our community safe, inclusive, and focused on health and wellness."
      updatedAt="August 2026"
    >
      <LegalSection title="1. Health & Safety">
        <div className="space-y-2">
          <p><strong>No promotion of eating disorders.</strong> Content promoting extreme restriction, purging, or other disordered eating behaviours is prohibited.</p>
          <p><strong>No dangerous health advice.</strong> Do not promote unverified supplements, unlicensed drugs, or dangerous practices.</p>
          <p><strong>No medical claims outside a licensed relationship.</strong> Sharing your own fitness story is welcome. Advising specific treatment, dosing, or diagnosis is not. Claims that a meal plan or programme "treats", "cures", or "manages" a medical condition (e.g. diabetes, PCOS, insulin resistance) are prohibited unless made within a verified practitioner relationship.</p>
          <p><strong>Professional guidance disclaimer.</strong> Users who are not verified practitioners must include a disclaimer when sharing health information. Only verified practitioners may present advice as professional guidance, and only within their verified scope of practice.</p>
          <p><strong>No PED promotion.</strong> Promotion of performance-enhancing drugs is prohibited except for factual educational content from verified practitioners.</p>
          <p><strong>No dangerous stunts.</strong> Content depicting extreme self-harm in the context of fitness or misuse of equipment will be removed.</p>
          <p><strong>Scope of practice.</strong> Coaches and trainers must provide guidance only within their verified scope (general fitness and wellness) and must not present meal plans as personalised medical nutrition therapy.</p>
        </div>
      </LegalSection>

      <LegalSection title="2. Sponsored Content & Gifting Disclosure">
        <div className="space-y-2">
          <p><strong>Disclose material connections.</strong> If you received anything of value — gifted products, free programme access, payment, affiliate benefits, trips, or event invitations — in exchange for content, you must disclose it clearly and prominently ("#ad", "Sponsored", or "Paid partnership" near the top of the post).</p>
          <p><strong>No hidden disclosures.</strong> Burying a disclosure in a long caption or fine print is treated as non-disclosure. Undisclosed promotional content may be flagged, labelled, or removed.</p>
          <p><strong>No fake reviews.</strong> Reviews must reflect genuine experiences. Do not post incentivised reviews without disclosure.</p>
          <p><strong>No artificial metrics.</strong> Do not purchase followers, likes, or engagement. Do not use bots.</p>
          <p><strong>No fraudulent services.</strong> Do not claim certifications you do not hold or take payment without delivering promised services.</p>
        </div>
      </LegalSection>

      <LegalSection title="3. AI-Generated Content">
        <div className="space-y-2">
          <p><strong>Label AI output.</strong> Every AI-generated text, image, recommendation, or ranking is labelled with its source model and a limitation statement.</p>
          <p><strong>No impersonation by AI.</strong> You may not repost AI output as your own advice or present it as professional guidance.</p>
          <p><strong>No medical claims by AI.</strong> AI must not produce diagnosis, prescription, or legal interpretation.</p>
          <p><strong>Human review.</strong> Automated moderation flags are reviewed by a human moderator before any removal action is taken.</p>
        </div>
      </LegalSection>

      <LegalSection title="4. Age Safety">
        <div className="space-y-2">
          <p><strong>Platform strictly 16+.</strong> Any accounts confirmed to belong to persons under 16 are permanently terminated.</p>
          <p><strong>Parental co-owner for 16–17.</strong> Users aged 16–17 must be co-owned by a verified parent or guardian.</p>
          <p><strong>No content targeting minors.</strong> No content sexualising minors or designed to appeal inappropriately to persons under 16.</p>
          <p><strong>Zero tolerance for CSAM.</strong> Any creation or sharing of child sexual abuse material results in immediate account termination and reporting to NCMEC and local law enforcement.</p>
        </div>
      </LegalSection>

      <LegalSection title="5. Respect &amp; Inclusion">
        <div className="space-y-2">
          <p><strong>No hate speech.</strong> Zero tolerance for hate speech targeting any person based on body size/shape, race, ethnicity, religion, gender, sexual orientation, disability, or nationality.</p>
          <p><strong>No body-shaming.</strong> No fat-phobia, body-shaming, diet-culture extremism, or derogatory comments about anyone's appearance or abilities.</p>
          <p><strong>No bullying or harassment.</strong> No targeted abuse, intimidation, or coordinated attacks.</p>
          <p><strong>No spam.</strong> No coordinated inauthentic behaviour, spam, or artificial engagement.</p>
          <p><strong>No impersonation.</strong> No impersonation of verified trainers, practitioners, or public figures.</p>
          <p><strong>No doxxing.</strong> Do not share another person's private information without consent.</p>
        </div>
      </LegalSection>

      <LegalSection title="6. Live Sessions">
        <div className="space-y-2">
          <p><strong>Host controls.</strong> Hosts may mute, remove, and ban viewers. Recording requires explicit consent from the host and visible participants.</p>
          <p><strong>Viewer conduct.</strong> No doxxing, no sexual content, no medical advice, no commercial solicitation outside authorised paid sessions.</p>
          <p><strong>Safety.</strong> Every live session shows the host's emergency contact and a BuddyUp safety shortcut.</p>
        </div>
      </LegalSection>

      <LegalSection title="7. Enforcement">
        <div className="space-y-2">
          <p><strong>1st minor violation:</strong> Warning + content removal</p>
          <p><strong>2nd minor / 1st moderate:</strong> 24-hour content posting suspension</p>
          <p><strong>3rd minor / 2nd moderate / 1st severe:</strong> 7-day full suspension</p>
          <p><strong>4th / 2nd severe:</strong> 30-day suspension + mandatory account review</p>
          <p><strong>5th / any critical:</strong> Permanent ban + potential law enforcement referral</p>
          <p className="mt-3">Undisclosed sponsorship and medical claims are treated as moderate-to-severe violations. Users may appeal enforcement actions within 14 days through Settings → Help &amp; Safety.</p>
        </div>
      </LegalSection>

      <LegalSection title="8. Reporting">
        <p>Report violations via the Report button on any post, comment, or profile, or email <strong>safety@buddyup.app</strong>. Reports are reviewed within 24 hours; severe categories are escalated within 1 hour. Reports involving imminent harm bypass the queue.</p>
        <LegalNotice>
          Health misinformation, medical claims, and undisclosed sponsorships are automatically flagged by our moderation systems and always reviewed by a human moderator before action.
        </LegalNotice>
      </LegalSection>
    </LegalPage>
  );
}
