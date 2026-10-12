import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { adminPortalApi, type ModerationReportRow } from '@/api/adminPortal';
import AdminModeration from '@/pages/admin/AdminModeration';

vi.mock('@/api/adminPortal', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/api/adminPortal')>();
  return {
    ...actual,
    adminPortalApi: {
      getModerationReports: vi.fn(),
      assignModerationReport: vi.fn(),
      handleModerationReport: vi.fn(),
      getUsers: vi.fn(),
      getContentFlags: vi.fn(),
      getContentFlagStats: vi.fn(),
      actOnContentFlag: vi.fn(),
      getPendingApprovals: vi.fn(),
      getModerationActions: vi.fn(),
      createModerationAction: vi.fn(),
      reverseModerationAction: vi.fn(),
      getCommendations: vi.fn(),
      createCommendation: vi.fn(),
      revokeCommendation: vi.fn(),
    },
  };
});

const api = adminPortalApi;
const getReports = api.getModerationReports as unknown as ReturnType<typeof vi.fn>;
const assignReport = api.assignModerationReport as unknown as ReturnType<typeof vi.fn>;
const handleReport = api.handleModerationReport as unknown as ReturnType<typeof vi.fn>;
const getPending = api.getPendingApprovals as unknown as ReturnType<typeof vi.fn>;
const getActions = api.getModerationActions as unknown as ReturnType<typeof vi.fn>;
const createAction = api.createModerationAction as unknown as ReturnType<typeof vi.fn>;
const getCommendations = api.getCommendations as unknown as ReturnType<typeof vi.fn>;

const envelope = (data: unknown[], pagination?: { count: number; next: string | null; previous: string | null }) => ({
  success: true,
  data,
  message: '',
  errors: null,
  pagination: pagination ?? { count: data.length, next: null, previous: null },
});

const REPORTS: ModerationReportRow[] = [
  {
    id: 'r-1',
    reason: 'harassment',
    description: 'Targeted abuse in a comment thread.',
    status: 'open',
    assigned_to: null,
    sla_due_at: new Date(Date.now() - 3_600_000).toISOString(),
    sla_breached: true,
    created_at: '2026-03-01T09:00:00Z',
  },
  {
    id: 'r-2',
    reason: 'spam',
    description: 'Repeated promotional DMs.',
    status: 'investigating',
    assigned_to: 'staff-uuid-1',
    sla_due_at: new Date(Date.now() + 7_200_000).toISOString(),
    sla_breached: false,
    created_at: '2026-03-01T10:00:00Z',
  },
];

const renderPage = () =>
  render(
    <MemoryRouter>
      <AdminModeration />
    </MemoryRouter>,
  );

beforeEach(() => {
  vi.clearAllMocks();
  getReports.mockResolvedValue(envelope(REPORTS));
  assignReport.mockResolvedValue(envelope(REPORTS[0])[0] ? { success: true, data: REPORTS[0], message: 'Report assigned.', errors: null, pagination: null } : {});
  handleReport.mockResolvedValue({ success: true, data: REPORTS[0], message: '', errors: null, pagination: null });
  getPending.mockResolvedValue(envelope([]));
  getActions.mockResolvedValue(envelope([]));
  createAction.mockResolvedValue({ success: true, data: { id: 'ma-1', action: 'warning' }, message: 'Warning issued and the user has been notified.', errors: null, pagination: null });
  getCommendations.mockResolvedValue(envelope([]));
});

describe('AdminModeration — report assignment', () => {
  it('renders a row per report with its status', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByText(/Targeted abuse in a comment thread/)).toBeInTheDocument());
    expect(screen.getByText(/Repeated promotional DMs/)).toBeInTheDocument();
    expect(screen.getAllByText('Open').some((el) => !el.closest('select'))).toBe(true);
    expect(screen.getAllByText('Investigating').some((el) => !el.closest('select'))).toBe(true);
  });

  it('shows who a report is assigned to, and marks the unassigned ones', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByText(/Assigned #staff-/)).toBeInTheDocument());
    // Stat card, filter chip and row badge all say "Unassigned".
    expect(screen.getAllByText('Unassigned').length).toBeGreaterThan(1);
  });

  it('offers "assign to me" only on an unassigned report', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByRole('button', { name: /assign to me/i })).toBeInTheDocument());
    expect(screen.getByRole('button', { name: /^unassign$/i })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /assign to someone/i })).toBeInTheDocument();
  });

  it('assigns a report to the signed-in moderator', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByRole('button', { name: /assign to me/i })).toBeInTheDocument());

    fireEvent.click(screen.getByRole('button', { name: /assign to me/i }));

    await waitFor(() =>
      expect(assignReport).toHaveBeenCalledWith('r-1', { assigned_to: 'me' }),
    );
  });

  it('unassigns with an explicit null rather than omitting the field', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByRole('button', { name: /^unassign$/i })).toBeInTheDocument());

    fireEvent.click(screen.getByRole('button', { name: /^unassign$/i }));

    await waitFor(() => expect(assignReport).toHaveBeenCalledWith('r-2', { assigned_to: null }));
    const [, payload] = assignReport.mock.calls[0];
    expect(payload).toHaveProperty('assigned_to');
  });

  it('sends assigned_to=me when the "assigned to me" chip is active', async () => {
    renderPage();
    await waitFor(() => expect(getReports).toHaveBeenCalledTimes(1));

    fireEvent.click(screen.getByRole('button', { name: /assigned to me/i }));

    await waitFor(() => expect(getReports).toHaveBeenCalledTimes(2));
    expect(getReports.mock.calls[1][0]).toMatchObject({ assigned_to: 'me' });
  });

  it('sends unassigned=true rather than the sentinel "unassigned"', async () => {
    renderPage();
    await waitFor(() => expect(getReports).toHaveBeenCalledTimes(1));

    fireEvent.click(screen.getByRole('button', { name: /^unassigned$/i }));

    await waitFor(() => expect(getReports).toHaveBeenCalledTimes(2));
    const params = getReports.mock.calls[1][0];
    expect(params.unassigned).toBe(true);
    // `assigned_to=unassigned` would be a 400 naming the bad value.
    expect(params.assigned_to ?? 'all').not.toBe('unassigned');
  });
});

