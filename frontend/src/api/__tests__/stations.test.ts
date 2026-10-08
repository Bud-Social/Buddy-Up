import { describe, expect, it, vi, beforeEach } from 'vitest';
import { apiClient } from '@/api/client';
import {
  hasStationDistance,
  isStationsUnavailable,
  sortStationsByDistance,
  stationAreaLabel,
  stationList,
  stationOpeningHoursLabel,
  stationsApi,
  stationsErrorMessage,
  type PickupStation,
} from '@/api/stations';

vi.mock('@/api/client', () => ({
  apiClient: { get: vi.fn(), post: vi.fn() },
}));

const getMock = apiClient.get as unknown as ReturnType<typeof vi.fn>;
const postMock = apiClient.post as unknown as ReturnType<typeof vi.fn>;

const ok = <T,>(data: T) => ({
  data: { success: true, data, message: '', errors: null, pagination: null },
});

const station = (over: Partial<PickupStation> & { id: string }): PickupStation => ({
  name: 'Pickup point',
  address: '',
  city: '',
  country: '',
  opening_hours: null,
  is_primary: false,
  owner_type: 'shop',
  ...over,
});

/** An axios-shaped rejection, which is how a real failure reaches a caller. */
const httpError = (status: number, body?: Record<string, unknown>) => {
  const e = new Error(`Request failed with status code ${status}`) as Error & { response: unknown };
  e.response = { status, data: body ?? { success: false, message: 'Something went wrong.' } };
  return e;
};

beforeEach(() => {
  vi.clearAllMocks();
  getMock.mockResolvedValue(ok([]));
  postMock.mockResolvedValue(ok({ id: 'pi-1' }));
});

describe('stationsApi.list — request shape', () => {
  it('asks for the station list with every documented geo filter', async () => {
    await stationsApi.list({ lat: -1.2833, lng: 36.8172, radius_km: 25, owner_type: 'shop' });
    expect(getMock).toHaveBeenCalledWith('/marketplace/stations/', {
      params: { lat: -1.2833, lng: 36.8172, radius_km: 25, owner_type: 'shop' },
    });
  });

  it('omits absent params so a location-less lookup stays clean', async () => {
    await stationsApi.list({ lat: undefined, lng: undefined, radius_km: undefined });
    expect(getMock).toHaveBeenCalledWith('/marketplace/stations/', { params: undefined });
    expect(getMock).toHaveBeenCalledWith('/marketplace/stations/', { params: undefined });

    getMock.mockClear();
    await stationsApi.list();
    expect(getMock).toHaveBeenCalledWith('/marketplace/stations/', { params: undefined });
  });

  it('fetches a single station by uuid', async () => {
    await stationsApi.get('st-1');
    expect(getMock).toHaveBeenCalledWith('/marketplace/stations/st-1/');
  });

  it('returns the envelope rather than the unwrapped array', async () => {
    getMock.mockResolvedValueOnce(ok([station({ id: 'st-1' })]));
    const res = await stationsApi.list();
    expect(res.success).toBe(true);
    expect(res.data).toHaveLength(1);
  });
});

describe('stationsApi.list — distance ordering', () => {
  it('sorts nearest first when the server supplied distances', async () => {
    getMock.mockResolvedValueOnce(
      ok([
        station({ id: 'far', name: 'Lakeside', distance_km: 12.4 }),
        station({ id: 'near', name: 'Westlands', distance_km: 0.8 }),
        station({ id: 'mid', name: 'Parklands', distance_km: 3.2 }),
      ]),
    );
    const res = await stationsApi.list({ lat: -1.28, lng: 36.81 });
    expect(res.data.map((s) => s.id)).toEqual(['near', 'mid', 'far']);
  });

  it('degrades to the server order when no station carries a distance', async () => {
    getMock.mockResolvedValueOnce(
      ok([
        station({ id: 'first', name: 'Alpha' }),
        station({ id: 'second', name: 'Bravo' }),
        station({ id: 'third', name: 'Charlie' }),
      ]),
    );
    const res = await stationsApi.list();
    expect(res.data.map((s) => s.id)).toEqual(['first', 'second', 'third']);
    expect(res.data.every((s) => !hasStationDistance(s))).toBe(true);
  });

  it('pushes unmeasured stations behind measured ones without reordering the rest', async () => {
    const unsorted: PickupStation[] = [
      station({ id: 'unknown-a' }),
      station({ id: 'far', distance_km: 9 }),
      station({ id: 'unknown-b' }),
      station({ id: 'near', distance_km: 1 }),
    ];
    expect(sortStationsByDistance(unsorted).map((s) => s.id)).toEqual([
      'near',
      'far',
      'unknown-a',
      'unknown-b',
    ]);
  });

  it('never mutates the caller array and copes with an empty list', () => {
    const list = [station({ id: 'b', distance_km: 5 }), station({ id: 'a', distance_km: 1 })];
    const sorted = sortStationsByDistance(list);
    expect(sorted).not.toBe(list);
    expect(list.map((s) => s.id)).toEqual(['b', 'a']);
    expect(sortStationsByDistance([])).toEqual([]);
  });

  it('ignores a non-numeric distance instead of sorting on it', () => {
    const list = [
      station({ id: 'nulled', distance_km: null }),
      station({ id: 'real', distance_km: 2 }),
      station({ id: 'nan', distance_km: Number.NaN }),
    ];
    expect(sortStationsByDistance(list).map((s) => s.id)).toEqual(['real', 'nulled', 'nan']);
    expect(hasStationDistance({ distance_km: null })).toBe(false);
    expect(hasStationDistance({ distance_km: Number.NaN })).toBe(false);
    expect(hasStationDistance({ distance_km: 0 })).toBe(true);
  });

  it('normalises a paginated or empty list body', () => {
    expect(stationList([{ id: 'a' }])).toHaveLength(1);
    expect(stationList({ results: [{ id: 'a' }, { id: 'b' }] })).toHaveLength(2);
    expect(stationList({ items: [{ id: 'a' }] })).toHaveLength(1);
    expect(stationList(null)).toEqual([]);
    expect(stationList(undefined)).toEqual([]);
    expect(stationList('nope')).toEqual([]);
    expect(stationList({ count: 3 })).toEqual([]);
  });
});

