import { useCallback, useMemo, useState } from 'react';
import { Dumbbell, Search, Users } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { adminPortalApi, type PortalGym } from '@/api/adminPortal';
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
  SearchField,
  StatusBadge,
} from './shared';
import { formatDate, shortId, text } from './format';
import { useDebounced, usePortalAction, usePortalList } from './usePortalList';

const ACCESS_OPTIONS = [
  { value: 'all', label: 'Any access' },
  { value: 'free', label: 'Free' },
  { value: 'subscription', label: 'Subscription' },
  { value: 'paid', label: 'Paid' },
  { value: 'hybrid', label: 'Hybrid' },
];

const CATEGORY_OPTIONS = [
  { value: 'all', label: 'Any category' },
  { value: 'gym', label: 'Gym' },
  { value: 'studio', label: 'Studio' },
  { value: 'crossfit', label: 'CrossFit' },
  { value: 'yoga', label: 'Yoga' },
  { value: 'pilates', label: 'Pilates' },
  { value: 'martial_arts', label: 'Martial arts' },
  { value: 'climbing', label: 'Climbing' },
];

const VERIFIED_OPTIONS = [
  { value: 'all', label: 'Any verification' },
  { value: 'true', label: 'Verified' },
  { value: 'false', label: 'Unverified' },
];

const boolOrUndef = (v: string) => (v === 'all' ? undefined : v === 'true');

