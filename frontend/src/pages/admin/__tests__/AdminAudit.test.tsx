import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen, waitFor, fireEvent, within } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { adminPortalApi, auditExportUrl, type AuditLogEntry } from '@/api/adminPortal';
import AdminAudit from '@/pages/admin/AdminAudit';

vi.mock('@/api/adminPortal', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/api/adminPortal')>();
  return {
    ...actual,
    adminPortalApi: {
      getAuditLog: vi.fn(),
      getAuditEntry: vi.fn(),
      getAuditTimeline: vi.fn(),
    },
  };
});

const api = adminPortalApi;
const getAuditLog = api.getAuditLog as unknown as ReturnType<typeof vi.fn>;
const getAuditEntry = api.getAuditEntry as unknown as ReturnType<typeof vi.fn>;
const getTimeline = api.getAuditTimeline as unknown as ReturnType<typeof vi.fn>;

const envelope = (data: unknown[]) => ({
  success: true,
  data,
  message: '',
  errors: null,
  pagination: { count: data.length, next: null, previous: null },
});

const ENTRIES: AuditLogEntry[] = [
  {
    id: 'log-1',
    actor_email: 'mod@example.com',
    action: 'users.suspend',
    target_type: 'user',
    target_id: 'u-1',
    summary: 'Suspended an account for chargeback fraud.',
    before: { is_active: true },
    after: { is_active: false },
    created_at: '2026-03-01T09:00:00Z',
  },
];

const renderPage = () =>
  render(
    <MemoryRouter>
      <AdminAudit />
    </MemoryRouter>,
  );

beforeEach(() => {
  vi.clearAllMocks();
  getAuditLog.mockResolvedValue(envelope(ENTRIES));
  getAuditEntry.mockResolvedValue(envelope(ENTRIES[0]));
  getTimeline.mockResolvedValue(envelope([
    { ...ENTRIES[0], id: 'log-0', action: 'users.flag', summary: 'Flagged the account.', created_at: '2026-02-28T09:00:00Z' },
    ENTRIES[0],
  ]));
});

describe('AdminAudit — filters', () => {
  it('lists without any filter by default', async () => {
    renderPage();
    await waitFor(() => expect(getAuditLog).toHaveBeenCalledTimes(1));
    const params = getAuditLog.mock.calls[0][0];
    expect(params.action ?? null).toBeNull();
    expect(params.target_type ?? null).toBeNull();
    expect(params.date_from ?? null).toBeNull();
  });

  it('re-queries with the action, target_type and target_id filters', async () => {
    renderPage();
    await waitFor(() => expect(getAuditLog).toHaveBeenCalledTimes(1));

    fireEvent.change(screen.getByLabelText('Action'), { target: { value: 'users.suspend' } });
    fireEvent.change(screen.getByLabelText('Target type'), { target: { value: 'user' } });
    fireEvent.change(screen.getByLabelText('Target id'), { target: { value: 'u-1' } });

    await waitFor(() => {
      const params = getAuditLog.mock.calls[getAuditLog.mock.calls.length - 1][0];
      expect(params).toMatchObject({ action: 'users.suspend', target_type: 'user', target_id: 'u-1' });
    });
  });

  it('sends the date range filters the API parses', async () => {
    renderPage();
    await waitFor(() => expect(getAuditLog).toHaveBeenCalledTimes(1));

    fireEvent.change(screen.getByLabelText('From'), { target: { value: '2026-01-01' } });
    fireEvent.change(screen.getByLabelText('To'), { target: { value: '2026-01-31' } });

    await waitFor(() => {
      const params = getAuditLog.mock.calls[getAuditLog.mock.calls.length - 1][0];
      expect(params).toMatchObject({ date_from: '2026-01-01', date_to: '2026-01-31' });
    });
  });

  it('drops every filter back to a bare listing', async () => {
    renderPage();
    await waitFor(() => expect(getAuditLog).toHaveBeenCalledTimes(1));
    fireEvent.change(screen.getByLabelText('Action'), { target: { value: 'users.suspend' } });
    await waitFor(() => expect(screen.getByRole('button', { name: /clear filters/i })).toBeInTheDocument());

    fireEvent.click(screen.getByRole('button', { name: /clear filters/i }));

    await waitFor(() => {
      const params = getAuditLog.mock.calls[getAuditLog.mock.calls.length - 1][0];
      expect(params.action ?? null).toBeNull();
    });
  });

  it("surfaces the API's grammar message for a malformed filter rather than an empty list", async () => {
    getAuditLog.mockRejectedValue(
      Object.assign(new Error('bad request'), {
        response: {
          status: 400,
          data: {
            success: false,
            message:
              "Malformed action filter: 'Users.Suspend'. Expected a dotted lowercase verb such as 'users.suspend', 'orders.status_change' or 'emails.send'.",
          },
        },
      }),
    );

    renderPage();
    await waitFor(() => expect(screen.getByText(/Malformed action filter/)).toBeInTheDocument());
    expect(screen.getByText(/Expected a dotted lowercase verb/)).toBeInTheDocument();
  });
});

