import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { ShoppingBag, Utensils, Dumbbell, Pill, Star, Plus, Calendar, Clock, Users, User, BarChart2 } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { ArtifactIcon } from '@/components/ui/ArtifactIcon';
import { useToast } from '@/components/ui/Toast';
import { marketplaceApi } from '@/api/marketplace';
import type { MealPlan, TrainingProgrammeMP, ProductMP } from '@/api/marketplace';

type Tab = 'events' | 'meal_plans' | 'programmes' | 'products';

export default function Marketplace() {
  const navigate = useNavigate();
  const [tab, setTab] = useState<Tab>('events');
  const [cartCount, setCartCount] = useState(0);

  const fetchCartCount = useCallback(() => {
    marketplaceApi.getCart().then(res => {
      setCartCount(res.data.items?.length || 0);
    }).catch(() => {});
  }, []);

  useEffect(() => {
    fetchCartCount();
    const handler = () => fetchCartCount();
    window.addEventListener('cart-updated', handler);
    return () => window.removeEventListener('cart-updated', handler);
  }, [fetchCartCount]);

  return (
    <div className="max-w-lg mx-auto pb-20">
      {/* Sticky Header */}
      <div className="sticky top-0 z-20 bg-buddy-background/80 backdrop-blur-md p-4 pb-2 border-b border-buddy-surface">
        <div className="flex items-center justify-between mb-4">
          <h1 className="font-display text-2xl font-extrabold">Marketplace</h1>
          <div className="flex items-center gap-2">
            <Button variant="secondary" size="sm" onClick={() => navigate('/marketplace/creator')} className="flex items-center gap-1">
              <BarChart2 size={14} />
              <span className="hidden sm:inline">Creator</span>
            </Button>
            <Button variant="secondary" size="sm" onClick={() => navigate('/marketplace/cart')} className="relative flex items-center gap-1">
              <ShoppingBag size={14} />
              <span className="hidden sm:inline">Cart</span>
              {cartCount > 0 && (
                <span className="absolute -top-1 -right-1 bg-buddy-green text-buddy-black text-[10px] font-bold w-4 h-4 flex items-center justify-center rounded-full">
                  {cartCount}
                </span>
              )}
            </Button>
          </div>
        </div>

        <div className="flex rounded-xl bg-buddy-surface p-1">
          {[
            { key: 'events' as const, label: 'Events', icon: Calendar },
            { key: 'meal_plans' as const, label: 'Meal Plans', icon: Utensils },
            { key: 'programmes' as const, label: 'Programmes', icon: Dumbbell },
            { key: 'products' as const, label: 'Products', icon: ShoppingBag },
          ].map(({ key, label, icon: Icon }) => (
            <button key={key} onClick={() => setTab(key)}
              className={`flex-1 py-2 text-xs font-medium rounded-lg transition-colors flex items-center justify-center gap-1 ${
                tab === key ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary hover:text-buddy-text-primary'
              }`}>
              <Icon size={14} className="flex-shrink-0" />
              <span className="hidden sm:inline truncate">{label}</span>
            </button>
          ))}
        </div>
      </div>

      <div className="p-4 pt-4">
        {tab === 'events' && <EventsTab />}
        {tab === 'meal_plans' && <MealPlansTab />}
        {tab === 'programmes' && <ProgrammesTab />}
        {tab === 'products' && <ProductsTab />}
      </div>
    </div>
  );
}

