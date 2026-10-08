import { describe, expect, it, vi, beforeEach } from 'vitest';
import { apiClient } from '@/api/client';
import {
  adminPortalApi,
  adminPortalErrorMessage,
  isAdminPrivilegeError,
  portalListItems,
  portalPagination,
  type ApiResponse,
} from '@/api/adminPortal';

vi.mock('@/api/client', () => ({
  apiClient: { get: vi.fn(), post: vi.fn(), patch: vi.fn(), put: vi.fn(), delete: vi.fn() },
}));

const getMock = apiClient.get as unknown as ReturnType<typeof vi.fn>;
const postMock = apiClient.post as unknown as ReturnType<typeof vi.fn>;
const patchMock = apiClient.patch as unknown as ReturnType<typeof vi.fn>;

const ok = <T,>(data: T, pagination?: unknown) => ({
  data: { success: true, data, message: '', errors: null, pagination: pagination ?? null },
});

/** An axios-shaped rejection, which is how a real failure reaches a caller. */
const httpError = (status: number, body: Record<string, unknown>) => {
  const e = new Error(`Request failed with status code ${status}`) as Error & { response: unknown };
  e.response = { status, data: body };
  return e;
};

beforeEach(() => {
  vi.clearAllMocks();
  getMock.mockResolvedValue(ok([]));
  postMock.mockResolvedValue(ok(null));
  patchMock.mockResolvedValue(ok(null));
});

describe('adminPortalApi — users', () => {
  it('lists users from /portal/users/ with every documented filter', async () => {
    await adminPortalApi.getUsers({
      q: 'ada',
      role: 'trainer',
      is_active: true,
      verification_status: 'trainer',
      has_search_profile: false,
      page: 2,
      page_size: 25,
    });
    expect(getMock).toHaveBeenCalledWith('/portal/users/', {
      params: {
        q: 'ada',
        role: 'trainer',
        is_active: true,
        verification_status: 'trainer',
        has_search_profile: false,
        page: 2,
        page_size: 25,
      },
    });
  });

  it('omits empty filter values so the query string stays clean', async () => {
    await adminPortalApi.getUsers({ q: '', role: 'all', is_active: undefined, page: 1 });
    expect(getMock).toHaveBeenCalledWith('/portal/users/', { params: { page: 1 } });
  });

  it('sends no params key at all when every filter is empty', async () => {
    await adminPortalApi.getUsers({ q: '', role: 'all' });
    expect(getMock).toHaveBeenCalledWith('/portal/users/', { params: undefined });
  });

  it('patches a single user by uuid', async () => {
    await adminPortalApi.updateUser('u-1', { is_active: false });
    expect(patchMock).toHaveBeenCalledWith('/portal/users/u-1/', { is_active: false });
  });

  it('posts suspend and reinstate as act endpoints with a JSON body', async () => {
    await adminPortalApi.suspendUser('u-2', { reason: 'chargeback fraud' });
    expect(postMock).toHaveBeenCalledWith('/portal/users/u-2/suspend/', { reason: 'chargeback fraud' });

    await adminPortalApi.reinstateUser('u-2');
    expect(postMock).toHaveBeenCalledWith('/portal/users/u-2/reinstate/', {});
  });
});

describe('adminPortalApi — shops, products, certifications', () => {
  it('addresses shops by handle and URL-encodes it', async () => {
    await adminPortalApi.getShop('ada_lovelace');
    expect(getMock).toHaveBeenCalledWith('/portal/shops/ada_lovelace/');

    await adminPortalApi.updateShop('ada/lovelace', { is_active: false });
    expect(patchMock).toHaveBeenCalledWith('/portal/shops/ada%2Flovelace/', { is_active: false });
  });

  it('filters products on verification_status, category and is_active', async () => {
    await adminPortalApi.getProducts({ verification_status: 'verified', category: 'supplements', is_active: true });
    expect(getMock).toHaveBeenCalledWith('/portal/products/', {
      params: { verification_status: 'verified', category: 'supplements', is_active: true },
    });
  });

  it('patches a shop certification review with status and reason', async () => {
    await adminPortalApi.reviewShopCertification('cert-1', { status: 'rejected', reason: 'unreadable registration' });
    expect(patchMock).toHaveBeenCalledWith('/portal/shop-certifications/cert-1/', {
      status: 'rejected',
      reason: 'unreadable registration',
    });
  });
});

