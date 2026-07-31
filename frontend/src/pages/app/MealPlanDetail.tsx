import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, Star, Sparkles, ShoppingCart, MessageCircle, Clock, CheckCircle2, Lock, Flame } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { ArtifactIcon } from '@/components/ui/ArtifactIcon';
import { marketplaceApi } from '@/api/marketplace';
import type { MealPlan, MealPlanReview } from '@/api/marketplace';

export default function MealPlanDetail() {
  const { planId } = useParams<{ planId: string }>();
  const navigate = useNavigate();
  const [plan, setPlan] = useState<MealPlan | null>(null);
  const [reviews, setReviews] = useState<MealPlanReview[]>([]);
  const [loading, setLoading] = useState(true);
  const [purchasing, setPurchasing] = useState(false);
  const [reviewRating, setReviewRating] = useState(5);
  const [reviewBody, setReviewBody] = useState('');
  const [reviewing, setReviewing] = useState(false);

  useEffect(() => {
    if (!planId) return;
    setLoading(true);
    Promise.all([
      marketplaceApi.getMealPlan(planId),
      marketplaceApi.getMealPlanReviews(planId).catch(() => ({ data: [] } as unknown as { data: MealPlanReview[] })),
    ]).then(([p, r]) => {
      setPlan(p.data);
      setReviews(r.data || []);
    }).catch(() => navigate('/marketplace'))
    .finally(() => setLoading(false));
  }, [planId, navigate]);

  const handlePurchase = async () => {
    if (!planId) return;
    setPurchasing(true);
    try {
      const res = await marketplaceApi.purchaseMealPlan(planId);
      setPlan(res.data);
    } catch {
      /* ignore */
    } finally {
      setPurchasing(false);
    }
  };

  const handlePersonalise = async () => {
    if (!planId) return;
    try { await marketplaceApi.personaliseMealPlan(planId); } catch { /* ignore */ }
  };

  const handleReview = async () => {
    if (!planId) return;
    setReviewing(true);
    try {
      await marketplaceApi.reviewMealPlan(planId, reviewRating, reviewBody);
      const r = await marketplaceApi.getMealPlanReviews(planId);
      setReviews(r.data || []);
      setReviewBody('');
    } catch { /* ignore */ }
    finally { setReviewing(false); }
  };

  if (loading) {
    return (
      <div className="max-w-lg mx-auto p-4">
        <div className="flex items-center gap-3 mb-6"><button className="p-2"><ArrowLeft size={20} /></button><div className="h-7 w-40 bg-buddy-surface rounded animate-pulse" /></div>
        <Card className="p-4 animate-pulse space-y-3"><div className="h-6 w-3/4 bg-buddy-surface-raised rounded" /><div className="h-4 w-full bg-buddy-surface-raised rounded" /><div className="h-20 w-full bg-buddy-surface-raised rounded" /></Card>
      </div>
    );
  }

  if (!plan) return null;

  return (
    <div className="max-w-xl mx-auto p-4 pb-24">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => navigate('/marketplace')} className="p-2 rounded-xl bg-buddy-surface hover:bg-buddy-surface-raised transition-colors"><ArrowLeft size={20} /></button>
        <h1 className="font-display text-2xl font-extrabold truncate tracking-tight">{plan.title}</h1>
      </div>

      <Card className="p-0 overflow-hidden mb-6 border-none shadow-xl bg-buddy-surface/50 backdrop-blur-md">
        {plan.cover_image_url && (
          <div className="w-full h-48 sm:h-64 relative bg-buddy-black">
            <img src={plan.cover_image_url} alt={plan.title} className="w-full h-full object-cover" />
            <div className="absolute inset-0 bg-gradient-to-t from-buddy-black/90 via-buddy-black/20 to-transparent" />
            <div className="absolute bottom-4 left-4">
              <Badge variant="green" label={plan.diet_type.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')} size="sm" className="mb-2" />
              <h2 className="text-xl font-bold text-white">{plan.title}</h2>
              <p className="text-sm text-buddy-text-secondary mt-1 flex items-center gap-2">
                <Clock size={14} className="text-buddy-electric" /> {plan.duration_weeks} Weeks • {plan.meals_per_day} meals/day
              </p>
            </div>
            {plan.is_purchased && (
              <div className="absolute top-4 right-4 bg-buddy-green text-buddy-black px-3 py-1 rounded-full text-xs font-bold flex items-center gap-1 shadow-lg">
                <CheckCircle2 size={14} /> Purchased
              </div>
            )}
          </div>
        )}

        <div className="p-5 space-y-6">
          <div className="flex items-start justify-between">
            <div>
              <p className="text-sm text-buddy-text-secondary">Created by <span className="font-bold text-buddy-text-primary">{plan.creator_data.display_name}</span></p>
              {plan.shop_data && (
                <p className="text-xs text-buddy-text-secondary mt-0.5">Host: <span className="text-buddy-green font-medium cursor-pointer" onClick={() => navigate(`/shops/${plan.shop_data?.handle}`)}>{plan.shop_data.name}</span></p>
              )}
            </div>
            <div className="text-right">
              <div className="flex items-center gap-1 text-xs font-semibold">
                <Star size={14} className="text-buddy-gold fill-buddy-gold" /> {plan.average_rating} ({plan.review_count})
              </div>
              <p className="text-xs text-buddy-text-secondary mt-0.5">{plan.purchase_count} enrolled</p>
            </div>
          </div>

          <div>
            <h3 className="font-bold text-lg mb-2">About this Plan</h3>
            <p className="text-sm text-buddy-text-secondary leading-relaxed">{plan.description}</p>
          </div>

          {(plan.calorie_range || plan.macro_targets) && (
            <div className="bg-buddy-black rounded-xl p-4 border border-buddy-surface-raised grid grid-cols-2 gap-4">
              {plan.calorie_range && (
                <div>
                  <p className="text-xs text-buddy-text-secondary flex items-center gap-1"><Flame size={12} className="text-buddy-orange" /> Calories / Day</p>
                  <p className="text-sm font-bold mt-1">{plan.calorie_range}</p>
                </div>
              )}
              {plan.macro_targets && (
                <div>
                  <p className="text-xs text-buddy-text-secondary">Macro Targets</p>
                  <p className="text-sm font-bold mt-1 text-buddy-gold">
                    {plan.macro_targets.protein_pct}% P • {plan.macro_targets.carbs_pct}% C • {plan.macro_targets.fat_pct}% F
                  </p>
                </div>
              )}
            </div>
          )}

          {!plan.is_purchased && (
            <div className="bg-buddy-electric/10 border border-buddy-electric/20 rounded-xl p-4">
              <h4 className="font-bold text-sm text-buddy-electric flex items-center gap-2 mb-2"><Lock size={16} /> Premium Content Locked</h4>
              <p className="text-xs text-buddy-text-secondary mb-3">Purchase to unlock the full {plan.duration_weeks}-week daily schedule, complete shopping list, and daily reminder notifications to keep you on track.</p>
              <h4 className="font-heading font-semibold text-xs mb-2 text-buddy-text-primary">Preview (Day 1)</h4>
              <div className="text-xs text-buddy-text-secondary bg-buddy-black rounded-lg p-3">
                {plan.preview_day && Object.keys(plan.preview_day).length > 0 ? (
                  <div className="space-y-1.5">
                    {Object.entries(plan.preview_day as Record<string, string>).filter(([k]) => k !== 'cover_image_url').map(([k, v]) => (
                      <p key={k}><span className="font-medium capitalize text-buddy-text-primary">{k}:</span> {v}</p>
                    ))}
                  </div>
                ) : (
                  <p className="italic">Preview data not provided by creator.</p>
                )}
              </div>
            </div>
          )}

          {plan.is_purchased && plan.full_plan && (
            <div className="space-y-3">
              <h4 className="font-bold text-lg">Full Schedule</h4>
              <div className="space-y-3 max-h-[400px] overflow-y-auto pr-2 custom-scrollbar">
                {Object.entries(plan.full_plan as Record<string, unknown>).map(([week, days]) => (
                  <div key={week} className="bg-buddy-black border border-buddy-surface-raised rounded-xl overflow-hidden">
                    <div className="bg-buddy-surface px-4 py-2 font-bold text-sm border-b border-buddy-surface-raised capitalize text-buddy-electric">
                      {week.replace(/_/g, ' ')}
                    </div>
                    <div className="p-4 space-y-4">
                      {typeof days === 'object' && days && Object.entries(days as Record<string, unknown>).map(([day, meals]) => (
                        <div key={day}>
                          <p className="font-bold text-sm text-buddy-text-primary mb-2 capitalize">{day.replace(/_/g, ' ')}</p>
                          <div className="pl-3 border-l-2 border-buddy-surface-raised space-y-2">
                            {typeof meals === 'object' && meals && Object.entries(meals as Record<string, string>).map(([meal, food]) => (
                              <p key={meal} className="text-xs"><span className="font-medium text-buddy-green capitalize">{meal}:</span> <span className="text-buddy-text-secondary">{food}</span></p>
                            ))}
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {plan.is_purchased && plan.shopping_list && plan.shopping_list.length > 0 && (
            <div>
              <h4 className="font-bold text-lg mb-3">Shopping List</h4>
              <div className="bg-buddy-black rounded-xl p-4 text-sm text-buddy-text-secondary border border-buddy-surface-raised">
                <ul className="list-disc list-inside space-y-2">
                  {plan.shopping_list.map((item, i) => <li key={i}>{item}</li>)}
                </ul>
              </div>
            </div>
          )}

        </div>
      </Card>

      <div className="mt-6">
        <h2 className="font-bold text-xl mb-4 flex items-center gap-2">
          <MessageCircle className="text-buddy-electric" size={20} /> Community Reviews ({reviews.length})
        </h2>

        {plan.is_purchased && (
          <Card className="p-4 mb-4 space-y-3 border-none bg-buddy-surface/50 backdrop-blur-md">
            <p className="text-sm font-semibold">Write a Review</p>
            <div className="flex gap-1.5">
              {[1, 2, 3, 4, 5].map((s) => (
                <button key={s} onClick={() => setReviewRating(s)} className="transition-transform hover:scale-110">
                  <Star size={24} className={s <= reviewRating ? 'text-buddy-gold fill-buddy-gold drop-shadow-[0_0_8px_rgba(255,215,0,0.5)]' : 'text-buddy-surface-raised'} />
                </button>
              ))}
            </div>
            <textarea className="w-full rounded-xl bg-buddy-black border border-buddy-surface-raised px-4 py-3 text-sm focus:outline-none focus:border-buddy-electric transition-colors resize-none" rows={3} value={reviewBody} onChange={(e) => setReviewBody(e.target.value)} placeholder="How did this meal plan work out for you?" />
            <Button size="sm" onClick={handleReview} disabled={reviewing} className="bg-buddy-electric text-buddy-black hover:bg-buddy-electric/90">{reviewing ? 'Submitting...' : 'Submit Review'}</Button>
          </Card>
        )}

        <div className="space-y-3">
          {reviews.map((r) => (
            <Card key={r.id} className="p-4 border-none bg-buddy-surface/50">
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-bold">{r.buyer_data.display_name}</span>
                <div className="flex gap-0.5">
                  {Array.from({ length: r.rating }).map((_, i) => <Star key={i} size={14} className="text-buddy-gold fill-buddy-gold" />)}
                </div>
              </div>
              {r.body && <p className="text-sm text-buddy-text-secondary leading-relaxed">{r.body}</p>}
            </Card>
          ))}
          {reviews.length === 0 && <p className="text-sm text-buddy-text-secondary text-center py-10 bg-buddy-surface/30 rounded-xl">No reviews yet. Be the first to share your experience!</p>}
        </div>
      </div>

      {!plan.is_purchased && (
        <div className="fixed bottom-0 left-0 right-0 p-4 bg-buddy-black/95 backdrop-blur-xl border-t border-buddy-surface flex justify-center z-50">
          <div className="w-full max-w-xl flex items-center justify-between px-2">
            <div className="flex flex-col">
              <span className="text-xs font-semibold text-buddy-text-secondary uppercase tracking-wider mb-0.5">Price</span>
              <span className="text-xl font-bold text-buddy-green">
                {(!plan.price_artifacts || Object.keys(plan.price_artifacts).length === 0) ? 'Free' : Object.entries(plan.price_artifacts).map(([k, v]) => `${v} ${k}s`).join(', ')}
              </span>
            </div>
            <Button
              className="w-1/2 h-12 shadow-[0_0_15px_rgba(23,248,154,0.3)] text-buddy-black font-bold text-base"
              onClick={handlePurchase}
              disabled={purchasing}
              isLoading={purchasing}
            >
              <ShoppingCart size={18} className="mr-2" />
              Get Plan
            </Button>
          </div>
        </div>
      )}

      {plan.is_purchased && (
        <div className="fixed bottom-0 left-0 right-0 p-4 bg-buddy-black/95 backdrop-blur-xl border-t border-buddy-surface flex justify-center z-50">
          <div className="w-full max-w-xl">
             <Button className="w-full h-12 shadow-[0_0_15px_rgba(255,215,0,0.3)] bg-gradient-to-r from-buddy-gold to-yellow-300 text-buddy-black font-bold text-base" onClick={handlePersonalise}>
               <Sparkles size={18} className="mr-2" /> AI Personalise Plan
             </Button>
          </div>
        </div>
      )}
    </div>
  );
}
