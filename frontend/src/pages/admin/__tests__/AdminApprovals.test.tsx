import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { adminPortalApi, type GovernanceApproval } from '@/api/adminPortal';
import AdminApprovals from '@/pages/admin/AdminApprovals';

vi.mock('@/api/adminPortal', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/api/adminPortal')>();
  return {
    ...actual,
    adminPortalApi: {
      getApprovals: vi.fn(),
      getApproval: vi.fn(),
      approveApproval: vi.fn(),
      rejectApproval: vi.fn(),
      cancelApproval: vi.fn(),
      requestApproval: vi.fn(),
    },
  };
});

const api = adminPortalApi;
const getApprovals = api.getApprovals as unknown as ReturnType<typeof vi.fn>;
const approve = api.approveApproval as unknown as ReturnType<typeof vi.fn>;
const reject = api.rejectApproval as unknown as ReturnType<typeof vi.fn>;
const cancel = api.cancelApproval as unknown as ReturnType<typeof vi.fn>;
const request = api.requestApproval as unknown as ReturnType<typeof vi.fn>;

const envelope = (data: unknown[], message = '') => ({
  success: true,
  data,
  message,
  errors: null,
  pagination: { count: data.length, next: null, previous: null },
});

const APPROVALS: GovernanceApproval[] = [
  {
    id: 'a-1',
    action: 'ban',
    action_display: 'Ban Account',
    status: 'pending',
    target_user: { id: 'u-1', email: 'target@example.com', display_name: 'Target User' },
    requested_by: { id: 's-1', email: 'mod@example.com', display_name: 'Mod' },
    requested_by_profile: 'Mod',
    payload: { reason: 'chargeback fraud ring' },
    required_scope: 'users.write',
    requires_second: true,
    applied_at: null,
    created_at: '2026-03-01T09:00:00Z',
  },
];

const renderPage = () =>
  render(
    <MemoryRouter>
      <AdminApprovals />
    </MemoryRouter>,
  );

beforeEach(() => {
  vi.clearAllMocks();
  getApprovals.mockResolvedValue(envelope(APPROVALS));
  approve.mockResolvedValue(envelope(APPROVALS, 'Request approved and applied. The account has been banned.'));
  reject.mockResolvedValue(envelope(APPROVALS, 'Request rejected.'));
  cancel.mockResolvedValue(envelope(APPROVALS, 'Request cancelled.'));
  request.mockResolvedValue(envelope(APPROVALS, 'Request raised. Nothing has been applied.'));
});

describe('AdminApprovals — the queue', () => {
  it('defaults to the pending filter', async () => {
    renderPage();
    await waitFor(() => expect(getApprovals).toHaveBeenCalledTimes(1));
    expect(getApprovals.mock.calls[0][0]).toMatchObject({ status: 'pending' });
  });

  it('shows requester, target, action and payload on a row', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByText(/Target User/)).toBeInTheDocument());
    expect(screen.getByText('target@example.com')).toBeInTheDocument();
    expect(screen.getByText(/Target User/)).toBeInTheDocument();
    expect(screen.getByText('target@example.com')).toBeInTheDocument();
    expect(screen.getByText(/raised by/)).toHaveTextContent('Mod');
    expect(screen.getByText('Ban Account')).toBeInTheDocument();

    fireEvent.click(screen.getByRole('button', { name: /payload/i }));
    expect(screen.getByText('chargeback fraud ring')).toBeInTheDocument();
    expect(screen.getByText('users.write')).toBeInTheDocument();
    expect(screen.getByText('Mod')).toBeInTheDocument();
  });

  it('badges a pending ban as having applied nothing', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByText('Nothing applied yet')).toBeInTheDocument());
  });

  it('filters by action and by mine', async () => {
    renderPage();
    await waitFor(() => expect(getApprovals).toHaveBeenCalledTimes(1));

    fireEvent.change(screen.getByLabelText('Action'), { target: { value: 'suspension' } });
    await waitFor(() => expect(getApprovals).toHaveBeenCalledTimes(2));
    expect(getApprovals.mock.calls[1][0]).toMatchObject({ action: 'suspension' });

    fireEvent.click(screen.getByLabelText('Only requests I raised'));
    await waitFor(() => expect(getApprovals).toHaveBeenCalledTimes(3));
    expect(getApprovals.mock.calls[2][0]).toMatchObject({ mine: true });
  });

  it('shows the empty state when nothing matches', async () => {
    getApprovals.mockResolvedValue(envelope([]));
    renderPage();
    await waitFor(() => expect(screen.getByText(/No requests match/i)).toBeInTheDocument());
  });
});

