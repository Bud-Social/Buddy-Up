import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { ShoppingBag, Utensils, Dumbbell, Pill, Star, ExternalLink, Plus, Calendar } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { ArtifactIcon } from '@/components/ui/ArtifactIcon';
import { marketplaceApi } from '@/api/marketplace';
import type { MealPlan, TrainingProgrammeMP, ProductMP } from '@/api/marketplace';

type Tab = 'events' | 'meal_plans' | 'programmes' | 'products';

export default function Marketplace() {
  const navigate = useNavigate();
  const [tab, setTab] = useState<Tab>('events');

  return (
    <div className="max-w-lg mx-auto p-4">
      <h1 className="font-display text-2xl font-extrabold mb-4">Marketplace</h1>

      <div className="flex rounded-xl bg-buddy-surface p-1 mb-4">
        {[
          { key: 'events' as const, label: 'Events', icon: Calendar },
          { key: 'meal_plans' as const, label: 'Meal Plans', icon: Utensils },
          { key: 'programmes' as const, label: 'Programmes', icon: Dumbbell },
          { key: 'products' as const, label: 'Products', icon: ShoppingBag },
        ].map(({ key, label, icon: Icon }) => (
          <button key={key} onClick={() => setTab(key)}
            className={`flex-1 py-2 text-sm font-medium rounded-lg transition-colors flex items-center justify-center gap-1.5 ${
              tab === key ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary hover:text-buddy-text-primary'
            }`}><Icon size={14} /> {label}</button>
        ))}
      </div>

      {tab === 'events' && <EventsTab />}
      {tab === 'meal_plans' && <MealPlansTab />}
      {tab === 'programmes' && <ProgrammesTab />}
      {tab === 'products' && <ProductsTab />}
    </div>
  );
}

function MealPlansTab() {
  const navigate = useNavigate();
  const [plans, setPlans] = useState<MealPlan[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [dietFilter, setDietFilter] = useState('');

  const fetchPlans = useCallback(async () => {
    setIsLoading(true);
    marketplaceApi.getMealPlans(dietFilter || undefined)
      .then((res) => setPlans(res.data || []))
      .catch(() => {})
      .finally(() => setIsLoading(false));
  }, [dietFilter]);

  useEffect(() => { fetchPlans(); }, [fetchPlans]);

  const diets = ['balanced', 'high_protein', 'weight_loss', 'muscle_gain', 'vegan', 'keto', 'gluten_free', 'other'];

  return (
    <>
      <div className="flex gap-2 overflow-x-auto pb-3 mb-2 scrollbar-hide">
        <button onClick={() => setDietFilter('')} className={`px-3 py-1.5 rounded-full text-xs whitespace-nowrap capitalize transition-colors ${!dietFilter ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'}`}>All</button>
        {diets.map((d) => (
          <button key={d} onClick={() => setDietFilter(d)} className={`px-3 py-1.5 rounded-full text-xs whitespace-nowrap capitalize transition-colors ${dietFilter === d ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'}`}>{d.replace('_', ' ')}</button>
        ))}
      </div>

      <div className="flex justify-end mb-2">
        <button onClick={() => navigate('/marketplace/meal-plans/create')} className="flex items-center gap-1 text-xs font-medium text-buddy-green hover:underline"><Plus size={14} /> Create</button>
      </div>

      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse"><div className="h-20 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : plans.length === 0 ? (
        <div className="text-center py-20 text-buddy-text-secondary">No meal plans found.</div>
      ) : (
        <div className="space-y-3">
          {plans.map((plan) => (
            <Card key={plan.id} className="p-4 hover:bg-buddy-surface-raised transition-colors cursor-pointer" onClick={() => navigate(`/marketplace/meal-plans/${plan.id}`)}>
              <div className="flex items-start justify-between mb-2">
                <div>
                  <h3 className="font-heading font-semibold text-sm">{plan.title}</h3>
                  <p className="text-xs text-buddy-text-secondary mt-0.5">by {plan.creator_data.display_name} · {plan.duration_weeks} weeks · {plan.diet_type.replace('_', ' ')}</p>
                </div>
                {plan.creator_data.verification_status === 'practitioner' && <Badge variant="gold" label="Nutritionist" size="sm" />}
              </div>
              <div className="flex items-center gap-4 text-xs text-buddy-text-secondary">
                {plan.review_count > 0 && <span className="flex items-center gap-1"><Star size={12} className="text-buddy-gold fill-buddy-gold" /> {plan.average_rating} ({plan.review_count})</span>}
                <span>{plan.purchase_count} purchased</span>
                {plan.price_artifacts && Object.entries(plan.price_artifacts).map(([k, v]) => (
                  <span key={k} className="flex items-center gap-1"><ArtifactIcon artifact={k} size={14} /> {v}</span>
                ))}
              </div>
            </Card>
          ))}
        </div>
      )}


    </>
  );
}

