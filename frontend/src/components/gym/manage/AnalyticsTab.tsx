import { useEffect, useMemo, useState } from 'react';
import {
  Share2, Check, TrendingUp, TrendingDown, Users, UserCheck, MessagesSquare,
  ShoppingBag, Utensils, GraduationCap, CalendarDays, Zap, Percent,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Avatar } from '@/components/ui/Avatar';
import { gymInsightsApi, type GymAnalyticsPayload, type GymMessagesPayload } from '@/api/gyms';
import { CHART_TOOLTIP, AXIS_TICK, GRID_STROKE } from '@/components/analytics/chartConfig';
import {
  AreaChart, Area, BarChart, Bar, LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid,
} from 'recharts';

interface AnalyticsTabProps {
  slug: string;
  gymName: string;
}

type Segment = 'overview' | 'posts' | 'messaging' | 'shop';
const SEGMENTS: { key: Segment; label: string }[] = [
  { key: 'overview', label: 'Overview' },
  { key: 'posts', label: 'Posts' },
  { key: 'messaging', label: 'Messaging' },
  { key: 'shop', label: 'Connected shop' },
];

function timeAgo(iso: string | null) {
  if (!iso) return '';
  const s = Math.max(0, (Date.now() - new Date(iso).getTime()) / 1000);
  if (s < 60) return 'just now';
  if (s < 3600) return `${Math.floor(s / 60)}m ago`;
  if (s < 86400) return `${Math.floor(s / 3600)}h ago`;
  if (s < 7 * 86400) return `${Math.floor(s / 86400)}d ago`;
  return new Date(iso).toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
}

function KpiTile({ label, value, sub }: { label: string; value: React.ReactNode; sub?: string }) {
  return (
    <Card className="p-3">
      <p className="text-[9px] uppercase text-buddy-text-secondary">{label}</p>
      <p className="text-xl font-extrabold font-display tabular-nums mt-1">{value}</p>
      {sub && <p className="text-[9px] text-buddy-text-secondary/80 mt-0.5">{sub}</p>}
    </Card>
  );
}

function GrowthChip({ label, pct }: { label: string; pct: number }) {
  const up = pct >= 0;
  return (
    <div className="flex flex-col items-center gap-0.5 rounded-xl bg-buddy-surface px-2 py-2 min-w-[72px]">
      <span className={`flex items-center gap-1 text-xs font-extrabold tabular-nums ${up ? 'text-buddy-green' : 'text-buddy-red'}`}>
        {up ? <TrendingUp size={12} /> : <TrendingDown size={12} />}
        {up ? '+' : ''}{pct}%
      </span>
      <span className="text-[8px] uppercase text-buddy-text-secondary">{label}</span>
    </div>
  );
}

const xTick = (v: string) => String(v).slice(5);

/**
 * Rich analytics for owners: audience growth, conversion & retention,
 * revenue and the connected shop, with a share button for the gym's page.
 * Segmented into Overview / Posts / Messaging / Connected shop.
 */
