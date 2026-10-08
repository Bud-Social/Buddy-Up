import { useCallback, useMemo, useState } from 'react';
import { CheckCircle2, ClipboardList, RadioTower, XCircle } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { adminPortalApi, type PortalStation, type PortalStationApplication } from '@/api/adminPortal';
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
  FilterChips,
  FilterSelect,
  ReasonPrompt,
  SearchField,
  StatusBadge,
} from './shared';
import { formatDate, shortId, text } from './format';
import { useDebounced, usePortalAction, usePortalList } from './usePortalList';

const TABS = [
  { value: 'stations', label: 'Stations' },
  { value: 'applications', label: 'Applications' },
] as const;
type Tab = (typeof TABS)[number]['value'];

const STATUS_OPTIONS = [
  { value: 'all', label: 'Any status' },
  { value: 'active', label: 'Active' },
  { value: 'inactive', label: 'Inactive' },
  { value: 'maintenance', label: 'Maintenance' },
];

const APP_STATUS_OPTIONS = [
  { value: 'all', label: 'Any application status' },
  { value: 'pending', label: 'Pending' },
  { value: 'submitted', label: 'Submitted' },
  { value: 'under_review', label: 'Under review' },
  { value: 'approved', label: 'Approved' },
  { value: 'rejected', label: 'Rejected' },
];

const APP_PENDING = ['pending', 'submitted', 'under_review'];

