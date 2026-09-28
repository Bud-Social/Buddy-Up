import { useMemo } from 'react';
import { Trophy } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import type { DashboardData } from '@/api/admin';

function fmtMetric(v: number): string {
  return typeof v === 'number' ? (Math.abs(v) < 10 ? v.toFixed(4) : v.toLocaleString()) : String(v);
}

/** Per-category rollup: best completed run, active artifact, run counts. */
export function PerformanceTab({ data }: { data: DashboardData }) {
  const rows = useMemo(() => {
    const byModel = new Map<string, typeof data.runs>();
    for (const r of data.runs) {
      const list = byModel.get(r.model_name) || [];
      list.push(r);
      byModel.set(r.model_name, list);
    }
    return [...byModel.entries()].map(([name, runs]) => {
      const completed = runs.filter((r) => r.status === 'completed');
      const latest = [...runs].sort((a, b) => b.created_at.localeCompare(a.created_at))[0];
      const versions = data.models.filter((m) => m.name === name);
      const active = versions.find((m) => m.is_active) || null;
      const metricKeys = new Set<string>();
      for (const r of completed) for (const k of Object.keys(r.metrics || {})) metricKeys.add(k);
      const bestKey = ['test_accuracy', 'balanced_accuracy', 'val_auc', 'auc'].find((k) => metricKeys.has(k))
        || [...metricKeys][0] || null;
      let best: { value: number; version: string } | null = null;
      if (bestKey) {
        for (const r of completed) {
          const v = r.metrics?.[bestKey];
          if (typeof v === 'number' && (best === null || v > best.value)) {
            best = { value: v, version: r.version };
          }
        }
      }
      return {
        name, runs: runs.length,
        failed: runs.filter((r) => r.status === 'failed').length,
        latest, active, bestKey, best,
      };
    }).sort((a, b) => a.name.localeCompare(b.name));
  }, [data]);

  if (rows.length === 0) {
    return (
      <Card className="p-8 text-center">
        <Trophy size={32} className="mx-auto text-buddy-text-secondary/30 mb-3" />
        <p className="text-sm text-buddy-text-secondary">No training runs logged yet.</p>
      </Card>
    );
  }

  return (
    <div className="space-y-2">
      {rows.map((row) => (
        <Card key={row.name} className="p-4">
          <div className="flex items-center justify-between gap-2 flex-wrap">
            <p className="font-medium">{row.name.replace(/_/g, ' ')}</p>
            {row.active ? (
              <span className="text-[11px] font-semibold bg-buddy-green/15 text-buddy-green px-2 py-0.5 rounded-full">
                live: {row.active.version}
              </span>
            ) : (
              <span className="text-[11px] font-semibold bg-buddy-surface-raised text-buddy-text-secondary px-2 py-0.5 rounded-full">
                no active artifact
              </span>
            )}
          </div>
          <div className="flex flex-wrap gap-x-4 gap-y-1 mt-2 text-xs text-buddy-text-secondary">
            <span>{row.runs} runs · {row.failed} failed</span>
            {row.best && row.bestKey && (
              <span>best {row.bestKey.replace(/_/g, ' ')}: <span className="font-semibold text-buddy-text-primary">{fmtMetric(row.best.value)}</span> ({row.best.version})</span>
            )}
            <span>latest: {row.latest.version} · {row.latest.scenario || 'default'} · {row.latest.status}</span>
          </div>
        </Card>
      ))}
    </div>
  );
}
