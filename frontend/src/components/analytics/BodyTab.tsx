import { useEffect, useMemo, useRef, useState } from 'react';
import { Scale, Camera, X } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { StatCard } from '@/components/analytics/StatCard';
import { CHART_TOOLTIP, AXIS_TICK, GRID_STROKE, COLORS } from '@/components/analytics/chartConfig';
import { formatDate } from '@/components/analytics/format';
import { analyticsApi } from '@/api/analytics';
import type { AnalyticsSummaryData, BodyMetricInput } from '@/types/analytics';
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from 'recharts';

interface BodyRow {
  id: string;
  weight_kg: number;
  body_fat_pct: number | null;
  photo_url: string;
  notes: string;
  measured_at: string;
}

export function BodyTab() {
  const [summary, setSummary] = useState<AnalyticsSummaryData | null>(null);
  const [weight, setWeight] = useState('');
  const [bodyFat, setBodyFat] = useState('');
  const [notes, setNotes] = useState('');
  const [photo, setPhoto] = useState<File | null>(null);
  const [preview, setPreview] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const load = () => {
    analyticsApi.getSummary('all')
      .then((res) => setSummary(res.data))
      .catch(() => {});
  };

  useEffect(() => { load(); }, []);

  useEffect(() => () => {
    if (preview?.startsWith('blob:')) URL.revokeObjectURL(preview);
  }, [preview]);

  const handleFile = (e: React.ChangeEvent<HTMLInputElement>) => {
    const f = e.target.files?.[0];
    if (!f) return;
    setPhoto(f);
    setPreview(URL.createObjectURL(f));
  };

  const submit = async () => {
    const w = Number(weight);
    if (!w || w <= 0) { setError('Enter a valid weight.'); return; }
    setSaving(true);
    setError(null);
    const payload: BodyMetricInput = {
      weight_kg: w,
      body_fat_pct: bodyFat ? Number(bodyFat) : null,
      notes: notes || undefined,
      measured_at: new Date().toISOString(),
    };
    try {
      if (photo) {
        await analyticsApi.createBodyMetricWithPhoto(payload, photo);
      } else {
        await analyticsApi.createBodyMetric(payload);
      }
      setWeight(''); setBodyFat(''); setNotes(''); setPhoto(null); setPreview(null);
      load();
    } catch {
      setError('Failed to save body metric.');
    } finally {
      setSaving(false);
    }
  };

  const b = summary?.body;
  const chartData = useMemo(() => {
    if (!b) return [];
    return b.series.map((p) => ({
      date: p.measured_at ? p.measured_at.slice(0, 10) : '',
      kg: p.weight_kg,
    }));
  }, [b]);

  const snapRows: BodyRow[] = useMemo(() => {
    if (!b) return [];
    return (b.series as unknown as BodyRow[]).slice().reverse();
  }, [b]);

  const change = b?.weight_change_kg ?? 0;

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <StatCard label="Start Weight" value={b?.start_weight_kg ? `${b.start_weight_kg} kg` : '—'} icon={<Scale size={18} />} />
        <StatCard label="Current Weight" value={b?.latest_weight_kg ? `${b.latest_weight_kg} kg` : '—'} icon={<Scale size={18} />} />
        <StatCard label="Change" value={`${change >= 0 ? '+' : ''}${change} kg`} trend={b && b.count > 1 ? Math.round(Math.abs((change / (b.start_weight_kg || 1)) * 100)) : undefined} icon={<Scale size={18} />} />
        <StatCard label="Body Fat" value={b?.latest_body_fat_pct ? `${b.latest_body_fat_pct}%` : '—'} icon={<Scale size={18} />} />
      </div>

      {/* Weight chart */}
      <Card className="p-4">
        <h3 className="font-heading font-semibold mb-3">Weight Progress</h3>
        {chartData.length >= 2 ? (
          <div className="h-60">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={chartData} margin={{ top: 4, right: 8, left: -16, bottom: 0 }}>
                <CartesianGrid stroke={GRID_STROKE} strokeDasharray="3 3" vertical={false} />
                <XAxis dataKey="date" tick={AXIS_TICK} axisLine={false} tickLine={false} />
                <YAxis domain={['auto', 'auto']} tick={AXIS_TICK} axisLine={false} tickLine={false} />
                <Tooltip {...CHART_TOOLTIP} />
                <Line type="monotone" dataKey="kg" stroke={COLORS[0]} strokeWidth={2} dot={{ r: 4, fill: COLORS[0] }} name="kg" />
              </LineChart>
            </ResponsiveContainer>
          </div>
        ) : (
          <div className="h-40 flex items-center justify-center rounded-xl bg-buddy-surface-raised/50 text-sm text-buddy-text-secondary">
            Log at least two measurements to see your trend.
          </div>
        )}
      </Card>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {/* Add measurement */}
        <Card className="p-4">
          <h3 className="font-heading font-semibold mb-3">Record Measurement</h3>
          <div className="space-y-3">
            <div className="grid grid-cols-2 gap-2">
              <Input label="Weight (kg) *" type="number" step="0.1" min={0} placeholder="72.5" value={weight} onChange={(e) => setWeight(e.target.value)} />
              <Input label="Body Fat %" type="number" step="0.1" min={0} placeholder="18.0" value={bodyFat} onChange={(e) => setBodyFat(e.target.value)} />
            </div>
            <Input label="Notes" placeholder="Feeling strong, cut week 2..." value={notes} onChange={(e) => setNotes(e.target.value)} />

            {/* Body snap */}
            <div>
              <p className="text-sm font-medium text-buddy-text-secondary mb-1.5">Body Snap</p>
              <input ref={fileInputRef} type="file" accept="image/*" className="hidden" onChange={handleFile} />
              {preview ? (
                <div className="relative rounded-xl overflow-hidden">
                  <img src={preview} alt="Body snap preview" className="w-full h-48 object-cover" />
                  <button onClick={() => { setPhoto(null); setPreview(null); }} className="absolute top-2 right-2 p-1.5 bg-black/60 rounded-full text-white hover:bg-black/80">
                    <X size={14} />
                  </button>
                </div>
              ) : (
                <button
                  onClick={() => fileInputRef.current?.click()}
                  className="w-full h-28 rounded-xl border-2 border-dashed border-buddy-text-secondary/20 hover:border-buddy-green/50 flex flex-col items-center justify-center gap-1.5 text-buddy-text-secondary hover:text-buddy-green transition-colors"
                >
                  <Camera size={20} />
                  <span className="text-sm">Upload body snap</span>
                </button>
              )}
            </div>

            {error && <p className="text-sm text-buddy-red">{error}</p>}
            <Button onClick={submit} isLoading={saving} className="w-full">
              Save Measurement
            </Button>
          </div>
        </Card>

        {/* Progress snaps */}
        <div>
          <h3 className="font-heading font-semibold mb-3">Progress Snaps</h3>
          {snapRows.length === 0 ? (
            <Card className="p-6 text-center text-buddy-text-secondary text-sm">
              Upload a body snap to start your progress gallery.
            </Card>
          ) : (
            <div className="grid grid-cols-2 gap-3">
              {snapRows.map((r) => (
                <Card key={r.id} className="overflow-hidden">
                  {r.photo_url ? (
                    <img src={r.photo_url} alt="Body snap" className="w-full h-36 object-cover" />
                  ) : (
                    <div className="w-full h-36 bg-buddy-surface-raised flex items-center justify-center text-buddy-text-secondary/50">
                      <Scale size={20} />
                    </div>
                  )}
                  <div className="p-2.5">
                    <p className="text-sm font-medium">{r.weight_kg} kg</p>
                    <p className="text-xs text-buddy-text-secondary">{formatDate(r.measured_at)}</p>
                    {r.notes && <p className="text-xs text-buddy-text-secondary mt-1 line-clamp-1">{r.notes}</p>}
                  </div>
                </Card>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
