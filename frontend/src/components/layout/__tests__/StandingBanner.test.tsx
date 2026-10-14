import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { notificationsApi, type Notification } from '@/api/notifications';
import { StandingBanner } from '@/components/layout/StandingBanner';

/**
 * A suspension that lives only on a Settings sub-page is a suspension a member
 * finds out about by failing to post. These tests pin the three facts the banner
 * must carry — what happened, why, and when it ends — plus the link to the
 * appeal surface, and the two cases where it must stay silent: a reversed
 * action, and a feed that could not be read.
 */

vi.mock('@/api/notifications', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/api/notifications')>();
  return { ...actual, notificationsApi: { ...actual.notificationsApi, getList: vi.fn() } };
});

const getList = notificationsApi.getList as unknown as ReturnType<typeof vi.fn>;

const notification = (over: Partial<Notification>): Notification => ({
  id: 'n-1',
  notification_type: 'moderation_suspension',
  title: 'Your account was suspended',
  body: '',
  metadata: {},
  is_read: false,
  created_at: '2026-03-01T09:00:00Z',
  ...over,
});

const SUSPENDED = notification({
  metadata: {
    moderation_action_id: 'ma-1',
    action: 'user_suspended',
    reason: 'Repeated harassment in comment threads.',
    duration_days: 7,
    suspended_until: '2026-03-08T09:00:00Z',
  },
});

const renderBanner = () =>
  render(
    <MemoryRouter>
      <StandingBanner />
    </MemoryRouter>,
  );

beforeEach(() => {
  vi.clearAllMocks();
});

describe('StandingBanner', () => {
  it('shows the action, the reason, the end date, and an appeal link', async () => {
    getList.mockResolvedValue({ data: [SUSPENDED] });

    renderBanner();

    const banner = await screen.findByTestId('standing-banner');
    expect(banner).toHaveTextContent('Your account was suspended');
    expect(banner).toHaveTextContent('Repeated harassment in comment threads.');
    expect(banner).toHaveTextContent(/Until /);

    // The appeal surface is one tap away — the banner does not try to collect a
    // reason itself, because the appeal endpoint needs the action id and a
    // written justification.
    const appeal = screen.getByRole('link', { name: /Appeal this/i });
    expect(appeal).toHaveAttribute('href', '/settings/help');
  });

  it('says the action is permanent when there is no end date', async () => {
    getList.mockResolvedValue({
      data: [notification({
        notification_type: 'moderation_ban',
        title: 'Your account was banned',
        metadata: { moderation_action_id: 'ma-2', action: 'user_banned', reason: 'Fraud.', permanent: true },
      })],
    });

    renderBanner();
    expect(await screen.findByText(/Permanent — there is no end date/)).toBeInTheDocument();
  });

  it('stays silent for a reversed action', async () => {
    getList.mockResolvedValue({
      data: [
        SUSPENDED,
        notification({
          id: 'n-2',
          notification_type: 'moderation_action_reversed',
          title: 'The suspension was lifted',
          metadata: { original_action_id: 'ma-1' },
          created_at: '2026-03-02T09:00:00Z',
        }),
      ],
    });

    renderBanner();
    await waitFor(() => expect(getList).toHaveBeenCalled());
    expect(screen.queryByTestId('standing-banner')).not.toBeInTheDocument();
  });

  it('stays silent when the feed cannot be read', async () => {
    getList.mockRejectedValue(new Error('offline'));

    renderBanner();
    await waitFor(() => expect(getList).toHaveBeenCalled());
    expect(screen.queryByTestId('standing-banner')).not.toBeInTheDocument();
  });
});