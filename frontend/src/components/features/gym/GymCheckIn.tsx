import { useCallback, useEffect, useState } from 'react';
import { LogIn, Loader2, CheckCircle2, Clock } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { gymsApi, type GymCheckInStatus } from '@/api/gyms';
import { useToast } from '@/components/ui/Toast';

/**
 * Check in at a gym.
 *
 * A gym visit is what a "gym attendance" countdown follows, so checking in
 * is what moves it.
 */
export function GymCheckIn({ slug, gymName }: { slug: string; gymName: string }) {
  const { toast } = useToast();
  const [status, setStatus] = useState<GymCheckInStatus | null>(null);
  const [busy, setBusy] = useState(false);

  const load = useCallback(async () => {
    try {
      setStatus(await gymsApi.getCheckInStatus(slug));
    } catch {
      setStatus(null);
    }
  }, [slug]);

  useEffect(() => { load(); }, [load]);

  const checkIn = async () => {
    setBusy(true);
    try {
      const res = await gymsApi.checkIn(slug);
      toast('success', res.message || `Checked in at ${gymName}.`);
      await load();
    } catch (err) {
      const msg = (err as { response?: { data?: { message?: string } } })?.response?.data?.message;
      toast('error', msg || 'Could not check in.');
      await load();
    } finally {
      setBusy(false);
    }
  };

  if (!status?.is_member) return null;

  if (!status.can_check_in && status.next_check_in_at) {
    const next = new Date(status.next_check_in_at);
    const hours = Math.max(0, Math.floor((next.getTime() - Date.now()) / 3600000));
    const minutes = Math.max(0, Math.floor(((next.getTime() - Date.now()) % 3600000) / 60000));
    return (
      <div className="flex items-center gap-2 rounded-xl border border-buddy-border bg-buddy-surface/60 px-3 py-2.5 text-xs text-buddy-text-secondary">
        <CheckCircle2 size={14} className="text-buddy-green shrink-0" />
        Checked in
        {status.last_check_in_at && (
          <> · {new Date(status.last_check_in_at).toLocaleString(undefined, { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' })}</>
        )}
        <span className="ml-auto flex items-center gap-1">
          <Clock size={12} /> next in {hours}h {minutes}m
        </span>
      </div>
    );
  }

  return (
    <Button size="sm" className="w-full" onClick={checkIn} disabled={busy}>
      {busy ? <Loader2 size={14} className="animate-spin mr-1.5" /> : <LogIn size={14} className="mr-1.5" />}
      Check in at {gymName}
    </Button>
  );
}