export default function AdminStations() {
  const [tab, setTab] = useState<Tab>('stations');
  const [query, setQuery] = useState('');
  const [status, setStatus] = useState('all');
  const [appStatus, setAppStatus] = useState('all');
  const [expanded, setExpanded] = useState<string | null>(null);
  const [review, setReview] = useState<{ id: string; decision: 'approved' | 'rejected' } | null>(null);
  const debouncedQuery = useDebounced(query);
  const action = usePortalAction();

  const stationFilters = useMemo(
    () => ({ q: debouncedQuery.trim() || undefined, status }),
    [debouncedQuery, status],
  );
  const appFilters = useMemo(
    () => ({ q: debouncedQuery.trim() || undefined, status: appStatus }),
    [debouncedQuery, appStatus],
  );

  const stationFetcher = useCallback((params: Record<string, unknown>) => adminPortalApi.getStations(params as never), []);
  const appFetcher = useCallback((params: Record<string, unknown>) => adminPortalApi.getStationApplications(params as never), []);

  const stations = usePortalList<PortalStation>(stationFetcher, stationFilters);
  const apps = usePortalList<PortalStationApplication>(appFetcher, appFilters);

  const activeList = tab === 'stations' ? stations : apps;

  const toggleStation = useCallback(
    async (station: PortalStation) => {
      const id = station.id;
      if (!id) return;
      const next = station.is_active === false;
      const ok = await action.run(
        id,
        () => adminPortalApi.updateStation(id, { is_active: next }),
        { success: `${text(station.name, 'Station')} is now ${next ? 'active' : 'inactive'}.`, failure: 'Failed to update station.' },
      );
      if (ok) stations.reload(true);
    },
    [action, stations],
  );

  const submitReview = useCallback(
    async (application: PortalStationApplication, decision: 'approved' | 'rejected', reason: string) => {
      const id = application.id;
      if (!id) return;
      const ok = await action.run(
        id,
        () => adminPortalApi.updateStationApplication(id, { status: decision, reason }),
        { success: `Station application ${decision}.`, failure: 'Failed to review station application.' },
      );
      setReview(null);
      if (ok) apps.reload(true);
    },
    [action, apps],
  );

  if (activeList.error && !activeList.items.length) return <AdminErrorState message={activeList.error} onRetry={() => activeList.reload()} />;
  if (activeList.loading && !activeList.items.length) return <AdminSkeleton />;

  const pendingApps = apps.items.filter((a) => APP_PENDING.includes(String(a.status))).length;

  return (
    <div className="space-y-6 pb-8">
      <AdminPageHeader
        title="Stations"
        description="Pickup and dispatch stations, plus the applications to run one."
        onRefresh={() => activeList.reload()}
        refreshing={activeList.loading}
      />

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <AdminStatCard label="Stations" value={stations.count.toLocaleString()} />
        <AdminStatCard label="Active on this page" value={stations.items.filter((s) => s.is_active !== false).length} />
        <AdminStatCard label="Applications pending" value={pendingApps} sub={`${apps.count} total`} />
        <AdminStatCard label="Riders on this page" value={stations.items.reduce((n, s) => n + (s.rider_count ?? 0), 0)} />
      </div>

      <Card className="p-4 space-y-3">
        <div className="flex flex-wrap items-center gap-2">
          <FilterChips options={TABS.map((t) => ({ value: t.value, label: t.label }))} value={tab} onChange={(v) => setTab(v as Tab)} />
          <div className="ml-auto">
            <SearchField value={query} onChange={setQuery} label="Search stations" placeholder="Name, code, city…" />
          </div>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          {tab === 'stations' ? (
            <FilterSelect label="Station status" value={status} options={STATUS_OPTIONS} onChange={setStatus} />
          ) : (
            <FilterSelect label="Application status" value={appStatus} options={APP_STATUS_OPTIONS} onChange={setAppStatus} />
          )}
          {query && <Button variant="ghost" size="sm" onClick={() => setQuery('')}>Clear search</Button>}
        </div>
      </Card>

      {activeList.error && <AdminErrorBanner message={activeList.error} onRetry={() => activeList.reload()} />}
      {action.error && <AdminErrorBanner message={action.error} />}
      {action.notice && (
        <div className="bg-buddy-green/10 border border-buddy-green/20 text-buddy-green text-xs rounded-xl px-3 py-2">
          {action.notice}
        </div>
      )}

      {tab === 'stations' && (
        stations.items.length === 0 ? (
          <AdminEmptyState icon={<RadioTower size={32} />} title={stations.count === 0 ? 'No stations match the current filters.' : 'No stations on this page.'} />
        ) : (
          <div className="space-y-2">
            {stations.items.map((station, index) => {
              const key = station.id || `station-${index}`;
              const isOpen = expanded === key;
              const busy = action.actingId === key;
              return (
                <Card key={key} className="p-4">
                  <div className="flex flex-wrap items-start gap-3">
                    <div className="flex-1 min-w-0">
                      <div className="flex flex-wrap items-center gap-2">
                        <span className="text-sm font-semibold truncate">{text(station.name, 'Unnamed station')}</span>
                        <StatusBadge status={station.status} />
                        <BooleanBadge value={station.is_active} trueLabel="Active" falseLabel="Inactive" />
                        {station.code && <span className="text-[11px] font-mono text-buddy-text-secondary">{station.code}</span>}
                      </div>
                      <p className="text-xs text-buddy-text-secondary mt-1">
                        {text(station.address || station.city)}{station.country ? `, ${station.country}` : ''}
                      </p>
                      <p className="text-[11px] text-buddy-text-secondary mt-0.5">
                        {text(station.community_name || station.community)} · {station.rider_count ?? 0} riders · {shortId(station.id)}
                      </p>
                    </div>
                    <div className="flex items-center gap-2 flex-shrink-0">
                      <Button variant="ghost" size="sm" onClick={() => setExpanded(isOpen ? null : key)}>Details</Button>
                      {station.id && (
                        <Button variant={station.is_active === false ? 'outline' : 'destructive'} size="sm" disabled={busy} onClick={() => toggleStation(station)}>
                          {station.is_active === false ? 'Activate' : 'Deactivate'}
                        </Button>
                      )}
                    </div>
                  </div>
                  {isOpen && (
                    <div className="mt-3 pt-3 border-t border-buddy-surface grid grid-cols-1 sm:grid-cols-2 gap-x-6">
                      <DataRow label="Station ID">{text(station.id)}</DataRow>
                      <DataRow label="Code">{text(station.code)}</DataRow>
                      <DataRow label="City">{text(station.city)}</DataRow>
                      <DataRow label="Latitude">{typeof station.latitude === 'number' ? station.latitude : '—'}</DataRow>
                      <DataRow label="Longitude">{typeof station.longitude === 'number' ? station.longitude : '—'}</DataRow>
                      <DataRow label="Created">{formatDate(station.created_at)}</DataRow>
                    </div>
                  )}
                </Card>
              );
            })}
          </div>
        )
      )}

      {tab === 'applications' && (
        apps.items.length === 0 ? (
          <AdminEmptyState
            icon={<ClipboardList size={32} />}
            title={apps.count === 0 ? 'No station applications yet.' : 'No applications on this page.'}
            hint="Applications appear here when a user asks to open a new dispatch station."
          />
        ) : (
          <div className="space-y-2">
            {apps.items.map((application, index) => {
              const key = application.id || `app-${index}`;
              const isPending = APP_PENDING.includes(String(application.status));
              const busy = action.actingId === key;
              return (
                <Card key={key} className="p-4">
                  <div className="flex flex-wrap items-start gap-3">
                    <div className="flex-1 min-w-0">
                      <div className="flex flex-wrap items-center gap-2">
                        <span className="text-sm font-semibold truncate">{text(application.station_name || application.station, 'Station application')}</span>
                        <StatusBadge status={application.status} />
                      </div>
                      <p className="text-xs text-buddy-text-secondary mt-1">
                        Applicant {text(application.applicant_display_name || application.applicant)} · {shortId(application.id)}
                      </p>
                      <p className="text-[11px] text-buddy-text-secondary mt-0.5">
                        {text(application.station_code)} · submitted {formatDate(application.created_at)}
                        {application.reviewed_at ? ` · reviewed ${formatDate(application.reviewed_at)}` : ''}
                      </p>
                      {application.notes && <p className="text-xs text-buddy-text-secondary mt-1.5 line-clamp-2">{application.notes}</p>}
                      {application.rejection_reason && <p className="text-[11px] text-buddy-red mt-1 break-words">Reason: {application.rejection_reason}</p>}
                    </div>
                    <div className="flex items-center gap-2 flex-shrink-0">
                      {isPending ? (
                        <>
                          <Button variant="outline" size="sm" disabled={busy} onClick={() => setReview({ id: key, decision: 'approved' })}>
                            <CheckCircle2 size={14} className="mr-1" /> Approve
                          </Button>
                          <Button variant="destructive" size="sm" disabled={busy} onClick={() => setReview({ id: key, decision: 'rejected' })}>
                            <XCircle size={14} className="mr-1" /> Reject
                          </Button>
                        </>
                      ) : (
                        <span className="text-xs text-buddy-text-secondary">No action</span>
                      )}
                    </div>
                  </div>
                  <ReasonPrompt
                    open={review?.id === key}
                    action={review?.id === key ? review.decision : 'approved'}
                    submitLabel={review?.decision === 'rejected' ? 'Reject application' : 'Approve application'}
                    placeholder={review?.decision === 'rejected' ? 'Explain what is missing — the applicant sees this.' : 'Optional internal note.'}
                    busy={busy}
                    onSubmit={(reason) => submitReview(application, review?.decision || 'approved', reason)}
                    onCancel={() => setReview(null)}
                  />
                </Card>
              );
            })}
          </div>
        )
      )}

      <AdminPagination page={activeList.page} pageCount={activeList.pageCount} count={activeList.count} onPage={activeList.goToPage} busy={activeList.loading} />
    </div>
  );
}