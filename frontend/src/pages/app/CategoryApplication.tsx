import { useCallback, useEffect, useMemo, useState } from 'react';
import { BadgeCheck, ClipboardList, Hourglass, Loader, Plus, RefreshCw, ShieldQuestion } from 'lucide-react';
import { Link } from 'react-router-dom';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Input } from '@/components/ui/Input';
import { useToast } from '@/components/ui/Toast';
import { formatDate } from '@/pages/admin/format';
import {
  verificationApi,
  type CategoryApplicationType,
  type VerificationSubmission,
} from '@/api/verification';

/**
 * Apply for an elevated role, and track the applications you have made.
 *
 * This page exists because registration stopped accepting a role. Every account
 * is created as `user`, and `trainer` / `practitioner` are granted when a
 * **verification decision** is approved — two members of staff, one of whom must
 * be somebody other than the person who raised the request, and neither of whom
 * may be the applicant. A user told "register as a trainer" now has to be told
 * where that went, and this is the place.
 *
 * The per-category field requirements are the server's, not this page's: it
 * validates before a row exists, so an application missing its credential
 * number is refused at the door rather than arriving in a reviewer's queue to be
 * rejected for an administrative reason. Mirroring those rules here is only so
 * the applicant finds out before the round trip.
 */

const CATEGORIES: Array<{ value: CategoryApplicationType; label: string; blurb: string }> = [
  { value: 'trainer', label: 'Trainer', blurb: 'Certified personal trainer. Unlocks bookings, programmes and payouts.' },
  { value: 'practitioner', label: 'Health practitioner', blurb: 'Licensed clinician. Your verified scope limits the guidance you may give.' },
  { value: 'gym_owner', label: 'Gym owner', blurb: 'Own or run a gym on the platform.' },
  { value: 'shop_owner', label: 'Shop owner', blurb: 'Sell products, meal plans or programmes through a shop.' },
  { value: 'distributor', label: 'Distributor', blurb: 'Supply products and host marketplace events.' },
  { value: 'delivery_partner', label: 'Delivery partner', blurb: 'Deliver orders as an independent courier.' },
];

/** `apps.verification.models.VerificationSubmission.scope_of_practice` choices. */
const SCOPE_OPTIONS = [
  { value: 'general_fitness', label: 'General Fitness Coaching' },
  { value: 'nutrition_wellness', label: 'General Wellness Nutrition' },
  { value: 'meal_planning', label: 'Meal Planning (General Wellness)' },
  { value: 'medical_nutrition', label: 'Medical Nutrition Therapy' },
  { value: 'physical_therapy', label: 'Physiotherapy / Rehab' },
  { value: 'clinical', label: 'Clinical Practice' },
];

const TYPE_LABELS: Record<string, string> = {
  trainer: 'Trainer',
  practitioner: 'Health practitioner',
  gym_owner: 'Gym owner',
  shop_owner: 'Shop owner',
  distributor: 'Distributor',
  delivery_partner: 'Delivery partner',
  id: 'Identity',
  shop: 'Shop / seller',
  gym: 'Gym',
};

/** Mirrors `REQUIRED_FIELDS_BY_TYPE`. */
const REQUIRED: Record<string, string[]> = {
  trainer: ['credential_title', 'credential_issuer', 'credential_id', 'issued_date', 'scope_of_practice'],
  practitioner: ['credential_title', 'credential_issuer', 'credential_id', 'issued_date', 'scope_of_practice'],
  gym_owner: ['credential_title', 'credential_issuer', 'credential_id'],
  shop_owner: ['credential_title', 'credential_issuer', 'credential_id'],
  distributor: ['credential_title', 'credential_issuer', 'credential_id'],
  delivery_partner: ['credential_title', 'credential_issuer', 'credential_id'],
};

function statusBadge(status: string) {
  const map: Record<string, { variant: 'green' | 'orange' | 'red' | 'silver' | 'blue'; label: string }> = {
    draft: { variant: 'silver', label: 'Draft' },
    submitted: { variant: 'blue', label: 'Submitted' },
    under_review: { variant: 'orange', label: 'With a reviewer' },
    approved: { variant: 'green', label: 'Approved' },
    rejected: { variant: 'red', label: 'Rejected' },
  };
  const b = map[status] || { variant: 'silver' as const, label: status };
  return <Badge variant={b.variant} label={b.label} size="sm" />;
}

