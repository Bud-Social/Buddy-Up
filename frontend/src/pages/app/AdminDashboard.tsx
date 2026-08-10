import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import {
  Activity, AlertTriangle, Box, CheckCircle2, ChevronDown, ChevronRight,
  Cpu, Database, HardDrive, Layers, Loader, RefreshCw, Search, XCircle,
} from 'lucide-react';
import {
  Area, AreaChart, Bar, BarChart, CartesianGrid, ResponsiveContainer,
  Tooltip, XAxis, YAxis,
} from 'recharts';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { adminApi, type DashboardData, type TrainingRun } from '@/api/admin';

const POLL_MS = 30_000;

function formatBytes(bytes: number) {
  const gb = bytes / (1024 ** 3);
  return `${gb.toFixed(1)} GB`;
}

function formatDuration(seconds: number | null) {
  if (seconds == null) return '—';
  if (seconds < 60) return `${seconds.toFixed(0)}s`;
  const m = Math.floor(seconds / 60);
  const s = Math.round(seconds % 60);
  return `${m}m ${s}s`;
}

function StatusBadge({ status }: { status: string }) {
  const styles: Record<string, { cls: string; icon: typeof CheckCircle2 }> = {
    completed: { cls: 'bg-buddy-green/15 text-buddy-green', icon: CheckCircle2 },
    running: { cls: 'bg-buddy-electric/15 text-buddy-electric', icon: Activity },
    failed: { cls: 'bg-buddy-red/15 text-buddy-red', icon: XCircle },
  };
  const s = styles[status] || { cls: 'bg-buddy-surface-raised text-buddy-text-secondary', icon: Activity };
  const Icon = s.icon;
  return (
    <span className={`inline-flex items-center gap-1 text-[11px] font-semibold px-2 py-0.5 rounded-full capitalize ${s.cls}`}>
      <Icon size={11} />{status}
    </span>
  );
}

function formatDate(iso: string) {
  try {
    return new Date(iso).toLocaleString();
  } catch {
    return iso;
  }
}

function StatCard({ icon: Icon, label, value, sub }: { icon: typeof Cpu; label: string; value: string | number; sub?: string }) {
  return (
    <Card className="p-4">
      <div className="flex items-center gap-3">
        <div className="w-10 h-10 rounded-xl bg-buddy-green/10 flex items-center justify-center flex-shrink-0">
          <Icon size={20} className="text-buddy-green" />
        </div>
        <div className="min-w-0">
          <p className="text-xs text-buddy-text-secondary">{label}</p>
          <p className="font-display font-extrabold text-2xl leading-tight">{value}</p>
          {sub && <p className="text-[11px] text-buddy-text-secondary truncate">{sub}</p>}
        </div>
      </div>
    </Card>
  );
}

const TOOLTIP_STYLE = {
  background: '#141414',
  border: '1px solid #1E1E1E',
  borderRadius: 12,
  fontSize: 12,
};

function extractPrimaryMetric(run: TrainingRun): { key: string; value: number } | null {
  const entries = Object.entries(run.metrics || {});
  if (entries.length === 0) return null;
  const order = ['test_accuracy', 'balanced_accuracy', 'val_auc', 'auc', 'cal_mae_kcal', 'mae', 'mdae'];
  for (const key of order) {
    const hit = entries.find(([k]) => k === key);
    if (hit && typeof hit[1] === 'number' && Number.isFinite(hit[1])) return { key, value: hit[1] };
  }
  const first = entries[0];
  return typeof first[1] === 'number' && Number.isFinite(first[1])
    ? { key: first[0], value: first[1] } : null;
}

