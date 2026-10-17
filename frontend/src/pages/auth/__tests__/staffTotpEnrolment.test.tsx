import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { authApi } from '@/api';
import { useAuthStore } from '@/store/authStore';
import Login from '@/pages/auth/Login';

/**
 * The staff 2FA enrolment redirect.
 *
 * Without this the flow is a dead end that looks like a plain error: the server
 * answers 403 `mfa_enrolment_required` with a short-lived enrolment credential,
 * and a client that does not recognise the code drops the operator on a login
 * page they just completed, with no way to reach /totp/setup (which is
 * authenticated) and no explanation.
 */
vi.mock('@/api', async (importOriginal) => ({
  ...(await importOriginal<typeof import('@/api')>()),
  authApi: {
    login: vi.fn(),
    verifyLoginOtp: vi.fn(),
    totpChallenge: vi.fn(),
    googleLogin: vi.fn(),
  },
}));

const api = authApi as unknown as Record<string, ReturnType<typeof vi.fn>>;

function renderLogin() {
  return render(
    <MemoryRouter initialEntries={['/login']}>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route
          path="/totp-setup"
          element={<div data-testid="totp-setup-screen">Set up 2FA</div>}
        />
        <Route path="/feed" element={<div data-testid="feed" />} />
      </Routes>
    </MemoryRouter>,
  );
}

const EMAIL = 'staff@example.com';

/** Password step only: stops at the OTP screen. */
async function submitPassword(user = userEvent.setup()) {
  renderLogin();
  await waitFor(() => expect(screen.getByLabelText(/email/i)).toBeInTheDocument());
  await user.type(screen.getByLabelText(/email/i), EMAIL);
  await user.type(screen.getByLabelText(/password/i), 'TestPass123!');
  await user.click(screen.getByRole('button', { name: /sign in|log in/i }));
  await waitFor(() => expect(api.login).toHaveBeenCalled());
  await waitFor(() => expect(screen.getByLabelText(/code/i)).toBeInTheDocument());
  return user;
}

/** Password step, then the email OTP. */
async function completeLogin(user = userEvent.setup()) {
  await submitPassword(user);
  await user.type(screen.getByLabelText(/code/i), '123456');
  await user.click(screen.getByRole('button', { name: /verify|continue/i }));
  return user;
}

describe('staff 2FA enrolment redirect', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    useAuthStore.setState({ totpEnrolmentToken: null });
    api.login.mockResolvedValue({
      success: true,
      data: { require_otp: true, login_token: 'lt', masked_email: 'sta***@example.com' },
    } as never);
  });

  it('sends an OTP before mentioning 2FA at all', async () => {
    await submitPassword();

    // The email OTP is the identity proof, and it comes first: no OTP submitted,
    // no enrolment credential, nothing about 2FA offered yet.
    expect(api.verifyLoginOtp).not.toHaveBeenCalled();
    expect(useAuthStore.getState().totpEnrolmentToken).toBeNull();
  });

  it('redirects to 2FA setup when the server requires enrolment', async () => {
    api.verifyLoginOtp.mockRejectedValue({
      response: {
        data: {
          message: 'Two-factor authentication is required for staff accounts.',
          data: {
            code: 'mfa_enrolment_required',
            enrolment_token: 'enrol-abc',
            enrolment_path: '/api/v1/auth/totp/setup/',
          },
        },
      },
    });

    await completeLogin();

    await waitFor(() => expect(screen.getByTestId('totp-setup-screen')).toBeInTheDocument());
  });

  it('stores the enrolment credential so setup can send it', async () => {
    api.verifyLoginOtp.mockRejectedValue({
      response: {
        data: {
          message: 'Two-factor authentication is required for staff accounts.',
          data: { code: 'mfa_enrolment_required', enrolment_token: 'enrol-abc' },
        },
      },
    });

    await completeLogin();

    await waitFor(() =>
      expect(useAuthStore.getState().totpEnrolmentToken).toBe('enrol-abc'),
    );
  });

  it('never treats the enrolment credential as a session', async () => {
    api.verifyLoginOtp.mockRejectedValue({
      response: {
        data: {
          message: 'Two-factor authentication is required for staff accounts.',
          data: { code: 'mfa_enrolment_required', enrolment_token: 'enrol-abc' },
        },
      },
    });

    await completeLogin();
    await waitFor(() => expect(screen.getByTestId('totp-setup-screen')).toBeInTheDocument());

    // Still anonymous. The credential enrols a device; it is not a login.
    expect(useAuthStore.getState().accessToken).toBeNull();
    expect(useAuthStore.getState().isAuthenticated).toBe(false);
  });

  it('shows the message when the code is something else', async () => {
    api.verifyLoginOtp.mockRejectedValue({
      response: { data: { message: 'Invalid OTP code.' } },
    });

    await completeLogin();

    // A plain failure stays on the page and does not navigate anywhere.
    await waitFor(() => expect(screen.getByText(/invalid otp/i)).toBeInTheDocument());
    expect(screen.queryByTestId('totp-setup-screen')).not.toBeInTheDocument();
  });

  it('ignores the enrolment code when no credential came with it', async () => {
    // Malformed server response: the code is present but unusable. Navigating
    // anyway would land on a setup screen that can only 401.
    api.verifyLoginOtp.mockRejectedValue({
      response: { data: { message: 'Something went wrong.', data: { code: 'mfa_enrolment_required' } } },
    });

    await completeLogin();

    await waitFor(() => expect(screen.getByText(/something went wrong/i)).toBeInTheDocument());
    expect(screen.queryByTestId('totp-setup-screen')).not.toBeInTheDocument();
  });
});

