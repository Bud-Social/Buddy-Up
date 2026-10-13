import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { useAuthStore } from '@/store/authStore';
import { Sidebar } from '@/components/layout/Sidebar';
import { marketplaceApi } from '@/api/marketplace';
import { stationsApi } from '@/api/stations';
import { gymsApi } from '@/api/gyms';

vi.mock('@/api/marketplace', async (importOriginal) => ({
  ...(await importOriginal<typeof import('@/api/marketplace')>()),
  marketplaceApi: {
    getMyShops: vi.fn(),
    getMyServices: vi.fn(),
    getOrganisedEvents: vi.fn(),
    getCourierSummary: vi.fn(),
  },
}));

vi.mock('@/api/stations', async (importOriginal) => ({
  ...(await importOriginal<typeof import('@/api/stations')>()),
  stationsApi: { list: vi.fn() },
}));

vi.mock('@/api/gyms', async (importOriginal) => ({
  ...(await importOriginal<typeof import('@/api/gyms')>()),
  gymsApi: { list: vi.fn() },
}));

const market = marketplaceApi as unknown as Record<string, ReturnType<typeof vi.fn>>;
const stations = stationsApi as unknown as Record<string, ReturnType<typeof vi.fn>>;
const gyms = gymsApi as unknown as Record<string, ReturnType<typeof vi.fn>>;

const envelope = (data: unknown) => ({ success: true, data, message: '', errors: null, pagination: null });
const httpError = (status: number) => Object.assign(new Error('x'), { response: { status, data: {} } });

const ME = { id: 'u-me', username: 'karen' };

/** All five probes resolved false — nobody who is not a business of any kind. */
function defaultProbes(overrides: Record<string, unknown> = {}) {
  market.getMyShops.mockResolvedValue(envelope([]));
  market.getMyServices.mockResolvedValue(envelope({ meal_plans: [], programmes: [], events: [], products: [] }));
  market.getOrganisedEvents.mockResolvedValue(envelope([]));
  market.getCourierSummary.mockRejectedValue(httpError(404));
  stations.list.mockResolvedValue(envelope([]));
  gyms.list.mockResolvedValue(envelope([]));
  for (const [key, value] of Object.entries(overrides)) {
    // Only marketplace keys are overridable by name — `stations.list` and
    // `gyms.list` share a name, so those two are always set explicitly.
    (market as Record<string, ReturnType<typeof vi.fn>>)[key].mockResolvedValue(value);
  }
}

const renderSidebar = () =>
  render(
    <MemoryRouter initialEntries={['/feed']}>
      <Sidebar />
    </MemoryRouter>,
  );

/**
 * True for any destination gated behind an ownership signal. The gym manage
 * link carries a slug, so it is matched by pattern rather than by literal.
 */
const isBusinessHref = (href: string) =>
  ['/marketplace/creator', '/marketplace/events', '/marketplace/stations', '/marketplace/delivery'].includes(href)
  || /^\/gyms\/[^/]+\/manage$/.test(href);

const hrefs = () => screen.getAllByRole('link').map((a) => a.getAttribute('href'));

