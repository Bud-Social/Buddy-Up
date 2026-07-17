import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { marketplaceApi } from '@/api/marketplace';

export default function CreatorStudio() {
  const navigate = useNavigate();
  const [data, setData] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    marketplaceApi.getMyServices()
      .then((res) => setData(res.data))
      .catch(() => {})
      .finally(() => setIsLoading(false));
  }, []);

  if (isLoading) return <div className="p-4 text-center">Loading...</div>;
  if (!data) return <div className="p-4 text-center text-buddy-text-secondary">Failed to load.</div>;

  return (
    <div className="max-w-lg mx-auto p-4 space-y-6 pb-20">
      <div className="flex items-center gap-3 mb-2">
        <button onClick={() => navigate('/marketplace')} className="p-2 rounded-full hover:bg-buddy-surface">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <h1 className="font-display text-2xl font-extrabold">Creator Studio</h1>
      </div>

      {/* Analytics Dashboard */}
      <section className="space-y-4">
        <h2 className="text-sm font-bold text-buddy-text-secondary uppercase">Performance Overview</h2>
        
        <div className="grid grid-cols-2 gap-3">
          <Card className="p-4 bg-gradient-to-br from-buddy-green/20 to-transparent border-buddy-green/30">
            <p className="text-xs text-buddy-text-secondary font-medium">Total Revenue</p>
            <p className="text-2xl font-display font-extrabold mt-1">$4,250</p>
            <p className="text-[10px] text-buddy-green mt-1 flex items-center gap-1">
              <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m3 16 4-4 4 4 8-8"/><path d="m15 8 h4 v4"/></svg>
              +12% this month
            </p>
          </Card>
          <Card className="p-4">
            <p className="text-xs text-buddy-text-secondary font-medium">Viewability</p>
            <p className="text-2xl font-display font-extrabold mt-1">18.4K</p>
            <p className="text-[10px] text-buddy-green mt-1 flex items-center gap-1">
              <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m3 16 4-4 4 4 8-8"/><path d="m15 8 h4 v4"/></svg>
              Impressions
            </p>
          </Card>
        </div>

        <Card className="p-4">
          <p className="text-xs text-buddy-text-secondary font-medium mb-3">Sales Source Breakdown</p>
          <div className="space-y-3">
            <div>
              <div className="flex justify-between text-xs mb-1">
                <span>Followers (65%)</span>
                <span className="font-bold">142 sales</span>
              </div>
              <div className="h-2 w-full bg-buddy-surface-raised rounded-full overflow-hidden">
                <div className="h-full bg-buddy-electric w-[65%]" />
              </div>
            </div>
            <div>
              <div className="flex justify-between text-xs mb-1">
                <span>Non-Followers (35%)</span>
                <span className="font-bold">78 sales</span>
              </div>
              <div className="h-2 w-full bg-buddy-surface-raised rounded-full overflow-hidden">
                <div className="h-full bg-buddy-green w-[35%]" />
              </div>
            </div>
          </div>
        </Card>

        <div className="grid grid-cols-2 gap-3">
          <Card className="p-4">
            <p className="text-xs text-buddy-text-secondary font-medium mb-2">Age Distribution</p>
            <div className="space-y-1.5">
              {[
                { label: '18-24', pct: '25%' },
                { label: '25-34', pct: '45%' },
                { label: '35-44', pct: '20%' },
                { label: '45+', pct: '10%' },
              ].map((item) => (
                <div key={item.label} className="flex items-center gap-2 text-xs">
                  <span className="w-10">{item.label}</span>
                  <div className="h-1.5 flex-1 bg-buddy-surface-raised rounded-full">
                    <div className="h-full bg-buddy-gold rounded-full" style={{ width: item.pct }} />
                  </div>
                </div>
              ))}
            </div>
          </Card>

          <Card className="p-4">
            <p className="text-xs text-buddy-text-secondary font-medium mb-2">Category Sales</p>
            <div className="space-y-1.5">
              {[
                { label: 'Programmes', pct: '50%', color: 'bg-buddy-blue' },
                { label: 'Meal Plans', pct: '30%', color: 'bg-buddy-green' },
                { label: 'Events', pct: '20%', color: 'bg-buddy-gold' },
              ].map((item) => (
                <div key={item.label} className="flex items-center gap-2 text-xs">
                  <span className="w-16 truncate">{item.label}</span>
                  <div className="h-1.5 flex-1 bg-buddy-surface-raised rounded-full">
                    <div className={`h-full rounded-full ${item.color}`} style={{ width: item.pct }} />
                  </div>
                </div>
              ))}
            </div>
          </Card>
        </div>
      </section>

      <div className="h-px w-full bg-buddy-surface" />

      {/* Drafts and Abandoned Cart Services */}
      <section>
        <h3 className="text-xs font-bold text-buddy-text-secondary uppercase mb-2">My Meal Plans</h3>
        <div className="space-y-2">
          {data.meal_plans.length === 0 && <p className="text-xs text-buddy-text-secondary">No meal plans created.</p>}
          {data.meal_plans.map((p: any) => (
            <Card key={p.id} className="p-3 flex items-center justify-between">
              <div>
                <p className="text-sm font-medium">{p.title}</p>
                <div className="flex items-center gap-2 mt-1">
                  <p className="text-xs text-buddy-text-secondary">{p.is_published ? 'Published' : 'Draft'}</p>
                  {p.abandoned_cart_count > 0 && (
                    <Badge variant="orange" label={`${p.abandoned_cart_count} in carts`} size="sm" />
                  )}
                </div>
              </div>
              <Button size="sm" variant="ghost" onClick={() => navigate(`/marketplace/meal-plans/${p.id}`)}>View</Button>
            </Card>
          ))}
        </div>
      </section>

      <section>
        <h3 className="text-xs font-bold text-buddy-text-secondary uppercase mb-2">My Programmes</h3>
        <div className="space-y-2">
          {data.programmes.length === 0 && <p className="text-xs text-buddy-text-secondary">No programmes created.</p>}
          {data.programmes.map((p: any) => (
            <Card key={p.id} className="p-3 flex items-center justify-between">
              <div>
                <p className="text-sm font-medium">{p.title}</p>
                <div className="flex items-center gap-2 mt-1">
                  <p className="text-xs text-buddy-text-secondary">{p.is_published ? 'Published' : 'Draft'}</p>
                  {p.abandoned_cart_count > 0 && (
                    <Badge variant="orange" label={`${p.abandoned_cart_count} in carts`} size="sm" />
                  )}
                </div>
              </div>
              <Button size="sm" variant="ghost" onClick={() => navigate(`/marketplace/programmes/${p.id}`)}>View</Button>
            </Card>
          ))}
        </div>
      </section>

      <section>
        <h3 className="text-xs font-bold text-buddy-text-secondary uppercase mb-2">My Events</h3>
        <div className="space-y-2">
          {data.events.length === 0 && <p className="text-xs text-buddy-text-secondary">No events created.</p>}
          {data.events.map((p: any) => (
            <Card key={p.id} className="p-3 flex items-center justify-between">
              <div>
                <p className="text-sm font-medium">{p.title}</p>
                <div className="flex items-center gap-2 mt-1">
                  <p className="text-xs text-buddy-text-secondary">{p.is_published ? 'Published' : 'Draft'}</p>
                  {p.abandoned_cart_count > 0 && (
                    <Badge variant="orange" label={`${p.abandoned_cart_count} in carts`} size="sm" />
                  )}
                </div>
              </div>
              <Button size="sm" variant="ghost" onClick={() => navigate(`/marketplace/events/${p.id}`)}>View</Button>
            </Card>
          ))}
        </div>
      </section>
    </div>
  );
}
