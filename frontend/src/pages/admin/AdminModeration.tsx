import { useCallback, useEffect, useMemo, useState, type ReactNode } from 'react';
import {
  Award, CheckCircle2, ShieldAlert, ShieldCheck, Trash2, Undo2,
  UserCheck, UserMinus, ArrowUpRight, Ban, Clock, Mail,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import {
  adminPortalApi,
  adminPortalErrorMessage,
  moderationActionApplied,
  type ContentFlagRow,
  type Commendation,
  type ModerationActionRow,
  type ModerationReportRow,
  type PendingApprovalRow,
  type PortalUser,
  type ResolvedContent,
} from '@/api/adminPortal';
import {
  AdminEmptyState,
  AdminErrorBanner,
  AdminPageHeader,
  AdminPagination,
  AdminSkeleton,
  AdminStatCard,
  DataRow,
  FilterChips,
  ReasonPrompt,
  SearchField,
  StatusBadge,
} from './shared';
import { formatDate, formatDuration, shortId, slaState, text } from './format';
import { useDebounced, usePortalAction, usePortalList } from './usePortalList';

/**
 * Moderator dashboard.
 *
 * The organising idea is that a moderator's two beliefs about this console must
 * never be wrong in the same direction:
 *
 * 1. *Something I did took effect.* A warning applies at once; a suspension or
 *    a ban does not. `POST /moderation/actions/` answers **202** with
 *    `applied: false` for the latter, and a 2xx that means "nothing happened" is
 *    exactly the kind of response a naive client reports as success. Every
 *    mutation here reads {@link moderationActionApplied} and renders the pending
 *    state in the server's own words.
 * 2. *Somebody else has to agree.* Those same requests appear in the pending
 *    approvals section so a moderator can see their request is still waiting,
 *    rather than assuming it failed and raising it again.
 */

type Tab = 'reports' | 'flags' | 'pending' | 'actions' | 'commendations';

const TABS: Array<{ value: Tab; label: string }> = [
  { value: 'reports', label: 'Reports' },
  { value: 'flags', label: 'AI flags' },
  { value: 'pending', label: 'Pending approvals' },
  { value: 'actions', label: 'Action ledger' },
  { value: 'commendations', label: 'Commendations' },
];

const REPORT_STATUS_OPTIONS = [
  { value: 'all', label: 'Any status' },
  { value: 'open', label: 'Open' },
  { value: 'investigating', label: 'Investigating' },
  { value: 'resolved', label: 'Resolved' },
  { value: 'dismissed', label: 'Dismissed' },
];

const ASSIGNMENT_OPTIONS = [
  { value: 'all', label: 'Anyone' },
  { value: 'me', label: 'Assigned to me' },
  { value: 'unassigned', label: 'Unassigned' },
];

const ACTION_OPTIONS = [
  { value: 'all', label: 'Any action' },
  { value: 'warning', label: 'Warning' },
  { value: 'user_suspended', label: 'User suspended' },
  { value: 'user_banned', label: 'User banned' },
  { value: 'content_removed', label: 'Content removed' },
  { value: 'action_reversed', label: 'Action reversed' },
];

/** Only these four have a reversal path; the rest are server-owned outcomes. */
const REVERSIBLE_ACTIONS = new Set(['warning', 'user_suspended', 'user_banned', 'content_removed']);

const DISCIPLINARY_ACTIONS = [
  { value: 'warning', label: 'Warning — applies immediately', needsDuration: false },
  { value: 'user_suspended', label: 'Suspension — needs a second approver', needsDuration: true },
  { value: 'user_banned', label: 'Ban — needs a second approver, permanent', needsDuration: false },
];

const COMMENDATION_CATEGORIES = [
  { value: 'excellent_service', label: 'Excellent Service' },
  { value: 'helpful', label: 'Helpful' },
  { value: 'reliable', label: 'Reliable' },
  { value: 'community_builder', label: 'Community Builder' },
  { value: 'above_and_beyond', label: 'Above and Beyond' },
  { value: 'resolved_issue', label: 'Resolved Issue' },
];

const REASON_HELP: Record<string, string> = {
  medical_claim: 'Content claims a meal plan or programme treats, cures, or manages a medical condition. Non-practitioners must never make these claims.',
  undisclosed_sponsor: 'Content appears promotional (gifted/paid) without a clear, prominent disclosure. Hidden disclosures count as non-disclosure.',
  adult_ungated: 'Adult content was posted outside the Mature category. Move it behind the age gate or remove it.',
};

function SlaBadge({ dueAt, breached }: { dueAt: unknown; breached: unknown }) {
  const sla = slaState(dueAt, breached);
  return (
    <Badge
      variant={sla.variant}
      label={sla.overdue ? `SLA breached · ${sla.label}` : `SLA ${sla.label}`}
      size="sm"
    />
  );
}

/** Notices are coloured by what they mean, not by how they were produced. */
function Notice({ tone, children }: { tone: 'pending' | 'ok' | 'warn'; children: ReactNode }) {
  const cls =
    tone === 'ok'
      ? 'bg-buddy-green/10 border border-buddy-green/20 text-buddy-green'
      : tone === 'warn'
        ? 'bg-buddy-orange/10 border border-buddy-orange/20 text-buddy-orange'
        : 'bg-buddy-electric/10 border border-buddy-electric/20 text-buddy-electric';
  return <div className={`text-xs rounded-xl px-3 py-2 ${cls}`}>{children}</div>;
}

/* ------------------------------------------------------------------ */
/* Reports: assignment + SLA                                           */
/* ------------------------------------------------------------------ */

function ReportsTab({ onChanged }: { onChanged: () => void }) {
  const [status, setStatus] = useState('all');
  const [assignment, setAssignment] = useState('all');
  const [picking, setPicking] = useState<string | null>(null);
  const [pickQuery, setPickQuery] = useState('');
  const [pickResults, setPickResults] = useState<PortalUser[]>([]);
  const [pickingBusy, setPickingBusy] = useState(false);
  const action = usePortalAction();
  const debouncedPick = useDebounced(pickQuery, 300);

  const filters = useMemo(
    () => ({
      status,
      // `unassigned` is its own server-side boolean; folding it into
      // `assigned_to` would be a lie — `assigned_to=unassigned` is a 400.
      assigned_to: assignment === 'all' || assignment === 'unassigned' ? undefined : assignment,
      unassigned: assignment === 'unassigned' ? true : undefined,
    }),
    [status, assignment],
  );

  const fetcher = useCallback(
    (params: Record<string, unknown>) => adminPortalApi.getModerationReports(params as never),
    [],
  );
  const { items, count, page, pageCount, loading, error, reload, goToPage } =
    usePortalList<ModerationReportRow>(fetcher, filters);

  const assign = useCallback(
    async (report: ModerationReportRow, assignedTo: string | null) => {
      const id = report.id;
      if (!id) return;
      const ok = await action.run(
        id,
        () => adminPortalApi.assignModerationReport(id, { assigned_to: assignedTo }),
        {
          success: assignedTo ? 'Report assigned.' : 'Report returned to the unassigned queue.',
          failure: 'Failed to change the assignment.',
        },
      );
      setPicking(null);
      setPickQuery('');
      setPickResults([]);
      if (ok) {
        reload(true);
        onChanged();
      }
    },
    [action, reload, onChanged],
  );

  const handle = useCallback(
    async (report: ModerationReportRow, verb: 'investigate' | 'resolve' | 'dismiss') => {
      const id = report.id;
      if (!id) return;
      const ok = await action.run(
        id,
        () => adminPortalApi.handleModerationReport(id, verb, ''),
        { success: `Report ${verb === 'resolve' ? 'resolved' : verb === 'dismiss' ? 'dismissed' : 'marked for investigation'}.`, failure: `Failed to ${verb} the report.` },
      );
      if (ok) {
        reload(true);
        onChanged();
      }
    },
    [action, reload, onChanged],
  );

  // Staff directory lookup for "assign to another": the assign endpoint takes a
  // user id, and an operator cannot be expected to know one.
  useEffect(() => {
    const q = debouncedPick.trim();
    if (!q) {
      setPickResults([]);
      return;
    }
    let cancelled = false;
    setPickingBusy(true);
    adminPortalApi
      .getUsers({ q, is_active: true })
      .then((res) => {
        if (cancelled) return;
        setPickResults((Array.isArray(res?.data) ? res.data : []).filter((u) => u.is_staff === true).slice(0, 6));
      })
      .catch(() => { if (!cancelled) setPickResults([]); })
      .finally(() => { if (!cancelled) setPickingBusy(false); });
    return () => { cancelled = true; };
  }, [debouncedPick]);

  const breached = items.filter((r) => r.sla_breached === true).length;
  const unassigned = items.filter((r) => !r.assigned_to).length;

  if (loading && !items.length) return <AdminSkeleton rows={4} />;

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <AdminStatCard label="Matching reports" value={count.toLocaleString()} />
        <AdminStatCard label="On this page" value={items.length} />
        <AdminStatCard label="SLA breached" value={breached} />
        <AdminStatCard label="Unassigned" value={unassigned} />
      </div>

      <Card className="p-4 space-y-3">
        <FilterChips options={REPORT_STATUS_OPTIONS} value={status} onChange={setStatus} />
        <div className="flex flex-wrap items-center gap-2">
          <FilterChips options={ASSIGNMENT_OPTIONS} value={assignment} onChange={setAssignment} />
          {(status !== 'all' || assignment !== 'all') && (
            <Button variant="ghost" size="sm" onClick={() => { setStatus('all'); setAssignment('all'); }}>
              Clear filters
            </Button>
          )}
        </div>
      </Card>

      {error && <AdminErrorBanner message={error} onRetry={() => reload()} />}
      {action.error && <AdminErrorBanner message={action.error} />}
      {action.notice && <Notice tone="ok">{action.notice}</Notice>}

      {items.length === 0 ? (
        <AdminEmptyState
          icon={<ShieldCheck size={32} />}
          title={count === 0 ? 'No reports match the current filters.' : 'No reports on this page.'}
          hint="Adjust the filters above, or clear them to see the whole queue."
        />
      ) : (
        <div className="space-y-2">
          {items.map((report, index) => {
            const id = report.id || `report-${index}`;
            const busy = action.actingId === report.id;
            const closed = report.status === 'resolved' || report.status === 'dismissed';
            return (
              <Card key={id} className="p-4">
                <div className="flex flex-wrap items-start gap-3">
                  <div className="flex-1 min-w-0">
                    <div className="flex flex-wrap items-center gap-2">
                      <span className="text-sm font-semibold capitalize">{text(report.reason, 'Unspecified')}</span>
                      <StatusBadge status={report.status} />
                      {!closed && <SlaBadge dueAt={report.sla_due_at} breached={report.sla_breached} />}
                      {report.assigned_to ? (
                        <Badge variant="blue" label={`Assigned ${shortId(report.assigned_to)}`} size="sm" />
                      ) : (
                        <Badge variant="silver" label="Unassigned" size="sm" />
                      )}
                    </div>
                    <p className="text-sm mt-1.5 break-words">{text(report.description, 'No description supplied.')}</p>
                    <p className="text-[11px] text-buddy-text-secondary mt-1">
                      {shortId(report.id)} · target {shortId(report.target_user)} · filed {formatDate(report.created_at)}
                    </p>
                    {/* Reports used to carry only a free-text content_url, which
                        this screen dropped entirely -- so a moderator could see
                        that something was reported and not what. */}
                    {report.content_type && (
                      <p className="text-[11px] text-buddy-text-secondary mt-1 font-mono">
                        {report.content_type}:{report.content_id || '—'}
                      </p>
                    )}
                    {(report.content_type || report.content_url) && (
                      <ContentPeek
                        contentType={report.content_type || ''}
                        contentId={report.content_id || ''}
                      />
                    )}
                    {report.resolution_note && (
                      <p className="text-[11px] text-buddy-text-secondary mt-1 break-words">Resolution: {report.resolution_note}</p>
                    )}
                  </div>

                  {!closed && (
                    <div className="flex flex-wrap items-center gap-1.5 flex-shrink-0">
                      {report.assigned_to ? (
                        <>
                          <Button variant="ghost" size="sm" disabled={busy} onClick={() => assign(report, null)}>
                            <UserMinus size={14} className="mr-1" /> Unassign
                          </Button>
                          <Button variant="ghost" size="sm" disabled={busy} onClick={() => setPicking(picking === id ? null : id)}>
                            <UserCheck size={14} className="mr-1" /> Reassign
                          </Button>
                        </>
                      ) : (
                        <>
                          <Button variant="outline" size="sm" disabled={busy} onClick={() => assign(report, 'me')}>
                            <UserCheck size={14} className="mr-1" /> Assign to me
                          </Button>
                          <Button variant="ghost" size="sm" disabled={busy} onClick={() => setPicking(picking === id ? null : id)}>
                            Assign to someone
                          </Button>
                        </>
                      )}
                      <Button variant="ghost" size="sm" disabled={busy} onClick={() => handle(report, 'investigate')}>
                        Investigate
                      </Button>
                      <Button variant="outline" size="sm" disabled={busy} onClick={() => handle(report, 'resolve')}>
                        <CheckCircle2 size={14} className="mr-1" /> Resolve
                      </Button>
                      <Button variant="ghost" size="sm" disabled={busy} onClick={() => handle(report, 'dismiss')}>
                        Dismiss
                      </Button>
                    </div>
                  )}
                </div>

                {picking === id && (
                  <div className="mt-3 pt-3 border-t border-buddy-surface">
                    <p className="text-xs text-buddy-text-secondary mb-2">
                      Reports can only be assigned to a staff member. Search by email or username.
                    </p>
                    <SearchField
                      value={pickQuery}
                      onChange={setPickQuery}
                      label="Search staff to assign"
                      placeholder="Staff email or username…"
                    />
                    {pickingBusy && <p className="text-[11px] text-buddy-text-secondary mt-2">Searching…</p>}
                    {!pickingBusy && pickQuery.trim() && pickResults.length === 0 && (
                      <p className="text-[11px] text-buddy-text-secondary mt-2">
                        No active staff account matches “{pickQuery.trim()}”.
                      </p>
                    )}
                    {pickResults.length > 0 && (
                      <div className="flex flex-wrap gap-1.5 mt-2">
                        {pickResults.map((u) => (
                          <Button
                            key={u.id || u.email}
                            variant="outline"
                            size="sm"
                            disabled={busy}
                            onClick={() => u.id && assign(report, u.id)}
                          >
                            {text(u.email || u.username, 'staff')}
                          </Button>
                        ))}
                      </div>
                    )}
                    <Button variant="ghost" size="sm" className="mt-2" onClick={() => { setPicking(null); setPickQuery(''); setPickResults([]); }}>
                      Cancel
                    </Button>
                  </div>
                )}
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
/* AI flag queue                                                       */
/* ------------------------------------------------------------------ */

/**
 * Renders the live object behind a flag.
 *
 * The queue used to show a truncated id and a 500-character preview, which is
 * enough to triage but not to act on: "is this a joke or an advert" needs the
 * post in front of you. Collapsed by default so the queue stays scannable, and
 * fetched on demand rather than sixteen extra calls on page load.
 *
 * Staff-only, and deliberately shows the content in full.
 */
function ContentPeek({ contentType, contentId }: { contentType: string; contentId: string }) {
  const [open, setOpen] = useState(false);
  const [data, setData] = useState<ResolvedContent | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const load = useCallback(() => {
    setLoading(true);
    setError('');
    adminPortalApi
      .resolveModerationContent(contentType, contentId)
      .then((res) => setData(res?.data ?? null))
      .catch(() => setError('Could not load this content.'))
      .finally(() => setLoading(false));
  }, [contentType, contentId]);

  if (!contentType || !contentId) return null;

  return (
    <div className="mt-2">
      <button
        type="button"
        onClick={() => { const next = !open; setOpen(next); if (next && !data && !loading) load(); }}
        className="text-[11px] text-buddy-green hover:underline inline-flex items-center gap-1"
      >
        {open ? 'Hide content' : 'View content'}
        <ArrowUpRight size={11} className={open ? 'rotate-90' : ''} />
      </button>

      {open && (
        <div className="mt-2 rounded-lg border border-buddy-surface bg-buddy-surface-raised/40 p-3 space-y-2">
          {loading && <p className="text-[11px] text-buddy-text-secondary">Loading…</p>}
          {error && <p className="text-[11px] text-buddy-red">{error}</p>}
          {!loading && !error && data && !data.label && (
            <p className="text-[11px] text-buddy-text-secondary">
              This content has already been deleted.
            </p>
          )}
          {!loading && !error && data?.label && (
            <>
              <div className="flex flex-wrap items-center gap-2">
                <Badge variant="electric" label={data.label} size="sm" />
                {data.author?.display_name && (
                  <span className="text-[11px] text-buddy-text-secondary">
                    by {data.author.display_name}
                  </span>
                )}
              </div>
              {data.takedown?.taken_down && (
                <p className="text-[11px] text-buddy-orange">
                  Taken down ({data.takedown.reason}).
                  {typeof data.takedown.appeal_window_days === 'number'
                    ? ` Appealable for ${data.takedown.appeal_window_days} more days.`
                    : ''}
                </p>
              )}
              {data.title && (
                typeof data.title === 'string'
                  ? <p className="text-sm font-medium break-words">{data.title}</p>
                  : null
              )}
              {typeof data.body === 'string' && data.body && (
                <p className="text-xs text-buddy-text-primary whitespace-pre-wrap break-words line-clamp-12">
                  {data.body}
                </p>
              )}
              {data.context?.post_body && (
                <p className="text-[11px] text-buddy-text-secondary italic break-words">
                  on: {data.context.post_body}
                </p>
              )}
              {data.fields && Object.keys(data.fields).length > 0 && (
                <dl className="grid grid-cols-[auto,1fr] gap-x-3 gap-y-0.5 text-[11px]">
                  {Object.entries(data.fields).map(([k, v]) => (
                    <div key={k} className="contents">
                      <dt className="text-buddy-text-secondary">{k.replace(/_/g, ' ')}</dt>
                      <dd className="break-words">{v === '' || v === null ? '—' : String(v)}</dd>
                    </div>
                  ))}
                </dl>
              )}
              {data.route && (
                <a
                  href={data.route}
                  className="inline-block text-[11px] text-buddy-green hover:underline"
                >
                  Open in app →
                </a>
              )}
            </>
          )}
        </div>
      )}
    </div>
  );
}

function FlagsTab() {
  const [flags, setFlags] = useState<ContentFlagRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [reasonFilter, setReasonFilter] = useState('all');
  // Content type is a first-class filter, not a label you read. The queue used
  // to return every type in one list, so "what have we flagged in communities"
  // had no query that could answer it.
  const [typeFilter, setTypeFilter] = useState('all');
  const [actingId, setActingId] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState('');

  const load = useCallback(() => {
    setLoading(true);
    setError('');
    Promise.all([
      adminPortalApi.getContentFlags({
        is_actioned: false,
        flag_reason: reasonFilter === 'all' ? undefined : reasonFilter,
        content_type: typeFilter === 'all' ? undefined : typeFilter,
      }),
      adminPortalApi.getContentFlagStats(),
    ])
      .then(([flagsRes]) => setFlags(Array.isArray(flagsRes?.data) ? flagsRes.data : []))
      .catch(() => setError('Failed to load the flag queue. Staff access required.'))
      .finally(() => setLoading(false));
  }, [reasonFilter, typeFilter]);

  useEffect(() => { load(); }, [load]);

  const act = useCallback(
    async (flag: ContentFlagRow, action: 'approve' | 'remove' | 'escalate') => {
      const id = flag.id;
      if (!id) return;
      setActingId(id);
      setError('');
      try {
        const res = await adminPortalApi.actOnContentFlag(id, action);
        // A takedown hides rather than deletes, and the appeal window is the
        // difference between "removed" and "gone" in a moderator's head. Say so
        // rather than leaving them to assume the content was destroyed.
        const takedown = (res?.data as { takedown?: { appeal_window_days?: number } } | undefined)?.takedown;
        if (action === 'remove' && takedown) {
          setError('');
          setSuccessMessage(
            `Taken down. Hidden from members, still visible to you and the creator, ` +
            `and reversible for ${takedown.appeal_window_days ?? 90} days.`,
          );
        }
        load();
      } catch {
        setError(`Failed to ${action} flag ${shortId(id)}. The flag is still open.`);
      } finally {
        setActingId(null);
      }
    },
    [load],
  );

  /** Mirrors the handler registry server-side; see `describe_registry()`. */
  const CONTENT_TYPE_CHIPS = [
    { value: 'all', label: 'All types' },
    { value: 'feed.post', label: 'Posts' },
    { value: 'feed.comment', label: 'Comments' },
    { value: 'user.profile', label: 'Profiles' },
    { value: 'profiles.buddy_search_profile', label: 'Find a buddy' },
    { value: 'messaging.community', label: 'Communities' },
    { value: 'messaging.community_post', label: 'Community posts' },
    { value: 'marketplace.product', label: 'Products' },
    { value: 'marketplace.meal_plan', label: 'Meal plans' },
    { value: 'marketplace.programme', label: 'Programmes' },
    { value: 'marketplace.event', label: 'Events' },
    { value: 'gym', label: 'Gyms' },
    { value: 'gyms.schedule_post', label: 'Schedules' },
    { value: 'lives.buddy_live', label: 'Lives' },
    { value: 'sessions.booking', label: 'Sessions' },
    { value: 'sessions.trainer_profile', label: 'Trainer profiles' },
    { value: 'sessions.availability', label: 'Availability' },
  ];

  const REASON_CHIPS = ['all', 'nsfw', 'toxic', 'spam', 'misinfo', 'medical_claim', 'undisclosed_sponsor', 'adult_ungated'].map((r) => ({
    value: r,
    label: r === 'all' ? 'All' : r.replace(/_/g, ' '),
  }));

  return (
    <div className="space-y-4">
      <Card className="p-4 space-y-3">
        <FilterChips options={REASON_CHIPS} value={reasonFilter} onChange={setReasonFilter} />
        <div>
          <p className="text-[11px] text-buddy-text-secondary mb-1.5 font-semibold uppercase tracking-wide">
            Content type
          </p>
          <FilterChips options={CONTENT_TYPE_CHIPS} value={typeFilter} onChange={setTypeFilter} />
        </div>
      </Card>
      {error && <AdminErrorBanner message={error} onRetry={load} />}
      {successMessage && (
        <p className="text-xs text-buddy-green">{successMessage}</p>
      )}
      {loading && !flags.length ? (
        <AdminSkeleton rows={4} />
      ) : flags.length === 0 ? (
        <AdminEmptyState icon={<ShieldCheck size={32} />} title="No AI-flagged content awaiting review." />
      ) : (
        <div className="space-y-2">
          {flags.map((flag, index) => (
            <Card key={flag.id || `flag-${index}`} className="p-4">
              <div className="flex flex-wrap items-start gap-3">
                <div className="flex-1 min-w-0">
                  <div className="flex flex-wrap items-center gap-2">
                    <Badge variant="electric" label={text(flag.flag_reason, 'flagged').toUpperCase()} size="sm" />
                    <StatusBadge status={flag.severity} />
                    <span className="text-[11px] text-buddy-text-secondary font-mono">
                      {text(flag.content_type, 'content')}:{shortId(flag.content_id)}
                    </span>
                    {typeof flag.confidence === 'number' && (
                      <span className="text-[11px] text-buddy-text-secondary">· {Math.round(flag.confidence * 100)}% conf</span>
                    )}
                  </div>
                  <p className="text-sm mt-2 line-clamp-3 break-words">{text(flag.content_preview, 'No preview available.')}</p>
                  {flag.flag_reason && REASON_HELP[flag.flag_reason] && (
                    <p className="text-[11px] text-buddy-orange mt-1.5">
                      <span className="font-semibold">Guidance:</span> {REASON_HELP[flag.flag_reason]}
                    </p>
                  )}
                  <p className="text-[11px] text-buddy-text-secondary mt-1.5">{formatDate(flag.created_at)}</p>
                  <ContentPeek contentType={flag.content_type || ''} contentId={flag.content_id || ''} />
                </div>
                <div className="flex items-center gap-2 flex-shrink-0">
                  <Button variant="outline" size="sm" disabled={actingId === flag.id} onClick={() => act(flag, 'approve')}>
                    <CheckCircle2 size={14} className="mr-1" /> Approve
                  </Button>
                  <Button variant="destructive" size="sm" disabled={actingId === flag.id} onClick={() => act(flag, 'remove')}>
                    <Trash2 size={14} className="mr-1" /> Remove
                  </Button>
                  <Button variant="ghost" size="sm" disabled={actingId === flag.id} onClick={() => act(flag, 'escalate')}>
                    <ArrowUpRight size={14} className="mr-1" /> Escalate
                  </Button>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Pending approvals                                                   */
/* ------------------------------------------------------------------ */

function PendingTab() {
  const [rows, setRows] = useState<PendingApprovalRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const load = useCallback(() => {
    setLoading(true);
    setError('');
    adminPortalApi
      .getPendingApprovals()
      .then((res) => setRows(Array.isArray(res?.data) ? res.data : []))
      .catch(() => setError('Failed to load the pending approvals queue.'))
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => { load(); }, [load]);

  if (loading && !rows.length) return <AdminSkeleton rows={3} />;

  return (
    <div className="space-y-4">
      {error && <AdminErrorBanner message={error} onRetry={load} />}
      <Notice tone="pending">
        A suspension or a ban raised here is <strong>not applied</strong>. It waits in the governance
        approval queue until a different member of staff approves it. Use <strong>Approvals</strong> in
        the admin nav to decide one — and remember the person who raised it cannot decide it.
      </Notice>

      {rows.length === 0 ? (
        <AdminEmptyState icon={<ShieldCheck size={32} />} title="No ban or suspension is waiting for a second approver." />
      ) : (
        <div className="space-y-2">
          {rows.map((row, index) => (
            <Card key={row.id || `pending-${index}`} className="p-4">
              <div className="flex flex-wrap items-start gap-3">
                <div className="flex-1 min-w-0">
                  <div className="flex flex-wrap items-center gap-2">
                    <StatusBadge status={row.governance_action} />
                    <Badge variant="orange" label="Awaiting a second approver" size="sm" />
                    {typeof row.duration_days === 'number' && (
                      <Badge variant="silver" label={`${row.duration_days} day term`} size="sm" />
                    )}
                  </div>
                  <p className="text-sm mt-1.5 break-words">{text(row.reason, 'No reason recorded.')}</p>
                  <p className="text-[11px] text-buddy-text-secondary mt-1">
                    target {shortId(row.target_user)} · raised by {text(row.requested_by_profile, shortId(row.requested_by))} ·{' '}
                    {formatDate(row.created_at)} · waiting {formatDuration(row.waiting_seconds)}
                  </p>
                </div>
              </div>
              <div className="mt-3 pt-3 border-t border-buddy-surface grid grid-cols-1 sm:grid-cols-2 gap-x-6">
                <DataRow label="Request id">{text(row.id)}</DataRow>
                <DataRow label="Moderation action">{text(row.moderation_action_id)}</DataRow>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Disciplinary actions + reversal                                     */
/* ------------------------------------------------------------------ */

function ActionsTab() {
  const [rows, setRows] = useState<ModerationActionRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [filter, setFilter] = useState('all');
  const [outcome, setOutcome] = useState<{ tone: 'pending' | 'ok'; text: string } | null>(null);
  const [submitError, setSubmitError] = useState('');
  const [busy, setBusy] = useState(false);
  const [reversing, setReversing] = useState<string | null>(null);
  const action = usePortalAction();

  const [targetUser, setTargetUser] = useState('');
  const [verb, setVerb] = useState('warning');
  const [reason, setReason] = useState('');
  const [durationDays, setDurationDays] = useState('');

  const load = useCallback(() => {
    setLoading(true);
    setError('');
    adminPortalApi
      .getModerationActions({ action: filter === 'all' ? undefined : filter })
      .then((res) => setRows(Array.isArray(res?.data) ? res.data : []))
      .catch(() => setError('Failed to load the moderation ledger.'))
      .finally(() => setLoading(false));
  }, [filter]);

  useEffect(() => { load(); }, [load]);

  const needsDuration = DISCIPLINARY_ACTIONS.find((a) => a.value === verb)?.needsDuration ?? false;
  const canSubmit = targetUser.trim().length > 0 && reason.trim().length > 0 && (!needsDuration || durationDays.trim().length > 0);

  const submit = useCallback(async () => {
    if (!canSubmit || busy) return;
    setBusy(true);
    setOutcome(null);
    setSubmitError('');
    const days = needsDuration ? Number(durationDays) : null;
    try {
      const res = await adminPortalApi.createModerationAction({
        action: verb,
        target_user: targetUser.trim(),
        reason: reason.trim(),
        duration_days: needsDuration && Number.isFinite(days) ? days : null,
      });
      // The decisive branch: 201 means it happened, 202 means it is queued.
      // axios cannot tell them apart, so `applied` is the only honest signal.
      if (moderationActionApplied(res?.data)) {
        setOutcome({ tone: 'ok', text: res?.message || 'Warning issued and the user has been notified.' });
      } else {
        setOutcome({
          tone: 'pending',
          text:
            res?.message ||
            'This action requires a second approver. The request has been raised in the governance queue and nothing has been applied yet.',
        });
      }
      setReason('');
      setDurationDays('');
      load();
    } catch (e) {
      // The server's own refusal — scope missing, self-target, bad duration —
      // is the most useful thing on screen here, so it is shown verbatim.
      setSubmitError(adminPortalErrorMessage(e, 'Failed to raise the action.'));
    } finally {
      setBusy(false);
    }
  }, [canSubmit, busy, verb, targetUser, reason, needsDuration, durationDays, load]);

  const reverse = useCallback(
    async (row: ModerationActionRow, why: string) => {
      const id = row.id;
      if (!id) return;
      const ok = await action.run(
        id,
        () => adminPortalApi.reverseModerationAction(id, { reason: why }),
        { success: 'Action reversed.', failure: 'Failed to reverse the action.' },
      );
      setReversing(null);
      if (ok) load();
    },
    [action, load],
  );

  if (loading && !rows.length && !outcome) return <AdminSkeleton rows={4} />;

  return (
    <div className="space-y-4">
      <Card className="p-4 space-y-3">
        <div>
          <h3 className="text-sm font-semibold">Take a disciplinary action</h3>
          <p className="text-[11px] text-buddy-text-secondary mt-0.5">
            A warning applies immediately. A suspension or a ban is <strong>raised for a second approver</strong> —
            nothing is applied to the account until someone else approves it.
          </p>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <label className="block text-xs text-buddy-text-secondary">
            <span className="mb-1 block">User id (the account being actioned)</span>
            <input
              value={targetUser}
              onChange={(e) => setTargetUser(e.target.value)}
              placeholder="00000000-0000-0000-0000-000000000000"
              aria-label="Target user id"
              className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm font-mono placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
            />
          </label>
          <label className="block text-xs text-buddy-text-secondary">
            <span className="mb-1 block">Action</span>
            <select
              value={verb}
              onChange={(e) => setVerb(e.target.value)}
              aria-label="Disciplinary action"
              className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm focus:outline-none focus:border-buddy-green"
            >
              {DISCIPLINARY_ACTIONS.map((a) => (
                <option key={a.value} value={a.value}>{a.label}</option>
              ))}
            </select>
          </label>
        </div>

        <label className="block text-xs text-buddy-text-secondary">
          <span className="mb-1 block">Reason (required — the user sees this) <span className="text-buddy-red">*</span></span>
          <textarea
            rows={3}
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            placeholder="What did they do, and why is this the right consequence?"
            aria-label="Action reason"
            className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
          />
        </label>

        {needsDuration && (
          <label className="block text-xs text-buddy-text-secondary sm:max-w-xs">
            <span className="mb-1 block">Duration in days (required) <span className="text-buddy-red">*</span></span>
            <input
              type="number"
              min={1}
              value={durationDays}
              onChange={(e) => setDurationDays(e.target.value)}
              placeholder="30"
              aria-label="Duration in days"
              className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
            />
            <span className="mt-1 block text-[11px]">
              A suspension with no end date is refused by the API. For an open-ended action, escalate instead.
            </span>
          </label>
        )}

        <div className="flex items-center gap-2">
          <Button size="sm" disabled={!canSubmit} isLoading={busy} onClick={submit}>
            {needsDuration ? 'Raise for approval' : 'Issue warning'}
          </Button>
          {!canSubmit && <span className="text-[11px] text-buddy-text-secondary">A user id and a reason are required.</span>}
        </div>

        {outcome && <Notice tone={outcome.tone}>{outcome.text}</Notice>}
        {submitError && <AdminErrorBanner message={submitError} />}
      </Card>

      <Card className="p-4">
        <FilterChips options={ACTION_OPTIONS} value={filter} onChange={setFilter} />
      </Card>

      {error && <AdminErrorBanner message={error} onRetry={load} />}
      {action.notice && <Notice tone="ok">{action.notice}</Notice>}

      {rows.length === 0 ? (
        <AdminEmptyState icon={<ShieldAlert size={32} />} title="No moderation actions recorded for this filter." />
      ) : (
        <div className="space-y-2">
          {rows.map((row, index) => {
            const id = row.id || `action-${index}`;
            const busyRow = action.actingId === row.id;
            const reversible = Boolean(row.action && REVERSIBLE_ACTIONS.has(row.action)) && row.is_reversed !== true;
            return (
              <Card key={id} className="p-4">
                <div className="flex flex-wrap items-start gap-3">
                  <div className="flex-1 min-w-0">
                    <div className="flex flex-wrap items-center gap-2">
                      <StatusBadge status={row.action} />
                      {row.is_reversed && <Badge variant="silver" label="Reversed" size="sm" />}
                      {typeof row.duration_days === 'number' && (
                        <Badge variant="silver" label={`${row.duration_days} days`} size="sm" />
                      )}
                    </div>
                    <p className="text-sm mt-1.5 break-words">{text(row.reason, 'No reason recorded.')}</p>
                    <p className="text-[11px] text-buddy-text-secondary mt-1">
                      {shortId(row.id)} · target {shortId(row.target_user)} · moderator {shortId(row.moderator)} ·{' '}
                      {formatDate(row.created_at)}
                    </p>
                    {row.is_reversed && (
                      <p className="text-[11px] text-buddy-text-secondary mt-1 break-words">
                        Reversed {formatDate(row.reversed_at)} — {text(row.reversal_reason, 'no reason recorded')}
                        {row.reversed_by_moderator ? ` by ${text(row.reversed_by_moderator.email, shortId(row.reversed_by_moderator.id))}` : ''}
                      </p>
                    )}
                  </div>
                  <div className="flex-shrink-0">
                    {reversible ? (
                      <Button variant="ghost" size="sm" disabled={busyRow} onClick={() => setReversing(reversing === id ? null : id)}>
                        <Undo2 size={14} className="mr-1" /> Reverse action
                      </Button>
                    ) : (
                      <span className="text-[11px] text-buddy-text-secondary">Not reversible</span>
                    )}
                  </div>
                </div>

                <ReasonPrompt
                  open={reversing === id}
                  action="approved"
                  requireNote
                  submitLabel="Reverse this action"
                  placeholder="Why is this being undone? The user is notified with this reason."
                  busy={busyRow}
                  onSubmit={(why) => reverse(row, why)}
                  onCancel={() => setReversing(null)}
                />
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Commendations                                                       */
/* ------------------------------------------------------------------ */

function CommendationsTab() {
  const [rows, setRows] = useState<Commendation[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [recipient, setRecipient] = useState('');
  const [category, setCategory] = useState('helpful');
  const [message, setMessage] = useState('');
  const [busy, setBusy] = useState(false);
  const [issueError, setIssueError] = useState('');
  const [revoking, setRevoking] = useState<string | null>(null);
  const [notice, setNotice] = useState('');
  const action = usePortalAction();

  const load = useCallback(() => {
    setLoading(true);
    setError('');
    adminPortalApi
      .getCommendations()
      .then((res) => setRows(Array.isArray(res?.data) ? res.data : []))
      .catch(() => setError('Failed to load commendations.'))
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => { load(); }, [load]);

  const issue = useCallback(async () => {
    if (!recipient.trim() || !message.trim() || busy) return;
    setBusy(true);
    setNotice('');
    try {
      const res = await adminPortalApi.createCommendation({
        recipient: recipient.trim(),
        category,
        message: message.trim(),
      });
      setNotice(res?.message || 'Commendation issued and the recipient has been notified.');
      setRecipient('');
      setMessage('');
      load();
    } catch (e) {
      setIssueError(adminPortalErrorMessage(e, 'Failed to issue the commendation.'));
    } finally {
      setBusy(false);
    }
  }, [recipient, message, category, busy, load]);

  const revoke = useCallback(
    async (row: Commendation, reason: string) => {
      const id = row.id;
      if (!id) return;
      const ok = await action.run(
        id,
        () => adminPortalApi.revokeCommendation(id, reason ? { reason } : {}),
        { success: 'Commendation revoked. The record is kept; the recipient no longer sees it.', failure: 'Failed to revoke the commendation.' },
      );
      setRevoking(null);
      if (ok) load();
    },
    [action, load],
  );

  return (
    <div className="space-y-4">
      <Card className="p-4 space-y-3">
        <div>
          <h3 className="text-sm font-semibold flex items-center gap-1.5"><Award size={14} /> Issue a commendation</h3>
          <p className="text-[11px] text-buddy-text-secondary mt-0.5">
            The recipient is identified by <strong>profile</strong> id, not user id — the API resolves it
            against the profile table and says so in its own error if you give it the wrong one.
          </p>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <label className="block text-xs text-buddy-text-secondary">
            <span className="mb-1 block">Recipient profile id</span>
            <input
              value={recipient}
              onChange={(e) => setRecipient(e.target.value)}
              placeholder="Profile id"
              aria-label="Recipient profile id"
              className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm font-mono placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
            />
          </label>
          <label className="block text-xs text-buddy-text-secondary">
            <span className="mb-1 block">Category</span>
            <select
              value={category}
              onChange={(e) => setCategory(e.target.value)}
              aria-label="Commendation category"
              className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm focus:outline-none focus:border-buddy-green"
            >
              {COMMENDATION_CATEGORIES.map((c) => (
                <option key={c.value} value={c.value}>{c.label}</option>
              ))}
            </select>
          </label>
        </div>
        <label className="block text-xs text-buddy-text-secondary">
          <span className="mb-1 block">Message (required)</span>
          <textarea
            rows={2}
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            placeholder="What did they do that was worth recording?"
            aria-label="Commendation message"
            className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
          />
        </label>
        <Button size="sm" disabled={!recipient.trim() || !message.trim()} isLoading={busy} onClick={issue}>
          Issue commendation
        </Button>
        {notice && <Notice tone="ok">{notice}</Notice>}
        {issueError && <AdminErrorBanner message={issueError} />}
      </Card>

      {error && <AdminErrorBanner message={error} onRetry={load} />}
      {action.notice && <Notice tone="ok">{action.notice}</Notice>}

      {loading && !rows.length ? (
        <AdminSkeleton rows={3} />
      ) : rows.length === 0 ? (
        <AdminEmptyState icon={<Award size={32} />} title="No commendations recorded yet." />
      ) : (
        <div className="space-y-2">
          {rows.map((row, index) => {
            const id = row.id || `commendation-${index}`;
            return (
              <Card key={id} className="p-4">
                <div className="flex flex-wrap items-start gap-3">
                  <div className="flex-1 min-w-0">
                    <div className="flex flex-wrap items-center gap-2">
                      <StatusBadge status={row.category} />
                      {row.visible_to_recipient === false && <Badge variant="silver" label="Revoked" size="sm" />}
                    </div>
                    <p className="text-sm mt-1.5 break-words">{text(row.message, 'No message recorded.')}</p>
                    <p className="text-[11px] text-buddy-text-secondary mt-1">
                      to {text(row.recipient?.display_name, shortId(row.recipient?.id))} · {formatDate(row.created_at)}
                    </p>
                  </div>
                  <Button variant="ghost" size="sm" onClick={() => setRevoking(revoking === id ? null : id)}>
                    Revoke
                  </Button>
                </div>
                <ReasonPrompt
                  open={revoking === id}
                  action="approved"
                  submitLabel="Revoke commendation"
                  placeholder="Why is this being withdrawn? (optional — the row is kept either way)"
                  busy={action.actingId === row.id}
                  onSubmit={(reason) => revoke(row, reason)}
                  onCancel={() => setRevoking(null)}
                />
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Page                                                                */
/* ------------------------------------------------------------------ */

export default function AdminModeration() {
  const [tab, setTab] = useState<Tab>('reports');
  const [pendingCount, setPendingCount] = useState<number | null>(null);
  const [nonce, setNonce] = useState(0);

  // The pending count is the page's whole warning system: a moderator who
  // cannot see that their ban is still queued will raise it again.
  useEffect(() => {
    let cancelled = false;
    adminPortalApi
      .getPendingApprovals()
      .then((res) => { if (!cancelled) setPendingCount(Array.isArray(res?.data) ? res.data.length : 0); })
      .catch(() => { if (!cancelled) setPendingCount(null); });
    return () => { cancelled = true; };
  }, [nonce]);

  const refresh = useCallback(() => setNonce((n) => n + 1), []);

  const tabOptions = useMemo(
    () =>
      TABS.map((t) =>
        t.value === 'pending' && pendingCount
          ? { value: t.value, label: `${t.label} (${pendingCount})` }
          : t,
      ),
    [pendingCount],
  );

  return (
    <div className="space-y-6 pb-8">
      <AdminPageHeader
        title="Moderation"
        description="Flags, the report queue, disciplinary actions and the two-person approvals they wait on."
        onRefresh={refresh}
      />

      <Card className="p-4">
        <FilterChips options={tabOptions} value={tab} onChange={(v) => setTab(v as Tab)} />
      </Card>

      {tab === 'reports' && <ReportsTab onChanged={refresh} />}
      {tab === 'flags' && <FlagsTab />}
      {tab === 'pending' && <PendingTab />}
      {tab === 'actions' && <ActionsTab />}
      {tab === 'commendations' && <CommendationsTab />}

      <p className="text-[11px] text-buddy-text-secondary/70 flex items-center gap-1.5">
        <Clock size={12} /> Response targets are 4 hours for violence, nudity and ungated adult content,
        24 hours otherwise. <Mail size={12} className="ml-2" /> Suspended and banned users are notified by email.
        <Ban size={12} className="ml-2" /> Bans and suspensions need a second approver before they apply.
      </p>
    </div>
  );
}
