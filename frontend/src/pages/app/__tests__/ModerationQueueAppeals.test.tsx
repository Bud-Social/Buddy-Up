import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { moderationApi, type ModerationAppeal, type UserReport } from '@/api/moderation';
import ModerationQueue from '@/pages/app/ModerationQueue';

/**
 * Regression coverage for the appeal-review bug.
 *
 * `ModerationAppealReviewSerializer` declares `resolution_note` as required for
 * *every* decision. This screen used to call `reviewAppeal(id, decision)` with
 * no note, so every appeal approved or denied from the admin console returned
 * 400 and the reviewer could do nothing but watch the error. These tests exist
 * to make that shape impossible to reintroduce silently: the note is collected
 * in the UI and asserted to be present in the request body.
 */
vi.mock('@/api/moderation', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/api/moderation')>();
  return {
    ...actual,
    moderationApi: {
      getQueue: vi.fn(),
      getStats: vi.fn(),
      actOnFlag: vi.fn(),
      getReports: vi.fn(),
      handleReport: vi.fn(),
      getAppeals: vi.fn(),
      reviewAppeal: vi.fn(),
      createAppeal: vi.fn(),
      getCommendations: vi.fn(),
      deleteCommendation: vi.fn(),
      getPendingApprovals: vi.fn(),
    },
  };
});

const api = moderationApi;
const getAppeals = api.getAppeals as unknown as ReturnType<typeof vi.fn>;
const reviewAppeal = api.reviewAppeal as unknown as ReturnType<typeof vi.fn>;
const getReports = api.getReports as unknown as ReturnType<typeof vi.fn>;
const handleReport = api.handleReport as unknown as ReturnType<typeof vi.fn>;

const envelope = (data: unknown[]) => ({ success: true, data, message: '', errors: null, pagination: null });

const APPEALS: ModerationAppeal[] = [
  {
    id: 'appeal-abcdef01-2345-6789-abcd-ef0123456789',
    action: 'ma-1',
    reason: 'I did not post that. My account was compromised and I have changed my password.',
    status: 'submitted',
    created_at: '2026-03-01T09:00:00Z',
  },
];

const REPORTS: UserReport[] = [
  {
    id: 'rep-1',
    reason: 'harassment',
    status: 'open',
    description: 'Targeted abuse in a comment thread.',
    assigned_to: null,
    sla_due_at: new Date(Date.now() - 7_200_000).toISOString(),
    sla_breached: true,
    created_at: '2026-03-01T09:00:00Z',
  },
  {
    id: 'rep-2',
    reason: 'spam',
    status: 'investigating',
    description: 'Repeated promotional DMs.',
    assigned_to: 'staff-uuid-1',
    sla_due_at: new Date(Date.now() + 5_400_000).toISOString(),
    sla_breached: false,
    created_at: '2026-03-01T10:00:00Z',
  },
];

const renderPage = () =>
  render(
    <MemoryRouter>
      <ModerationQueue />
    </MemoryRouter>,
  );

