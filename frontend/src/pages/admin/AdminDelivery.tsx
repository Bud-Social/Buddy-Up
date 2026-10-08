import { useCallback, useMemo, useState } from 'react';
import { Bike, CheckCircle2, ClipboardCheck, Users, XCircle } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { adminPortalApi, type PortalDeliveryApplication, type PortalDeliveryPersonnel } from '@/api/adminPortal';
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
  { value: 'personnel', label: 'Personnel' },
  { value: 'applications', label: 'Applications' },
] as const;
type Tab = (typeof TABS)[number]['value'];

const STATUS_OPTIONS = [
  { value: 'all', label: 'Any status' },
  { value: 'active', label: 'Active' },
  { value: 'inactive', label: 'Inactive' },
  { value: 'suspended', label: 'Suspended' },
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

export default function AdminDelivery() {
  const [tab, setTab] = useState<Tab>('personnel');
  const [query, setQuery] = useState('');
  const [status, setStatus] = useState('all');
  const [appStatus, setAppStatus] = useState('all');
  const [expanded, setExpanded] = useState<string | null>(null);
  const [review, setReview] = useState<{ id: string; decision: 'approved' | 'rejected' } | null>(null);
  const debouncedQuery = useDebounced(query);
  const action = usePortalAction();

  const personnelFilters = useMemo(
    () => ({ q: debouncedQuery.trim() || undefined, status }),
    [debouncedQuery, status],
  );
  const appFilters = useMemo(
    () => ({ q: debouncedQuery.trim() || undefined, status: appStatus }),
    [debouncedQuery, appStatus],
  );

  const personnelFetcher = useCallback((params: Record<string, unknown>) => adminPortalApi.getDeliveryPersonnel(params as never), []);
  const appFetcher = useCallback((params: Record<string, unknown>) => adminPortalApi.getDeliveryApplications(params as never), []);

  const personnel = usePortalList<PortalDeliveryPersonnel>(personnelFetcher, personnelFilters);
  const apps = usePortalList<PortalDeliveryApplication>(appFetcher, appFilters);

  const activeList = tab === 'personnel' ? personnel : apps;

  const submitReview = useCallback(
    async (application: PortalDeliveryApplication, decision: 'approved' | 'rejected', reason: string) => {
      const id = application.id;
      if (!id) return;
      const ok = await action.run(
        id,
        () => adminPortalApi.updateDeliveryApplication(id, { status: decision, reason }),
        { success: `Delivery application ${decision}.`, failure: 'Failed to review delivery application.' },
      );
      setReview(null);
      if (ok) apps.reload(true);
    },
    [action, apps],
  );

  if (activeList.error && !activeList.items.length) return <AdminErrorState message={activeList.error} onRetry={() => activeList.reload()} />;
  if (activeList.loading && !activeList.items.length) return <AdminSkeleton />;

  const pendingApps = apps.items.filter((a) => APP_PENDING.includes(String(a.status))).length;
  const deliveries = personnel.items.reduce((n, p) => n + (p.completed_deliveries ?? 0), 0);

  return (
    <div className="space-y-6 pb-8">
      <AdminPageHeader
        title="Delivery Personnel"
        description="Riders on the platform and the applications queue for new ones."
        onRefresh={() => activeList.reload()}
        refreshing={activeList.loading}
      />

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <AdminStatCard label="Personnel" value={personnel.count.toLocaleString()} />
        <AdminStatCard label="Deliveries on this page" value={deliveries.toLocaleString()} />
        <AdminStatCard label="Applications pending" value={pendingApps} sub={`${apps.count} total`} />
        <AdminStatCard label="Unverified personnel" value={personnel.items.filter((p) => p.is_verified !== true).length} />
      </div>

      <Card className="p-4 space-y-3">
        <div className="flex flex-wrap items-center gap-2">
          <FilterChips options={TABS.map((t) => ({ value: t.value, label: t.label }))} value={tab} onChange={(v) => setTab(v as Tab)} />
          <div className="ml-auto">
            <SearchField value={query} onChange={setQuery} label="Search delivery personnel" placeholder="Name, phone, plate…" />
          </div>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          {tab === 'personnel' ? (
            <FilterSelect label="Personnel status" value={status} options={STATUS_OPTIONS} onChange={setStatus} />
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

      {tab === 'personnel' && (
        personnel.items.length === 0 ? (
          <AdminEmptyState icon={<Bike size={32} />} title={personnel.count === 0 ? 'No delivery personnel match the current filters.' : 'No personnel on this page.'} />
        ) : (
          <div className="space-y-2">
            {personnel.items.map((person, index) => {
              const key = person.id || `person-${index}`;
              const isOpen = expanded === key;
              return (
                <Card key={key} className="p-4">
                  <div className="flex flex-wrap items-start gap-3">
                    <div className="flex-1 min-w-0">
                      <div className="flex flex-wrap items-center gap-2">
                        <span className="text-sm font-semibold truncate">{text(person.display_name || person.user, 'Unnamed rider')}</span>
                        <StatusBadge status={person.status} />
                        <BooleanBadge value={person.is_verified} trueLabel="Verified" falseLabel="Unverified" />
                        <BooleanBadge value={person.is_active} trueLabel="Active" falseLabel="Inactive" />
                      </div>
                      <p className="text-xs text-buddy-text-secondary mt-1">
                        {text(person.phone)} · {text(person.station_name || person.station)}
                      </p>
                      <p className="text-[11px] text-buddy-text-secondary mt-0.5">
                        {text(person.vehicle_type)} {text(person.vehicle_plate)} · {person.completed_deliveries ?? 0} deliveries
                        {typeof person.rating === 'number' ? ` · ${person.rating.toFixed(1)}★` : ''} · {shortId(person.id)}
                      </p>
                    </div>
                    <Button variant="ghost" size="sm" className="flex-shrink-0" onClick={() => setExpanded(isOpen ? null : key)}>Details</Button>
                  </div>
                  {isOpen && (
                    <div className="mt-3 pt-3 border-t border-buddy-surface grid grid-cols-1 sm:grid-cols-2 gap-x-6">
                      <DataRow label="Personnel ID">{text(person.id)}</DataRow>
                      <DataRow label="User">{text(person.user)}</DataRow>
                      <DataRow label="Station">{text(person.station_name || person.station)}</DataRow>
                      <DataRow label="Deliveries">{typeof person.completed_deliveries === 'number' ? person.completed_deliveries : '—'}</DataRow>
                      <DataRow label="Rating">{typeof person.rating === 'number' ? person.rating.toFixed(2) : '—'}</DataRow>
                      <DataRow label="Onboarded">{formatDate(person.created_at)}</DataRow>
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
            icon={<ClipboardCheck size={32} />}
            title={apps.count === 0 ? 'No delivery applications yet.' : 'No applications on this page.'}
            hint="Applications appear here when someone applies to deliver with BuddyUp."
          />
        ) : (
          <div className="space-y-2">
            {apps.items.map((application, index) => {
              const key = application.id || `delivery-app-${index}`;
              const isPending = APP_PENDING.includes(String(application.status));
              const busy = action.actingId === key;
              return (
                <Card key={key} className="p-4">
                  <div className="flex flex-wrap items-start gap-3">
                    <div className="flex-1 min-w-0">
                      <div className="flex flex-wrap items-center gap-2">
                        <span className="text-sm font-semibold truncate">{text(application.applicant_display_name || application.applicant, 'Applicant')}</span>
                        <StatusBadge status={application.status} />
                      </div>
                      <p className="text-xs text-buddy-text-secondary mt-1 break-all">
                        {text(application.applicant_email)} · {text(application.phone)}
                      </p>
                      <p className="text-[11px] text-buddy-text-secondary mt-0.5">
                        {text(application.station_name || application.station)} · {text(application.vehicle_type)} {text(application.vehicle_plate)} · {shortId(application.id)}
                      </p>
                      <p className="text-[11px] text-buddy-text-secondary mt-0.5">Submitted {formatDate(application.created_at)}</p>
                      {application.notes && <p className="text-xs text-buddy-text-secondary mt-1.5 line-clamp-2">{application.notes}</p>}
                      {application.rejection_reason && <p className="text-[11px] text-buddy-red mt-1 break-words">Reason: {application.rejection_reason}</p>}
                      {Array.isArray(application.documents) && application.documents.length > 0 && (
                        <div className="mt-1.5 flex flex-wrap gap-2">
                          {application.documents.map((doc, i) => (
                            <a key={doc.id || i} href={doc.file_url} target="_blank" rel="noreferrer" className="text-xs text-buddy-green hover:underline">
                              {text(doc.document_type, 'Document').replace(/_/g, ' ')} — {text(doc.status)}
                            </a>
                          ))}
                        </div>
                      )}
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

      {pendingApps > 0 && tab === 'personnel' && (
        <button
          type="button"
          onClick={() => setTab('applications')}
          className="w-full text-xs text-buddy-text-secondary hover:text-buddy-text-primary flex items-center justify-center gap-1.5"
        >
          <Users size={12} /> {pendingApps} delivery application{pendingApps === 1 ? '' : 's'} awaiting review
        </button>
      )}
    </div>
  );
}