describe('AdminApprovals — decide', () => {
  it('approves on the approve/ URL with the note that was typed', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByRole('button', { name: /^approve$/i })).toBeInTheDocument());

    fireEvent.click(screen.getByRole('button', { name: /^approve$/i }));
    const confirm = await screen.findByRole('button', { name: /approve and apply/i });
    fireEvent.change(screen.getByLabelText('Internal note'), { target: { value: 'evidence reviewed' } });
    fireEvent.click(confirm);

    await waitFor(() => expect(approve).toHaveBeenCalledWith('a-1', { note: 'evidence reviewed' }));
  });

  it('rejects on the reject/ URL', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByRole('button', { name: /^reject$/i })).toBeInTheDocument());

    fireEvent.click(screen.getByRole('button', { name: /^reject$/i }));
    const confirm = await screen.findByRole('button', { name: /reject request/i });
    fireEvent.change(screen.getByLabelText('Rejection reason'), { target: { value: 'not enough evidence' } });
    fireEvent.click(confirm);

    await waitFor(() => expect(reject).toHaveBeenCalledWith('a-1', { note: 'not enough evidence' }));
    expect(approve).not.toHaveBeenCalled();
  });

  it('cancels on the cancel/ URL', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByRole('button', { name: /^cancel$/i })).toBeInTheDocument());

    fireEvent.click(screen.getByRole('button', { name: /^cancel$/i }));
    const confirm = await screen.findByRole('button', { name: /cancel request/i });
    fireEvent.change(screen.getByLabelText('Rejection reason'), { target: { value: 'raised in error' } });
    fireEvent.click(confirm);

    await waitFor(() => expect(cancel).toHaveBeenCalledWith('a-1', { note: 'raised in error' }));
    expect(approve).not.toHaveBeenCalled();
    expect(reject).not.toHaveBeenCalled();
  });

  it('blocks a reject or cancel with no note, which the API would 400', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByRole('button', { name: /^reject$/i })).toBeInTheDocument());

    fireEvent.click(screen.getByRole('button', { name: /^reject$/i }));
    expect(await screen.findByRole('button', { name: /reject request/i })).toBeDisabled();
  });

  it("surfaces the server's self-approval refusal verbatim", async () => {
    approve.mockRejectedValue(
      Object.assign(new Error('nope'), {
        response: {
          status: 403,
          data: {
            success: false,
            message:
              'The person who raised this request cannot be the one who decides it. Two-person approval requires a different member of staff.',
          },
        },
      }),
    );

    renderPage();
    await waitFor(() => expect(screen.getByRole('button', { name: /^approve$/i })).toBeInTheDocument());
    fireEvent.click(screen.getByRole('button', { name: /^approve$/i }));
    fireEvent.click(await screen.findByRole('button', { name: /approve and apply/i }));

    expect(
      await screen.findByText(/The person who raised this request cannot be the one who decides it/),
    ).toBeInTheDocument();
  });

  it("surfaces the 409 on an already-settled request verbatim", async () => {
    reject.mockRejectedValue(
      Object.assign(new Error('conflict'), {
        response: {
          status: 409,
          data: { success: false, message: 'This request was already approved by someone else on 2026-03-02T10:00:00. It cannot be decided again.' },
        },
      }),
    );

    renderPage();
    await waitFor(() => expect(screen.getByRole('button', { name: /^reject$/i })).toBeInTheDocument());
    fireEvent.click(screen.getByRole('button', { name: /^reject$/i }));
    fireEvent.change(await screen.findByLabelText('Rejection reason'), { target: { value: 'x' } });
    fireEvent.click(screen.getByRole('button', { name: /reject request/i }));

    expect(await screen.findByText(/This request was already approved/)).toBeInTheDocument();
  });

  it('surfaces a missing-scope refusal naming the scope', async () => {
    approve.mockRejectedValue(
      Object.assign(new Error('forbidden'), {
        response: {
          status: 403,
          data: { success: false, message: "Approving a 'ban' request requires the 'users.write' scope, which your role does not include." },
        },
      }),
    );

    renderPage();
    await waitFor(() => expect(screen.getByRole('button', { name: /^approve$/i })).toBeInTheDocument());
    fireEvent.click(screen.getByRole('button', { name: /^approve$/i }));
    fireEvent.click(await screen.findByRole('button', { name: /approve and apply/i }));

    expect(await screen.findByText(/requires the 'users.write' scope/)).toBeInTheDocument();
  });
});

