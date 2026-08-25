import { useState, useEffect } from 'react';

import { Shield, CheckCircle, Clock, Plus } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Input } from '@/components/ui/Input';
import { Modal } from '@/components/ui/Modal';
import { useToast } from '@/components/ui/Toast';
import { verificationApi, type VerificationSubmission } from '@/api/verification';
import { IdVerificationWizard } from '@/components/verification/IdVerificationWizard';

const VERIFICATION_TYPES = [
  { value: 'id', label: 'ID Verification', desc: 'Verify your identity with a government-issued ID' },
  { value: 'trainer', label: 'Trainer Certification', desc: 'Get certified as a personal trainer' },
  { value: 'practitioner', label: 'Health Practitioner', desc: 'Verify your health practitioner credentials' },
  { value: 'shop', label: 'Shop / Seller Verification', desc: 'Verify your shop or seller business' },
  { value: 'gym', label: 'Gym Verification', desc: 'Verify your gym or training facility' },
];

const SCOPE_OPTIONS = [
  { value: 'general_fitness', label: 'General Fitness Coaching' },
  { value: 'nutrition_wellness', label: 'General Wellness Nutrition' },
  { value: 'meal_planning', label: 'Meal Planning (General Wellness)' },
  { value: 'medical_nutrition', label: 'Medical Nutrition Therapy' },
  { value: 'physical_therapy', label: 'Physiotherapy / Rehab' },
  { value: 'clinical', label: 'Clinical Practice' },
];

const NEEDS_CREDENTIALS = ['trainer', 'practitioner', 'shop'];

