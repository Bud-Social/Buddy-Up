import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen, waitFor, fireEvent, within } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { adminPortalApi, type PortalOrder, type PortalShopCertification } from '@/api/adminPortal';
import AdminShops from '@/pages/admin/AdminShops';

vi.mock('@/api/adminPortal', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/api/adminPortal')>();
  return {
    ...actual,
    adminPortalApi: {
      getShops: vi.fn(),
      getProducts: vi.fn(),
      getShopCertifications: vi.fn(),
      updateShop: vi.fn(),
      reviewShopCertification: vi.fn(),
      getOrders: vi.fn(),
      updateOrderStatus: vi.fn(),
    },
  };
});

const getShops = adminPortalApi.getShops as unknown as ReturnType<typeof vi.fn>;
const getProducts = adminPortalApi.getProducts as unknown as ReturnType<typeof vi.fn>;
const getCerts = adminPortalApi.getShopCertifications as unknown as ReturnType<typeof vi.fn>;
const updateShop = adminPortalApi.updateShop as unknown as ReturnType<typeof vi.fn>;
const reviewCert = adminPortalApi.reviewShopCertification as unknown as ReturnType<typeof vi.fn>;

const env = (data: unknown[], count?: number) => ({
  success: true,
  data,
  message: '',
  errors: null,
  pagination: typeof count === 'number' ? { count, next: null, previous: null } : null,
});

const CERT: PortalShopCertification = {
  id: 'cert-1',
  shop_handle: 'ada_goods',
  shop_name: 'Ada Goods',
  status: 'pending',
  document_type: 'business_registration',
  document_url: 'https://example.com/doc.pdf',
  submitted_at: '2026-02-01T10:00:00Z',
};

const renderPage = () =>
  render(
    <MemoryRouter>
      <AdminShops />
    </MemoryRouter>,
  );

beforeEach(() => {
  vi.clearAllMocks();
  getShops.mockResolvedValue(env([
    { id: 's1', handle: 'ada_goods', name: 'Ada Goods', verification_status: 'verified', is_active: true, product_count: 4 },
    { id: 's2', handle: 'old_shop', name: 'Old Shop', verification_status: 'unverified', is_active: false },
  ], 2));
  getProducts.mockResolvedValue(env([
    { id: 'p1', name: 'Whey Protein', brand: 'Ada', category: 'supplements', verification_status: 'verified', is_active: true, price_display: '$30' },
  ], 1));
  getCerts.mockResolvedValue(env([CERT], 1));
  updateShop.mockResolvedValue(env([{}]));
  reviewCert.mockResolvedValue(env([CERT]));
});

describe('AdminShops certification review queue', () => {
  const openCertTab = async () => {
    renderPage();
    // The tab strip renders below the skeleton, so wait for the first list.
    const tab = await screen.findByRole('button', { name: 'Certifications' });
    fireEvent.click(tab);
    await waitFor(() => expect(screen.getByText('Ada Goods')).toBeInTheDocument());
  };

  it('is the review queue that does not exist anywhere else in the UI today', async () => {
    await openCertTab();
    expect(getCerts).toHaveBeenCalled();
    // The queue row carries a Pending status badge (the stat card also says pending).
    expect(screen.getAllByText('Pending').some((el) => !el.closest('select'))).toBe(true);
    expect(screen.getByRole('link', { name: /open registration document/i })).toHaveAttribute('href', CERT.document_url);
  });

  it('filters the queue by status and re-queries', async () => {
    await openCertTab();
    fireEvent.change(screen.getByLabelText('Certification status'), { target: { value: 'rejected' } });
    await waitFor(() => {
      const last = getCerts.mock.calls[getCerts.mock.calls.length - 1][0];
      expect(last.status).toBe('rejected');
    });
  });

  it('approves with an optional internal note', async () => {
    await openCertTab();
    fireEvent.click(screen.getByRole('button', { name: /^Approve$/ }));
    const confirm = await screen.findByRole('button', { name: /approve certification/i });
    fireEvent.change(screen.getByLabelText('Internal note'), { target: { value: 'registration matches' } });
    fireEvent.click(confirm);
    await waitFor(() =>
      expect(reviewCert).toHaveBeenCalledWith('cert-1', { status: 'approved', reason: 'registration matches' }),
    );
  });

  it('blocks a rejection until a reason is supplied, then sends it', async () => {
    await openCertTab();
    fireEvent.click(screen.getByRole('button', { name: /^Reject$/ }));
    const confirm = await screen.findByRole('button', { name: /reject application/i });
    expect(confirm).toBeDisabled();
    fireEvent.change(screen.getByLabelText('Rejection reason'), { target: { value: 'illegible document' } });
    fireEvent.click(confirm);
    await waitFor(() =>
      expect(reviewCert).toHaveBeenCalledWith('cert-1', { status: 'rejected', reason: 'illegible document' }),
    );
  });

  it('surfaces the server message when a review is refused', async () => {
    reviewCert.mockRejectedValue(
      Object.assign(new Error('x'), {
        response: { status: 400, data: { success: false, message: 'Certification already reviewed by another admin.' } },
      }),
    );
    await openCertTab();
    fireEvent.click(screen.getByRole('button', { name: /^Approve$/ }));
    fireEvent.click(await screen.findByRole('button', { name: /approve certification/i }));
    await waitFor(() => expect(screen.getByText(/already reviewed by another admin/)).toBeInTheDocument());
  });

  it('shows the empty state when nothing has been submitted', async () => {
    getCerts.mockResolvedValue(env([], 0));
    renderPage();
    fireEvent.click(await screen.findByRole('button', { name: 'Certifications' }));
    await waitFor(() => expect(screen.getByText(/No shop certifications submitted yet/i)).toBeInTheDocument());
  });
});

