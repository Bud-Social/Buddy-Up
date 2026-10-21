import { describe, expect, it } from 'vitest';
import { orderDestination } from '../OrderHistory';
import type { Order, OrderItem } from '@/api/marketplace';

function item(overrides: Partial<OrderItem>): OrderItem {
  return {
    item_type: 'product',
    title: 'Item',
    quantity: 1,
    price_artifacts: {},
    paid_artifacts: {},
    creator_name: null,
    created_at: '2026-01-01',
    target: 'x',
    cover_url: null,
    detail_route: '/marketplace/products/x',
    ...overrides,
  };
}

function order(items: OrderItem[]): Order {
  return {
    id: 'o1',
    order_number: 'BU-1',
    status: 'paid',
    status_label: 'Paid',
    fulfillment_type: 'digital',
    delivery_address: {},
    pickup_details: {},
    items_total_artifacts: {},
    discount_artifacts: {},
    total_artifacts: {},
    total_usd: 0,
    spent_usd: 0,
    discount_code: null,
    status_history: [],
    items,
    fulfillment: null,
    paid_at: null,
    created_at: '2026-01-01',
  };
}

describe('orderDestination', () => {
  it('opens a programme straight from the receipt', () => {
    expect(orderDestination(order([
      item({ item_type: 'programme', detail_route: '/marketplace/programmes/p1' }),
    ]))).toBe('/marketplace/programmes/p1');
  });

  it('opens a meal plan straight from the receipt', () => {
    expect(orderDestination(order([
      item({ item_type: 'meal_plan', detail_route: '/marketplace/meal-plans/m1' }),
    ]))).toBe('/marketplace/meal-plans/m1');
  });

  it('sends physical products to the order tracker', () => {
    expect(orderDestination(order([item({})]))).toBe('/marketplace/orders/o1');
  });

  it('falls back to the tracker for mixed or deleted purchases', () => {
    expect(orderDestination(order([
      item({ item_type: 'programme', detail_route: '/marketplace/programmes/p1' }),
      item({}),
    ]))).toBe('/marketplace/orders/o1');
    expect(orderDestination(order([
      item({ item_type: 'meal_plan', detail_route: null }),
    ]))).toBe('/marketplace/orders/o1');
  });
});
