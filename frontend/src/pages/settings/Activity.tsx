import { useCallback, useEffect, useState } from 'react';
import { Activity, Loader } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { activityApi } from '@/api';
import type { ActivityEvent } from '@/api/activity';
import { SectionShell } from './SectionShell';

const ACTIVITY_TYPES = [
  { value: '', label: 'All activity' },
  { value: 'login', label: 'Logins' },
  { value: 'password_changed', label: 'Password changes' },
  { value: '2fa_enabled', label: '2FA enabled' },
  { value: '2fa_disabled', label: '2FA disabled' },
  { value: 'profile_updated', label: 'Profile updates' },
  { value: 'avatar_updated', label: 'Avatar changes' },
  { value: 'post_created', label: 'Posts created' },
  { value: 'buddy_request_sent', label: 'Buddy requests' },
  { value: 'account_deactivated', label: 'Account deactivated' },
] as const;

export default function ActivityLog() {
  const [events, setEvents] = useState<ActivityEvent[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [activityType, setActivityType] = useState('');

  const load = useCallback((type?: string) => {
    setLoading(true);
    setError('');
    activityApi.getActivityLog(type || undefined)
      .then((res) => setEvents(res.data || []))
      .catch(() => setError('Could not load your activity.'))
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => { load(); }, [load]);

  return (
    <SectionShell title="Activity Log">
      <div className="space-y-4">
        <Card className="p-3">
          <select
            value={activityType}
            onChange={(e) => { setActivityType(e.target.value); load(e.target.value); }}
            className="w-full bg-buddy-surface-raised text-sm rounded-lg px-3 py-2 border border-buddy-surface text-buddy-text-primary outline-none"
            aria-label="Filter activity by type"
          >
            {ACTIVITY_TYPES.map(({ value, label }) => <option key={value} value={value}>{label}</option>)}
          </select>
        </Card>

        {loading ? (
          <Card className="p-8 text-center"><Loader size={24} className="animate-spin text-buddy-text-secondary mx-auto" /></Card>
        ) : error ? (
          <Card className="p-8 text-center">
            <p className="text-sm text-buddy-red mb-2">{error}</p>
            <button onClick={() => load(activityType)} className="text-sm text-buddy-green hover:text-buddy-green-deep">Try Again</button>
          </Card>
        ) : events.length === 0 ? (
          <Card className="p-8 text-center">
            <Activity size={32} className="mx-auto text-buddy-text-secondary/30 mb-3" />
            <p className="text-sm text-buddy-text-secondary">No activity recorded yet</p>
          </Card>
        ) : (
          <div className="space-y-2">
            {events.map((e) => (
              <Card key={e.id} className="p-3">
                <div className="flex items-start justify-between gap-2">
                  <div className="min-w-0">
                    <p className="text-sm font-medium capitalize">{e.event_type.replace(/_/g, ' ')}</p>
                    <p className="text-xs text-buddy-text-secondary">{new Date(e.created_at).toLocaleString()}</p>
                    {e.ip_address && <p className="text-xs text-buddy-text-secondary">IP: {e.ip_address}</p>}
                  </div>
                  <span className="text-[10px] text-buddy-text-secondary bg-buddy-surface-raised px-2 py-0.5 rounded-full capitalize flex-shrink-0">
                    {e.event_type.replace(/_/g, ' ')}
                  </span>
                </div>
              </Card>
            ))}
          </div>
        )}
      </div>
    </SectionShell>
  );
}
