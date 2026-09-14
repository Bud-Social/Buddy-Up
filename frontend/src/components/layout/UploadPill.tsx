/**
 * UploadPill — persistent background-upload indicator mounted in AppShell.
 *
 * The uploadManager singleton survives route changes while the SPA lives, so
 * publishing continues while the user browses other content. This pill makes
 * that visible everywhere: progress, pause/resume/cancel, and completion.
 */
import { useEffect, useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { Loader2, Pause, Play, X, Check, AlertTriangle } from 'lucide-react';
import { uploadManager, type JobSnapshot } from '@/lib/uploadManager';

function activeJob(snaps: JobSnapshot[]): JobSnapshot | null {
  return snaps.find((s) => ['queued', 'finalizing', 'uploading', 'creating', 'paused'].includes(s.status)) ?? null;
}

export function UploadPill() {
  const navigate = useNavigate();
  const location = useLocation();
  const [snap, setSnap] = useState<JobSnapshot | null>(() => activeJob(uploadManager.getAllSnapshots()));
  const [doneFlash, setDoneFlash] = useState<JobSnapshot | null>(null);

  useEffect(() => {
    return uploadManager.subscribe((event) => {
      if (event.type === 'done') {
        const done = event.snapshot;
        setDoneFlash(done);
        setTimeout(() => setDoneFlash((d) => (d?.jobId === done.jobId ? null : d)), 6000);
      }
      setSnap(activeJob(uploadManager.getAllSnapshots()));
    });
  }, []);

  // Hide while the studio itself shows its own richer publish UI.
  if (location.pathname.startsWith('/create')) {
    if (!doneFlash) return null;
  }

  if (doneFlash && !snap) {
    return (
      <button
        onClick={() => { setDoneFlash(null); navigate('/feed/bud-press'); }}
        className="fixed bottom-20 md:bottom-6 left-1/2 -translate-x-1/2 z-40 flex items-center gap-2 pl-3 pr-2 py-2 rounded-full bg-buddy-green text-buddy-black text-xs font-bold shadow-2xl"
      >
        <Check size={15} /> Post published — view it
        <X size={13} className="opacity-60" onClick={(e) => { e.stopPropagation(); setDoneFlash(null); }} />
      </button>
    );
  }

  if (!snap) return null;

  const failed = snap.status === 'failed';
  return (
    <div className="fixed bottom-20 md:bottom-6 left-1/2 -translate-x-1/2 z-40 flex items-center gap-2 pl-3 pr-1.5 py-1.5 rounded-full bg-buddy-surface-raised border border-buddy-surface text-xs shadow-2xl max-w-[92vw]">
      <button
        onClick={() => navigate('/create')}
        className="flex items-center gap-2 min-w-0"
        title="Open studio"
      >
        {failed
          ? <AlertTriangle size={15} className="text-buddy-red shrink-0" />
          : snap.status === 'paused'
            ? <Play size={15} className="text-buddy-green shrink-0" />
            : <Loader2 size={15} className="text-buddy-green animate-spin shrink-0" />}
        <span className="min-w-0">
          <span className="block font-semibold truncate max-w-[38vw]">
            {failed ? 'Upload failed' : snap.status === 'paused' ? 'Upload paused' : `Uploading ${snap.overallPct}%`}
          </span>
          <span className="block text-[10px] text-buddy-text-secondary truncate max-w-[38vw]">
            {failed ? (snap.error || 'Tap to retry in studio') : 'Continues while you browse'}
          </span>
        </span>
      </button>
      <div className="flex items-center shrink-0">
        {!failed && snap.status !== 'paused' && (
          <button
            onClick={() => uploadManager.pauseJob(snap.jobId)}
            className="p-1.5 rounded-full text-buddy-text-secondary hover:text-buddy-text-primary"
            aria-label="Pause upload"
          ><Pause size={14} /></button>
        )}
        {!failed && snap.status === 'paused' && (
          <button
            onClick={() => uploadManager.resumeJob(snap.jobId)}
            className="p-1.5 rounded-full text-buddy-green"
            aria-label="Resume upload"
          ><Play size={14} /></button>
        )}
        {failed && (
          <button
            onClick={() => uploadManager.dismissJob(snap.jobId)}
            className="p-1.5 rounded-full text-buddy-text-secondary hover:text-buddy-red"
            aria-label="Dismiss"
          ><X size={14} /></button>
        )}
      </div>
    </div>
  );
}
