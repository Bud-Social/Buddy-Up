import { useCallback, useMemo, useState } from 'react';
import { Download, History, ScrollText, ArrowRight } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import {
  adminPortalApi,
  adminPortalErrorMessage,
  auditExportUrl,
  portalListItems,
  type AuditLogEntry,
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
  SearchField,
  StatusBadge,
} from './shared';
import { formatDate, shortId, text } from './format';
import { useDebounced, usePortalList } from './usePortalList';

/**
 * The audit trail.
 *
 * Three questions, three surfaces:
 *
 * 1. *What happened?* — the filtered list.
 * 2. *What exactly changed?* — a row's full `before` / `after`, which the list
 *    row deliberately does not carry: a summary line that showed the delta would
 *    be unreadable, and one that omitted it would make the list useless for an
 *    incident review.
 * 3. *What happened to this one thing, in order?* — the timeline, oldest first,
 *    because the question is always "what sequence led here".
 */

const EMPTY_FILTERS = { action: '', target_type: '', target_id: '', actor: '', date_from: '', date_to: '' };

/** Pretty-printed JSON in a scroll box, or a placeholder for a null delta. */
function Delta({ label, value }: { label: string; value: Record<string, unknown> | null | undefined }) {
  const empty = !value || Object.keys(value).length === 0;
  return (
    <div className="min-w-0">
      <p className="text-xs font-semibold mb-1">{label}</p>
      {empty ? (
        <p className="text-xs text-buddy-text-secondary">Nothing recorded.</p>
      ) : (
        <pre className="text-[11px] font-mono bg-buddy-surface-raised border border-buddy-surface rounded-xl p-3 overflow-x-auto max-h-64 whitespace-pre-wrap break-words">
          {JSON.stringify(value, null, 2)}
        </pre>
      )}
    </div>
  );
}