describe('staff 2FA enrolment after social sign-in', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    useAuthStore.setState({ totpEnrolmentToken: null });
    api.googleLogin.mockReset();
  });

  function renderLoginWithGoogle() {
    return render(
      <MemoryRouter initialEntries={['/login']}>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/totp-setup" element={<div data-testid="totp-setup-screen" />} />
          <Route path="/feed" element={<div data-testid="feed" />} />
        </Routes>
      </MemoryRouter>,
    );
  }

  /**
   * The Google button shells out to Google Identity Services via
   * `window.google.accounts.oauth2.initTokenClient`. Absent, it takes its
   * error branch and never reaches the login callback -- so the social paths
   * have to be driven through a stub of that exact contract, not a button
   * click.
   */
  function stubGoogle(credential = 'gid-token') {
    const win = window as unknown as { google?: unknown };
    win.google = {
      accounts: {
        oauth2: {
          initTokenClient: (cfg: { callback: (r: { id_token?: string }) => void }) => ({
            requestAccessToken: () => cfg.callback({ id_token: credential }),
          }),
        },
      },
    };
  }

  async function signInWithGoogle() {
    stubGoogle();
    renderLoginWithGoogle();
    const user = userEvent.setup();
    const button = await screen.findByRole('button', { name: /continue with google/i });
    await user.click(button);
    // Google hands over a credential, but a consent gate stands between that
    // and the login call. Approving it is part of the flow, not a test detail.
    await user.click(await screen.findByRole('button', { name: /allow & continue/i }));
    await waitFor(() => expect(api.googleLogin).toHaveBeenCalled());
    return user;
  }

  it('sends an email OTP instead of opening a session', async () => {
    // The IdP vouches for the user to Google, not to us, so social sign-in is
    // routed through the same email OTP the password path uses.
    api.googleLogin.mockResolvedValue({
      success: true,
      data: {
        require_otp: true,
        login_token: 'lt',
        masked_email: 'sta***@example.com',
        mfa_enrolment_pending: true,
      },
    } as never);

    await signInWithGoogle();

    // No session was accepted, and the user is still anonymous.
    expect(useAuthStore.getState().accessToken).toBeNull();
    expect(useAuthStore.getState().isAuthenticated).toBe(false);
  });

  it('prompts for the emailed code rather than going to the feed', async () => {
    api.googleLogin.mockResolvedValue({
      success: true,
      data: {
        require_otp: true,
        login_token: 'lt',
        masked_email: 'sta***@example.com',
        mfa_enrolment_pending: true,
      },
    } as never);

    await signInWithGoogle();

    await waitFor(() => expect(screen.getByLabelText(/otp code/i)).toBeInTheDocument());
    expect(screen.queryByTestId('feed')).not.toBeInTheDocument();
  });

  it('an ordinary social login still opens the app', async () => {
    api.googleLogin.mockResolvedValue({
      success: true,
      data: {
        access: 'a',
        refresh: 'r',
        user: { id: 'u1', email: 'p@example.com' },
        profile: { user_id: 'u1', username: 'p', display_name: 'P' },
      },
    } as never);

    await signInWithGoogle();

    await waitFor(() => expect(useAuthStore.getState().isAuthenticated).toBe(true));
    await waitFor(() => expect(screen.getByTestId('feed')).toBeInTheDocument());
  });

  it('a social login that still has TOTP asks for the authenticator code', async () => {
    api.googleLogin.mockResolvedValue({
      success: true,
      data: { require_totp: true, temp_token: 'tt' },
    } as never);

    await signInWithGoogle();

    // A different step from the emailed OTP one.
    await waitFor(() => expect(screen.getByLabelText(/authenticator code/i)).toBeInTheDocument());
  });
});