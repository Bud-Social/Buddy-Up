import { useNavigate } from 'react-router-dom';
import { Card } from '@/components/ui/Card';
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

  return (
    <SectionShell title="Help & Safety">
      <div className="space-y-2">
        {LINKS.map(({ label, desc, link, mailto }) => (
          <Card key={label} className="p-4 hover:bg-buddy-surface-raised cursor-pointer transition-colors"
            onClick={() => { if (mailto) window.open(mailto, '_blank'); else if (link) navigate(link); }}>
            <p className="text-sm font-medium">{label}</p>
            <p className="text-xs text-buddy-text-secondary">{desc}</p>
          </Card>
        ))}
      </div>
    </SectionShell>
  );
}
