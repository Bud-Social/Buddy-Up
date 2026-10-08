import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { adminPortalApi, type ApiResponse } from '@/api/adminPortal';
import { AdminLayout } from '@/components/layout/AdminLayout';
import AdminHome from '@/pages/admin/AdminHome';

const nav = (label: RegExp) => screen.getAllByRole('link', { name: label });

/** Envelope helper — `count` sets the reported total, `items` the fallback. */
const envelope = (count?: number | null, items?: unknown[]) => ({
  success: true,
  data: items ?? [],
  message: '',
  errors: null,
  pagination: typeof count === 'number' ? { count, next: null, previous: null } : null,
}) as unknown as ApiResponse<never>;

describe('AdminLayout', () => {
  beforeEach(() => {
    render(
      <MemoryRouter initialEntries={['/admin']}>
        <AdminLayout />
      </MemoryRouter>,
    );
  });

  it('is branded "Admin", not "ML Admin"', () => {
    expect(screen.getByRole('heading', { level: 1 })).toHaveTextContent('Admin');
    expect(screen.queryByText('ML Admin')).not.toBeInTheDocument();
    expect(document.body.textContent).not.toContain('ML dashboard —');
  });

  it('describes the console as a platform-wide surface in the footer', () => {
    expect(document.body.textContent).toContain('BuddyUp Fit Admin');
    expect(document.body.textContent).toContain('people, marketplace, delivery');
  });

  it('marks the console mode explicitly', () => {
    expect(screen.getByText('Console')).toBeInTheDocument();
  });

  it('exposes every admin domain in the nav', () => {
    for (const label of [
      /Models/, /Users/, /Shops/, /Orders/, /Gyms/,
      /Communities/, /Stations/, /Delivery/, /Wallet/,
      /Moderation/, /Verification/,
    ]) {
      expect(nav(label).length).toBeGreaterThan(0);
    }
  });

  it('keeps the pre-existing ML, moderation and verification routes reachable', () => {
    const hrefs = nav(/./).map((a) => a.getAttribute('href'));
    expect(hrefs).toContain('/admin');
    expect(hrefs).toContain('/admin/moderation');
    expect(hrefs).toContain('/admin/verification');
  });
});

describe('AdminLayout admin <-> app toggle', () => {
  beforeEach(() => {
    render(
      <MemoryRouter initialEntries={['/admin']}>
        <AdminLayout />
      </MemoryRouter>,
    );
  });

  it('offers a two-way toggle between the console and the normal app', () => {
    const group = screen.getByRole('group', { name: /switch between the admin console and the buddyup app/i });
    expect(group).toBeInTheDocument();
    expect(screen.getAllByRole('link', { name: /^Admin$/ }).length).toBeGreaterThan(0);
    expect(screen.getAllByRole('link', { name: /^App$/ }).length).toBeGreaterThan(0);
  });

  it('links out to /feed and back to /admin — plain navigation, same session', () => {
    const hrefs = screen.getAllByRole('link').map((a) => a.getAttribute('href'));
    expect(hrefs).toContain('/feed');
    expect(hrefs).toContain('/admin');
    // Plus the persistent header escape hatch.
    expect(screen.getAllByRole('link', { name: /back to app/i }).length).toBeGreaterThan(0);
  });

  it('does not offer any impersonation or act-as affordance', () => {
    const labels = screen.getAllByRole('link').map((a) => (a.textContent || '').toLowerCase());
    for (const forbidden of ['impersonate', 'act as', 'view as', 'switch user', 'sudo']) {
      expect(labels.some((l) => l.includes(forbidden))).toBe(false);
    }
  });

  it('states that the admin is acting as themselves', () => {
    expect(document.body.textContent).toContain('signed in as yourself');
  });
});

describe('AdminLayout mode highlighting', () => {
  it('marks the console side active while inside the console', () => {
    render(
      <MemoryRouter initialEntries={['/admin/users']}>
        <AdminLayout />
      </MemoryRouter>,
    );
    const active = screen.getAllByRole('link', { name: /^Admin$/ }).filter((a) => a.className.includes('text-buddy-green'));
    expect(active.length).toBeGreaterThan(0);
  });

  it('marks the app side active while in the normal app', () => {
    render(
      <MemoryRouter initialEntries={['/feed']}>
        <AdminLayout />
      </MemoryRouter>,
    );
    const appLinks = screen.getAllByRole('link', { name: /^App$/ });
    expect(appLinks.some((a) => a.className.includes('text-buddy-green'))).toBe(true);
  });
});

