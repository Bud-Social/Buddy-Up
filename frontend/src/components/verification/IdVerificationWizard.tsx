import { useCallback, useEffect, useRef, useState } from 'react';
import { Camera, CheckCircle, ChevronLeft, CreditCard, Loader, RefreshCw, Shield, UserRound } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { useToast } from '@/components/ui/Toast';
import { verificationApi, type VerificationSubmission } from '@/api/verification';

type WizardStep = 'intro' | 'id_document' | 'selfie_liveness' | 'review' | 'submitted';

const DOC_TYPES = [
  { value: 'id_card', label: 'National ID Card' },
  { value: 'passport', label: 'Passport' },
  { value: 'drivers_license', label: "Driver's License" },
];

const STEP_ORDER: WizardStep[] = ['intro', 'id_document', 'selfie_liveness', 'review'];

interface IdVerificationWizardProps {
  onDone: () => void;
}

/**
 * Multistep ID + selfie verification wizard.
 * Steps: overview → ID document upload → liveness selfie capture →
 * face-match (server-side) → review & submit.
 */
export function IdVerificationWizard({ onDone }: IdVerificationWizardProps) {
  const { toast } = useToast();
  const [step, setStep] = useState<WizardStep>('intro');
  const [submissionId, setSubmissionId] = useState<string | null>(null);
  const [docType, setDocType] = useState('id_card');
  const [uploadingStep, setUploadingStep] = useState(false);
  const [faceMatch, setFaceMatch] = useState<{ status: string; score: number | null } | null>(null);

  // Selfie camera state
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const streamRef = useRef<MediaStream | null>(null);
  const [cameraReady, setCameraReady] = useState(false);
  const [cameraError, setCameraError] = useState(false);

  const stopCamera = useCallback(() => {
    streamRef.current?.getTracks().forEach((t) => t.stop());
    streamRef.current = null;
    setCameraReady(false);
  }, []);

  useEffect(() => () => stopCamera(), [stopCamera]);

  const startCamera = async () => {
    setCameraError(false);
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: 'user', width: { ideal: 720 } },
        audio: false,
      });
      streamRef.current = stream;
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        await videoRef.current.play().catch(() => undefined);
      }
      setCameraReady(true);
    } catch {
      setCameraError(true);
    }
  };

  const ensureDraft = async (): Promise<string> => {
    if (submissionId) return submissionId;
    const res = await verificationApi.createSubmission('id', []);
    const sub = res.data as VerificationSubmission;
    setSubmissionId(sub.id);
    return sub.id;
  };

  const handleUpload = async (blob: Blob, filename: string, stepName: 'id_document' | 'selfie_liveness') => {
    setUploadingStep(true);
    try {
      const id = await ensureDraft();
      const res = await verificationApi.uploadStep(id, stepName, blob, filename, stepName === 'id_document' ? docType : undefined);
      if (res.data.face_match) setFaceMatch(res.data.face_match);
      toast('success', stepName === 'id_document' ? 'ID document uploaded' : 'Selfie captured — checking match…');
      setStep(stepName === 'id_document' ? 'selfie_liveness' : 'review');
      return true;
    } catch (err: unknown) {
      const detail = (err as { response?: { data?: { detail?: string } } })?.response?.data?.detail;
      toast('error', detail || 'Upload failed — please retry');
      return false;
    } finally {
      setUploadingStep(false);
    }
  };

  const handleFileSelected = (e: React.ChangeEvent<HTMLInputElement>, stepName: 'id_document' | 'selfie_liveness') => {
    const file = e.target.files?.[0];
    e.target.value = '';
    if (!file) return;
    void handleUpload(file, file.name || 'upload.jpg', stepName);
  };

  const captureSelfie = async () => {
    if (!videoRef.current || !canvasRef.current) return;
    const video = videoRef.current;
    const canvas = canvasRef.current;
    canvas.width = video.videoWidth || 640;
    canvas.height = video.videoHeight || 480;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;
    ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
    stopCamera();
    const blob = await new Promise<Blob | null>((resolve) => canvas.toBlob(resolve, 'image/jpeg', 0.9));
    if (!blob) {
      toast('error', 'Capture failed — please retry');
      return;
    }
    void handleUpload(blob, 'selfie.jpg', 'selfie_liveness');
  };

  const handleSubmit = async () => {
    if (!submissionId) return;
    setUploadingStep(true);
    try {
      await verificationApi.submitDraft(submissionId);
      toast('success', 'Verification submitted for review!');
      setStep('submitted');
    } catch (err: unknown) {
      const detail = (err as { response?: { data?: { detail?: string } } })?.response?.data?.detail;
      toast('error', detail || 'Failed to submit');
    } finally {
      setUploadingStep(false);
    }
  };

  // ── Submitted confirmation ────────────────────────────────────────────────
  if (step === 'submitted') {
    return (
      <Card className="p-6 bg-buddy-green/10 border-buddy-green/30 text-center">
        <CheckCircle size={40} className="mx-auto text-buddy-green mb-3" />
        <h3 className="font-heading font-bold mb-1">Verification submitted</h3>
        <p className="text-sm text-buddy-text-secondary mb-4">
          Our team will review your ID and selfie
          {faceMatch ? ` (match check: ${faceMatch.status.replace(/_/g, ' ')})` : ''} shortly.
        </p>
        <Button onClick={onDone}>Back to Verification</Button>
      </Card>
    );
  }

  const currentIdx = STEP_ORDER.indexOf(step);

  return (
    <Card className="p-5">
      {/* Progress header */}
      <div className="flex items-center gap-2 mb-5" aria-hidden>
        {STEP_ORDER.map((s, i) => (
          <div key={s} className="flex items-center gap-2 flex-1">
            <div className={`w-7 h-7 rounded-full flex items-center justify-center text-xs shrink-0 ${
              i < currentIdx ? 'bg-buddy-green text-black' : i === currentIdx ? 'bg-buddy-green/20 text-buddy-green border border-buddy-green' : 'bg-buddy-surface-raised text-buddy-text-secondary'
            }`}>
              {i < currentIdx ? <CheckCircle size={14} /> : i + 1}
            </div>
            {i < STEP_ORDER.length - 1 && (
              <div className={`h-0.5 flex-1 ${i < currentIdx ? 'bg-buddy-green' : 'bg-buddy-surface-raised'}`} />
            )}
          </div>
        ))}
      </div>

      {step === 'intro' && (
        <div className="space-y-4">
          <div className="flex items-center gap-2">
            <Shield size={20} className="text-buddy-green" />
            <h3 className="font-heading font-bold">Verify your identity</h3>
          </div>
          <ol className="space-y-2 text-sm text-buddy-text-secondary list-decimal list-inside">
            <li>Upload a government-issued ID document.</li>
            <li>Capture a live selfie to match against your ID.</li>
            <li>Review and submit for approval.</li>
          </ol>
          <p className="text-[11px] text-buddy-text-secondary">
            Your documents are stored securely and only visible to the verification team.
          </p>
          <div className="flex gap-2">
            {submissionId && (
              <Button variant="ghost" onClick={() => { setSubmissionId(null); onDone(); }}>Cancel</Button>
            )}
            <Button className="flex-1" onClick={() => setStep('id_document')}>Start verification</Button>
          </div>
        </div>
      )}

      {step === 'id_document' && (
        <div className="space-y-4">
          <h3 className="font-heading font-bold flex items-center gap-2"><CreditCard size={18} /> Upload your ID</h3>
          <div>
            <label className="text-sm font-medium block mb-2">Document type</label>
            <div className="grid grid-cols-3 gap-2">
              {DOC_TYPES.map((d) => (
                <button key={d.value} type="button" onClick={() => setDocType(d.value)}
                  className={`p-2 rounded-xl border text-xs transition-colors ${docType === d.value ? 'border-buddy-green bg-buddy-green/10' : 'border-buddy-surface-raised hover:border-buddy-green/40'}`}>
                  {d.label}
                </button>
              ))}
            </div>
          </div>
          <label className={`block cursor-pointer rounded-xl border-2 border-dashed p-6 text-center transition-colors ${uploadingStep ? 'opacity-50 pointer-events-none' : 'border-buddy-green/30 hover:border-buddy-green/60'}`}>
            <CreditCard size={28} className="mx-auto text-buddy-text-secondary mb-2" />
            <p className="text-sm">{uploadingStep ? 'Uploading…' : 'Tap to upload a photo of your document'}</p>
            <p className="text-xs text-buddy-text-secondary mt-1">JPG or PNG · max 10 MB · all details must be legible</p>
            <input type="file" accept="image/*" className="hidden" disabled={uploadingStep}
              onChange={(e) => handleFileSelected(e, 'id_document')} />
          </label>
          <Button variant="ghost" size="sm" onClick={() => setStep('intro')} disabled={uploadingStep}>
            <ChevronLeft size={14} /> Back
          </Button>
        </div>
      )}

      {step === 'selfie_liveness' && (
        <div className="space-y-4">
          <h3 className="font-heading font-bold flex items-center gap-2"><UserRound size={18} /> Liveness selfie</h3>
          <p className="text-sm text-buddy-text-secondary">
            Look straight at the camera in good lighting. We'll match this selfie with your ID photo.
          </p>

          <div className="relative rounded-xl overflow-hidden bg-buddy-surface-raised aspect-video">
            <video ref={videoRef} playsInline muted className="w-full h-full object-cover scale-x-[-1]" />
            {!cameraReady && !cameraError && (
              <div className="absolute inset-0 flex flex-col items-center justify-center gap-3">
                <Button onClick={startCamera}><Camera size={16} /> Enable camera</Button>
                <p className="text-xs text-buddy-text-secondary">or upload a recent photo below</p>
              </div>
            )}
            {cameraError && (
              <div className="absolute inset-0 flex items-center justify-center p-4 text-center">
                <p className="text-sm text-buddy-text-secondary">Camera unavailable — you can upload a selfie photo instead.</p>
              </div>
            )}
            {cameraReady && (
              <div className="absolute inset-x-8 inset-y-4 rounded-[50%] border-2 border-dashed border-buddy-green/70 pointer-events-none" />
            )}
          </div>

          <canvas ref={canvasRef} className="hidden" />

          <div className="flex gap-2">
            {cameraReady ? (
              <Button className="flex-1" onClick={() => void captureSelfie()} isLoading={uploadingStep}>Capture selfie</Button>
            ) : (
              <label className={`flex-1 ${uploadingStep ? 'pointer-events-none opacity-50' : ''}`}>
                <span className="sr-only">Upload selfie</span>
                <span className="block text-center cursor-pointer bg-buddy-surface-raised hover:bg-buddy-surface-raised/70 border border-buddy-surface-raised text-buddy-text-primary font-medium py-2.5 px-4 rounded-xl text-sm transition-colors">
                  {uploadingStep ? 'Uploading…' : 'Upload selfie photo'}
                </span>
                <input type="file" accept="image/*" className="hidden" disabled={uploadingStep}
                  onChange={(e) => handleFileSelected(e, 'selfie_liveness')} />
              </label>
            )}
            <Button variant="ghost" size="sm" onClick={() => { stopCamera(); setStep('id_document'); }} disabled={uploadingStep}>
              <ChevronLeft size={14} /> Back
            </Button>
          </div>
        </div>
      )}

      {step === 'review' && (
        <div className="space-y-4">
          <h3 className="font-heading font-bold">Review & submit</h3>
          <div className="space-y-2 text-sm">
            <div className="flex items-center justify-between p-3 rounded-xl bg-buddy-surface-raised">
              <span>ID document ({DOC_TYPES.find((d) => d.value === docType)?.label})</span>
              <CheckCircle size={16} className="text-buddy-green" />
            </div>
            <div className="flex items-center justify-between p-3 rounded-xl bg-buddy-surface-raised">
              <span>Liveness selfie</span>
              <CheckCircle size={16} className="text-buddy-green" />
            </div>
            <div className="flex items-center justify-between p-3 rounded-xl bg-buddy-surface-raised">
              <span>Face match</span>
              {faceMatch ? (
                <span className={`text-xs font-medium ${faceMatch.status === 'auto_matched' ? 'text-buddy-green' : 'text-buddy-orange'}`}>
                  {faceMatch.status === 'auto_matched'
                    ? `Matched (${Math.round(faceMatch.score ?? 0)}%)`
                    : faceMatch.status === 'manual_review'
                      ? 'Queued for manual review'
                      : faceMatch.status.replace(/_/g, ' ')}
                </span>
              ) : (
                <Loader size={14} className="animate-spin text-buddy-text-secondary" />
              )}
            </div>
          </div>
          <p className="text-[11px] text-buddy-text-secondary">
            {faceMatch?.status === 'auto_matched'
              ? 'Automatic match passed — submitting will fast-track your verification.'
              : 'Your submission will be reviewed by our team before your badge is granted.'}
          </p>
          <div className="flex gap-2">
            <Button variant="ghost" onClick={() => setStep('selfie_liveness')} disabled={uploadingStep}>
              <ChevronLeft size={14} /> Back
            </Button>
            <Button className="flex-1" onClick={handleSubmit} isLoading={uploadingStep}>
              <RefreshCw size={14} /> Submit for review
            </Button>
          </div>
        </div>
      )}
    </Card>
  );
}
