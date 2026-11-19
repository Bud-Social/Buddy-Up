import { CloudOff, RefreshCw, CloudUpload } from 'lucide-react';
import { useActivityQueue } from '@/hooks/useActivityQueue';

/**
 * Shows how many sessions are waiting on this device, with a manual sync
 * button. Renders nothing when the queue is empty (and shortly after a sync
 * completes, when it reports what caught up).
 */
export function ActivityQueueBanner({ className = '' }: { className?: string }) {
  const { pending, syncing, justSynced, syncNow } = useActivityQueue();

  if (!pending && !justSynced) return null;

  const caughtUp = pending === 0 && justSynced > 0;

  return (
    <div
      className={`flex items-center gap-2 rounded-xl border px-3 py-2 text-xs ${
        caughtUp
          ? 'border-buddy-green/30 bg-buddy-green/10 text-buddy-green'
          : 'border-buddy-gold/30 bg-buddy-gold/10 text-buddy-gold'
      } ${className}`}
    >
      {caughtUp ? <CloudUpload size={14} /> : <CloudOff size={14} />}
      <span className="flex-1">
        {caughtUp
          ? `${justSynced} offline ${justSynced === 1 ? 'activity' : 'activities'} synced.`
          : pending === 1
            ? '1 activity is saved on this device. It uploads automatically when you reconnect.'
            : `${pending} activities are saved on this device. They upload automatically when you reconnect.`}
      </span>
      {!caughtUp && (
        <button
          type="button"
          onClick={() => void syncNow()}
          disabled={syncing}
          className="inline-flex items-center gap-1 rounded-lg px-2 py-1 font-medium hover:bg-buddy-gold/15 disabled:opacity-50"
        >
          <RefreshCw size={12} className={syncing ? 'animate-spin' : ''} />
          {syncing ? 'Syncing…' : 'Sync now'}
        </button>
      )}
    </div>
  );
}
