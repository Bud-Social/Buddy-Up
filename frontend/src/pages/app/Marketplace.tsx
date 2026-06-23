import { useState, useEffect, useCallback } from 'react';
import { ShoppingBag, Utensils, Dumbbell, Pill, Star, ExternalLink, Sparkles, ChevronRight } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { ArtifactIcon } from '@/components/ui/ArtifactIcon';
import { Modal } from '@/components/ui/Modal';
import { marketplaceApi } from '@/api/marketplace';
import type { MealPlan, TrainingProgrammeMP, ProductMP } from '@/api/marketplace';

type Tab = 'meal_plans' | 'programmes' | 'products';

export default function Marketplace() {
  const [tab, setTab] = useState<Tab>('meal_plans');

  return (
    <div className="max-w-lg mx-auto p-4">
      <h1 className="font-display text-2xl font-extrabold mb-4">Marketplace</h1>

      <div className="flex rounded-xl bg-buddy-surface p-1 mb-4">
        {[
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

      {tab === 'meal_plans' && <MealPlansTab />}
      {tab === 'programmes' && <ProgrammesTab />}
      {tab === 'products' && <ProductsTab />}
    </div>
  );
}

function MealPlansTab() {
  const [plans, setPlans] = useState<MealPlan[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [dietFilter, setDietFilter] = useState('');
  const [selectedPlan, setSelectedPlan] = useState<MealPlan | null>(null);

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
            <Card key={plan.id} className="p-4 hover:bg-buddy-surface-raised transition-colors cursor-pointer" onClick={() => setSelectedPlan(plan)}>
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

      <Modal isOpen={!!selectedPlan} onClose={() => setSelectedPlan(null)} title={selectedPlan?.title} size="lg">
        {selectedPlan && (
          <div className="space-y-4 max-h-96 overflow-y-auto">
            <p className="text-sm text-buddy-text-secondary">{selectedPlan.description}</p>
            <div className="flex gap-2 text-xs">
              <Badge variant="blue" label={`${selectedPlan.duration_weeks} weeks`} />
              <Badge variant="green" label={selectedPlan.diet_type.replace('_', ' ')} />
              {selectedPlan.calorie_range && <Badge variant="silver" label={selectedPlan.calorie_range} />}
            </div>
            <div>
              <h4 className="font-heading font-semibold text-sm mb-2">Preview (Day 1)</h4>
              <div className="bg-buddy-surface rounded-xl p-3 text-sm text-buddy-text-secondary">
                {selectedPlan.preview_day ? (
                  <div className="space-y-2">
                    {Object.entries(selectedPlan.preview_day as Record<string, string>).map(([k, v]) => (
                      <p key={k}><span className="font-medium capitalize">{k}:</span> {v}</p>
                    ))}
                  </div>
                ) : (
                  <p>Purchase to view the full meal plan.</p>
                )}
              </div>
            </div>
            <div className="flex gap-2">
              <Button className="flex-1" onClick={() => marketplaceApi.purchaseMealPlan(selectedPlan.id).then(() => setSelectedPlan(null))}>
                Purchase Plan
              </Button>
              {selectedPlan.is_purchased && (
                <Button variant="outline" className="flex-1" onClick={() => marketplaceApi.personaliseMealPlan(selectedPlan.id)}>
                  <Sparkles size={14} className="mr-1" /> AI Personalise
                </Button>
              )}
            </div>
          </div>
        )}
      </Modal>
    </>
  );
}

function ProgrammesTab() {
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
      {programmes.length === 0 ? (
        <div className="text-center py-20 text-buddy-text-secondary">No training programmes available yet.</div>
      ) : (
        programmes.map((p) => (
          <Card key={p.id} className="p-4">
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

      {isLoading ? (
        <div className="grid grid-cols-2 gap-3">
          {Array.from({ length: 4 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse"><div className="h-32 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-2 gap-3">
          {products.map((p) => (
            <Card key={p.id} className="p-3">
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
