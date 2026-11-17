import { useEffect, useState } from 'react';
import { CalendarClock, CheckCircle2, Dumbbell, Loader2, UserCheck, XCircle, UserX, Clock3 } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Avatar } from '@/components/ui/Avatar';
import { gymInsightsApi, type GymSessionsPayload } from '@/api/gyms';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from 'recharts';
import { CHART_TOOLTIP, AXIS_TICK, GRID_STROKE } from '@/components/analytics/chartConfig';

interface SessionsTabProps {
  slug: string;
}

const STATUS_STYLE: Record<string, string> = {
  pending: 'bg-buddy-gold/10 text-buddy-gold border-buddy-gold/20',
  confirmed: 'bg-buddy-green/10 text-buddy-green border-buddy-green/20',
  completed: 'bg-buddy-surface text-buddy-text-secondary border-buddy-surface-raised',
  cancelled_by_client: 'bg-buddy-red/10 text-buddy-red border-buddy-red/20',
  cancelled_by_trainer: 'bg-buddy-red/10 text-buddy-red border-buddy-red/20',
  no_show: 'bg-buddy-red/10 text-buddy-red border-buddy-red/20',
};

function fmtWhen(iso: string | null) {
  if (!iso) return '—';
  const d = new Date(iso);
  return `${d.toLocaleDateString(undefined, { weekday: 'short', month: 'short', day: 'numeric' })} · ${d.toLocaleTimeString(undefined, { hour: '2-digit', minute: '2-digit' })}`;
}

function statusLabel(status: string) {
  return status.replaceAll('_', ' ');
}

/**
 * Sessions — bookings made against the coaches/trainers/practitioners tied to
 * this gym, plus the check-ins the gym has received. The summary strip covers
 * the last 30 days; the chart is the daily check-in cadence.
 */
export function SessionsTab({ slug }: SessionsTabProps) {
  const [payload, setPayload] = useState<GymSessionsPayload | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!slug) return;
    setLoading(true);
    setError(null);
    gymInsightsApi.sessions(slug)
      .then((res) => setPayload(res.data ?? null))
      .catch((e: any) => setError(e?.response?.data?.message || 'Could not load sessions.'))
      .finally(() => setLoading(false));
  }, [slug]);

  const s = payload?.summary;
  const series = payload?.check_ins_daily ?? [];

  if (loading) {
    return (
      <div className="grid gap-3 animate-pulse">
        <div className="grid grid-cols-2 md:grid-cols-6 gap-2">
          {Array.from({ length: 6 }).map((_, i) => <div key={i} className="h-20 bg-buddy-surface rounded-2xl" />)}
        </div>
        <div className="h-44 bg-buddy-surface rounded-2xl" />
        <div className="h-56 bg-buddy-surface rounded-2xl" />
      </div>
    );
  }

  return (
    <section className="space-y-3">
      <p className="text-[10px] uppercase text-buddy-text-secondary flex items-center gap-1.5"><Dumbbell size={12} /> Coaches, bookings &amp; door check-ins · last 30 days</p>

      {error && <p className="text-[11px] text-buddy-red bg-buddy-red/10 border border-buddy-red/20 rounded-lg px-2 py-1.5" role="alert">{error}</p>}

      {/* Summary strip */}
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-2">
        {[
          { label: 'Sessions done', value: s?.sessions_30d ?? 0, icon: CheckCircle2, tone: 'text-buddy-green' },
          { label: 'Upcoming 30d', value: s?.upcoming_30d ?? 0, icon: CalendarClock, tone: 'text-buddy-blue' },
          { label: 'Cancelled', value: s?.cancelled_30d ?? 0, icon: XCircle, tone: 'text-buddy-red' },
          { label: 'No-shows', value: s?.no_shows_30d ?? 0, icon: UserX, tone: 'text-buddy-gold' },
          { label: 'Check-ins', value: s?.check_ins_30d ?? 0, icon: UserCheck, tone: 'text-buddy-green' },
          { label: 'Unique attendees', value: s?.unique_attendees_30d ?? 0, icon: Clock3, tone: 'text-buddy-text-primary' },
        ].map(({ label, value, icon: Icon, tone }) => (
          <Card key={label} className="p-3">
            <p className="text-[9px] uppercase text-buddy-text-secondary flex items-center gap-1"><Icon size={11} className={tone} />{label}</p>
            <p className="text-xl font-extrabold font-display tabular-nums mt-1">{value}</p>
          </Card>
        ))}
      </div>

      {/* Check-ins cadence */}
      <Card className="p-4">
        <p className="text-[10px] uppercase text-buddy-text-secondary mb-2">Door check-ins · last 30 days</p>
        {series.length > 0 ? (
          <div className="h-40">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={series} margin={{ top: 4, right: 4, left: -18, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke={GRID_STROKE} vertical={false} />
                <XAxis dataKey="date" tick={AXIS_TICK} tickFormatter={(v: string) => v.slice(5)} interval="preserveStartEnd" />
                <YAxis allowDecimals={false} tick={AXIS_TICK} />
                <Tooltip {...CHART_TOOLTIP} labelFormatter={(v: any) => String(v ?? '')} />
                <Bar dataKey="count" name="Check-ins" fill="#00C896" radius={[3, 3, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        ) : (
          <p className="text-[11px] text-buddy-text-secondary/70 py-6 text-center">No door check-ins in the last 30 days yet.</p>
        )}
      </Card>

      {/* Bookings */}
      <Card className="overflow-hidden">
        <div className="flex items-center justify-between px-4 pt-3 pb-2">
          <p className="text-[10px] uppercase text-buddy-text-secondary">Bookings on gym coaches</p>
          {loading && <Loader2 size={12} className="animate-spin text-buddy-green" />}
        </div>
        {payload && payload.bookings.length > 0 ? (
          <div className="max-h-96 overflow-y-auto divide-y divide-buddy-surface-raised">
            {payload.bookings.map((b) => (
              <div key={b.id} className="flex items-center gap-2.5 px-4 py-2.5">
                <Avatar src={b.client_avatar} alt={b.client_display} size="sm" />
                <div className="min-w-0 flex-1">
                  <p className="text-[11px] font-semibold truncate">{b.client_display} <span className="text-buddy-text-secondary font-normal">with</span> {b.trainer_display}</p>
                  <p className="text-[9px] text-buddy-text-secondary truncate">{fmtWhen(b.scheduled_at)}{b.duration_minutes ? ` · ${b.duration_minutes} min` : ''}{b.session_type ? ` · ${b.session_type.replaceAll('_', ' ')}` : ''}</p>
                </div>
                <span className={`text-[9px] uppercase font-semibold border rounded-full px-2 py-0.5 whitespace-nowrap ${STATUS_STYLE[b.status] || 'bg-buddy-surface text-buddy-text-secondary border-buddy-surface-raised'}`}>
                  {statusLabel(b.status)}
                </span>
              </div>
            ))}
          </div>
        ) : (
          <p className="px-4 pb-4 text-[11px] text-buddy-text-secondary/70">No bookings against your gym’s coaches yet. When a member books a coach tied to this gym, it lands here.</p>
        )}
      </Card>
    </section>
  );
}
