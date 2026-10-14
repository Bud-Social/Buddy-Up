import { useCallback, useEffect, useMemo, useState } from 'react';
import {
  CheckCircle2, Clock3, Hourglass, RefreshCw, Search, ShieldCheck, ShieldAlert,
  UserCheck, XCircle, Stethoscope,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { ReasonPrompt } from '@/pages/admin/shared';
import { formatDate } from '@/pages/admin/format';
import { verificationApi, type VerificationSubmission } from '@/api/verification';

const POLL_MS = 30_000;

/**
 * Verification review queue — **two-person only**.
 *
 * The buttons here used to call `review/` and report success. They were wrong:
 * `review/` answers **202** and applies nothing. It raises a decision request
 * and moves the submission to `under_review`; a *different* member of staff
 * has to call `decide/` before anything changes — no `Profile.verification_status`,
 * no `Gym.is_verified`, no granted role. The old page would have told a
 * reviewer they had approved a trainer when the applicant was still unverified.
 *
 * So the two acts are two separate affordances here:
 *
 * 1. **Request a decision** (the first person). After it resolves the row shows
 *    "awaiting a second approver", naming who asked and for what. Never
 *    "approved".
 * 2. **Decide** (the second person), shown only while `pending_approval` is
 *    non-null. The server refuses the same account with a 403; that refusal is
 *    rendered verbatim rather than swallowed into a generic failure, because it
 *    is the rule an operator is most likely to hit and least likely to
 *    understand unprompted.
 */

const TYPE_LABELS: Record<string, string> = {
  id: 'ID Verification',
  trainer: 'Trainer Certification',
  practitioner: 'Health Practitioner',
  shop: 'Shop / Seller Verification',
  gym: 'Gym Verification',
  gym_owner: 'Gym Owner',
  shop_owner: 'Shop Owner',
  delivery_partner: 'Delivery Partner',
};

const SCOPE_LABELS: Record<string, string> = {
  general_fitness: 'General Fitness Coaching',
  nutrition_wellness: 'General Wellness Nutrition',
  meal_planning: 'Meal Planning (General Wellness)',
  medical_nutrition: 'Medical Nutrition Therapy',
  physical_therapy: 'Physiotherapy / Rehab',
  clinical: 'Clinical Practice',
};

type Decision = 'approve' | 'reject';

function statusBadge(status: string) {
  const map: Record<string, { variant: 'green' | 'orange' | 'red' | 'silver' | 'blue'; label: string }> = {
    draft: { variant: 'silver', label: 'Draft' },
    submitted: { variant: 'blue', label: 'Submitted' },
    under_review: { variant: 'orange', label: 'Awaiting a second approver' },
    approved: { variant: 'green', label: 'Approved' },
    rejected: { variant: 'red', label: 'Rejected' },
    expired: { variant: 'silver', label: 'Expired' },
  };
  const b = map[status] || { variant: 'silver' as const, label: status };
  return <Badge variant={b.variant} label={b.label} size="sm" />;
}

/** The server's own words for a refusal, with a fallback if the body is empty. */
function decisionErrorMessage(error: unknown, fallback: string): string {
  const detail = (error as { response?: { data?: { detail?: string; message?: string } } })?.response?.data;
  return detail?.detail || detail?.message || fallback;
}

function isReviewable(sub: VerificationSubmission): boolean {
  return sub.status === 'submitted' || sub.status === 'under_review';
}

export default function AdminVerification() {
  const [submissions, setSubmissions] = useState<VerificationSubmission[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const [actingId, setActingId] = useState<string | null>(null);
  const [typeFilter, setTypeFilter] = useState<'all' | string>('all');
  const [query, setQuery] = useState('');
  const [reviewPrompt, setReviewPrompt] = useState<{ id: string; action: Decision } | null>(null);
  const [decidePrompt, setDecidePrompt] = useState<{ id: string; action: Decision } | null>(null);

  const load = useCallback((silent = false) => {
    if (!silent) setLoading(true);
    verificationApi.listSubmissions()
      .then((res) => { setSubmissions(res.data || []); setError(''); })
      .catch(() => { if (!silent) setError('Failed to load verification submissions. Staff access required.'); })
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => { load(); }, [load]);

  useEffect(() => {
    const timer = window.setInterval(() => load(true), POLL_MS);
    return () => window.clearInterval(timer);
  }, [load]);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    return submissions.filter((s) => {
      if (typeFilter !== 'all' && s.verification_type !== typeFilter) return false;
      if (q && !`${s.notes} ${s.credential_title} ${s.credential_issuer} ${s.credential_id} ${s.verification_type}`.toLowerCase().includes(q)) return false;
      return true;
    });
  }, [submissions, typeFilter, query]);

  const pending = submissions.filter((s) => ['submitted', 'under_review'].includes(s.status)).length;
  const awaitingSecond = submissions.filter((s) => s.pending_approval).length;

  /** First person: raise the request. Applies nothing, by design. */
  const requestReview = useCallback(async (id: string, action: Decision, reason: string) => {
    setActingId(id);
    setError('');
    setNotice('');
    try {
      await verificationApi.reviewSubmission(id, action, action === 'reject' ? reason : undefined);
      setNotice(
        'Decision requested. Nothing has been approved yet — a second member of staff must settle it, and it is not applied until they do.',
      );
      setReviewPrompt(null);
      await load(true);
    } catch (err) {
      setError(decisionErrorMessage(err, `Could not request a decision on submission #${id.slice(0, 8)}.`));
    } finally {
      setActingId(null);
    }
  }, [load]);

  /** Second person: settle it. This is the call that applies the effect. */
  const decide = useCallback(async (id: string, action: Decision, note: string) => {
    setActingId(id);
    setError('');
    setNotice('');
    try {
      const res = await verificationApi.decideSubmission(id, action, note);
      const applied = res?.approval?.applied_at;
      setNotice(
        action === 'approve'
          ? `Approved by ${res?.approval?.decided_by || 'a second approver'}. Effect recorded${applied ? ` at ${formatDate(applied)}` : ''}.`
          : `Rejected by ${res?.approval?.decided_by || 'a second approver'}. The applicant reads the note you left.`,
      );
      setDecidePrompt(null);
      await load(true);
    } catch (err) {
      // The requester-is-the-approver refusal arrives here and is shown as the
      // server phrased it, not flattened into "something went wrong".
      setError(decisionErrorMessage(err, `Could not settle the decision on submission #${id.slice(0, 8)}.`));
    } finally {
      setActingId(null);
    }
  }, [load]);

  if (loading && !submissions.length) {
    return (
      <div className="space-y-4">
        <Card className="h-24 animate-pulse bg-buddy-surface-raised" />
        <Card className="h-64 animate-pulse bg-buddy-surface-raised" />
      </div>
    );
  }

  if (error && !submissions.length) {
    return (
      <Card className="p-8 text-center">
        <ShieldAlert size={32} className="mx-auto text-buddy-red mb-3" />
        <p className="text-sm text-buddy-text-secondary mb-4">{error}</p>
        <Button variant="outline" size="sm" onClick={() => load()}><RefreshCw size={14} className="mr-1" /> Retry</Button>
      </Card>
    );
  }

  return (
    <div className="space-y-6 pb-8">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="font-display text-xl sm:text-2xl font-extrabold">Verification Review</h2>
          <p className="text-xs text-buddy-text-secondary mt-0.5">
            Two-person decisions · {pending} pending · {awaitingSecond} awaiting a second approver
          </p>
        </div>
        <Button variant="outline" size="sm" onClick={() => load()} isLoading={loading}>
          <RefreshCw size={14} className="mr-1" /> Refresh
        </Button>
      </div>

      {error && (
        <div className="bg-buddy-red/5 border border-buddy-red/20 text-buddy-red text-xs rounded-xl px-3 py-2 break-words">
          {error}
        </div>
      )}
      {notice && (
        <div className="bg-buddy-green/5 border border-buddy-green/20 text-buddy-green text-xs rounded-xl px-3 py-2 break-words">
          {notice}
        </div>
      )}

      <Card className="p-4 flex items-start gap-3">
        <UserCheck size={20} className="text-buddy-green mt-0.5 shrink-0" />
        <div className="text-xs text-buddy-text-secondary">
          <p className="font-semibold text-buddy-text-primary mb-1">Two-person rule</p>
          <p>
            <strong className="text-buddy-text-primary">Request a decision</strong> raises a request and changes
            nothing — the applicant stays unverified and no role is granted. A <em>different</em> member of
            staff then settles it with <strong className="text-buddy-text-primary">Decide</strong>, and only
            that call writes anything. The person who raised a request can never be the one who settles it,
            and nobody can decide their own application.
          </p>
        </div>
      </Card>

      <Card className="p-4 flex items-start gap-3">
        <Stethoscope size={20} className="text-buddy-green mt-0.5 shrink-0" />
        <div className="text-xs text-buddy-text-secondary">
          <p className="font-semibold text-buddy-text-primary mb-1">Scope-of-practice check</p>
          <p>
            Settling a trainer or practitioner approval also sets their platform <em>verification status</em>{' '}
            and grants the <code className="text-buddy-text-primary">trainer</code> / <code className="text-buddy-text-primary">practitioner</code> role.
            Confirm the declared scope of practice matches the credential provided. Shop &amp; gym approvals
            require a business registration document.
          </p>
        </div>
      </Card>

      <div className="flex flex-wrap items-center gap-2">
        {(['all', 'id', 'trainer', 'practitioner', 'shop', 'gym', 'gym_owner', 'shop_owner', 'delivery_partner'] as const).map((t) => (
          <button
            key={t}
            onClick={() => setTypeFilter(t)}
            aria-pressed={typeFilter === t}
            className={`text-xs px-2.5 py-1 rounded-lg transition-colors ${
              typeFilter === t
                ? 'bg-buddy-green/15 text-buddy-green font-semibold'
                : 'text-buddy-text-secondary hover:bg-buddy-surface-raised'
            }`}
          >
            {t === 'all' ? 'All' : TYPE_LABELS[t] || t}
          </button>
        ))}
        <div className="relative ml-auto">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-buddy-text-secondary" />
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search notes / credential…"
            aria-label="Search notes or credential"
            className="w-56 bg-buddy-surface-raised border border-buddy-surface rounded-xl pl-9 pr-3 py-2 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
          />
        </div>
      </div>

      {filtered.length === 0 ? (
        <Card className="p-8 text-center">
          <ShieldCheck size={32} className="mx-auto text-buddy-green/40 mb-3" />
          <p className="text-sm text-buddy-text-secondary">
            {submissions.length === 0 ? 'No verification submissions yet.' : 'No submissions match the current filter.'}
          </p>
        </Card>
      ) : (
        <div className="space-y-2">
          {filtered.map((sub) => {
            const owed = Boolean(sub.pending_approval);
            const settled = sub.approval_state && sub.approval_state.status !== 'pending' ? sub.approval_state : null;
            const promptOpen = reviewPrompt?.id === sub.id ? reviewPrompt.action : null;
            const decideOpen = decidePrompt?.id === sub.id ? decidePrompt.action : null;
            return (
              <Card key={sub.id} className="p-4">
                <div className="flex flex-wrap items-start gap-3">
                  <div className="flex-1 min-w-0">
                    <div className="flex flex-wrap items-center gap-2">
                      <span className="text-[11px] font-semibold uppercase tracking-wide text-buddy-text-primary">
                        {TYPE_LABELS[sub.verification_type] || sub.verification_type}
                      </span>
                      {statusBadge(sub.status)}
                      <span className="text-[11px] text-buddy-text-secondary font-mono">#{sub.id.slice(0, 8)}</span>
                      <span className="text-[11px] text-buddy-text-secondary">
                        · {sub.documents?.length || 0} document(s) · {new Date(sub.created_at).toLocaleDateString()}
                      </span>
                    </div>
                    {sub.credential_title && (
                      <p className="text-sm mt-2">
                        <span className="text-buddy-text-secondary text-xs">Credential:</span>{' '}
                        <span className="font-medium">{sub.credential_title}</span>
                        {sub.credential_issuer && <span className="text-buddy-text-secondary"> — {sub.credential_issuer}</span>}
                        {sub.credential_id && <span className="text-buddy-text-secondary"> ({sub.credential_id})</span>}
                      </p>
                    )}
                    {sub.scope_of_practice && (
                      <p className="text-xs text-buddy-text-secondary mt-0.5">
                        Scope: <span className="text-buddy-text-primary">{SCOPE_LABELS[sub.scope_of_practice] || sub.scope_of_practice}</span>
                      </p>
                    )}
                    {sub.notes && <p className="text-xs text-buddy-text-secondary mt-1.5 line-clamp-2">{sub.notes}</p>}
                    {sub.documents?.map((d) => (
                      <a key={d.id} href={d.file_url} target="_blank" rel="noreferrer"
                        className="inline-block text-xs text-buddy-green hover:underline mt-1.5 mr-2">
                        {d.document_type.replace(/_/g, ' ')} — {d.status}
                      </a>
                    ))}
                    {sub.gym_name && <p className="text-[11px] text-buddy-text-secondary mt-1">Gym: {sub.gym_name}</p>}

                    {owed && sub.pending_approval && (
                      <div
                        className="mt-3 rounded-xl border border-buddy-orange/30 bg-buddy-orange/5 p-3"
                        data-testid={`awaiting-second-${sub.id}`}
                      >
                        <p className="text-xs font-semibold text-buddy-orange flex items-center gap-1.5">
                          <Hourglass size={13} /> Awaiting a second approver
                        </p>
                        <p className="text-[11px] text-buddy-text-secondary mt-1">
                          Requested by {sub.pending_approval.requested_by_profile || 'a staff member'}
                          {sub.pending_approval.requested_at ? ` on ${formatDate(sub.pending_approval.requested_at)}` : ''}
                          {sub.pending_approval.decision
                            ? ` · proposes to ${sub.pending_approval.decision === 'approve' ? 'approve' : 'reject'}`
                            : ''}
                          . Nothing has been applied: the verification status, the gym flag and any granted role
                          are all still unchanged.
                        </p>
                        {sub.pending_approval.required_scope && (
                          <p className="text-[11px] text-buddy-text-secondary mt-1">
                            Approving requires the <code>{sub.pending_approval.required_scope}</code> scope.
                          </p>
                        )}
                      </div>
                    )}

                    {settled && (
                      <div className="mt-3 rounded-xl border border-buddy-surface-raised p-3 text-[11px] text-buddy-text-secondary">
                        <p>
                          <span className="font-semibold text-buddy-text-primary">Settled</span> by{' '}
                          {settled.decided_by || 'a second approver'} on {formatDate(settled.decided_at)} —
                          request {settled.status}
                          {settled.decision ? `, ${settled.decision === 'approve' ? 'approved' : 'rejected'}` : ''}
                          {settled.applied_at ? `, applied ${formatDate(settled.applied_at)}` : ''}.
                        </p>
                        {settled.decision_note && (
                          <p className="mt-1 break-words">
                            <span className="font-medium text-buddy-text-primary">Note to applicant: </span>
                            {settled.decision_note}
                          </p>
                        )}
                      </div>
                    )}
                  </div>

                  <div className="flex flex-col items-end gap-2 flex-shrink-0">
                    {isReviewable(sub) && !owed ? (
                      <>
                        <Button
                          variant="outline" size="sm"
                          disabled={actingId === sub.id}
                          onClick={() => setReviewPrompt({ id: sub.id, action: 'approve' })}
                        >
                          <CheckCircle2 size={14} className="mr-1" /> Request approval
                        </Button>
                        <Button
                          variant="destructive" size="sm"
                          disabled={actingId === sub.id}
                          onClick={() => setReviewPrompt({ id: sub.id, action: 'reject' })}
                        >
                          <XCircle size={14} className="mr-1" /> Request rejection
                        </Button>
                      </>
                    ) : owed ? (
                      <>
                        <Button
                          size="sm"
                          disabled={actingId === sub.id}
                          onClick={() => setDecidePrompt({ id: sub.id, action: 'approve' })}
                        >
                          <UserCheck size={14} className="mr-1" /> Decide: approve
                        </Button>
                        <Button
                          variant="destructive" size="sm"
                          disabled={actingId === sub.id}
                          onClick={() => setDecidePrompt({ id: sub.id, action: 'reject' })}
                        >
                          <XCircle size={14} className="mr-1" /> Decide: reject
                        </Button>
                      </>
                    ) : (
                      <span className="text-xs text-buddy-text-secondary flex items-center gap-1">
                        <Clock3 size={12} /> No action
                      </span>
                    )}
                  </div>
                </div>

                {promptOpen && (
                  <ReasonPrompt
                    open
                    action={promptOpen === 'approve' ? 'approved' : 'rejected'}
                    placeholder={
                      promptOpen === 'approve'
                        ? 'Optional note on why you are recommending approval.'
                        : 'Why should this be rejected? The applicant reads this.'
                    }
                    busy={actingId === sub.id}
                    submitLabel="Request decision"
                    onSubmit={(reason) => requestReview(sub.id, promptOpen, reason)}
                    onCancel={() => setReviewPrompt(null)}
                  />
                )}

                {decideOpen && (
                  <ReasonPrompt
                    open
                    action={decideOpen === 'approve' ? 'approved' : 'rejected'}
                    placeholder={
                      decideOpen === 'approve'
                        ? 'Optional note recorded against the decision.'
                        : 'A rejection must say why. This note is what the applicant reads.'
                    }
                    busy={actingId === sub.id}
                    submitLabel="Settle decision"
                    onSubmit={(note) => decide(sub.id, decideOpen, note)}
                    onCancel={() => setDecidePrompt(null)}
                  />
                )}
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}