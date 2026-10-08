import { useCallback, useMemo, useState } from 'react';
import { CheckCircle2, Search, UserCog, UserX } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { adminPortalApi, type PortalUser } from '@/api/adminPortal';
import {
  AdminEmptyState,
  AdminErrorBanner,
  AdminErrorState,
  AdminPageHeader,
  AdminPagination,
  AdminSkeleton,
  AdminStatCard,
  BooleanBadge,
  DataRow,
  FilterSelect,
  ReasonPrompt,
  SearchField,
  StatusBadge,
} from './shared';
import { formatDate, shortId, text } from './format';
import { useDebounced, usePortalAction, usePortalList } from './usePortalList';

const ROLE_OPTIONS = [
  { value: 'all', label: 'All roles' },
  { value: 'user', label: 'User' },
  { value: 'trainer', label: 'Trainer' },
  { value: 'practitioner', label: 'Practitioner' },
];

const VERIFICATION_OPTIONS = [
  { value: 'all', label: 'Any verification' },
  { value: 'none', label: 'None' },
  { value: 'email', label: 'Email' },
  { value: 'id', label: 'ID' },
  { value: 'trainer', label: 'Trainer' },
  { value: 'practitioner', label: 'Practitioner' },
];

const ACTIVE_OPTIONS = [
  { value: 'all', label: 'Any account state' },
  { value: 'true', label: 'Active' },
  { value: 'false', label: 'Inactive' },
];

const PROFILE_OPTIONS = [
  { value: 'all', label: 'Search profile: any' },
  { value: 'true', label: 'Has search profile' },
  { value: 'false', label: 'No search profile' },
];

const boolOrUndef = (v: string) => (v === 'all' ? undefined : v === 'true');

