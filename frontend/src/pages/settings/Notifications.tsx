import { useEffect, useState } from 'react';
import { Loader } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Toggle } from '@/components/ui/Toggle';
import { useToast } from '@/components/ui/Toast';
import { notificationsApi } from '@/api';
import type { NotificationPreferences } from '@/api/notifications';
import { buildTimezoneOptions, getDeviceTimezone } from '@/lib/timezones';
import { SectionShell } from './SectionShell';

type PrefKey = keyof NotificationPreferences;

const CHANNELS: Array<{ key: PrefKey; label: string; desc: string }> = [
  { key: 'push_enabled', label: 'Push notifications', desc: 'Delivered to this device' },
  { key: 'email_enabled', label: 'Email notifications', desc: 'Digest and important updates' },
  { key: 'in_app_enabled', label: 'In-app notifications', desc: 'Bells inside the app' },
];

/** All 12 per-category toggles (exact keys the PUT endpoint accepts). */
const CATEGORIES: Array<{ key: PrefKey; label: string }> = [
  { key: 'buddy_request_push', label: 'Buddy requests' },
  { key: 'buddy_accepted_push', label: 'Buddy accepted' },
  { key: 'new_follower_push', label: 'New followers' },
  { key: 'comment_push', label: 'Comments' },
  { key: 'live_starting_push', label: 'Live starting' },
  { key: 'session_reminder_push', label: 'Session reminders' },
  { key: 'streak_milestone_push', label: 'Streak milestones' },
  { key: 'accountability_ping_push', label: 'Accountability pings' },
  { key: 'programme_reminder_push', label: 'Programme reminders' },
  { key: 'meal_reminder_push', label: 'Meal reminders' },
  { key: 'shop_cert_push', label: 'Shop certifications' },
  { key: 'new_purchase_push', label: 'New purchases' },
];

export default function Notifications() {
  const { toast } = useToast();
  const [prefs, setPrefs] = useState<NotificationPreferences | null>(null);
  const [loading, setLoading] = useState(true);
  const [timezones, setTimezones] = useState<Array<{ value: string; label: string }>>([]);

  useEffect(() => {
    setTimezones(buildTimezoneOptions(getDeviceTimezone()));
    let cancelled = false;
    notificationsApi.getPreferences()
      .then((res) => { if (!cancelled) setPrefs(res.data); })
      .catch(() => { if (!cancelled) setPrefs(null); })
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, []);

  /** Optimistic flip; rolls back to the previous snapshot if the PUT fails. */
  const handleToggle = async (key: PrefKey) => {
    if (!prefs) return;
    const previous = prefs;
    const updated = { ...prefs, [key]: !prefs[key] };
    setPrefs(updated);
    try {
      const res = await notificationsApi.updatePreferences({ [key]: updated[key] });
      setPrefs(res.data);
    } catch {
      setPrefs(previous);
      toast('error', 'Failed to update notification setting');
    }
  };

  const handleQuietHours = async (field: 'quiet_hours_start' | 'quiet_hours_end', value: string) => {
    if (!prefs) return;
    const previous = prefs;
    const updated = { ...prefs, [field]: value || null };
    setPrefs(updated);
    try {
      const res = await notificationsApi.updatePreferences({ [field]: value || null });
      setPrefs(res.data);
    } catch {
      setPrefs(previous);
      toast('error', 'Failed to update quiet hours');
    }
  };

  const handleTimezone = async (timezone: string) => {
    if (!prefs) return;
    const previous = prefs;
    setPrefs({ ...prefs, timezone });
    try {
      const res = await notificationsApi.updatePreferences({ timezone: timezone || null });
      setPrefs(res.data);
    } catch {
      setPrefs(previous);
      toast('error', 'Failed to update timezone');
    }
  };

  return (
    <SectionShell title="Notifications">
      {loading ? (
        <Card className="p-8 text-center"><Loader size={24} className="animate-spin text-buddy-text-secondary mx-auto" /></Card>
      ) : !prefs ? (
        <Card className="p-8 text-center"><p className="text-sm text-buddy-text-secondary">Could not load preferences.</p></Card>
      ) : (
        <div className="space-y-4">
          <Card className="p-4 space-y-4">
            <h3 className="font-heading text-sm font-semibold">Channels</h3>
            {CHANNELS.map(({ key, label, desc }) => (
              <div key={key} className="flex items-center justify-between">
                <div><p className="text-sm">{label}</p><p className="text-xs text-buddy-text-secondary">{desc}</p></div>
                <Toggle checked={Boolean(prefs[key])} onCheckedChange={() => handleToggle(key)} label={label} />
              </div>
            ))}
          </Card>

          <Card className="p-4 space-y-3">
            <h3 className="font-heading text-sm font-semibold">Categories</h3>
            {CATEGORIES.map(({ key, label }) => (
              <div key={key} className="flex items-center justify-between">
                <span className="text-sm">{label}</span>
                <Toggle checked={Boolean(prefs[key])} onCheckedChange={() => handleToggle(key)} label={label} />
              </div>
            ))}
          </Card>

          <Card className="p-4 space-y-3">
            <h3 className="font-heading text-sm font-semibold">Quiet Hours</h3>
            <p className="text-xs text-buddy-text-secondary">Mute everything between these times.</p>
            <div className="flex items-center gap-3">
              <label className="flex-1 space-y-1">
                <span className="text-xs text-buddy-text-secondary">Start</span>
                <input type="time" value={prefs.quiet_hours_start || ''} onChange={(e) => handleQuietHours('quiet_hours_start', e.target.value)}
                  className="w-full bg-buddy-surface-raised text-sm rounded-lg px-3 py-2 border border-buddy-surface text-buddy-text-primary outline-none" />
              </label>
              <label className="flex-1 space-y-1">
                <span className="text-xs text-buddy-text-secondary">End</span>
                <input type="time" value={prefs.quiet_hours_end || ''} onChange={(e) => handleQuietHours('quiet_hours_end', e.target.value)}
                  className="w-full bg-buddy-surface-raised text-sm rounded-lg px-3 py-2 border border-buddy-surface text-buddy-text-primary outline-none" />
              </label>
            </div>
            <label className="block space-y-1">
              <span className="text-xs text-buddy-text-secondary">Timezone</span>
              <select
                value={prefs.timezone || getDeviceTimezone()}
                onChange={(e) => handleTimezone(e.target.value)}
                className="w-full bg-buddy-surface-raised text-sm rounded-lg px-3 py-2 border border-buddy-surface text-buddy-text-primary outline-none"
              >
                {timezones.map((tz) => <option key={tz.value} value={tz.value}>{tz.label}</option>)}
              </select>
            </label>
          </Card>
        </div>
      )}
    </SectionShell>
  );
}