function ProgrammesTab() {
  const navigate = useNavigate();
  const [programmes, setProgrammes] = useState<TrainingProgrammeMP[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    marketplaceApi.getProgrammes()
      .then((res) => setProgrammes(res.data || []))
      .catch(() => {})
      .finally(() => setIsLoading(false));
  }, []);

  if (isLoading) return <div className="space-y-3">{Array.from({ length: 3 }).map((_, i) => (<Card key={i} className="p-4 animate-pulse"><div className="h-20 bg-buddy-surface-raised rounded-xl" /></Card>))}</div>;

  return (
    <div className="space-y-3">
      <div className="flex justify-end mb-2">
        <button onClick={() => navigate('/marketplace/programmes/create')} className="flex items-center gap-1 text-xs font-medium text-buddy-green hover:underline"><Plus size={14} /> Create</button>
      </div>
      {programmes.length === 0 ? (
        <div className="text-center py-20 text-buddy-text-secondary">No training programmes available yet.</div>
      ) : (
        programmes.map((p) => (
          <Card key={p.id} className="p-4 hover:bg-buddy-surface-raised transition-colors cursor-pointer" onClick={() => navigate(`/marketplace/programmes/${p.id}`)}>
            <div className="flex items-start justify-between mb-2">
              <div>
                <h3 className="font-heading font-semibold text-sm">{p.title}</h3>
                <p className="text-xs text-buddy-text-secondary mt-0.5">by {p.creator_data.display_name} · {p.duration_weeks} weeks · {p.category}</p>
              </div>
              <Badge variant="green" label={p.category} size="sm" />
            </div>
            <p className="text-sm text-buddy-text-secondary mb-2">{p.description?.slice(0, 150)}</p>
            <div className="flex items-center justify-between">
              <span className="text-xs">{p.purchase_count} enrolled</span>
              {p.price_artifacts && Object.entries(p.price_artifacts).map(([k, v]) => (
                <span key={k} className="flex items-center gap-1 text-xs"><ArtifactIcon artifact={k} size={14} /> {v}</span>
              ))}
              <Button size="sm">Enroll</Button>
            </div>
          </Card>
        ))
      )}
    </div>
  );
}

