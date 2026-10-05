import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import FindBuddy, { formatDistanceBadge, sortByDistance } from '../FindBuddy';
import { profilesApi, type NearbyBuddy } from '@/api/profiles';

vi.mock('@/api/profiles', () => ({
  profilesApi: {
    getNearbyBuddies: vi.fn(),
    getSearchProfile: vi.fn(),
    getMyProfile: vi.fn(),
    sendBuddyRequest: vi.fn(),
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
    explanation: 'Nearby',
    ...overrides,
  } as NearbyBuddy;
}

beforeEach(() => {
  vi.clearAllMocks();
  api.getSearchProfile.mockResolvedValue({ data: null });
  api.getNearbyBuddies.mockResolvedValue({
    data: [buddy({ username: 'far', distance: 4.2 }), buddy({ username: 'near', distance: 1.3 })],
    geo: null,
  });
});

function renderPage() {
  return render(<MemoryRouter><FindBuddy /></MemoryRouter>);
}

describe('formatDistanceBadge', () => {
  it('formats kilometres, metres and unknown distances', () => {
    expect(formatDistanceBadge(1.3)).toBe('1.3 km');
    expect(formatDistanceBadge(0.64)).toBe('640 m');
    expect(formatDistanceBadge(12)).toBe('12 km');
    expect(formatDistanceBadge(null)).toBeNull();
    expect(formatDistanceBadge(Number.NaN)).toBeNull();
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

describe('FindBuddy result tiles', () => {
  it('renders a square-tile grid with a distance badge per buddy', async () => {
    const { container } = renderPage();

    await waitFor(() => expect(screen.getByTestId('distance-near')).toBeDefined());

    const grid = container.querySelector('.grid.grid-cols-2');
    expect(grid).not.toBeNull();
    expect(grid?.className).toContain('sm:grid-cols-3');
    expect(grid?.className).toContain('lg:grid-cols-4');
    expect(grid?.className).toContain('gap-3');

    const tiles = container.querySelectorAll('.aspect-square');
    expect(tiles.length).toBeGreaterThanOrEqual(2);

    // Closest first, with the banded distance from the search API.
    expect(screen.getByTestId('distance-near').textContent).toContain('1.3 km');
    expect(screen.getByTestId('distance-far').textContent).toContain('4.2 km');
  });

  it('keeps each tile tappable to the profile', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByTestId('distance-near')).toBeDefined());
    expect(screen.getByRole('button', { name: /Open near's profile/ })).toBeDefined();
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
    await waitFor(() => expect(container.querySelector('.aspect-square')).toBeNull());
    expect(screen.getByText(/to find walk buddies around you/)).toBeDefined();
    expect(screen.getByRole('button', { name: 'Near me' })).toBeDefined();
  });
});