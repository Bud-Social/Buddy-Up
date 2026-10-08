import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import CheckoutPage from '@/pages/app/CheckoutPage';
import { marketplaceApi } from '@/api/marketplace';
import { walletApi } from '@/api/wallet';
import { stationsApi } from '@/api/stations';

const navigateMock = vi.fn();

vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual<typeof import('react-router-dom')>('react-router-dom');
  return { ...actual, useNavigate: () => navigateMock };
});

// Only the network calls are faked — the pure helpers (error-message extraction,
// station sorting/labelling, 404 detection) are the real implementations.
vi.mock('@/api/marketplace', async (importOriginal) => ({
  ...(await importOriginal<typeof import('@/api/marketplace')>()),
  marketplaceApi: { getCart: vi.fn(), checkoutCart: vi.fn() },
}));

vi.mock('@/api/wallet', () => ({
  walletApi: { getBalance: vi.fn() },
}));

vi.mock('@/api/stations', async (importOriginal) => ({
  ...(await importOriginal<typeof import('@/api/stations')>()),
  stationsApi: { list: vi.fn(), createPaymentIntent: vi.fn() },
}));

const market = marketplaceApi as unknown as Record<string, ReturnType<typeof vi.fn>>;
const wallet = walletApi as unknown as Record<string, ReturnType<typeof vi.fn>>;
const stations = stationsApi as unknown as Record<string, ReturnType<typeof vi.fn>>;

const PRODUCT_ITEM = {
  id: 'item-1',
  item_type: 'product',
  quantity: 2,
  product: 'p-1',
  product_detail: {
    id: 'p-1',
    name: 'Whey isolate',
    delivery_modes: ['pickup', 'delivery'],
    fulfillment_details: { pickup_location: 'Karura Fitness' },
  },
  item_total_artifacts: { dumbbell: 2 },
  item_total_usd: 1,
};

const DIGITAL_ITEM = {
  id: 'item-2',
  item_type: 'meal_plan',
  quantity: 1,
  meal_plan: 'plan-1',
  meal_plan_detail: { title: 'Keto reset' },
  item_total_artifacts: { dumbbell: 1 },
  item_total_usd: 0.5,
};

/** Rates come from the cart endpoint, so the summary reuses them verbatim. */
const cartResponse = (items: unknown[], overrides: Record<string, unknown> = {}) => ({
  data: {
    base_currency: 'USD',
    local_currency: 'KES',
    conversion_rate: 129.5,
    total_artifacts: { dumbbell: 3 },
    total_usd: 1.5,
    total_local_currency: 194.25,
    items,
    ...overrides,
  },
});

/** The backend only ever suggests a mode the cart's products actually allow. */
const physicalSuggestion = {
  type: 'delivery',
  available: ['delivery', 'pickup'],
  detail: { pickup_location: 'Karura Fitness' },
};

const STATIONS = [
  {
    id: 'st-far',
    name: 'Lakeside Hub',
    address: 'Oginga Odinga Street',
    city: 'Nairobi',
    country: 'Kenya',
    opening_hours: { monday: { open: '09:00', close: '17:00' }, tuesday: { open: '09:00', close: '17:00' } },
    is_primary: false,
    owner_type: 'shop',
    distance_km: 11.4,
  },
  {
    id: 'st-near',
    name: 'Westlands Hub',
    address: 'Mombasa Road',
    city: 'Nairobi',
    country: 'Kenya',
    opening_hours: {
      monday: { open: '08:00', close: '20:00' },
      tuesday: { open: '08:00', close: '20:00' },
      wednesday: { open: '08:00', close: '20:00' },
      thursday: { open: '08:00', close: '20:00' },
      friday: { open: '08:00', close: '20:00' },
      saturday: { open: '08:00', close: '20:00' },
      sunday: { open: '08:00', close: '20:00' },
    },
    is_primary: true,
    owner_type: 'shop',
    distance_km: 0.8,
  },
];

