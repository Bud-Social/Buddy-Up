import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { ShoppingBag, Utensils, Dumbbell, Pill, Star, Plus, Calendar, Clock, Users, BarChart2, Package } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { ArtifactIcon } from '@/components/ui/ArtifactIcon';
import { useToast } from '@/components/ui/Toast';
import { marketplaceApi } from '@/api/marketplace';
import type { MealPlan, TrainingProgrammeMP, ProductMP } from '@/api/marketplace';
import { EVENT_CATEGORIES } from '@/config/eventCategories';

const ARTIFACT_USD_VALUES: Record<string, number> = {
  dumbbell: 0.10, barbell: 0.50, burpee: 1.00,
  squat: 2.50, sprint: 5.00, pr: 10.00, champion: 25.00,
};
const USD_KES_RATE = 129.5;

function artifactsToUsd(artifacts: Record<string, number> | null | undefined): number {
  if (!artifacts) return 0;
  return Object.entries(artifacts).reduce((sum, [k, v]) => sum + (ARTIFACT_USD_VALUES[k] || 0) * v, 0);
}

function CurrencyHint({ artifacts }: { artifacts: Record<string, number> | null | undefined }) {
  const usd = artifactsToUsd(artifacts);
  if (usd <= 0) return null;
  return (
    <span className="text-[10px] text-buddy-text-secondary ml-1">
      ~${usd.toFixed(2)} (~KES {(usd * USD_KES_RATE).toFixed(2)})
    </span>
  );
}

type Tab = 'events' | 'meal_plans' | 'programmes' | 'products';

export default function Marketplace() {
  const navigate = useNavigate();
  const [tab, setTab] = useState<Tab>('events');
  const [cartCount, setCartCount] = useState(0);
  const [hasShop, setHasShop] = useState(false);

  const fetchCartCount = useCallback(() => {
    marketplaceApi.getCart().then(res => {
      setCartCount(res.data.items?.length || 0);
    }).catch(() => {});
  }, []);

  const fetchMyShops = useCallback(() => {
    marketplaceApi.getMyShops().then(res => {
      setHasShop((res.data || []).length > 0);
    }).catch(() => {});
  }, []);

  useEffect(() => {
    fetchCartCount();
    fetchMyShops();
    const handler = () => fetchCartCount();
    window.addEventListener('cart-updated', handler);
    return () => window.removeEventListener('cart-updated', handler);
  }, [fetchCartCount, fetchMyShops]);

  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto pb-20">
      {/* Sticky Header */}
      <div className="sticky top-12 lg:top-0 z-20 bg-buddy-background/80 backdrop-blur-md p-4 pb-2 border-b border-buddy-surface">
        <div className="flex items-center justify-between mb-4">
          <h1 className="font-display text-2xl font-extrabold">Marketplace</h1>
          <div className="flex items-center gap-2">
            <Button variant="secondary" size="sm" onClick={() => navigate('/marketplace/creator')} className="flex flex-col sm:flex-row items-center gap-0.5 sm:gap-1">
              <BarChart2 size={14} />
              <span className="text-[10px] sm:text-xs leading-none">{hasShop ? 'Creator' : 'Become a Creator'}</span>
            </Button>
            <Button variant="secondary" size="sm" onClick={() => navigate('/marketplace/orders')} className="flex items-center gap-1">
              <Package size={14} />
              <span className="hidden sm:inline">Orders</span>
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
              className={`flex-1 py-1.5 text-xs font-medium rounded-lg transition-colors flex flex-col items-center justify-center gap-0.5 sm:flex-row sm:gap-1 ${
                tab === key ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary hover:text-buddy-text-primary'
              }`}>
              <Icon size={14} className="flex-shrink-0" />
              <span className="truncate max-w-full">{label}</span>
            </button>
          ))}
        </div>
      </div>

      <div className="p-4 pt-4">
        {tab === 'events' && <EventsTab hasShop={hasShop} />}
        {tab === 'meal_plans' && <MealPlansTab hasShop={hasShop} />}
        {tab === 'programmes' && <ProgrammesTab hasShop={hasShop} />}
        {tab === 'products' && <ProductsTab hasShop={hasShop} />}
      </div>
    </div>
  );
}

const CART_ID_KEYS: Record<'meal_plan' | 'programme' | 'event_ticket' | 'product', string> = {
  meal_plan: 'meal_plan_id',
  programme: 'programme_id',
  product: 'product_id',
  event_ticket: 'event_id',
};

