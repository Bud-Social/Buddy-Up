import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import CartPage from '@/pages/app/CartPage';
import { marketplaceApi } from '@/api/marketplace';
import { walletApi } from '@/api/wallet';

const navigateMock = vi.fn();

vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual<typeof import('react-router-dom')>('react-router-dom');
  return { ...actual, useNavigate: () => navigateMock };
});

vi.mock('@/api/marketplace', () => ({
  marketplaceApi: {
    getCart: vi.fn(),
    removeFromCart: vi.fn(),
    addToCart: vi.fn(),
    checkoutCart: vi.fn(),
    applyDiscount: vi.fn(),
  },
}));

vi.mock('@/api/wallet', () => ({
  walletApi: { getBalance: vi.fn() },
}));

const market = marketplaceApi as unknown as Record<string, ReturnType<typeof vi.fn>>;
const wallet = walletApi as unknown as Record<string, ReturnType<typeof vi.fn>>;

function cartWithItems() {
  return {
    data: {
      base_currency: 'USD',
      local_currency: 'KES',
      conversion_rate: 129.5,
      total_artifacts: { dumbbell: 2 },
      total_usd: 2,
      total_local_currency: 259,
      items: [
        {
          id: 'item-1',
          item_type: 'meal_plan',
          quantity: 2,
          meal_plan_id: 'plan-1',
          meal_plan_detail: { title: 'Keto reset', price_artifacts: { dumbbell: 1 } },
          item_total_artifacts: { dumbbell: 2 },
          item_total_usd: 1,
        },
      ],
    },
  };
}

beforeEach(() => {
  vi.clearAllMocks();
  market.getCart.mockResolvedValue(cartWithItems());
  market.checkoutCart.mockResolvedValue({ data: {} });
  wallet.getBalance.mockResolvedValue({ data: { regular_balance: [{ artifact_type: 'dumbbell', quantity: 5 }] } });
});

function renderCart() {
  return render(<MemoryRouter><CartPage /></MemoryRouter>);
}

describe('CartPage shortfall', () => {
  it('stays quiet about the balance when it covers the cart', async () => {
    renderCart();

    expect(await screen.findByText('Keto reset')).toBeInTheDocument();
    expect(screen.queryByRole('alert')).toBeNull();
    expect((screen.getByRole('button', { name: /Review & Checkout/ }) as HTMLButtonElement).disabled).toBe(false);
  });

  it('names the gap before checkout when the balance is short', async () => {
    wallet.getBalance.mockResolvedValue({ data: { regular_balance: [{ artifact_type: 'dumbbell', quantity: 1 }] } });
    renderCart();

    // The shortfall is surfaced on the cart itself, not hidden behind a modal.
    expect(await screen.findByRole('alert')).toHaveTextContent('Not enough dumbbell');
  });
});

describe('CartPage hands checkout over to the standalone page', () => {
  it('navigates to /marketplace/checkout instead of opening its own modal', async () => {
    renderCart();

    await userEvent.click(await screen.findByRole('button', { name: /Review & Checkout/ }));

    expect(navigateMock).toHaveBeenCalledWith('/marketplace/checkout');
    // The confirm and receipt modals are gone; the cart is a pure cart.
    expect(screen.queryByRole('button', { name: 'Confirm Payment' })).toBeNull();
    expect(screen.queryByText('Order Receipt')).toBeNull();
    expect(screen.queryByText('Confirm Order')).toBeNull();
  });

  it('never places the order itself, even with a shortfall', async () => {
    wallet.getBalance.mockResolvedValue({ data: { regular_balance: [{ artifact_type: 'dumbbell', quantity: 1 }] } });
    renderCart();

    const review = await screen.findByRole('button', { name: /Review & Checkout/ });
    expect((review as HTMLButtonElement).disabled).toBe(false);
    await userEvent.click(review);

    expect(navigateMock).toHaveBeenCalledWith('/marketplace/checkout');
    expect(market.checkoutCart).not.toHaveBeenCalled();
  });
});
