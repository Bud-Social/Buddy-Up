import { useCallback, useEffect, useMemo, useState } from 'react';
import { KeyRound, ShieldOff, UserPlus } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import {
  adminPortalApi,
  adminPortalErrorMessage,
  type GovernanceApproval,
  type StaffInvitation,
  type StaffRoleAssignment,
} from '@/api/adminPortal';
import {
  AdminEmptyState,
  AdminErrorBanner,
  AdminErrorState,
  AdminPageHeader,
  AdminPagination,
  AdminSkeleton,
  AdminStatCard,
  DataRow,
  FilterChips,
  ReasonPrompt,
  StatusBadge,
} from './shared';
import { formatDate, shortId, text } from './format';
import { usePortalAction, usePortalList } from './usePortalList';

/**
 * Staff roles and their effective scopes.
 *
 * A role is a *floor* of scopes, not a permission bundle somebody accumulates,
 * and `effective_scopes` is the number that matters: it is the defaults plus
 * the per-person extras, computed server-side from the same helper the
 * permission check uses. Showing only `role` here would tell an operator
 * nothing about what a colleague can actually reach.
 *
 * The other thing this page has to be honest about is that granting is
 * usually not granting. `POST /governance/staff-roles/` answers **202** with an
 * approval request when `requires_second` is left on, and the message says
 * nothing has been applied. A page that reported that as "Role granted" would
 * be the single most dangerous lie in this console — an operator would walk
 * away believing a colleague had access they do not.
 */

const ROLE_OPTIONS = [
  { value: 'all', label: 'All roles' },
  { value: 'admin', label: 'Administrator' },
  { value: 'moderator', label: 'Moderator' },
  { value: 'support', label: 'Support Agent' },
  { value: 'gym_relations', label: 'Gym Relations' },
  { value: 'supplier_relations', label: 'Supplier Relations' },
  { value: 'logistics', label: 'Logistics' },
  { value: 'finance', label: 'Finance' },
  { value: 'verification_regulator', label: 'Verification Regulator' },
];

const REVOKED_OPTIONS = [
  { value: 'active', label: 'Active only' },
  { value: 'all', label: 'Including revoked' },
  { value: 'revoked', label: 'Revoked only' },
];

const GRANTABLE_ROLES = ROLE_OPTIONS.filter((r) => r.value !== 'all');

/**
 * True when a grant came back as an approval request rather than a live role.
 *
 * The endpoint answers **201** with a `StaffRole` when the grant applied
 * inline, and **202** with an `AccountActionRequest` when it was routed for a
 * second approver. Both are 2xx, so the status code says nothing — the shape
 * does. A `StaffRole` has `effective_scopes` and no `status`; a pending
 * request has `status`/`requires_second` and no scopes.
 */
function isPendingGrant(data: StaffRoleAssignment | GovernanceApproval | null | undefined): boolean {
  if (!data) return false;
  const maybe = data as Partial<GovernanceApproval>;
  return maybe.status === 'pending' || maybe.requires_second === true;
}

function ScopeChips({ scopes, tone = 'silver' }: { scopes: string[] | null | undefined; tone?: 'silver' | 'electric' }) {  if (!scopes || scopes.length === 0) {
    return <span className="text-xs text-buddy-text-secondary">None — unrestricted (no role row means full access).</span>;
  }
  return (
    <span className="flex flex-wrap gap-1 justify-end">
      {scopes.map((s) => (
        <Badge key={s} variant={tone} label={s} size="sm" />
      ))}
    </span>
  );
}