export default function CategoryApplication() {
  const { toast } = useToast();
  const [tab, setTab] = useState<'apply' | 'mine'>('apply');

  const [category, setCategory] = useState<CategoryApplicationType>('trainer');
  const [credentialTitle, setCredentialTitle] = useState('');
  const [credentialIssuer, setCredentialIssuer] = useState('');
  const [credentialId, setCredentialId] = useState('');
  const [issuedDate, setIssuedDate] = useState('');
  const [scope, setScope] = useState('');
  const [gymHandle, setGymHandle] = useState('');
  const [notes, setNotes] = useState('');
  const [documentUrl, setDocumentUrl] = useState('');
  const [documentIds, setDocumentIds] = useState<string[]>([]);
  const [submitting, setSubmitting] = useState(false);
  const [formError, setFormError] = useState('');

  const [applications, setApplications] = useState<VerificationSubmission[]>([]);
  const [loadingApps, setLoadingApps] = useState(true);
  const [appsError, setAppsError] = useState('');

  const loadApplications = useCallback(() => {
    setLoadingApps(true);
    verificationApi.getMyApplications()
      .then((res) => { setApplications(res.data || []); setAppsError(''); })
      .catch(() => setAppsError('Could not load your applications.'))
      .finally(() => setLoadingApps(false));
  }, []);

  useEffect(() => { loadApplications(); }, [loadApplications]);

  const needsProfessional = category === 'trainer' || category === 'practitioner';
  const missing = useMemo(
    () => (REQUIRED[category] || []).filter((field) => {
      if (field === 'scope_of_practice') return !scope;
      return !({ credential_title: credentialTitle, credential_issuer: credentialIssuer, credential_id: credentialId, issued_date: issuedDate }[field] || '').trim();
    }),
    [category, credentialTitle, credentialIssuer, credentialId, issuedDate, scope],
  );
  const needsGym = category === 'gym_owner';
  const blocked = missing.length > 0 || documentIds.length === 0 || (needsGym && !gymHandle.trim());

  const attachDocument = useCallback(async () => {
    const url = documentUrl.trim();
    if (!url) return;
    setFormError('');
    try {
      const res = await verificationApi.uploadDocument('certification', url);
      if (res.data?.id) setDocumentIds((ids) => [...ids, res.data.id]);
      setDocumentUrl('');
    } catch {
      setFormError('That document could not be stored. Check the URL and try again.');
    }
  }, [documentUrl]);

  const submit = useCallback(async () => {
    setSubmitting(true);
    setFormError('');
    try {
      await verificationApi.applyForCategory({
        category,
        credential_title: credentialTitle.trim(),
        credential_issuer: credentialIssuer.trim(),
        credential_id: credentialId.trim(),
        ...(issuedDate ? { issued_date: issuedDate } : {}),
        ...(scope ? { scope_of_practice: scope } : {}),
        ...(gymHandle.trim() ? { gym_handle: gymHandle.trim() } : {}),
        document_ids: documentIds,
        ...(notes.trim() ? { notes: notes.trim() } : {}),
      });
      toast('success', 'Application submitted. It goes to two reviewers, not one.');
      setCredentialTitle(''); setCredentialIssuer(''); setCredentialId('');
      setIssuedDate(''); setScope(''); setGymHandle(''); setNotes(''); setDocumentIds([]);
      setTab('mine');
      loadApplications();
    } catch (err: unknown) {
      const body = (err as { response?: { data?: { detail?: string; errors?: Record<string, string[]> } } })?.response?.data;
      const detail = body?.errors
        ? Object.entries(body.errors).map(([k, v]) => `${k}: ${v.join(' ')}`).join(' ')
        : '';
      setFormError(body?.detail || detail || 'The application was refused. Check the fields and try again.');
    } finally {
      setSubmitting(false);
    }
  }, [category, credentialTitle, credentialIssuer, credentialId, issuedDate, scope, gymHandle, documentIds, notes, toast, loadApplications]);

  return (
    <div className="max-w-2xl lg:max-w-3xl mx-auto p-4 space-y-5">
      <div>
        <h1 className="font-display text-2xl font-extrabold">Professional categories</h1>
        <p className="text-xs text-buddy-text-secondary mt-0.5">
          Trainer and practitioner standing is granted after review. It cannot be chosen at sign-up, and one
          person cannot grant it to themselves.
        </p>
      </div>

      <div className="flex items-center gap-2">
        {([['apply', 'Apply'], ['mine', 'My applications']] as const).map(([id, label]) => (
          <button
            key={id}
            type="button"
            aria-pressed={tab === id}
            onClick={() => setTab(id)}
            className={`text-xs px-3 py-1.5 rounded-lg transition-colors ${
              tab === id ? 'bg-buddy-green/15 text-buddy-green font-semibold' : 'text-buddy-text-secondary hover:bg-buddy-surface-raised'
            }`}
          >
            {label}
          </button>
        ))}
      </div>

      {tab === 'apply' ? (
        <div className="space-y-4">
          <Card className="p-4 space-y-3">
            <div>
              <label className="block text-sm font-medium text-buddy-text-primary mb-2" htmlFor="category">Category</label>
              <div className="space-y-2" id="category">
                {CATEGORIES.map((option) => (
                  <button
                    key={option.value}
                    type="button"
                    aria-pressed={category === option.value}
                    onClick={() => setCategory(option.value)}
                    className={`w-full text-left p-3 rounded-xl border transition-colors ${
                      category === option.value ? 'border-buddy-green bg-buddy-green/10' : 'border-buddy-surface hover:border-buddy-green/40'
                    }`}
                  >
                    <p className="text-sm font-medium">{option.label}</p>
                    <p className="text-xs text-buddy-text-secondary mt-0.5">{option.blurb}</p>
                  </button>
                ))}
              </div>
            </div>

            <Input label="Credential title" placeholder="e.g. Certified Personal Trainer" value={credentialTitle} onChange={(e) => setCredentialTitle(e.target.value)} />
            <Input label="Issuing body" placeholder="e.g. REPs Kenya, ACSM, Registrar of Companies" value={credentialIssuer} onChange={(e) => setCredentialIssuer(e.target.value)} />
            <Input label="Credential / registration number" placeholder="e.g. Certification number" value={credentialId} onChange={(e) => setCredentialId(e.target.value)} />

            {needsProfessional && (
              <>
                <div>
                  <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5" htmlFor="issued_date">Date issued</label>
                  <input
                    id="issued_date"
                    type="date"
                    value={issuedDate}
                    onChange={(e) => setIssuedDate(e.target.value)}
                    className="w-full bg-buddy-surface rounded-xl px-4 py-2.5 text-sm text-buddy-text-primary focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5" htmlFor="scope">Scope of practice</label>
                  <select
                    id="scope"
                    value={scope}
                    onChange={(e) => setScope(e.target.value)}
                    className="w-full bg-buddy-surface rounded-xl px-3 py-2.5 text-sm text-buddy-text-primary focus:outline-none focus:border-buddy-green"
                  >
                    <option value="">Select a scope…</option>
                    {SCOPE_OPTIONS.map((option) => (
                      <option key={option.value} value={option.value}>{option.label}</option>
                    ))}
                  </select>
                  <p className="text-[11px] text-buddy-orange mt-1.5">
                    Your verified scope limits what advice you may give. Medical claims outside a licensed
                    scope are prohibited.
                  </p>
                </div>
              </>
            )}

            {needsGym && (
              <Input label="Gym handle" placeholder="e.g. nairobi-iron" value={gymHandle} onChange={(e) => setGymHandle(e.target.value)} />
            )}

            <div>
              <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5" htmlFor="doc-url">Supporting document</label>
              <div className="flex gap-2">
                <input
                  id="doc-url"
                  value={documentUrl}
                  onChange={(e) => setDocumentUrl(e.target.value)}
                  placeholder="https://… (your certificate scan)"
                  className="flex-1 bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
                />
                <Button variant="outline" size="sm" disabled={!documentUrl.trim()} onClick={attachDocument}>
                  <Plus size={14} className="mr-1" /> Attach
                </Button>
              </div>
              <p className="text-[11px] text-buddy-text-secondary mt-1.5">
                {documentIds.length
                  ? `${documentIds.length} document(s) attached.`
                  : 'At least one document is required — a credential number with nothing behind it cannot be reviewed.'}
              </p>
            </div>

            <textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder="Anything the reviewer should know (optional)"
              aria-label="Notes for the reviewer"
              className="w-full bg-buddy-surface rounded-xl px-4 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none h-20"
            />

            {formError && (
              <p className="text-[11px] text-buddy-red break-words">{formError}</p>
            )}

            <div className="flex items-center gap-3">
              <Button onClick={submit} isLoading={submitting} disabled={blocked}>
                Submit application
              </Button>
              {blocked && (
                <p className="text-[11px] text-buddy-text-secondary">
                  {missing.length > 0
                    ? `Still needed: ${missing.map((f) => f.replace(/_/g, ' ')).join(', ')}.`
                    : needsGym && !gymHandle.trim()
                      ? 'Name the gym you are applying to run.'
                      : 'Attach a supporting document.'}
                </p>
              )}
            </div>
          </Card>

          <Card className="p-4 flex items-start gap-3">
            <ShieldQuestion size={18} className="text-buddy-green mt-0.5 shrink-0" />
            <p className="text-[11px] text-buddy-text-secondary">
              Who decides: one member of staff reviews your application and recommends a decision, then a{' '}
              <em>different</em> member of staff settles it. Neither can be you. Until that second person
              acts, your verification status and any role are unchanged — you will see the state on
              &ldquo;My applications&rdquo;.
            </p>
          </Card>
        </div>
      ) : (
        <div className="space-y-3">
          <div className="flex items-center justify-between">
            <p className="text-xs text-buddy-text-secondary">
              {applications.length} application{applications.length === 1 ? '' : 's'}
            </p>
            <Button variant="ghost" size="sm" onClick={loadApplications} aria-label="Refresh my applications">
              <RefreshCw size={14} className="mr-1" /> Refresh
            </Button>
          </div>

          {loadingApps && (
            <Card className="p-8 text-center"><Loader size={20} className="animate-spin mx-auto text-buddy-text-secondary" /></Card>
          )}

          {appsError && <p className="text-xs text-buddy-red">{appsError}</p>}

          {!loadingApps && !appsError && applications.length === 0 && (
            <Card className="p-8 text-center">
              <ClipboardList size={28} className="mx-auto text-buddy-green/40 mb-2" />
              <p className="text-sm text-buddy-text-secondary">You have not applied for a category yet.</p>
              <p className="text-xs text-buddy-text-secondary/80 mt-1">
                Identity verification is separate and lives on the Verification page.
              </p>
            </Card>
          )}

          {applications.map((application) => {
            const settled = application.approval_state && application.approval_state.status !== 'pending'
              ? application.approval_state
              : null;
            return (
              <Card key={application.id} className="p-4" data-testid="my-application">
                <div className="flex flex-wrap items-center gap-2">
                  <span className="text-sm font-semibold">
                    {TYPE_LABELS[application.verification_type] || application.verification_type}
                  </span>
                  {statusBadge(application.status)}
                  <span className="text-[11px] text-buddy-text-secondary">
                    {formatDate(application.submitted_at || application.created_at)}
                  </span>
                </div>

                {application.credential_title && (
                  <p className="text-xs text-buddy-text-secondary mt-1.5">
                    {application.credential_title}
                    {application.credential_issuer ? ` — ${application.credential_issuer}` : ''}
                    {application.credential_id ? ` (${application.credential_id})` : ''}
                  </p>
                )}

                {application.pending_approval && (
                  <p className="text-[11px] text-buddy-orange mt-2 flex items-start gap-1.5">
                    <Hourglass size={12} className="mt-0.5 shrink-0" />
                    <span>
                      A reviewer has recommended{' '}
                      {application.pending_approval.decision === 'approve' ? 'approval' : 'rejection'}. A second
                      approver still has to settle it — nothing has been granted yet.
                    </span>
                  </p>
                )}

                {settled && (
                  <div className="mt-2 rounded-xl border border-buddy-surface-raised p-3 text-[11px] text-buddy-text-secondary">
                    <p className="flex items-center gap-1.5">
                      <BadgeCheck size={12} />
                      <span className="font-medium text-buddy-text-primary">
                        {settled.decision === 'approve' ? 'Approved' : 'Rejected'}
                      </span>
                      {settled.decided_at ? `on ${formatDate(settled.decided_at)}` : ''}
                    </p>
                    {settled.decision_note && (
                      <p className="mt-1 break-words">
                        <span className="font-medium text-buddy-text-primary">Reviewer&apos;s note: </span>
                        {settled.decision_note}
                      </p>
                    )}
                  </div>
                )}

                {application.documents?.map((document) => (
                  <a key={document.id} href={document.file_url} target="_blank" rel="noreferrer"
                    className="inline-block text-[11px] text-buddy-green hover:underline mt-2 mr-2">
                    {document.document_type.replace(/_/g, ' ')}
                  </a>
                ))}
              </Card>
            );
          })}

          <p className="text-[11px] text-buddy-text-secondary">
            Need identity verification instead?{' '}
            <Link to="/verification" className="text-buddy-green hover:underline">Open the Verification page</Link>.
          </p>
        </div>
      )}
    </div>
  );
}