describe('AdminAudit — row detail', () => {
  it('renders the summary, actor and action on a row', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByText(/Suspended an account for chargeback fraud/)).toBeInTheDocument());
    expect(screen.getByText(/mod@example.com/)).toBeInTheDocument();
    expect(screen.getByText('users.suspend')).toBeInTheDocument();
  });

  it('re-reads the full record on click and shows before and after', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByText(/Suspended an account/)).toBeInTheDocument());

    fireEvent.click(screen.getByText(/Suspended an account for chargeback fraud/));

    await waitFor(() => expect(getAuditEntry).toHaveBeenCalledWith('log-1'));
    expect(await screen.findByText('Before')).toBeInTheDocument();
    expect(screen.getByText('After')).toBeInTheDocument();
    expect(screen.getByText(/"is_active": true/)).toBeInTheDocument();
    expect(screen.getByText(/"is_active": false/)).toBeInTheDocument();
  });

  it('does not dump the delta into the list row', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByText(/Suspended an account/)).toBeInTheDocument());
    expect(screen.queryByText(/"is_active": true/)).toBeNull();
  });

  it('shows an empty delta as a placeholder rather than blank space', async () => {
    getAuditEntry.mockResolvedValue(envelope({ ...ENTRIES[0], before: null, after: null }));
    renderPage();
    await waitFor(() => expect(screen.getByText(/Suspended an account/)).toBeInTheDocument());
    fireEvent.click(screen.getByText(/Suspended an account for chargeback fraud/));
    await waitFor(() => expect(screen.getAllByText('Nothing recorded.').length).toBe(2));
  });
});

describe('AdminAudit — object timeline', () => {
  it('requires a target type before it will query', async () => {
    renderPage();
    await waitFor(() => expect(getAuditLog).toHaveBeenCalled());
    expect(screen.getByRole('button', { name: /load timeline/i })).toBeDisabled();
  });

  it('loads a per-object timeline oldest first', async () => {
    renderPage();
    await waitFor(() => expect(getAuditLog).toHaveBeenCalled());

    fireEvent.change(screen.getByLabelText('Timeline target type'), { target: { value: 'user' } });
    fireEvent.change(screen.getByLabelText('Timeline target id'), { target: { value: 'u-1' } });
    fireEvent.click(screen.getByRole('button', { name: /load timeline/i }));

    await waitFor(() => expect(getTimeline).toHaveBeenCalled());
    expect(getTimeline.mock.calls[0][0]).toMatchObject({ target_type: 'user' });
  });

  it('renders the timeline entries in the order the API returned them', async () => {
    renderPage();
    await waitFor(() => expect(getAuditLog).toHaveBeenCalled());
    fireEvent.change(screen.getByLabelText('Timeline target type'), { target: { value: 'user' } });
    fireEvent.click(screen.getByRole('button', { name: /load timeline/i }));

    const flagged = await screen.findByText('Flagged the account.');
    // Scope to the timeline: the same summary text also exists as a list row.
    const timeline = flagged.closest('ol') as HTMLElement;
    const items = within(timeline).getAllByRole('listitem');
    expect(items).toHaveLength(2);
    expect(items[0]).toHaveTextContent('Flagged the account.');
    expect(items[1]).toHaveTextContent('Suspended an account for chargeback fraud.');
  });

  it("surfaces the API's refusal when target_type is missing server-side", async () => {
    getTimeline.mockRejectedValue(
      Object.assign(new Error('bad request'), {
        response: {
          status: 400,
          data: {
            success: false,
            message:
              'target_type is required. The timeline is a history of one thing; without it you are asking for every action this platform has taken.',
          },
        },
      }),
    );

    renderPage();
    await waitFor(() => expect(getAuditLog).toHaveBeenCalled());
    fireEvent.change(screen.getByLabelText('Timeline target type'), { target: { value: 'user' } });
    fireEvent.click(screen.getByRole('button', { name: /load timeline/i }));

    expect(await screen.findByText(/target_type is required/)).toBeInTheDocument();
  });
});

describe('AdminAudit — CSV export', () => {
  it('opens the export endpoint as a download, carrying the active filters', async () => {
    const open = vi.spyOn(window, 'open').mockReturnValue(null);
    renderPage();
    await waitFor(() => expect(getAuditLog).toHaveBeenCalledTimes(1));

    fireEvent.change(screen.getByLabelText('Target type'), { target: { value: 'user' } });
    await waitFor(() => expect(getAuditLog).toHaveBeenCalledTimes(2));

    fireEvent.click(screen.getByRole('button', { name: /export csv/i }));

    expect(open).toHaveBeenCalledTimes(1);
    const url = open.mock.calls[0][0] as string;
    expect(url).toBe(auditExportUrl({ target_type: 'user' }));
    expect(url).toContain('/governance/audit/export/');
    expect(url).toContain('target_type=user');
    expect(open.mock.calls[0][1]).toBe('_blank');
    open.mockRestore();
  });
});
