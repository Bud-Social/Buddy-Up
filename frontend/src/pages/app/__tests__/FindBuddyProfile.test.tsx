import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import FindBuddyProfile from '../FindBuddyProfile';
import { profilesApi } from '@/api/profiles';
import { messagingApi } from '@/api';

const navigateMock = vi.fn();

vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual<typeof import('react-router-dom')>('react-router-dom');
  return { ...actual, useNavigate: () => navigateMock };
});

vi.mock('@/api/profiles', () => ({
  profilesApi: {
    getUserSearchProfile: vi.fn(),
    likeBuddy: vi.fn(),
    unlikeBuddy: vi.fn(),
    block: vi.fn(),
    getProfile: vi.fn(),
  },
}));

vi.mock('@/api', () => ({
  messagingApi: { startConversation: vi.fn() },
}));

vi.mock('@/api/feed', () => ({
  feedApi: { submitReport: vi.fn() },
  REPORT_REASONS: [
    { value: 'spam', label: 'Spam' },
    { value: 'harassment', label: 'Harassment' },
  ],
}));

vi.mock('@/lib/geo', () => ({
  requestLocation: vi.fn().mockRejectedValue(new Error('denied')),
}));

const api = profilesApi as unknown as Record<string, ReturnType<typeof vi.fn>>;

const profile = {
  username: 'dawn',
  display_name: 'Dawn Runner',
  avatar_url: 'https://cdn.test/avatar.jpg',
  intents: ['run'],
  custom_intent: '',
  modes: ['in_person'],
  bio: 'Easy 5k at 6am.',
  goals: ['endurance'],
  age_band: '25-34',
  photos: ['https://cdn.test/one.jpg', 'https://cdn.test/two.jpg'],
  neighbourhood: 'Kileleshwa',
  search_radius_km: 5,
  available_now: true,
  available_until: null,
  pace: 'steady',
  visibility: 'public',
  incognito: false,
  liked_by_me: false,
  liked_me: false,
  is_buddy: false,
  can_message: true,
  distance_km: 0.6,
};

beforeEach(() => {
  vi.clearAllMocks();
  api.getUserSearchProfile.mockResolvedValue({ data: profile });
  api.likeBuddy.mockResolvedValue({ data: { liked: true, username: 'dawn', liked_me: true } });
  api.unlikeBuddy.mockResolvedValue({ data: { liked: false, username: 'dawn', liked_me: true } });
  api.block.mockResolvedValue({ data: null });
  api.getProfile.mockResolvedValue({ data: { user_id: 'user-9', username: 'dawn' } });
});

function renderPage() {
  return render(
    <MemoryRouter initialEntries={['/buddies/find/dawn']}>
      <Routes>
        <Route path="/buddies/find/:username" element={<FindBuddyProfile />} />
        <Route path="/:username" element={<p>main profile</p>} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('FindBuddyProfile', () => {
  it('renders the search profile essentials', async () => {
    renderPage();

    expect(await screen.findByRole('heading', { name: 'Dawn Runner' })).toBeDefined();
    expect(screen.getByText(/Easy 5k at 6am\./)).toBeDefined();
    expect(screen.getByText(/Pace:/)).toBeDefined();
    expect(screen.getByText(/Around Kileleshwa/)).toBeDefined();
    expect(screen.getByText('Available now')).toBeDefined();
    expect(screen.getByText(/@dawn · 25-34 · <1 km/)).toBeDefined();
    expect(screen.getByText('1/2')).toBeDefined();
  });

  it('opens a chat in the buddy messages surface', async () => {
    (messagingApi.startConversation as unknown as ReturnType<typeof vi.fn>).mockResolvedValue({ data: { id: 'conv-1' } });
    renderPage();

    await userEvent.click(await screen.findByRole('button', { name: /Message/ }));
    await waitFor(() => expect(navigateMock).toHaveBeenCalledWith('/buddies/messages/conv-1'));
  });

  it('tags the buddy-profile thread as a discovery chat', async () => {
    (messagingApi.startConversation as unknown as ReturnType<typeof vi.fn>).mockResolvedValue({ data: { id: 'conv-1' } });
    renderPage();

    await userEvent.click(await screen.findByRole('button', { name: /Message/ }));

    await waitFor(() =>
      expect(messagingApi.startConversation).toHaveBeenCalledWith(['dawn'], undefined, 'discovery'),
    );
  });

  it('toggles interest and badges a mutual like', async () => {
    api.getUserSearchProfile.mockResolvedValue({ data: { ...profile, liked_me: true } });
    renderPage();

    const like = await screen.findByRole('button', { name: 'Show interest in @dawn' });
    expect(screen.getByText('Liked you')).toBeDefined();

    await userEvent.click(like);
    await waitFor(() => expect(api.likeBuddy).toHaveBeenCalledWith('dawn'));
  });

  it('surfaces the server message when a like is refused', async () => {
    api.likeBuddy.mockRejectedValue({ response: { data: { message: 'Unable to like this profile.' } } });
    renderPage();

    await userEvent.click(await screen.findByRole('button', { name: 'Show interest in @dawn' }));
    await waitFor(() =>
      expect(screen.getByRole('button', { name: 'Show interest in @dawn' }).getAttribute('aria-pressed')).toBe('false'),
    );
  });

  it('reports through the shared reason sheet', async () => {
    const { feedApi } = await import('@/api/feed');
    (feedApi.submitReport as unknown as ReturnType<typeof vi.fn>).mockResolvedValue({ data: {} });
    renderPage();

    await userEvent.click(await screen.findByRole('button', { name: /Report/ }));
    await userEvent.click(screen.getByRole('menuitemradio', { name: /Harassment/ }));
    await userEvent.click(screen.getByRole('button', { name: 'Submit report' }));

    await waitFor(() =>
      expect(feedApi.submitReport).toHaveBeenCalledWith(expect.objectContaining({
        target_user: 'user-9',
        reason: 'harassment',
      })),
    );
  });

  it('blocks then leaves the surface', async () => {
    renderPage();

    await userEvent.click(await screen.findByRole('button', { name: /Block @dawn/ }));
    await waitFor(() => expect(api.block).toHaveBeenCalledWith('dawn'));
    expect(navigateMock).toHaveBeenCalledWith(-1);
  });

  it('links out to the main profile', async () => {
    renderPage();
    await userEvent.click(await screen.findByRole('button', { name: 'View main profile' }));
    expect(navigateMock).toHaveBeenCalledWith('/dawn');
  });

  it('shows the empty state when there is no visible search profile', async () => {
    api.getUserSearchProfile.mockResolvedValue({ data: null });
    renderPage();

    expect(await screen.findByText(/isn't available right now/)).toBeDefined();
  });
});
