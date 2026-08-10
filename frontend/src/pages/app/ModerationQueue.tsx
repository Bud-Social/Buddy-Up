import { useCallback, useEffect, useMemo, useState } from 'react';
import {
  AlertTriangle, CheckCircle2, Flag, RefreshCw, Search, ShieldAlert,
  ShieldCheck, Trash2, ArrowUpRight,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { moderationApi, type ContentFlag, type ModerationStats } from '@/api/moderation';

const POLL_MS = 30_000;

function formatDate(iso: string) {
  try {
    return new Date(iso).toLocaleString();
  } catch {
    return iso;
  }
}

function SeverityBadge({ severity }: { severity: ContentFlag['severity'] }) {
  const styles: Record<ContentFlag['severity'], string> = {
    critical: 'bg-buddy-red/15 text-buddy-red',
    high: 'bg-buddy-red/10 text-buddy-red',
    medium: 'bg-buddy-orange/15 text-buddy-orange',
    low: 'bg-buddy-surface-raised text-buddy-text-secondary',
  };
  return (
    <span className={`text-[11px] font-semibold px-2 py-0.5 rounded-full capitalize ${styles[severity]}`}>
      {severity}
    </span>
  );
}

function ReasonBadge({ reason }: { reason: ContentFlag['flag_reason'] }) {
  const labels: Record<ContentFlag['flag_reason'], string> = {
    nsfw: 'NSFW', toxic: 'Toxic', spam: 'Spam', misinfo: 'Misinfo', custom: 'Custom',
  };
  return (
    <span className="inline-flex items-center gap-1 text-[11px] font-semibold px-2 py-0.5 rounded-full bg-buddy-electric/15 text-buddy-electric uppercase tracking-wide">
      <Flag size={10} />{labels[reason] || reason}
    </span>
  );
}

function StatCard({ label, value, sub }: { label: string; value: string | number; sub?: string }) {
  return (
    <Card className="p-4">
      <p className="text-xs text-buddy-text-secondary">{label}</p>
      <p className="font-display font-extrabold text-2xl leading-tight mt-0.5">{value}</p>
      {sub && <p className="text-[11px] text-buddy-text-secondary truncate">{sub}</p>}
    </Card>
  );
}

export default function ModerationQueue() {
  const [flags, setFlags] = useState<ContentFlag[]>([]);
  const [stats, setStats] = useState<ModerationStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [actingId, setActingId] = useState<string | null>(null);
  const [reasonFilter, setReasonFilter] = useState<'all' | ContentFlag['flag_reason']>('all');
  const [query, setQuery] = useState('');

  const load = useCallback((silent = false) => {
    if (!silent) setLoading(true);
    setError('');
    Promise.all([
      moderationApi.getQueue(reasonFilter === 'all' ? {} : { flag_reason: reasonFilter }),
      moderationApi.getStats(),
    ])
      .then(([queueRes, statsRes]) => {
        setFlags(queueRes.data || []);
        setStats(statsRes.data);
      })
      .catch(() => { if (!silent) setError('Failed to load moderation queue. Staff access required.'); })
      .finally(() => setLoading(false));
  }, [reasonFilter]);

  useEffect(() => { load(); }, [load]);

  useEffect(() => {
    const timer = window.setInterval(() => load(true), POLL_MS);
    return () => window.clearInterval(timer);
  }, [load]);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return flags;
    return flags.filter((f) => `${f.content_preview} ${f.content_id} ${f.source}`.toLowerCase().includes(q));
  }, [flags, query]);

  const act = useCallback(async (flag: ContentFlag, action: 'approve' | 'remove' | 'escalate') => {
    setActingId(flag.id);
    setError('');
    try {
      await moderationApi.actOnFlag(flag.id, action);
      await load(true);
    } catch {
      setError(`Failed to ${action} flag #${flag.id.slice(0, 8)}.`);
    } finally {
      setActingId(null);
    }
  }, [load]);

  if (loading && !flags.length) {
    return (
      <div className="space-y-4">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          {[0, 1, 2, 3].map((i) => <Card key={i} className="h-24 animate-pulse bg-buddy-surface-raised" />)}
        </div>
        <Card className="h-64 animate-pulse bg-buddy-surface-raised" />
      </div>
    );
  }

  if (error && !flags.length) {
    return (
      <Card className="p-8 text-center">
        <ShieldAlert size={32} className="mx-auto text-buddy-red mb-3" />
        <p className="text-sm text-buddy-text-secondary mb-4">{error}</p>
        <Button variant="outline" size="sm" onClick={() => load()}><RefreshCw size={14} className="mr-1" /> Retry</Button>
      </Card>
    );
  }

  const unactioned = stats?.unactioned ?? flags.length;

  return (
    <div className="space-y-6 pb-8">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="font-display text-xl sm:text-2xl font-extrabold">HITL Moderation Queue</h2>
          <p className="text-xs text-buddy-text-secondary mt-0.5">
            Review AI-flagged content · {unactioned} pending
          </p>
        </div>
        <Button variant="outline" size="sm" onClick={() => load()} isLoading={loading}>
          <RefreshCw size={14} className="mr-1" /> Refresh
        </Button>
      </div>

      {error && (
        <div className="bg-buddy-red/5 border border-buddy-red/20 text-buddy-red text-xs rounded-xl px-3 py-2">
          {error}
        </div>
      )}

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <StatCard label="Total flags" value={stats?.total ?? 0} />
        <StatCard label="Pending review" value={unactioned} sub={`${stats?.by_severity.critical ?? 0} critical`} />
        <StatCard label="Actioned" value={stats?.actioned ?? 0} />
        <StatCard label="By reason" value="—" sub={`${stats?.by_reason.nsfw ?? 0} NSFW · ${stats?.by_reason.toxic ?? 0} toxic`} />
      </div>

      <div className="flex flex-wrap items-center gap-2">
        {(['all', 'nsfw', 'toxic', 'spam', 'misinfo', 'custom'] as const).map((r) => (
          <button
            key={r}
            onClick={() => setReasonFilter(r)}
            className={`text-xs px-2.5 py-1 rounded-lg capitalize transition-colors ${
              reasonFilter === r
                ? 'bg-buddy-green/15 text-buddy-green font-semibold'
                : 'text-buddy-text-secondary hover:bg-buddy-surface-raised'
            }`}
          >
            {r === 'all' ? 'All' : r}
          </button>
        ))}
        <div className="relative ml-auto">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-buddy-text-secondary" />
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search preview / id / source…"
            className="w-56 bg-buddy-surface-raised border border-buddy-surface rounded-xl pl-9 pr-3 py-2 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
          />
        </div>
      </div>

      {filtered.length === 0 ? (
        <Card className="p-8 text-center">
          <ShieldCheck size={32} className="mx-auto text-buddy-green/40 mb-3" />
          <p className="text-sm text-buddy-text-secondary">
            {flags.length === 0 ? 'No AI-flagged content awaiting review.' : 'No flags match the current filter.'}
          </p>
        </Card>
      ) : (
        <div className="space-y-2">
          {filtered.map((flag) => (
            <Card key={flag.id} className="p-4">
              <div className="flex flex-wrap items-start gap-3">
                <div className="flex-1 min-w-0">
                  <div className="flex flex-wrap items-center gap-2">
                    <ReasonBadge reason={flag.flag_reason} />
                    <SeverityBadge severity={flag.severity} />
                    <span className="text-[11px] text-buddy-text-secondary font-mono">
                      {flag.content_type}:{flag.content_id.slice(0, 8)}
                    </span>
                    <span className="text-[11px] text-buddy-text-secondary">· {Math.round(flag.confidence * 100)}% conf</span>
                    <span className="text-[11px] text-buddy-text-secondary">· {flag.source}</span>
                  </div>
                  <p className="text-sm mt-2 line-clamp-3 break-words">{flag.content_preview || 'No preview available.'}</p>
                  <p className="text-[11px] text-buddy-text-secondary mt-1.5">{formatDate(flag.created_at)}</p>
                </div>
                <div className="flex items-center gap-2 flex-shrink-0">
                  <Button
                    variant="outline" size="sm"
                    disabled={actingId === flag.id}
                    onClick={() => act(flag, 'approve')}
                  >
                    <CheckCircle2 size={14} className="mr-1" /> Approve
                  </Button>
                  <Button
                    variant="destructive" size="sm"
                    disabled={actingId === flag.id}
                    onClick={() => act(flag, 'remove')}
                  >
                    <Trash2 size={14} className="mr-1" /> Remove
                  </Button>
                  <Button
                    variant="ghost" size="sm"
                    disabled={actingId === flag.id}
                    onClick={() => act(flag, 'escalate')}
                  >
                    <ArrowUpRight size={14} className="mr-1" /> Escalate
                  </Button>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
