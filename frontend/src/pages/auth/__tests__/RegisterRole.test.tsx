import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { authApi } from '@/api';
import Register from '@/pages/auth/Register';

/**
 * Registration can no longer grant a professional role.
 *
 * `RegisterSerializer.validate_role` refuses anything but `user`, so a form that
 * still offered "Trainer" would either 400 the whole sign-up or — worse, and the
 * reason this is pinned by a test rather than a comment — look like it had
 * applied. The role now arrives through a two-person verification decision, so
 * the form's job is to send no role at all and point at the application flow.
 */

vi.mock('@/api', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/api')>();
  return {
    ...actual,
    authApi: {
      ...actual.authApi,
      register: vi.fn(),
      googleLogin: vi.fn(),
    },
  };
});

const register = authApi.register as unknown as ReturnType<typeof vi.fn>;

const renderPage = (route = '/signup') =>
  render(
    <MemoryRouter initialEntries={[route]}>
      <Register />
    </MemoryRouter>,
  );

/** Fill step 1 and step 2 so the submit fires. */
const completeSignUp = async () => {
  fireEvent.change(screen.getByLabelText('Email'), { target: { value: 'member@example.com' } });
  fireEvent.change(screen.getByLabelText('Password'), { target: { value: 'Str0ngPassphrase' } });
  fireEvent.click(screen.getByLabelText(/I agree to the/i));
  fireEvent.click(screen.getByLabelText(/I am 16 years of age or older/i));
  fireEvent.click(screen.getByRole('button', { name: 'Continue' }));

  fireEvent.change(screen.getByLabelText('Day'), { target: { value: '4' } });
  fireEvent.change(screen.getByLabelText('Month'), { target: { value: '5' } });
  fireEvent.change(screen.getByLabelText('Year'), { target: { value: '1995' } });
  fireEvent.click(screen.getByRole('button', { name: 'Create Account' }));
};

beforeEach(() => {
  vi.clearAllMocks();
  register.mockResolvedValue({
    data: { registration_token: 'tok', email: 'member@example.com', user_id: 'u-1' },
  });
  window.history.pushState({}, '', '/signup');
});

describe('Register — no self-declared role', () => {
  it('offers no role selector at all', () => {
    renderPage();

    expect(screen.queryByRole('button', { name: /^Trainer$/ })).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /^Practitioner$/ })).not.toBeInTheDocument();
    expect(screen.queryByText("I'm joining as")).not.toBeInTheDocument();
  });

  it('never sends a role in the registration payload', async () => {
    renderPage();
    await completeSignUp();

    await waitFor(() => expect(register).toHaveBeenCalledTimes(1));
    const payload = register.mock.calls[0][0];

    expect(payload).not.toHaveProperty('role');
    expect(Object.keys(payload)).not.toContain('role');
    expect(payload.email).toBe('member@example.com');
  });

  it('routes a would-be trainer or practitioner to the application flow', () => {
    renderPage();

    expect(screen.getByText(/Joining as a member/i)).toBeInTheDocument();
    const link = screen.getByRole('link', { name: /Apply for a category/i });
    expect(link).toHaveAttribute('href', '/verification/categories');
  });

  it('explains a legacy ?role=trainer link instead of silently dropping it', () => {
    renderPage('/signup?role=trainer');

    expect(screen.getByText(/can no longer be chosen at sign-up/i)).toBeInTheDocument();
    expect(screen.getByText(/two\s+people, not one/i)).toBeInTheDocument();
  });
});