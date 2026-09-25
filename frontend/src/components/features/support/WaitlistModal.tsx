import { Modal } from '@/components/ui/Modal';
import { WaitlistForm } from './WaitlistForm';
import type { WaitlistInterest } from '@/api/waitlist';

interface WaitlistModalProps {
  isOpen: boolean;
  onClose: () => void;
  /** Interest tab preselected when the popup opens. */
  interest?: WaitlistInterest;
  /** Optional plan/source name shown in the title, e.g. "Premium" or "Trainer Pro". */
  tier?: string;
}

/**
 * Popup wrapper around the waitlist form. Landing CTAs ("Get Started Free",
 * "Join as a Trainer", "Create a Gym", …) open this instead of navigating to
 * the prelaunch signup flow. `key` remounts the form whenever the requested
 * interest changes, so the correct tab is preselected on every open.
 */
export function WaitlistModal({ isOpen, onClose, interest = 'user', tier }: WaitlistModalProps) {
  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      size="xl"
      title={tier ? `Join the waiting list — ${tier}` : 'Join the waiting list — launching November'}
    >
      {isOpen ? <WaitlistForm key={interest} initialInterest={interest} /> : null}
    </Modal>
  );
}
