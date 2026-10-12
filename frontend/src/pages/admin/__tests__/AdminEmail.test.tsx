import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { adminPortalApi, type PortalUser, type StaffEmailLog } from '@/api/adminPortal';
import AdminEmail from '@/pages/admin/AdminEmail';

vi.mock('@/api/adminPortal', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/api/adminPortal')>();
  return {
    ...actual,
    adminPortalApi: {
      getEmailLog: vi.fn(),
      sendStaffEmail: vi.fn(),
      resendStaffEmail: vi.fn(),
      getUsers: vi.fn(),
    },
  };
});

const api = adminPortalApi;
const getEmailLog = api.getEmailLog as unknown as ReturnType<typeof vi.fn>;
const sendEmail = api.sendStaffEmail as unknown as ReturnType<typeof vi.fn>;
const resend = api.resendStaffEmail as unknown as ReturnType<typeof vi.fn>;
const getUsers = api.getUsers as unknown as ReturnType<typeof vi.fn>;

const envelope = (data: unknown[], message = '') => ({
  success: true,
  data,
  message,
  errors: null,
  pagination: { count: data.length, next: null, previous: null },
});

const RECIPIENTS: PortalUser[] = [
  { id: 'u-1', email: 'ada@example.com', display_name: 'Ada Lovelace' },
];

const LOG: StaffEmailLog[] = [
  {
    id: 'e-1',
    recipient_email: 'ada@example.com',
    subject: 'Your order has shipped',
    body_preview: 'It left the warehouse this morning.',
    status: 'failed',
    error: 'SMTP refused: 550 mailbox unavailable',
    created_at: '2026-03-01T09:00:00Z',
  },
  {
    id: 'e-2',
    recipient_email: 'grace@example.com',
    subject: 'Welcome to BuddyUp',
    status: 'sent',
    created_at: '2026-03-01T10:00:00Z',
  },
];

const renderPage = () =>
  render(
    <MemoryRouter>
      <AdminEmail />
    </MemoryRouter>,
  );

/** Fill the compose form end to end; the send button needs all three. */
const fillAndSend = async () => {
  fireEvent.change(screen.getByLabelText('Search for the recipient'), { target: { value: 'ada' } });
  const pick = await screen.findByRole('button', { name: /Ada Lovelace/ });
  fireEvent.click(pick);
  fireEvent.change(screen.getByLabelText('Email subject'), { target: { value: 'Your order has shipped' } });
  fireEvent.change(screen.getByLabelText('Email body'), { target: { value: 'It left the warehouse.' } });
  fireEvent.click(screen.getByRole('button', { name: /queue message/i }));
};

beforeEach(() => {
  vi.clearAllMocks();
  getEmailLog.mockResolvedValue(envelope(LOG));
  getUsers.mockResolvedValue(envelope(RECIPIENTS));
  sendEmail.mockResolvedValue(
    envelope(
      { id: 'e-3', recipient_email: 'ada@example.com', status: 'queued' },
      'Message queued for delivery. It is recorded against your staff account whether or not it arrives.',
    ),
  );
  resend.mockResolvedValue(envelope({ id: 'e-4', status: 'queued' }, 'Requeued for delivery.'));
});

