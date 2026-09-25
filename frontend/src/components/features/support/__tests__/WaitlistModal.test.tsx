import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { WaitlistModal } from '@/components/features/support/WaitlistModal';

vi.mock('@/api/waitlist', () => ({
  joinWaitlist: vi.fn(),
}));

describe('WaitlistModal', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders nothing when closed', () => {
    const { container } = render(<WaitlistModal isOpen={false} onClose={() => {}} />);
    expect(container).toBeEmptyDOMElement();
  });

  it('pops the waitlist form with the requested interest preselected', () => {
    render(<WaitlistModal isOpen onClose={() => {}} interest="trainer" />);
    expect(screen.getByText('Join the waiting list — launching November')).toBeDefined();
    // Trainer tab active, gym tab available for switching.
    expect(screen.getByRole('tab', { name: /Trainer/i, selected: true })).toBeDefined();
    expect(screen.getByRole('tab', { name: /Gym/i, selected: false })).toBeDefined();
  });

  it('closes via the header close button', () => {
    const onClose = vi.fn();
    render(<WaitlistModal isOpen onClose={onClose} />);
    fireEvent.click(screen.getByRole('button', { name: /close/i }));
    expect(onClose).toHaveBeenCalledTimes(1);
  });

  it('shows the tier name in the title when one is passed', () => {
    render(<WaitlistModal isOpen onClose={() => {}} interest="trainer" tier="Premium" />);
    expect(screen.getByText('Join the waiting list — Premium')).toBeDefined();
    expect(screen.queryByText('Join the waiting list — launching November')).toBeNull();
  });
});
