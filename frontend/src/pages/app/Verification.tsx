import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Shield, Upload, CheckCircle, XCircle, Clock, Loader, Plus } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Input } from '@/components/ui/Input';
import { Modal } from '@/components/ui/Modal';
import { useToast } from '@/components/ui/Toast';
import { verificationApi, type VerificationSubmission } from '@/api/verification';

const VERIFICATION_TYPES = [
  { value: 'id', label: 'ID Verification', desc: 'Verify your identity with a government-issued ID' },
  { value: 'trainer', label: 'Trainer Certification', desc: 'Get certified as a personal trainer' },
  { value: 'practitioner', label: 'Health Practitioner', desc: 'Verify your health practitioner credentials' },
];

export default function Verification() {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [submissions, setSubmissions] = useState<VerificationSubmission[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [showSubmitModal, setShowSubmitModal] = useState(false);
  const [selectedType, setSelectedType] = useState('');
  const [documentUrl, setDocumentUrl] = useState('');
  const [notes, setNotes] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

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
      await verificationApi.createSubmission(selectedType, [docRes.data.id], notes || undefined);
      toast('success', 'Verification submission created!');
      setShowSubmitModal(false);
      setSelectedType('');
      setDocumentUrl('');
      setNotes('');
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
    <div className="max-w-lg mx-auto p-4">
      <div className="flex items-center justify-between mb-4">
        <h1 className="font-display text-2xl font-extrabold">Verification</h1>
        <Button size="sm" onClick={() => setShowSubmitModal(true)}>
          <Plus size={14} className="mr-1" /> New Request
        </Button>
      </div>

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
                <button key={t.value} onClick={() => setSelectedType(t.value)}
                  className={`w-full text-left p-3 rounded-xl border transition-colors ${selectedType === t.value ? 'border-buddy-green bg-buddy-green/10' : 'border-buddy-surface hover:border-buddy-green/40'}`}>
                  <p className="text-sm font-medium capitalize">{t.label}</p>
                  <p className="text-xs text-buddy-text-secondary mt-0.5">{t.desc}</p>
                </button>
              ))}
            </div>
          </div>
          <Input label="Document URL" placeholder="https://..." value={documentUrl} onChange={(e) => setDocumentUrl(e.target.value)} />
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