const openAppeals = async () => {
  renderPage();
  await waitFor(() => expect(screen.getByRole('button', { name: /Appeals/ })).toBeInTheDocument());
  fireEvent.click(screen.getByRole('button', { name: /Appeals/ }));
  await screen.findByText(/Appeal #appeal-/);
};

beforeEach(() => {
  vi.clearAllMocks();
  (api.getQueue as unknown as ReturnType<typeof vi.fn>).mockResolvedValue(envelope([]));
  (api.getStats as unknown as ReturnType<typeof vi.fn>).mockResolvedValue(
    envelope({ total: 0, unactioned: 0, actioned: 0, by_severity: {}, by_reason: {} }),
  );
  getAppeals.mockResolvedValue(envelope(APPEALS));
  getReports.mockResolvedValue(envelope(REPORTS));
  handleReport.mockResolvedValue(REPORTS[0]);
  reviewAppeal.mockResolvedValue({ ...APPEALS[0], status: 'approved' });
});

describe('ModerationQueue — appeal review sends resolution_note (regression)', () => {
  it('asks for a note before an appeal can be approved', async () => {
    await openAppeals();

    fireEvent.click(screen.getByRole('button', { name: /^Approve$/ }));

    const confirm = await screen.findByRole('button', { name: /approve appeal/i });
    // The submit button is dead until a note is typed — the API 400s without
    // one, so there is nothing to gain by letting the reviewer send it.
    expect(confirm).toBeDisabled();
    expect(reviewAppeal).not.toHaveBeenCalled();
  });

  it('asks for a note before an appeal can be denied, too', async () => {
    await openAppeals();

    fireEvent.click(screen.getByRole('button', { name: /^Deny$/ }));

    const confirm = await screen.findByRole('button', { name: /deny appeal/i });
    expect(confirm).toBeDisabled();
    expect(reviewAppeal).not.toHaveBeenCalled();
  });

  it('sends a non-empty resolution_note when approving — the case that always 400ed', async () => {
    await openAppeals();

    fireEvent.click(screen.getByRole('button', { name: /^Approve$/ }));
    const confirm = await screen.findByRole('button', { name: /approve appeal/i });
    fireEvent.change(screen.getByLabelText('Internal note'), {
      target: { value: 'Account was compromised; credentials changed before the ban.' },
    });
    expect(confirm).toBeEnabled();
    fireEvent.click(confirm);

    await waitFor(() =>
      expect(reviewAppeal).toHaveBeenCalledWith(
        'appeal-abcdef01-2345-6789-abcd-ef0123456789',
        'approve',
        'Account was compromised; credentials changed before the ban.',
      ),
    );
    // The exact field the API requires, spelled exactly as the API spells it.
    const [id, decision, note] = reviewAppeal.mock.calls[0];
    expect(id).toBeTruthy();
    expect(decision).toBe('approve');
    expect(note).toBe('Account was compromised; credentials changed before the ban.');
  });

  it('sends a non-empty resolution_note when denying', async () => {
    await openAppeals();

    fireEvent.click(screen.getByRole('button', { name: /^Deny$/ }));
    const confirm = await screen.findByRole('button', { name: /deny appeal/i });
    fireEvent.change(screen.getByLabelText('Rejection reason'), { target: { value: 'The removed posts are still up.' } });
    fireEvent.click(confirm);

    await waitFor(() =>
      expect(reviewAppeal).toHaveBeenCalledWith(
        'appeal-abcdef01-2345-6789-abcd-ef0123456789',
        'deny',
        'The removed posts are still up.',
      ),
    );
  });

  it('never calls the API with an empty note, whichever button was pressed', async () => {
    await openAppeals();

    fireEvent.click(screen.getByRole('button', { name: /^Approve$/ }));
    await screen.findByRole('button', { name: /approve appeal/i });
    // Whitespace only is not a note.
    fireEvent.change(screen.getByLabelText('Internal note'), { target: { value: '   ' } });
    fireEvent.click(screen.getByRole('button', { name: /approve appeal/i }));
    fireEvent.click(screen.getByRole('button', { name: /cancel/i }));

    expect(reviewAppeal).not.toHaveBeenCalled();
  });

  it('surfaces the failure and keeps the appeal in the queue when the server refuses', async () => {
    reviewAppeal.mockRejectedValue(new Error('400'));
    await openAppeals();

    fireEvent.click(screen.getByRole('button', { name: /^Approve$/ }));
    const confirm = await screen.findByRole('button', { name: /approve appeal/i });
    fireEvent.change(screen.getByLabelText('Internal note'), { target: { value: 'looks wrong to me' } });
    fireEvent.click(confirm);

    await waitFor(() => expect(screen.getByText(/A decision requires a resolution note/)).toBeInTheDocument());
    expect(screen.getByText(/Appeal #appeal-/)).toBeInTheDocument();
  });
});

describe('ModerationQueue — reports', () => {
  const openReports = async () => {
    renderPage();
    await waitFor(() => expect(screen.getByRole('button', { name: /User reports/ })).toBeInTheDocument());
    fireEvent.click(screen.getByRole('button', { name: /User reports/ }));
    await screen.findByText(/Targeted abuse in a comment thread/);
  };

  it('shows who each report is assigned to', async () => {
    await openReports();
    expect(screen.getByText(/Assigned #staff-/)).toBeInTheDocument();
    expect(screen.getAllByText('Unassigned').length).toBeGreaterThan(0);
  });

  it('renders the SLA as a countdown and marks a breached one', async () => {
    await openReports();
    expect(screen.getByText(/SLA breached/)).toBeInTheDocument();
    expect(screen.getByText(/SLA .*left/)).toBeInTheDocument();
  });

  it('exposes Resolve alongside Investigate and Dismiss', async () => {
    await openReports();
    expect(screen.getAllByRole('button', { name: /^Resolve$/ })).toHaveLength(2);
    expect(screen.getAllByRole('button', { name: /^Investigate$/ })).toHaveLength(2);
    expect(screen.getAllByRole('button', { name: /^Dismiss$/ })).toHaveLength(2);
  });

  it('resolves a report through the handle endpoint', async () => {
    await openReports();
    fireEvent.click(screen.getAllByRole('button', { name: /^Resolve$/ })[0]);
    await waitFor(() => expect(handleReport).toHaveBeenCalledWith('rep-1', 'resolve'));
  });

  it('hides the actions on a settled report', async () => {
    getReports.mockResolvedValue(envelope([{ ...REPORTS[0], status: 'resolved' }]));
    await openReports();
    expect(screen.queryByRole('button', { name: /^Resolve$/ })).toBeNull();
  });
});
