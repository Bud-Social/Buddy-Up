import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import CourierDashboard from '@/pages/app/CourierDashboard';
import { marketplaceApi } from '@/api/marketplace';

// Only the network layer is faked. `react-router-dom` stays real so the
// "summary 404s → go to the wizard" case is exercised as an actual redirect.
vi.mock('@/api/marketplace', async (importOriginal) => ({
  ...(await importOriginal<typeof import('@/api/marketplace')>()),
  marketplaceApi: {
    getCourierSummary: vi.fn(),
    getCourierOrders: vi.fn(),
    getCourierEarnings: vi.fn(),
    updateCourierOrderStatus: vi.fn(),
    toggleCourierActive: vi.fn(),
  },
}));

const api = marketplaceApi as unknown as Record<string, ReturnType<typeof vi.fn>>;

/** Axios-shaped rejection so the page's 404 branch is exercised for real. */
const httpError = (status: number, message = '') =>
  Object.assign(new Error(message || `HTTP ${status}`), { response: { status, data: { message } } });

const SUMMARY = {
  vehicle_type: 'motorcycle',
  service_zones: ['Westlands', 'Kilimani'],
  is_active: true,
  rating: 4.75,
  commission_rate: 0.12,
  counts: { processing: 1, shipped: 1, out_for_delivery: 2, delivered: 3 },
  active: 4,
};

const order = (over: Record<string, unknown> = {}) => ({
  id: 'o-1',
  order_number: 'BUD-1001',
  status: 'processing',
  status_label: 'Processing',
  fulfillment_status: 'delivery',
  created_at: '2026-05-01T09:00:00Z',
  paid_at: '2026-05-01T09:05:00Z',
  items: [{ title: 'Whey isolate', quantity: 2, creator_name: 'Karen' }],
  delivery_address: { line1: '12th Street', city: 'Nairobi', country: 'KE' },
  pickup_station: { name: 'Westlands Hub', address: 'Level 2, Sarita Centre' },
  commission_artifacts: { pr: 1 },
  ...over,
});

function setup(orders: unknown[] = []) {
  api.getCourierSummary.mockResolvedValue({ success: true, data: SUMMARY, message: '', errors: null, pagination: null });
  api.getCourierOrders.mockResolvedValue({ success: true, data: orders, message: '', errors: null, pagination: null });
  api.getCourierEarnings.mockResolvedValue({
    success: true,
    data: { delivered_count: 3, delivered_value_artifacts: { champion: 2 }, commission_artifacts: { pr: 4 } },
    message: '', errors: null, pagination: null,
  });
  return render(
    <MemoryRouter initialEntries={['/marketplace/delivery']}>
      <Routes>
        <Route path="/marketplace/delivery" element={<CourierDashboard />} />
        <Route path="/marketplace/delivery/register" element={<h1>Courier registration wizard</h1>} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('CourierDashboard — legal status transitions', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders exactly the four legal transitions across every courier status', async () => {
    setup([
      order({ id: 'a', status: 'processing', order_number: 'BUD-A' }),
      order({ id: 'b', status: 'shipped', order_number: 'BUD-B' }),
      order({ id: 'c', status: 'out_for_delivery', order_number: 'BUD-C' }),
      order({ id: 'd', status: 'out_for_delivery', order_number: 'BUD-D' }),
    ]);

    await screen.findByText('BUD-A');

    // processing → out_for_delivery
    const a = screen.getByText('BUD-A').closest('[class*="rounded"]') as HTMLElement;
    expect(within(a).getByRole('button', { name: 'Start delivery' })).toBeInTheDocument();

    // shipped → out_for_delivery
    const b = screen.getByText('BUD-B').closest('[class*="rounded"]') as HTMLElement;
    expect(within(b).getByRole('button', { name: 'Start delivery' })).toBeInTheDocument();

    // out_for_delivery → delivered AND → processing (both, on both cards)
    const c = screen.getByText('BUD-C').closest('[class*="rounded"]') as HTMLElement;
    expect(within(c).getByRole('button', { name: 'Mark delivered' })).toBeInTheDocument();
    expect(within(c).getByRole('button', { name: 'Return to processing' })).toBeInTheDocument();
    const d = screen.getByText('BUD-D').closest('[class*="rounded"]') as HTMLElement;
    expect(within(d).getByRole('button', { name: 'Mark delivered' })).toBeInTheDocument();
    expect(within(d).getByRole('button', { name: 'Return to processing' })).toBeInTheDocument();
  });

  it('offers no action at all from a status with no legal courier move', async () => {
    setup([
      order({ id: 'a', status: 'pending', order_number: 'BUD-P', status_label: 'Pending' }),
      order({ id: 'b', status: 'delivered', order_number: 'BUD-DEL', status_label: 'Delivered' }),
      order({ id: 'c', status: 'cancelled', order_number: 'BUD-CAN', status_label: 'Cancelled' }),
    ]);

    await screen.findByText('BUD-P');
    expect(screen.queryByRole('button', { name: 'Start delivery' })).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Mark delivered' })).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Return to processing' })).not.toBeInTheDocument();
    // A courier may never cancel, refund or re-open — none of those exist.
    expect(screen.queryByRole('button', { name: /cancel/i })).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /refund/i })).not.toBeInTheDocument();
    expect(screen.queryAllByText(/No status changes available/)).toHaveLength(3);
  });

  it('shows the delivery address and pickup point without a tap', async () => {
    setup([order()]);
    await screen.findByText('BUD-1001');
    expect(screen.getByText('12th Street, Nairobi, KE')).toBeInTheDocument();
    expect(screen.getByText(/Pick up: Westlands Hub/)).toBeInTheDocument();
  });

  it('sends only the legal status to the endpoint', async () => {
    api.updateCourierOrderStatus.mockResolvedValue({ success: true, data: order() });
    setup([order({ id: 'a', status: 'out_for_delivery', order_number: 'BUD-C' })]);

    await screen.findByText('BUD-C');
    await userEvent.click(screen.getByRole('button', { name: 'Return to processing' }));

    await waitFor(() => expect(api.updateCourierOrderStatus).toHaveBeenCalledWith('a', 'processing'));
  });

  it('surfaces the 400 that names an illegal move', async () => {
    api.updateCourierOrderStatus.mockRejectedValue(httpError(400, 'Illegal move: processing -> cancelled.'));
    setup([order({ id: 'a', status: 'out_for_delivery', order_number: 'BUD-C' })]);

    await screen.findByText('BUD-C');
    await userEvent.click(screen.getByRole('button', { name: 'Mark delivered' }));

    expect(await screen.findByRole('alert')).toHaveTextContent('Illegal move: processing -> cancelled.');
  });
});

