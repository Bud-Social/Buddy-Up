import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { marketplaceApi } from '@/api/marketplace';
import type { DiscountAnalytics } from '@/api/marketplace';
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, BarChart, Bar, CartesianGrid } from 'recharts';

export default function DiscountCodeAnalyticsPage() {
  const { codeId } = useParams();
  const navigate = useNavigate();
  const [analytics, setAnalytics] = useState<DiscountAnalytics | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (!codeId) return;
    marketplaceApi.getDiscountCodeAnalytics(codeId)
      .then(res => setAnalytics(res.data))
      .catch(() => {})
      .finally(() => setIsLoading(false));
  }, [codeId]);

  if (isLoading) return (
    <div className="max-w-lg mx-auto p-4 space-y-3 animate-pulse">
      <div className="h-8 w-48 bg-buddy-surface rounded" />
      {Array.from({ length: 4 }).map((_, i) => <div key={i} className="h-24 bg-buddy-surface rounded-xl" />)}
    </div>
  );

  if (!analytics) return (
    <div className="max-w-lg mx-auto p-4 text-center">
      <p className="text-buddy-text-secondary mb-4">Analytics not found.</p>
      <Button onClick={() => navigate('/marketplace/creator')}>Back to Studio</Button>
    </div>
  );

  const code = analytics.code;
  const chartData = analytics.usage_over_time.map(p => ({ date: p.date.slice(0, 10), uses: p.count }));
  const distData = analytics.repeat_usage_distribution.map(d => ({ uses: `${d.uses}x`, users: d.users }));
  const maxDist = Math.max(...distData.map(d => d.users), 1);

  return (
    <div className="max-w-lg mx-auto p-4 pb-24 space-y-4">
      <div className="flex items-center gap-3">
        <button onClick={() => navigate('/marketplace/creator')} className="p-2 rounded-xl bg-buddy-surface hover:bg-buddy-surface-raised transition-colors">
          <ArrowLeft size={20} />
        </button>
        <div className="flex-1 min-w-0">
          <h1 className="font-display text-2xl font-extrabold truncate">Code Analytics</h1>
          <div className="flex items-center gap-2 mt-0.5">
            <p className="font-mono font-bold text-sm text-buddy-electric">{code.code}</p>
            {code.is_expired && <Badge variant="red" label="Expired" size="sm" />}
            {!code.is_expired && code.is_active && <Badge variant="green" label="Active" size="sm" />}
            {!code.is_active && !code.is_expired && <Badge variant="orange" label="Suspended" size="sm" />}
          </div>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-3">
        <Card className="p-4 bg-gradient-to-br from-buddy-electric/20 to-transparent border-buddy-electric/30">
          <p className="text-xs text-buddy-text-secondary font-medium">Total Uses</p>
          <p className="text-2xl font-display font-extrabold mt-1">{analytics.total_uses}</p>
          <p className="text-[10px] text-buddy-electric mt-1">{analytics.successful_uses} successful</p>
        </Card>
        <Card className="p-4">
          <p className="text-xs text-buddy-text-secondary font-medium">Savings (USD)</p>
          <p className="text-2xl font-display font-extrabold mt-1 text-buddy-green">${analytics.total_savings_usd.toFixed(2)}</p>
          <p className="text-[10px] text-buddy-text-secondary mt-1">${analytics.avg_savings_per_user.toFixed(2)} / user</p>
        </Card>
        <Card className="p-4">
          <p className="text-xs text-buddy-text-secondary font-medium">Unique Users</p>
          <p className="text-2xl font-display font-extrabold mt-1">{analytics.unique_users}</p>
          <p className="text-[10px] text-buddy-text-secondary mt-1">{analytics.returning_users} returning</p>
        </Card>
        <Card className="p-4">
          <p className="text-xs text-buddy-text-secondary font-medium">Retention Rate</p>
          <p className="text-2xl font-display font-extrabold mt-1 text-buddy-gold">{analytics.retention_rate}%</p>
          <p className="text-[10px] text-buddy-text-secondary mt-1">users who used code 2+ times</p>
        </Card>
      </div>

      <Card className="p-4">
        <p className="text-xs text-buddy-text-secondary font-medium mb-3">Usage Over Time</p>
        {chartData.length === 0 ? (
          <p className="text-xs text-buddy-text-secondary py-8 text-center">No usage yet.</p>
        ) : (
          <ResponsiveContainer width="100%" height={180}>
            <LineChart data={chartData} margin={{ top: 5, right: 8, bottom: 0, left: -25 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#1E1E1E" />
              <XAxis dataKey="date" tick={{ fill: '#A0A0A0', fontSize: 10 }} tickLine={false} axisLine={false} />
              <YAxis tick={{ fill: '#A0A0A0', fontSize: 10 }} tickLine={false} axisLine={false} allowDecimals={false} />
              <Tooltip contentStyle={{ background: '#141414', border: '1px solid #1E1E1E', borderRadius: 12, fontSize: 12 }} />
              <Line type="monotone" dataKey="uses" stroke="#7B61FF" strokeWidth={2} dot={{ r: 3, fill: '#7B61FF' }} />
            </LineChart>
          </ResponsiveContainer>
        )}
      </Card>

      <Card className="p-4">
        <div className="flex items-center justify-between mb-1">
          <p className="text-xs text-buddy-text-secondary font-medium">Repeat Usage Distribution</p>
          <p className="text-[10px] text-buddy-text-secondary">how many times each user used the code</p>
        </div>
        {distData.length === 0 ? (
          <p className="text-xs text-buddy-text-secondary py-6 text-center">No data yet.</p>
        ) : (
          <div className="flex items-end gap-2 h-32">
            {distData.map(d => (
              <div key={d.uses} className="flex-1 flex flex-col items-center gap-1">
                <div className="w-full bg-buddy-electric/40 hover:bg-buddy-electric rounded-t transition-colors" style={{ height: `${(d.users / maxDist) * 100}%`, minHeight: d.users > 0 ? 8 : 0 }} />
                <span className="text-[10px] text-buddy-text-secondary">{d.users}</span>
                <span className="text-[10px] font-medium">{d.uses}</span>
              </div>
            ))}
          </div>
        )}
      </Card>

      {analytics.top_users.length > 0 && (
        <Card className="p-4">
          <p className="text-xs text-buddy-text-secondary font-medium mb-2">Top Users</p>
          <div className="space-y-2">
            {analytics.top_users.map((u, i) => (
              <div key={i} className="flex items-center justify-between text-xs">
                <div className="flex items-center gap-2 min-w-0">
                  <span className="w-5 h-5 rounded-full bg-buddy-surface-raised flex items-center justify-center text-[10px] font-bold shrink-0">{i + 1}</span>
                  <span className="truncate font-medium">@{u.user__username}</span>
                </div>
                <div className="flex items-center gap-3 flex-shrink-0">
                  <span className="text-buddy-text-secondary">{u.uses} uses</span>
                  <span className="text-buddy-green font-medium">${(u.savings || 0).toFixed(2)} saved</span>
                </div>
              </div>
            ))}
          </div>
        </Card>
      )}

      <Card className="p-4">
        <p className="text-xs text-buddy-text-secondary font-medium mb-2">Code Details</p>
        <div className="grid grid-cols-2 gap-2 text-xs">
          <div><span className="text-buddy-text-secondary">Type</span><p className="font-bold capitalize mt-0.5">{code.discount_type.replace('_', ' ')}</p></div>
          <div><span className="text-buddy-text-secondary">Value</span><p className="font-bold mt-0.5">{code.discount_type === 'percentage' ? `${code.discount_pct}% off` : 'Fixed artifacts'}</p></div>
          <div><span className="text-buddy-text-secondary">Uses</span><p className="font-bold mt-0.5">{code.times_used} / {code.usage_limit || '∞'}</p></div>
          <div><span className="text-buddy-text-secondary">Shares</span><p className="font-bold mt-0.5">{analytics.share_count}</p></div>
          <div className="col-span-2"><span className="text-buddy-text-secondary">Order Value Attributed</span><p className="font-bold mt-0.5 text-buddy-green">${analytics.total_order_value_usd.toFixed(2)}</p></div>
        </div>
      </Card>
    </div>
  );
}
