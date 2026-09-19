import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { WaitlistForm } from '@/components/features/support/WaitlistForm';

const mockJoin = vi.fn();

vi.mock('@/api/waitlist', () => ({
  joinWaitlist: (...args: unknown[]) => mockJoin(...args),
}));

describe('WaitlistForm', () => {
  beforeEach(() => {
    mockJoin.mockReset();
  });

  it('renders email field and submit button', () => {
    render(<WaitlistForm />);
    expect(screen.getByText('Join the Waiting List')).toBeDefined();
    expect(screen.getByRole('button', { name: 'Notify me' })).toBeDefined();
  });

  it('shows success state after signup', async () => {
    mockJoin.mockResolvedValue({
      success: true, data: { email: 'a@b.c' },
      message: 'You joined the waitlist.', errors: null, pagination: null,
    });
    render(<WaitlistForm />);
    fireEvent.change(screen.getByPlaceholderText('you@example.com'), {
      target: { value: 'a@b.c' },
    });
    fireEvent.change(screen.getByLabelText('Country'), {
      target: { value: 'Kenya' },
    });
    fireEvent.click(screen.getByRole('button', { name: 'Notify me' }));
    await waitFor(() => {
      expect(screen.getByText("You're on the list")).toBeDefined();
    });
    expect(mockJoin).toHaveBeenCalledWith(
      expect.objectContaining({ email: 'a@b.c', country: 'Kenya' }),
    );
  });

  it('shows error message on failure', async () => {
    mockJoin.mockRejectedValue({
      isAxiosError: true,
      response: { data: { message: 'Bad email', errors: null } },
    });
    render(<WaitlistForm />);
    fireEvent.change(screen.getByPlaceholderText('you@example.com'), {
      target: { value: 'a@b.c' },
    });
    fireEvent.click(screen.getByRole('button', { name: 'Notify me' }));
    await waitFor(() => {
      expect(screen.getByRole('alert')).toBeDefined();
    });
  });
});