describe('adminPortalApi — orders', () => {
  it('lists orders with the full filter set', async () => {
    await adminPortalApi.getOrders({
      status: 'pending',
      fulfillment_type: 'physical',
      payment_status: 'paid',
      payment_method: 'mpesa',
      q: 'ORD-1',
    });
    expect(getMock).toHaveBeenCalledWith('/portal/orders/', {
      params: {
        status: 'pending',
        fulfillment_type: 'physical',
        payment_status: 'paid',
        payment_method: 'mpesa',
        q: 'ORD-1',
      },
    });
  });

  it('PATCHes the status sub-route, not the order resource', async () => {
    await adminPortalApi.updateOrderStatus('o-1', { status: 'shipped', note: 'handed to courier' });
    expect(patchMock).toHaveBeenCalledWith('/portal/orders/o-1/status/', { status: 'shipped', note: 'handed to courier' });
  });
});

describe('adminPortalApi — gyms and communities', () => {
  it('filters gyms and never requests a member roster', async () => {
    await adminPortalApi.getGyms({ access_type: 'subscription', category: 'studio', is_verified: true });
    expect(getMock).toHaveBeenCalledWith('/portal/gyms/', {
      params: { access_type: 'subscription', category: 'studio', is_verified: true },
    });
    expect(JSON.stringify(getMock.mock.calls)).not.toContain('member');
  });

  it('patches a gym by uuid', async () => {
    await adminPortalApi.updateGym('g-1', { is_verified: true });
    expect(patchMock).toHaveBeenCalledWith('/portal/gyms/g-1/', { is_verified: true });
  });

  it('lists communities with visibility and search filters', async () => {
    await adminPortalApi.getCommunities({ is_public: false, q: 'runners' });
    expect(getMock).toHaveBeenCalledWith('/portal/communities/', { params: { is_public: false, q: 'runners' } });
  });
});

describe('adminPortalApi — stations and delivery', () => {
  it('covers stations, station applications, personnel and personnel applications', async () => {
    await adminPortalApi.getStations({ q: 'karen' });
    expect(getMock).toHaveBeenCalledWith('/portal/stations/', { params: { q: 'karen' } });

    await adminPortalApi.updateStation('s-1', { is_active: false });
    expect(patchMock).toHaveBeenCalledWith('/portal/stations/s-1/', { is_active: false });

    await adminPortalApi.getStationApplications({ status: 'pending' });
    expect(getMock).toHaveBeenCalledWith('/portal/station-applications/', { params: { status: 'pending' } });

    await adminPortalApi.updateStationApplication('sa-1', { status: 'approved', reason: 'site visit booked' });
    expect(patchMock).toHaveBeenCalledWith('/portal/station-applications/sa-1/', {
      status: 'approved',
      reason: 'site visit booked',
    });

    await adminPortalApi.getDeliveryPersonnel({ station: 's-1' });
    expect(getMock).toHaveBeenCalledWith('/portal/delivery-personnel/', { params: { station: 's-1' } });

    await adminPortalApi.getDeliveryApplications({ status: 'submitted' });
    expect(getMock).toHaveBeenCalledWith('/portal/delivery-personnel-applications/', { params: { status: 'submitted' } });

    await adminPortalApi.updateDeliveryApplication('da-1', { status: 'rejected', reason: 'no valid licence' });
    expect(patchMock).toHaveBeenCalledWith('/portal/delivery-personnel-applications/da-1/', {
      status: 'rejected',
      reason: 'no valid licence',
    });
  });
});

