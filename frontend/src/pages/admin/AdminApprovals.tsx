import { useCallback, useMemo, useState } from 'react';
import { CheckCircle2, Gavel, Plus, XCircle, Ban as BanIcon, FileText } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import {
  adminPortalApi,
  adminPortalErrorMessage,
  type ApprovalAction,
  type GovernanceApproval,
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
  FilterSelect,
  ReasonPrompt,
  SearchField,
  StatusBadge,
} from './shared';
import { formatDate, shortId, text } from './format';
import { useDebounced, usePortalAction, usePortalList } from './usePortalList';

/**
 * The two-person approval queue.
 *
 * Every failure mode this page has to get right is a *refusal*, and refusals
 * are the API's own sentences, not ours:
 *
 * - approving your own request → 403 "The person who raised this request cannot
 *   be the one who decides it.";
 * - deciding a settled request → 409 "This request was already approved…";
 * - approving without the scope → 403 naming the missing scope;
 * - rejecting or cancelling with no note → 400.
 *
 * None of those are worth paraphrasing. `adminPortalErrorMessage` is used
 * directly so the operator reads the rule, not our summary of it.
 */

const STATUS_OPTIONS = [
  { value: 'all', label: 'All' },
  { value: 'pending', label: 'Pending' },
  { value: 'approved', label: 'Approved' },
  { value: 'rejected', label: 'Rejected' },
  { value: 'cancelled', label: 'Cancelled' },
];

const ACTION_FILTER_OPTIONS = [
  { value: 'all', label: 'Any action' },
  { value: 'ban', label: 'Ban' },
  { value: 'suspension', label: 'Suspension' },
  { value: 'staff_role_grant', label: 'Staff role grant' },
  { value: 'payout', label: 'Payout' },
  { value: 'verification_decision', label: 'Verification decision' },
];

const REQUESTABLE_ACTIONS: Array<{ value: ApprovalAction; label: string }> = [
  { value: 'ban', label: 'Ban account' },
  { value: 'suspension', label: 'Suspend account' },
  { value: 'staff_role_grant', label: 'Grant staff role' },
  { value: 'payout', label: 'Payout' },
  { value: 'verification_decision', label: 'Verification decision' },
];

const STAFF_ROLES = [
  { value: 'admin', label: 'Administrator' },
  { value: 'moderator', label: 'Moderator' },
  { value: 'support', label: 'Support Agent' },
  { value: 'gym_relations', label: 'Gym Relations' },
  { value: 'supplier_relations', label: 'Supplier Relations' },
  { value: 'logistics', label: 'Logistics' },
  { value: 'finance', label: 'Finance' },
  { value: 'verification_regulator', label: 'Verification Regulator' },
];

const isStandingAction = (action: unknown) => action === 'ban' || action === 'suspension';

/** Payload keys that get a dedicated row; anything else falls through to JSON. */
function PayloadRows({ payload }: { payload: Record<string, unknown> | null | undefined }) {
  const entries = payload && typeof payload === 'object' ? Object.entries(payload) : [];
  if (entries.length === 0) return <p className="text-xs text-buddy-text-secondary">No payload recorded.</p>;
  return (
    <div>
      {entries.map(([key, value]) => (
        <DataRow key={key} label={key.replace(/_/g, ' ')}>
          {typeof value === 'object' && value !== null
            ? JSON.stringify(value)
            : typeof value === 'boolean'
              ? value ? 'Yes' : 'No'
              : String(value)}
        </DataRow>
      ))}
    </div>
  );
}