function AddToCartButton({ type, id }: { type: 'meal_plan' | 'programme' | 'event_ticket' | 'product', id: string }) {
  const { toast } = useToast();
  const [loading, setLoading] = useState(false);

  const handleAdd = async (e: React.MouseEvent) => {
    e.stopPropagation();
    setLoading(true);
    try {
      await marketplaceApi.addToCart(type, { [CART_ID_KEYS[type]]: id }, 1);
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

function MealPlansTab({ hasShop }: { hasShop: boolean }) {
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

      {hasShop && (
        <div className="flex justify-end mb-2">
          <button onClick={() => navigate('/marketplace/meal-plans/create')} className="flex items-center gap-1 text-xs font-medium text-buddy-green hover:underline"><Plus size={14} /> Create</button>
        </div>
      )}

      {isLoading ? (
        <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3">
          {Array.from({ length: 4 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse"><div className="h-32 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : plans.length === 0 ? (
        <div className="text-center py-20 text-buddy-text-secondary">No meal plans found.</div>
      ) : (
        <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3">
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
                  <div className="flex flex-wrap items-center gap-x-2 gap-y-1">
                    {plan.price_artifacts && Object.entries(plan.price_artifacts).map(([k, v]) => (
                      <span key={k} className="flex items-center gap-1 text-xs font-bold text-buddy-green"><ArtifactIcon artifact={k} size={12} /> {v as any}</span>
                    ))}
                    <CurrencyHint artifacts={plan.price_artifacts} />
                  </div>
                  {plan.review_count > 0 && <span className="flex items-center gap-1 text-[10px] font-medium text-buddy-gold flex-shrink-0"><Star size={10} className="fill-buddy-gold" /> {plan.average_rating}</span>}
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

function ProgrammesTab({ hasShop }: { hasShop: boolean }) {
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
      {hasShop && (
        <div className="flex justify-end mb-2">
          <button onClick={() => navigate('/marketplace/programmes/create')} className="flex items-center gap-1 text-xs font-medium text-buddy-green hover:underline"><Plus size={14} /> Create</button>
        </div>
      )}
      {programmes.length === 0 ? (
        <div className="text-center py-20 text-buddy-text-secondary">No training programmes available yet.</div>
      ) : (
        <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3">
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
                  <div className="flex flex-wrap items-center gap-x-2 gap-y-1">
                    {p.price_artifacts && Object.entries(p.price_artifacts).map(([k, v]) => (
                      <span key={k} className="flex items-center gap-1 text-xs font-bold text-buddy-green"><ArtifactIcon artifact={k} size={12} /> {v as any}</span>
                    ))}
                    <CurrencyHint artifacts={p.price_artifacts} />
                  </div>
                  <span className="text-[10px] font-medium text-buddy-text-secondary flex items-center gap-1 flex-shrink-0"><Users size={10} /> {p.purchase_count}</span>
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

function ProductsTab({ hasShop }: { hasShop: boolean }) {
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

      {hasShop && (
        <div className="flex justify-end mb-2">
          <button onClick={() => navigate('/marketplace/products/create')} className="flex items-center gap-1 text-xs font-medium text-buddy-green hover:underline"><Plus size={14} /> Recommend</button>
        </div>
      )}

      {isLoading ? (
        <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3">
          {Array.from({ length: 4 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse"><div className="h-32 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3">
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
                  <div>
                    {p.price_display && <span className="text-xs font-coin font-bold text-buddy-green">{p.price_display}</span>}
                  </div>
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

function EventsTab({ hasShop }: { hasShop: boolean }) {
  const navigate = useNavigate();
  const [events, setEvents] = useState<any[]>([]);
  const [scope, setScope] = useState<'upcoming' | 'past' | 'all'>('upcoming');
  const [categoryFilter, setCategoryFilter] = useState('all');
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    setIsLoading(true);
    marketplaceApi.getEvents(scope)
      .then((res) => setEvents(res.data || []))
      .catch(() => {})
      .finally(() => setIsLoading(false));
  }, [scope]);

  const SCOPE_OPTIONS: { key: 'upcoming' | 'past' | 'all'; label: string }[] = [
    { key: 'upcoming', label: 'Upcoming' },
    { key: 'past', label: 'Past' },
    { key: 'all', label: 'All' },
  ];
  const filteredEvents = events.filter((e) => {
    if (categoryFilter === 'all') return true;
    return (e.category || '').toLowerCase() === categoryFilter.toLowerCase();
  });

  return (
    <>
      <div className="flex items-center mb-3">
        <div className="flex items-center gap-2">
          <div className="flex items-center gap-1 bg-buddy-surface-raised rounded-lg p-0.5">
            {SCOPE_OPTIONS.map((opt) => (
              <button
                key={opt.key}
                onClick={() => setScope(opt.key)}
                className={`px-2.5 py-1 rounded-md text-[11px] font-semibold transition-colors ${
                  scope === opt.key
                    ? 'bg-buddy-electric text-white shadow-sm'
                    : 'text-buddy-text-secondary hover:text-white'
                }`}
              >
                {opt.label}
              </button>
            ))}
          </div>
        </div>
        <div className="flex gap-2">
          <button onClick={() => navigate('/marketplace/events/my-tickets')} className="text-xs font-medium text-buddy-electric hover:underline">My Tickets</button>
          <button onClick={() => navigate(hasShop ? '/marketplace/events/create' : '/marketplace/creator')} className="text-xs font-medium text-buddy-green hover:underline">{hasShop ? 'Host' : 'Become Host'}</button>
        </div>
      </div>

      {/* Category Filter Pill Bar */}
      <div className="flex gap-2 overflow-x-auto pb-3 mb-3 scrollbar-hide snap-x snap-mandatory">
        <button
          onClick={() => setCategoryFilter('all')}
          className={`flex-shrink-0 px-3 py-1 rounded-full text-xs whitespace-nowrap transition-colors snap-start font-medium ${
            categoryFilter === 'all'
              ? 'bg-buddy-green text-buddy-black'
              : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'
          }`}
        >
          All Categories
        </button>
        {EVENT_CATEGORIES.map((cat) => (
          <button
            key={cat.key}
            onClick={() => setCategoryFilter(categoryFilter === cat.key ? 'all' : cat.key)}
            className={`flex-shrink-0 flex items-center gap-1.5 px-3 py-1 rounded-full text-xs whitespace-nowrap transition-colors snap-start font-medium ${
              categoryFilter === cat.key
                ? 'bg-buddy-green text-buddy-black'
                : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'
            }`}
          >
            {cat.Icon ? <cat.Icon size={13} /> : <span>{cat.icon}</span>}
            <span>{cat.label}</span>
          </button>
        ))}
      </div>

      {isLoading ? (
        <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3">
          {Array.from({ length: 4 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse"><div className="h-32 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : filteredEvents.length === 0 ? (
        <div className="text-center py-20 text-buddy-text-secondary">
          No events found in this category.
        </div>
      ) : (
        <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3">
          {filteredEvents.map((e) => (
            <Card key={e.id} className="p-3 hover:bg-buddy-surface-raised transition-colors cursor-pointer flex flex-col" onClick={() => navigate(`/marketplace/events/${e.id}`)}>
              <div className="aspect-square bg-buddy-surface rounded-xl mb-2 flex items-center justify-center relative overflow-hidden">
                {e.cover_image_url ? (
                  <img src={e.cover_image_url} alt={e.title} className="w-full h-full object-cover" />
                ) : (
                  <Calendar size={32} className="text-buddy-text-secondary/30" />
                )}
                <Badge
                  variant={e.ticket_price_artifacts && Object.keys(e.ticket_price_artifacts).length > 0 ? 'gold' : 'green'}
                  label={e.ticket_price_artifacts && Object.keys(e.ticket_price_artifacts).length > 0 ? 'Paid' : 'Free'}
                  size="sm"
                  className="absolute top-2 left-2 shadow-sm"
                />
                <div className="absolute top-2 right-2 px-2 py-0.5 bg-buddy-black/70 backdrop-blur-sm rounded text-[10px] font-bold text-white capitalize">
                  {e.event_type === 'online' ? 'Online' : e.event_type.replace('_', ' ')}
                </div>
                {new Date(e.start_datetime).getTime() < Date.now() && (
                  <div className="absolute bottom-2 right-2 px-2 py-0.5 bg-buddy-red/90 backdrop-blur-sm rounded text-[10px] font-bold text-white">
                    Ended
                  </div>
                )}
              </div>
              <div className="flex-1">
                <p className="text-sm font-medium truncate">{e.title}</p>
                <p className="text-xs text-buddy-text-secondary mt-0.5 truncate">by {e.creator_data.display_name}</p>
                <p className="text-[10px] text-buddy-text-secondary mt-0.5 flex items-center gap-1">
                  <Calendar size={10} className="text-buddy-green" /> {new Date(e.start_datetime).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}
                </p>
                <p className="text-[10px] text-buddy-text-secondary flex items-center gap-1">
                  <Clock size={10} className="text-buddy-electric" /> {new Date(e.start_datetime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                </p>
                <div className="flex flex-wrap items-center gap-x-2 gap-y-1 mt-1">
                  {e.ticket_price_artifacts && Object.keys(e.ticket_price_artifacts).length > 0
                    ? Object.entries(e.ticket_price_artifacts).map(([k, v]) => (
                        <span key={k} className="flex items-center gap-1 text-xs font-bold text-buddy-green"><ArtifactIcon artifact={k} size={12} /> {v as any}</span>
                      ))
                    : <span className="text-xs font-bold text-buddy-green">Free</span>}
                  {e.ticket_price_artifacts && <CurrencyHint artifacts={e.ticket_price_artifacts} />}
                </div>
                <div className="flex items-center justify-between mt-1 pt-2 border-t border-buddy-surface-raised">
                  <span className="flex items-center gap-1 text-[10px] font-medium text-buddy-text-secondary">
                    <Users size={10} /> {e.attendee_count}
                  </span>
                  {e.capacity > 0 && (
                    <span className="text-[10px] text-buddy-text-secondary">{e.capacity - e.attendee_count} left</span>
                  )}
                </div>
              </div>
              <AddToCartButton type="event_ticket" id={e.id} />
            </Card>
          ))}
        </div>
      )}
    </>
  );
}
