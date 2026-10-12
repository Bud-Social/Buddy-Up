import { describe, expect, it, vi, beforeEach } from 'vitest';
import { apiClient } from '@/api/client';
import {
  adminPortalApi,
  auditExportUrl,
  moderationActionApplied,
  type ApiResponse,
} from '@/api/adminPortal';

vi.mock('@/api/client', () => ({
  apiClient: {
    get: vi.fn(),
    post: vi.fn(),
    patch: vi.fn(),
    put: vi.fn(),
    delete: vi.fn(),
    defaults: { baseURL: 'http://localhost:8002/api/v1' },
  },
}));

const getMock = apiClient.get as unknown as ReturnType<typeof vi.fn>;
const postMock = apiClient.post as unknown as ReturnType<typeof vi.fn>;
const patchMock = apiClient.patch as unknown as ReturnType<typeof vi.fn>;
const deleteMock = apiClient.delete as unknown as ReturnType<typeof vi.fn>;

const ok = <T,>(data: T, message = '', pagination?: unknown) => ({
  data: { success: true, data, message, errors: null, pagination: pagination ?? null },
});

beforeEach(() => {
  vi.clearAllMocks();
  getMock.mockResolvedValue(ok([]));
  postMock.mockResolvedValue(ok(null));
  patchMock.mockResolvedValue(ok(null));
  deleteMock.mockResolvedValue({ data: undefined });
});

describe('adminPortalApi — staff roles', () => {
  it('lists role assignments with the role and revoked filters', async () => {
    await adminPortalApi.getStaffRoles({ role: 'moderator', revoked: 'false', page: 1, page_size: 25 });
    expect(getMock).toHaveBeenCalledWith('/governance/staff-roles/', {
      params: { role: 'moderator', revoked: 'false', page: 1, page_size: 25 },
    });
  });

  it('grants a role through the collection POST, never a PUT', async () => {
    await adminPortalApi.createStaffRole({ user: 'u-1', role: 'moderator', scopes: ['users.read'], requires_second: true });
    expect(postMock).toHaveBeenCalledWith('/governance/staff-roles/', {
      user: 'u-1',
      role: 'moderator',
      scopes: ['users.read'],
      requires_second: true,
    });
  });

  it('narrows with PATCH and revokes with DELETE on the detail route', async () => {
    await adminPortalApi.updateStaffRole('sr-1', { scopes: ['users.read'] });
    expect(patchMock).toHaveBeenCalledWith('/governance/staff-roles/sr-1/', { scopes: ['users.read'] });

    // No reason supplied → no body at all, rather than an empty payload.
    await adminPortalApi.revokeStaffRole('sr-1');
    expect(deleteMock).toHaveBeenCalledWith('/governance/staff-roles/sr-1/', { data: undefined });

    // A reason the operator typed must reach the server, not be discarded.
    await adminPortalApi.revokeStaffRole('sr-1', 'moving teams');
    expect(deleteMock).toHaveBeenLastCalledWith('/governance/staff-roles/sr-1/', {
      data: { notes: 'moving teams' },
    });
  });
});

