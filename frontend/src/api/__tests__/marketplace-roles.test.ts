import { describe, expect, it, vi, beforeEach } from 'vitest';
import { apiClient } from '@/api/client';
import {
  marketplaceApi,
  courierActionsFor,
  COURIER_STATUS_ACTIONS,
  eventActionErrorMessage,
  type CourierOrder,
  type CourierTargetStatus,
} from '@/api/marketplace';

vi.mock('@/api/client', () => ({
  apiClient: { get: vi.fn(), post: vi.fn(), patch: vi.fn(), put: vi.fn(), delete: vi.fn() },
}));

const getMock = apiClient.get as unknown as ReturnType<typeof vi.fn>;
const postMock = apiClient.post as unknown as ReturnType<typeof vi.fn>;
const patchMock = apiClient.patch as unknown as ReturnType<typeof vi.fn>;

const ok = <T,>(data: T) => ({ data: { success: true, data, message: '', errors: null, pagination: null } });

const httpError = (status: number, body?: Record<string, unknown>) =>
  Object.assign(new Error(`Request failed with status code ${status}`), {
    response: { status, data: body ?? { success: false, message: 'Something went wrong.' } },
  });

beforeEach(() => vi.clearAllMocks());

describe('courier status map', () => {
  it('encodes exactly the four moves the endpoint accepts', () => {
    const pairs = Object.entries(COURIER_STATUS_ACTIONS).flatMap(([from, actions]) =>
      actions.map((a) => `${from}->${a.to}`),
    );
    expect(pairs).toEqual([
      'processing->out_for_delivery',
      'shipped->out_for_delivery',
      'out_for_delivery->delivered',
      'out_for_delivery->processing',
    ]);
    // Four legal moves and nothing else — no duplicate pairs.
    expect(new Set(pairs).size).toBe(4);
  });

  it.each([
    ['processing', ['out_for_delivery']],
    ['shipped', ['out_for_delivery']],
    ['out_for_delivery', ['delivered', 'processing']],
  ])('%s offers %s', (status, expected) => {
    expect(courierActionsFor(status).map((a) => a.to)).toEqual(expected);
  });

  it.each([['pending'], ['paid'], ['delivered'], ['completed'], ['cancelled'], ['ready_for_pickup'], [''], [null], [undefined], ['shipped ']])(
    'offers nothing from %s',
    (status) => {
      expect(courierActionsFor(status as string | null | undefined)).toEqual([]);
    },
  );

  it('returns a copy so a caller cannot mutate the map', () => {
    const first = courierActionsFor('out_for_delivery');
    first.push({ to: 'cancelled', label: 'Cancel' });
    expect(courierActionsFor('out_for_delivery')).toHaveLength(2);
  });
});

describe('marketplaceApi — courier', () => {
  it('reads the summary from the delivery endpoint', async () => {
    getMock.mockResolvedValue(ok({ vehicle_type: 'van' }));
    await marketplaceApi.getCourierSummary();
    expect(getMock).toHaveBeenCalledWith('/marketplace/delivery/summary/');
  });

  it('propagates the 404 that means "no DeliveryPersonnel row"', async () => {
    getMock.mockRejectedValue(httpError(404));
    await expect(marketplaceApi.getCourierSummary()).rejects.toThrow();
  });

  it('omits the status filter when none is given and sends it when there is', async () => {
    getMock.mockResolvedValue(ok([] as CourierOrder[]));
    await marketplaceApi.getCourierOrders();
    expect(getMock).toHaveBeenCalledWith('/marketplace/delivery/my-orders/', { params: {} });
    await marketplaceApi.getCourierOrders('out_for_delivery', 2);
    expect(getMock).toHaveBeenLastCalledWith('/marketplace/delivery/my-orders/', { params: { status: 'out_for_delivery', page: 2 } });
  });

  it('PATCHes only the status — never carrier or tracking', async () => {
    patchMock.mockResolvedValue(ok({ id: 'o-1' }));
    await marketplaceApi.updateCourierOrderStatus('o-1', 'delivered');
    expect(patchMock).toHaveBeenCalledWith('/marketplace/delivery/my-orders/o-1/', { status: 'delivered' });
  });

  it('reads earnings over an explicit window', async () => {
    getMock.mockResolvedValue(ok({ delivered_count: 3 }));
    await marketplaceApi.getCourierEarnings({ from: '2026-05-01', to: '2026-05-31' });
    expect(getMock).toHaveBeenCalledWith('/marketplace/delivery/earnings/', {
      params: { from: '2026-05-01', to: '2026-05-31' },
    });
  });

  it('sends no params at all when no window is given', async () => {
    getMock.mockResolvedValue(ok({}));
    await marketplaceApi.getCourierEarnings();
    expect(getMock).toHaveBeenCalledWith('/marketplace/delivery/earnings/', { params: undefined });
  });

  it('registers and toggles through the same self-registration endpoint', async () => {
    postMock.mockResolvedValue(ok({}));
    await marketplaceApi.registerDeliveryPersonnel({ vehicle_type: 'van', service_zones: ['Kilimani'] });
    expect(postMock).toHaveBeenCalledWith('/marketplace/delivery-personnel/', { vehicle_type: 'van', service_zones: ['Kilimani'] });

    await marketplaceApi.toggleCourierActive(false);
    expect(postMock).toHaveBeenLastCalledWith('/marketplace/delivery-personnel/', { is_active: false });
  });
});

