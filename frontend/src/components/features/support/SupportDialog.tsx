import { ClipboardList, Heart } from 'lucide-react';
import { Modal } from '@/components/ui/Modal';
import { Card } from '@/components/ui/Card';
import { FUNDRAISER_URL, PLEDGE_FORM_URL } from '@/config/support';

interface SupportDialogProps {
  open: boolean;
  onClose: () => void;
}

export function SupportDialog({ open, onClose }: SupportDialogProps) {
  return (
    <Modal isOpen={open} onClose={onClose} title="Support BuddyUp" size="md">
      <p className="text-sm text-buddy-text-secondary mb-4">
        Help us keep building your fitness family. Donate to our fundraiser or pledge funding to power
        what&apos;s next.
      </p>
      <div className="grid sm:grid-cols-2 gap-4">
        {FUNDRAISER_URL ? (
          <a href={FUNDRAISER_URL} target="_blank" rel="noopener" className="block">
            <Card className="p-5 h-full hover:bg-buddy-surface-raised transition-colors cursor-pointer">
              <Heart size={28} className="text-buddy-green mb-3" />
              <h3 className="font-heading font-semibold mb-1">Donate</h3>
              <p className="text-sm text-buddy-text-secondary">
                Chip in to our fundraiser and keep BuddyUp free for everyone.
              </p>
            </Card>
          </a>
        ) : (
          <Card className="p-5 h-full opacity-50" aria-disabled="true">
            <Heart size={28} className="text-buddy-text-secondary mb-3" />
            <h3 className="font-heading font-semibold mb-1">Donate</h3>
            <p className="text-sm text-buddy-text-secondary">Coming soon</p>
          </Card>
        )}
        {PLEDGE_FORM_URL ? (
          <a href={PLEDGE_FORM_URL} target="_blank" rel="noopener" className="block">
            <Card className="p-5 h-full hover:bg-buddy-surface-raised transition-colors cursor-pointer">
              <ClipboardList size={28} className="text-buddy-green mb-3" />
              <h3 className="font-heading font-semibold mb-1">Pledge Funding</h3>
              <p className="text-sm text-buddy-text-secondary">
                Pledge funding and we&apos;ll be in touch about next steps.
              </p>
            </Card>
          </a>
        ) : (
          <Card className="p-5 h-full opacity-50" aria-disabled="true">
            <ClipboardList size={28} className="text-buddy-text-secondary mb-3" />
            <h3 className="font-heading font-semibold mb-1">Pledge Funding</h3>
            <p className="text-sm text-buddy-text-secondary">Coming soon</p>
          </Card>
        )}
      </div>
    </Modal>
  );
}