describe('adminPortalApi — approvals', () => {
  it('passes status, action, target_user and mine through as query params', async () => {
    await adminPortalApi.getApprovals({ status: 'pending', action: 'ban', target_user: 'u-9', mine: true });
    expect(getMock).toHaveBeenCalledWith('/governance/approvals/', {
      params: { status: 'pending', action: 'ban', target_user: 'u-9', mine: true },
    });
  });

  it('hits one distinct verb endpoint per decision', async () => {
    await adminPortalApi.approveApproval('a-1', { note: 'evidence reviewed' });
    expect(postMock).toHaveBeenNthCalledWith(1, '/governance/approvals/a-1/approve/', { note: 'evidence reviewed' });

    await adminPortalApi.rejectApproval('a-1', { note: 'insufficient evidence' });
    expect(postMock).toHaveBeenNthCalledWith(2, '/governance/approvals/a-1/reject/', { note: 'insufficient evidence' });

    await adminPortalApi.cancelApproval('a-1', { note: 'raised in error' });
    expect(postMock).toHaveBeenNthCalledWith(3, '/governance/approvals/a-1/cancel/', { note: 'raised in error' });
  });

  it('sends an empty body when a decision carries no note', async () => {
    await adminPortalApi.approveApproval('a-2');
    expect(postMock).toHaveBeenCalledWith('/governance/approvals/a-2/approve/', {});
  });

  it('raises a request on the dedicated /request/ path, not the collection', async () => {
    await adminPortalApi.requestApproval({
      action: 'suspension',
      target_user: 'u-3',
      payload: { reason: 'chargeback fraud', duration_days: 30 },
    });
    expect(postMock).toHaveBeenCalledWith('/governance/approvals/request/', {
      action: 'suspension',
      target_user: 'u-3',
      payload: { reason: 'chargeback fraud', duration_days: 30 },
    });
  });

  it('reads one request from the detail path', async () => {
    await adminPortalApi.getApproval('a-1');
    expect(getMock).toHaveBeenCalledWith('/governance/approvals/a-1/');
  });
});

describe('adminPortalApi — audit', () => {
  it('sends every documented filter', async () => {
    await adminPortalApi.getAuditLog({
      action: 'users.suspend',
      target_type: 'user',
      target_id: 'u-7',
      actor: '11111111-2222-3333-4444-555555555555',
      date_from: '2026-01-01',
      date_to: '2026-01-31',
    });
    expect(getMock).toHaveBeenCalledWith('/governance/audit/', {
      params: {
        action: 'users.suspend',
        target_type: 'user',
        target_id: 'u-7',
        actor: '11111111-2222-3333-4444-555555555555',
        date_from: '2026-01-01',
        date_to: '2026-01-31',
      },
    });
  });

  it('requests a per-object timeline with target_type supplied', async () => {
    await adminPortalApi.getAuditTimeline({ target_type: 'user', target_id: 'u-7' });
    expect(getMock).toHaveBeenCalledWith('/governance/audit/timeline/', {
      params: { target_type: 'user', target_id: 'u-7' },
    });
  });

  it('builds an absolute export URL carrying the active filters', () => {
    const url = auditExportUrl({ target_type: 'user', date_from: '2026-01-01' });
    expect(url).toContain('/governance/audit/export/');
    expect(url).toContain('target_type=user');
    expect(url).toContain('date_from=2026-01-01');
  });

  it('never leaks the unused `all` sentinel into the export URL', () => {
    expect(auditExportUrl({ action: 'all', target_type: '' })).toBe('http://localhost:8002/api/v1/governance/audit/export/');
  });
});

describe('adminPortalApi — assistance email', () => {
  it('sends to exactly one recipient and posts to /emails/send/', async () => {
    await adminPortalApi.sendStaffEmail({ user_id: 'u-1', subject: 'Your order', body: 'It shipped.' });
    expect(postMock).toHaveBeenCalledWith('/governance/emails/send/', {
      user_id: 'u-1',
      subject: 'Your order',
      body: 'It shipped.',
    });
  });

  it('filters the log by status, recipient and sender', async () => {
    await adminPortalApi.getEmailLog({ status: 'failed', recipient_email: 'a@b.com', sent_by: 'u-2' });
    expect(getMock).toHaveBeenCalledWith('/governance/emails/log/', {
      params: { status: 'failed', recipient_email: 'a@b.com', sent_by: 'u-2' },
    });
  });

  it('resends a failed message by id with no body', async () => {
    await adminPortalApi.resendStaffEmail('e-1');
    expect(postMock).toHaveBeenCalledWith('/governance/emails/e-1/resend/', {});
  });
});

