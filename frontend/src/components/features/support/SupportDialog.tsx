import { Briefcase, ClipboardList, Heart } from 'lucide-react';
import { Modal } from '@/components/ui/Modal';
import { Card } from '@/components/ui/Card';
import { SUPPORT_LINKS } from '@/config/support';

interface SupportDialogProps {
  open: boolean;
  onClose: () => void;
}

export function SupportDialog({ open, onClose }: SupportDialogProps) {
  return (
    <Modal isOpen={open} onClose={onClose} title="Support BuddyUp" size="md">
      <p className="text-sm text-buddy-text-secondary mb-4">
        Help us keep building your fitness family. Donate to our fundraiser, pledge funding,
        or partner your brand with us to power what&apos;s next.
      </p>
      <div className="grid sm:grid-cols-2 gap-4">
        {SUPPORT_LINKS.fundraiserUrl ? (
          <a href={SUPPORT_LINKS.fundraiserUrl} target="_blank" rel="noreferrer noopener" className="block">
            <Card className="p-5 h-full hover:bg-buddy-surface-raised transition-colors cursor-pointer">
              <Heart size={28} className="text-buddy-green mb-3" />
              <h3 className="font-heading font-semibold mb-1">Donate</h3>
              <p className="text-sm text-buddy-text-secondary">
                Chip in to our fundraiser and keep BuddyUp free for everyone.
              </p>
            </Card>
          </a>
        ) : (
          <Card className="p-5 h-full opacity-60" aria-disabled="true">
            <Heart size={28} className="text-buddy-green mb-3" />
            <h3 className="font-heading font-semibold mb-1">Donate</h3>
            <p className="text-sm text-buddy-text-secondary">
              Coming soon — the fundraiser link is not configured in this build.
            </p>
          </Card>
        )}
        {SUPPORT_LINKS.pledgeFormUrl ? (
          <a href={SUPPORT_LINKS.pledgeFormUrl} target="_blank" rel="noreferrer noopener" className="block">
            <Card className="p-5 h-full hover:bg-buddy-surface-raised transition-colors cursor-pointer">
              <ClipboardList size={28} className="text-buddy-green mb-3" />
              <h3 className="font-heading font-semibold mb-1">Pledge Funding</h3>
              <p className="text-sm text-buddy-text-secondary">
                Pledge funding and we&apos;ll be in touch about next steps.
              </p>
            </Card>
          </a>
        ) : (
          <Card className="p-5 h-full opacity-60" aria-disabled="true">
            <ClipboardList size={28} className="text-buddy-green mb-3" />
            <h3 className="font-heading font-semibold mb-1">Pledge Funding</h3>
            <p className="text-sm text-buddy-text-secondary">
              Coming soon — the pledge link is not configured in this build.
            </p>
          </Card>
        )}
        {SUPPORT_LINKS.partnershipFormUrl ? (
          <a href={SUPPORT_LINKS.partnershipFormUrl} target="_blank" rel="noreferrer noopener" className="block sm:col-span-2">
            <Card className="p-5 h-full hover:bg-buddy-surface-raised transition-colors cursor-pointer">
              <Briefcase size={28} className="text-buddy-gold mb-3" />
              <h3 className="font-heading font-semibold mb-1">Partnership Proposal for Brands</h3>
              <p className="text-sm text-buddy-text-secondary">
                Sponsor challenges, events, and gym spaces — put your brand in front of
                Kenya&apos;s fitness family.
              </p>
            </Card>
          </a>
        ) : (
          <Card className="p-5 h-full opacity-60 sm:col-span-2" aria-disabled="true">
            <Briefcase size={28} className="text-buddy-gold mb-3" />
            <h3 className="font-heading font-semibold mb-1">Partnership Proposal for Brands</h3>
            <p className="text-sm text-buddy-text-secondary">
              Coming soon — the partnership form is not configured in this build.
            </p>
          </Card>
        )}
      </div>
    </Modal>
  );
}