const checkoutResult = (over: Record<string, unknown> = {}) => ({
  data: {
    order_id: 'order-1',
    order_number: 'BUD-1042',
    status: 'paid',
    fulfillment_type: 'digital',
    items: [{ item_type: 'meal_plan', title: 'Keto reset', quantity: 1, paid_artifacts: { dumbbell: 3 } }],
    total_artifacts: { dumbbell: 3 },
    original_artifacts: { dumbbell: 4 },
    savings_artifacts: { dumbbell: 1 },
    savings_usd: 0.5,
    discount_code: 'FIT10',
    spent_usd: 1.5,
    new_balance: { dumbbell: 2 },
    ...over,
  },
});

const httpError = (status: number, body: Record<string, unknown>) => {
  const e = new Error(`Request failed with status code ${status}`) as Error & { response: unknown };
  e.response = { status, data: body };
  return e;
};

beforeEach(() => {
  vi.clearAllMocks();
  market.getCart.mockResolvedValue(cartResponse([PRODUCT_ITEM, DIGITAL_ITEM]));
  market.checkoutCart.mockResolvedValue(checkoutResult());
  wallet.getBalance.mockResolvedValue({ data: { regular_balance: [{ artifact_type: 'dumbbell', quantity: 5 }] } });
  stations.list.mockResolvedValue({ success: true, data: STATIONS });
  stations.createPaymentIntent.mockResolvedValue({ success: true, data: { id: 'pi-1', status: 'initiated' } });
});

function renderCheckout() {
  return render(<MemoryRouter><CheckoutPage /></MemoryRouter>);
}

/** The summary card only mounts once the cart has loaded, so it gates assertions. */
const reviewForm = () => screen.findByText('Order summary');
const payButton = () => screen.getByRole('button', { name: /^Pay|^Confirm Order$/ });
const fulfillmentTile = (name: RegExp) => screen.queryByRole('button', { name });
const paymentTile = (name: RegExp) => screen.getByRole('button', { name });


async function chooseDelivery() {
  await userEvent.click(screen.getByRole('button', { name: /Delivery/ }));
}

async function fillAddress() {
  await userEvent.type(screen.getByLabelText('Address line 1'), 'Mombasa Road, Westlands');
  await userEvent.type(screen.getByLabelText('City'), 'Nairobi');
  await userEvent.type(screen.getByLabelText('Country'), 'Kenya');
  await userEvent.type(screen.getByLabelText('Phone'), '+254 712 345 678');
}

describe('CheckoutPage order summary', () => {
  it('renders items, per-item prices and the USD/KES total from the cart rates', async () => {
    renderCheckout();

    expect(await screen.findByText('Whey isolate')).toBeInTheDocument();
    expect(screen.getByText('Keto reset')).toBeInTheDocument();
    expect(screen.getByText('USD 1.00 · KES 129.50')).toBeInTheDocument();
    expect(screen.getByText('Total (USD)')).toBeInTheDocument();
    expect(screen.getByText('USD 1.50')).toBeInTheDocument();
    expect(screen.getByText('Total (KES)')).toBeInTheDocument();
    expect(screen.getByText('KES 194.25')).toBeInTheDocument();
    expect(screen.getByText('3 dumbbell')).toBeInTheDocument();
  });

  it('shows the discount and the saving it produced', async () => {
    market.getCart.mockResolvedValue({
      data: {
        ...cartResponse([DIGITAL_ITEM, { ...DIGITAL_ITEM, id: 'item-3', quantity: 1 }]).data,
        discount_code: { code: 'FIT10', discount_type: 'percentage', discount_pct: 20 },
        total_artifacts: { dumbbell: 1 },
      },
    });
    renderCheckout();

    expect(await screen.findByText('FIT10 — 20% off')).toBeInTheDocument();
    expect(screen.getByText('-1 dumbbell')).toBeInTheDocument();
  });

  it('shows an empty state instead of a broken checkout when the cart is empty', async () => {
    market.getCart.mockResolvedValue({ data: { ...cartResponse([]).data, items: [] } });
    renderCheckout();

    expect(await screen.findByText('There is nothing to check out')).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /^Pay/ })).toBeNull();
  });
});

