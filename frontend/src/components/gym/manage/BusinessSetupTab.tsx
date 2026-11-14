import { useEffect, useRef, useState } from 'react';
import {
  AlertTriangle, BadgeCheck, FileText, Image as ImageIcon, Loader2,
  ShieldCheck, Trash2, Upload, UserCheck, Video, X,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Badge } from '@/components/ui/Badge';
import { Modal } from '@/components/ui/Modal';
import { Avatar } from '@/components/ui/Avatar';
import { gymsApi } from '@/api/gyms';
import { verificationApi } from '@/api/verification';
import type { GymMembership, GymMediaItem, GymEndorsement, GymRegistration } from '@/types';

const REGISTRATION_DOC_TYPES = [
  { value: 'certification', label: 'Business registration certificate' },
  { value: 'proof_of_address', label: 'Proof of address' },
  { value: 'other', label: 'Other supporting document' },
];

const STATUS_COPY: Record<string, { label: string; variant: 'blue' | 'green' | 'gold' | 'red' | 'silver' | 'orange' }> = {
  unverified: { label: 'Not registered', variant: 'silver' },
  pending: { label: 'Under review', variant: 'gold' },
  verified: { label: 'Verified business', variant: 'green' },
  rejected: { label: 'Rejected', variant: 'red' },
  suspended: { label: 'Suspended', variant: 'orange' },
};

interface BusinessSetupTabProps {
  slug: string;
  canManage: boolean;
  members: GymMembership[];
  onDeleted: () => void;
}

/**
 * Everything that makes a gym a *registered business* rather than just a page.
 *
 * Three deliberately separate buckets:
 *  - registration paperwork, which goes through apps.verification and is
 *    private to reviewers (never surfaced as a public gallery URL);
 *  - gallery media, which is public and member-facing;
 *  - endorsements, which let a verified business fast-track its own trainers.
 *
 * Keeping them apart is the whole point: a leaked business certificate is a
 * privacy incident, a missing gym photo is a bad card.
 */
