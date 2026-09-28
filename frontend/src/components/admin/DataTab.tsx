import { useCallback, useEffect, useState } from 'react';
import { Database, HardDrive, RefreshCw } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { adminApi, type LoaderStatus, type ScrapeBatch } from '@/api/admin';

function ageString(mtime: number): string {
  if (!mtime) return 'unknown age';
  const mins = Math.max(0, Math.round((Date.now() / 1000 - mtime) / 60));
  if (mins < 60) return `${mins}m ago`;
  const hours = Math.round(mins / 60);
  if (hours < 48) return `${hours}h ago`;
  return `${Math.round(hours / 24)}d ago`;
}

export function DataTab() {
  const [scrapers, setScrapers] = useState<ScrapeBatch[] | null>(null);
  const [loaders, setLoaders] = useState<LoaderStatus | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const load = useCallback(() => {
    setLoading(true);
    setError('');
    Promise.all([adminApi.getScrapers(), adminApi.getLoaders()])
      .then(([s, l]) => {
        setScrapers(s.data || []);
        setLoaders(l.data);
      })
      .catch(() => setError('Failed to load data operations.'))
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => { load(); }, [load]);

  if (loading && !loaders) {
    return <Card className="h-48 animate-pulse bg-buddy-surface-raised" />;
  }
  if (error) {
    return (
      <Card className="p-8 text-center">
        <p className="text-sm text-buddy-text-secondary mb-4">{error}</p>
        <Button variant="outline" size="sm" onClick={load}><RefreshCw size={14} className="mr-1" /> Retry</Button>
      </Card>
    );
  }

  return (
    <div className="space-y-3">
      <Card className="p-4">
        <div className="flex items-center gap-2 mb-2">
          <HardDrive size={16} className="text-buddy-green" />
          <p className="text-sm font-semibold">Training disk</p>
          {loaders?.degraded && (
            <span className="text-[11px] bg-buddy-red/15 text-buddy-red px-2 py-0.5 rounded-full">agent unreachable — disk only</span>
          )}
        </div>
        {loaders && (
          <>
            <div className="h-2 rounded-full bg-buddy-surface-raised overflow-hidden">
              <div
                className="h-full bg-buddy-green rounded-full"
                style={{ width: `${Math.min((loaders.disk.used_gb / Math.max(loaders.disk.total_gb, 0.01)) * 100, 100)}%` }}
              />
            </div>
            <p className="text-xs text-buddy-text-secondary mt-2">
              {loaders.disk.free_gb.toFixed(1)} GB free of {loaders.disk.total_gb.toFixed(1)} GB
            </p>
            {loaders.sources.length > 0 && (
              <div className="mt-3 space-y-1">
                {loaders.sources.map((s) => (
                  <p key={s.name} className="flex justify-between text-xs text-buddy-text-secondary">
                    <span className="truncate mr-2">{s.name}</span>
                    <span className="font-mono">{s.mb.toLocaleString()} MB</span>
                  </p>
                ))}
              </div>
            )}
          </>
        )}
      </Card>

      <Card className="p-4">
        <div className="flex items-center gap-2 mb-3">
          <Database size={16} className="text-buddy-green" />
          <p className="text-sm font-semibold">Scrape batches</p>
          <span className="text-xs text-buddy-text-secondary">({scrapers?.length ?? 0})</span>
        </div>
        {!scrapers || scrapers.length === 0 ? (
          <p className="text-xs text-buddy-text-secondary py-4 text-center">
            No batches on disk. Run <span className="font-mono">data_agent.py fetch --task &lt;name&gt;</span> to stage real data.
          </p>
        ) : (
          <div className="space-y-2">
            {scrapers.map((b) => (
              <div key={`${b.task}/${b.batch}`} className="flex items-start justify-between gap-2 text-xs border-b border-buddy-surface last:border-0 pb-2 last:pb-0">
                <div className="min-w-0">
                  <p className="font-mono truncate">{b.task}/{b.batch}</p>
                  <p className="text-buddy-text-secondary truncate">{b.source || 'unknown source'}</p>
                </div>
                <div className="text-right flex-shrink-0">
                  <p className="font-semibold">{b.mb.toLocaleString()} MB{b.n != null ? ` · n=${b.n.toLocaleString()}` : ''}</p>
                  <p className="text-buddy-text-secondary">{ageString(b.mtime)}</p>
                </div>
              </div>
            ))}
          </div>
        )}
      </Card>
    </div>
  );
}