describe('AdminModeration — SLA', () => {
  it('marks a breached report clearly and counts it', async () => {
    renderPage();
    await waitFor(() => expect(screen.getAllByText(/SLA breached/).length).toBeGreaterThan(0));
    // The badge reads as a countdown ("…overdue"), not as a timestamp, and the
    // stat card counts the same rows.
    expect(screen.getAllByText(/overdue/).length).toBeGreaterThan(0);
  });

  it('shows a countdown rather than a raw timestamp for an in-window report', async () => {
    renderPage();
    await waitFor(() => expect(screen.getAllByText(/SLA .*left/).length).toBeGreaterThan(0));
    expect(screen.getByText(/SLA .*left/).textContent).toMatch(/left/);
  });

  it('never renders a raw overdue date as a countdown', async () => {
    renderPage();
    await waitFor(() => expect(screen.getAllByText(/SLA breached/).length).toBeGreaterThan(0));
    screen.getAllByText(/SLA breached/).forEach((el) => expect(el.textContent).not.toContain('2026-'));
  });
});

describe('AdminModeration — disciplinary actions', () => {
  const openActionsTab = async () => {
    renderPage();
    await waitFor(() => expect(screen.getByRole('button', { name: /action ledger/i })).toBeInTheDocument());
    fireEvent.click(screen.getByRole('button', { name: /action ledger/i }));
    await screen.findByLabelText('Action reason');
  };

  it('requires a reason before an action can be raised', async () => {
    await openActionsTab();
    fireEvent.change(screen.getByLabelText('Target user id'), { target: { value: 'u-1' } });
    expect(screen.getByRole('button', { name: /issue warning/i })).toBeDisabled();

    fireEvent.change(screen.getByLabelText('Action reason'), { target: { value: 'medical claim in a meal plan' } });
    expect(screen.getByRole('button', { name: /issue warning/i })).toBeEnabled();
  });

  it('requires a duration in days for a suspension, because the API refuses a duration-less one', async () => {
    await openActionsTab();
    fireEvent.change(screen.getByLabelText('Disciplinary action'), { target: { value: 'user_suspended' } });
    fireEvent.change(screen.getByLabelText('Target user id'), { target: { value: 'u-1' } });
    fireEvent.change(screen.getByLabelText('Action reason'), { target: { value: 'chargeback fraud' } });

    const submit = screen.getByRole('button', { name: /raise for approval/i });
    expect(submit).toBeDisabled();

    fireEvent.change(screen.getByLabelText('Duration in days'), { target: { value: '30' } });
    expect(submit).toBeEnabled();

    fireEvent.click(submit);
    await waitFor(() =>
      expect(createAction).toHaveBeenCalledWith({
        action: 'user_suspended',
        target_user: 'u-1',
        reason: 'chargeback fraud',
        duration_days: 30,
      }),
    );
  });

  it('does not offer a duration for a permanent ban — the API refuses one', async () => {
    await openActionsTab();
    fireEvent.change(screen.getByLabelText('Disciplinary action'), { target: { value: 'user_banned' } });
    expect(screen.queryByLabelText('Duration in days')).toBeNull();
    expect(screen.getByText(/A ban is permanent|permanent/i)).toBeInTheDocument();
  });

  it('says "awaiting a second approver" for a ban instead of claiming it succeeded', async () => {
    // This is the 202 shape: `applied: false` with the server's own sentence.
    createAction.mockResolvedValue({
      success: true,
      data: { applied: false, approval: { id: 'a-1', status: 'pending' } },
      message: 'user_banned requires a second approver. The request has been raised in the governance queue and nothing has been applied yet.',
      errors: null,
      pagination: null,
    });

    await openActionsTab();
    fireEvent.change(screen.getByLabelText('Disciplinary action'), { target: { value: 'user_banned' } });
    fireEvent.change(screen.getByLabelText('Target user id'), { target: { value: 'u-1' } });
    fireEvent.change(screen.getByLabelText('Action reason'), { target: { value: 'chargeback fraud ring' } });
    fireEvent.click(screen.getByRole('button', { name: /issue warning|raise for approval/i }));

    const notice = await screen.findByText(/nothing has been applied yet/i);
    expect(notice.textContent).toMatch(/second approver/i);
    // And nothing anywhere claims the ban happened.
    expect(screen.queryByText(/banned successfully|has been banned/i)).toBeNull();
  });

  it('confirms a warning, which the API applies immediately (201, no `applied` key)', async () => {
    await openActionsTab();
    fireEvent.change(screen.getByLabelText('Target user id'), { target: { value: 'u-1' } });
    fireEvent.change(screen.getByLabelText('Action reason'), { target: { value: 'medical claim' } });
    fireEvent.click(screen.getByRole('button', { name: /issue warning/i }));

    expect(await screen.findByText(/Warning issued and the user has been notified/i)).toBeInTheDocument();
  });

  it("surfaces the server's own refusal verbatim", async () => {
    createAction.mockRejectedValue(
      Object.assign(new Error('nope'), {
        response: {
          status: 403,
          data: { success: false, message: "Raising a 'ban' request requires the 'users.write' scope, which your role does not include." },
        },
      }),
    );

    await openActionsTab();
    fireEvent.change(screen.getByLabelText('Disciplinary action'), { target: { value: 'user_banned' } });
    fireEvent.change(screen.getByLabelText('Target user id'), { target: { value: 'u-1' } });
    fireEvent.change(screen.getByLabelText('Action reason'), { target: { value: 'fraud' } });
    fireEvent.click(screen.getByRole('button', { name: /issue warning|raise for approval/i }));

    expect(await screen.findByText(/requires the 'users.write' scope/)).toBeInTheDocument();
  });

  it('requires a reason before an action can be reversed', async () => {
    getActions.mockResolvedValue(envelope([
      { id: 'ma-1', action: 'user_banned', target_user: 'u-1', reason: 'fraud', is_reversed: false, created_at: '2026-03-01T00:00:00Z' },
    ]));
    await openActionsTab();

    fireEvent.click(await screen.findByRole('button', { name: /reverse action/i }));
    const confirm = await screen.findByRole('button', { name: /reverse this action/i });
    expect(confirm).toBeDisabled();

    fireEvent.change(screen.getByLabelText('Internal note'), { target: { value: 'appeal upheld' } });
    expect(confirm).toBeEnabled();

    fireEvent.click(confirm);
    await waitFor(() =>
      expect(api.reverseModerationAction).toHaveBeenCalledWith('ma-1', { reason: 'appeal upheld' }),
    );
  });
});