function AddToCartButton({ type, id }: { type: 'meal_plan' | 'programme' | 'event_ticket' | 'product', id: string }) {
  const { toast } = useToast();
  const [loading, setLoading] = useState(false);

  const handleAdd = async (e: React.MouseEvent) => {
    e.stopPropagation();
    setLoading(true);
    try {
      await marketplaceApi.addToCart(type, { [`${type}_id`]: id }, 1);
      toast('success', 'Added to cart!');
      window.dispatchEvent(new CustomEvent('cart-updated'));
    } catch {
      toast('error', 'Failed to add to cart');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Button size="sm" variant="primary" className="w-full text-xs py-1 h-7 mt-2" onClick={handleAdd} disabled={loading}>
      {loading ? 'Adding...' : 'Add to Cart'}
    </Button>
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
      <div className="flex gap-2 overflow-x-auto pb-3 mb-2 scrollbar-hide snap-x snap-mandatory">
        <button onClick={() => setDietFilter('')} className={`flex-shrink-0 px-3 py-1.5 rounded-full text-xs whitespace-nowrap capitalize transition-colors snap-start ${!dietFilter ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'}`}>All</button>
        {diets.map((d) => (
          <button key={d} onClick={() => setDietFilter(d)} className={`flex-shrink-0 px-3 py-1.5 rounded-full text-xs whitespace-nowrap capitalize transition-colors snap-start ${dietFilter === d ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'}`}>{d.replace('_', ' ')}</button>
        ))}
      </div>

      <div className="flex justify-end mb-2">
        <button onClick={() => navigate('/marketplace/meal-plans/create')} className="flex items-center gap-1 text-xs font-medium text-buddy-green hover:underline"><Plus size={14} /> Create</button>
      </div>

      {isLoading ? (
        <div className="grid grid-cols-2 gap-3">
          {Array.from({ length: 4 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse"><div className="h-32 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : plans.length === 0 ? (
        <div className="text-center py-20 text-buddy-text-secondary">No meal plans found.</div>
      ) : (
        <div className="grid grid-cols-2 gap-3">
          {plans.map((plan) => (
            <Card key={plan.id} className="p-3 hover:bg-buddy-surface-raised transition-colors cursor-pointer flex flex-col" onClick={() => navigate(`/marketplace/meal-plans/${plan.id}`)}>
              <div className="aspect-square bg-buddy-surface rounded-xl mb-2 flex items-center justify-center relative overflow-hidden">
                {plan.cover_image_url ? (
                  <img src={plan.cover_image_url} alt={plan.title} className="w-full h-full object-cover" />
                ) : (
                  <Utensils size={32} className="text-buddy-text-secondary/30" />
                )}
                <Badge variant="blue" label={plan.diet_type.replace('_', ' ')} size="sm" className="absolute top-2 left-2 shadow-sm capitalize" />
                {plan.creator_data.verification_status === 'practitioner' && (
                  <Badge variant="gold" label="Nutritionist" size="sm" className="absolute top-2 right-2 shadow-sm" />
                )}
              </div>
              <div className="flex-1">
                <p className="text-sm font-medium truncate">{plan.title}</p>
                <p className="text-xs text-buddy-text-secondary mt-0.5 truncate">by {plan.creator_data.display_name}</p>
                <p className="text-[10px] text-buddy-text-secondary mt-0.5 flex items-center gap-1">
                  <Clock size={10} className="text-buddy-green" /> {plan.duration_weeks} weeks
                </p>
                <div className="flex items-center justify-between mt-2 pt-2 border-t border-buddy-surface-raised">
                  <div className="flex gap-2">
                    {plan.price_artifacts && Object.entries(plan.price_artifacts).map(([k, v]) => (
                      <span key={k} className="flex items-center gap-1 text-xs font-bold text-buddy-green"><ArtifactIcon artifact={k} size={12} /> {v as any}</span>
                    ))}
                  </div>
                  {plan.review_count > 0 && <span className="flex items-center gap-1 text-[10px] font-medium text-buddy-gold"><Star size={10} className="fill-buddy-gold" /> {plan.average_rating}</span>}
                </div>
              </div>
              <AddToCartButton type="meal_plan" id={plan.id} />
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
        <div className="grid grid-cols-2 gap-3">
          {programmes.map((p) => (
            <Card key={p.id} className="p-3 hover:bg-buddy-surface-raised transition-colors cursor-pointer flex flex-col" onClick={() => navigate(`/marketplace/programmes/${p.id}`)}>
              <div className="aspect-square bg-buddy-surface rounded-xl mb-2 flex items-center justify-center relative overflow-hidden">
                {p.cover_image_url ? (
                  <img src={p.cover_image_url} alt={p.title} className="w-full h-full object-cover" />
                ) : (
                  <Dumbbell size={32} className="text-buddy-text-secondary/30" />
                )}
                <Badge variant="green" label={p.category} size="sm" className="absolute top-2 left-2 shadow-sm capitalize" />
              </div>
              <div className="flex-1">
                <p className="text-sm font-medium truncate">{p.title}</p>
                <p className="text-xs text-buddy-text-secondary mt-0.5 truncate">by {p.creator_data.display_name}</p>
                <p className="text-[10px] text-buddy-text-secondary mt-0.5 flex items-center gap-1">
                  <Clock size={10} className="text-buddy-green" /> {p.duration_weeks} weeks
                </p>
                <div className="flex items-center justify-between mt-2 pt-2 border-t border-buddy-surface-raised">
                  <div className="flex gap-2">
                    {p.price_artifacts && Object.entries(p.price_artifacts).map(([k, v]) => (
                      <span key={k} className="flex items-center gap-1 text-xs font-bold text-buddy-green"><ArtifactIcon artifact={k} size={12} /> {v as any}</span>
                    ))}
                  </div>
                  <span className="text-[10px] font-medium text-buddy-text-secondary flex items-center gap-1"><Users size={10} /> {p.purchase_count}</span>
                </div>
              </div>
              <AddToCartButton type="programme" id={p.id} />
            </Card>
          ))}
        </div>
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
      <div className="flex gap-2 overflow-x-auto pb-3 mb-2 scrollbar-hide snap-x snap-mandatory">
        <button onClick={() => setCategory('')} className={`flex-shrink-0 px-3 py-1.5 rounded-full text-xs capitalize transition-colors snap-start ${!category ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'}`}>All</button>
        {cats.map((c) => (
          <button key={c} onClick={() => setCategory(c)} className={`flex-shrink-0 px-3 py-1.5 rounded-full text-xs capitalize transition-colors snap-start ${category === c ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'}`}>{c}</button>
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
            <Card key={p.id} className="p-3 hover:bg-buddy-surface-raised transition-colors cursor-pointer flex flex-col" onClick={() => navigate(`/marketplace/products/${p.id}`)}>
              <div className="aspect-square bg-buddy-surface rounded-xl mb-2 flex items-center justify-center text-3xl">
                {p.image_url ? <img src={p.image_url} alt={p.name} className="w-full h-full rounded-xl object-cover" /> : <Pill size={32} className="text-buddy-text-secondary/30" />}
              </div>
              <div className="flex-1">
                <p className="text-sm font-medium truncate">{p.name}</p>
                <p className="text-xs text-buddy-text-secondary">{p.brand}</p>
                {p.recommender_data && <p className="text-xs text-buddy-electric mt-0.5">Rec. by {p.recommender_data.display_name}</p>}
                <div className="flex items-center justify-between mt-2">
                  {p.price_display && <span className="text-xs font-coin font-bold text-buddy-green">{p.price_display}</span>}
                </div>
              </div>
              <AddToCartButton type="product" id={p.id} />
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
        <h2 className="text-sm font-bold text-buddy-text-secondary uppercase">Upcoming Events</h2>
        <div className="flex gap-2">
          <button onClick={() => navigate('/marketplace/events/my-tickets')} className="text-xs font-medium text-buddy-electric hover:underline">My Tickets</button>
          <button onClick={() => navigate('/marketplace/events/create')} className="text-xs font-medium text-buddy-green hover:underline">Host</button>
        </div>
      </div>

      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse"><div className="h-16 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : events.length === 0 ? (
        <div className="text-center py-20 text-buddy-text-secondary">No upcoming events.</div>
      ) : (
        <div className="space-y-3">
          {events.map((e) => (
            <Card key={e.id} className="p-4 hover:bg-buddy-surface-raised transition-colors cursor-pointer" onClick={() => navigate(`/marketplace/events/${e.id}`)}>
              <div className="flex gap-4">
                <div className="w-14 h-14 bg-buddy-surface rounded-xl flex flex-col items-center justify-center flex-shrink-0">
                  <span className="text-xs font-bold text-buddy-green uppercase">{new Date(e.start_time).toLocaleString('en-US', { month: 'short' })}</span>
                  <span className="text-lg font-display font-extrabold">{new Date(e.start_time).getDate()}</span>
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between gap-2">
                    <p className="text-sm font-medium truncate">{e.title}</p>
                    <Badge variant={e.ticket_price_artifacts && Object.keys(e.ticket_price_artifacts).length > 0 ? 'gold' : 'green'} label={e.ticket_price_artifacts && Object.keys(e.ticket_price_artifacts).length > 0 ? 'Paid' : 'Free'} size="sm" />
                  </div>
                  <p className="text-xs text-buddy-text-secondary mt-1 flex items-center gap-1">
                    <Clock size={12} /> {new Date(e.start_time).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                  </p>
                  <p className="text-xs text-buddy-text-secondary flex items-center gap-1 mt-0.5">
                    {e.event_type === 'virtual' ? <Calendar size={12} /> : <Users size={12} />} 
                    <span className="capitalize">{e.event_type}</span> • {e.attendee_count} attending
                  </p>
                </div>
              </div>
              <div className="mt-3">
                <AddToCartButton type="event_ticket" id={e.id} />
              </div>
            </Card>
          ))}
        </div>
      )}
    </>
  );
}