describe('AdminEmail — send', () => {
  it('states plainly that sending queues rather than delivers', async () => {
    renderPage();
    expect(await screen.findByText(/Sending queues the message; it does not confirm delivery/)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /queue message/i })).toBeInTheDocument();
  });

  it('will not send without a picked recipient, subject and body', async () => {
    renderPage();
    await screen.findByLabelText('Email subject');
    expect(screen.getByRole('button', { name: /queue message/i })).toBeDisabled();
    expect(screen.getByText(/Pick a registered user first/)).toBeInTheDocument();
  });

  it('sends to the picked user by id, with the subject and body', async () => {
    renderPage();
    await screen.findByLabelText('Email subject');
    await fillAndSend();

    await waitFor(() =>
      expect(sendEmail).toHaveBeenCalledWith({
        user_id: 'u-1',
        subject: 'Your order has shipped',
        body: 'It left the warehouse.',
      }),
    );
  });

  it('confirms with the server\'s own "queued" sentence, not "sent"', async () => {
    renderPage();
    await screen.findByLabelText('Email subject');
    await fillAndSend();

    expect(
      await screen.findByText(/Message queued for delivery\. It is recorded against your staff account/),
    ).toBeInTheDocument();
    expect(screen.queryByText(/message sent successfully|email sent/i)).toBeNull();
  });

  it('surfaces the 429 ceiling sentence, including the number the server quoted', async () => {
    sendEmail.mockRejectedValue(
      Object.assign(new Error('too many'), {
        response: {
          status: 429,
          data: {
            success: false,
            message:
              'You have queued 20 messages in the last hour. The ceiling is 20 per hour — if you genuinely need to send more than that, escalate to an administrator rather than working around this.',
          },
        },
      }),
    );

    renderPage();
    await screen.findByLabelText('Email subject');
    await fillAndSend();

    const banner = await screen.findByText(/You have queued 20 messages in the last hour/);
    expect(banner).toHaveTextContent('The ceiling is 20 per hour');
    // Nothing claims the message went out.
    expect(screen.queryByText(/queued for delivery\. It is recorded/)).toBeNull();
  });

  it("surfaces the API's refusal of an unregistered address", async () => {
    sendEmail.mockRejectedValue(
      Object.assign(new Error('bad request'), {
        response: {
          status: 400,
          data: {
            success: false,
            message: 'No account is registered with this address. This console can only message users who have an account.',
          },
        },
      }),
    );

    renderPage();
    await screen.findByLabelText('Email subject');
    await fillAndSend();

    expect(await screen.findByText(/No account is registered with this address/)).toBeInTheDocument();
  });

  it('tells the operator when a search finds no account', async () => {
    getUsers.mockResolvedValue(envelope([]));
    renderPage();
    await screen.findByLabelText('Email subject');

    fireEvent.change(screen.getByLabelText('Search for the recipient'), { target: { value: 'nobody' } });

    expect(await screen.findByText(/No account matches/)).toBeInTheDocument();
  });
});

describe('AdminEmail — the log', () => {
  it('renders each message with its delivery status', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByText('Your order has shipped')).toBeInTheDocument());
    expect(screen.getByText('Welcome to BuddyUp')).toBeInTheDocument();
    expect(screen.getAllByText('Failed').some((el) => !el.closest('select'))).toBe(true);
    expect(screen.getAllByText('Sent').some((el) => !el.closest('select'))).toBe(true);
    expect(screen.getByText(/SMTP refused/)).toBeInTheDocument();
  });

  it('offers Resend on a failed message only', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByRole('button', { name: /^resend$/i })).toBeInTheDocument());
    expect(screen.getAllByRole('button', { name: /^resend$/i })).toHaveLength(1);
    expect(screen.getByText('Delivered — not resent')).toBeInTheDocument();
  });

  it('resends by id and reports the requeue', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByRole('button', { name: /^resend$/i })).toBeInTheDocument());

    fireEvent.click(screen.getByRole('button', { name: /^resend$/i }));

    await waitFor(() => expect(resend).toHaveBeenCalledWith('e-1'));
    expect(await screen.findByText('Requeued for delivery.')).toBeInTheDocument();
  });

  it("surfaces the 409 when a message that is not failed is resent", async () => {
    resend.mockRejectedValue(
      Object.assign(new Error('conflict'), {
        response: {
          status: 409,
          data: {
            success: false,
            message: 'Only a failed message can be resent; this one is sent.',
          },
        },
      }),
    );

    renderPage();
    await waitFor(() => expect(screen.getByRole('button', { name: /^resend$/i })).toBeInTheDocument());
    fireEvent.click(screen.getByRole('button', { name: /^resend$/i }));

    expect(await screen.findByText(/Only a failed message can be resent/)).toBeInTheDocument();
  });

  it('filters the log by status and recipient', async () => {
    renderPage();
    await waitFor(() => expect(getEmailLog).toHaveBeenCalledTimes(1));

    fireEvent.change(screen.getByLabelText('Status'), { target: { value: 'failed' } });
    await waitFor(() => expect(getEmailLog).toHaveBeenCalledTimes(2));
    expect(getEmailLog.mock.calls[1][0]).toMatchObject({ status: 'failed' });

    fireEvent.change(screen.getByLabelText('Filter by recipient email'), { target: { value: 'ada@example.com' } });
    await waitFor(
      () => {
        const params = getEmailLog.mock.calls[getEmailLog.mock.calls.length - 1][0];
        expect(params.recipient_email).toBe('ada@example.com');
      },
      { timeout: 3000 },
    );
  });
});