describe('AdminApprovals — raise a request', () => {
  const openForm = async () => {
    renderPage();
    await waitFor(() => expect(screen.getByRole('button', { name: /raise a request/i })).toBeInTheDocument());
    fireEvent.click(screen.getByRole('button', { name: /raise a request/i }));
    await screen.findByLabelText('Requested action');
  };

  it('demands a target and a reason before a ban can be requested', async () => {
    await openForm();
    fireEvent.change(screen.getByLabelText('Requested action'), { target: { value: 'ban' } });
    expect(screen.getByRole('button', { name: /raise request/i })).toBeDisabled();

    fireEvent.change(screen.getByLabelText('Target user id for request'), { target: { value: 'u-1' } });
    expect(screen.getByRole('button', { name: /raise request/i })).toBeDisabled();

    fireEvent.change(screen.getByLabelText('Request reason'), { target: { value: 'fraud ring' } });
    expect(screen.getByRole('button', { name: /raise request/i })).toBeEnabled();
  });

  it('refuses to let a ban carry a duration, as the API does', async () => {
    await openForm();
    fireEvent.change(screen.getByLabelText('Requested action'), { target: { value: 'ban' } });
    expect(screen.queryByLabelText('Request duration in days')).toBeNull();
  });

  it('requires a duration for a suspension', async () => {
    await openForm();
    fireEvent.change(screen.getByLabelText('Requested action'), { target: { value: 'suspension' } });
    fireEvent.change(screen.getByLabelText('Target user id for request'), { target: { value: 'u-1' } });
    fireEvent.change(screen.getByLabelText('Request reason'), { target: { value: 'fraud' } });

    const submit = screen.getByRole('button', { name: /raise request/i });
    expect(submit).toBeDisabled();
    fireEvent.change(screen.getByLabelText('Request duration in days'), { target: { value: '14' } });
    expect(submit).toBeEnabled();

    fireEvent.click(submit);
    await waitFor(() =>
      expect(request).toHaveBeenCalledWith({
        action: 'suspension',
        target_user: 'u-1',
        payload: { reason: 'fraud', duration_days: 14 },
      }),
    );
  });

  it('says a raised request has not been applied', async () => {
    await openForm();
    fireEvent.change(screen.getByLabelText('Requested action'), { target: { value: 'ban' } });
    fireEvent.change(screen.getByLabelText('Target user id for request'), { target: { value: 'u-1' } });
    fireEvent.change(screen.getByLabelText('Request reason'), { target: { value: 'fraud' } });
    fireEvent.click(screen.getByRole('button', { name: /raise request/i }));

    expect(await screen.findByText(/Nothing has been applied/i)).toBeInTheDocument();
  });
});
