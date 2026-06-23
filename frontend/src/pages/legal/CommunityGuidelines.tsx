export default function CommunityGuidelines() {
  return (
    <div className="min-h-screen bg-buddy-black">
      <div className="max-w-3xl mx-auto px-6 py-16">
        <h1 className="font-display text-4xl font-extrabold mb-2">Community Guidelines</h1>
        <p className="text-buddy-text-secondary text-sm mb-12">Version 1.0 — Last updated June 2025</p>

        <div className="prose prose-invert max-w-none space-y-8 text-sm leading-relaxed text-buddy-text-secondary">
          <p className="text-buddy-text-primary">BuddyUp exists to help people find their fitness family. These guidelines keep our community safe, inclusive, and focused on health and wellness.</p>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">1. Health & Safety</h2>
            <div className="space-y-2">
              <p><strong>No promotion of eating disorders.</strong> Content promoting extreme restriction, purging, or other disordered eating behaviours is prohibited.</p>
              <p><strong>No dangerous health advice.</strong> Do not promote unverified supplements, unlicensed drugs, or dangerous practices (e.g., dehydration for weight cutting without medical supervision).</p>
              <p><strong>Professional guidance disclaimer.</strong> Users who are not verified practitioners must include a disclaimer when sharing health information. Only verified practitioners may present advice as professional guidance.</p>
              <p><strong>No PED promotion.</strong> Promotion of performance-enhancing drugs is prohibited except for factual educational content from verified practitioners.</p>
              <p><strong>No dangerous stunts.</strong> Content depicting extreme self-harm in the context of fitness or misuse of equipment will be removed.</p>
              <p><strong>Scope of practice.</strong> Health practitioners must provide advice only within their scope of practice and supported by evidence.</p>
            </div>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">2. Age Safety</h2>
            <div className="space-y-2">
              <p><strong>Platform strictly 16+.</strong> Any accounts confirmed to belong to persons under 16 are permanently terminated.</p>
              <p><strong>No content targeting minors.</strong> No content sexualising minors or designed to appeal inappropriately to persons under 16.</p>
              <p><strong>Zero tolerance for CSAM.</strong> Any creation or sharing of child sexual abuse material results in immediate account termination and reporting to relevant authorities (NCMEC and local law enforcement).</p>
            </div>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">3. Respect & Inclusion</h2>
            <div className="space-y-2">
              <p><strong>No hate speech.</strong> Zero tolerance for hate speech targeting any person based on body size/shape, race, ethnicity, religion, gender, sexual orientation, disability, or nationality.</p>
              <p><strong>No body-shaming.</strong> No fat-phobia, body-shaming, diet-culture extremism, or derogatory comments about anyone's appearance or physical abilities.</p>
              <p><strong>No bullying or harassment.</strong> No targeted abuse, intimidation, or coordinated attacks against any user.</p>
              <p><strong>No spam.</strong> No coordinated inauthentic behaviour, spam, or artificial engagement.</p>
              <p><strong>No impersonation.</strong> No impersonation of verified trainers, practitioners, or public figures.</p>
            </div>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">4. Commercial Integrity</h2>
            <div className="space-y-2">
              <p><strong>No fraudulent services.</strong> Do not claim certifications you do not hold or take payment without delivering promised services.</p>
              <p><strong>No fake reviews.</strong> Reviews must reflect genuine experiences with the trainer, practitioner, or product.</p>
              <p><strong>No artificial metrics.</strong> Do not purchase followers, likes, or engagement. Do not use bots.</p>
              <p><strong>Disclose sponsorships.</strong> Promoted or sponsored content must be clearly disclosed with a "Sponsored" or "Paid Partnership" tag.</p>
            </div>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">5. Privacy</h2>
            <div className="space-y-2">
              <p><strong>No doxxing.</strong> Do not share another person's private information without their consent.</p>
              <p><strong>No unauthorised recording.</strong> Do not record or share content from private groups or lives without consent of all participants.</p>
            </div>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">6. Enforcement</h2>
            <div className="space-y-2">
              <p><strong>1st minor violation:</strong> Warning + content removal</p>
              <p><strong>2nd minor / 1st moderate:</strong> 24-hour content posting suspension</p>
              <p><strong>3rd minor / 2nd moderate / 1st severe:</strong> 7-day full suspension</p>
              <p><strong>4th / 2nd severe:</strong> 30-day suspension + mandatory account review</p>
              <p><strong>5th / any critical:</strong> Permanent ban + potential law enforcement referral</p>
              <p className="mt-3">Users may appeal enforcement actions within 14 days through the Help & Safety section in Settings.</p>
            </div>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">7. Reporting</h2>
            <p>Report violations via the Report button on any post, comment, or profile. Reports are reviewed within 24 hours. Severe categories are escalated within 1 hour.</p>
          </section>
        </div>
      </div>
    </div>
  );
}
