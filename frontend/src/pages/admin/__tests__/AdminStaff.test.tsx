import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { adminPortalApi, type StaffRoleAssignment } from '@/api/adminPortal';
import AdminStaff from '@/pages/admin/AdminStaff';

vi.mock('@/api/adminPortal', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/api/adminPortal')>();
  return {
    ...actual,
    adminPortalApi: {
      getStaffRoles: vi.fn(),
      getStaffRole: vi.fn(),
      createStaffRole: vi.fn(),
      updateStaffRole: vi.fn(),
      revokeStaffRole: vi.fn(),
    },
  };
});

const api = adminPortalApi;
const getStaffRoles = api.getStaffRoles as unknown as ReturnType<typeof vi.fn>;
const createStaffRole = api.createStaffRole as unknown as ReturnType<typeof vi.fn>;
const revokeStaffRole = api.revokeStaffRole as unknown as ReturnType<typeof vi.fn>;

const envelope = (data: unknown[], message = '') => ({
  success: true,
  data,
  message,
  errors: null,
  pagination: { count: data.length, next: null, previous: null },
});

const ROLES: StaffRoleAssignment[] = [
  {
    id: 'sr-1',
    user: { id: 's-1', email: 'lead@example.com', display_name: 'Team Lead' },
    role: 'moderator',
    role_display: 'Moderator',
    scopes: ['orders.read'],
    default_scopes: ['users.read'],
    effective_scopes: ['orders.read', 'users.read'],
    granted_by: { id: 's-0', email: 'admin@example.com' },
    granted_at: '2026-02-01T09:00:00Z',
    is_active: true,
  },
];

const renderPage = () =>
  render(
    <MemoryRouter>
      <AdminStaff />
    </MemoryRouter>,
  );

const openGrantForm = async () => {
  renderPage();
  await waitFor(() => expect(screen.getByRole('button', { name: /grant a role/i })).toBeInTheDocument());
  fireEvent.click(screen.getByRole('button', { name: /grant a role/i }));
  await screen.findByLabelText('Staff user id');
};

beforeEach(() => {
  vi.clearAllMocks();
  getStaffRoles.mockResolvedValue(envelope(ROLES));
  createStaffRole.mockResolvedValue(
    envelope(
      { id: 'ar-1', action: 'staff_role_grant', status: 'pending', requires_second: true },
      'Role change requires a second approver. The request has been raised and nothing has been applied yet.',
    ),
  );
  revokeStaffRole.mockResolvedValue(envelope(ROLES[0], 'Staff role revoked.'));
});

describe('AdminStaff — listing', () => {
  it('shows the holder, their role and the effective scopes', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByText('Team Lead')).toBeInTheDocument());
    // The badge and the role chip filter both say "Moderator".
    expect(screen.getAllByText('Moderator').length).toBeGreaterThan(1);
    // Role floor plus the per-person extras — the number that decides reach.
    expect(screen.getByText(/Effective scopes \(2\)/)).toBeInTheDocument();
    // `orders.read` is both a default and an extra on this row, so it appears
    // twice: once in the effective set, once in the breakdown below it.
    expect(screen.getAllByText('orders.read').length).toBe(2);
    expect(screen.getAllByText('users.read').length).toBe(2);
    expect(screen.getByText(/Role floor \(1\)/)).toBeInTheDocument();
  });

  it('defaults to active assignments only', async () => {
    renderPage();
    await waitFor(() => expect(getStaffRoles).toHaveBeenCalledTimes(1));
    expect(getStaffRoles.mock.calls[0][0]).toMatchObject({ revoked: 'false' });
  });

  it('can list revoked assignments too', async () => {
    renderPage();
    await waitFor(() => expect(getStaffRoles).toHaveBeenCalledTimes(1));
    fireEvent.click(screen.getByRole('button', { name: /revoked only/i }));
    await waitFor(() => expect(getStaffRoles).toHaveBeenCalledTimes(2));
    expect(getStaffRoles.mock.calls[1][0]).toMatchObject({ revoked: 'true' });
  });
});

