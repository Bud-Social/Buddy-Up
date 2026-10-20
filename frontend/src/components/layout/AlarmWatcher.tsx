import { useCallback, useEffect, useRef, useState } from 'react';
import { AlarmClock, Square } from 'lucide-react';
import { alarmsApi } from '@/api';
import type { Alarm } from '@/api/alarms';
import { nextFireDate } from '@/lib/alarmSchedule';
import { playAlarmSound, primeAlarmAudio, stopAllAlarms } from '@/lib/alarmPlayer';
import { Button } from '@/components/ui/Button';

/**
 * App-wide alarm scheduler. Mounted once inside the authenticated shell so an
 * alarm rings no matter which page is open (previously it only worked while
 * the Alarm Center was mounted). One-shot alarms disable themselves after
 * firing; repeating alarms re-arm for their next occurrence.
 */
export function AlarmWatcher() {
  const [alarms, setAlarms] = useState<Alarm[]>([]);
  const [ringing, setRinging] = useState<Alarm | null>(null);
  const cancelRef = useRef(new Map<string, () => void>());
  const snoozeTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const load = useCallback(() => {
    alarmsApi
      .getAlarms()
      .then((r) => setAlarms(r.data))
      .catch(() => undefined);
  }, []);

  useEffect(() => {
    primeAlarmAudio();
    load();
    const onFocus = () => load();
    window.addEventListener('focus', onFocus);
    const interval = window.setInterval(load, 5 * 60 * 1000);
    return () => {
      window.removeEventListener('focus', onFocus);
      window.clearInterval(interval);
    };
  }, [load]);

  const arm = useCallback((alarm: Alarm, from: Date = new Date()) => {
    cancelRef.current.get(alarm.id)?.();
    cancelRef.current.delete(alarm.id);

    const fireAt = nextFireDate(alarm.time, alarm.days_mask, from);
    if (!fireAt) return;

    const timer = setTimeout(() => {
      cancelRef.current.delete(alarm.id);
      stopAllAlarms();
      setRinging(alarm);
      playAlarmSound(alarm.sound?.audio_url ?? '');

      if (alarm.days_mask === 0) {
        // One-shot: consume it so it doesn't ring again tomorrow.
        setAlarms((prev) =>
          prev.map((a) => (a.id === alarm.id ? { ...a, enabled: false } : a)),
        );
        alarmsApi.updateAlarm(alarm.id, { enabled: false }).catch(() => undefined);
      } else {
        arm(alarm, new Date(Date.now() + 60_000));
      }
    }, Math.max(0, fireAt.getTime() - Date.now()));

    cancelRef.current.set(alarm.id, () => clearTimeout(timer));
  }, []);

  useEffect(() => {
    const enabled = alarms.filter((a) => a.enabled);
    const enabledIds = new Set(enabled.map((a) => a.id));

    for (const [id, cancel] of cancelRef.current) {
      if (!enabledIds.has(id)) {
        cancel();
        cancelRef.current.delete(id);
      }
    }
    enabled.forEach((alarm) => {
      if (!cancelRef.current.has(alarm.id)) arm(alarm);
    });
  }, [alarms, arm]);

  useEffect(
    () => () => {
      for (const cancel of cancelRef.current.values()) cancel();
      cancelRef.current.clear();
      if (snoozeTimerRef.current) clearTimeout(snoozeTimerRef.current);
      stopAllAlarms();
    },
    [],
  );

  const stop = () => {
    stopAllAlarms();
    setRinging(null);
  };

  const snooze = () => {
    if (!ringing) return;
    const alarm = ringing;
    stop();
    if (snoozeTimerRef.current) clearTimeout(snoozeTimerRef.current);
    snoozeTimerRef.current = setTimeout(() => {
      setRinging(alarm);
      playAlarmSound(alarm.sound?.audio_url ?? '');
    }, Math.max(1, alarm.snooze_minutes) * 60_000);
  };

  if (!ringing) return null;

  return (
    <div
      role="alert"
      aria-live="assertive"
      className="fixed bottom-24 md:bottom-6 right-4 z-[60] w-[min(22rem,calc(100vw-2rem))]"
    >
      <div className="rounded-xl border border-buddy-green/50 bg-buddy-surface-raised p-4 shadow-2xl space-y-3">
        <div className="flex items-start gap-3">
          <AlarmClock size={20} className="text-buddy-green flex-shrink-0 mt-0.5" />
          <div className="min-w-0">
            <p className="font-heading text-sm font-semibold">
              Alarm · {ringing.time.slice(0, 5)}
            </p>
            <p className="text-xs text-buddy-text-secondary truncate">
              {ringing.label || 'Time to rise and grind'}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <Button size="sm" variant="outline" onClick={snooze}>
            Snooze {ringing.snooze_minutes}m
          </Button>
          <Button size="sm" onClick={stop}>
            <Square size={14} /> Stop
          </Button>
        </div>
      </div>
    </div>
  );
}