export default function Verification() {
  const { toast } = useToast();
  const [submissions, setSubmissions] = useState<VerificationSubmission[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [showSubmitModal, setShowSubmitModal] = useState(false);
  const [showIdWizard, setShowIdWizard] = useState(false);
  const [selectedType, setSelectedType] = useState('');
  const [documentUrl, setDocumentUrl] = useState('');
  const [notes, setNotes] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const [credentialTitle, setCredentialTitle] = useState('');
  const [credentialIssuer, setCredentialIssuer] = useState('');
  const [credentialId, setCredentialId] = useState('');
  const [issuedDate, setIssuedDate] = useState('');
  const [scopeOfPractice, setScopeOfPractice] = useState('');

  const fetchSubmissions = async () => {
    setIsLoading(true);
    try {
      const res = await verificationApi.listSubmissions();
      setSubmissions(res.data || []);
    } catch {
      toast('error', 'Failed to load verification submissions');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => { fetchSubmissions(); }, []);

  const handleSubmit = async () => {
    if (!selectedType || !documentUrl) {
      toast('error', 'Please select a verification type and provide a document URL');
      return;
    }
    setIsSubmitting(true);
    try {
      const docRes = await verificationApi.uploadDocument(selectedType === 'id' ? 'id_card' : 'certification', documentUrl);
      await verificationApi.createSubmission(selectedType, [docRes.data.id], notes || undefined, {
        credential_title: credentialTitle || undefined,
        credential_issuer: credentialIssuer || undefined,
        credential_id: credentialId || undefined,
        issued_date: issuedDate || undefined,
        scope_of_practice: scopeOfPractice || undefined,
      });
      toast('success', 'Verification submission created!');
      setShowSubmitModal(false);
      setSelectedType('');
      setDocumentUrl('');
      setNotes('');
      setCredentialTitle('');
      setCredentialIssuer('');
      setCredentialId('');
      setIssuedDate('');
      setScopeOfPractice('');
      fetchSubmissions();
    } catch {
      toast('error', 'Failed to create verification submission');
    } finally {
      setIsSubmitting(false);
    }
  };

  const statusBadge = (status: string) => {
    const map: Record<string, { variant: 'green' | 'orange' | 'red' | 'silver' | 'blue'; label: string }> = {
      draft: { variant: 'silver', label: 'Draft' },
      submitted: { variant: 'blue', label: 'Submitted' },
      under_review: { variant: 'orange', label: 'Under Review' },
      approved: { variant: 'green', label: 'Approved' },
      rejected: { variant: 'red', label: 'Rejected' },
    };
    const b = map[status] || { variant: 'silver' as const, label: status };
    return <Badge variant={b.variant} label={b.label} size="sm" />;
  };

  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4">
      <div className="flex items-center justify-between mb-4">
        <h1 className="font-display text-2xl font-extrabold">Verification</h1>
        <Button size="sm" onClick={() => setShowIdWizard(true)}>
          <Plus size={14} className="mr-1" /> New Request
        </Button>
      </div>

      {showIdWizard && (
        <div className="mb-4">
          <IdVerificationWizard onDone={() => { setShowIdWizard(false); fetchSubmissions(); }} />
        </div>
      )}

      <Card className="p-4 mb-4">
        <div className="flex items-start gap-3">
          <Shield size={24} className="text-buddy-green mt-1" />
          <div>
            <h3 className="font-heading font-semibold text-sm">Why verify?</h3>
            <p className="text-xs text-buddy-text-secondary mt-1">
              Verification badges help build trust in the community. Verify your identity, trainer certifications, or practitioner credentials to unlock special badges and features.
            </p>
          </div>
        </div>
      </Card>

      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 2 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse"><div className="h-16 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : submissions.length === 0 ? (
        <div className="text-center py-20">
          <Shield size={48} className="mx-auto text-buddy-text-secondary/30 mb-4" />
          <p className="text-buddy-text-secondary">No verification submissions yet</p>
          <p className="text-buddy-text-secondary/50 text-sm mt-1">Submit your first verification request to get verified!</p>
        </div>
      ) : (
        <div className="space-y-3">
          {submissions.map((sub) => (
            <Card key={sub.id} className="p-4">
              <div className="flex items-start justify-between mb-2">
                <div>
                  <h3 className="font-heading font-semibold text-sm capitalize">{sub.verification_type.replace('_', ' ')} Verification</h3>
                  <p className="text-xs text-buddy-text-secondary mt-0.5">
                    Submitted {new Date(sub.created_at).toLocaleDateString()}
                  </p>
                </div>
                {statusBadge(sub.status)}
              </div>
              {sub.status === 'draft' && (
                <Button size="sm" variant="outline" className="mt-2" onClick={async () => {
                  try {
                    await verificationApi.submitDraft(sub.id);
                    toast('success', 'Submission sent for review!');
                    fetchSubmissions();
                  } catch {
                    toast('error', 'Failed to submit');
                  }
                }}>
                  <CheckCircle size={14} className="mr-1" /> Submit for Review
                </Button>
              )}
              {sub.status === 'rejected' && sub.documents?.[0]?.rejection_reason && (
                <p className="text-xs text-buddy-red mt-2">Reason: {sub.documents[0].rejection_reason}</p>
              )}
              {(sub.credential_title || sub.scope_of_practice) && (
                <div className="mt-2 space-y-0.5 text-xs text-buddy-text-secondary">
                  {sub.credential_title && (
                    <p><span className="font-medium">Credential:</span> {sub.credential_title}{sub.credential_issuer ? ` — ${sub.credential_issuer}` : ''}{sub.credential_id ? ` (${sub.credential_id})` : ''}</p>
                  )}
                  {sub.scope_of_practice && (
                    <p><span className="font-medium">Scope:</span> {SCOPE_OPTIONS.find((s) => s.value === sub.scope_of_practice)?.label || sub.scope_of_practice.replace(/_/g, ' ')}</p>
                  )}
                </div>
              )}
              <div className="flex items-center gap-2 mt-2 text-xs text-buddy-text-secondary">
                <Clock size={12} /> {sub.documents?.length || 0} document(s)
              </div>
            </Card>
          ))}
        </div>
      )}

      <Modal isOpen={showSubmitModal} onClose={() => setShowSubmitModal(false)} title="New Verification Request">
        <div className="space-y-4">
          <div>
            <label className="text-sm font-medium block mb-2">Verification Type</label>
            <div className="space-y-2">
              {VERIFICATION_TYPES.map((t) => (
                <button key={t.value} onClick={() => {
                  if (t.value === 'id') {
                    setShowSubmitModal(false);
                    setShowIdWizard(true);
                    return;
                  }
                  setSelectedType(t.value);
                }}
                  className={`w-full text-left p-3 rounded-xl border transition-colors ${selectedType === t.value ? 'border-buddy-green bg-buddy-green/10' : 'border-buddy-surface hover:border-buddy-green/40'}`}>
                  <p className="text-sm font-medium capitalize">{t.label}</p>
                  <p className="text-xs text-buddy-text-secondary mt-0.5">{t.desc}</p>
                </button>
              ))}
            </div>
          </div>
          <Input label="Document URL" placeholder="https://..." value={documentUrl} onChange={(e) => setDocumentUrl(e.target.value)} />
          {NEEDS_CREDENTIALS.includes(selectedType) && (
            <div className="space-y-3 rounded-xl border border-buddy-surface-raised p-3">
              <p className="text-xs font-medium text-buddy-text-secondary uppercase tracking-wide">Credential Details</p>
              <Input label="Credential Title" placeholder="e.g. Certified Personal Trainer, Business Registration" value={credentialTitle} onChange={(e) => setCredentialTitle(e.target.value)} />
              <Input label="Issuer" placeholder="e.g. REPs Kenya, ACSM, Registrar of Companies" value={credentialIssuer} onChange={(e) => setCredentialIssuer(e.target.value)} />
              <Input label="Credential / Registration ID" placeholder="e.g. Certification number" value={credentialId} onChange={(e) => setCredentialId(e.target.value)} />
              <div>
                <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Issued Date</label>
                <input
                  type="date"
                  value={issuedDate}
                  onChange={(e) => setIssuedDate(e.target.value)}
                  className="w-full bg-buddy-surface rounded-xl px-4 py-2.5 text-sm text-buddy-text-primary focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                />
              </div>
              {selectedType === 'trainer' || selectedType === 'practitioner' ? (
                <div>
                  <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Scope of Practice</label>
                  <div className="grid grid-cols-1 gap-1.5">
                    {SCOPE_OPTIONS.map((s) => (
                      <button key={s.value} type="button" onClick={() => setScopeOfPractice(s.value)}
                        className={`w-full text-left px-3 py-2 rounded-lg border text-xs transition-colors ${scopeOfPractice === s.value ? 'border-buddy-green bg-buddy-green/10 text-buddy-text-primary' : 'border-buddy-surface-raised text-buddy-text-secondary hover:border-buddy-green/40'}`}>
                        {s.label}
                      </button>
                    ))}
                  </div>
                  <p className="text-[11px] text-buddy-orange mt-1.5">
                    Your verified scope limits what advice you may provide. Medical claims outside a licensed scope are prohibited.
                  </p>
                </div>
              ) : (
                <p className="text-[11px] text-buddy-text-secondary">
                  Business verification requires a registration document. Provide the registered name and number above.
                </p>
              )}
            </div>
          )}
          <textarea
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            placeholder="Additional notes (optional)"
            className="w-full bg-buddy-surface rounded-xl px-4 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none h-20"
          />
          <div className="flex gap-2">
            <Button variant="ghost" onClick={() => setShowSubmitModal(false)} className="flex-1">Cancel</Button>
            <Button onClick={handleSubmit} isLoading={isSubmitting} className="flex-1">Submit</Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}