describe('CourierDashboard — earnings card', () => {
  beforeEach(() => vi.clearAllMocks());

  it('labels the earnings figure as an estimate, not a payable balance', async () => {
    setup([order()]);
    await screen.findByText('BUD-1001');

    expect(screen.getByText('Estimated commission')).toBeInTheDocument();
    expect(screen.getByText('Estimate')).toBeInTheDocument();
    expect(screen.getByText(/not a payable balance/i)).toBeInTheDocument();
    // The value is rendered as an approximation, never as a settled figure.
    expect(screen.getByText(/≈ \$40\.00/)).toBeInTheDocument();
  });

  it('does not use payable-balance wording anywhere on the page', async () => {
    setup([order()]);
    await screen.findByText('BUD-1001');
    expect(document.body.textContent).not.toMatch(/\bavailable (for )?withdraw/i);
    expect(document.body.textContent).not.toMatch(/\bpayout balance\b/i);
  });
});

describe('CourierDashboard — no registration', () => {
  beforeEach(() => vi.clearAllMocks());

  it('routes to the registration wizard when the summary 404s', async () => {
    api.getCourierSummary.mockRejectedValue(httpError(404, 'Not found.'));
    api.getCourierOrders.mockResolvedValue({ success: true, data: [], message: '', errors: null, pagination: null });
    api.getCourierEarnings.mockResolvedValue({ success: true, data: {}, message: '', errors: null, pagination: null });

    render(
      <MemoryRouter initialEntries={['/marketplace/delivery']}>
        <Routes>
          <Route path="/marketplace/delivery" element={<CourierDashboard />} />
          <Route path="/marketplace/delivery/register" element={<h1>Courier registration wizard</h1>} />
        </Routes>
      </MemoryRouter>,
    );

    expect(await screen.findByRole('heading', { name: 'Courier registration wizard' })).toBeInTheDocument();
    // No empty shell: the dashboard body never rendered.
    expect(screen.queryByText('Assigned orders')).not.toBeInTheDocument();
    expect(screen.queryByText('Earnings')).not.toBeInTheDocument();
  });

  it('shows the error inline for any other failure', async () => {
    api.getCourierSummary.mockRejectedValue(httpError(500, 'Delivery service unavailable.'));
    api.getCourierOrders.mockResolvedValue({ success: true, data: [], message: '', errors: null, pagination: null });
    api.getCourierEarnings.mockResolvedValue({ success: true, data: {}, message: '', errors: null, pagination: null });

    render(
      <MemoryRouter initialEntries={['/marketplace/delivery']}>
        <CourierDashboard />
      </MemoryRouter>,
    );

    expect(await screen.findByText('Delivery service unavailable.')).toBeInTheDocument();
  });
});

describe('CourierDashboard — profile card', () => {
  beforeEach(() => vi.clearAllMocks());

  it('shows vehicle, zones, rating and the availability toggle', async () => {
    setup([]);
    await waitFor(() => expect(screen.getByText('Westlands')).toBeInTheDocument());
    expect(screen.getByText('motorcycle')).toBeInTheDocument();
    expect(screen.getByText('4.75')).toBeInTheDocument();
    expect(screen.getByText('12.0%')).toBeInTheDocument();
    expect(screen.getByRole('switch', { name: 'Accepting deliveries' })).toHaveAttribute('aria-checked', 'true');
  });

  it('posts the availability toggle and reflects it immediately', async () => {
    api.toggleCourierActive.mockResolvedValue({ success: true, data: {} });
    setup([]);
    const toggle = await screen.findByRole('switch', { name: 'Accepting deliveries' });

    await userEvent.click(toggle);

    await waitFor(() => expect(api.toggleCourierActive).toHaveBeenCalledWith(false, expect.objectContaining({ vehicle_type: 'motorcycle' })));
    expect(screen.getByRole('switch', { name: 'Accepting deliveries' })).toHaveAttribute('aria-checked', 'false');
  });

  it('rolls the toggle back when the write is refused', async () => {
    api.toggleCourierActive.mockRejectedValue(httpError(400, 'You cannot pause while an order is out for delivery.'));
    setup([]);
    const toggle = await screen.findByRole('switch', { name: 'Accepting deliveries' });

    await userEvent.click(toggle);

    expect(await screen.findByRole('alert')).toHaveTextContent('You cannot pause while an order is out for delivery.');
    expect(screen.getByRole('switch', { name: 'Accepting deliveries' })).toHaveAttribute('aria-checked', 'true');
  });
});