describe('CheckoutPage fulfillment feasibility', () => {
  it('offers pickup and delivery for a physical product that allows both', async () => {
    renderCheckout();
    await reviewForm();

    expect(fulfillmentTile(/^Digital/)).not.toBeNull();
    expect(fulfillmentTile(/^Pickup/)).not.toBeNull();
    expect(fulfillmentTile(/^Delivery/)).not.toBeNull();
    expect(screen.queryByText(/are delivered digitally, so pickup and delivery are not/)).toBeNull();
  });

  it('offers digital only — and says why — when nothing physical is in the cart', async () => {
    market.getCart.mockResolvedValue(cartResponse([DIGITAL_ITEM]));
    renderCheckout();
    await reviewForm();

    expect(fulfillmentTile(/^Digital/)).not.toBeNull();
    expect(fulfillmentTile(/^Pickup/)).toBeNull();
    expect(fulfillmentTile(/^Delivery/)).toBeNull();
    expect(screen.getByText(/Meal plans, programmes and event tickets are delivered digitally/)).toBeInTheDocument();
  });

  it('honours a product that only delivers', async () => {
    market.getCart.mockResolvedValue(cartResponse([{ ...PRODUCT_ITEM, product_detail: { ...PRODUCT_ITEM.product_detail, delivery_modes: ['delivery'] } }]));
    renderCheckout();
    await reviewForm();

    expect(fulfillmentTile(/^Delivery/)).not.toBeNull();
    expect(fulfillmentTile(/^Pickup/)).toBeNull();
  });

  it('pre-selects the server suggestion when the cart can fulfill it', async () => {
    market.getCart.mockResolvedValue(cartResponse([PRODUCT_ITEM, DIGITAL_ITEM], { suggested_fulfillment: physicalSuggestion }));
    renderCheckout();
    await reviewForm();

    expect(fulfillmentTile(/^Delivery/)).toHaveAttribute('aria-pressed', 'true');
    expect(fulfillmentTile(/^Digital/)).toHaveAttribute('aria-pressed', 'false');
  });

  it('ignores a server suggestion the cart cannot fulfill', async () => {
    market.getCart.mockResolvedValue(cartResponse([DIGITAL_ITEM], { suggested_fulfillment: physicalSuggestion }));
    renderCheckout();
    await reviewForm();

    expect(fulfillmentTile(/^Delivery/)).toBeNull();
    expect(fulfillmentTile(/^Digital/)).toHaveAttribute('aria-pressed', 'true');
  });

  it('seeds the collection point from the seller fulfillment details', async () => {
    stations.list.mockRejectedValue(httpError(404, { message: 'Not found.' }));
    market.getCart.mockResolvedValue(cartResponse([PRODUCT_ITEM, DIGITAL_ITEM], { suggested_fulfillment: physicalSuggestion }));
    renderCheckout();
    await reviewForm();

    await userEvent.click(screen.getByRole('button', { name: /^Pickup/ }));
    expect(await screen.findByLabelText('Collection point')).toHaveValue('Karura Fitness');
  });
});