describe('AdminModeration — pending approvals', () => {
  it('surfaces bans that are still waiting, with how long they have waited', async () => {
    getPending.mockResolvedValue(envelope([
      {
        id: 'a-1',
        governance_action: 'ban',
        target_user: 'u-1',
        requested_by_profile: 'Ada Lovelace',
        reason: 'chargeback fraud',
        waiting_seconds: 7200,
        created_at: '2026-03-01T09:00:00Z',
      },
    ]));

    renderPage();
    await waitFor(() => expect(getPending).toHaveBeenCalled());
    fireEvent.click(await screen.findByRole('button', { name: /pending approvals/i }));

    expect(await screen.findByText(/Awaiting a second approver/i)).toBeInTheDocument();
    expect(screen.getByText(/chargeback fraud/)).toBeInTheDocument();
    expect(screen.getByText(/waiting 2h/)).toBeInTheDocument();
    expect(screen.getByText(/not applied/i)).toBeInTheDocument();
  });

  it('badges the pending tab with the queue size so a moderator sees it is waiting', async () => {
    getPending.mockResolvedValue(envelope([
      { id: 'a-1', governance_action: 'ban', reason: 'x' },
      { id: 'a-2', governance_action: 'suspension', reason: 'y' },
    ]));
    renderPage();
    await waitFor(() =>
      expect(screen.getByRole('button', { name: /Pending approvals \(2\)/ })).toBeInTheDocument(),
    );
  });
});

describe('AdminModeration — report resolution', () => {
  it('exposes Resolve alongside Investigate and Dismiss', async () => {
    renderPage();
    await waitFor(() => expect(screen.getAllByRole('button', { name: /^resolve$/i }).length).toBe(2));
    fireEvent.click(screen.getAllByRole('button', { name: /^resolve$/i })[0]);
    await waitFor(() => expect(handleReport).toHaveBeenCalledWith('r-1', 'resolve', ''));
  });
});
