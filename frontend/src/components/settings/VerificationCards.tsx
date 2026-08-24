/**
 * VerificationCards – functional age verification + professional badge
 * application flows for Settings → Verifications. Replaces the old
 * "coming soon" stubs; submissions land in the admin review queue.
 */
import { useRef, useState } from 'react';
import { CheckCircle, Loader, ShieldCheck } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { useToast } from '@/components/ui/Toast';
import { apiClient } from '@/api/client';
import { messagingApi } from '@/api/messaging';
import { verificationApi } from '@/api/verification';
import type { ApiResponse } from '@/types';

/** Persist DOB server-side and report the computed adult status. */
async function submitDob(dateOfBirth: string): Promise<{ age: number; is_adult: boolean }> {
  const res = await apiClient.post<ApiResponse<{ age: number; is_adult: boolean }>>(
    '/auth/social/age-setup/',
    { date_of_birth: dateOfBirth },
  );
  return res.data.data as { age: number; is_adult: boolean };
}

export function AgeVerificationCard() {
  const { toast } = useToast();
  const [dob, setDob] = useState('');
  const [saving, setSaving] = useState(false);
  const [result, setResult] = useState<{ age: number; is_adult: boolean } | null>(null);

  const handleVerify = async () => {
    if (!dob) return;
    setSaving(true);
    try {
      const r = await submitDob(dob);
      setResult(r);
      toast(r.is_adult ? 'success' : 'info',
        r.is_adult ? 'Age verified — mature content unlocked.' : `Age recorded (${r.age}). Accounts under 18 have restricted access.`);
    } catch (err: unknown) {
      const msg = (err as { response?: { data?: { message?: string } } })?.response?.data?.message || 'Verification failed';
      toast('error', msg);
    } finally {
      setSaving(false);
    }
  };

  return (
    <Card className="p-4 space-y-4">
      <div>
        <p className="text-sm font-medium">Age Verification</p>
        <p className="text-xs text-buddy-text-secondary mb-2">
          Required for accessing mature content and gyms. Your date of birth is
          stored only as a secure hash.
        </p>
        {result ? (
          <p className="text-sm text-buddy-green flex items-center gap-1.5">
            <CheckCircle size={15} /> Verified — age {result.age} ({result.is_adult ? 'adult' : 'minor'}).
          </p>
        ) : (
          <div className="flex gap-2 items-end">
            <Input
              type="date"
              value={dob}
              onChange={(e) => setDob(e.target.value)}
              className="max-w-[180px]"
              title="Date of birth"
            />
            <Button size="sm" variant="outline" onClick={handleVerify} isLoading={saving} disabled={!dob || saving}>
              Verify Age
            </Button>
          </div>
        )}
      </div>
    </Card>
  );
}

const BADGE_TYPES = [
  { value: 'trainer', label: 'Certified Trainer' },
  { value: 'practitioner', label: 'Health Practitioner' },
];

export function BadgeApplicationForm() {
  const { toast } = useToast();
  const fileRef = useRef<HTMLInputElement>(null);
  const [type, setType] = useState('trainer');
  const [title, setTitle] = useState('');
  const [issuer, setIssuer] = useState('');
  const [notes, setNotes] = useState('');
  const [file, setFile] = useState<File | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [done, setDone] = useState(false);

  const handleSubmit = async () => {
    if (!file) {
      toast('error', 'Attach a photo of your certificate or ID.');
      return;
    }
    setSubmitting(true);
    try {
      // 1) upload the file, 2) register the document, 3) create + submit.
      const up = await messagingApi.uploadAttachment(file);
      const doc = await verificationApi.uploadDocument(type, up.data!.url);
      await verificationApi.createSubmission(
        type,
        [doc.data!.id],
        notes || undefined,
        {
          credential_title: title || undefined,
          credential_issuer: issuer || undefined,
        },
      );
      setDone(true);
      toast('success', 'Application submitted — our team will review it shortly.');
    } catch (err: unknown) {
      const msg = (err as { response?: { data?: { message?: string } } })?.response?.data?.message || 'Submission failed';
      toast('error', msg);
    } finally {
      setSubmitting(false);
    }
  };

  if (done) {
    return (
      <p className="text-sm text-buddy-green flex items-center gap-1.5">
        <ShieldCheck size={16} /> Application submitted. Track its status in Verifications.
      </p>
    );
  }

  return (
    <div className="space-y-2.5">
      <div className="flex gap-2">
        {BADGE_TYPES.map(b => (
          <button
            key={b.value}
            onClick={() => setType(b.value)}
            className={`px-3 py-1.5 rounded-full text-xs font-semibold transition-colors ${type === b.value ? 'bg-buddy-green text-buddy-black' : 'bg-buddy-surface-raised text-buddy-text-secondary hover:text-buddy-text-primary'}`}
          >
            {b.label}
          </button>
        ))}
      </div>
      <Input placeholder="Credential title (e.g. NASM-CPT)" value={title} onChange={(e) => setTitle(e.target.value)} />
      <Input placeholder="Issuing organisation" value={issuer} onChange={(e) => setIssuer(e.target.value)} />
      <Input placeholder="Anything we should know? (optional)" value={notes} onChange={(e) => setNotes(e.target.value)} />
      <input
        ref={fileRef}
        type="file"
        accept="image/*,application/pdf"
        className="hidden"
        onChange={(e) => { setFile(e.target.files?.[0] ?? null); e.target.value = ''; }}
      />
      <div className="flex items-center gap-2">
        <Button size="sm" variant="outline" onClick={() => fileRef.current?.click()}>
          {file ? `📎 ${file.name.slice(0, 24)}` : 'Attach certificate'}
        </Button>
        <Button size="sm" onClick={handleSubmit} disabled={submitting || !file}>
          {submitting ? <Loader size={14} className="animate-spin" /> : null}
          Submit application
        </Button>
      </div>
    </div>
  );
}
