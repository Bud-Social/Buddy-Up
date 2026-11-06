import { render, screen, fireEvent } from '@testing-library/react';
import { WalkthroughOverlay, shouldShowWalkthrough } from '../WalkthroughOverlay';

describe('WalkthroughOverlay', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it('renders the first step', () => {
    render(<WalkthroughOverlay onClose={() => {}} />);
    expect(screen.getByText('Find your buddy')).toBeInTheDocument();
    expect(screen.getByText('1 of 3')).toBeInTheDocument();
  });

  it('advances to the next step', () => {
    render(<WalkthroughOverlay onClose={() => {}} />);
    fireEvent.click(screen.getByText('Next'));
    expect(screen.getByText('Track your streak')).toBeInTheDocument();
    expect(screen.getByText('2 of 3')).toBeInTheDocument();
  });

  it('shows "Let\'s go" on the last step', () => {
    render(<WalkthroughOverlay onClose={() => {}} />);
    fireEvent.click(screen.getByText('Next'));
    fireEvent.click(screen.getByText('Next'));
    expect(screen.getByText("Let's go")).toBeInTheDocument();
    expect(screen.getByText('3 of 3')).toBeInTheDocument();
  });

  it('skip button dismisses and persists', () => {
    const onClose = vi.fn();
    render(<WalkthroughOverlay onClose={onClose} />);
    fireEvent.click(screen.getByText('Skip for now'));
    expect(onClose).toHaveBeenCalled();
    expect(localStorage.getItem('buddyup-walkthrough-seen')).toBe('1');
  });

  it('close button dismisses and persists', () => {
    const onClose = vi.fn();
    render(<WalkthroughOverlay onClose={onClose} />);
    fireEvent.click(screen.getByLabelText('Close walkthrough'));
    expect(onClose).toHaveBeenCalled();
    expect(localStorage.getItem('buddyup-walkthrough-seen')).toBe('1');
  });

  it('shouldShowWalkthrough returns true when not seen', () => {
    expect(shouldShowWalkthrough()).toBe(true);
  });

  it('shouldShowWalkthrough returns false when seen', () => {
    localStorage.setItem('buddyup-walkthrough-seen', '1');
    expect(shouldShowWalkthrough()).toBe(false);
  });
});
