import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import userEvent from '@testing-library/user-event';
import GymManage from '@/pages/app/GymManage';
import { gymsApi } from '@/api/gyms';

vi.mock('@/api/gyms', async (importOriginal) => ({
  ...(await importOriginal<typeof import('@/api/gyms')>()),
  gymsApi: {
    detail: vi.fn(),
    getMembers: vi.fn(),
    getJoinRequests: vi.fn(),
    getSchedulePosts: vi.fn(),
    getReviews: vi.fn(),
    getPartnerMetrics: vi.fn(),
    manageMember: vi.fn(),
    removeMember: vi.fn(),
    invite: vi.fn(),
    manageJoinRequest: vi.fn(),
    createSchedulePost: vi.fn(),
    replyToReview: vi.fn(),
  },
}));

const api = gymsApi as unknown as Record<string, ReturnType<typeof vi.fn>>;

const envelope = (data: unknown) => ({ data, success: true });

const GYM = {
  id: 'g1',
  name: 'Karura Fitness',
  handle: 'karura',
  membership_role: 'owner',
  access_type: 'public',
};

const MEMBERS = [
  {
    id: 'm1',
    member_id: 'user-1',
    role: 'member',
    member_data: { username: 'ada', display_name: 'Ada Lovelace' },
  },
  {
    id: 'm2',
    member_id: 'user-2',
    role: 'owner',
    member_data: { username: 'grace', display_name: 'Grace Hopper' },
  },
];

/**
 * Render and wait out the loading skeleton, so a click never lands on the
 * placeholder instead of the tab strip.
 */
async function renderLoaded() {
  renderManage();
  return screen.findByRole('button', { name: 'Overview' });
}

function renderManage() {
  return render(
    <MemoryRouter initialEntries={['/gyms/karura/manage']}>
      <Routes>
        <Route path="/gyms/:slug/manage" element={<GymManage />} />
        <Route path="/:username" element={<div>profile page</div>} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('Gym management console', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    api.detail.mockResolvedValue(envelope(GYM));
    api.getMembers.mockResolvedValue(envelope(MEMBERS));
    api.getJoinRequests.mockResolvedValue(envelope([]));
    api.getSchedulePosts.mockResolvedValue(envelope([]));
    api.getReviews.mockResolvedValue(envelope([]));
    api.getPartnerMetrics.mockResolvedValue(
      envelope({
        active_members: 42,
        check_ins_30d: 128,
        unique_attendees_30d: 31,
        activation_rate_30d: 0.74,
        scheduled_activities_30d: 9,
      }),
    );
  });

  it('opens on the Overview tab so analytics are the landing surface', async () => {
    renderManage();
    await waitFor(() => expect(screen.getByText('Active members')).toBeInTheDocument());
    expect(screen.getByText('42')).toBeInTheDocument();
    // The window is stated on the tile, not implied by a bare heading.
    expect(screen.getByText('Check-ins (30d)')).toBeInTheDocument();
    expect(screen.getByText('74%')).toBeInTheDocument();
  });

  it('keeps the tab strip to one row of short labels', async () => {
    renderManage();
    await waitFor(() => expect(screen.getByText('Active members')).toBeInTheDocument());
    // "Join requests" was renamed "Requests": it wrapped the strip to two rows.
    expect(screen.getByRole('button', { name: 'Requests' })).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Join requests' })).not.toBeInTheDocument();
  });

  it('offers a role change for an ordinary member', async () => {
    const user = userEvent.setup();
    await renderLoaded();
    await user.click(screen.getByRole('button', { name: 'Members' }));

    await user.click(await screen.findByRole('button', { name: 'Change role for Ada Lovelace' }));
    await user.click(screen.getByRole('button', { name: 'moderator' }));
    await user.click(screen.getByRole('button', { name: 'Save role' }));

    await waitFor(() =>
      expect(api.manageMember).toHaveBeenCalledWith('karura', 'user-1', 'change_role', 'moderator'),
    );
  });

  it('offers removal for an ordinary member', async () => {
    const user = userEvent.setup();
    await renderLoaded();
    await user.click(screen.getByRole('button', { name: 'Members' }));

    await user.click(await screen.findByRole('button', { name: 'Remove Ada Lovelace' }));
    await user.click(screen.getByRole('button', { name: 'Remove', exact: true }));

    await waitFor(() => expect(api.removeMember).toHaveBeenCalledWith('karura', 'user-1'));
  });

  it('does not offer role or removal controls for owners', async () => {
    const user = userEvent.setup();
    await renderLoaded();
    await user.click(screen.getByRole('button', { name: 'Members' }));

    // Ownership changes go through transfer, so these are hidden rather than
    // shown and then refused by the server.
    expect(screen.queryByRole('button', { name: /Change role for Grace/ })).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /Remove Grace/ })).not.toBeInTheDocument();
  });

  it('explains itself instead of rendering an empty analytics shell for a plain member', async () => {
    api.detail.mockResolvedValue(envelope({ ...GYM, membership_role: 'member' }));
    renderManage();

    await waitFor(() =>
      expect(
        screen.getByText(/available to owners, co-owners and moderators/i),
      ).toBeInTheDocument(),
    );
    expect(screen.queryByText('Active members')).not.toBeInTheDocument();
  });

  it('does not crash when the analytics endpoint is unavailable', async () => {
    api.getPartnerMetrics.mockRejectedValue(new Error('boom'));
    renderManage();

    await waitFor(() => expect(screen.getByText('Could not load gym analytics.')).toBeInTheDocument());
  });
});