describe('adminPortalApi — wallet', () => {
  it('reads transactions and the reconciliation report', async () => {
    await adminPortalApi.getTransactions({ direction: 'credit', status: 'completed' });
    expect(getMock).toHaveBeenCalledWith('/portal/transactions/', {
      params: { direction: 'credit', status: 'completed' },
    });

    await adminPortalApi.getReconciliation({ date_from: '2026-01-01', date_to: '2026-01-31' });
    expect(getMock).toHaveBeenCalledWith('/portal/wallet/reconciliation/', {
      params: { date_from: '2026-01-01', date_to: '2026-01-31' },
    });
  });
});

describe('adminPortalApi — envelope contract', () => {
  it('resolves to the raw envelope, not the unwrapped data', async () => {
    getMock.mockResolvedValueOnce(ok([{ id: 'u-1' }], { count: 1, next: null, previous: null }));
    const res: ApiResponse<Array<{ id: string }>> = await adminPortalApi.getUsers();
    expect(res.success).toBe(true);
    expect(res.data).toEqual([{ id: 'u-1' }]);
    expect(res.pagination).toEqual({ count: 1, next: null, previous: null });
  });

  it('normalises list payloads defensively', () => {
    expect(portalListItems([{ id: 1 }])).toHaveLength(1);
    expect(portalListItems({ results: [{ id: 1 }, { id: 2 }] })).toHaveLength(2);
    expect(portalListItems({ items: [{ id: 1 }] })).toHaveLength(1);
    expect(portalListItems(null)).toEqual([]);
    expect(portalListItems(undefined)).toEqual([]);
    expect(portalListItems('nope')).toEqual([]);
    expect(portalListItems({ count: 5 })).toEqual([]);
  });

  it('defaults every pagination member', () => {
    expect(portalPagination(null, 30)).toEqual({ count: 30, next: null, previous: null, page: 1, num_pages: 2 });
    expect(portalPagination(undefined)).toMatchObject({ count: 0, next: null, previous: null, num_pages: 1 });
    expect(portalPagination({ count: 51, next: 'x', previous: 'y' })).toMatchObject({ count: 51, next: 'x', previous: 'y' });
  });
});

describe('adminPortalApi — error surfacing', () => {
  it('prefers the server message from a failed envelope', () => {
    const message = adminPortalErrorMessage(httpError(400, { success: false, message: 'Illegal transition: delivered → shipped' }));
    expect(message).toBe('Illegal transition: delivered → shipped');
  });

  it('flattens a field-level errors object when there is no message', () => {
    const message = adminPortalErrorMessage(httpError(400, { errors: { reason: ['This field is required.'] } }));
    expect(message).toContain('reason: This field is required.');
  });

  it('falls back rather than throwing on a malformed error', () => {
    expect(adminPortalErrorMessage(new Error('boom'), 'Fallback.')).toBe('Fallback.');
    expect(adminPortalErrorMessage(null, 'Fallback.')).toBe('Fallback.');
    expect(adminPortalErrorMessage({})).toBe('Something went wrong.');
  });

  it('adds the staff-access sentence on a 403 privilege escalation', () => {
    const err = httpError(403, { success: false, message: 'You do not have permission to perform this action.' });
    expect(isAdminPrivilegeError(err)).toBe(true);
    const message = adminPortalErrorMessage(err);
    expect(message).toContain('You do not have permission to perform this action.');
    expect(message).toContain('Staff access is required for the admin console');
  });

  it('flags an expired session on a 401', () => {
    const message = adminPortalErrorMessage(httpError(401, { success: false, message: 'Token expired.' }));
    expect(message).toContain('Token expired.');
    expect(message).toContain('sign in again');
    expect(isAdminPrivilegeError(httpError(401, {}))).toBe(false);
    expect(isAdminPrivilegeError(new Error('network'))).toBe(false);
  });

  it('leaves non-403/401 messages untouched', () => {
    expect(adminPortalErrorMessage(httpError(500, { message: 'Server exploded' }))).toBe('Server exploded');
  });
});