export default function AdminApprovals() {
  const [status, setStatus] = useState('pending');
  const [action_, setAction] = useState('all');
  const [targetUser, setTargetUser] = useState('');
  const [mine, setMine] = useState(false);
  const [expanded, setExpanded] = useState<string | null>(null);
  const [prompt, setPrompt] = useState<{ id: string; kind: 'approve' | 'reject' | 'cancel' } | null>(null);
  const debouncedTarget = useDebounced(targetUser);
  const mutation = usePortalAction();

  const filters = useMemo(
    () => ({
      status,
      action: action_,
      target_user: debouncedTarget.trim() || undefined,
      mine: mine || undefined,
    }),
    [status, action_, debouncedTarget, mine],
  );

  const fetcher = useCallback(
    (params: Record<string, unknown>) => adminPortalApi.getApprovals(params as never),
    [],
  );
  const { items, count, page, pageCount, loading, error, reload, goToPage } =
    usePortalList<GovernanceApproval>(fetcher, filters);

  const decide = useCallback(
    async (row: GovernanceApproval, kind: 'approve' | 'reject' | 'cancel', note: string) => {
      const id = row.id;
      if (!id) return;
      const call =
        kind === 'approve' ? adminPortalApi.approveApproval
          : kind === 'reject' ? adminPortalApi.rejectApproval
            : adminPortalApi.cancelApproval;
      const verb = kind === 'approve' ? 'approved' : kind === 'reject' ? 'rejected' : 'cancelled';
      // A refusal is the expected outcome here as often as success is, so the
      // message is surfaced verbatim either way.
      const ok = await mutation.run(
        id,
        () => call(id, note ? { note } : {}),
        { success: `Request ${verb}.`, failure: `Failed to ${verb} the request.` },
      );
      setPrompt(null);
      if (ok) reload(true);
    },
    [mutation, reload],
  );

  const pendingCount = items.filter((r) => r.status === 'pending').length;
  const standingPending = items.filter((r) => r.status === 'pending' && isStandingAction(r.action)).length;

  if (loading && !items.length) return <AdminSkeleton />;
  if (error && !items.length) return <AdminErrorState message={error} onRetry={() => reload()} />;

  return (
    <div className="space-y-6 pb-8">
      <AdminPageHeader
        title="Approvals"
        description="Two-person approval. Nobody decides their own request, and approving applies the effect exactly once."
        onRefresh={() => reload()}
        refreshing={loading}
      />

      <RequestForm onRaised={() => reload(true)} />

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <AdminStatCard label="Matching requests" value={count.toLocaleString()} />
        <AdminStatCard label="Pending on this page" value={pendingCount} />
        <AdminStatCard label="Bans / suspensions waiting" value={standingPending} />
        <AdminStatCard label="Settled" value={items.length - pendingCount} />
      </div>

      <Card className="p-4 space-y-3">
        <FilterChips options={STATUS_OPTIONS} value={status} onChange={setStatus} />
        <div className="flex flex-wrap items-center gap-2">
          <FilterSelect label="Action" value={action_} options={ACTION_FILTER_OPTIONS} onChange={setAction} />
          <SearchField value={targetUser} onChange={setTargetUser} label="Filter by target user id" placeholder="Target user id…" />
          <label className="inline-flex items-center gap-1.5 text-xs text-buddy-text-secondary">
            <input
              type="checkbox"
              checked={mine}
              onChange={(e) => setMine(e.target.checked)}
              aria-label="Only requests I raised"
              className="accent-buddy-green"
            />
            Only mine
          </label>
          {(status !== 'pending' || action_ !== 'all' || targetUser || mine) && (
            <Button variant="ghost" size="sm" onClick={() => { setStatus('pending'); setAction('all'); setTargetUser(''); setMine(false); }}>
              Clear filters
            </Button>
          )}
        </div>
      </Card>

      {error && <AdminErrorBanner message={error} onRetry={() => reload()} />}
      {mutation.error && (
        <AdminErrorBanner message={mutation.error} onRetry={mutation.clearError} />
      )}
      {mutation.notice && (
        <div className="bg-buddy-green/10 border border-buddy-green/20 text-buddy-green text-xs rounded-xl px-3 py-2">
          {mutation.notice}
        </div>
      )}

      {items.length === 0 ? (
        <AdminEmptyState
          icon={<Gavel size={32} />}
          title={count === 0 ? 'No requests match the current filters.' : 'No requests on this page.'}
          hint="A ban or suspension raised from Moderation appears here within seconds."
        />
      ) : (
        <div className="space-y-2">
          {items.map((row, index) => {
            const id = row.id || `approval-${index}`;
            const isOpen = expanded === id;
            const isPending = row.status === 'pending';
            const busy = mutation.actingId === row.id;
            return (
              <Card key={id} className="p-4">
                <div className="flex flex-wrap items-start gap-3">
                  <div className="flex-1 min-w-0">
                    <div className="flex flex-wrap items-center gap-2">
                      <StatusBadge status={row.status} />
                      <Badge variant={isStandingAction(row.action) ? 'red' : 'silver'} label={text(row.action_display || row.action, 'request')} size="sm" />
                      {row.requires_second === false && <Badge variant="gold" label="Single approver" size="sm" />}
                      {row.applied_at && <Badge variant="green" label="Effect applied" size="sm" />}
                      {isPending && row.applied_at === null && row.action !== 'staff_role_grant' && (
                        <Badge variant="orange" label="Nothing applied yet" size="sm" />
                      )}
                    </div>
                    <p className="text-sm mt-1.5 break-words">
                      {text(row.target_user?.display_name, 'Unknown target')} ·{' '}
                      <span className="text-buddy-text-secondary">{text(row.target_user?.email)}</span>
                    </p>
                    <p className="text-[11px] text-buddy-text-secondary mt-1">
                      {shortId(row.id)} · raised by {text(row.requested_by_profile, shortId(row.requested_by?.id))} ·{' '}
                      {formatDate(row.created_at)}
                    </p>
                    {row.decided_at && (
                      <p className="text-[11px] text-buddy-text-secondary mt-1 break-words">
                        {text(row.status)} by {text(row.decided_by?.email, shortId(row.decided_by?.id))} on{' '}
                        {formatDate(row.decided_at)}
                        {row.decision_note ? ` — ${row.decision_note}` : ''}
                      </p>
                    )}
                    {row.effect && (
                      <p className="text-[11px] text-buddy-green mt-1 break-words">{row.effect}</p>
                    )}
                  </div>

                  <div className="flex flex-wrap items-center gap-1.5 flex-shrink-0">
                    <Button variant="ghost" size="sm" onClick={() => setExpanded(isOpen ? null : id)}>
                      <FileText size={14} className="mr-1" /> {isOpen ? 'Hide' : 'Payload'}
                    </Button>
                    {isPending && (
                      <>
                        <Button
                          variant="outline"
                          size="sm"
                          disabled={busy}
                          onClick={() => setPrompt(prompt?.id === id && prompt.kind === 'approve' ? null : { id, kind: 'approve' })}
                        >
                          <CheckCircle2 size={14} className="mr-1" /> Approve
                        </Button>
                        <Button
                          variant="destructive"
                          size="sm"
                          disabled={busy}
                          onClick={() => setPrompt(prompt?.id === id && prompt.kind === 'reject' ? null : { id, kind: 'reject' })}
                        >
                          <XCircle size={14} className="mr-1" /> Reject
                        </Button>
                        <Button
                          variant="ghost"
                          size="sm"
                          disabled={busy}
                          onClick={() => setPrompt(prompt?.id === id && prompt.kind === 'cancel' ? null : { id, kind: 'cancel' })}
                        >
                          Cancel
                        </Button>
                      </>
                    )}
                  </div>
                </div>

                {isOpen && (
                  <div className="mt-3 pt-3 border-t border-buddy-surface grid grid-cols-1 lg:grid-cols-2 gap-4">
                    <div>
                      <p className="text-xs font-semibold mb-1.5">Request</p>
                      <DataRow label="Target user">{text(row.target_user?.id)}</DataRow>
                      <DataRow label="Requester">{text(row.requested_by_profile, '—')}</DataRow>
                      <DataRow label="Approver scope">{text(row.required_scope)}</DataRow>
                      <DataRow label="Requires second">{row.requires_second === false ? 'No' : 'Yes'}</DataRow>
                      <DataRow label="Applied at">{formatDate(row.applied_at)}</DataRow>
                    </div>
                    <div>
                      <p className="text-xs font-semibold mb-1.5">Payload</p>
                      <PayloadRows payload={row.payload} />
                    </div>
                  </div>
                )}

                <ReasonPrompt
                  open={prompt?.id === id}
                  // Reject and cancel share a shape: a required note that the
                  // target reads, not an internal annotation. Only approve is
                  // an "internal note", so only approve gets that label.
                  action={prompt?.kind === 'approve' ? 'approved' : 'rejected'}
                  submitLabel={
                    prompt?.kind === 'approve' ? 'Approve and apply'
                      : prompt?.kind === 'reject' ? 'Reject request'
                        : 'Cancel request'
                  }
                  placeholder={
                    prompt?.kind === 'approve'
                      ? 'Optional note for the audit trail. This approval applies the effect immediately.'
                      : 'Required. This is the record the target will read in an appeal.'
                  }
                  // The server requires a note for reject and cancel, and only
                  // encourages one for approve. Blocking the button early saves
                  // a round trip that is guaranteed to be a 400.
                  requireNote={prompt?.kind !== 'approve'}
                  busy={busy}
                  onSubmit={(note) => {
                    const kind = prompt?.kind ?? 'approve';
                    const target = items.find((r) => (r.id || `approval-${index}`) === id);
                    if (target) decide(target, kind, note);
                  }}
                  onCancel={() => setPrompt(null)}
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
/* Raise a request                                                     */
/* ------------------------------------------------------------------ */

function RequestForm({ onRaised }: { onRaised: () => void }) {
  const [open, setOpen] = useState(false);
  const [action_, setAction] = useState<ApprovalAction>('suspension');
  const [targetUser, setTargetUser] = useState('');
  const [reason, setReason] = useState('');
  const [durationDays, setDurationDays] = useState('');
  const [role, setRole] = useState('moderator');
  const [scopes, setScopes] = useState('');
  const [notes, setNotes] = useState('');
  const [freeform, setFreeform] = useState('{}');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');

  const standing = isStandingAction(action_);
  const roleGrant = action_ === 'staff_role_grant';

  const canSubmit = useMemo(() => {
    if (!targetUser.trim()) return false;
    if (standing && !reason.trim()) return false;
    if (action_ === 'suspension' && !durationDays.trim()) return false;
    if (!standing && !roleGrant) return false; // free-form payload has no server-side rule to pre-check
    return true;
  }, [targetUser, reason, durationDays, standing, roleGrant, action_]);

  const buildPayload = useCallback((): Record<string, unknown> => {
    if (standing) {
      const payload: Record<string, unknown> = { reason: reason.trim() };
      if (action_ === 'suspension' && durationDays.trim()) {
        const days = Number(durationDays);
        if (Number.isFinite(days)) payload.duration_days = days;
      }
      return payload;
    }
    if (roleGrant) {
      return {
        role,
        scopes: scopes.split(',').map((s) => s.trim()).filter(Boolean),
        notes: notes.trim(),
      };
    }
    try {
      const parsed: unknown = JSON.parse(freeform);
      return parsed && typeof parsed === 'object' ? (parsed as Record<string, unknown>) : {};
    } catch {
      return {};
    }
  }, [standing, action_, reason, durationDays, roleGrant, role, scopes, notes, freeform]);

  const submit = useCallback(async () => {
    if (busy) return;
    setBusy(true);
    setError('');
    setNotice('');
    try {
      const res = await adminPortalApi.requestApproval({
        action: action_,
        target_user: targetUser.trim(),
        payload: buildPayload(),
      });
      setNotice(
        res?.message ||
          'Request raised. Nothing has been applied — it needs approval by a different member of staff.',
      );
      setTargetUser('');
      setReason('');
      setDurationDays('');
      setNotes('');
      setScopes('');
      onRaised();
    } catch (e) {
      setError(adminPortalErrorMessage(e, 'Failed to raise the request.'));
    } finally {
      setBusy(false);
    }
  }, [busy, action_, targetUser, buildPayload, onRaised]);

  if (!open) {
    return (
      <Card className="p-4">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div className="min-w-0">
            <h3 className="text-sm font-semibold flex items-center gap-1.5"><Plus size={14} /> Request an action</h3>
            <p className="text-[11px] text-buddy-text-secondary mt-0.5">
              Raising a request never applies it. Somebody else has to approve it.
            </p>
          </div>
          <Button variant="outline" size="sm" onClick={() => setOpen(true)}>Raise a request</Button>
        </div>
      </Card>
    );
  }

  return (
    <Card className="p-4 space-y-3">
      <div className="flex items-center justify-between gap-3">
        <h3 className="text-sm font-semibold flex items-center gap-1.5"><BanIcon size={14} /> Request an action</h3>
        <Button variant="ghost" size="sm" onClick={() => { setOpen(false); setError(''); setNotice(''); }}>Close</Button>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <label className="block text-xs text-buddy-text-secondary">
          <span className="mb-1 block">Action</span>
          <select
            value={action_}
            onChange={(e) => setAction(e.target.value as ApprovalAction)}
            aria-label="Requested action"
            className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm focus:outline-none focus:border-buddy-green"
          >
            {REQUESTABLE_ACTIONS.map((a) => (
              <option key={a.value} value={a.value}>{a.label}</option>
            ))}
          </select>
        </label>
        <label className="block text-xs text-buddy-text-secondary">
          <span className="mb-1 block">Target user id</span>
          <input
            value={targetUser}
            onChange={(e) => setTargetUser(e.target.value)}
            placeholder="00000000-0000-0000-0000-000000000000"
            aria-label="Target user id for request"
            className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm font-mono placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
          />
        </label>
      </div>

      {standing && (
        <>
          <label className="block text-xs text-buddy-text-secondary">
            <span className="mb-1 block">Reason <span className="text-buddy-red">*</span></span>
            <textarea
              rows={2}
              value={reason}
              onChange={(e) => setReason(e.target.value)}
              placeholder="Why is this being requested?"
              aria-label="Request reason"
              className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
            />
          </label>
          {action_ === 'suspension' && (
            <label className="block text-xs text-buddy-text-secondary sm:max-w-xs">
              <span className="mb-1 block">Duration in days <span className="text-buddy-red">*</span></span>
              <input
                type="number"
                min={1}
                value={durationDays}
                onChange={(e) => setDurationDays(e.target.value)}
                placeholder="30"
                aria-label="Request duration in days"
                className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
              />
            </label>
          )}
          {action_ === 'ban' && (
            <p className="text-[11px] text-buddy-orange">
              A ban is permanent — the API refuses a duration on it. The only way back is a reversal or a
              successful appeal.
            </p>
          )}
        </>
      )}

      {roleGrant && (
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <label className="block text-xs text-buddy-text-secondary">
            <span className="mb-1 block">Role</span>
            <select
              value={role}
              onChange={(e) => setRole(e.target.value)}
              aria-label="Requested role"
              className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm focus:outline-none focus:border-buddy-green"
            >
              {STAFF_ROLES.map((r) => (
                <option key={r.value} value={r.value}>{r.label}</option>
              ))}
            </select>
          </label>
          <label className="block text-xs text-buddy-text-secondary">
            <span className="mb-1 block">Extra scopes (comma separated)</span>
            <input
              value={scopes}
              onChange={(e) => setScopes(e.target.value)}
              placeholder="users.read, orders.write"
              aria-label="Requested scopes"
              className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
            />
          </label>
        </div>
      )}

      {!standing && !roleGrant && (
        <label className="block text-xs text-buddy-text-secondary">
          <span className="mb-1 block">Payload (JSON)</span>
          <textarea
            rows={3}
            value={freeform}
            onChange={(e) => setFreeform(e.target.value)}
            aria-label="Request payload JSON"
            className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm font-mono focus:outline-none focus:border-buddy-green"
          />
        </label>
      )}

      <label className="block text-xs text-buddy-text-secondary">
        <span className="mb-1 block">Notes (optional)</span>
        <input
          value={notes}
          onChange={(e) => setNotes(e.target.value)}
          aria-label="Request notes"
          placeholder="Context for the approver"
          className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
        />
      </label>

      <div className="flex items-center gap-2">
        <Button size="sm" disabled={!canSubmit} isLoading={busy} onClick={submit}>Raise request</Button>
        {!canSubmit && (
          <span className="text-[11px] text-buddy-text-secondary">
            {standing && action_ === 'suspension'
              ? 'A target, a reason and a duration are required.'
              : standing ? 'A target and a reason are required.' : 'A target user id is required.'}
          </span>
        )}
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