describe('AdminHome', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  it('renders one overview card per domain and links to each page', async () => {
    // Every probe mocked: one failing endpoint must degrade a single card,
    // not blank the console.
    vi.spyOn(adminPortalApi, 'getUsers').mockResolvedValue(envelope(42));
    vi.spyOn(adminPortalApi, 'getShops').mockResolvedValue(envelope(7));
    vi.spyOn(adminPortalApi, 'getProducts').mockResolvedValue(envelope(120));
    vi.spyOn(adminPortalApi, 'getOrders').mockResolvedValue(envelope(3));
    vi.spyOn(adminPortalApi, 'getGyms').mockResolvedValue(envelope(9));
    vi.spyOn(adminPortalApi, 'getCommunities').mockResolvedValue(envelope(4));
    vi.spyOn(adminPortalApi, 'getStations').mockResolvedValue(envelope(2));
    vi.spyOn(adminPortalApi, 'getDeliveryPersonnel').mockResolvedValue(envelope(11));
    vi.spyOn(adminPortalApi, 'getTransactions').mockRejectedValue(
      Object.assign(new Error('x'), { response: { status: 500, data: { message: 'Ledger unavailable.' } } }),
    );

    render(
      <MemoryRouter>
        <AdminHome />
      </MemoryRouter>,
    );

    await waitFor(() => expect(screen.getByText('42')).toBeInTheDocument());
    expect(screen.getByText('120')).toBeInTheDocument();
    expect(screen.getByText('9')).toBeInTheDocument();
    // Exactly one card degraded.
    expect(screen.getAllByText('Unavailable')).toHaveLength(1);
    expect(screen.getByRole('link', { name: 'Open Users' })).toHaveAttribute('href', '/admin/users');
    expect(screen.getByRole('link', { name: 'Open Orders' })).toHaveAttribute('href', '/admin/orders');
    expect(screen.getByRole('link', { name: 'Open Transactions' })).toHaveAttribute('href', '/admin/wallet');
    expect(screen.getByRole('link', { name: 'Open Delivery' })).toHaveAttribute('href', '/admin/delivery');
  });

  it('falls back to the item count when the envelope carries no pagination', async () => {
    vi.spyOn(adminPortalApi, 'getUsers').mockResolvedValue(envelope(undefined, [{ id: 'a' }, { id: 'b' }]) as never);
    vi.spyOn(adminPortalApi, 'getShops').mockResolvedValue(envelope(null));
    vi.spyOn(adminPortalApi, 'getProducts').mockResolvedValue(envelope(null));
    vi.spyOn(adminPortalApi, 'getOrders').mockResolvedValue(envelope(null));
    vi.spyOn(adminPortalApi, 'getGyms').mockResolvedValue(envelope(null));
    vi.spyOn(adminPortalApi, 'getCommunities').mockResolvedValue(envelope(null));
    vi.spyOn(adminPortalApi, 'getStations').mockResolvedValue(envelope(null));
    vi.spyOn(adminPortalApi, 'getDeliveryPersonnel').mockResolvedValue(envelope(null));
    vi.spyOn(adminPortalApi, 'getTransactions').mockResolvedValue(envelope(null));

    render(
      <MemoryRouter>
        <AdminHome />
      </MemoryRouter>,
    );
    await waitFor(() => expect(screen.getByText('2')).toBeInTheDocument());
  });

  it('surfaces a console-wide failure when every probe fails', async () => {
    for (const key of ['getUsers', 'getShops', 'getProducts', 'getOrders', 'getGyms', 'getCommunities', 'getStations', 'getDeliveryPersonnel', 'getTransactions'] as const) {
      vi.spyOn(adminPortalApi, key).mockRejectedValue(new Error('down'));
    }
    render(
      <MemoryRouter>
        <AdminHome />
      </MemoryRouter>,
    );
    await waitFor(() => expect(screen.getByText(/not reachable from this session/i)).toBeInTheDocument());
  });
});

describe('Sidebar staff entry point', () => {
  beforeEach(() => {
    vi.doUnmock('@/components/features/support/SupportDialog');
  });

  it('points staff at the new admin home and labels it clearly', async () => {
    const store = await import('@/store/authStore');
    store.useAuthStore.setState({
      user: {
        id: 'u-1', email: 'staff@buddyup.fit', email_verified: true, is_adult: true,
        phone_verified: true, is_staff: true, created_at: '2026-01-01',
      } as never,
    });
    const { Sidebar } = await import('@/components/layout/Sidebar');
    render(
      <MemoryRouter>
        <Sidebar />
      </MemoryRouter>,
    );
    const entry = screen.getByRole('link', { name: /Admin/ });
    expect(entry).toHaveAttribute('href', '/admin/overview');
    expect(entry.textContent).toBe('Admin');

    store.useAuthStore.setState({ user: null });
  });
});

describe('Sidebar non-staff', () => {
  it('does not expose the admin entry point', async () => {
    const store = await import('@/store/authStore');
    store.useAuthStore.setState({ user: null });
    const { Sidebar } = await import('@/components/layout/Sidebar');
    render(
      <MemoryRouter>
        <Sidebar />
      </MemoryRouter>,
    );
    expect(screen.queryByRole('link', { name: /^Admin$/ })).not.toBeInTheDocument();
  });
});