describe('Sidebar — business entries are gated on real ownership data', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    useAuthStore.setState({
      isAuthenticated: true,
      user: { id: ME.id, is_staff: false } as never,
      profile: { username: ME.username } as never,
    });
  });

  it('shows no business section at all for an operator with no roles', async () => {
    defaultProbes();
    renderSidebar();
    await waitFor(() => expect(screen.getByRole('link', { name: 'Home' })).toBeInTheDocument());

    expect(screen.queryByText('Your business')).not.toBeInTheDocument();
    expect(hrefs().filter((h) => h && isBusinessHref(h))).toEqual([]);
    expect(screen.queryByText('Staff')).not.toBeInTheDocument();
  });

  it('shows the full main list regardless of role', async () => {
    defaultProbes();
    renderSidebar();

    for (const label of ['Home', 'Discover', 'Find a Buddy', 'Analytics', 'Gyms', 'Marketplace', 'Profile']) {
      expect(screen.getByRole('link', { name: label })).toBeInTheDocument();
    }
    expect(screen.getByText('Main')).toBeInTheDocument();
  });

  it('shows Creator Studio when the user owns a shop', async () => {
    defaultProbes({ getMyShops: envelope([{ id: 's1', handle: 'fitgear' }]) });
    renderSidebar();

    await waitFor(() => expect(screen.getByRole('link', { name: 'Creator Studio' })).toBeInTheDocument());
    expect(hrefs().filter((h) => h && isBusinessHref(h))).toEqual(['/marketplace/creator']);
  });

  it('shows Creator Studio when the user has sold but owns no shop', async () => {
    defaultProbes({
      getMyServices: envelope({ meal_plans: [], programmes: [{ id: 'p1' }], events: [], products: [] }),
    });
    renderSidebar();

    await waitFor(() => expect(screen.getByRole('link', { name: 'Creator Studio' })).toBeInTheDocument());
  });

  it('shows My Events when the user has created events', async () => {
    defaultProbes({ getOrganisedEvents: envelope([{ id: 'e1', title: 'Sunrise Run' }]) });
    renderSidebar();

    await waitFor(() => expect(screen.getByRole('link', { name: 'My Events' })).toBeInTheDocument());
    expect(hrefs().filter((h) => h && isBusinessHref(h))).toEqual(['/marketplace/events']);
  });

  it('shows My Gym, linked to that gym\'s manage route, for an owner', async () => {
    defaultProbes();
    gyms.list.mockResolvedValue(envelope([{ handle: 'legitgym', name: 'Legit Gym', membership_role: 'owner' }]));
    renderSidebar();

    await waitFor(() => expect(screen.getByRole('link', { name: 'My Gym' })).toBeInTheDocument());
    expect(screen.getByRole('link', { name: 'My Gym' })).toHaveAttribute('href', '/gyms/legitgym/manage');
  });

  it('shows My Gym for a co_owner too', async () => {
    defaultProbes();
    gyms.list.mockResolvedValue(envelope([{ handle: 'sidegym', name: 'Side Gym', membership_role: 'co_owner' }]));
    renderSidebar();

    await waitFor(() => expect(screen.getByRole('link', { name: 'My Gym' })).toHaveAttribute('href', '/gyms/sidegym/manage'));
  });

  it('hides My Gym for a plain member of someone else\'s gym', async () => {
    defaultProbes();
    gyms.list.mockResolvedValue(envelope([{ handle: 'legitgym', name: 'Legit Gym', membership_role: 'member' }]));
    renderSidebar();

    await waitFor(() => expect(screen.getByRole('link', { name: 'Gyms' })).toBeInTheDocument());
    expect(screen.queryByRole('link', { name: 'My Gym' })).not.toBeInTheDocument();
    expect(screen.queryByText('Your business')).not.toBeInTheDocument();
  });

  it('shows My Stations only when the list response proves ownership', async () => {
    defaultProbes();
    stations.list.mockResolvedValue(envelope([
      { id: 's-mine', name: 'Mine', owner_type: 'shop', shop: { owner: ME.id } },
      { id: 's-theirs', name: 'Theirs', owner_type: 'shop', shop: { owner: 'u-other' } },
    ]));
    gyms.list.mockResolvedValue(envelope([]));
    renderSidebar();

    await waitFor(() => expect(screen.getByRole('link', { name: 'My Stations' })).toBeInTheDocument());
    expect(hrefs().filter((h) => h && isBusinessHref(h))).toEqual(['/marketplace/stations']);
  });

  it('hides My Stations when the caller owns none of the listed stations', async () => {
    stations.list.mockResolvedValue(envelope([{ id: 's-theirs', owner_type: 'shop', shop: { owner: 'u-other' } }]));
    gyms.list.mockResolvedValue(envelope([]));
    renderSidebar();

    await waitFor(() => expect(screen.getByRole('link', { name: 'Home' })).toBeInTheDocument());
    expect(screen.queryByRole('link', { name: 'My Stations' })).not.toBeInTheDocument();
  });

  it('shows Courier when the delivery summary resolves', async () => {
    defaultProbes({ getCourierSummary: envelope({ vehicle_type: 'motorcycle', is_active: true }) });
    renderSidebar();

    await waitFor(() => expect(screen.getByRole('link', { name: 'Courier' })).toBeInTheDocument());
    expect(hrefs().filter((h) => h && isBusinessHref(h))).toEqual(['/marketplace/delivery']);
  });

  it('hides Courier when the delivery summary 404s (no DeliveryPersonnel row)', async () => {
    defaultProbes();
    renderSidebar();

    await waitFor(() => expect(screen.getByRole('link', { name: 'Home' })).toBeInTheDocument());
    expect(screen.queryByRole('link', { name: 'Courier' })).not.toBeInTheDocument();
  });

  it('renders exactly the business entries a multi-role operator qualifies for', async () => {
    market.getMyShops.mockResolvedValue(envelope([{ id: 's1', handle: 'fitgear' }]));
    market.getMyServices.mockResolvedValue(envelope({ meal_plans: [], programmes: [], events: [], products: [] }));
    market.getOrganisedEvents.mockResolvedValue(envelope([{ id: 'e1' }]));
    market.getCourierSummary.mockResolvedValue(envelope({ is_active: true }));
    stations.list.mockResolvedValue(envelope([{ id: 's1', owner_type: 'gym', gym: { owner_data: [{ user_id: ME.id, role: 'owner' }] } }]));
    gyms.list.mockResolvedValue(envelope([{ handle: 'legitgym', name: 'Legit Gym', membership_role: 'owner' }]));
    renderSidebar();

    await waitFor(() => expect(screen.getByText('Your business')).toBeInTheDocument());
    expect(hrefs().filter((h) => h && isBusinessHref(h)).sort()).toEqual([
      '/gyms/legitgym/manage',
      '/marketplace/creator',
      '/marketplace/delivery',
      '/marketplace/events',
      '/marketplace/stations',
    ]);
    for (const label of ['Creator Studio', 'My Events', 'My Gym', 'My Stations', 'Courier']) {
      expect(screen.getByRole('link', { name: label })).toBeInTheDocument();
    }
  });

  it('hides every business entry when every probe fails', async () => {
    for (const fn of [market.getMyShops, market.getMyServices, market.getOrganisedEvents, market.getCourierSummary, stations.list, gyms.list]) {
      fn.mockRejectedValue(new Error('network down'));
    }
    renderSidebar();

    await waitFor(() => expect(screen.getByRole('link', { name: 'Home' })).toBeInTheDocument());
    expect(hrefs().filter((h) => h && isBusinessHref(h))).toEqual([]);
  });

  it('never probes anything for a signed-out visitor', async () => {
    useAuthStore.setState({ isAuthenticated: false, user: null, profile: null });
    renderSidebar();

    await waitFor(() => expect(screen.getByRole('link', { name: 'Home' })).toBeInTheDocument());
    expect(market.getMyShops).not.toHaveBeenCalled();
    expect(gyms.list).not.toHaveBeenCalled();
    expect(stations.list).not.toHaveBeenCalled();
  });
});

