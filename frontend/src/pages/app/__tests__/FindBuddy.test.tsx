import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import FindBuddy, { formatDistanceBadge, sortByDistance } from '../FindBuddy';
import { profilesApi, type NearbyBuddy } from '@/api/profiles';
import { messagingApi } from '@/api';

const navigateMock = vi.fn();

vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual<typeof import('react-router-dom')>('react-router-dom');
  return { ...actual, useNavigate: () => navigateMock };
});

vi.mock('@/api/profiles', () => ({
  profilesApi: {
    getNearbyBuddies: vi.fn(),
    getSearchProfile: vi.fn(),
    getMyProfile: vi.fn(),
    likeBuddy: vi.fn(),
    unlikeBuddy: vi.fn(),
  },
  BUDDY_INTENTS: ['walk', 'run', 'gym'],
  BUDDY_MODES: ['group', 'solo'],
  BUDDY_GOALS: ['endurance'],
  BUDDY_VISIBILITY: ['public', 'buddies'],
}));

vi.mock('@/api', () => ({
  messagingApi: { startConversation: vi.fn() },
}));

vi.mock('@/api/feed', () => ({
  feedApi: { uploadPostMedia: vi.fn() },
}));

vi.mock('@/lib/geo', () => ({
  requestLocation: vi.fn(),
}));

const api = profilesApi as unknown as Record<string, ReturnType<typeof vi.fn>>;

function buddy(overrides: Partial<NearbyBuddy> & { username: string; distance: number | null }): NearbyBuddy {
  return {
    profile: {
      user_id: overrides.username,
      username: overrides.username,
      display_name: overrides.username,
      avatar_url: '',
      preferences: { preferred_workouts: ['running'] },
    } as NearbyBuddy['profile'],
    distance_km: overrides.distance,
    display_name: overrides.username,
    intents: ['run'],
    custom_intent: '',
    modes: [],
    bio: '',
    goals: [],
    age_band: '25-34',
    photos: [],
    available_now: false,
    liked_by_me: false,
    liked_me: false,
    explanation: 'Nearby',
    ...overrides,
  } as NearbyBuddy;
}

beforeEach(() => {
  vi.clearAllMocks();
  api.getSearchProfile.mockResolvedValue({ data: null });
  api.likeBuddy.mockResolvedValue({ data: { liked: true, username: 'near', liked_me: false } });
  api.unlikeBuddy.mockResolvedValue({ data: { liked: false, username: 'near', liked_me: false } });
  api.getNearbyBuddies.mockResolvedValue({
    data: [buddy({ username: 'far', distance: 4.2 }), buddy({ username: 'near', distance: 1.3 })],
    geo: null,
  });
});

function renderPage() {
  return render(<MemoryRouter><FindBuddy /></MemoryRouter>);
}

describe('formatDistanceBadge', () => {
  it('bands anything under a kilometre instead of showing metres', () => {
    expect(formatDistanceBadge(0.64)).toBe('<1 km');
    expect(formatDistanceBadge(0.02)).toBe('<1 km');
  });

  it('stays exact from a kilometre up', () => {
    expect(formatDistanceBadge(1)).toBe('1.0 km');
    expect(formatDistanceBadge(1.3)).toBe('1.3 km');
    expect(formatDistanceBadge(12)).toBe('12 km');
  });

  it('returns null for unknown distances', () => {
    expect(formatDistanceBadge(null)).toBeNull();
    expect(formatDistanceBadge(Number.NaN)).toBeNull();
    expect(formatDistanceBadge(-1)).toBeNull();
  });
});

describe('sortByDistance', () => {
  it('puts the closest buddy first and unknown distances last', () => {
    const sorted = sortByDistance([
      buddy({ username: 'a', distance: null }),
      buddy({ username: 'b', distance: 5 }),
      buddy({ username: 'c', distance: 0.2 }),
    ]);
    expect(sorted.map((b) => b.profile.username)).toEqual(['c', 'b', 'a']);
  });
});

