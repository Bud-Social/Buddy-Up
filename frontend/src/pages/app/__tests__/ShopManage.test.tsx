import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import ShopManage from '@/pages/app/ShopManage';
import { marketplaceApi, gymLinksApi } from '@/api/marketplace';

vi.mock('@/api/marketplace', async (importOriginal) => ({
  ...(await importOriginal<typeof import('@/api/marketplace')>()),
  marketplaceApi: {
    ...(await importOriginal<typeof import('@/api/marketplace')>()).marketplaceApi,
    getShopManage: vi.fn(),
    addShopMember: vi.fn(),
    removeShopMember: vi.fn(),
  },
  gymLinksApi: { list: vi.fn(), respond: vi.fn() },
}));

const api = marketplaceApi as unknown as Record<string, ReturnType<typeof vi.fn>>;
const links = gymLinksApi as unknown as Record<string, ReturnType<typeof vi.fn>>;

const envelope = (data: unknown) => ({ success: true, data, message: '', errors: null, pagination: null });

const SHOP = {
  id: 'sh-1',
  handle: 'fitgear',
  name: 'FitGear',
  description: 'Gym gear and supplements',
  logo_url: '',
  banner_url: '',
  is_certified: true,
  accent_color: '#00C896',
  contact_email: 'owner@fitgear.example',
  contact_phone: '',
  website_url: '',
  social_links: {},
  category: 'supplements',
  verification_status: 'verified',
  is_active: true,
  is_verified: true,
  created_at: '2026-01-01T00:00:00Z',
  my_role: 'owner',
  product_count: 12,
  programme_count: 2,
  meal_plan_count: 3,
  event_count: 1,
  members: [
    { id: 'm-1', role: 'owner', profile_data: { username: 'karen', display_name: 'Karen', avatar_url: '' }, created_at: '2026-01-01T00:00:00Z' },
    { id: 'm-2', role: 'manager', profile_data: { username: 'brian', display_name: 'Brian', avatar_url: '' }, created_at: '2026-02-01T00:00:00Z' },
    { id: 'm-3', role: 'staff', profile_data: { username: 'lucy', display_name: 'Lucy', avatar_url: '' }, created_at: '2026-03-01T00:00:00Z' },
  ],
};

function renderPage(url = '/marketplace/shops/fitgear/manage', shopOverride: Record<string, unknown> = {}) {
  api.getShopManage.mockResolvedValue(envelope({ ...SHOP, ...shopOverride }));
  links.list.mockResolvedValue(envelope([]));
  return render(
    <MemoryRouter initialEntries={[url]}>
      <Routes>
        <Route path="/marketplace/shops/:handle/manage" element={<ShopManage />} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('ShopManage — per-shop management console', () => {
  beforeEach(() => vi.clearAllMocks());

  it('renders the shop summary, stats and owner roster by default', async () => {
    renderPage();
    expect((await screen.findAllByText('FitGear')).length).toBeGreaterThan(0);
    expect(screen.getByText('@fitgear')).toBeInTheDocument();
    expect(screen.getByText('12')).toBeInTheDocument(); // products tile
    expect(screen.getByText('2')).toBeInTheDocument();   // programmes tile
  });

  it('deep-links to the team tab and lists the roster with roles', async () => {
    renderPage('/marketplace/shops/fitgear/manage?tab=team');
    expect(await screen.findByRole('tab', { name: 'Team' })).toHaveAttribute('aria-selected', 'true');
    expect(screen.getByText(/@karen/)).toBeInTheDocument();
    expect(screen.getByText(/@brian/)).toBeInTheDocument();
    expect(screen.getByText(/@lucy/)).toBeInTheDocument();
  });

  it('owner sees the invite control and can toggle a staff member to manager', async () => {
    api.addShopMember.mockResolvedValue(envelope({ id: 'm-3', role: 'manager' }));
    renderPage('/marketplace/shops/fitgear/manage?tab=team');
    await screen.findByText(/@lucy/);

    const toggle = screen.getByRole('button', { name: /Toggle lucy between staff and manager/ });
    await userEvent.click(toggle);
    await waitFor(() => expect(api.addShopMember).toHaveBeenCalledWith('fitgear', 'lucy', 'manager'));
  });

  it('deep-links to gym requests and fetches that shop\'s queue only', async () => {
    renderPage('/marketplace/shops/fitgear/manage?tab=gym-links');
    expect(await screen.findByRole('tab', { name: 'Gym requests' })).toHaveAttribute('aria-selected', 'true');
    await waitFor(() => expect(links.list).toHaveBeenCalledWith(undefined, 'fitgear'));
  });

  it('shows a read-only console with an explanatory notice for non-owners', async () => {
    renderPage('/marketplace/shops/fitgear/manage', { my_role: 'staff' });
    expect(await screen.findByText(/Only the shop owner can make changes here/)).toBeInTheDocument();
    expect(screen.queryByLabelText('Username to invite')).not.toBeInTheDocument();
  });
});