describe('AdminShops shops and products tabs', () => {
  it('renders the shops tab with verification badges', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByText('Old Shop')).toBeInTheDocument());
    const badges = (t: string) => screen.getAllByText(t).filter((el) => !el.closest('select'));
    expect(badges('Verified').length).toBeGreaterThan(0);
    expect(badges('Unverified').length).toBeGreaterThan(0);
    expect(badges('Inactive').length).toBeGreaterThan(0);
    expect(badges('Active').length).toBeGreaterThan(0);
  });

  it('deactivates a shop via a PATCH keyed by handle', async () => {
    renderPage();
    await waitFor(() => expect(screen.getAllByRole('button', { name: /^Deactivate$/ }).length).toBeGreaterThan(0));
    fireEvent.click(screen.getAllByRole('button', { name: /^Deactivate$/ })[0]);
    await waitFor(() => expect(updateShop).toHaveBeenCalledWith('ada_goods', { is_active: false }));
  });

  it('switches to the products tab and renders the product row', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByText('Old Shop')).toBeInTheDocument());
    fireEvent.click(screen.getByRole('button', { name: 'Products' }));

    await waitFor(() => expect(screen.getByText('Whey Protein')).toBeInTheDocument());
    expect(document.body.textContent).toContain('$30');
    expect(document.body.textContent).toContain('supplements');
  });

  it('does not crash on a shop with no fields beyond an id', async () => {
    getShops.mockResolvedValue(env([{ id: 'bare' }], 1));
    renderPage();
    await waitFor(() => expect(screen.getByText('Unnamed shop')).toBeInTheDocument());
    // Defensive defaults stand in for every absent field.
    expect(document.body.textContent).toContain('@—');
    expect(document.body.textContent).toContain('Unknown');
  });
});

describe('AdminShops error handling', () => {
  it('surfaces the list error with a retry', async () => {
    getShops.mockRejectedValue(
      Object.assign(new Error('x'), { response: { status: 403, data: { success: false, message: 'You do not have permission to perform this action.' } } }),
    );
    getProducts.mockRejectedValue(new Error('x'));
    getCerts.mockRejectedValue(new Error('x'));
    renderPage();
    await waitFor(() => expect(screen.getByText(/Staff access is required for the admin console/)).toBeInTheDocument());
  });

  it('renders an order-free empty state for products', async () => {
    getProducts.mockResolvedValue(env([], 0));
    renderPage();
    await waitFor(() => expect(screen.getByText('Old Shop')).toBeInTheDocument());
    fireEvent.click(screen.getByRole('button', { name: 'Products' }));

    await waitFor(() => expect(screen.getByText(/No products match the current filters/i)).toBeInTheDocument());
  });
});

describe('AdminOrders status vocabulary', () => {
  it('offers only real order statuses, never payment-only values', async () => {
    const getOrders = adminPortalApi.getOrders as unknown as ReturnType<typeof vi.fn>;
    getOrders.mockResolvedValue(env([], 0));
    const { default: AdminOrders } = await import('@/pages/admin/AdminOrders');

    render(
      <MemoryRouter>
        <AdminOrders />
      </MemoryRouter>,
    );

    await waitFor(() => expect(screen.getByText('Any status')).toBeInTheDocument());
    // `refunded` is a payment_status, `confirmed` never existed. Either one
    // here 400s the entire list request.
    expect(screen.queryByRole('button', { name: /^refunded$/i })).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /^confirmed$/i })).not.toBeInTheDocument();
    // `paid` and `completed` were missing, and `paid` is the default status
    // of every new order.
    expect(screen.getByRole('button', { name: /^paid$/i })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /^completed$/i })).toBeInTheDocument();
  });

  it('renders transitions from the server-provided allowed_next_statuses', async () => {
    const getOrders = adminPortalApi.getOrders as unknown as ReturnType<typeof vi.fn>;
    const updateStatus = adminPortalApi.updateOrderStatus as unknown as ReturnType<typeof vi.fn>;
    const { default: AdminOrders } = await import('@/pages/admin/AdminOrders');

    const order: PortalOrder = {
      id: 'o1', order_number: 'ORD-1', status: 'paid', payment_status: 'paid',
      allowed_next_statuses: ['processing', 'cancelled'],
    };
    getOrders.mockResolvedValue(env([order], 1));
    updateStatus.mockRejectedValue(
      Object.assign(new Error('x'), {
        response: { status: 400, data: { success: false, message: 'Cannot move order from paid to cancelled for a digital order.' } },
      }),
    );

    render(
      <MemoryRouter>
        <AdminOrders />
      </MemoryRouter>,
    );

    await waitFor(() => expect(screen.getByText('ORD-1')).toBeInTheDocument());
    fireEvent.click(screen.getByRole('button', { name: /details/i }));

    // Exactly the server's list inside the "Move to" panel — nothing
    // invented client-side, and nothing the server omitted.
    const moveTo = (await screen.findByText('Move to')).parentElement as HTMLElement;
    const offered = within(moveTo).getAllByRole('button');
    expect(offered.map((b) => b.textContent?.replace(/.*\s/, ''))).toEqual(['processing', 'cancelled']);

    fireEvent.click(within(moveTo).getByRole('button', { name: /cancelled/i }));
    fireEvent.click(await screen.findByRole('button', { name: /^confirm$/i }));

    await waitFor(() => expect(screen.getByText(/Cannot move order from paid/)).toBeInTheDocument());
    expect(updateStatus).toHaveBeenCalledWith('o1', { status: 'cancelled', note: undefined });
  });
});