describe('Sidebar — staff section', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    defaultProbes();
  });

  it('shows Admin under a Staff heading for staff', async () => {
    useAuthStore.setState({ isAuthenticated: true, user: { id: 'u-me', is_staff: true } as never, profile: { username: ME.username } as never });
    renderSidebar();

    await waitFor(() => expect(screen.getByRole('link', { name: 'Admin' })).toBeInTheDocument());
    expect(screen.getByRole('link', { name: 'Admin' })).toHaveAttribute('href', '/admin/overview');
    expect(screen.getByText('Staff')).toBeInTheDocument();
  });

  it('omits the Staff section entirely for non-staff', async () => {
    useAuthStore.setState({ isAuthenticated: true, user: { id: 'u-me', is_staff: false } as never, profile: { username: ME.username } as never });
    renderSidebar();

    await waitFor(() => expect(screen.getByRole('link', { name: 'Home' })).toBeInTheDocument());
    expect(screen.queryByRole('link', { name: 'Admin' })).not.toBeInTheDocument();
    expect(screen.queryByText('Staff')).not.toBeInTheDocument();
  });
});

describe('Sidebar — role switcher', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    useAuthStore.setState({
      isAuthenticated: true,
      user: { id: ME.id, is_staff: false } as never,
      profile: { username: ME.username } as never,
    });
  });

  it('is absent for a single-role operator', async () => {
    defaultProbes({ getMyShops: envelope([{ id: 's1' }]) });
    renderSidebar();

    await waitFor(() => expect(screen.getByRole('link', { name: 'Creator Studio' })).toBeInTheDocument());
    expect(screen.queryByLabelText('Switch between your roles')).not.toBeInTheDocument();
  });

  it('lists exactly the destinations a multi-role operator holds', async () => {
    market.getMyShops.mockResolvedValue(envelope([{ id: 's1' }]));
    market.getMyServices.mockResolvedValue(envelope({ meal_plans: [], programmes: [], events: [], products: [] }));
    market.getOrganisedEvents.mockResolvedValue(envelope([{ id: 'e1' }]));
    market.getCourierSummary.mockResolvedValue(envelope({ is_active: true }));
    stations.list.mockResolvedValue(envelope([]));
    gyms.list.mockResolvedValue(envelope([{ handle: 'legitgym', name: 'Legit Gym', membership_role: 'owner' }]));
    renderSidebar();

    const switcher = await screen.findByLabelText('Switch between your roles');
    const options = Array.from(switcher.querySelectorAll('option')).map((o) => o.getAttribute('value'));
    // Placeholder first, then one entry per destination — no more, no less.
    expect(options).toEqual(['', '/marketplace/creator', '/marketplace/events', '/gyms/legitgym/manage', '/marketplace/delivery']);
    expect(options).not.toContain('/marketplace/stations');
  });

  it('shows a human label for each destination it holds', async () => {
    market.getMyShops.mockResolvedValue(envelope([{ id: 's1' }]));
    market.getMyServices.mockResolvedValue(envelope({ meal_plans: [], programmes: [], events: [], products: [] }));
    market.getOrganisedEvents.mockResolvedValue(envelope([{ id: 'e1' }]));
    market.getCourierSummary.mockResolvedValue(envelope({ is_active: true }));
    stations.list.mockResolvedValue(envelope([]));
    gyms.list.mockResolvedValue(envelope([]));
    renderSidebar();

    const switcher = await screen.findByLabelText('Switch between your roles');
    const labels = Array.from(switcher.querySelectorAll('option')).map((o) => o.textContent);
    expect(labels).toEqual(['Switch role…', 'Shop', 'Events', 'Courier']);
  });
});