export function AnalyticsTab({ slug, gymName }: AnalyticsTabProps) {
  const [segment, setSegment] = useState<Segment>('overview');
  const [payload, setPayload] = useState<GymAnalyticsPayload | null>(null);
  const [messages, setMessages] = useState<GymMessagesPayload | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    if (!slug) return;
    setLoading(true);
    setError(null);
    gymInsightsApi.analytics(slug)
      .then((res) => setPayload(res.data ?? null))
      .catch((e: any) => setError(e?.response?.data?.message || 'Could not load analytics.'))
      .finally(() => setLoading(false));
    gymInsightsApi.messages(slug)
      .then((res) => setMessages(res.data ?? null))
      .catch(() => setMessages(null));
  }, [slug]);

  const k = payload?.kpis;
  const g = payload?.growth;
  const ts = payload?.timeseries;

  const share = async () => {
    const text = payload?.share_card ?? `${gymName} insights`;
    const url = typeof window !== 'undefined' ? window.location.href : '';
    try {
      if (navigator.share) {
        await navigator.share({ title: gymName, text, url });
      } else if (navigator.clipboard) {
        await navigator.clipboard.writeText(`${text} — ${url}`);
        setCopied(true);
        window.setTimeout(() => setCopied(false), 2000);
      }
    } catch {
      /* user dismissed the share sheet */
    }
  };

  const shopTiles = useMemo(() => {
    if (!k) return [];
    return [
      { label: 'Events hosted', icon: CalendarDays, tint: '#7B61FF', now: k.events_hosted_30d, total: k.events_hosted },
      { label: 'Products sold', icon: ShoppingBag, tint: '#FF6B35', now: k.products_sold_30d, total: k.products_sold },
      { label: 'Programmes sold', icon: GraduationCap, tint: '#00C896', now: k.programmes_sold_30d, total: k.programmes_sold },
      { label: 'Meal plans sold', icon: Utensils, tint: '#FFD700', now: k.meal_plans_sold_30d, total: k.meal_plans_sold },
    ];
  }, [k]);

  if (loading) {
    return (
      <div className="grid gap-3 animate-pulse">
        <div className="h-10 bg-buddy-surface rounded-2xl" />
        <div className="h-16 bg-buddy-surface rounded-2xl" />
        <div className="grid grid-cols-2 md:grid-cols-4 gap-2">
          {Array.from({ length: 8 }).map((_, i) => <div key={i} className="h-16 bg-buddy-surface rounded-2xl" />)}
        </div>
        <div className="h-48 bg-buddy-surface rounded-2xl" />
      </div>
    );
  }

  return (
    <section className="space-y-3">
      <div className="flex items-center justify-between gap-2 flex-wrap">
        <p className="text-[10px] uppercase text-buddy-text-secondary flex items-center gap-1.5"><Zap size={12} /> Analytics · last 30 days</p>
        <Button size="sm" variant="outline" onClick={share} aria-label="Share gym insights">
          {copied ? <Check size={13} className="mr-1" /> : <Share2 size={13} className="mr-1" />}
          {copied ? 'Copied' : 'Share'}
        </Button>
      </div>

      {error && <p className="text-[11px] text-buddy-red bg-buddy-red/10 border border-buddy-red/20 rounded-lg px-2 py-1.5" role="alert">{error}</p>}

      {/* Growth vs previous 30 days */}
      {g && (
        <Card className="p-3">
          <p className="text-[9px] uppercase text-buddy-text-secondary mb-1.5">Growth · vs previous 30 days</p>
          <div className="flex gap-1.5 overflow-x-auto pb-0.5 -mx-1 px-1">
            <GrowthChip label="Audience" pct={g.audience_pct} />
            <GrowthChip label="Check-ins" pct={g.check_ins_pct} />
            <GrowthChip label="Bookings" pct={g.bookings_pct} />
            <GrowthChip label="Posts" pct={g.posts_pct} />
            <GrowthChip label="Messages" pct={g.messages_pct} />
            <GrowthChip label="Revenue" pct={g.revenue_pct} />
          </div>
        </Card>
      )}

      {/* Segmented control */}
      <div className="flex rounded-lg bg-buddy-surface p-0.5 w-max max-w-full overflow-x-auto" role="group" aria-label="Analytics sections">
        {SEGMENTS.map(({ key, label }) => (
          <button
            key={key}
            onClick={() => setSegment(key)}
            aria-pressed={segment === key}
            className={`px-3 py-1.5 rounded-md text-[11px] font-semibold whitespace-nowrap transition-colors ${segment === key ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary'}`}
          >
            {label}
          </button>
        ))}
      </div>

      {segment === 'overview' && k && (
        <>
          {/* Audience & retention */}
          <div>
            <p className="text-[9px] uppercase text-buddy-text-secondary mb-1.5 flex items-center gap-1.5"><Users size={11} /> Audience &amp; retention</p>
            <div className="grid grid-cols-2 md:grid-cols-6 gap-2">
              <KpiTile label="Active members" value={k.active_members} />
              <KpiTile label="New · 30d" value={`+${k.new_members_30d}`} />
              <KpiTile label="Churned · 30d" value={k.churned_30d} />
              <KpiTile label="Retention" value={`${k.retention_rate_30d}%`} sub="Active vs churned" />
              <KpiTile label="Activation" value={`${k.activation_rate_30d}%`} sub="Attendees / members" />
              <KpiTile label="Community members" value={k.community_members} sub="In linked communities" />
            </div>
          </div>

          {/* Door & coaching */}
          <div>
            <p className="text-[9px] uppercase text-buddy-text-secondary mb-1.5 flex items-center gap-1.5"><UserCheck size={11} /> Door &amp; coaching</p>
            <div className="grid grid-cols-2 md:grid-cols-6 gap-2">
              <KpiTile label="Check-ins" value={k.check_ins_30d} />
              <KpiTile label="Per day" value={k.avg_check_ins_per_day} />
              <KpiTile label="Unique attendees" value={k.unique_attendees_30d} />
              <KpiTile label="Visit rate" value={k.visit_rate_30d} sub="Check-ins per active member" />
              <KpiTile label="Bookings" value={k.bookings_30d} />
              <KpiTile label="Completed" value={k.completed_bookings_30d} sub="Sessions done" />
            </div>
          </div>

          {/* Conversion */}
          <div>
            <p className="text-[9px] uppercase text-buddy-text-secondary mb-1.5 flex items-center gap-1.5"><Percent size={11} /> Conversion</p>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-2">
              <Card className="p-3">
                <p className="text-[9px] uppercase text-buddy-text-secondary">Join-request conversion</p>
                <p className="text-2xl font-extrabold font-display tabular-nums mt-1">{k.join_conversion_30d}<span className="text-xs text-buddy-text-secondary">%</span></p>
                <div className="mt-1.5 h-1.5 rounded bg-buddy-surface-raised overflow-hidden">
                  <div className="h-full bg-buddy-green rounded" style={{ width: `${Math.min(100, k.join_conversion_30d)}%` }} />
                </div>
                <p className="text-[9px] text-buddy-text-secondary/80 mt-1">{k.join_requests_approved_30d} of {k.join_requests_30d} requests approved</p>
              </Card>
              <Card className="p-3">
                <p className="text-[9px] uppercase text-buddy-text-secondary">Member activation</p>
                <p className="text-2xl font-extrabold font-display tabular-nums mt-1">{k.activation_rate_30d}<span className="text-xs text-buddy-text-secondary">%</span></p>
                <div className="mt-1.5 h-1.5 rounded bg-buddy-surface-raised overflow-hidden">
                  <div className="h-full bg-buddy-blue rounded" style={{ width: `${Math.min(100, k.activation_rate_30d)}%` }} />
                </div>
                <p className="text-[9px] text-buddy-text-secondary/80 mt-1">{k.unique_attendees_30d} of {k.active_members} members checked in</p>
              </Card>
              <Card className="p-3">
                <p className="text-[9px] uppercase text-buddy-text-secondary">Retention</p>
                <p className="text-2xl font-extrabold font-display tabular-nums mt-1">{k.retention_rate_30d}<span className="text-xs text-buddy-text-secondary">%</span></p>
                <div className="mt-1.5 h-1.5 rounded bg-buddy-surface-raised overflow-hidden">
                  <div className="h-full bg-buddy-gold rounded" style={{ width: `${Math.min(100, k.retention_rate_30d)}%` }} />
                </div>
                <p className="text-[9px] text-buddy-text-secondary/80 mt-1">Active vs {k.churned_30d} churned · 30d</p>
              </Card>
            </div>
          </div>

          {/* Revenue curve */}
          <Card className="p-4">
            <p className="text-[10px] uppercase text-buddy-text-secondary mb-2">Revenue artifacts · last 30 days</p>
            {ts && ts.revenue_artifacts.some((p) => p.count > 0) ? (
              <div className="h-40">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={ts.revenue_artifacts} margin={{ top: 4, right: 4, left: -14, bottom: 0 }}>
                    <defs>
                      <linearGradient id="revArtifacts" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#FFD700" stopOpacity={0.35} />
                        <stop offset="95%" stopColor="#FFD700" stopOpacity={0} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke={GRID_STROKE} vertical={false} />
                    <XAxis dataKey="date" tick={AXIS_TICK} tickFormatter={xTick} interval="preserveStartEnd" />
                    <YAxis allowDecimals={false} tick={AXIS_TICK} />
                    <Tooltip {...CHART_TOOLTIP} />
                    <Area type="monotone" dataKey="count" name="Artifacts" stroke="#FFD700" strokeWidth={2} fill="url(#revArtifacts)" />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            ) : (
              <p className="text-[11px] text-buddy-text-secondary/70 py-6 text-center">No gym revenue recorded in the last 30 days yet.</p>
            )}
          </Card>
        </>
      )}

      {segment === 'posts' && k && (
        <>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-2">
            <KpiTile label="Posts · 30d" value={k.posts_30d} sub="Routine posts & classes" />
            <KpiTile label="Avg per day" value={(k.posts_30d / 30).toFixed(1)} />
            <KpiTile label="Audience growth" value={`${g?.audience_pct ?? 0}%`} sub="New members vs prev. 30d" />
            <KpiTile label="Visit rate" value={k.visit_rate_30d} sub="Check-ins per active member" />
          </div>
          <Card className="p-4">
            <p className="text-[10px] uppercase text-buddy-text-secondary mb-2">Posts per day · last 30 days</p>
            {ts && ts.posts.some((p) => p.count > 0) ? (
              <div className="h-48">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={ts.posts} margin={{ top: 4, right: 4, left: -18, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke={GRID_STROKE} vertical={false} />
                    <XAxis dataKey="date" tick={AXIS_TICK} tickFormatter={xTick} interval="preserveStartEnd" />
                    <YAxis allowDecimals={false} tick={AXIS_TICK} />
                    <Tooltip {...CHART_TOOLTIP} />
                    <Bar dataKey="count" name="Posts" fill="#7B61FF" radius={[3, 3, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            ) : (
              <p className="text-[11px] text-buddy-text-secondary/70 py-6 text-center">No gym posts in the last 30 days. Post from the Posts tab to see momentum here.</p>
            )}
          </Card>
          <p className="text-[9px] text-buddy-text-secondary/70">Routine posts and class sessions feed this curve; announcements and the gym feed live in the Posts tab.</p>
        </>
      )}

      {segment === 'messaging' && k && (
        <>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-2">
            <KpiTile label="Messages · 30d" value={k.messages_30d} sub="Your inbox & linked communities" />
            <KpiTile label="From real clients" value={k.inbound_client_messages_30d} sub="Not your staff" />
            <KpiTile label="Messaging growth" value={`${g?.messages_pct ?? 0}%`} sub="vs previous 30d" />
            <KpiTile label="Community members" value={k.community_members} sub="Across linked communities" />
          </div>
          <Card className="p-4">
            <p className="text-[10px] uppercase text-buddy-text-secondary mb-2">Messages per day · last 30 days</p>
            {ts && ts.messages.some((p) => p.count > 0) ? (
              <div className="h-48">
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={ts.messages} margin={{ top: 4, right: 4, left: -14, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke={GRID_STROKE} vertical={false} />
                    <XAxis dataKey="date" tick={AXIS_TICK} tickFormatter={xTick} interval="preserveStartEnd" />
                    <YAxis allowDecimals={false} tick={AXIS_TICK} />
                    <Tooltip {...CHART_TOOLTIP} />
                    <Line type="monotone" dataKey="count" name="Messages" stroke="#00C896" strokeWidth={2} dot={false} />
                  </LineChart>
                </ResponsiveContainer>
              </div>
            ) : (
              <p className="text-[11px] text-buddy-text-secondary/70 py-6 text-center">No messages in gym conversations yet.</p>
            )}
          </Card>
          <Card className="overflow-hidden">
            <p className="text-[10px] uppercase text-buddy-text-secondary px-4 pt-3 pb-2 flex items-center gap-1.5"><MessagesSquare size={12} /> Latest from real clients</p>
            {messages && messages.recent_inbound.length > 0 ? (
              <div className="max-h-64 overflow-y-auto divide-y divide-buddy-surface-raised">
                {messages.recent_inbound.slice(0, 8).map((m) => (
                  <div key={m.id} className="flex items-start gap-2 px-4 py-2">
                    <Avatar src={m.sender_avatar} alt={m.sender_display} size="xs" />
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center gap-2">
                        <p className="text-[10px] font-semibold">{m.sender_display}</p>
                        <p className="text-[9px] text-buddy-text-secondary/70">{timeAgo(m.sent_at)}</p>
                      </div>
                      <p className="text-[11px] text-buddy-text-secondary line-clamp-2">{m.body}</p>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="px-4 pb-4 text-[11px] text-buddy-text-secondary/70">No client messages in the last 30 days.</p>
            )}
          </Card>
        </>
      )}

      {segment === 'shop' && k && (
        <>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-2">
            <KpiTile label="Paid orders · 30d" value={k.shop_orders_30d} sub="Across connected shops" />
            <KpiTile label="Revenue · 30d" value={k.revenue_30d_artifacts} sub="Artifacts · joins + shops + events" />
            <KpiTile label="Revenue growth" value={`${g?.revenue_pct ?? 0}%`} sub="vs previous 30d" />
            <KpiTile label="Lifetime artifacts" value={k.revenue_lifetime_artifacts} />
          </div>
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-2">
            {shopTiles.map(({ label, icon: Icon, tint, now, total }) => (
              <Card key={label} className="p-3" style={{ borderTop: `2px solid ${tint}` }}>
                <p className="text-[9px] uppercase text-buddy-text-secondary flex items-center gap-1"><Icon size={11} style={{ color: tint }} />{label}</p>
                <p className="text-2xl font-extrabold font-display tabular-nums mt-1">{now}</p>
                <p className="text-[9px] text-buddy-text-secondary/80 mt-0.5">{total} all-time</p>
              </Card>
            ))}
          </div>
          <p className="text-[9px] text-buddy-text-secondary/70">30-day vs all-time sales for events, products, programmes and meal plans sold by the shop(s) connected to this gym. Connect a shop from the Shops tab to see this fill in.</p>
        </>
      )}
    </section>
  );
}