describe('CheckoutPage payment-method gating', () => {
  it('keeps Confirm open when the wallet covers the cart and shows the after-purchase balance', async () => {
    renderCheckout();

    const artifacts = await screen.findByRole('button', { name: /Artifacts/ });
    expect(artifacts).toHaveAttribute('aria-pressed', 'true');
    expect(artifacts).toHaveTextContent('Balance 5 dumbbell · 2 after this order');
    expect((payButton() as HTMLButtonElement).disabled).toBe(false);
    expect(screen.queryByText(/Not enough dumbbell/)).toBeNull();
  });

  it('disables and annotates artifacts when the wallet is short, and blocks Confirm', async () => {
    wallet.getBalance.mockResolvedValue({ data: { regular_balance: [{ artifact_type: 'dumbbell', quantity: 1 }] } });
    renderCheckout();

    const artifacts = await screen.findByRole('button', { name: /Artifacts/ });
    expect((artifacts as HTMLButtonElement).disabled).toBe(true);
    expect(artifacts).toHaveTextContent('This order needs 3 dumbbell, you have 1.');
    expect(screen.getByText(/Not enough dumbbell — this cart needs 3, you have 1/)).toBeInTheDocument();
    expect(payButton()).toHaveTextContent('Confirm Order');
    expect((payButton() as HTMLButtonElement).disabled).toBe(true);

    await userEvent.click(artifacts);
    expect(market.checkoutCart).not.toHaveBeenCalled();
  });

  it('opens the gate back up on M-Pesa, which does not draw on the wallet', async () => {
    wallet.getBalance.mockResolvedValue({ data: { regular_balance: [{ artifact_type: 'dumbbell', quantity: 1 }] } });
    renderCheckout();

    await screen.findByRole('button', { name: /Artifacts/ });
    const mpesa = paymentTile(/M-Pesa/);
    expect((mpesa as HTMLButtonElement).disabled).toBe(false);
    expect(mpesa).toHaveTextContent('Confirm the prompt on your phone first.');

    await userEvent.click(mpesa);
    expect((payButton() as HTMLButtonElement).disabled).toBe(false);
    expect(payButton()).toHaveTextContent('KES 194.25');
    expect(screen.getByLabelText('M-Pesa phone')).toBeInTheDocument();
  });

  it('blocks an M-Pesa order with a malformed phone number', async () => {
    renderCheckout();
    await screen.findByRole('button', { name: /Artifacts/ });
    await userEvent.click(paymentTile(/M-Pesa/));

    await userEvent.type(screen.getByLabelText('M-Pesa phone'), '123');
    await userEvent.click(payButton());

    expect(await screen.findByRole('alert')).toHaveTextContent('Enter a valid M-Pesa phone number to continue.');
    expect(market.checkoutCart).not.toHaveBeenCalled();
  });

  it('does not assert a shortfall when the wallet read fails, leaving the server to decide', async () => {
    wallet.getBalance.mockRejectedValue(new Error('offline'));
    renderCheckout();

    const artifacts = await screen.findByRole('button', { name: /Artifacts/ });
    expect((artifacts as HTMLButtonElement).disabled).toBe(false);
    expect(screen.queryByText(/Not enough dumbbell/)).toBeNull();
  });
});

describe('CheckoutPage delivery address validation', () => {
  it('blocks the submit and names each missing required field', async () => {
    renderCheckout();
    await reviewForm();
    await chooseDelivery();

    await userEvent.click(payButton());

    expect(await screen.findByRole('alert')).toHaveTextContent('Check the delivery address');
    expect(market.checkoutCart).not.toHaveBeenCalled();
    expect(screen.getByText('Enter the street address.')).toBeInTheDocument();
    expect(screen.getByText('Enter the city.')).toBeInTheDocument();
    expect(screen.getByText('Enter the country.')).toBeInTheDocument();
    expect(screen.getByText('Enter a phone number for the courier.')).toBeInTheDocument();
  });

  it('rejects a phone number that is not a plausible number', async () => {
    renderCheckout();
    await reviewForm();
    await chooseDelivery();
    await fillAddress();

    await userEvent.clear(screen.getByLabelText('Phone'));
    await userEvent.type(screen.getByLabelText('Phone'), 'call-me');
    await userEvent.click(payButton());

    expect(await screen.findByText('Use 7–15 digits, e.g. +254 712 345 678.')).toBeInTheDocument();
    expect(market.checkoutCart).not.toHaveBeenCalled();
  });

  it('submits the whole structured address once it validates', async () => {
    renderCheckout();
    await reviewForm();
    await chooseDelivery();
    await fillAddress();
    await userEvent.type(screen.getByLabelText('Address line 2'), 'Westlands Mall, Level 2');
    await userEvent.type(screen.getByLabelText('Postal code'), '00100');
    await userEvent.type(screen.getByLabelText('Notes'), 'Buzz 4B at the east gate');

    await userEvent.click(payButton());

    await waitFor(() => expect(market.checkoutCart).toHaveBeenCalledTimes(1));
    expect(market.checkoutCart.mock.calls[0][0]).toEqual({
      fulfillment_type: 'delivery',
      payment_method: 'artifacts',
      delivery_address: {
        line1: 'Mombasa Road, Westlands',
        line2: 'Westlands Mall, Level 2',
        city: 'Nairobi',
        postal_code: '00100',
        country: 'Kenya',
        phone: '+254 712 345 678',
        notes: 'Buzz 4B at the east gate',
      },
    });
  });
});

