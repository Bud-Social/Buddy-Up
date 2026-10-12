import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ChevronDown } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import AccountSafety from './AccountSafety';
import { SectionShell } from './SectionShell';

const LINKS: Array<{ label: string; desc: string; link?: string; mailto?: string }> = [
  { label: 'Help Centre', desc: 'FAQs, reporting, and support contacts', link: '/help' },
  { label: 'Report a Problem', desc: 'Report bugs, abusive content, or safety concerns', mailto: 'mailto:support@buddyup.com' },
  { label: 'Community Guidelines', desc: 'Read our rules for respectful interaction', link: '/community-guidelines' },
  { label: 'Safety Centre', desc: 'Resources and tools for staying safe', link: '/community-guidelines' },
  { label: 'Medical Disclaimer', desc: 'Scope of health and wellness information', link: '/medical-disclaimer' },
  { label: 'Sponsorship Policy', desc: 'Gifting and disclosure requirements', link: '/sponsorship-policy' },
  { label: 'Adult Content Policy', desc: 'Rules for the age-gated Mature category', link: '/adult-content-policy' },
  { label: 'Terms of Service', desc: 'Our terms and conditions', link: '/terms' },
  { label: 'Privacy Policy', desc: 'How we handle your data', link: '/privacy' },
  { label: 'Cookie Policy', desc: 'How we use cookies', link: '/cookie-policy' },
  { label: 'Contact Support', desc: 'Email us at support@buddyup.com', mailto: 'mailto:support@buddyup.com' },
];

export default function Help() {
  const navigate = useNavigate();
  // Open by default. A user who has been suspended needs to read the reason and
  // find the appeal button without hunting for it, and the empty states are one
  // line each — burying a standing that already exists behind a tap is the
  // wrong trade. Collapsible for everyone who has no action on their account.
  const [safetyOpen, setSafetyOpen] = useState(true);

  return (
    <SectionShell title="Help & Safety">
      <div className="space-y-2">
        <Card
          className="p-4 cursor-pointer transition-colors hover:bg-buddy-surface-raised"
          onClick={() => setSafetyOpen((open) => !open)}
          role="button"
          tabIndex={0}
          aria-expanded={safetyOpen}
          onKeyDown={(e) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); setSafetyOpen((open) => !open); } }}
        >
          <div className="flex items-center justify-between gap-3">
            <div className="min-w-0">
              <p className="text-sm font-medium">Moderation, appeals &amp; commendations</p>
              <p className="text-xs text-buddy-text-secondary">
                See any action taken on your account, appeal it, and read your commendations
              </p>
            </div>
            <ChevronDown size={16} className={`text-buddy-text-secondary flex-shrink-0 transition-transform ${safetyOpen ? 'rotate-180' : ''}`} />
          </div>
        </Card>

        {safetyOpen && (
          <div className="pt-2 pb-2">
            <AccountSafety />
          </div>
        )}

        {LINKS.map(({ label, desc, link, mailto }) => (
          <Card key={label} className="p-4 hover:bg-buddy-surface-raised cursor-pointer transition-colors"
            onClick={() => { if (mailto) window.open(mailto, '_blank', 'noopener,noreferrer'); else if (link) navigate(link); }}>
            <p className="text-sm font-medium">{label}</p>
            <p className="text-xs text-buddy-text-secondary">{desc}</p>
          </Card>
        ))}
      </div>
    </SectionShell>
  );
}
