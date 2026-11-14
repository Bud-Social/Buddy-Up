import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import userEvent from '@testing-library/user-event';
import CommunityDetail from '@/pages/app/CommunityDetail';
import { messagingApi, type Community } from '@/api/messaging';

vi.mock('@/api/messaging', async (importOriginal) => ({
  ...(await importOriginal<typeof import('@/api/messaging')>()),
  messagingApi: {
    getCommunity: vi.fn(),
    getCommunityPosts: vi.fn(),
    getCommunityEvents: vi.fn(),
    getCommunitySchedules: vi.fn(),
    getCommunityLives: vi.fn(),
    createCommunityEvent: vi.fn(),
    createCommunityLive: vi.fn(),
    createCommunitySchedule: vi.fn(),
    deleteCommunityEvent: vi.fn(),
    deleteCommunityLive: vi.fn(),
    deleteCommunitySchedule: vi.fn(),
    joinCommunity: vi.fn(),
    leaveCommunity: vi.fn(),
    updateCommunity: vi.fn(),
    rotateInviteCode: vi.fn(),
    removeCommunityMember: vi.fn(),
    setCommunityRole: vi.fn(),
    transferCommunityOwnership: vi.fn(),
    togglePostLike: vi.fn(),
    repostCommunityPost: vi.fn(),
    saveCommunityPost: vi.fn(),
    reactCommunityPost: vi.fn(),
  },
}));

const api = messagingApi as unknown as Record<string, ReturnType<typeof vi.fn>>;

const baseCommunity = {
  id: 'c1',
  is_group: true,
  is_community: true,
  group_name: 'Run Club',
  group_avatar_url: '',
  description: 'Sunday runs',
  cover_url: '',
  invite_code: 'RUN-123',
  is_public: true,
  membership_role: 'owner',
  my_role: 'owner',
  member_count: 12,
  members: [],
  participants_data: [],
  unread_count: 0,
  last_message: null,
  last_message_at: null,
  created_at: '',
} as unknown as Community;

function renderPage() {
  return render(
    <MemoryRouter initialEntries={['/communities/c1']}>
      <Routes>
        <Route path="/communities/:communityId" element={<CommunityDetail />} />
        <Route path="/messages/:conversationId" element={<div>chat screen</div>} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('CommunityDetail', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    api.getCommunity.mockResolvedValue(baseCommunity);
    api.getCommunityPosts.mockResolvedValue([]);
    api.getCommunityEvents.mockResolvedValue([]);
    api.getCommunitySchedules.mockResolvedValue([]);
    api.getCommunityLives.mockResolvedValue([]);
  });

  it('exposes feed, members, events, schedules and lives tabs', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByText('Run Club')).toBeInTheDocument());
    for (const label of ['Feed', 'Members', 'Events', 'Schedules', 'Lives']) {
      expect(screen.getByRole('button', { name: new RegExp(label) })).toBeInTheDocument();
    }
    expect(screen.getByText(/12 members/)).toBeInTheDocument();
  });

  it('redirects to the community chat', async () => {
    const user = userEvent.setup();
    renderPage();
    await waitFor(() => expect(screen.getByText('Run Club')).toBeInTheDocument());
    await user.click(screen.getByRole('button', { name: /Chat/ }));
    expect(await screen.findByText('chat screen')).toBeInTheDocument();
  });

  it('hides management controls from a plain member', async () => {
    api.getCommunity.mockResolvedValue({ ...baseCommunity, membership_role: 'member', my_role: 'member' });
    renderPage();
    await waitFor(() => expect(screen.getByText('Run Club')).toBeInTheDocument());
    await userEvent.setup().click(screen.getByRole('button', { name: /Events/ }));
    expect(screen.queryByRole('button', { name: /Add event/ })).not.toBeInTheDocument();
  });

  it('creates an event with the chosen times', async () => {
    const user = userEvent.setup();
    api.createCommunityEvent.mockResolvedValue({ id: 'e1', community_id: 'c1' });
    renderPage();
    await waitFor(() => expect(screen.getByText('Run Club')).toBeInTheDocument());

    await user.click(screen.getByRole('button', { name: /Events/ }));
    await user.click(screen.getByRole('button', { name: /Add event/ }));
    await user.type(screen.getByLabelText('Title'), 'Long run');
    await user.type(screen.getByLabelText('Starts'), '2026-12-01T07:00');
    await user.type(screen.getByLabelText('Ends'), '2026-12-01T09:00');
    await user.click(screen.getByRole('button', { name: 'Save' }));

    await waitFor(() => expect(api.createCommunityEvent).toHaveBeenCalledWith(
      'c1',
      expect.objectContaining({
        title: 'Long run',
        event_type: 'in_person',
        is_free: true,
      }),
    ));
  });

  it('renders the community calendar with its name attached', async () => {
    api.getCommunityEvents.mockResolvedValue([
      {
        id: 'e1', community_id: 'c1', community_name: 'Run Club',
        title: 'Parkrun', start_datetime: '2026-12-01T07:00:00Z',
        end_datetime: '2026-12-01T08:00:00Z', location: 'Karura',
        online_url: '', event_type: 'in_person', is_free: true,
        capacity: 0, spots_remaining: 0, creator_data: { username: 'owner' },
      },
    ]);
    const user = userEvent.setup();
    renderPage();
    await waitFor(() => expect(screen.getByText('Run Club')).toBeInTheDocument());
    await user.click(screen.getByRole('button', { name: /Events/ }));
    expect(await screen.findByText('Parkrun')).toBeInTheDocument();
    expect(screen.getByText(/Karura/)).toBeInTheDocument();
  });

  it('offers a join action to non-members', async () => {
    api.getCommunity.mockResolvedValue({ ...baseCommunity, membership_role: null, my_role: null, members: [] });
    renderPage();
    await waitFor(() => expect(screen.getByText('Run Club')).toBeInTheDocument());
    expect(screen.getByRole('button', { name: /Join community/ })).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /Chat/ })).not.toBeInTheDocument();
  });
});
