import { useState } from 'react';
import { FlaskConical, Loader } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { adminApi, TEST_ROUTES, type ModelTestResult } from '@/api/admin';

function formatBytes(n: number): string {
  if (n < 1024) return `${n} B`;
  if (n < 1024 * 1024) return `${(n / 1024).toFixed(0)} KB`;
  return `${(n / 1024 / 1024).toFixed(1)} MB`;
}

export function TestingTab({ onTested }: { onTested: () => void }) {
  const [route, setRoute] = useState(TEST_ROUTES[0].route);
  const [text, setText] = useState(TEST_ROUTES[0].sample);
  const [json, setJson] = useState('');
  const [image, setImage] = useState<File | null>(null);
  const [running, setRunning] = useState(false);
  const [error, setError] = useState('');
  const [result, setResult] = useState<ModelTestResult | null>(null);

  const spec = TEST_ROUTES.find((r) => r.route === route) || TEST_ROUTES[0];

  const pickRoute = (next: string) => {
    setRoute(next);
    setResult(null);
    setError('');
    const found = TEST_ROUTES.find((r) => r.route === next);
    if (found?.kind === 'text') setText(found.sample);
    if (found?.kind === 'json') setJson(found.sample);
    if (found?.kind === 'image') setImage(null);
  };

  const run = async () => {
    setRunning(true);
    setError('');
    setResult(null);
    try {
      const res = await adminApi.testModel(route, { text, json, image: image || undefined });
      setResult(res.data);
      if (!res.success) setError(res.message || 'Model returned an error.');
      onTested();
    } catch (e) {
      const msg = (e as { response?: { data?: { message?: string } } })?.response?.data?.message;
      setError(msg || 'Test request failed. Is the AI service reachable?');
    } finally {
      setRunning(false);
    }
  };

  return (
    <div className="space-y-3">
      <Card className="p-4">
        <div className="flex items-center gap-2 mb-3">
          <FlaskConical size={16} className="text-buddy-green" />
          <p className="text-sm font-semibold">Probe a live artifact</p>
        </div>
        <label className="block text-xs text-buddy-text-secondary mb-1">Route</label>
        <select
          value={route}
          onChange={(e) => pickRoute(e.target.value)}
          className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm mb-3 focus:outline-none focus:border-buddy-green"
        >
          {TEST_ROUTES.map((r) => (
            <option key={r.route} value={r.route}>{r.model} · {r.route}</option>
          ))}
        </select>

        {spec.kind === 'text' && (
          <>
            <label className="block text-xs text-buddy-text-secondary mb-1">Input text</label>
            <textarea
              value={text}
              onChange={(e) => setText(e.target.value)}
              rows={3}
              className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm focus:outline-none focus:border-buddy-green resize-none"
            />
          </>
        )}
        {spec.kind === 'json' && (
          <>
            <label className="block text-xs text-buddy-text-secondary mb-1">Input JSON</label>
            <textarea
              value={json}
              onChange={(e) => setJson(e.target.value)}
              rows={5}
              spellCheck={false}
              className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-xs font-mono focus:outline-none focus:border-buddy-green resize-none"
            />
          </>
        )}
        {spec.kind === 'image' && (
          <>
            <label className="block text-xs text-buddy-text-secondary mb-1">Input image</label>
            <input
              type="file"
              accept="image/*"
              onChange={(e) => setImage(e.target.files?.[0] || null)}
              className="w-full text-xs text-buddy-text-secondary file:mr-2 file:rounded-lg file:border-0 file:bg-buddy-green/15 file:text-buddy-green file:px-3 file:py-1.5 file:text-xs file:font-semibold"
            />
            {image && <p className="text-xs text-buddy-text-secondary mt-1">{image.name} · {formatBytes(image.size)}</p>}
          </>
        )}

        {error && <p className="text-xs text-buddy-red mt-3">{error}</p>}
        <Button className="mt-3" size="sm" onClick={run} isLoading={running} disabled={running || (spec.kind === 'image' && !image)}>
          {running ? <Loader size={14} className="mr-1 animate-spin" /> : <FlaskConical size={14} className="mr-1" />}
          Run test
        </Button>
      </Card>

      {result && (
        <Card className="p-4">
          <div className="flex flex-wrap items-center gap-2 mb-2">
            <p className="font-medium">{result.model}</p>
            <span className="text-[11px] bg-buddy-surface-raised px-2 py-0.5 rounded-full text-buddy-text-secondary">
              {result.active_version ? `live: ${result.active_version}` : 'no active version'}
            </span>
            <span className="text-[11px] bg-buddy-surface-raised px-2 py-0.5 rounded-full text-buddy-text-secondary">
              {result.elapsed_ms} ms · HTTP {result.status_code}
            </span>
          </div>
          {result.artifact_path && (
            <p className="text-[11px] font-mono text-buddy-text-secondary break-all mb-2">{result.artifact_path}</p>
          )}
          <pre className="text-[11px] font-mono bg-buddy-black/40 rounded-xl p-3 overflow-x-auto max-h-80 overflow-y-auto whitespace-pre-wrap break-all">
            {JSON.stringify(result.result, null, 2)}
          </pre>
        </Card>
      )}
    </div>
  );
}
