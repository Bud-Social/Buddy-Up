import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { notificationsApi, type Notification } from '@/api/notifications';
import { moderationApi } from '@/api/moderation';
import AccountSafety from '@/pages/settings/AccountSafety';
import { buildStanding, endDateLabel } from '@/pages/settings/standing';

vi.mock('@/api/notifications', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/api/notifications')>();
  return { ...actual, notificationsApi: { ...actual.notificationsApi, getList: vi.fn() } };
});

vi.mock('@/api/moderation', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/api/moderation')>();
  return {
    ...actual,
    moderationApi: {
      getAppeals: vi.fn(),
      createAppeal: vi.fn(),
      getCommendations: vi.fn(),
      deleteCommendation: vi.fn(),
    },
  };
});

vi.mock('@/components/ui/Toast', () => ({
  useToast: () => ({ toast: vi.fn(), showToast: vi.fn() }),
}));

const getList = notificationsApi.getList as unknown as ReturnType<typeof vi.fn>;
const getAppeals = moderationApi.getAppeals as unknown as ReturnType<typeof vi.fn>;
const createAppeal = moderationApi.createAppeal as unknown as ReturnType<typeof vi.fn>;
const getCommendations = moderationApi.getCommendations as unknown as ReturnType<typeof vi.fn>;
const deleteCommendation = moderationApi.deleteCommendation as unknown as ReturnType<typeof vi.fn>;

const envelope = (data: unknown[]) => ({ success: true, data, message: '', errors: null, pagination: null });

const SUSPENSION_NOTIFICATION: Notification = {
  id: 'n-1',
  notification_type: 'moderation_suspension',
  title: 'Your account has been suspended',
  body: 'Repeated chargeback fraud.',
  metadata: {
    moderation_action_id: 'ma-abc123',
    action: 'user_suspended',
    reason: 'Repeated chargeback fraud.',
    duration_days: 30,
    suspended_until: '2026-04-01T00:00:00Z',
    permanent: false,
    can_appeal: true,
  },
  is_read: false,
  created_at: '2026-03-01T09:00:00Z',
};

const BAN_NOTIFICATION: Notification = {
  id: 'n-2',
  notification_type: 'moderation_ban',
  title: 'Your account has been banned',
  body: 'Selling counterfeit goods.',
  metadata: {
    moderation_action_id: 'ma-def456',
    action: 'user_banned',
    reason: 'Selling counterfeit goods.',
    duration_days: null,
    suspended_until: null,
    permanent: true,
  },
  is_read: false,
  created_at: '2026-02-01T09:00:00Z',
};

const renderPanel = () =>
  render(
    <MemoryRouter>
      <AccountSafety />
    </MemoryRouter>,
  );

beforeEach(() => {
  vi.clearAllMocks();
  getList.mockResolvedValue(envelope([SUSPENSION_NOTIFICATION, BAN_NOTIFICATION]));
  getAppeals.mockResolvedValue(envelope([]));
  getCommendations.mockResolvedValue(envelope([]));
  createAppeal.mockResolvedValue(envelope([{ id: 'ap-1', status: 'submitted' }]));
});

describe('buildStanding', () => {
  it('reads one standing entry per action from the notification metadata', () => {
    const rows = buildStanding([SUSPENSION_NOTIFICATION, BAN_NOTIFICATION]);
    expect(rows).toHaveLength(2);
    expect(rows.map((r) => r.actionId).sort()).toEqual(['ma-abc123', 'ma-def456']);
    expect(rows[0].reason).toBe('Repeated chargeback fraud.');
  });

  it('ignores notifications that are not moderation actions', () => {
    const rows = buildStanding([
      { ...SUSPENSION_NOTIFICATION, id: 'n-x', notification_type: 'comment_like', metadata: {} },
    ]);
    expect(rows).toHaveLength(0);
  });

  it('marks an action reversed when a later notice names it, and stops offering it', () => {
    const reversal: Notification = {
      id: 'n-3',
      notification_type: 'moderation_action_reversed',
      title: 'A moderation action on your account was reversed',
      body: 'Appeal approved.',
      metadata: { moderation_action_id: 'ma-rev', original_action_id: 'ma-abc123' },
      is_read: false,
      created_at: '2026-03-05T09:00:00Z',
    };
    const rows = buildStanding([reversal, SUSPENSION_NOTIFICATION, BAN_NOTIFICATION]);
    const suspension = rows.find((r) => r.actionId === 'ma-abc123');
    expect(suspension?.reversed).toBe(true);
    expect(endDateLabel(suspension!)).toMatch(/no longer applies/i);
    expect(rows.find((r) => r.actionId === 'ma-def456')?.reversed).toBe(false);
  });

  it('does not list a reversal as something to appeal', () => {
    const reversal: Notification = {
      id: 'n-3',
      notification_type: 'moderation_action_reversed',
      title: 'Reversed',
      body: '',
      metadata: { moderation_action_id: 'ma-rev', original_action_id: 'ma-abc123' },
      is_read: false,
      created_at: '2026-03-05T09:00:00Z',
    };
    const rows = buildStanding([reversal]);
    expect(rows).toHaveLength(0);
  });
});