function RunRow({ run, expanded, onToggle }: { run: TrainingRun; expanded: boolean; onToggle: () => void }) {
  const metricEntries = Object.entries(run.metrics || {});
  return (
    <div className="border border-buddy-surface rounded-xl overflow-hidden">
      <button onClick={onToggle} className="w-full flex items-center gap-3 p-3 hover:bg-buddy-surface-raised/60 transition-colors text-left">
        <StatusBadge status={run.status} />
        <div className="flex-1 min-w-0">
          <p className="text-sm font-medium truncate">
            {run.model_name}<span className="text-buddy-text-secondary">:{run.version}</span>
            {run.scenario && <span className="ml-2 text-[10px] uppercase tracking-wide text-buddy-text-secondary bg-buddy-surface-raised px-1.5 py-0.5 rounded">{run.scenario}</span>}
          </p>
          <p className="text-[11px] text-buddy-text-secondary truncate">
            {run.framework}{run.gpu ? ` · ${run.gpu}` : ''} · {formatDuration(run.duration_seconds)} · {formatDate(run.created_at)}
          </p>
        </div>
        {expanded ? <ChevronDown size={16} className="text-buddy-text-secondary" /> : <ChevronRight size={16} className="text-buddy-text-secondary" />}
      </button>
      {expanded && (
        <div className="px-3 pb-3 space-y-2 border-t border-buddy-surface">
          {run.artifact_path && (
            <div className="pt-2">
              <p className="text-[11px] text-buddy-text-secondary">Artifact</p>
              <p className="text-xs font-mono break-all">{run.artifact_path}</p>
            </div>
          )}
          {run.n_classes != null && (
            <div>
              <p className="text-[11px] text-buddy-text-secondary">Classes</p>
              <p className="text-xs">{run.n_classes}</p>
            </div>
          )}
          {metricEntries.length > 0 && (
            <div>
              <p className="text-[11px] text-buddy-text-secondary">Metrics</p>
              <div className="flex flex-wrap gap-1.5 pt-0.5">
                {metricEntries.map(([k, v]) => (
                  <span key={k} className="text-[11px] bg-buddy-surface-raised px-2 py-0.5 rounded-full">
                    <span className="text-buddy-text-secondary">{k.replace(/_/g, ' ')}:</span>{' '}
                    <span className="font-semibold">{typeof v === 'number' ? v.toFixed(4) : v}</span>
                  </span>
                ))}
              </div>
            </div>
          )}
          {run.error && (
            <div className="bg-buddy-red/5 border border-buddy-red/20 rounded-lg p-2">
              <p className="text-[11px] text-buddy-red font-semibold mb-0.5">Error</p>
              <p className="text-xs font-mono whitespace-pre-wrap break-all text-buddy-text-secondary">{run.error}</p>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

export default function AdminDashboard() {
  const [data, setData] = useState<DashboardData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [expandedRun, setExpandedRun] = useState<number | null>(null);
  const [statusFilter, setStatusFilter] = useState<'all' | TrainingRun['status']>('all');
  const [query, setQuery] = useState('');
  const [live, setLive] = useState(true);
  const timerRef = useRef<number | null>(null);

  const load = useCallback((silent = false) => {
    if (!silent) setLoading(true);
    setError('');
    adminApi.getDashboard()
      .then((res) => setData(res.data))
      .catch(() => { if (!silent) setError('Failed to load dashboard. Check that you are staff and the API is reachable.'); })
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => { load(); }, [load]);

  useEffect(() => {
    if (timerRef.current) window.clearInterval(timerRef.current);
    if (live) {
      timerRef.current = window.setInterval(() => load(true), POLL_MS);
    }
    return () => { if (timerRef.current) window.clearInterval(timerRef.current); };
  }, [live, load]);

  const filteredRuns = useMemo(() => {
    if (!data) return [];
    const q = query.trim().toLowerCase();
    return data.runs.filter((r) => {
      if (statusFilter !== 'all' && r.status !== statusFilter) return false;
      if (q && !`${r.model_name} ${r.version} ${r.scenario}`.toLowerCase().includes(q)) return false;
      return true;
    });
  }, [data, statusFilter, query]);

  const trendData = useMemo(() => {
    if (!data) return [];
    const byDay = new Map<string, { day: string; runs: number; completed: number; failed: number }>();
    for (const r of data.runs) {
      const day = new Date(r.created_at).toISOString().slice(0, 10);
      if (!byDay.has(day)) byDay.set(day, { day, runs: 0, completed: 0, failed: 0 });
      const row = byDay.get(day)!;
      row.runs += 1;
      if (r.status === 'completed') row.completed += 1;
      if (r.status === 'failed') row.failed += 1;
    }
    return [...byDay.entries()].sort((a, b) => a[0].localeCompare(b[0])).map(([, v]) => v);
  }, [data]);

  const modelMetricData = useMemo(() => {
    if (!data) return [];
    const byModel = new Map<string, TrainingRun>();
    for (const r of data.runs) {
      if (r.status !== 'completed') continue;
      const cur = byModel.get(r.model_name);
      if (!cur || r.created_at > cur.created_at) byModel.set(r.model_name, r);
    }
    return [...byModel.entries()]
      .map(([name, run]) => {
        const primary = extractPrimaryMetric(run);
        if (!primary) return null;
        return { name: name.replace(/_/g, ' '), [primary.key]: primary.value };
      })
      .filter(Boolean) as Array<Record<string, string | number>>;
  }, [data]);

  const primaryMetricKey = useMemo(() => {
    if (!data) return 'test_accuracy';
    const seen = new Set<string>();
    for (const r of data.runs) {
      for (const k of Object.keys(r.metrics || {})) seen.add(k);
    }
    for (const k of ['test_accuracy', 'balanced_accuracy', 'val_auc', 'auc', 'cal_mae_kcal', 'mae', 'mdae']) {
      if (seen.has(k)) return k;
    }
    return seen.size ? [...seen][0] : 'test_accuracy';
  }, [data]);

  if (loading && !data) {
    return (
      <div className="space-y-4">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          {[0, 1, 2, 3].map((i) => <Card key={i} className="h-24 animate-pulse bg-buddy-surface-raised" />)}
        </div>
        <Card className="h-48 animate-pulse bg-buddy-surface-raised" />
        <Card className="h-64 animate-pulse bg-buddy-surface-raised" />
      </div>
    );
  }

  if (error && !data) {
    return (
      <Card className="p-8 text-center">
        <AlertTriangle size={32} className="mx-auto text-buddy-red mb-3" />
        <p className="text-sm text-buddy-text-secondary mb-4">{error}</p>
        <Button variant="outline" size="sm" onClick={() => load()}><RefreshCw size={14} className="mr-1" /> Retry</Button>
      </Card>
    );
  }

  if (!data) return null;
  const { health, models, runs } = data;

  return (
    <div className="space-y-6 pb-8">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="font-display text-xl sm:text-2xl font-extrabold">Model Training Dashboard</h2>
          <p className="text-xs text-buddy-text-secondary mt-0.5">
            Last training: {health.last_training ? formatDate(health.last_training) : 'never'}
            {live && <span className="ml-2 inline-flex items-center gap-1 text-buddy-green"><span className="w-1.5 h-1.5 rounded-full bg-buddy-green animate-pulse" /> auto-refresh {POLL_MS / 1000}s</span>}
          </p>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="ghost" size="sm" onClick={() => setLive((v) => !v)}>
            {live ? 'Pause' : 'Resume'}
          </Button>
          <Button variant="outline" size="sm" onClick={() => load()} isLoading={loading}>
            <RefreshCw size={14} className="mr-1" /> Refresh
          </Button>
        </div>
      </div>

      {/* Health cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <StatCard icon={Box} label="Models" value={health.models.total} sub={`${health.models.active} active`} />
        <StatCard icon={Activity} label="Training runs" value={health.runs.total} sub={`${health.runs.last_24h} in last 24h`} />
        <StatCard icon={Cpu} label="Status" value={`${health.runs.completed} ✓`} sub={`${health.runs.failed} failed · ${health.runs.running} running`} />
        <StatCard icon={HardDrive} label="Disk" value={`${health.disk.percent}%`} sub={`${formatBytes(health.disk.used_bytes)} / ${formatBytes(health.disk.total_bytes)}`} />
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-3">
        <Card className="p-4">
          <p className="text-xs text-buddy-text-secondary font-medium mb-1">Training Runs by Day</p>
          {trendData.length === 0 ? (
            <p className="text-xs text-buddy-text-secondary py-8 text-center">No runs yet.</p>
          ) : (
            <ResponsiveContainer width="100%" height={160}>
              <AreaChart data={trendData} margin={{ top: 5, right: 8, bottom: 0, left: -25 }}>
                <defs>
                  <linearGradient id="runGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#00C896" stopOpacity={0.35} />
                    <stop offset="95%" stopColor="#00C896" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#1E1E1E" />
                <XAxis dataKey="day" tick={{ fill: '#A0A0A0', fontSize: 10 }} tickLine={false} axisLine={false} />
                <YAxis tick={{ fill: '#A0A0A0', fontSize: 10 }} tickLine={false} axisLine={false} allowDecimals={false} />
                <Tooltip contentStyle={TOOLTIP_STYLE} />
                <Area type="monotone" dataKey="runs" stroke="#00C896" strokeWidth={2} fill="url(#runGrad)" />
              </AreaChart>
            </ResponsiveContainer>
          )}
        </Card>
        <Card className="p-4">
          <p className="text-xs text-buddy-text-secondary font-medium mb-1">Latest Metric per Model</p>
          {modelMetricData.length === 0 ? (
            <p className="text-xs text-buddy-text-secondary py-8 text-center">No completed runs with numeric metrics yet.</p>
          ) : (
            <ResponsiveContainer width="100%" height={160}>
              <BarChart data={modelMetricData} margin={{ top: 5, right: 8, bottom: 0, left: -25 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#1E1E1E" />
                <XAxis dataKey="name" tick={{ fill: '#A0A0A0', fontSize: 9 }} tickLine={false} axisLine={false} interval={0} angle={-22} textAnchor="end" height={46} />
                <YAxis tick={{ fill: '#A0A0A0', fontSize: 10 }} tickLine={false} axisLine={false} />
                <Tooltip contentStyle={TOOLTIP_STYLE} cursor={{ fill: '#1E1E1E' }} />
                <Bar dataKey={primaryMetricKey} fill="#7B61FF" radius={[6, 6, 0, 0]} name={primaryMetricKey.replace(/_/g, ' ')} />
              </BarChart>
            </ResponsiveContainer>
          )}
        </Card>
      </div>

      {/* System details */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <Card className="p-4">
          <div className="flex items-center gap-2 mb-2">
            <HardDrive size={16} className="text-buddy-green" />
            <p className="text-sm font-semibold">Disk usage</p>
          </div>
          <div className="h-2 rounded-full bg-buddy-surface-raised overflow-hidden">
            <div className="h-full bg-buddy-green rounded-full" style={{ width: `${Math.min(health.disk.percent, 100)}%` }} />
          </div>
          <p className="text-xs text-buddy-text-secondary mt-2">
            {formatBytes(health.disk.free_bytes)} free of {formatBytes(health.disk.total_bytes)} · {health.disk.path}
          </p>
        </Card>
        <Card className="p-4">
          <div className="flex items-center gap-2 mb-2">
            <Database size={16} className="text-buddy-green" />
            <p className="text-sm font-semibold">Services</p>
          </div>
          <div className="space-y-1 text-xs text-buddy-text-secondary">
            <p className="flex justify-between"><span>AI service</span><span className="font-mono text-buddy-text-primary">{health.ai_service_url}</span></p>
            <p className="flex justify-between"><span>MLflow URI</span><span className="font-mono text-buddy-text-primary">{health.mlflow_tracking_uri || 'not configured'}</span></p>
            <p className="flex justify-between"><span>Artifact dir</span><span className={`font-mono ${health.artifact_dir.exists ? 'text-buddy-green' : 'text-buddy-red'}`}>{health.artifact_dir.exists ? 'present' : 'missing'}</span></p>
          </div>
        </Card>
      </div>

      {/* Models registry */}
      <section>
        <div className="flex items-center gap-2 mb-3">
          <Layers size={18} className="text-buddy-green" />
          <h3 className="font-heading text-lg font-semibold">Model Registry</h3>
          <span className="text-xs text-buddy-text-secondary">({models.length})</span>
        </div>
        {models.length === 0 ? (
          <Card className="p-8 text-center">
            <Layers size={32} className="mx-auto text-buddy-text-secondary/30 mb-3" />
            <p className="text-sm text-buddy-text-secondary">No models registered yet.</p>
          </Card>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            {models.map((m) => {
              const metrics = Object.entries(m.metrics || {});
              return (
                <Card key={m.id} className="p-4">
                  <div className="flex items-center justify-between gap-2">
                    <p className="font-medium truncate">{m.name}<span className="text-buddy-text-secondary">:{m.version}</span></p>
                    {m.is_active ? (
                      <span className="text-[11px] font-semibold bg-buddy-green/15 text-buddy-green px-2 py-0.5 rounded-full">Active</span>
                    ) : (
                      <span className="text-[11px] font-semibold bg-buddy-surface-raised text-buddy-text-secondary px-2 py-0.5 rounded-full">Inactive</span>
                    )}
                  </div>
                  <p className="text-[11px] text-buddy-text-secondary mt-0.5">{m.framework}</p>
                  {m.description && <p className="text-xs text-buddy-text-secondary mt-1.5 line-clamp-2">{m.description}</p>}
                  {metrics.length > 0 && (
                    <div className="flex flex-wrap gap-1.5 mt-2">
                      {metrics.map(([k, v]) => (
                        <span key={k} className="text-[11px] bg-buddy-surface-raised px-2 py-0.5 rounded-full">
                          <span className="text-buddy-text-secondary">{k.replace(/_/g, ' ')}:</span>{' '}
                          <span className="font-semibold">{typeof v === 'number' ? v.toFixed(4) : v}</span>
                        </span>
                      ))}
                    </div>
                  )}
                </Card>
              );
            })}
          </div>
        )}
      </section>

      {/* Training runs / log viewer */}
      <section>
        <div className="flex flex-wrap items-center gap-2 mb-3">
          <div className="flex items-center gap-2">
            <Database size={18} className="text-buddy-green" />
            <h3 className="font-heading text-lg font-semibold">Recent Training Runs</h3>
            <span className="text-xs text-buddy-text-secondary">({filteredRuns.length}/{runs.length})</span>
          </div>
          <div className="flex items-center gap-1 ml-auto">
            {(['all', 'completed', 'running', 'failed'] as const).map((s) => (
              <button
                key={s}
                onClick={() => setStatusFilter(s)}
                className={`text-xs px-2.5 py-1 rounded-lg capitalize transition-colors ${
                  statusFilter === s
                    ? 'bg-buddy-green/15 text-buddy-green font-semibold'
                    : 'text-buddy-text-secondary hover:bg-buddy-surface-raised'
                }`}
              >
                {s === 'all' ? 'All' : s}
              </button>
            ))}
          </div>
        </div>
        <div className="relative mb-3">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-buddy-text-secondary" />
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search model / version / scenario…"
            className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl pl-9 pr-3 py-2 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
          />
        </div>
        {filteredRuns.length === 0 ? (
          <Card className="p-8 text-center">
            <Activity size={32} className="mx-auto text-buddy-text-secondary/30 mb-3" />
            <p className="text-sm text-buddy-text-secondary">
              {runs.length === 0
                ? 'No training runs logged yet. Notebooks call mlflow_log() to appear here.'
                : 'No runs match the current filter.'}
            </p>
          </Card>
        ) : (
          <div className="space-y-2">
            {filteredRuns.map((run) => (
              <RunRow
                key={run.id}
                run={run}
                expanded={expandedRun === run.id}
                onToggle={() => setExpandedRun(expandedRun === run.id ? null : run.id)}
              />
            ))}
          </div>
        )}
      </section>

      {loading && <div className="flex justify-center py-4"><Loader size={20} className="animate-spin text-buddy-text-secondary" /></div>}
    </div>
  );
}
