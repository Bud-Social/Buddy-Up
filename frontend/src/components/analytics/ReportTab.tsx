import { useState } from 'react';
import { FileBarChart2, Download, Share2, ExternalLink, Check } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { StatCard } from '@/components/analytics/StatCard';
import { formatKm, formatNumber, formatDuration, titleCase } from '@/components/analytics/format';
import { analyticsApi } from '@/api/analytics';
import type { AnalyticsPeriod, AnalyticsReportResult, ShareReportResult } from '@/types/analytics';

interface Props { period: AnalyticsPeriod; }

export function ReportTab({ period }: Props) {
  const [report, setReport] = useState<AnalyticsReportResult | null>(null);
  const [loading, setLoading] = useState(false);
  const [sharing, setSharing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [shared, setShared] = useState<ShareReportResult | null>(null);
  const [body, setBody] = useState('');

  const generate = async () => {
    setLoading(true);
    setError(null);
    setShared(null);
    try {
      const res = await analyticsApi.generateReport(period);
      setReport(res.data);
    } catch {
      setError('Failed to generate report.');
    } finally {
      setLoading(false);
    }
  };

  const download = async () => {
    try {
      const res = await analyticsApi.downloadReport(period);
      if (res.data?.image_url) {
        window.open(res.data.image_url, '_blank');
      }
    } catch {
      setError('Failed to download report.');
    }
  };

  const share = async () => {
    setSharing(true);
    setError(null);
    try {
      const res = await analyticsApi.shareReport({ period, body: body.trim() || undefined });
      setShared(res.data);
      setBody('');
    } catch {
      setError('Failed to share report.');
    } finally {
      setSharing(false);
    }
  };

  const s = report?.data;

  return (
    <div className="space-y-4">
      <Card className="p-4">
        <div className="flex flex-col sm:flex-row sm:items-center gap-3">
          <div className="flex items-center gap-3 flex-1">
            <div className="w-11 h-11 rounded-xl bg-buddy-green/15 flex items-center justify-center text-buddy-green">
              <FileBarChart2 size={22} />
            </div>
            <div>
              <h3 className="font-heading font-semibold">Comprehensive Report</h3>
              <p className="text-sm text-buddy-text-secondary">
                A watermarked summary of your {titleCase(period)} progress — workouts, activity, nutrition, body, lives &amp; spending.
              </p>
            </div>
          </div>
          <Button onClick={generate} isLoading={loading} className="gap-2">
            <FileBarChart2 size={16} />
            {report ? 'Regenerate' : 'Generate Report'}
          </Button>
        </div>
        {error && <p className="text-sm text-buddy-red mt-3">{error}</p>}
      </Card>

      {loading && !report && (
        <div className="animate-pulse grid grid-cols-2 md:grid-cols-4 gap-3">
          {Array.from({ length: 4 }).map((_, i) => <div key={i} className="h-24 bg-buddy-surface rounded-2xl" />)}
          <div className="col-span-2 md:col-span-4 h-72 bg-buddy-surface rounded-2xl" />
        </div>
      )}

      {report && s && (
        <>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            <StatCard label="Workouts" value={formatNumber(s.workouts.count)} sub={`${formatNumber(s.workouts.total_calories_burned)} kcal`} />
            <StatCard label="Distance" value={`${formatKm(s.activity.total_distance_km)} km`} sub={`${formatDuration(s.activity.total_duration_seconds)} active`} />
            <StatCard label="Calories Logged" value={formatNumber(s.nutrition.total_calories)} sub={`${formatNumber(s.nutrition.count)} meals`} />
            <StatCard label="Body" value={s.body.latest_weight_kg ? `${s.body.latest_weight_kg} kg` : '—'} sub={`${s.body.count} check-ins`} />
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
            <Card className="p-4">
              <h3 className="font-heading font-semibold mb-3">Report Image</h3>
              {report.image_url ? (
                <div className="rounded-xl overflow-hidden border border-buddy-surface-raised">
                  <img src={report.image_url} alt="Analytics report" className="w-full" />
                </div>
              ) : (
                <div className="h-48 flex items-center justify-center text-sm text-buddy-text-secondary rounded-xl bg-buddy-surface-raised/50">
                  No image generated.
                </div>
              )}
              <div className="flex gap-2 mt-3">
                <Button variant="outline" onClick={download} className="flex-1 gap-2">
                  <Download size={16} /> Open Full Size
                </Button>
              </div>
            </Card>

            <div className="space-y-4">
              <Card className="p-4">
                <h3 className="font-heading font-semibold mb-2">Share to Feed</h3>
                <p className="text-sm text-buddy-text-secondary mb-3">
                  Post this report as a <span className="text-buddy-green font-medium">progress update</span> on your feed.
                </p>
                <textarea
                  value={body}
                  onChange={(e) => setBody(e.target.value)}
                  placeholder="Add a caption (optional)..."
                  rows={3}
                  className="w-full bg-buddy-surface rounded-xl border border-buddy-surface-raised px-4 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none"
                />
                {shared && (
                  <div className="mt-3 flex items-start gap-2 text-sm text-buddy-green bg-buddy-green/10 rounded-xl p-3">
                    <Check size={16} className="mt-0.5 flex-shrink-0" />
                    <div>
                      <p className="font-medium">Report shared!</p>
                      <p className="text-xs text-buddy-green/80 mt-0.5">Post {shared.post_id.slice(0, 8)}… is live on your feed.</p>
                      <a href="/feed" className="text-xs underline mt-1 inline-flex items-center gap-1">
                        View your feed <ExternalLink size={11} />
                      </a>
                    </div>
                  </div>
                )}
                <Button onClick={share} isLoading={sharing} className="w-full gap-2 mt-3">
                  <Share2 size={16} /> {shared ? 'Share Again' : 'Share Report'}
                </Button>
              </Card>

              <Card className="p-4">
                <h3 className="font-heading font-semibold mb-3">Snapshot</h3>
                <dl className="space-y-2 text-sm">
                  <Row k="Most trained" v={s.workouts.most_trained ? titleCase(s.workouts.most_trained) : '—'} />
                  <Row k="Workout volume" v={`${formatNumber(s.workouts.total_volume)} kg`} />
                  <Row k="Total steps" v={formatNumber(s.activity.total_steps)} />
                  <Row k="Avg pace" v={s.activity.avg_pace ? `${Math.floor(s.activity.avg_pace / 60)}:${String(Math.round(s.activity.avg_pace % 60)).padStart(2, '0')} /km` : '—'} />
                  <Row k="Lives joined" v={formatNumber(s.lives.joined_count)} />
                  <Row k="Lives time" v={formatDuration(s.lives.total_duration_seconds)} />
                  <Row k="Spent" v={`${formatNumber(s.spending.total_artifacts_spent)} artifacts`} />
                  <Row k="Weight change" v={s.body.weight_change_kg != null ? `${s.body.weight_change_kg >= 0 ? '+' : ''}${s.body.weight_change_kg} kg` : '—'} />
                </dl>
              </Card>
            </div>
          </div>
        </>
      )}
    </div>
  );
}

function Row({ k, v }: { k: string; v: string }) {
  return (
    <div className="flex items-center justify-between gap-3">
      <dt className="text-buddy-text-secondary">{k}</dt>
      <dd className="font-medium text-right">{v}</dd>
    </div>
  );
}
