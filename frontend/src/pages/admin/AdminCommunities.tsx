import { useCallback, useMemo, useState } from 'react';
import { Eye, EyeOff, Search, Users, UsersRound } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { adminPortalApi, type PortalCommunity } from '@/api/adminPortal';
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
} from './shared';
import { formatDate, shortId, text } from './format';
import { useDebounced, usePortalList } from './usePortalList';

const VISIBILITY_OPTIONS = [
  { value: 'all', label: 'Public and private' },
  { value: 'true', label: 'Public only' },
  { value: 'false', label: 'Private only' },
];

export default function AdminCommunities() {
  const [query, setQuery] = useState('');
  const [isPublic, setIsPublic] = useState('all');
  const [expanded, setExpanded] = useState<string | null>(null);
  // Detail is fetched on first expand so the row can show fresh counts and
  // fields the list omits, without eighteen calls on page load.
  const [details, setDetails] = useState<Record<string, PortalCommunity>>({});
  const [detailLoading, setDetailLoading] = useState<string | null>(null);
  const debouncedQuery = useDebounced(query);

  const toggleDetails = useCallback(async (community: PortalCommunity, key: string) => {
    if (expanded === key) {
      setExpanded(null);
      return;
    }
    setExpanded(key);
    if (!community.id || details[key]) return;
    setDetailLoading(key);
    try {
      const res = await adminPortalApi.getCommunity(community.id);
      if (res?.data) setDetails((prev) => ({ ...prev, [key]: res.data }));
    } catch {
      // Keep rendering the list row's fields; the detail call is an enhancement.
    } finally {
      setDetailLoading(null);
    }
  }, [expanded, details]);

  const filters = useMemo(
    () => ({
      q: debouncedQuery.trim() || undefined,
      is_public: isPublic === 'all' ? undefined : isPublic === 'true',
    }),
    [debouncedQuery, isPublic],
  );

  const fetcher = useCallback((params: Record<string, unknown>) => adminPortalApi.getCommunities(params as never), []);
  const { items, count, page, pageCount, loading, error, reload, goToPage } = usePortalList<PortalCommunity>(fetcher, filters);

  if (loading && !items.length) return <AdminSkeleton />;
  if (error && !items.length) return <AdminErrorState message={error} onRetry={() => reload()} />;

  const totalMembers = items.reduce((sum, c) => sum + (typeof c.member_count === 'number' ? c.member_count : 0), 0);
  const privateCount = items.filter((c) => c.is_public === false).length;

  return (
    <div className="space-y-6 pb-8">
      <AdminPageHeader
        title="Communities"
        description="Group spaces on the platform. Member counts only — individual members are never listed here."
        onRefresh={() => reload()}
        refreshing={loading}
      />

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <AdminStatCard label="Matching communities" value={count.toLocaleString()} />
        <AdminStatCard label="Members on this page" value={totalMembers.toLocaleString()} sub="count only" />
        <AdminStatCard label="Private" value={privateCount} />
        <AdminStatCard label="On this page" value={items.length} />
      </div>

      <Card className="p-4 flex flex-wrap items-center gap-2">
        <SearchField value={query} onChange={setQuery} label="Search communities" placeholder="Name, slug…" />
        <div className="ml-auto">
          <FilterSelect label="Visibility" value={isPublic} options={VISIBILITY_OPTIONS} onChange={setIsPublic} />
        </div>
      </Card>

      {error && <AdminErrorBanner message={error} onRetry={() => reload()} />}

      {items.length === 0 ? (
        <AdminEmptyState icon={<UsersRound size={32} />} title={count === 0 ? 'No communities match the current filters.' : 'No communities on this page.'} />
      ) : (
        <div className="space-y-2">
          {items.map((community, index) => {
            const key = community.id || `community-${index}`;
            const isOpen = expanded === key;
            const detail = details[key] ?? community;
            return (
              <Card key={key} className="p-4">
                <div className="flex flex-wrap items-start gap-3">
                  <div className="flex-1 min-w-0">
                    <div className="flex flex-wrap items-center gap-2">
                      <span className="text-sm font-semibold truncate">{text(community.group_name, 'Unnamed community')}</span>
                      {community.is_public === true ? (
                        <BooleanBadge value={true} trueLabel="Public" />
                      ) : (
                        <span className="inline-flex items-center gap-1 text-[11px] font-semibold px-2 py-0.5 rounded-full bg-slate-400/20 text-slate-300">
                          <EyeOff size={10} /> Private
                        </span>
                      )}
                      {community.is_community === false && (
                        <span className="text-[11px] text-buddy-text-secondary">not a community</span>
                      )}
                    </div>
                    <p className="text-xs text-buddy-text-secondary mt-1">
                      {text(community.origin, 'unknown origin')} · {shortId(community.id)}
                    </p>
                    {community.description && <p className="text-xs text-buddy-text-secondary mt-1.5 line-clamp-2">{community.description}</p>}
                    <p className="text-[11px] text-buddy-text-secondary mt-1 flex items-center gap-1.5">
                      <Users size={11} /> {typeof community.member_count === 'number' ? community.member_count.toLocaleString() : '—'} members
                      <span>· {typeof community.post_count === 'number' ? community.post_count : '—'} posts · created {formatDate(community.created_at)}</span>
                    </p>
                  </div>
                  <Button variant="ghost" size="sm" className="flex-shrink-0" onClick={() => { void toggleDetails(community, key); }}>
                    <Eye size={14} className="mr-1" /> Details
                  </Button>
                </div>
                {isOpen && (
                  <div className="mt-3 pt-3 border-t border-buddy-surface">
                    {detailLoading === key && (
                      <p className="text-[11px] text-buddy-text-secondary mb-2">Loading full detail…</p>
                    )}
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-x-6">
                      <DataRow label="Community ID">{text(detail.id)}</DataRow>
                      <DataRow label="Origin">{text(detail.origin)}</DataRow>
                      <DataRow label="Created by">{text(detail.created_by_username)}</DataRow>
                      <DataRow label="Members (count only)">
                        {typeof detail.member_count === 'number' ? detail.member_count : '—'}
                      </DataRow>
                      <DataRow label="Posts">{typeof detail.post_count === 'number' ? detail.post_count : '—'}</DataRow>
                      <DataRow label="Gym">{detail.gym_handle ? `/${detail.gym_handle}` : '—'}</DataRow>
                      <DataRow label="Invite code">{text(detail.invite_code)}</DataRow>
                      <DataRow label="Last activity">{formatDate(detail.last_message_at)}</DataRow>
                    </div>
                  </div>
                )}
              </Card>
            );
          })}
        </div>
      )}

      <AdminPagination page={page} pageCount={pageCount} count={count} onPage={goToPage} busy={loading} />
      <p className="text-[11px] text-buddy-text-secondary text-center flex items-center justify-center gap-1.5">
        <Search size={12} /> Private communities are visible to staff for moderation, but their membership is never exposed.
      </p>
    </div>
  );
}