describe('FindBuddy result cards', () => {
  it('renders rectangular cards with a distance badge per buddy', async () => {
    const { container } = renderPage();

    await waitFor(() => expect(screen.getByTestId('distance-near')).toBeDefined());

    const grid = container.querySelector('.grid.grid-cols-2');
    expect(grid?.className).toContain('sm:grid-cols-3');
    expect(grid?.className).toContain('lg:grid-cols-4');
    expect(grid?.className).toContain('gap-3');

    const cards = container.querySelectorAll('.aspect-\\[3\\/4\\]');
    expect(cards.length).toBeGreaterThanOrEqual(2);

    // Closest first, with the banded distance from the search API.
    expect(screen.getByTestId('distance-near').textContent).toContain('1.3 km');
    expect(screen.getByTestId('distance-far').textContent).toContain('4.2 km');
  });

  it('routes the card body to the full buddy profile', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByTestId('distance-near')).toBeDefined());

    await userEvent.click(screen.getByRole('button', { name: /Open near's buddy profile/ }));
    expect(navigateMock).toHaveBeenCalledWith('/buddies/find/near');
  });

  it('keeps the row actions off the card body route', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByTestId('distance-near')).toBeDefined());

    await userEvent.click(screen.getByRole('button', { name: 'Message @near' }));
    await userEvent.click(screen.getByRole('button', { name: 'Show interest in @near' }));

    expect(navigateMock).not.toHaveBeenCalled();
  });

  it('opens the card Message thread as a discovery chat', async () => {
    (messagingApi.startConversation as unknown as ReturnType<typeof vi.fn>).mockResolvedValue({ data: { id: 'conv-1' } });
    renderPage();
    await waitFor(() => expect(screen.getByTestId('distance-near')).toBeDefined());

    await userEvent.click(screen.getByRole('button', { name: 'Message @near' }));

    await waitFor(() =>
      expect(messagingApi.startConversation).toHaveBeenCalledWith(['near'], undefined, 'discovery'),
    );
    expect(navigateMock).toHaveBeenCalledWith('/messages/conv-1');
  });

  it('toggles the like optimistically and clears the server back-signal', async () => {
    api.likeBuddy.mockResolvedValue({ data: { liked: true, username: 'near', liked_me: true } });
    renderPage();
    await waitFor(() => expect(screen.getByTestId('distance-near')).toBeDefined());

    await userEvent.click(screen.getByRole('button', { name: 'Show interest in @near' }));

    await waitFor(() =>
      expect(screen.getByRole('button', { name: 'Remove interest in @near' }).getAttribute('aria-pressed')).toBe('true'),
    );
    expect(api.likeBuddy).toHaveBeenCalledWith('near');
    // Mutual interest keeps the "Liked you" affordance off the filled heart.
    expect(screen.queryByText('Liked you')).toBeNull();

    await userEvent.click(screen.getByRole('button', { name: 'Remove interest in @near' }));
    await waitFor(() => expect(api.unlikeBuddy).toHaveBeenCalledWith('near'));
  });

  it('rolls the like back when the server refuses', async () => {
    api.likeBuddy.mockRejectedValue({ response: { data: { message: 'Unable to like this profile.' } } });
    renderPage();
    await waitFor(() => expect(screen.getByTestId('distance-near')).toBeDefined());

    await userEvent.click(screen.getByRole('button', { name: 'Show interest in @near' }));

    await waitFor(() =>
      expect(screen.getByRole('button', { name: 'Show interest in @near' }).getAttribute('aria-pressed')).toBe('false'),
    );
  });

  it('badges the heart when they liked you and you have not', async () => {
    api.getNearbyBuddies.mockResolvedValue({
      data: [buddy({ username: 'mutual', distance: 0.8, liked_me: true })],
      geo: null,
    });
    renderPage();

    await waitFor(() => expect(screen.getByTestId('distance-mutual')).toBeDefined());
    expect(screen.getByText('Liked you')).toBeDefined();
    expect(screen.getByTestId('distance-mutual').textContent).toContain('<1 km');
  });

  it('falls back to initials and a Nearby badge when there is no photo or distance', async () => {
    api.getNearbyBuddies.mockResolvedValue({
      data: [buddy({ username: 'anon', distance: null })],
      geo: null,
    });
    renderPage();

    await waitFor(() => expect(screen.getByTestId('distance-anon')).toBeDefined());
    expect(screen.getByTestId('distance-anon').textContent).toContain('Nearby');
    expect(screen.getByText('A')).toBeDefined();
  });

  it('keeps the empty state', async () => {
    api.getNearbyBuddies.mockResolvedValue({ data: [], geo: null });
    const { container } = renderPage();
    await waitFor(() => expect(container.querySelector('.aspect-\\[3\\/4\\]')).toBeNull());
    expect(screen.getByText(/to find walk buddies around you/)).toBeDefined();
    expect(screen.getByRole('button', { name: 'Near me' })).toBeDefined();
  });

  it('sends the header to the buddy messages page', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByTestId('distance-near')).toBeDefined());

    await userEvent.click(screen.getByRole('button', { name: 'Buddy messages' }));
    expect(navigateMock).toHaveBeenCalledWith('/buddies/messages');
  });
});