describe('stationsApi.createPaymentIntent', () => {
  it('posts to the order payment-intent route', async () => {
    await stationsApi.createPaymentIntent({ order_id: 'o-1', method: 'mpesa', phone: '+254712345678' });
    expect(postMock).toHaveBeenCalledWith('/marketplace/orders/payment-intents/', {
      order_id: 'o-1',
      method: 'mpesa',
      phone: '+254712345678',
    });
  });

  it('omits the phone key entirely when no number is supplied', async () => {
    await stationsApi.createPaymentIntent({ order_id: 'o-2', method: 'card' });
    expect(postMock).toHaveBeenCalledWith('/marketplace/orders/payment-intents/', {
      order_id: 'o-2',
      method: 'card',
    });
  });

  it('returns the raw envelope with the created intent', async () => {
    postMock.mockResolvedValueOnce(
      ok({ id: 'pi-1', order_id: 'o-1', method: 'mpesa', amount: 500, currency: 'KES', status: 'initiated' }),
    );
    const res = await stationsApi.createPaymentIntent({ order_id: 'o-1', method: 'mpesa' });
    expect(res.data).toMatchObject({ id: 'pi-1', status: 'initiated', currency: 'KES' });
  });
});

describe('station labels', () => {
  it('collapses an address, city and country into one line', () => {
    expect(stationAreaLabel(station({ id: 's', address: 'Mombasa Road', city: 'Nairobi', country: 'Kenya' })))
      .toBe('Mombasa Road, Nairobi, Kenya');
  });

  it('falls back rather than rendering a blank area', () => {
    expect(stationAreaLabel(station({ id: 's' }))).toBe('Address not listed');
    expect(stationAreaLabel(station({ id: 's', address: '   ' }))).toBe('Address not listed');
  });

  it('summarises identical hours across the whole week once', () => {
    const hours = Object.fromEntries(
      ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'].map((day) => [
        day,
        { open: '08:00', close: '20:00' },
      ]),
    );
    expect(stationOpeningHoursLabel(hours)).toBe('Daily 08:00\u201320:00');
  });

  it('labels each open day when hours differ, and skips closed days', () => {
    expect(
      stationOpeningHoursLabel({
        monday: { open: '08:00', close: '18:00' },
        tuesday: { open: '08:00', close: '18:00' },
        wednesday: { open: '08:00', close: '21:00' },
        sunday: { closed: true },
      }),
    ).toBe('Mon 08:00\u201318:00 · Tue 08:00\u201318:00 · Wed 08:00\u201321:00');
  });

  it('does not call a weekday-only station "Daily"', () => {
    expect(
      stationOpeningHoursLabel({
        monday: { open: '09:00', close: '17:00' },
        tuesday: { open: '09:00', close: '17:00' },
      }),
    ).toBe('Mon 09:00\u201317:00 · Tue 09:00\u201317:00');
  });

  it('accepts a plain string per day and non-canonical day keys', () => {
    expect(stationOpeningHoursLabel({ mon: '09:00 - 17:00' })).toBe('09:00 - 17:00');
    expect(stationOpeningHoursLabel({ public_holidays: 'By appointment' })).toBe('By appointment');
  });

  it('handles an open-only window and falls back for unusable hours', () => {
    expect(stationOpeningHoursLabel({ monday: { open: '24h' } })).toBe('Mon 24h');
    expect(stationOpeningHoursLabel(null)).toBe('Hours not listed');
    expect(stationOpeningHoursLabel({})).toBe('Hours not listed');
    expect(stationOpeningHoursLabel({ monday: { closed: true } })).toBe('Hours not listed');
    expect(stationOpeningHoursLabel({ monday: {} })).toBe('Hours not listed');
  });
});

describe('stations failure handling', () => {
  it('flags an unbuilt endpoint so callers can fall back', () => {
    expect(isStationsUnavailable(httpError(404))).toBe(true);
    expect(isStationsUnavailable(httpError(405))).toBe(true);
    expect(isStationsUnavailable(httpError(501))).toBe(true);
  });

  it('does not treat a server or network failure as a missing endpoint', () => {
    expect(isStationsUnavailable(httpError(500))).toBe(false);
    expect(isStationsUnavailable(httpError(403))).toBe(false);
    expect(isStationsUnavailable(new Error('Network Error'))).toBe(false);
    expect(isStationsUnavailable(undefined)).toBe(false);
  });

  it('surfaces the server message, then field errors, then a fallback', () => {
    expect(stationsErrorMessage(httpError(404, { message: 'No route.' }))).toBe('No route.');
    expect(stationsErrorMessage(httpError(400, { errors: { name: ['This field is required.'] } })))
      .toContain('name: This field is required.');
    expect(stationsErrorMessage(new Error('boom'), 'Fallback.')).toBe('Fallback.');
    expect(stationsErrorMessage(null, 'Fallback.')).toBe('Fallback.');
  });
});