export default function AdminAudit() {
  const [raw, setRaw] = useState(EMPTY_FILTERS);
  const [selected, setSelected] = useState<AuditLogEntry | null>(null);
  const [detailError, setDetailError] = useState('');

  // Timeline is a separate query: the API requires `target_type`, and the list
  // must not fail for a user who has not typed one.
  const [timelineTarget, setTimelineTarget] = useState({ target_type: '', target_id: '' });
  const [timeline, setTimeline] = useState<AuditLogEntry[]>([]);
  const [timelineLoading, setTimelineLoading] = useState(false);
  const [timelineError, setTimelineError] = useState('');

  const action = useDebounced(raw.action);
  const targetType = useDebounced(raw.target_type);
  const targetId = useDebounced(raw.target_id);
  const actor = useDebounced(raw.actor);
  const dateFrom = useDebounced(raw.date_from);
  const dateTo = useDebounced(raw.date_to);

  const filters = useMemo(
    () => ({
      action: action.trim() || undefined,
      target_type: targetType.trim() || undefined,
      target_id: targetId.trim() || undefined,
      actor: actor.trim() || undefined,
      date_from: dateFrom.trim() || undefined,
      date_to: dateTo.trim() || undefined,
    }),
    [action, targetType, targetId, actor, dateFrom, dateTo],
  );

  const fetcher = useCallback(
    (params: Record<string, unknown>) => adminPortalApi.getAuditLog(params as never),
    [],
  );
  const { items, count, page, pageCount, loading, error, reload, goToPage } =
    usePortalList<AuditLogEntry>(fetcher, filters);

  // Selecting a row re-reads it from the detail endpoint rather than trusting
  // the list row, so the before/after shown is the full delta and not whatever
  // a future list serializer happens to include.
  const openRow = useCallback(async (row: AuditLogEntry) => {
    setSelected(row);
    setDetailError('');
    if (!row.id) return;
    try {
      const res = await adminPortalApi.getAuditEntry(row.id);
      if (res?.data) setSelected(res.data);
    } catch (e) {
      setDetailError(adminPortalErrorMessage(e, 'Failed to load the full record.'));
    }
  }, []);

  const loadTimeline = useCallback(async () => {
    const type = timelineTarget.target_type.trim();
    if (!type) {
      setTimeline([]);
      setTimelineError('');
      return;
    }
    setTimelineLoading(true);
    setTimelineError('');
    try {
      const res = await adminPortalApi.getAuditTimeline({
        target_type: type,
        target_id: timelineTarget.target_id.trim() || undefined,
      });
      setTimeline(portalListItems<AuditLogEntry>(res?.data));
    } catch (e) {
      setTimeline([]);
      setTimelineError(adminPortalErrorMessage(e, 'Failed to load the timeline.'));
    } finally {
      setTimelineLoading(false);
    }
  }, [timelineTarget]);

  const exportCsv = useCallback(() => {
    // The endpoint sets `Content-Disposition: attachment`, so this is a download
    // rather than a tab. It carries the active filters, so what lands on disk is
    // exactly what the operator was looking at.
    window.open(auditExportUrl(filters), '_blank', 'noopener,noreferrer');
  }, [filters]);

  const filtered = Object.values(raw).some(Boolean);

  if (loading && !items.length) return <AdminSkeleton />;
  if (error && !items.length) return <AdminErrorState message={error} onRetry={() => reload()} />;

  return (
    <div className="space-y-6 pb-8">
      <AdminPageHeader
        title="Audit"
        description="Every mutating staff action, with the before and after that produced it."
        onRefresh={() => reload()}
        refreshing={loading}
        actions={
          <Button variant="outline" size="sm" onClick={exportCsv}>
            <Download size={14} className="mr-1" /> Export CSV
          </Button>
        }
      />

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <AdminStatCard label="Matching entries" value={count.toLocaleString()} />
        <AdminStatCard label="On this page" value={items.length} />
        <AdminStatCard
          label="Distinct actors here"
          value={new Set(items.map((r) => r.actor_email).filter(Boolean)).size}
        />
        <AdminStatCard
          label="Distinct verbs here"
          value={new Set(items.map((r) => r.action).filter(Boolean)).size}
        />
      </div>

      <Card className="p-4 space-y-3">
        <p className="text-xs font-semibold">Filters</p>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
          <FilterInput
            label="Action"
            value={raw.action}
            placeholder="users.suspend"
            hint="Dotted lowercase verb"
            onChange={(v) => setRaw((f) => ({ ...f, action: v }))}
          />
          <FilterInput
            label="Target type"
            value={raw.target_type}
            placeholder="user"
            hint="Lowercase word"
            onChange={(v) => setRaw((f) => ({ ...f, target_type: v }))}
          />
          <FilterInput
            label="Target id"
            value={raw.target_id}
            placeholder="00000000-…"
            onChange={(v) => setRaw((f) => ({ ...f, target_id: v }))}
          />
          <FilterInput
            label="Actor"
            value={raw.actor}
            placeholder="User id"
            hint="Staff user id"
            onChange={(v) => setRaw((f) => ({ ...f, actor: v }))}
          />
          <FilterInput
            label="From"
            value={raw.date_from}
            placeholder="YYYY-MM-DD"
            onChange={(v) => setRaw((f) => ({ ...f, date_from: v }))}
          />
          <FilterInput
            label="To"
            value={raw.date_to}
            placeholder="YYYY-MM-DD"
            onChange={(v) => setRaw((f) => ({ ...f, date_to: v }))}
          />
        </div>
        {filtered && (
          <Button variant="ghost" size="sm" onClick={() => setRaw(EMPTY_FILTERS)}>Clear filters</Button>
        )}
        <p className="text-[11px] text-buddy-text-secondary">
          A malformed filter is rejected by the API with a message naming the expected grammar — that
          message is shown below rather than swallowed into an empty list.
        </p>
      </Card>

      {error && <AdminErrorBanner message={error} onRetry={() => reload()} />}

      {selected && (
        <Card className="p-4 space-y-3">
          <div className="flex flex-wrap items-start justify-between gap-3">
            <div className="min-w-0">
              <p className="text-sm font-semibold">{text(selected.summary, text(selected.action, 'Audit entry'))}</p>
              <p className="text-[11px] text-buddy-text-secondary mt-0.5 break-all">
                {shortId(selected.id)} · {text(selected.actor_email, 'unknown actor')} · {formatDate(selected.created_at)}
              </p>
            </div>
            <Button variant="ghost" size="sm" onClick={() => { setSelected(null); setDetailError(''); }}>Close</Button>
          </div>
          {detailError && <AdminErrorBanner message={detailError} onRetry={() => openRow(selected)} />}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-x-6">
            <DataRow label="Action">{text(selected.action)}</DataRow>
            <DataRow label="Target">
              {text(selected.target_type)}{selected.target_id ? ` · ${shortId(selected.target_id)}` : ''}
            </DataRow>
            <DataRow label="Request id">{text(selected.request_id)}</DataRow>
            <DataRow label="IP address">{text(selected.ip_address)}</DataRow>
            <DataRow label="User agent">{text(selected.user_agent, '—')}</DataRow>
          </div>
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
            <Delta label="Before" value={selected.before} />
            <Delta label="After" value={selected.after} />
          </div>
        </Card>
      )}

      {items.length === 0 ? (
        <AdminEmptyState
          icon={<ScrollText size={32} />}
          title={count === 0 ? 'No audit entries match the current filters.' : 'No audit entries on this page.'}
          hint="A mistyped filter is the most common cause — the API will tell you so in the error above."
        />
      ) : (
        <div className="space-y-2">
          {items.map((row, index) => (
            <Card
              key={row.id || `audit-${index}`}
              className={`p-4 cursor-pointer transition-colors hover:bg-buddy-surface-raised ${selected?.id === row.id ? 'border-buddy-green/40' : ''}`}
              onClick={() => openRow(row)}
            >
              <div className="flex flex-wrap items-start gap-3">
                <div className="flex-1 min-w-0">
                  <div className="flex flex-wrap items-center gap-2">
                    <Badge variant="blue" label={text(row.action, 'action')} size="sm" />
                    {row.target_type && (
                      <Badge variant="silver" label={`${row.target_type}${row.target_id ? `:${shortId(row.target_id)}` : ''}`} size="sm" />
                    )}
                  </div>
                  <p className="text-sm mt-1.5 break-words">{text(row.summary, 'No summary recorded.')}</p>
                  <p className="text-[11px] text-buddy-text-secondary mt-1">
                    {text(row.actor_email, 'unknown actor')} · {formatDate(row.created_at)}
                  </p>
                </div>
                <Button variant="ghost" size="sm" className="flex-shrink-0">
                  Details <ArrowRight size={14} className="ml-1" />
                </Button>
              </div>
            </Card>
          ))}
        </div>
      )}

      <AdminPagination page={page} pageCount={pageCount} count={count} onPage={goToPage} busy={loading} />

      <Card className="p-4 space-y-3">
        <div>
          <h3 className="text-sm font-semibold flex items-center gap-1.5"><History size={14} /> Object timeline</h3>
          <p className="text-[11px] text-buddy-text-secondary mt-0.5">
            Everything that ever happened to one object, oldest first. A target type is required — a
            timeline without one is just the whole log.
          </p>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 items-end">
          <FilterInput
            label="Timeline target type"
            value={timelineTarget.target_type}
            placeholder="user"
            hint="Required — a timeline without it is the whole log"
            onChange={(v) => setTimelineTarget((t) => ({ ...t, target_type: v }))}
          />
          <FilterInput
            label="Timeline target id"
            value={timelineTarget.target_id}
            placeholder="00000000-…"
            onChange={(v) => setTimelineTarget((t) => ({ ...t, target_id: v }))}
          />
          <Button variant="outline" size="sm" onClick={loadTimeline} disabled={!timelineTarget.target_type.trim()}>
            Load timeline
          </Button>
        </div>

        {timelineError && <AdminErrorBanner message={timelineError} onRetry={loadTimeline} />}
        {timelineLoading && <AdminSkeleton rows={2} />}
        {!timelineLoading && timeline.length > 0 && (
          <ol className="space-y-2">
            {timeline.map((entry, index) => (
              <li key={entry.id || `tl-${index}`} className="flex gap-3">
                <div className="flex flex-col items-center flex-shrink-0 pt-1">
                  <span className="w-2 h-2 rounded-full bg-buddy-green" aria-hidden="true" />
                  {index < timeline.length - 1 && <span className="w-px flex-1 bg-buddy-surface-raised mt-1" aria-hidden="true" />}
                </div>
                <div className="min-w-0 pb-1">
                  <div className="flex flex-wrap items-center gap-2">
                    <StatusBadge status={entry.action} />
                    <span className="text-[11px] text-buddy-text-secondary">{formatDate(entry.created_at)}</span>
                  </div>
                  <p className="text-xs mt-1 break-words">{text(entry.summary, 'No summary recorded.')}</p>
                  <p className="text-[11px] text-buddy-text-secondary">{text(entry.actor_email, 'unknown actor')}</p>
                </div>
              </li>
            ))}
          </ol>
        )}
        {!timelineLoading && timelineTarget.target_type.trim() && timeline.length === 0 && !timelineError && (
          <p className="text-xs text-buddy-text-secondary text-center py-4">
            Nothing has been recorded against this object.
          </p>
        )}
      </Card>

      <p className="text-[11px] text-buddy-text-secondary/70">
        Exports are capped at 50,000 rows server-side and carry whatever filters are active. A CSV
        downloaded from here is a copy of the platform's own record of your staff account — treat it
        accordingly.
      </p>
    </div>
  );
}

function FilterInput({
  label,
  value,
  placeholder,
  hint,
  onChange,
}: {
  label: string;
  value: string;
  placeholder?: string;
  hint?: string;
  onChange: (value: string) => void;
}) {
  return (
    <label className="block text-xs text-buddy-text-secondary">
      <span className="mb-1 block">{label}</span>
      <SearchField value={value} onChange={onChange} label={label} placeholder={placeholder || `${label}…`} />
      {hint && <span className="mt-0.5 block text-[10px] text-buddy-text-secondary/70">{hint}</span>}
    </label>
  );
}