describe('CheckoutPage pickup station picker', () => {
  it('lists stations nearest first with distance and opening hours', async () => {
    renderCheckout();
    await reviewForm();
    await userEvent.click(screen.getByRole('button', { name: /^Pickup/ }));

    await screen.findByRole('radio', { name: /Westlands Hub/ });

    const radios = screen.getAllByRole('radio') as HTMLInputElement[];
    expect(radios).toHaveLength(2);
    const options = screen.getAllByRole('radio').map((el) => el.closest('label') as HTMLElement);
    expect(within(options[0]).getByText('Westlands Hub')).toBeInTheDocument();
    expect(within(options[0]).getByText(/800 m away/)).toBeInTheDocument();
    expect(within(options[0]).getByText('Daily 08:00–20:00')).toBeInTheDocument();
    expect(within(options[0]).getByText('Primary')).toBeInTheDocument();
    expect(within(options[0]).getByText('Nearest')).toBeInTheDocument();
    expect(within(options[1]).getByText('Lakeside Hub')).toBeInTheDocument();
    expect(within(options[1]).getByText(/11 km away|11.4 km away/)).toBeInTheDocument();
    expect(within(options[1]).getByText('Mon 09:00–17:00 · Tue 09:00–17:00')).toBeInTheDocument();
  });

  it('refuses to submit until a station is chosen', async () => {
    renderCheckout();
    await reviewForm();
    await userEvent.click(screen.getByRole('button', { name: /^Pickup/ }));
    await screen.findByRole('radio', { name: /Westlands Hub/ });

    await userEvent.click(payButton());

    expect(await screen.findByRole('alert')).toHaveTextContent('Choose a pickup station to continue.');
    expect(screen.getByText('Choose the station you will collect from.')).toBeInTheDocument();
    expect(market.checkoutCart).not.toHaveBeenCalled();
  });

  it('carries pickup_station_id and payment_method on the success payload', async () => {
    market.checkoutCart.mockResolvedValue(
      checkoutResult({ fulfillment_type: 'pickup', items: [{ item_type: 'product', title: 'Whey isolate', quantity: 2, paid_artifacts: { dumbbell: 2 } }] }),
    );
    renderCheckout();
    await reviewForm();
    await userEvent.click(screen.getByRole('button', { name: /^Pickup/ }));
    await userEvent.click(await screen.findByRole('radio', { name: /Westlands Hub/ }));
    await userEvent.click(paymentTile(/^Card/));
    await userEvent.click(payButton());

    await waitFor(() => expect(market.checkoutCart).toHaveBeenCalledTimes(1));
    expect(market.checkoutCart.mock.calls[0][0]).toEqual({
      fulfillment_type: 'pickup',
      payment_method: 'card',
      pickup_station_id: 'st-near',
      pickup_details: {
        venue: 'Westlands Hub',
        location: 'Westlands Hub',
        instructions: '',
      },
    });
    // Card is real money, so an intent is started once the order exists.
    await waitFor(() =>
      expect(stations.createPaymentIntent).toHaveBeenCalledWith({ order_id: 'order-1', method: 'card' }),
    );
  });

  it('falls back to a search box when there is no location to rank by', async () => {
    stations.list.mockResolvedValue({
      success: true,
      data: STATIONS.map(({ distance_km: _omitted, ...rest }) => rest),
    });

    renderCheckout();
    await reviewForm();
    await userEvent.click(screen.getByRole('button', { name: /^Pickup/ }));

    await screen.findByRole('radio', { name: /Lakeside Hub/ });
    expect(stations.list).toHaveBeenCalledWith({ lat: undefined, lng: undefined, radius_km: undefined });
    expect(screen.getByText(/No location shared, so stations are not ranked by distance/)).toBeInTheDocument();
    expect(screen.queryByText(/\d+(\.\d+)? (km|m) away/)).toBeNull();

    await userEvent.type(screen.getByLabelText('Search stations'), 'lake');
    expect(screen.getAllByRole('radio')).toHaveLength(1);
    expect(screen.getByRole('radio', { name: /Lakeside Hub/ })).toBeInTheDocument();

    await userEvent.clear(screen.getByLabelText('Search stations'));
    await userEvent.type(screen.getByLabelText('Search stations'), 'nowhere');
    expect(screen.getByText(/No station matches/)).toBeInTheDocument();
  });

  it('degrades to a free-text collection point when the endpoint is not there yet', async () => {
    stations.list.mockRejectedValue(httpError(404, { message: 'Not found.' }));
    renderCheckout();
    await reviewForm();
    await userEvent.click(screen.getByRole('button', { name: /^Pickup/ }));

    expect(await screen.findByLabelText('Collection point')).toBeInTheDocument();
    expect(screen.getByText(/Station picking is unavailable right now/)).toBeInTheDocument();
    expect(screen.getByText('Not found.')).toBeInTheDocument();

    await userEvent.click(payButton());
    expect(await screen.findByRole('alert')).toHaveTextContent('Enter a collection point to continue.');

    await userEvent.type(screen.getByLabelText('Collection point'), 'Karura Fitness, Westlands');
    await userEvent.click(payButton());
    await waitFor(() => expect(market.checkoutCart).toHaveBeenCalledTimes(1));
    expect(market.checkoutCart.mock.calls[0][0]).toMatchObject({
      fulfillment_type: 'pickup',
      pickup_station_id: null,
      pickup_details: { location: 'Karura Fitness, Westlands' },
    });
  });
});