describe('adminPortalApi — moderation operations', () => {
  it('reads the report queue with assignment filters', async () => {
    await adminPortalApi.getModerationReports({ status: 'open', assigned_to: 'me', unassigned: true, page: 2 });
    expect(getMock).toHaveBeenCalledWith('/moderation/reports/', {
      params: { status: 'open', assigned_to: 'me', unassigned: true, page: 2 },
    });
  });

  it('assigns with an explicit assignee and unassigns with an explicit null', async () => {
    await adminPortalApi.assignModerationReport('r-1', { assigned_to: 'staff-1' });
    expect(postMock).toHaveBeenNthCalledWith(1, '/moderation/reports/r-1/assign/', { assigned_to: 'staff-1' });

    // `null` is meaningful here — it is the unassign. The payload key must be
    // present, because omitting it entirely is a 400, not an implicit unassign.
    await adminPortalApi.assignModerationReport('r-1', { assigned_to: null });
    expect(postMock).toHaveBeenNthCalledWith(2, '/moderation/reports/r-1/assign/', { assigned_to: null });
  });

  it('reads the pending-approvals queue used by bans awaiting a second approver', async () => {
    await adminPortalApi.getPendingApprovals();
    expect(getMock).toHaveBeenCalledWith('/moderation/content-flags/pending-approvals/');
  });

  it('posts a disciplinary action and a reversal', async () => {
    await adminPortalApi.createModerationAction({
      action: 'user_suspended',
      target_user: 'u-1',
      reason: 'chargeback fraud',
      duration_days: 30,
    });
    expect(postMock).toHaveBeenNthCalledWith(1, '/moderation/actions/', {
      action: 'user_suspended',
      target_user: 'u-1',
      reason: 'chargeback fraud',
      duration_days: 30,
    });

    await adminPortalApi.reverseModerationAction('ma-1', { reason: 'appeal upheld' });
    expect(postMock).toHaveBeenNthCalledWith(2, '/moderation/actions/ma-1/reverse/', { reason: 'appeal upheld' });
  });

  it('issues, revokes and hard-deletes commendations', async () => {
    await adminPortalApi.createCommendation({ recipient: 'p-1', category: 'helpful', message: 'Helped a new gym.' });
    expect(postMock).toHaveBeenNthCalledWith(1, '/moderation/commendations/', {
      recipient: 'p-1',
      category: 'helpful',
      message: 'Helped a new gym.',
    });

    await adminPortalApi.revokeCommendation('c-1', { reason: 'issued to the wrong profile' });
    expect(postMock).toHaveBeenNthCalledWith(2, '/moderation/commendations/c-1/revoke/', {
      reason: 'issued to the wrong profile',
    });

    await adminPortalApi.deleteCommendation('c-1');
    expect(deleteMock).toHaveBeenCalledWith('/moderation/commendations/c-1/');
  });
});

describe('moderationActionApplied — the 201/202 discriminator', () => {
  it('reads applied: false as "queued for a second approver, nothing happened"', () => {
    expect(moderationActionApplied({ applied: false, moderation_action: { id: 'ma-1' } })).toBe(false);
  });

  it('reads the 201 warning shape, which has no `applied` key, as applied', () => {
    expect(moderationActionApplied({ id: 'ma-2', action: 'warning' })).toBe(true);
  });

  it('treats an explicit applied:true as applied', () => {
    expect(moderationActionApplied({ applied: true })).toBe(true);
  });

  it('defaults to applied rather than claiming a refusal we cannot see', () => {
    expect(moderationActionApplied(undefined)).toBe(true);
    expect(moderationActionApplied(null)).toBe(true);
  });
});

describe('adminPortalApi — envelope contract is unchanged for the new surfaces', () => {
  it('resolves to the raw envelope so pages can read the server message', async () => {
    postMock.mockResolvedValueOnce(
      ok({ applied: false, approval: { id: 'a-1' } }, 'requires a second approver', null),
    );
    const res: ApiResponse<{ applied: boolean }> = await adminPortalApi.createModerationAction({
      action: 'user_banned',
      target_user: 'u-1',
      reason: 'fraud',
    });
    expect(res.message).toBe('requires a second approver');
    expect(res.data.applied).toBe(false);
  });
});