export default function AdminStaff() {
  const [role, setRole] = useState('all');
  const [revoked, setRevoked] = useState('active');
  const [revoking, setRevoking] = useState<string | null>(null);
  const action = usePortalAction();

  const filters = useMemo(
    () => ({
      role,
      // `revoked=false` means "not revoked"; `all` means "don't filter".
      revoked: revoked === 'active' ? 'false' : revoked === 'revoked' ? 'true' : undefined,
    }),
    [role, revoked],
  );

  const fetcher = useCallback(
    (params: Record<string, unknown>) => adminPortalApi.getStaffRoles(params as never),
    [],
  );
  const { items, count, page, pageCount, loading, error, reload, goToPage } =
    usePortalList<StaffRoleAssignment>(fetcher, filters);

  const revoke = useCallback(
    async (row: StaffRoleAssignment, why: string) => {
      const id = row.id;
      if (!id) return;
      const ok = await action.run(
        id,
        () => adminPortalApi.revokeStaffRole(id, why),
        {
          success: 'Staff role revoked. The holder now has no scopes until re-granted.',
          failure: 'Failed to revoke the staff role.',
        },
      );
      setRevoking(null);
      if (ok) reload(true);
      // `why` is captured for the operator's own record; the API takes no body.
      void why;
    },
    [action, reload],
  );

  const activeCount = items.filter((r) => r.is_active !== false).length;
  const wideCount = items.filter((r) => r.role === 'admin' && r.is_active !== false).length;

  if (loading && !items.length) return <AdminSkeleton />;
  if (error && !items.length) return <AdminErrorState message={error} onRetry={() => reload()} />;

  return (
    <div className="space-y-6 pb-8">
      <AdminPageHeader
        title="Staff roles"
        description="Who holds which role, and what that role actually lets them reach."
        onRefresh={() => reload()}
        refreshing={loading}
      />

      <InviteForm onInvited={() => reload(true)} />

      <GrantForm onGranted={() => reload(true)} />

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <AdminStatCard label="Matching assignments" value={count.toLocaleString()} />
        <AdminStatCard label="Active on this page" value={activeCount} />
        <AdminStatCard label="Administrators" value={wideCount} sub="admin carries every scope" />
        <AdminStatCard label="Revoked on this page" value={items.length - activeCount} />
      </div>

      <Card className="p-4 space-y-3">
        <FilterChips options={ROLE_OPTIONS} value={role} onChange={setRole} />
        <FilterChips options={REVOKED_OPTIONS} value={revoked} onChange={setRevoked} />
      </Card>

      {error && <AdminErrorBanner message={error} onRetry={() => reload()} />}
      {action.error && <AdminErrorBanner message={action.error} onRetry={action.clearError} />}
      {action.notice && (
        <div className="bg-buddy-green/10 border border-buddy-green/20 text-buddy-green text-xs rounded-xl px-3 py-2">
          {action.notice}
        </div>
      )}

      {items.length === 0 ? (
        <AdminEmptyState
          icon={<KeyRound size={32} />}
          title={count === 0 ? 'No role assignments match the current filters.' : 'No assignments on this page.'}
          hint="A staff account with no row here is unrestricted — that is the pre-governance behaviour and is intentional."
        />
      ) : (
        <div className="space-y-2">
          {items.map((row, index) => {
            const id = row.id || `role-${index}`;
            const isActive = row.is_active !== false && !row.revoked_at;
            return (
              <Card key={id} className="p-4">
                <div className="flex flex-wrap items-start gap-3">
                  <div className="flex-1 min-w-0">
                    <div className="flex flex-wrap items-center gap-2">
                      <span className="text-sm font-semibold truncate">
                        {text(row.user?.display_name, text(row.user?.email, 'Unknown staff member'))}
                      </span>
                      <StatusBadge status={row.role_display || row.role} />
                      {!isActive && <Badge variant="silver" label="Revoked" size="sm" />}
                      {row.role === 'admin' && <Badge variant="gold" label="Unrestricted" size="sm" />}
                    </div>
                    <p className="text-xs text-buddy-text-secondary mt-1 break-all">{text(row.user?.email)}</p>
                    <div className="mt-2">
                      <p className="text-[11px] text-buddy-text-secondary mb-1">Effective scopes ({row.effective_scopes?.length ?? 0})</p>
                      <ScopeChips scopes={row.effective_scopes} tone="electric" />
                    </div>
                    <p className="text-[11px] text-buddy-text-secondary mt-1.5">
                      {shortId(row.id)} · granted by {text(row.granted_by?.email, 'system')} ·{' '}
                      {formatDate(row.granted_at)}
                      {row.revoked_at ? ` · revoked ${formatDate(row.revoked_at)}` : ''}
                    </p>
                    {row.notes && <p className="text-[11px] text-buddy-text-secondary mt-1 break-words">{row.notes}</p>}
                  </div>
                  <div className="flex-shrink-0">
                    {isActive ? (
                      <Button variant="destructive" size="sm" onClick={() => setRevoking(revoking === id ? null : id)}>
                        <ShieldOff size={14} className="mr-1" /> Revoke
                      </Button>
                    ) : (
                      <span className="text-[11px] text-buddy-text-secondary">Revoked — grant a fresh role</span>
                    )}
                  </div>
                </div>

                {isActive && (
                  <div className="mt-3 pt-3 border-t border-buddy-surface grid grid-cols-1 sm:grid-cols-2 gap-x-6">
                    <DataRow label="Role code">{text(row.role)}</DataRow>
                    <DataRow label={`Role floor (${row.default_scopes?.length ?? 0})`}>
                      <ScopeChips scopes={row.default_scopes} />
                    </DataRow>
                    <DataRow label={`Per-person extras (${row.scopes?.length ?? 0})`}>
                      <ScopeChips scopes={row.scopes} />
                    </DataRow>
                    <DataRow label="User id">{text(row.user?.id)}</DataRow>
                  </div>
                )}

                <ReasonPrompt
                  open={revoking === id}
                  action="approved"
                  submitLabel="Revoke this role"
                  placeholder="Why is this being revoked? Recorded on the role row and in the audit trail."
                  busy={action.actingId === row.id}
                  onSubmit={(why) => revoke(row, why)}
                  onCancel={() => setRevoking(null)}
                />
              </Card>
            );
          })}
        </div>
      )}

      <AdminPagination page={page} pageCount={pageCount} count={count} onPage={goToPage} busy={loading} />
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Grant                                                               */
/* ------------------------------------------------------------------ */

function GrantForm({ onGranted }: { onGranted: () => void }) {
  const [open, setOpen] = useState(false);
  const [user, setUser] = useState('');
  const [role, setRole] = useState('moderator');
  const [scopes, setScopes] = useState('');
  const [notes, setNotes] = useState('');
  const [requiresSecond, setRequiresSecond] = useState(true);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');

  const submit = useCallback(async () => {
    if (!user.trim() || busy) return;
    setBusy(true);
    setError('');
    setNotice('');
    try {
      const res = await adminPortalApi.createStaffRole({
        user: user.trim(),
        role,
        scopes: scopes.split(',').map((s) => s.trim()).filter(Boolean),
        notes: notes.trim(),
        requires_second: requiresSecond,
      });
      // 201 means it is live. 202 means it is a request somebody else must
      // approve, and the payload is an approval, not a role.
      const queued = isPendingGrant(res?.data);
      setNotice(
        queued
          ? res?.message ||
            'Role change requires a second approver. The request has been raised and nothing has been applied yet.'
          : res?.message || 'Staff role granted.',
      );
      setUser('');
      setScopes('');
      setNotes('');
      onGranted();
    } catch (e) {
      setError(adminPortalErrorMessage(e, 'Failed to grant the staff role.'));
    } finally {
      setBusy(false);
    }
  }, [user, busy, role, scopes, notes, requiresSecond, onGranted]);

  if (!open) {
    return (
      <Card className="p-4">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div className="min-w-0">
            <h3 className="text-sm font-semibold flex items-center gap-1.5"><UserPlus size={14} /> Grant a staff role</h3>
            <p className="text-[11px] text-buddy-text-secondary mt-0.5">
              A grant routed for approval changes nothing until somebody else signs it off. You can also
              grant yourself nothing — the API refuses self-grant outright.
            </p>
          </div>
          <Button variant="outline" size="sm" onClick={() => setOpen(true)}>Grant a role</Button>
        </div>
      </Card>
    );
  }

  return (
    <Card className="p-4 space-y-3">
      <div className="flex items-center justify-between gap-3">
        <h3 className="text-sm font-semibold flex items-center gap-1.5"><UserPlus size={14} /> Grant a staff role</h3>
        <Button variant="ghost" size="sm" onClick={() => { setOpen(false); setError(''); setNotice(''); }}>Close</Button>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <label className="block text-xs text-buddy-text-secondary">
          <span className="mb-1 block">Staff user id</span>
          <input
            value={user}
            onChange={(e) => setUser(e.target.value)}
            placeholder="00000000-0000-0000-0000-000000000000"
            aria-label="Staff user id"
            className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm font-mono placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
          />
          <span className="mt-0.5 block text-[10px] text-buddy-text-secondary/70">Must be an is_staff account.</span>
        </label>
        <label className="block text-xs text-buddy-text-secondary">
          <span className="mb-1 block">Role</span>
          <select
            value={role}
            onChange={(e) => setRole(e.target.value)}
            aria-label="Role to grant"
            className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm focus:outline-none focus:border-buddy-green"
          >
            {GRANTABLE_ROLES.map((r) => (
              <option key={r.value} value={r.value}>{r.label}</option>
            ))}
          </select>
          <span className="mt-0.5 block text-[10px] text-buddy-text-secondary/70">
            The role sets the scope floor. Extras are added on top, never subtracted.
          </span>
        </label>
      </div>

      <label className="block text-xs text-buddy-text-secondary">
        <span className="mb-1 block">Extra scopes (comma separated, optional)</span>
        <input
          value={scopes}
          onChange={(e) => setScopes(e.target.value)}
          placeholder="users.read, orders.cases.read"
          aria-label="Extra scopes"
          className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
        />
        <span className="mt-0.5 block text-[10px] text-buddy-text-secondary/70">
          An unknown scope is a 400 naming the valid list, not a silent no-op.
        </span>
      </label>

      <label className="block text-xs text-buddy-text-secondary">
        <span className="mb-1 block">Notes (optional)</span>
        <input
          value={notes}
          onChange={(e) => setNotes(e.target.value)}
          placeholder="Why is this person being given this role?"
          aria-label="Grant notes"
          className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
        />
      </label>

      <label className="inline-flex items-start gap-2 text-xs text-buddy-text-secondary">
        <input
          type="checkbox"
          checked={requiresSecond}
          onChange={(e) => setRequiresSecond(e.target.checked)}
          aria-label="Require a second approver"
          className="accent-buddy-green mt-0.5"
        />
        <span>
          Require a second approver <strong>(recommended)</strong> — the request is raised in the
          approvals queue and nothing is applied until somebody else approves it.
          {role === 'admin' && !requiresSecond && (
            <span className="block text-buddy-orange mt-0.5">
              Applying <code>admin</code> without approval removes every scope limit on this account, right
              now, with nobody else in the loop.
            </span>
          )}
        </span>
      </label>

      <div className="flex items-center gap-2">
        <Button size="sm" disabled={!user.trim()} isLoading={busy} onClick={submit}>
          {requiresSecond ? 'Request role change' : 'Grant role now'}
        </Button>
        {!user.trim() && <span className="text-[11px] text-buddy-text-secondary">A staff user id is required.</span>}
      </div>

      {notice && (
        <div className="bg-buddy-electric/10 border border-buddy-electric/20 text-buddy-electric text-xs rounded-xl px-3 py-2">
          {notice}
        </div>
      )}
      {error && <AdminErrorBanner message={error} />}
    </Card>
  );
}


/**
 * Onboarding by invitation — the path for somebody who does not have an account
 * yet.
 *
 * `GrantForm` above needs a user id, so it cannot onboard anyone: a new hire has
 * no row to point at. This form takes an email, and the link it sends is the
 * only thing that creates their staff access. The two-person queue is applied
 * here exactly as it is there, so the default is "request" rather than "send".
 */
function InviteForm({ onInvited }: { onInvited: () => void }) {
  const [email, setEmail] = useState('');
  const [role, setRole] = useState('support');
  const [notes, setNotes] = useState('');
  const [requiresSecond, setRequiresSecond] = useState(true);
  const [busy, setBusy] = useState(false);
  const [notice, setNotice] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [rows, setRows] = useState<StaffInvitation[]>([]);
  const [loadingRows, setLoadingRows] = useState(true);

  const loadRows = useCallback(async () => {
    setLoadingRows(true);
    try {
      const res = await adminPortalApi.getStaffInvitations();
      setRows(res.data || []);
      setError(null);
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not load invitations.');
    } finally {
      setLoadingRows(false);
    }
  }, []);

  useEffect(() => { loadRows(); }, [loadRows]);

  const submit = async () => {
    if (!email.trim()) return;
    setBusy(true);
    setError(null);
    setNotice(null);
    try {
      const res = await adminPortalApi.createStaffInvitation({
        email: email.trim(),
        role,
        notes: notes.trim(),
        requires_second: requiresSecond,
      });
      setNotice(res.message || '');
      setEmail('');
      setNotes('');
      await loadRows();
      onInvited();
    } catch (e: any) {
      const data = e?.response?.data;
      setError(data?.message || 'Could not create that invitation.');
    } finally {
      setBusy(false);
    }
  };

  const revoke = async (row: StaffInvitation) => {
    try {
      await adminPortalApi.revokeStaffInvitation(row.id);
      await loadRows();
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not revoke that invitation.');
    }
  };

  const resend = async (row: StaffInvitation) => {
    try {
      const res = await adminPortalApi.resendStaffInvitation(row.id);
      setNotice(res.message || 'Invitation resent.');
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not resend that invitation.');
    }
  };

  const live = rows.filter((r) => r.is_live);

  return (
    <Card className="p-4 space-y-3">
      <div>
        <h3 className="font-semibold text-sm">Invite a new staff member</h3>
        <p className="text-xs text-buddy-text-secondary mt-0.5">
          For somebody who does not have an account yet. They register, then the
          link they receive sets their access.
        </p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
        <Input
          label="Email"
          type="email"
          value={email}
          onChange={(e: React.ChangeEvent<HTMLInputElement>) => setEmail(e.target.value)}
          placeholder="new.staff@example.com"
        />
        <div>
          <span className="block text-xs font-medium mb-1">Role</span>
          <select
            value={role}
            onChange={(e) => setRole(e.target.value)}
            className="w-full bg-buddy-surface border border-buddy-surface-raised rounded-xl p-2.5 text-sm"
          >
            {ROLE_OPTIONS.filter((r) => r.value !== 'all').map((r) => (
              <option key={r.value} value={r.value}>{r.label}</option>
            ))}
          </select>
        </div>
        <Input
          label="Note (optional)"
          value={notes}
          onChange={(e: React.ChangeEvent<HTMLInputElement>) => setNotes(e.target.value)}
          placeholder="Why they are being added"
        />
      </div>

      <label className="flex items-start gap-2 text-xs">
        <input
          type="checkbox"
          checked={requiresSecond}
          onChange={(e) => setRequiresSecond(e.target.checked)}
          className="mt-0.5"
        />
        <span className="text-buddy-text-secondary">
          Require a second approver (recommended).
          {!requiresSecond && (
            <span className="block text-buddy-orange mt-0.5">
              The link is emailed immediately and nobody else has agreed to it.
              Only do this for someone you have already cleared.
            </span>
          )}
        </span>
      </label>

      <div className="flex items-center gap-2">
        <Button size="sm" disabled={!email.trim()} isLoading={busy} onClick={submit}>
          {requiresSecond ? 'Request invitation' : 'Invite now'}
        </Button>
      </div>

      {notice && (
        <div className="bg-buddy-green/10 border border-buddy-green/20 text-buddy-green text-xs rounded-xl px-3 py-2">
          {notice}
        </div>
      )}
      {error && <AdminErrorBanner message={error} onRetry={() => loadRows()} />}

      {live.length > 0 && (
        <div className="pt-2 border-t border-buddy-surface-raised">
          <p className="text-xs font-semibold mb-2">Outstanding invitations</p>
          <div className="space-y-1.5">
            {live.map((row) => (
              <div
                key={row.id}
                className="flex flex-wrap items-center gap-2 text-xs bg-buddy-surface-raised/40 rounded-lg px-3 py-2"
              >
                <span className="font-medium">{row.email}</span>
                <Badge variant="silver" size="sm" label={row.role_display || row.role} />
                {row.has_account && (
                  <span className="text-buddy-text-secondary">
                    has an account — they sign in, then accept
                  </span>
                )}
                <span className="flex-1" />
                <Button size="sm" variant="ghost" onClick={() => resend(row)}>Resend</Button>
                <Button size="sm" variant="ghost" onClick={() => revoke(row)}>Revoke</Button>
              </div>
            ))}
          </div>
        </div>
      )}
      {!loadingRows && live.length === 0 && (
        <p className="text-[11px] text-buddy-text-secondary">
          No outstanding invitations.
        </p>
      )}
    </Card>
  );
}