describe('marketplaceApi — event organiser', () => {
  it('lists the caller\'s own events', async () => {
    getMock.mockResolvedValue(ok([{ id: 'e1' }]));
    await marketplaceApi.getOrganisedEvents();
    expect(getMock).toHaveBeenCalledWith('/marketplace/events/mine/');
  });

  it('omits every blank attendee filter from the query string', async () => {
    getMock.mockResolvedValue(ok([]));
    await marketplaceApi.getEventAttendees('e1');
    expect(getMock).toHaveBeenCalledWith('/marketplace/events/e1/attendees/', { params: {} });
  });

  it('keeps checked_in=false, which is a real filter and not a blank', async () => {
    getMock.mockResolvedValue(ok([]));
    await marketplaceApi.getEventAttendees('e1', { checked_in: false });
    expect(getMock).toHaveBeenCalledWith('/marketplace/events/e1/attendees/', { params: { checked_in: false } });
  });

  it('sends all three attendee filters together', async () => {
    getMock.mockResolvedValue(ok([]));
    await marketplaceApi.getEventAttendees('e1', { checked_in: true, status: 'valid', tier: 'vip', page: 2, page_size: 25 });
    expect(getMock).toHaveBeenCalledWith('/marketplace/events/e1/attendees/', {
      params: { checked_in: true, status: 'valid', tier: 'vip', page: 2, page_size: 25 },
    });
  });

  it('checks a ticket in with the bare code', async () => {
    postMock.mockResolvedValue(ok({}));
    await marketplaceApi.checkInAttendee('e1', 'BUD-EV-AAAA');
    expect(postMock).toHaveBeenCalledWith('/marketplace/events/e1/check-in/', { ticket_code: 'BUD-EV-AAAA' });
  });

  it('checks a ticket back out', async () => {
    postMock.mockResolvedValue(ok({}));
    await marketplaceApi.checkOutAttendee('e1', 'BUD-EV-AAAA');
    expect(postMock).toHaveBeenCalledWith('/marketplace/events/e1/check-out/', { ticket_code: 'BUD-EV-AAAA' });
  });

  it('reads event stats', async () => {
    getMock.mockResolvedValue(ok({ tickets_sold: 45 }));
    await marketplaceApi.getEventStats('e1');
    expect(getMock).toHaveBeenCalledWith('/marketplace/events/e1/stats/');
  });

  it('surfaces the 409 conflict body verbatim', () => {
    const message = eventActionErrorMessage(
      httpError(409, { message: 'Already checked in by Njeri at 06:12.' }),
      'fallback',
    );
    expect(message).toBe('Already checked in by Njeri at 06:12.');
  });

  it('flattens a field-level error body when there is no message', () => {
    expect(
      eventActionErrorMessage(httpError(400, { errors: { ticket_code: ['Unknown ticket.'] } }), 'fallback'),
    ).toBe('ticket_code: Unknown ticket.');
  });

  it('falls back to its own wording when the server says nothing', () => {
    expect(eventActionErrorMessage(httpError(500, {}), 'Check-in failed.')).toBe('Check-in failed.');
  });
});

describe('marketplaceApi — stations', () => {
  it('creates a station', async () => {
    postMock.mockResolvedValue(ok({ id: 's-1' }));
    await marketplaceApi.createStation({ name: 'Westlands Hub', owner_type: 'shop' });
    expect(postMock).toHaveBeenCalledWith('/marketplace/stations/', { name: 'Westlands Hub', owner_type: 'shop' });
  });

  it('updates a station by id', async () => {
    patchMock.mockResolvedValue(ok({ id: 's-1' }));
    await marketplaceApi.updateStation('s-1', { name: 'Renamed', is_primary: true });
    expect(patchMock).toHaveBeenCalledWith('/marketplace/stations/s-1/', { name: 'Renamed', is_primary: true });
  });

  it('applies to become a station', async () => {
    postMock.mockResolvedValue(ok({ id: 'app-1', status: 'pending' }));
    await marketplaceApi.applyForStation({ notes: 'Want a hub in Kilimani' });
    expect(postMock).toHaveBeenCalledWith('/marketplace/station-applications/', { notes: 'Want a hub in Kilimani' });
  });
});

describe('CourierTargetStatus', () => {
  it('is a compile-time union of the legal destinations only', () => {
    // Runtime mirror of the type: if this drifts from COURIER_STATUS_ACTIONS,
    // the cast below stops type-checking.
    const legal: CourierTargetStatus[] = ['out_for_delivery', 'delivered', 'processing'];
    const fromMap = [...new Set(Object.values(COURIER_STATUS_ACTIONS).flat().map((a) => a.to))].sort();
    expect(legal.sort()).toEqual(fromMap.sort());
  });
});