import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { SuggestionForm } from '@/components/features/support/SuggestionForm';
import { ContactForm } from '@/components/features/support/ContactForm';

const mockSubmitSuggestion = vi.fn();
const mockSubmitContact = vi.fn();

vi.mock('@/api/contact', () => ({
  submitSuggestion: (...args: unknown[]) => mockSubmitSuggestion(...args),
  submitContact: (...args: unknown[]) => mockSubmitContact(...args),
}));

describe('SuggestionForm', () => {
  beforeEach(() => {
    mockSubmitSuggestion.mockReset();
  });

  it('renders title, description, and submit button', () => {
    render(<SuggestionForm />);
    expect(screen.getByText('Suggest a feature')).toBeDefined();
    expect(screen.getByRole('button', { name: 'Send suggestion' })).toBeDefined();
  });

  it('shows success state after submit', async () => {
    mockSubmitSuggestion.mockResolvedValue({
      success: true, data: { id: 1 },
      message: 'Thanks — your suggestion is in.', errors: null, pagination: null,
    });
    render(<SuggestionForm />);
    fireEvent.change(screen.getByPlaceholderText('e.g. Corporate step challenges'), {
      target: { value: 'Corporate step challenge' },
    });
    fireEvent.change(screen.getByPlaceholderText('Who is it for, and what would it unlock?'), {
      target: { value: 'For companies with teams.' },
    });
    fireEvent.click(screen.getByRole('button', { name: 'Send suggestion' }));
    await waitFor(() => {
      expect(screen.getByText('Suggestion received')).toBeDefined();
    });
    expect(mockSubmitSuggestion).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Corporate step challenge' }),
    );
  });

  it('shows error message on failure', async () => {
    mockSubmitSuggestion.mockRejectedValue({
      isAxiosError: true,
      response: { data: { message: 'Bad request', errors: null } },
    });
    render(<SuggestionForm />);
    fireEvent.change(screen.getByPlaceholderText('e.g. Corporate step challenges'), {
      target: { value: 'X' },
    });
    fireEvent.change(screen.getByPlaceholderText('Who is it for, and what would it unlock?'), {
      target: { value: 'Y' },
    });
    fireEvent.click(screen.getByRole('button', { name: 'Send suggestion' }));
    await waitFor(() => {
      expect(screen.getByRole('alert')).toBeDefined();
    });
  });
});

describe('ContactForm', () => {
  beforeEach(() => {
    mockSubmitContact.mockReset();
  });

  it('renders and submits a contact message', async () => {
    mockSubmitContact.mockResolvedValue({
      success: true, data: { id: 1 }, message: 'ok', errors: null, pagination: null,
    });
    render(<ContactForm />);
    fireEvent.change(screen.getByPlaceholderText('Alex'), {
      target: { value: 'Alex' },
    });
    fireEvent.change(screen.getByPlaceholderText('you@example.com'), {
      target: { value: 'alex@example.com' },
    });
    fireEvent.change(screen.getByPlaceholderText('How can we help?'), {
      target: { value: 'Hello there.' },
    });
    fireEvent.click(screen.getByRole('button', { name: 'Send message' }));
    await waitFor(() => {
      expect(screen.getByText('Message received')).toBeDefined();
    });
    expect(mockSubmitContact).toHaveBeenCalledWith(
      expect.objectContaining({ email: 'alex@example.com', message: 'Hello there.' }),
    );
  });
});
