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
    getRoutinePosts: vi.fn(),
    getReviews: vi.fn(),
    getPartnerMetrics: vi.fn(),
    manageMember: vi.fn(),
    removeMember: vi.fn(),
    invite: vi.fn(),
    manageJoinRequest: vi.fn(),
    createRoutinePost: vi.fn(),
    replyToReview: vi.fn(),
    getVenues: vi.fn(),
    getOnlineCoaching: vi.fn(),
    getMedia: vi.fn(),
    getEndorsements: vi.fn(),
    getVerificationStatus: vi.fn(),
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
    api.getRoutinePosts.mockResolvedValue(envelope([]));
    api.getReviews.mockResolvedValue(envelope([]));
    api.getPartnerMetrics.mockResolvedValue(
      envelope({
        active_members: 42,
        check_ins_30d: 128,
        unique_attendees_30d: 31,
        activation_rate_30d: 74,
        scheduled_activities_30d: 9,
      }),
    );
    api.getVenues.mockResolvedValue(envelope([]));
    api.getOnlineCoaching.mockResolvedValue(
      envelope({ offers_online_coaching: false, coaching_types: [], coaches: [] }),
    );
    api.getMedia.mockResolvedValue(envelope([]));
    api.getEndorsements.mockResolvedValue(envelope({ can_endorse: false, endorsements: [] }));
    api.getVerificationStatus.mockResolvedValue(
      envelope({
        id: 'r1', gym_id: 'g1', legal_name: '', registration_number: '',
        country: '', tax_id: '', website: '', contact_email: '', contact_phone: '',
        status: 'unverified', rejection_reason: '', submitted_at: null,
        reviewed_at: null, created_at: '', updated_at: '',
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

  it('exposes locations, online coaching, announcements and business setup', async () => {
    await renderLoaded();
    for (const label of ['Locations', 'Online', 'Announce', 'Setup']) {
      expect(screen.getByRole('button', { name: label })).toBeInTheDocument();
    }
  });

  it('lists every branch with its pin state', async () => {
    const user = userEvent.setup();
    api.getVenues.mockResolvedValue(envelope([
      {
        id: 'v1', name: 'Westlands', address: 'Ring Road', city: 'Nairobi',
        country: 'Kenya', latitude: -1.26, longitude: 36.8, instructions: '',
        is_primary: true, is_active: true,
      },
      {
        id: 'v2', name: 'Karen', address: 'Ngong Road', city: 'Nairobi',
        country: 'Kenya', latitude: null, longitude: null, instructions: '',
        is_primary: false, is_active: true,
      },
    ]));
    await renderLoaded();
    await user.click(screen.getByRole('button', { name: 'Locations' }));

    expect(await screen.findByText('Westlands')).toBeInTheDocument();
    expect(screen.getByText('Karen')).toBeInTheDocument();
    expect(screen.getByText(/Locations \(2\)/)).toBeInTheDocument();
    expect(screen.getByText('Pinned')).toBeInTheDocument();
  });

  it('stops registration edits once the business is verified', async () => {
    const user = userEvent.setup();
    api.getVerificationStatus.mockResolvedValue(
      envelope({
        id: 'r1', gym_id: 'g1', legal_name: 'Karura Fitness Ltd',
        registration_number: 'REG-1', country: 'Kenya', tax_id: '',
        website: '', contact_email: 'hi@karura.test', contact_phone: '',
        status: 'verified', rejection_reason: '', submitted_at: null,
        reviewed_at: null, created_at: '', updated_at: '',
      }),
    );
    await renderLoaded();
    await user.click(screen.getByRole('button', { name: 'Setup' }));

    expect(await screen.findByText('Verified business')).toBeInTheDocument();
    expect(screen.getByText(/Members see the blue tick/i)).toBeInTheDocument();
    expect(screen.queryByText('Registration details')).not.toBeInTheDocument();
  });
});