export function BusinessSetupTab({ slug, canManage, members, onDeleted }: BusinessSetupTabProps) {
  const [registration, setRegistration] = useState<GymRegistration | null>(null);
  const [loadingRegistration, setLoadingRegistration] = useState(true);
  const [form, setForm] = useState({
    legal_name: '', registration_number: '', country: '', tax_id: '',
    website: '', contact_email: '', contact_phone: '',
  });
  const [uploadedDocs, setUploadedDocs] = useState<Array<{ id: string; document_type: string; status: string }>>([]);
  const [docType, setDocType] = useState('certification');
  const [uploadingDoc, setUploadingDoc] = useState(false);
  const [saving, setSaving] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [registrationError, setRegistrationError] = useState<string | null>(null);
  const [registrationMessage, setRegistrationMessage] = useState<string | null>(null);

  const [media, setMedia] = useState<GymMediaItem[]>([]);
  const [mediaKind, setMediaKind] = useState<'photo' | 'video'>('photo');
  const [uploadingMedia, setUploadingMedia] = useState(false);
  const [mediaError, setMediaError] = useState<string | null>(null);
  const mediaInput = useRef<HTMLInputElement>(null);

  const [endorsements, setEndorsements] = useState<GymEndorsement[]>([]);
  const [canEndorse, setCanEndorse] = useState(false);
  const [endorseUser, setEndorseUser] = useState('');
  const [endorseType, setEndorseType] = useState<'trainer' | 'practitioner'>('trainer');
  const [endorseNote, setEndorseNote] = useState('');
  const [endorsing, setEndorsing] = useState(false);
  const [endorseError, setEndorseError] = useState<string | null>(null);

  const [deleteOpen, setDeleteOpen] = useState(false);
  const [deleting, setDeleting] = useState(false);

  const loadRegistration = async () => {
    setLoadingRegistration(true);
    setRegistrationError(null);
    try {
      const res = await gymsApi.getVerificationStatus(slug);
      setRegistration(res.data);
      setForm({
        legal_name: res.data.legal_name || '',
        registration_number: res.data.registration_number || '',
        country: res.data.country || '',
        tax_id: res.data.tax_id || '',
        website: res.data.website || '',
        contact_email: res.data.contact_email || '',
        contact_phone: res.data.contact_phone || '',
      });
    } catch (e: any) {
      setRegistrationError(e?.response?.data?.message || 'Could not load registration status.');
    } finally {
      setLoadingRegistration(false);
    }
  };

  const loadMedia = async () => {
    try {
      const res = await gymsApi.getMedia(slug);
      setMedia(res.data || []);
    } catch {
      setMedia([]);
    }
  };

  const loadEndorsements = async () => {
    try {
      const res = await gymsApi.getEndorsements(slug);
      setCanEndorse(res.data.can_endorse);
      setEndorsements(res.data.endorsements || []);
    } catch {
      setCanEndorse(false);
      setEndorsements([]);
    }
  };

  useEffect(() => {
    loadRegistration();
    loadMedia();
    loadEndorsements();
    /* eslint-disable-next-line react-hooks/exhaustive-deps */
  }, [slug]);

  const uploadDocument = async (file: File) => {
    setUploadingDoc(true);
    setRegistrationError(null);
    try {
      const res = await verificationApi.uploadCredential(docType, file);
      setUploadedDocs((prev) => [
        ...prev,
        { id: res.data.id, document_type: res.data.document_type, status: res.data.status },
      ]);
    } catch (e: any) {
      setRegistrationError(e?.response?.data?.message || 'Could not upload that document.');
    } finally {
      setUploadingDoc(false);
    }
  };

  const submitRegistration = async () => {
    setSubmitting(true);
    setRegistrationError(null);
    setRegistrationMessage(null);
    try {
      const res = await gymsApi.submitRegistration(slug, {
        ...form,
        document_ids: uploadedDocs.map((d) => d.id),
      });
      setRegistration(res.data);
      setRegistrationMessage(res.message || 'Submitted for verification.');
    } catch (e: any) {
      setRegistrationError(e?.response?.data?.message || 'Could not submit for verification.');
    } finally {
      setSubmitting(false);
    }
  };

  const saveDraft = async () => {
    setSaving(true);
    setRegistrationError(null);
    setRegistrationMessage(null);
    try {
      const res = await gymsApi.saveRegistration(slug, form);
      setRegistration(res.data);
      setRegistrationMessage('Registration details saved.');
    } catch (e: any) {
      setRegistrationError(e?.response?.data?.message || 'Could not save registration details.');
    } finally {
      setSaving(false);
    }
  };

  const uploadMedia = async (files: FileList | null) => {
    if (!files || files.length === 0) return;
    setUploadingMedia(true);
    setMediaError(null);
    try {
      const res = await gymsApi.uploadMedia(slug, Array.from(files), mediaKind);
      setMedia((prev) => [...(res.data || []), ...prev]);
    } catch (e: any) {
      setMediaError(e?.response?.data?.message || 'Could not upload that media.');
    } finally {
      setUploadingMedia(false);
      if (mediaInput.current) mediaInput.current.value = '';
    }
  };

  const removeMedia = async (item: GymMediaItem) => {
    setMediaError(null);
    try {
      await gymsApi.deleteMedia(slug, item.id);
      setMedia((prev) => prev.filter((m) => m.id !== item.id));
    } catch (e: any) {
      setMediaError(e?.response?.data?.message || 'Could not remove that media.');
    }
  };

  const endorse = async () => {
    if (!endorseUser.trim()) return;
    setEndorsing(true);
    setEndorseError(null);
    try {
      const res = await gymsApi.endorseTrainer(slug, {
        username: endorseUser.trim(),
        verification_type: endorseType,
        note: endorseNote.trim(),
      });
      setEndorsements((prev) => [res.data, ...prev.filter((e) => e.id !== res.data.id)]);
      setEndorseUser('');
      setEndorseNote('');
    } catch (e: any) {
      setEndorseError(e?.response?.data?.message || 'Could not endorse that member.');
    } finally {
      setEndorsing(false);
    }
  };

  const withdraw = async (endorsement: GymEndorsement) => {
    setEndorseError(null);
    try {
      await gymsApi.withdrawEndorsement(slug, endorsement.id);
      setEndorsements((prev) => prev.filter((e) => e.id !== endorsement.id));
    } catch (e: any) {
      setEndorseError(e?.response?.data?.message || 'Could not withdraw that endorsement.');
    }
  };

  const deleteGym = async () => {
    setDeleting(true);
    try {
      await gymsApi.delete(slug);
      onDeleted();
    } catch (e: any) {
      setRegistrationError(e?.response?.data?.message || 'Could not delete this gym.');
      setDeleteOpen(false);
    } finally {
      setDeleting(false);
    }
  };

  const status = registration?.status || 'unverified';
  const statusCopy = STATUS_COPY[status] || STATUS_COPY.unverified;

  return (
    <section className="space-y-4">
      <h2 className="text-sm font-bold text-buddy-text-secondary uppercase">Business setup</h2>

      {/* ── Verification status ─────────────────────────────────────────── */}
      <Card className="p-4 space-y-2">
        <div className="flex items-center gap-2">
          <ShieldCheck size={16} className="text-buddy-blue" />
          <p className="text-sm font-medium flex-1">Business verification</p>
          <Badge variant={statusCopy.variant} label={statusCopy.label} />
        </div>
        {loadingRegistration ? (
          <p className="text-xs text-buddy-text-secondary">Loading…</p>
        ) : status === 'verified' ? (
          <p className="text-xs text-buddy-text-secondary">
            Your business is verified. Members see the blue tick on your gym card.
          </p>
        ) : status === 'pending' ? (
          <p className="text-xs text-buddy-text-secondary">
            Your documents are with our review team. Registration details are
            locked until a decision is made.
          </p>
        ) : status === 'rejected' ? (
          <div className="space-y-1">
            <p className="text-xs text-buddy-red">
              This registration was rejected{registration?.rejection_reason ? ':' : '.'}
            </p>
            {registration?.rejection_reason && (
              <p className="text-xs text-buddy-text-secondary bg-buddy-red/5 border border-buddy-red/20 rounded-lg p-2">
                {registration.rejection_reason}
              </p>
            )}
            <p className="text-xs text-buddy-text-secondary">Fix the issue and resubmit below.</p>
          </div>
        ) : (
          <p className="text-xs text-buddy-text-secondary">
            Add your legal business details and at least one registration
            document. Certified gyms get the verified badge and can fast-track
            their trainers.
          </p>
        )}
        {registrationError && (
          <p className="text-xs text-buddy-red" role="alert">{registrationError}</p>
        )}
        {registrationMessage && (
          <p className="text-xs text-buddy-green">{registrationMessage}</p>
        )}
      </Card>

      {/* ── Registration details + documents ────────────────────────────── */}
      {(status === 'unverified' || status === 'rejected') && canManage && (
        <Card className="p-4 space-y-3">
          <p className="text-sm font-medium">Registration details</p>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <Input
              label="Legal business name"
              value={form.legal_name}
              onChange={(e) => setForm({ ...form, legal_name: e.target.value })}
              placeholder="Iron Core Fitness Ltd"
            />
            <Input
              label="Registration number"
              value={form.registration_number}
              onChange={(e) => setForm({ ...form, registration_number: e.target.value })}
              placeholder="Company / tax registration number"
            />
            <Input
              label="Country"
              value={form.country}
              onChange={(e) => setForm({ ...form, country: e.target.value })}
            />
            <Input
              label="Tax ID (optional)"
              value={form.tax_id}
              onChange={(e) => setForm({ ...form, tax_id: e.target.value })}
            />
            <Input
              label="Website (optional)"
              value={form.website}
              onChange={(e) => setForm({ ...form, website: e.target.value })}
              placeholder="https://"
            />
            <Input
              label="Contact email"
              type="email"
              value={form.contact_email}
              onChange={(e) => setForm({ ...form, contact_email: e.target.value })}
            />
            <Input
              label="Contact phone"
              value={form.contact_phone}
              onChange={(e) => setForm({ ...form, contact_phone: e.target.value })}
            />
          </div>

          <div className="space-y-2 pt-1">
            <p className="text-sm font-medium">Registration documents</p>
            <p className="text-[11px] text-buddy-text-secondary">
              Private to reviewers and purged on the standard verification
              retention schedule. Never shown on your public profile.
            </p>
            <div className="flex flex-col sm:flex-row gap-2">
              <select
                aria-label="Document type"
                value={docType}
                onChange={(e) => setDocType(e.target.value)}
                className="flex-1 bg-buddy-surface border border-buddy-surface-raised rounded-xl px-3 py-2 text-sm text-buddy-text-primary focus:outline-none focus:border-buddy-green"
              >
                {REGISTRATION_DOC_TYPES.map((t) => (
                  <option key={t.value} value={t.value}>{t.label}</option>
                ))}
              </select>
              <label className={`inline-flex items-center justify-center gap-1 rounded-xl px-3 py-2 text-sm font-medium cursor-pointer ${uploadingDoc ? 'opacity-50' : 'bg-buddy-surface-raised hover:bg-buddy-surface'}`}>
                {uploadingDoc ? <Loader2 size={14} className="animate-spin" /> : <Upload size={14} />}
                Upload
                <input
                  type="file"
                  className="hidden"
                  disabled={uploadingDoc}
                  accept="image/*,application/pdf"
                  onChange={(e) => e.target.files?.[0] && uploadDocument(e.target.files[0])}
                />
              </label>
            </div>
            {uploadedDocs.length > 0 && (
              <ul className="space-y-1">
                {uploadedDocs.map((doc) => (
                  <li key={doc.id} className="flex items-center gap-2 text-xs text-buddy-text-secondary">
                    <FileText size={12} />
                    <span className="capitalize">{doc.document_type.replace(/_/g, ' ')}</span>
                    <span className="text-buddy-green">uploaded</span>
                  </li>
                ))}
              </ul>
            )}
          </div>

          <div className="flex flex-wrap gap-2">
            <Button variant="outline" onClick={saveDraft} isLoading={saving} disabled={!form.legal_name.trim()}>
              Save details
            </Button>
            <Button
              onClick={submitRegistration}
              isLoading={submitting}
              disabled={!form.legal_name.trim() || !form.registration_number.trim() || uploadedDocs.length === 0}
            >
              <BadgeCheck size={14} className="mr-1" /> Submit for verification
            </Button>
          </div>
          {uploadedDocs.length === 0 && (
            <p className="text-[11px] text-buddy-text-secondary">
              Upload at least one document to enable submission.
            </p>
          )}
        </Card>
      )}

      {/* ── Gallery ─────────────────────────────────────────────────────── */}
      <Card className="p-4 space-y-3">
        <div className="flex items-center gap-2">
          <ImageIcon size={16} className="text-buddy-green" />
          <p className="text-sm font-medium flex-1">Gym photos &amp; videos</p>
          <span className="text-[10px] text-buddy-text-secondary">{media.length} items</span>
        </div>
        <p className="text-xs text-buddy-text-secondary">
          Public gallery shown on your gym page. Photos and short videos only.
        </p>
        {mediaError && <p className="text-xs text-buddy-red" role="alert">{mediaError}</p>}

        <div className="flex items-center gap-2">
          {(['photo', 'video'] as const).map((kind) => (
            <button
              key={kind}
              type="button"
              onClick={() => setMediaKind(kind)}
              className={`px-3 py-1.5 rounded-full text-xs capitalize transition-colors ${
                mediaKind === kind
                  ? 'bg-buddy-green text-buddy-black font-medium'
                  : 'border border-buddy-surface text-buddy-text-secondary'
              }`}
            >
              {kind === 'photo' ? <ImageIcon size={12} className="inline mr-1" /> : <Video size={12} className="inline mr-1" />}
              {kind}
            </button>
          ))}
          {canManage && (
            <>
              <input
                ref={mediaInput}
                type="file"
                className="hidden"
                multiple
                accept={mediaKind === 'video' ? 'video/*' : 'image/*'}
                onChange={(e) => uploadMedia(e.target.files)}
              />
              <Button
                size="sm"
                variant="outline"
                className="ml-auto"
                isLoading={uploadingMedia}
                onClick={() => mediaInput.current?.click()}
              >
                <Upload size={12} className="mr-1" /> Upload
              </Button>
            </>
          )}
        </div>

        {media.length === 0 ? (
          <p className="text-xs text-buddy-text-secondary py-2">No gallery media yet.</p>
        ) : (
          <div className="grid grid-cols-3 gap-2">
            {media.map((item) => (
              <div key={item.id} className="relative rounded-lg overflow-hidden bg-buddy-surface aspect-square group">
                {item.kind === 'video' ? (
                  <video src={item.file_url} className="w-full h-full object-cover" muted playsInline />
                ) : (
                  <img src={item.file_url} alt={item.caption || 'Gym photo'} className="w-full h-full object-cover" loading="lazy" />
                )}
                {canManage && (
                  <button
                    type="button"
                    aria-label="Remove media"
                    onClick={() => removeMedia(item)}
                    className="absolute top-1 right-1 p-1 rounded-full bg-black/70 text-white opacity-0 group-hover:opacity-100 transition-opacity"
                  >
                    <X size={12} />
                  </button>
                )}
              </div>
            ))}
          </div>
        )}
      </Card>

      {/* ── Endorsements ────────────────────────────────────────────────── */}
      <Card className="p-4 space-y-3">
        <div className="flex items-center gap-2">
          <UserCheck size={16} className="text-buddy-blue" />
          <p className="text-sm font-medium flex-1">Endorse trainers</p>
          {canEndorse && <Badge variant="blue" label="Fast-track" />}
        </div>
        <p className="text-xs text-buddy-text-secondary">
          {canEndorse
            ? 'Vouch for a member trainer or practitioner. Their verification goes into the priority queue; a reviewer still makes the final call.'
            : 'Available once your business registration is verified. Endorsements never auto-approve a trainer.'}
        </p>
        {endorseError && <p className="text-xs text-buddy-red" role="alert">{endorseError}</p>}

        {endorsements.length > 0 && (
          <div className="space-y-2">
            {endorsements.map((endorsement) => (
              <div key={endorsement.id} className="flex items-center gap-2">
                <Avatar src={endorsement.trainer_data?.avatar_url} alt={endorsement.trainer_data?.display_name || 'Trainer'} size="sm" />
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium truncate">{endorsement.trainer_data?.display_name}</p>
                  <p className="text-xs text-buddy-text-secondary truncate">
                    @{endorsement.trainer_data?.username}
                    {endorsement.note ? ` · ${endorsement.note}` : ''}
                  </p>
                </div>
                {endorsement.trainer_data?.verification_status === 'verified' && (
                  <Badge variant="green" label="Verified" />
                )}
                {canManage && (
                  <Button size="sm" variant="ghost" aria-label="Withdraw endorsement" onClick={() => withdraw(endorsement)}>
                    <Trash2 size={14} />
                  </Button>
                )}
              </div>
            ))}
          </div>
        )}

        {canEndorse && canManage && (
          <div className="space-y-2 pt-2 border-t border-buddy-surface">
            <div className="flex gap-2">
              <Input
                value={endorseUser}
                onChange={(e) => setEndorseUser(e.target.value)}
                placeholder="Member username"
              />
              <select
                aria-label="Verification type"
                value={endorseType}
                onChange={(e) => setEndorseType(e.target.value as 'trainer' | 'practitioner')}
                className="bg-buddy-surface border border-buddy-surface-raised rounded-xl px-2 text-xs text-buddy-text-primary"
              >
                <option value="trainer">Trainer</option>
                <option value="practitioner">Practitioner</option>
              </select>
            </div>
            <Input
              value={endorseNote}
              onChange={(e) => setEndorseNote(e.target.value)}
              placeholder="How long have they worked with you? (optional)"
            />
            <div className="flex flex-wrap gap-1">
              {members
                .filter((m) => m.member_data?.username && m.role !== 'owner' && m.role !== 'co_owner')
                .filter((m) => !endorsements.some((e) => e.trainer_data?.username === m.member_data?.username))
                .slice(0, 8)
                .map((m) => (
                  <button
                    key={m.id}
                    type="button"
                    onClick={() => setEndorseUser(m.member_data?.username || '')}
                    className="text-[10px] bg-buddy-surface hover:bg-buddy-surface-raised text-buddy-text-secondary px-2 py-0.5 rounded-full"
                  >
                    {m.member_data?.display_name || m.member_data?.username}
                  </button>
                ))}
            </div>
            <Button size="sm" onClick={endorse} isLoading={endorsing} disabled={!endorseUser.trim()}>
              <UserCheck size={13} className="mr-1" /> Endorse for fast-track
            </Button>
          </div>
        )}
      </Card>

      {/* ── Danger zone ─────────────────────────────────────────────────── */}
      {canManage && (
        <Card className="p-4 space-y-2 border border-buddy-red/20">
          <div className="flex items-center gap-2">
            <AlertTriangle size={16} className="text-buddy-red" />
            <p className="text-sm font-medium text-buddy-red">Danger zone</p>
          </div>
          <p className="text-xs text-buddy-text-secondary">
            Deleting the gym removes it from discovery and detaches its members.
            This cannot be undone from the app.
          </p>
          <Button size="sm" variant="destructive" onClick={() => setDeleteOpen(true)}>
            <Trash2 size={13} className="mr-1" /> Delete gym
          </Button>
        </Card>
      )}

      <Modal isOpen={deleteOpen} onClose={() => setDeleteOpen(false)} title="Delete gym">
        <p className="text-sm text-buddy-text-secondary">
          Permanently delete this gym? Members lose access immediately and the
          handle is released.
        </p>
        <div className="flex gap-2 mt-4">
          <Button className="flex-1" variant="destructive" isLoading={deleting} onClick={deleteGym}>
            Delete
          </Button>
          <Button variant="ghost" onClick={() => setDeleteOpen(false)}>Cancel</Button>
        </div>
      </Modal>
    </section>
  );
}

export default BusinessSetupTab;