describe('CheckoutPage failure handling', () => {
  it('surfaces the ledger rejection inline and keeps every field the buyer typed', async () => {
    market.checkoutCart.mockRejectedValue(
      httpError(400, { success: false, message: 'Insufficient dumbbell tokens.' }),
    );
    renderCheckout();
    await reviewForm();
    await chooseDelivery();
    await fillAddress();
    await userEvent.type(screen.getByLabelText('Address line 2'), 'Westlands Mall, Level 2');

    await userEvent.click(payButton());

    expect(await screen.findByRole('alert')).toHaveTextContent('Insufficient dumbbell tokens.');
    expect(screen.getByLabelText('Address line 1')).toHaveValue('Mombasa Road, Westlands');
    expect(screen.getByLabelText('Address line 2')).toHaveValue('Westlands Mall, Level 2');
    expect(screen.getByLabelText('City')).toHaveValue('Nairobi');
    expect(screen.getByLabelText('Country')).toHaveValue('Kenya');
    expect(screen.getByLabelText('Phone')).toHaveValue('+254 712 345 678');
    // Still on the review form, so the buyer can change something and retry.
    expect(screen.getByText('Order summary')).toBeInTheDocument();
    expect(screen.queryByText('Order placed')).toBeNull();
  });

  it('keeps a chosen station and payment method after a failure', async () => {
    market.checkoutCart.mockRejectedValue(httpError(500, { message: 'Server exploded.' }));
    renderCheckout();
    await reviewForm();
    await userEvent.click(screen.getByRole('button', { name: /^Pickup/ }));
    await userEvent.click(await screen.findByRole('radio', { name: /Westlands Hub/ }));
    await userEvent.click(paymentTile(/M-Pesa/));
    await userEvent.type(screen.getByLabelText('M-Pesa phone'), '0712345678');

    await userEvent.click(payButton());

    expect(await screen.findByRole('alert')).toHaveTextContent('Server exploded.');
    expect(screen.getByRole('radio', { name: /Westlands Hub/ })).toBeChecked();
    expect(screen.getByLabelText('M-Pesa phone')).toHaveValue('0712345678');
  });

  it('refuses to render a receipt when the response carries no order reference', async () => {
    market.checkoutCart.mockResolvedValue({ data: { status: 'paid' } });
    renderCheckout();
    await reviewForm();

    await userEvent.click(payButton());

    expect(await screen.findByRole('alert')).toHaveTextContent('Checkout returned an unexpected response');
    expect(screen.queryByText('Order placed')).toBeNull();
  });

  it('shows a retry affordance when the cart itself cannot be loaded', async () => {
    market.getCart.mockRejectedValue(httpError(500, { message: 'Cart unavailable.' }));
    renderCheckout();

    expect(await screen.findByText('Cart unavailable.')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Try again' })).toBeInTheDocument();
  });
});

describe('CheckoutPage receipt', () => {
  it('renders order number, totals, rail, fulfillment and a link to the order', async () => {
    renderCheckout();
    await reviewForm();
    await userEvent.click(payButton());

    expect(await screen.findByText('Order placed')).toBeInTheDocument();
    expect(screen.getByText('Order #BUD-1042')).toBeInTheDocument();
    expect(screen.getByText('Artifacts (wallet)')).toBeInTheDocument();
    expect(screen.getByText('Paid')).toBeInTheDocument();
    expect(screen.getByText('Digital')).toBeInTheDocument();
    expect(screen.getByText('Status: paid')).toBeInTheDocument();
    expect(screen.getByText('You paid')).toBeInTheDocument();
    expect(screen.getByText('Keto reset × 1')).toBeInTheDocument();
    expect(screen.getByText('-1 dumbbell')).toBeInTheDocument();
    expect(screen.getByText(/Savings \(FIT10\)/)).toBeInTheDocument();
    expect(screen.getByText('USD 1.50')).toBeInTheDocument();
    expect(screen.getByText('KES 194.25')).toBeInTheDocument();
    expect(screen.getByText('2 dumbbell')).toBeInTheDocument();
    // The review form is gone.
    expect(screen.queryByText('Order summary')).toBeNull();

    await userEvent.click(screen.getByRole('button', { name: 'View Order' }));
    expect(navigateMock).toHaveBeenCalledWith('/marketplace/orders/order-1');
  });

  it('shows the station the buyer chose and hands off the card as unconfirmed', async () => {
    renderCheckout();
    await reviewForm();
    await userEvent.click(screen.getByRole('button', { name: /^Pickup/ }));
    await userEvent.click(await screen.findByRole('radio', { name: /Westlands Hub/ }));
    await userEvent.click(paymentTile(/^Card/));
    await userEvent.click(payButton());

    expect(await screen.findByText('Order placed')).toBeInTheDocument();
    expect(screen.getByText('Westlands Hub')).toBeInTheDocument();
    expect(screen.getByText('Collecting from')).toBeInTheDocument();
    expect(screen.getByText('Card')).toBeInTheDocument();
    expect(screen.getByText('Awaiting provider confirmation')).toBeInTheDocument();
    expect(screen.getByText(/Your card provider still needs to confirm this payment/)).toBeInTheDocument();
  });

  it('keeps the receipt when the payment-intent endpoint is missing', async () => {
    stations.createPaymentIntent.mockRejectedValue(httpError(404, { message: 'Not found.' }));
    renderCheckout();
    await reviewForm();
    await userEvent.click(paymentTile(/M-Pesa/));
    await userEvent.type(screen.getByLabelText('M-Pesa phone'), '0712345678');
    await userEvent.click(payButton());

    expect(await screen.findByText('Order placed')).toBeInTheDocument();
    expect(await screen.findByText('Not found.')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'View Order' })).toBeInTheDocument();
    expect(stations.createPaymentIntent).toHaveBeenCalledWith({ order_id: 'order-1', method: 'mpesa', phone: '0712345678' });
  });

  it('navigates back to the cart from the header', async () => {
    renderCheckout();
    await reviewForm();

    await userEvent.click(screen.getByRole('button', { name: 'Back to Cart' }));
    expect(navigateMock).toHaveBeenCalledWith('/marketplace/cart');
  });
});