describe('endDateLabel', () => {
  const base = {
    actionId: 'a', action: 'user_suspended', notificationType: 'moderation_suspension',
    title: '', reason: '', createdAt: '', until: null, permanent: false, durationDays: null, reversed: false,
  };

  it('shows the end date for a temporary action', () => {
    expect(endDateLabel({ ...base, until: '2026-04-01T00:00:00Z' })).toMatch(/^Until /);
  });

  it('says permanent when there is no end date and the action is a ban', () => {
    expect(endDateLabel({ ...base, action: 'user_banned', permanent: true })).toMatch(/Permanent/i);
  });

  it('falls back to the day term, then to an honest "no end date"', () => {
    expect(endDateLabel({ ...base, durationDays: 14 })).toBe('14 day term');
    expect(endDateLabel(base)).toBe('No end date recorded');
  });
});

describe('AccountSafety — standing', () => {
  it('shows the reason for each action on the account', async () => {
    renderPanel();
    expect(await screen.findByText('Your account has been suspended')).toBeInTheDocument();
    expect(screen.getByText('Your account has been banned')).toBeInTheDocument();
    expect(screen.getByText('Repeated chargeback fraud.')).toBeInTheDocument();
    expect(screen.getByText('Selling counterfeit goods.')).toBeInTheDocument();
  });

  it('shows an end date for a temporary suspension and "permanent" for a ban', async () => {
    renderPanel();
    await screen.findByText('Your account has been suspended');
    expect(screen.getByText(/^Until /)).toBeInTheDocument();
    expect(screen.getByText(/Permanent — there is no end date/)).toBeInTheDocument();
  });

  it('says so plainly when nothing has been done to the account', async () => {
    getList.mockResolvedValue(envelope([]));
    renderPanel();
    expect(await screen.findByText(/No moderation action has been taken on your account/)).toBeInTheDocument();
  });

  it('does not hide the appeal form when commendations fail to load', async () => {
    getCommendations.mockRejectedValue(new Error('boom'));
    renderPanel();
    await screen.findByText('Your account has been suspended');
    expect(screen.getAllByRole('button', { name: /appeal this/i }).length).toBeGreaterThan(0);
    expect(screen.getByText(/Could not load your commendations/)).toBeInTheDocument();
  });
});