export default function AdminGyms() {
  const [query, setQuery] = useState('');
  const [access, setAccess] = useState('all');
  const [category, setCategory] = useState('all');
  const [verified, setVerified] = useState('all');
  const [expanded, setExpanded] = useState<string | null>(null);
  const debouncedQuery = useDebounced(query);
  const action = usePortalAction();

  const filters = useMemo(
    () => ({
      q: debouncedQuery.trim() || undefined,
      access_type: access,
      category,
      is_verified: boolOrUndef(verified),
    }),
    [debouncedQuery, access, category, verified],
  );

  const fetcher = useCallback((params: Record<string, unknown>) => adminPortalApi.getGyms(params as never), []);
  const { items, count, page, pageCount, loading, error, reload, goToPage } = usePortalList<PortalGym>(fetcher, filters);

  const toggle = useCallback(
    async (gym: PortalGym) => {
      const id = gym.id;
      if (!id) return;
      const next = gym.is_active === false;
      const ok = await action.run(
        id,
        () => adminPortalApi.updateGym(id, { is_active: next }),
        { success: `${text(gym.name, 'Gym')} is now ${next ? 'active' : 'inactive'}.`, failure: 'Failed to update gym.' },
      );
      if (ok) reload(true);
    },
    [action, reload],
  );

  const setVerification = useCallback(
    async (gym: PortalGym, next: boolean) => {
      const id = gym.id;
      if (!id) return;
      const ok = await action.run(
        id,
        () => adminPortalApi.updateGym(id, { is_verified: next }),
        { success: `${text(gym.name, 'Gym')} ${next ? 'marked verified' : 'verification removed'}.`, failure: 'Failed to update verification.' },
      );
      if (ok) reload(true);
    },
    [action, reload],
  );

  if (loading && !items.length) return <AdminSkeleton />;
  if (error && !items.length) return <AdminErrorState message={error} onRetry={() => reload()} />;

  const totalMembers = items.reduce((sum, g) => sum + (typeof g.member_count === 'number' ? g.member_count : 0), 0);

  return (
    <div className="space-y-6 pb-8">
      <AdminPageHeader
        title="Gyms"
        description="Studios, gyms and training spaces. Member counts only — the console never loads a member roster."
        onRefresh={() => reload()}
        refreshing={loading}
      />

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <AdminStatCard label="Matching gyms" value={count.toLocaleString()} />
        <AdminStatCard label="Members on this page" value={totalMembers.toLocaleString()} sub="count only" />
        <AdminStatCard label="Unverified" value={items.filter((g) => g.is_verified !== true).length} />
        <AdminStatCard label="Inactive" value={items.filter((g) => g.is_active === false).length} />
      </div>

      <Card className="p-4 flex flex-wrap items-center gap-2">
        <SearchField value={query} onChange={setQuery} label="Search gyms" placeholder="Name, handle, city…" />
        <div className="flex flex-wrap items-center gap-2 ml-auto">
          <FilterSelect label="Access" value={access} options={ACCESS_OPTIONS} onChange={setAccess} />
          <FilterSelect label="Category" value={category} options={CATEGORY_OPTIONS} onChange={setCategory} />
          <FilterSelect label="Verification" value={verified} options={VERIFIED_OPTIONS} onChange={setVerified} />
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
        <AdminEmptyState icon={<Dumbbell size={32} />} title={count === 0 ? 'No gyms match the current filters.' : 'No gyms on this page.'} />
      ) : (
        <div className="space-y-2">
          {items.map((gym, index) => {
            const key = gym.id || `gym-${index}`;
            const isOpen = expanded === key;
            const busy = action.actingId === key;
            return (
              <Card key={key} className="p-4">
                <div className="flex flex-wrap items-start gap-3">
                  <div className="flex-1 min-w-0">
                    <div className="flex flex-wrap items-center gap-2">
                      <span className="text-sm font-semibold truncate">{text(gym.name, 'Unnamed gym')}</span>
                      <StatusBadge status={gym.category} />
                      <StatusBadge status={gym.access_type} />
                      <BooleanBadge value={gym.is_verified} trueLabel="Verified" falseLabel="Unverified" />
                      <BooleanBadge value={gym.is_active} trueLabel="Active" falseLabel="Inactive" />
                    </div>
                    <p className="text-xs text-buddy-text-secondary mt-1">
                      @{text(gym.handle)} · {text(gym.location_city)}{gym.location_country ? `, ${gym.location_country}` : ''}
                    </p>
                    <p className="text-[11px] text-buddy-text-secondary mt-0.5 flex items-center gap-1.5">
                      <Users size={11} /> {typeof gym.member_count === 'number' ? gym.member_count.toLocaleString() : '—'} members
                      <span>· {shortId(gym.id)} · created {formatDate(gym.created_at)}</span>
                    </p>
                  </div>
                  <div className="flex items-center gap-2 flex-shrink-0">
                    <Button variant="ghost" size="sm" onClick={() => setExpanded(isOpen ? null : key)}>Details</Button>
                    {gym.id && (
                      <>
                        <Button
                          variant="outline"
                          size="sm"
                          disabled={busy}
                          onClick={() => setVerification(gym, gym.is_verified !== true)}
                        >
                          {gym.is_verified === true ? 'Unverify' : 'Verify'}
                        </Button>
                        <Button
                          variant={gym.is_active === false ? 'outline' : 'destructive'}
                          size="sm"
                          disabled={busy}
                          onClick={() => toggle(gym)}
                        >
                          {gym.is_active === false ? 'Activate' : 'Deactivate'}
                        </Button>
                      </>
                    )}
                  </div>
                </div>
                {isOpen && (
                  <div className="mt-3 pt-3 border-t border-buddy-surface grid grid-cols-1 sm:grid-cols-2 gap-x-6">
                    <DataRow label="Gym ID">{text(gym.id)}</DataRow>
                    <DataRow label="Handle">{text(gym.handle)}</DataRow>
                    <DataRow label="Subscription">{text(gym.subscription_type)}</DataRow>
                    <DataRow label="Verification status">{text(gym.verification_status)}</DataRow>
                    <DataRow label="Owner">{text(gym.owner)}</DataRow>
                    <DataRow label="Members (count only)">{typeof gym.member_count === 'number' ? gym.member_count : '—'}</DataRow>
                  </div>
                )}
              </Card>
            );
          })}
        </div>
      )}

      <AdminPagination page={page} pageCount={pageCount} count={count} onPage={goToPage} busy={loading} />
      <p className="text-[11px] text-buddy-text-secondary text-center flex items-center justify-center gap-1.5">
        <Search size={12} /> Community privacy: gym rosters are never exposed to the admin API.
      </p>
    </div>
  );
}