export default function AdminUsers() {
  const [query, setQuery] = useState('');
  const [role, setRole] = useState('all');
  const [active, setActive] = useState('all');
  const [verification, setVerification] = useState('all');
  const [hasSearchProfile, setHasSearchProfile] = useState('all');
  const [expanded, setExpanded] = useState<string | null>(null);
  const [pending, setPending] = useState<{ id: string; action: 'suspended' | 'reinstated' } | null>(null);
  const debouncedQuery = useDebounced(query);
  const action = usePortalAction();

  const filters = useMemo(
    () => ({
      q: debouncedQuery.trim() || undefined,
      role,
      is_active: boolOrUndef(active),
      verification_status: verification,
      has_search_profile: boolOrUndef(hasSearchProfile),
    }),
    [debouncedQuery, role, active, verification, hasSearchProfile],
  );

  const fetcher = useCallback(
    (params: Record<string, unknown>) => adminPortalApi.getUsers(params as never),
    [],
  );
  const { items, count, page, pageCount, loading, error, reload, goToPage } = usePortalList<PortalUser>(fetcher, filters);

  const suspend = useCallback(
    async (user: PortalUser, reason: string) => {
      const id = user.id;
      if (!id) return;
      const ok = await action.run(
        id,
        () => adminPortalApi.suspendUser(id, { reason }),
        { success: `Suspended ${text(user.email || user.username, 'user')}.`, failure: 'Failed to suspend user.' },
      );
      setPending(null);
      if (ok) reload(true);
    },
    [action, reload],
  );

  const reinstate = useCallback(
    async (user: PortalUser) => {
      const id = user.id;
      if (!id) return;
      const ok = await action.run(
        id,
        () => adminPortalApi.reinstateUser(id, {}),
        { success: `Reinstated ${text(user.email || user.username, 'user')}.`, failure: 'Failed to reinstate user.' },
      );
      if (ok) reload(true);
    },
    [action, reload],
  );

  const suspended = items.filter((u) => u.is_suspended === true || u.is_active === false).length;
  const staff = items.filter((u) => u.is_staff === true).length;

  if (loading && !items.length) return <AdminSkeleton />;

  if (error && !items.length) return <AdminErrorState message={error} onRetry={() => reload()} />;

  return (
    <div className="space-y-6 pb-8">
      <AdminPageHeader
        title="Users"
        description={`Search, inspect and suspend accounts. Counts only — no profile content is loaded.`}
        onRefresh={() => reload()}
        refreshing={loading}
      />

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <AdminStatCard label="Matching users" value={count.toLocaleString()} />
        <AdminStatCard label="On this page" value={items.length} />
        <AdminStatCard label="Suspended / inactive" value={suspended} />
        <AdminStatCard label="Staff on this page" value={staff} />
      </div>

      <Card className="p-4 space-y-3">
        <div className="flex flex-wrap items-center gap-2">
          <SearchField value={query} onChange={setQuery} label="Search users" placeholder="Email, username, id…" />
          <div className="flex flex-wrap items-center gap-2 ml-auto">
            <FilterSelect label="Role" value={role} options={ROLE_OPTIONS} onChange={setRole} />
            <FilterSelect label="Account state" value={active} options={ACTIVE_OPTIONS} onChange={setActive} />
          </div>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          <FilterSelect label="Verification" value={verification} options={VERIFICATION_OPTIONS} onChange={setVerification} />
          <FilterSelect label="Search profile" value={hasSearchProfile} options={PROFILE_OPTIONS} onChange={setHasSearchProfile} />
          {(query || role !== 'all' || active !== 'all' || verification !== 'all' || hasSearchProfile !== 'all') && (
            <Button
              variant="ghost"
              size="sm"
              onClick={() => { setQuery(''); setRole('all'); setActive('all'); setVerification('all'); setHasSearchProfile('all'); }}
            >
              Clear filters
            </Button>
          )}
        </div>
      </Card>

      {error && <AdminErrorBanner message={error} onRetry={() => reload()} />}
      {action.error && <AdminErrorBanner message={action.error} />}
      {action.notice && (
        <div className="bg-buddy-green/10 border border-buddy-green/20 text-buddy-green text-xs rounded-xl px-3 py-2">
          {action.notice}
        </div>
      )}

      {items.length === 0 ? (
        <AdminEmptyState
          icon={<Search size={32} />}
          title={count === 0 ? 'No users match the current filters.' : 'No users on this page.'}
          hint="Adjust the filters above, or clear them to see everyone."
        />
      ) : (
        <div className="space-y-2">
          {items.map((user, index) => {
            const id = user.id || user.email || `row-${index}`;
            const isOpen = expanded === id;
            const busy = action.actingId === user.id;
            const isSuspended = user.is_suspended === true || user.is_active === false;
            return (
              <Card key={id} className="p-4">
                <div className="flex flex-wrap items-start gap-3">
                  <div className="flex-1 min-w-0">
                    <div className="flex flex-wrap items-center gap-2">
                      <span className="text-sm font-semibold truncate">{text(user.username || user.display_name, 'Unnamed user')}</span>
                      <StatusBadge status={user.role} />
                      <StatusBadge status={user.verification_status} />
                      {user.is_staff === true && <StatusBadge status="staff" />}
                      <BooleanBadge value={user.email_verified} trueLabel="Email verified" falseLabel="Email unverified" />
                    </div>
                    <p className="text-xs text-buddy-text-secondary mt-1 break-all">{text(user.email)}</p>
                    <p className="text-[11px] text-buddy-text-secondary mt-0.5">
                      {shortId(user.id)} · joined {formatDate(user.date_joined || user.created_at)}
                      {user.last_login ? ` · last seen ${formatDate(user.last_login)}` : ''}
                    </p>
                    {user.suspension_reason && (
                      <p className="text-[11px] text-buddy-red mt-1 break-words">Suspended: {user.suspension_reason}</p>
                    )}
                  </div>
                  <div className="flex items-center gap-2 flex-shrink-0">
                    <Button variant="ghost" size="sm" onClick={() => setExpanded(isOpen ? null : id)}>
                      <UserCog size={14} className="mr-1" /> {isOpen ? 'Hide' : 'Details'}
                    </Button>
                    {isSuspended ? (
                      <Button variant="outline" size="sm" disabled={busy} onClick={() => reinstate(user)}>
                        <CheckCircle2 size={14} className="mr-1" /> Reinstate
                      </Button>
                    ) : (
                      <Button variant="destructive" size="sm" disabled={busy} onClick={() => setPending({ id, action: 'suspended' })}>
                        <UserX size={14} className="mr-1" /> Suspend
                      </Button>
                    )}
                  </div>
                </div>

                {isOpen && (
                  <div className="mt-3 pt-3 border-t border-buddy-surface grid grid-cols-1 sm:grid-cols-2 gap-x-6">
                    <DataRow label="User ID">{text(user.id)}</DataRow>
                    <DataRow label="Display name">{text(user.display_name)}</DataRow>
                    <DataRow label="Phone">{text(user.phone)}</DataRow>
                    <DataRow label="Staff">{user.is_staff ? 'Yes' : 'No'}</DataRow>
                    <DataRow label="Superuser">{user.is_superuser ? 'Yes' : 'No'}</DataRow>
                    <DataRow label="Adult account">{user.is_adult === undefined ? '—' : user.is_adult ? 'Yes' : 'No'}</DataRow>
                    <DataRow label="Onboarding">{user.onboarding_completed === undefined ? '—' : user.onboarding_completed ? 'Complete' : 'Incomplete'}</DataRow>
                    <DataRow label="Search profile">{user.has_search_profile === undefined ? '—' : user.has_search_profile ? 'Present' : 'Absent'}</DataRow>
                    <DataRow label="Posts">{typeof user.post_count === 'number' ? user.post_count : '—'}</DataRow>
                    <DataRow label="Suspended at">{formatDate(user.suspended_at)}</DataRow>
                  </div>
                )}

                <ReasonPrompt
                  open={pending?.id === id}
                  action="rejected"
                  submitLabel="Suspend account"
                  placeholder="Why is this account being suspended? The user sees this reason."
                  busy={busy}
                  onSubmit={(reason) => suspend(user, reason)}
                  onCancel={() => setPending(null)}
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