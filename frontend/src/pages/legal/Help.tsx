import LegalPage, { LegalSection, LegalNotice } from './LegalPage';
import { Link } from 'react-router-dom';

const FAQ = [
  {
    q: 'How do I report a post or profile?',
    a: 'Use the Report button on any post, comment, or profile. Reports are reviewed within 24 hours; severe categories (imminent harm, CSAM) are escalated immediately.',
  },
  {
    q: 'Why was my post flagged or removed?',
    a: 'Posts are automatically screened for prohibited content including medical claims, undisclosed sponsorships, and safety violations. Every automatic flag is reviewed by a human moderator before action. You can appeal within 14 days.',
  },
  {
    q: 'What counts as a medical claim on BuddyUp?',
    a: 'Any content claiming a meal plan or programme "treats", "cures", or "manages" a medical condition. Sharing your own experience is fine; giving professional advice outside a verified practitioner relationship is not. See the Medical Disclaimer.',
  },
  {
    q: 'Do I have to disclose gifted products?',
    a: 'Yes. If you received anything of value in exchange for content, disclose it clearly at the start of your post (#ad, Sponsored, Paid partnership). Hidden disclosures are treated as non-disclosure. See the Sponsorship Policy.',
  },
  {
    q: 'How does verification work?',
    a: 'Go to Settings → Verification. You can verify your identity, or apply for Trainer, Practitioner, Shop, or Gym verification. Practitioners must provide credential details including issuer and scope of practice.',
  },
  {
    q: 'How do I export or delete my data?',
    a: 'Go to Settings → Your Data. You can export a full JSON archive of your data or request account deletion. Deletion takes effect after a 30-day grace period during which you can recover the account.',
  },
  {
    q: 'I am 16 or 17. How do I use BuddyUp?',
    a: 'Users aged 16–17 must be co-owned by a verified parent or guardian. You will be asked to provide their name and contact details during registration.',
  },
  {
    q: 'How do I get in touch with support?',
    a: 'Email support@buddyup.app for account help, safety@buddyup.app for safety or content concerns, and privacy@buddyup.app for data protection requests.',
  },
];

export default function Help() {
  return (
    <LegalPage
      title="Help Centre"
      subtitle="Answers to common questions, plus how to reach our support, safety, and data protection teams."
      updatedAt="August 2026"
    >
      <LegalSection title="Frequently Asked Questions">
        <div className="space-y-4">
          {FAQ.map((item) => (
            <div key={item.q}>
              <h3 className="font-medium text-buddy-text-primary mb-1">{item.q}</h3>
              <p className="text-buddy-text-secondary">{item.a}</p>
            </div>
          ))}
        </div>
      </LegalSection>

      <LegalSection title="How to Report">
        <p>You can report content in three ways:</p>
        <ul className="list-disc list-inside space-y-1">
          <li><strong>In-app:</strong> the Report button on any post, comment, profile, or live session</li>
          <li><strong>By email:</strong> <strong>safety@buddyup.app</strong> for content or safety concerns</li>
          <li><strong>For data matters:</strong> <strong>privacy@buddyup.app</strong></li>
        </ul>
        <p className="mt-2">Emergency or imminent-harm situations are escalated immediately. You can report anonymously and our team will keep your identity private where possible.</p>
      </LegalSection>

      <LegalSection title="Regulatory Complaints">
        <p>If you believe content violates Kenya's consumer protection, advertising, or data protection laws, you may:</p>
        <ul className="list-disc list-inside space-y-1">
          <li>Email <strong>safety@buddyup.app</strong> and we will review within the statutory window</li>
          <li>Lodge a complaint with the Kenya Office of the Data Protection Commissioner (ODPC) for data matters</li>
          <li>Report to the relevant consumer protection authority in your jurisdiction</li>
        </ul>
        <p className="mt-2">Complaints are handled through our documented review workflow and every outcome is recorded for audit.</p>
      </LegalSection>

      <LegalSection title="Legal Documents">
        <ul className="space-y-1">
          <li><Link to="/terms" className="text-buddy-accent hover:underline">Terms of Service</Link></li>
          <li><Link to="/privacy" className="text-buddy-accent hover:underline">Privacy Policy</Link></li>
          <li><Link to="/community-guidelines" className="text-buddy-accent hover:underline">Community Guidelines</Link></li>
          <li><Link to="/cookie-policy" className="text-buddy-accent hover:underline">Cookie Policy</Link></li>
          <li><Link to="/medical-disclaimer" className="text-buddy-accent hover:underline">Medical &amp; Wellness Disclaimer</Link></li>
          <li><Link to="/sponsorship-policy" className="text-buddy-accent hover:underline">Sponsorship &amp; Disclosure Policy</Link></li>
          <li><Link to="/adult-content-policy" className="text-buddy-accent hover:underline">Adult Content Policy</Link></li>
        </ul>
        <LegalNotice>
          BuddyUp is a fitness and wellness platform, not a medical service. If you are experiencing a medical emergency, contact your local emergency services immediately.
        </LegalNotice>
      </LegalSection>
    </LegalPage>
  );
}