describe('AdminStaff — granting', () => {
  it('defaults to routing the grant through a second approver', async () => {
    await openGrantForm();
    expect(screen.getByLabelText('Require a second approver')).toBeChecked();

    fireEvent.change(screen.getByLabelText('Staff user id'), { target: { value: 's-2' } });
    fireEvent.change(screen.getByLabelText('Extra scopes'), { target: { value: 'users.read, orders.write' } });
    fireEvent.click(screen.getByRole('button', { name: /request role change/i }));

    await waitFor(() =>
      expect(createStaffRole).toHaveBeenCalledWith({
        user: 's-2',
        role: 'moderator',
        scopes: ['users.read', 'orders.write'],
        notes: '',
        requires_second: true,
      }),
    );
  });

  it('says the change needs a second approver instead of claiming the role was granted', async () => {
    await openGrantForm();
    fireEvent.change(screen.getByLabelText('Staff user id'), { target: { value: 's-2' } });
    fireEvent.click(screen.getByRole('button', { name: /request role change/i }));

    const notice = await screen.findByText(/requires a second approver/i);
    expect(notice).toHaveTextContent('nothing has been applied yet');
    expect(screen.queryByText(/^Staff role granted\.$/)).toBeNull();
  });

  it('confirms only when the API actually applied it (201, a StaffRole back)', async () => {
    createStaffRole.mockResolvedValue(
      envelope({ ...ROLES[0], id: 'sr-2' }, 'Staff role granted.'),
    );
    await openGrantForm();
    fireEvent.change(screen.getByLabelText('Staff user id'), { target: { value: 's-2' } });
    fireEvent.click(screen.getByRole('button', { name: /request role change/i }));

    expect(await screen.findByText('Staff role granted.')).toBeInTheDocument();
  });

  it('warns before applying administrator inline with nobody else in the loop', async () => {
    await openGrantForm();
    fireEvent.click(screen.getByLabelText('Require a second approver'));
    fireEvent.change(screen.getByLabelText('Role to grant'), { target: { value: 'admin' } });

    expect(screen.getByText(/removes every scope limit on this account/)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /grant role now/i })).toBeInTheDocument();
  });

  it("surfaces the API's refusal of a self-grant verbatim", async () => {
    createStaffRole.mockRejectedValue(
      Object.assign(new Error('forbidden'), {
        response: {
          status: 403,
          data: {
            success: false,
            message: 'You cannot grant yourself a staff role. Role changes need another administrator to approve, so ask one to raise the request.',
          },
        },
      }),
    );

    await openGrantForm();
    fireEvent.change(screen.getByLabelText('Staff user id'), { target: { value: 's-2' } });
    fireEvent.click(screen.getByRole('button', { name: /request role change/i }));

    expect(await screen.findByText(/You cannot grant yourself a staff role/)).toBeInTheDocument();
  });

  it("surfaces the API's rejection of an unknown scope", async () => {
    createStaffRole.mockRejectedValue(
      Object.assign(new Error('bad request'), {
        response: {
          status: 400,
          data: { success: false, errors: { scopes: ["Unknown scope(s): ['payouts.write']."] } },
        },
      }),
    );

    await openGrantForm();
    fireEvent.change(screen.getByLabelText('Staff user id'), { target: { value: 's-2' } });
    fireEvent.change(screen.getByLabelText('Extra scopes'), { target: { value: 'payouts.write' } });
    fireEvent.click(screen.getByRole('button', { name: /request role change/i }));

    expect(await screen.findByText(/Unknown scope\(s\)/)).toBeInTheDocument();
  });
});

describe('AdminStaff — revoking', () => {
  it('revokes by id and reports the consequence', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByRole('button', { name: /^revoke$/i })).toBeInTheDocument());

    fireEvent.click(screen.getByRole('button', { name: /^revoke$/i }));
    fireEvent.change(await screen.findByLabelText('Internal note'), { target: { value: 'moving teams' } });
    fireEvent.click(screen.getByRole('button', { name: /revoke this role/i }));

    // The typed reason must be sent, not collected and dropped.
    await waitFor(() => expect(revokeStaffRole).toHaveBeenCalledWith('sr-1', 'moving teams'));
    expect(await screen.findByText(/Staff role revoked/)).toBeInTheDocument();
  });

  it('does not offer revocation on a role that is already revoked', async () => {
    getStaffRoles.mockResolvedValue(envelope([{ ...ROLES[0], is_active: false, revoked_at: '2026-03-01T00:00:00Z' }]));
    renderPage();
    await waitFor(() => expect(screen.getByText('Team Lead')).toBeInTheDocument());
    expect(screen.queryByRole('button', { name: /^revoke$/i })).toBeNull();
    expect(screen.getByText(/grant a fresh role/i)).toBeInTheDocument();
  });
});