describe('AccountSafety — appeals', () => {
  const openForm = async () => {
    renderPanel();
    await screen.findByText('Your account has been suspended');
    fireEvent.click(screen.getAllByRole('button', { name: /appeal this/i })[0]);
    return screen.findByLabelText('Appeal reason');
  };

  it('will not submit an appeal with no reason', async () => {
    await openForm();
    expect(screen.getByRole('button', { name: /submit appeal/i })).toBeDisabled();
    fireEvent.change(screen.getByLabelText('Appeal reason'), { target: { value: '   ' } });
    expect(screen.getByRole('button', { name: /submit appeal/i })).toBeDisabled();
  });

  it('posts the moderation action id and the reason to POST /moderation/appeals/', async () => {
    await openForm();
    fireEvent.change(screen.getByLabelText('Appeal reason'), {
      target: { value: 'That was my brother\'s account. I have secured it since.' },
    });
    fireEvent.click(screen.getByRole('button', { name: /submit appeal/i }));

    await waitFor(() =>
      expect(createAppeal).toHaveBeenCalledWith({
        action: 'ma-abc123',
        reason: 'That was my brother\'s account. I have secured it since.',
      }),
    );
  });

  it('sends exactly the two fields the endpoint accepts — no extra keys', async () => {
    await openForm();
    fireEvent.change(screen.getByLabelText('Appeal reason'), { target: { value: 'please review' } });
    fireEvent.click(screen.getByRole('button', { name: /submit appeal/i }));

    await waitFor(() => expect(createAppeal).toHaveBeenCalled());
    const payload = createAppeal.mock.calls[0][0];
    expect(Object.keys(payload).sort()).toEqual(['action', 'reason']);
    // `decision` and `resolution_note` are review-side fields; sending them from
    // the create form would be a 400 from an all-read serializer.
    expect(payload).not.toHaveProperty('resolution_note');
    expect(payload).not.toHaveProperty('status');
  });

  it("explains the refusal when the server rejects the appeal", async () => {
    createAppeal.mockRejectedValue(new Error('403'));
    await openForm();
    fireEvent.change(screen.getByLabelText('Appeal reason'), { target: { value: 'please review' } });
    fireEvent.click(screen.getByRole('button', { name: /submit appeal/i }));

    expect(await screen.findByText(/Your appeal could not be submitted/)).toBeInTheDocument();
  });

  it('stops offering a second appeal for an action already appealed', async () => {
    getAppeals.mockResolvedValue(envelope([
      { id: 'ap-1', action: 'ma-abc123', status: 'submitted', reason: 'already asked', created_at: '2026-03-02T09:00:00Z' },
    ]));
    renderPanel();
    await screen.findByText('Your account has been suspended');

    expect(screen.getByText(/You have already appealed this/)).toBeInTheDocument();
    // Only the ban, which has no appeal yet, is still appealable.
    expect(screen.getAllByRole('button', { name: /appeal this/i })).toHaveLength(1);
  });

  it('lists the user\'s own appeals with their status and the decision note', async () => {
    getAppeals.mockResolvedValue(envelope([
      {
        id: 'ap-1',
        action: 'ma-abc123',
        status: 'denied',
        reason: 'That was my brother\'s account.',
        resolution_note: 'The posts remain up under a second account.',
        created_at: '2026-03-02T09:00:00Z',
      },
    ]));
    renderPanel();
    await screen.findByText('Your account has been suspended');

    expect(screen.getByText('denied')).toBeInTheDocument();
    expect(screen.getByText(/The posts remain up under a second account/)).toBeInTheDocument();
  });
});

describe('AccountSafety — commendations', () => {
  it('lists the user\'s commendations with a delete action', async () => {
    getCommendations.mockResolvedValue(envelope([
      { id: 'c-1', category: 'helpful', category_display: 'Helpful', message: 'Helped a new gym get set up.', created_at: '2026-02-01T09:00:00Z' },
    ]));
    renderPanel();
    expect(await screen.findByText('Helpful')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /remove commendation Helpful/i })).toBeInTheDocument();
  });

  it('deletes a commendation by id', async () => {
    getCommendations.mockResolvedValue(envelope([
      { id: 'c-1', category: 'helpful', category_display: 'Helpful', message: 'Helped a new gym get set up.' },
    ]));
    deleteCommendation.mockResolvedValue(undefined);
    renderPanel();
    fireEvent.click(await screen.findByRole('button', { name: /remove commendation/i }));

    await waitFor(() => expect(deleteCommendation).toHaveBeenCalledWith('c-1'));
    await waitFor(() => expect(screen.queryByText('Helpful')).toBeNull());
  });

  it('keeps the commendation on screen and explains when the delete fails', async () => {
    getCommendations.mockResolvedValue(envelope([
      { id: 'c-1', category: 'helpful', category_display: 'Helpful', message: 'Helped a new gym.' },
    ]));
    deleteCommendation.mockRejectedValue(new Error('403'));
    renderPanel();
    fireEvent.click(await screen.findByRole('button', { name: /remove commendation/i }));

    expect(await screen.findByText(/Could not remove that commendation/)).toBeInTheDocument();
    expect(screen.getByText('Helpful')).toBeInTheDocument();
  });

  it('says so plainly when there are no commendations', async () => {
    renderPanel();
    await screen.findByText('Your account has been suspended');
    expect(screen.getByText(/No commendations yet/)).toBeInTheDocument();
  });
});
