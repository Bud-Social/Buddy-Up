import { useCallback, useEffect, useState } from 'react';
import {
  ScrollText, ChevronDown, ChevronRight, RefreshCw, MapPin, Megaphone, UserCog,
  Users, Store, Calendar, BadgeCheck, Pencil, FileText, Activity,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { gymsApi } from '@/api/gyms';
import type { GymActionLog } from '@/types';

interface LogsTabProps {
  slug: string;
}

const ACTION_FAMILIES: { key: string; label: string; icon: typeof Pencil }[] = [
  { key: '', label: 'All', icon: Activity },
  { key: 'gym.update', label: 'Gym', icon: Pencil },
  { key: 'gym.venue', label: 'Venues', icon: MapPin },
  { key: 'gym.coach', label: 'Coaches', icon: Users },
  { key: 'gym.member', label: 'Members', icon: UserCog },
  { key: 'gym.announce', label: 'Announce', icon: Megaphone },
  { key: 'gym.events', label: 'Events', icon: Calendar },
  { key: 'gym.shops', label: 'Shops', icon: Store },
  { key: 'gym.tier', label: 'Tier', icon: BadgeCheck },
  { key: 'gym.registration', label: 'Registration', icon: FileText },
];

function iconFor(action: string) {
  const family = ACTION_FAMILIES.find((f) => f.key && action.startsWith(f.key));
  return family?.icon ?? ScrollText;
}

function labelFor(action: string) {
  return action;
}

function shortTime(iso: string) {
  const d = new Date(iso);
  const diff = Date.now() - d.getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return 'just now';
  if (mins < 60) return `${mins}m ago`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `${days}d ago`;
  return d.toLocaleDateString();
}

function DiffTable({ before, after }: { before: GymActionLog['before']; after: GymActionLog['after'] }) {
  const keys = Array.from(new Set([...(before ? Object.keys(before) : []), ...(after ? Object.keys(after) : [])]));
  if (keys.length === 0) return <p className="text-[11px] text-buddy-text-secondary">No state delta recorded.</p>;
  return (
    <div className="mt-2 rounded-xl border border-buddy-surface-raised bg-buddy-surface overflow-hidden">
      <table className="w-full text-[11px]">
        <thead>
          <tr className="text-buddy-text-secondary bg-buddy-surface-raised/40">
            <th className="text-left px-2 py-1 font-medium">Field</th>
            <th className="text-left px-2 py-1 font-medium">Before</th>
            <th className="text-left px-2 py-1 font-medium">After</th>
          </tr>
        </thead>
        <tbody>
          {keys.map((k) => (
            <tr key={k} className="border-t border-buddy-surface-raised/60">
              <td className="px-2 py-1 font-mono text-[10px] text-buddy-text-secondary">{k}</td>
              <td className="px-2 py-1 break-all">{before && k in before ? String(before[k] ?? '—') : '—'}</td>
              <td className="px-2 py-1 break-all">{after && k in after ? String(after[k] ?? '—') : '—'}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

/**
 * Privileged-action audit trail for the gym. Append-only on the server;
 * moderators, owners and co-owners see it — members never do.
 */
export function LogsTab({ slug }: LogsTabProps) {
  const [logs, setLogs] = useState<GymActionLog[] | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [family, setFamily] = useState('');
  const [expanded, setExpanded] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await gymsApi.getActionLogs(slug, { ...(family ? { action: family } : {}), limit: 200 });
      setLogs(Array.isArray(res.data) ? res.data : []);
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not load the action log.');
      setLogs([]);
    } finally {
      setLoading(false);
    }
  }, [slug, family]);

  useEffect(() => { load(); }, [load]);

  return (
    <section className="space-y-3">
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <h2 className="text-sm font-bold text-buddy-text-secondary uppercase flex items-center gap-2">
          <ScrollText size={14} /> Action log{logs ? ` (${logs.length})` : ''}
        </h2>
        <Button size="sm" variant="ghost" onClick={load} disabled={loading} aria-label="Refresh log">
          <RefreshCw size={13} className={loading ? 'animate-spin' : ''} />
        </Button>
      </div>

      <div className="flex flex-wrap gap-1.5">
        {ACTION_FAMILIES.map(({ key, label, icon: Icon }) => {
          const active = family === key;
          return (
            <button
              key={key || 'all'}
              type="button"
              onClick={() => setFamily(key)}
              aria-pressed={active}
              className={`flex items-center gap-1 px-2 py-1 rounded-full text-[11px] border transition-colors ${
                active
                  ? 'border-buddy-green bg-buddy-green/10 text-buddy-green'
                  : 'border-buddy-surface-raised text-buddy-text-secondary hover:text-buddy-text-primary'
              }`}
            >
              <Icon size={10} /> {label}
            </button>
          );
        })}
      </div>

      {error && <p className="text-xs text-buddy-red bg-buddy-red/5 border border-buddy-red/20 rounded-lg px-3 py-2" role="alert">{error}</p>}
      {!error && logs === null && <Card className="h-24 animate-pulse bg-buddy-surface-raised" />}
      {!error && logs?.length === 0 && (
        <Card className="p-8 text-center text-buddy-text-secondary text-xs">
          Nothing logged yet. Privileged actions (role changes, venues, coaches,<br />
          announcements, events, shop links) will appear here.
        </Card>
      )}

      <div className="space-y-2">
        {logs?.map((log) => {
          const Icon = iconFor(log.action);
          const open = expanded === log.id;
          return (
            <Card key={log.id} className="p-3">
              <button
                type="button"
                className="flex w-full items-start gap-3 text-left"
                onClick={() => setExpanded(open ? null : log.id)}
                aria-expanded={open}
              >
                <span className="w-8 h-8 shrink-0 rounded-lg bg-buddy-green/10 text-buddy-green flex items-center justify-center">
                  <Icon size={15} />
                </span>
                <span className="flex-1 min-w-0">
                  <span className="flex items-center gap-2 flex-wrap">
                    <span className="text-[10px] font-mono uppercase text-buddy-text-secondary">{labelFor(log.action)}</span>
                    <span className="text-[10px] text-buddy-text-secondary">· @{log.actor || 'system'}</span>
                    <span className="text-[10px] text-buddy-text-secondary ml-auto" title={new Date(log.created_at).toLocaleString()}>
                      {shortTime(log.created_at)}
                    </span>
                  </span>
                  <span className="block text-xs text-buddy-text-primary mt-0.5 break-words">{log.summary}</span>
                </span>
                <span className="shrink-0 text-buddy-text-secondary">{open ? <ChevronDown size={14} /> : <ChevronRight size={14} />}</span>
              </button>
              {open && <DiffTable before={log.before} after={log.after} />}
            </Card>
          );
        })}
      </div>
    </section>
  );
}

export default LogsTab;
