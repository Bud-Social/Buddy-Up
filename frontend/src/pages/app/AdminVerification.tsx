import { useCallback, useEffect, useMemo, useState } from 'react';
import { CheckCircle2, RefreshCw, Search, ShieldCheck, ShieldAlert, XCircle, Stethoscope } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { verificationApi, type VerificationSubmission } from '@/api/verification';

const POLL_MS = 30_000;

const TYPE_LABELS: Record<string, string> = {
  id: 'ID Verification',
  trainer: 'Trainer Certification',
  practitioner: 'Health Practitioner',
  shop: 'Shop / Seller Verification',
  gym: 'Gym Verification',
};

const SCOPE_LABELS: Record<string, string> = {
  general_fitness: 'General Fitness Coaching',
  nutrition_wellness: 'General Wellness Nutrition',
  meal_planning: 'Meal Planning (General Wellness)',
  medical_nutrition: 'Medical Nutrition Therapy',
  physical_therapy: 'Physiotherapy / Rehab',
  clinical: 'Clinical Practice',
};

function statusBadge(status: string) {
  const map: Record<string, { variant: 'green' | 'orange' | 'red' | 'silver' | 'blue'; label: string }> = {
    draft: { variant: 'silver', label: 'Draft' },
    submitted: { variant: 'blue', label: 'Submitted' },
    under_review: { variant: 'orange', label: 'Under Review' },
    approved: { variant: 'green', label: 'Approved' },
    rejected: { variant: 'red', label: 'Rejected' },
    expired: { variant: 'silver', label: 'Expired' },
  };
  const b = map[status] || { variant: 'silver' as const, label: status };
  return <Badge variant={b.variant} label={b.label} size="sm" />;
}

export default function AdminVerification() {
  const [submissions, setSubmissions] = useState<VerificationSubmission[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [actingId, setActingId] = useState<string | null>(null);
  const [typeFilter, setTypeFilter] = useState<'all' | string>('all');
  const [query, setQuery] = useState('');
  const [expanded, setExpanded] = useState<string | null>(null);

  const load = useCallback((silent = false) => {
    if (!silent) setLoading(true);
    setError('');
    verificationApi.listSubmissions()
      .then((res) => setSubmissions(res.data || []))
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

  const act = useCallback(async (sub: VerificationSubmission, action: 'approve' | 'reject') => {
    setActingId(sub.id);
    setError('');
    try {
      await verificationApi.reviewSubmission(sub.id, action, action === 'reject' ? 'Rejected by administrator.' : undefined);
      await load(true);
    } catch {
      setError(`Failed to ${action} submission #${sub.id.slice(0, 8)}.`);
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
            Review identity, trainer, practitioner, shop &amp; gym submissions · {pending} pending
          </p>
        </div>
        <Button variant="outline" size="sm" onClick={() => load()} isLoading={loading}>
          <RefreshCw size={14} className="mr-1" /> Refresh
        </Button>
      </div>

      {error && (
        <div className="bg-buddy-red/5 border border-buddy-red/20 text-buddy-red text-xs rounded-xl px-3 py-2">{error}</div>
      )}

      <Card className="p-4 flex items-start gap-3">
        <Stethoscope size={20} className="text-buddy-green mt-0.5 shrink-0" />
        <div className="text-xs text-buddy-text-secondary">
          <p className="font-semibold text-buddy-text-primary mb-1">Scope-of-practice check</p>
          <p>
            Approving a trainer or practitioner also sets their platform <em>verification status</em> and their displayed badge.
            Practitioner approval permits professional guidance — confirm the declared scope of practice matches the credential provided.
            Shop &amp; gym approvals require a business registration document.
          </p>
        </div>
      </Card>

      <div className="flex flex-wrap items-center gap-2">
        {(['all', 'id', 'trainer', 'practitioner', 'shop', 'gym'] as const).map((t) => (
          <button
            key={t}
            onClick={() => setTypeFilter(t)}
            className={`text-xs px-2.5 py-1 rounded-lg capitalize transition-colors ${
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
          {filtered.map((sub) => (
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
                </div>
                <div className="flex items-center gap-2 flex-shrink-0">
                  {(sub.status === 'submitted' || sub.status === 'under_review') ? (
                    <>
                      <Button
                        variant="outline" size="sm"
                        disabled={actingId === sub.id}
                        onClick={() => act(sub, 'approve')}
                      >
                        <CheckCircle2 size={14} className="mr-1" /> Approve
                      </Button>
                      <Button
                        variant="destructive" size="sm"
                        disabled={actingId === sub.id}
                        onClick={() => act(sub, 'reject')}
                      >
                        <XCircle size={14} className="mr-1" /> Reject
                      </Button>
                    </>
                  ) : (
                    <span className="text-xs text-buddy-text-secondary">No action</span>
                  )}
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
