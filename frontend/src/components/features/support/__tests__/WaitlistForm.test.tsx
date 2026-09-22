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

  it('submits gym leads with gym details', async () => {
    mockJoin.mockResolvedValue({
      success: true, data: { email: 'g@gym.co' },
      message: 'You joined the waitlist.', errors: null, pagination: null,
    });
    render(<WaitlistForm initialInterest="gym" />);
    fireEvent.change(screen.getByPlaceholderText('Nairobi Iron House'), {
      target: { value: 'Iron House' },
    });
    fireEvent.change(screen.getByPlaceholderText('Nairobi'), {
      target: { value: 'Nairobi' },
    });
    fireEvent.change(screen.getByPlaceholderText('you@example.com'), {
      target: { value: 'g@gym.co' },
    });
    fireEvent.change(screen.getByLabelText('Country'), {
      target: { value: 'Kenya' },
    });
    fireEvent.click(screen.getByRole('button', { name: 'Notify me' }));
    await waitFor(() => {
      expect(screen.getByText("You're on the list")).toBeDefined();
    });
    expect(mockJoin).toHaveBeenCalledWith(
      expect.objectContaining({
        interest: 'gym',
        metadata: expect.objectContaining({ gym_name: 'Iron House', city: 'Nairobi' }),
      }),
    );
  });

  it('submits trainer leads with trainer details', async () => {
    mockJoin.mockResolvedValue({
      success: true, data: { email: 't@coach.me' },
      message: 'You joined the waitlist.', errors: null, pagination: null,
    });
    render(<WaitlistForm initialInterest="trainer" />);
    fireEvent.change(screen.getByPlaceholderText('Nairobi'), {
      target: { value: 'Kisumu' },
    });
    fireEvent.change(screen.getByPlaceholderText('you@example.com'), {
      target: { value: 't@coach.me' },
    });
    fireEvent.change(screen.getByLabelText('Country'), {
      target: { value: 'Kenya' },
    });
    fireEvent.click(screen.getByRole('button', { name: 'Notify me' }));
    await waitFor(() => {
      expect(screen.getByText("You're on the list")).toBeDefined();
    });
    expect(mockJoin).toHaveBeenCalledWith(
      expect.objectContaining({
        interest: 'trainer',
        metadata: expect.objectContaining({ city: 'Kisumu', role: 'trainer' }),
      }),
    );
  });

  it('submits corporate leads with company details', async () => {
    mockJoin.mockResolvedValue({
      success: true, data: { email: 'hr@acme.co' },
      message: 'You joined the waitlist.', errors: null, pagination: null,
    });
    render(<WaitlistForm initialInterest="corporate" />);
    fireEvent.change(screen.getByPlaceholderText('Acme Ltd'), {
      target: { value: 'Acme Ltd' },
    });
    fireEvent.change(screen.getByPlaceholderText('Nairobi'), {
      target: { value: 'Nairobi' },
    });
    fireEvent.change(screen.getByPlaceholderText('you@example.com'), {
      target: { value: 'hr@acme.co' },
    });
    fireEvent.change(screen.getByLabelText('Country'), {
      target: { value: 'Kenya' },
    });
    fireEvent.click(screen.getByRole('button', { name: 'Team challenges' }));
    fireEvent.click(screen.getByRole('button', { name: 'Notify me' }));
    await waitFor(() => {
      expect(screen.getByText("You're on the list")).toBeDefined();
    });
    expect(mockJoin).toHaveBeenCalledWith(
      expect.objectContaining({
        interest: 'corporate',
        metadata: expect.objectContaining({
          company_name: 'Acme Ltd', city: 'Nairobi', packages: ['challenges'],
        }),
      }),
    );
  });

  it('submits supplier leads with business details', async () => {
    mockJoin.mockResolvedValue({
      success: true, data: { email: 'shop@fit.co' },
      message: 'You joined the waitlist.', errors: null, pagination: null,
    });
    render(<WaitlistForm initialInterest="supplier" />);
    fireEvent.change(screen.getByPlaceholderText('FitFuel Supplies'), {
      target: { value: 'FitFuel' },
    });
    fireEvent.change(screen.getByPlaceholderText('Nairobi'), {
      target: { value: 'Nairobi' },
    });
    fireEvent.change(screen.getByPlaceholderText('you@example.com'), {
      target: { value: 'shop@fit.co' },
    });
    fireEvent.change(screen.getByLabelText('Country'), {
      target: { value: 'Kenya' },
    });
    fireEvent.click(screen.getByRole('button', { name: 'Supplements' }));
    fireEvent.click(screen.getByRole('button', { name: 'Notify me' }));
    await waitFor(() => {
      expect(screen.getByText("You're on the list")).toBeDefined();
    });
    expect(mockJoin).toHaveBeenCalledWith(
      expect.objectContaining({
        interest: 'supplier',
        metadata: expect.objectContaining({
          business: 'FitFuel', city: 'Nairobi', categories: ['supplements'],
        }),
      }),
    );
  });
});