function ProductsTab() {
  const navigate = useNavigate();
  const [products, setProducts] = useState<ProductMP[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [category, setCategory] = useState('');

  useEffect(() => {
    setIsLoading(true);
    marketplaceApi.getProducts(category || undefined)
      .then((res) => setProducts(res.data || []))
      .catch(() => {})
      .finally(() => setIsLoading(false));
  }, [category]);

  const cats = ['supplement', 'equipment', 'gear'];

  return (
    <>
      <div className="flex gap-2 pb-3 mb-2">
        <button onClick={() => setCategory('')} className={`px-3 py-1.5 rounded-full text-xs capitalize transition-colors ${!category ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'}`}>All</button>
        {cats.map((c) => (
          <button key={c} onClick={() => setCategory(c)} className={`px-3 py-1.5 rounded-full text-xs capitalize transition-colors ${category === c ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'}`}>{c}</button>
        ))}
      </div>

      <div className="flex justify-end mb-2">
        <button onClick={() => navigate('/marketplace/products/create')} className="flex items-center gap-1 text-xs font-medium text-buddy-green hover:underline"><Plus size={14} /> Create</button>
      </div>

      {isLoading ? (
        <div className="grid grid-cols-2 gap-3">
          {Array.from({ length: 4 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse"><div className="h-32 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-2 gap-3">
          {products.map((p) => (
            <Card key={p.id} className="p-3 hover:bg-buddy-surface-raised transition-colors cursor-pointer" onClick={() => navigate(`/marketplace/products/${p.id}`)}>
              <div className="aspect-square bg-buddy-surface rounded-xl mb-2 flex items-center justify-center text-3xl">
                {p.image_url ? <img src={p.image_url} alt={p.name} className="w-full h-full rounded-xl object-cover" /> : <Pill size={32} className="text-buddy-text-secondary/30" />}
              </div>
              <p className="text-sm font-medium truncate">{p.name}</p>
              <p className="text-xs text-buddy-text-secondary">{p.brand}</p>
              {p.recommender_data && <p className="text-xs text-buddy-electric mt-0.5">Rec. by {p.recommender_data.display_name}</p>}
              <div className="flex items-center justify-between mt-2">
                {p.price_display && <span className="text-xs font-coin font-bold text-buddy-green">{p.price_display}</span>}
                <a href={p.affiliate_url} target="_blank" rel="noopener noreferrer" className="flex items-center gap-1 text-xs text-buddy-electric hover:underline" onClick={(e) => e.stopPropagation()}>
                  <ExternalLink size={12} /> View
                </a>
              </div>
            </Card>
          ))}
        </div>
      )}
    </>
  );
}

function EventsTab() {
  const navigate = useNavigate();
  const [events, setEvents] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    setIsLoading(true);
    marketplaceApi.getEvents(true)
      .then((res) => setEvents(res.data || []))
      .catch(() => {})
      .finally(() => setIsLoading(false));
  }, []);

  return (
    <>
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-sm font-semibold">Upcoming Events</h2>
        <div className="flex gap-2">
          <button onClick={() => navigate('/marketplace/events/my-tickets')} className="text-xs font-medium text-buddy-text-secondary hover:text-buddy-text-primary px-2">
            My Tickets
          </button>
          <button onClick={() => navigate('/marketplace/events/create')} className="flex items-center gap-1 text-xs font-medium bg-buddy-green/10 text-buddy-green px-3 py-1.5 rounded-full hover:bg-buddy-green hover:text-buddy-black transition-colors">
            <Plus size={14} /> Create
          </button>
        </div>
      </div>

      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse"><div className="h-24 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : events.length === 0 ? (
        <div className="text-center py-20 text-buddy-text-secondary">No upcoming events found.</div>
      ) : (
        <div className="space-y-3">
          {events.map((event) => (
            <Card key={event.id} className="p-0 overflow-hidden hover:ring-2 ring-buddy-green transition-all cursor-pointer" onClick={() => navigate(`/marketplace/events/${event.id}`)}>
              <div className="flex flex-col sm:flex-row h-full">
                {event.cover_image_url && (
                  <div className="w-full sm:w-1/3 h-32 sm:h-auto bg-buddy-surface-raised relative">
                    <img src={event.cover_image_url} alt={event.title} className="w-full h-full object-cover" />
                    <div className="absolute top-2 left-2 px-2 py-0.5 bg-buddy-black/80 backdrop-blur-sm rounded text-[10px] font-bold uppercase tracking-wider text-buddy-gold">
                      {event.event_type.replace('_', ' ')}
                    </div>
                  </div>
                )}
                <div className="p-4 flex-1 flex flex-col justify-between">
                  <div>
                    <h3 className="font-semibold text-lg leading-tight mb-1 truncate">{event.title}</h3>
                    <p className="text-xs text-buddy-text-secondary line-clamp-2">{event.description || 'No description provided.'}</p>
                  </div>
                  
                  <div className="mt-4 flex items-center justify-between">
                    <div className="flex items-center gap-2 text-xs text-buddy-text-secondary">
                      <Calendar size={14} className="text-buddy-green" />
                      {new Date(event.start_datetime).toLocaleDateString(undefined, { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })}
                    </div>
                    
                    <div className="text-sm font-bold text-buddy-green">
                      {event.is_free ? 'Free' : Object.entries(event.ticket_price_artifacts || {}).map(([k, v]) => `${v} ${k}s`).join(', ')}
                    </div>
                  </div>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </>
  );
}
