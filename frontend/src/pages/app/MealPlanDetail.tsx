import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, Star, Sparkles, ShoppingCart, MessageCircle, Utensils } from 'lucide-react';
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
      marketplaceApi.getMealPlanReviews(planId).catch(() => [] as MealPlanReview[]),
    ]).then(([p, r]) => {
      setPlan(p.data);
      setReviews(r as MealPlanReview[]);
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
      setReviews(r.data);
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

  const isOwner = plan.creator_data;
  return (
    <div className="max-w-lg mx-auto p-4">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => navigate('/marketplace')} className="p-2 rounded-xl hover:bg-buddy-surface"><ArrowLeft size={20} /></button>
        <h1 className="font-display text-2xl font-extrabold truncate">{plan.title}</h1>
      </div>

      <Card className="p-4 space-y-4">
        <div className="flex items-start justify-between">
          <div>
            <p className="text-xs text-buddy-text-secondary">by {plan.creator_data.display_name}</p>
            <div className="flex gap-2 mt-1">
              <Badge variant="blue" label={`${plan.duration_weeks} weeks`} size="sm" />
              <Badge variant="green" label={plan.diet_type.replace('_', ' ')} size="sm" />
              {plan.calorie_range && <Badge variant="silver" label={plan.calorie_range} size="sm" />}
            </div>
          </div>
          {plan.creator_data.verification_status === 'practitioner' && <Badge variant="gold" label="Nutritionist" size="sm" />}
        </div>

        <p className="text-sm text-buddy-text-secondary">{plan.description}</p>

        <div className="flex items-center gap-4 text-xs text-buddy-text-secondary">
          {plan.review_count > 0 && (
            <span className="flex items-center gap-1"><Star size={12} className="text-buddy-gold fill-buddy-gold" /> {plan.average_rating} ({plan.review_count})</span>
          )}
          <span>{plan.purchase_count} purchased</span>
        </div>

        {plan.price_artifacts && Object.keys(plan.price_artifacts).length > 0 && (
          <div className="flex flex-wrap gap-2">
            {Object.entries(plan.price_artifacts).map(([k, v]) => (
              <span key={k} className="inline-flex items-center gap-1 rounded-full bg-buddy-green/10 px-2.5 py-1 text-xs font-medium text-buddy-green">
                <ArtifactIcon artifact={k} size={14} /> {v}
              </span>
            ))}
          </div>
        )}

        <div>
          <h4 className="font-heading font-semibold text-sm mb-2">Preview (Day 1)</h4>
          <div className="bg-buddy-surface rounded-xl p-3 text-sm text-buddy-text-secondary">
            {plan.preview_day ? (
              <div className="space-y-2">
                {Object.entries(plan.preview_day as Record<string, string>).map(([k, v]) => (
                  <p key={k}><span className="font-medium capitalize">{k}:</span> {v}</p>
                ))}
              </div>
            ) : (
              <p>Purchase to view the full meal plan.</p>
            )}
          </div>
        </div>

        {plan.full_plan && (
          <div>
            <h4 className="font-heading font-semibold text-sm mb-2">Full Plan</h4>
            <div className="bg-buddy-surface rounded-xl p-3 text-sm text-buddy-text-secondary max-h-60 overflow-y-auto">
              {Object.entries(plan.full_plan as Record<string, unknown>).map(([day, meals]) => (
                <div key={day} className="mb-3">
                  <p className="font-medium capitalize text-buddy-text-primary mb-1">{day.replace(/_/g, ' ')}</p>
                  {typeof meals === 'object' && meals && Object.entries(meals as Record<string, string>).map(([meal, food]) => (
                    <p key={meal} className="ml-2"><span className="capitalize">{meal}:</span> {food}</p>
                  ))}
                </div>
              ))}
            </div>
          </div>
        )}

        {plan.shopping_list && plan.shopping_list.length > 0 && (
          <div>
            <h4 className="font-heading font-semibold text-sm mb-2">Shopping List</h4>
            <div className="bg-buddy-surface rounded-xl p-3 text-sm text-buddy-text-secondary">
              <ul className="list-disc list-inside space-y-1">
                {plan.shopping_list.map((item, i) => <li key={i}>{item}</li>)}
              </ul>
            </div>
          </div>
        )}

        <div className="flex gap-2">
          {!plan.is_purchased ? (
            <Button className="flex-1" onClick={handlePurchase} disabled={purchasing}>
              <ShoppingCart size={16} className="mr-2" />
              {purchasing ? 'Processing...' : 'Purchase'}
            </Button>
          ) : (
            <>
              <Button variant="outline" className="flex-1" onClick={handlePersonalise}>
                <Sparkles size={16} className="mr-2" /> AI Personalise
              </Button>
            </>
          )}
        </div>
      </Card>

      <div className="mt-6">
        <h2 className="font-heading font-semibold text-lg mb-3 flex items-center gap-2">
          <MessageCircle size={18} /> Reviews ({reviews.length})
        </h2>

        {plan.is_purchased && (
          <Card className="p-4 mb-3 space-y-2">
            <div className="flex gap-1">
              {[1, 2, 3, 4, 5].map((s) => (
                <button key={s} onClick={() => setReviewRating(s)}>
                  <Star size={18} className={s <= reviewRating ? 'text-buddy-gold fill-buddy-gold' : 'text-buddy-text-secondary'} />
                </button>
              ))}
            </div>
            <textarea className="w-full rounded-xl bg-buddy-surface border border-buddy-surface-raised px-3 py-2 text-sm focus:outline-none focus:border-buddy-green resize-none" rows={2} value={reviewBody} onChange={(e) => setReviewBody(e.target.value)} placeholder="Write a review..." />
            <Button size="sm" onClick={handleReview} disabled={reviewing}>{reviewing ? 'Submitting...' : 'Submit Review'}</Button>
          </Card>
        )}

        <div className="space-y-2">
          {reviews.map((r) => (
            <Card key={r.id} className="p-3">
              <div className="flex items-center gap-2 mb-1">
                <span className="text-sm font-medium">{r.buyer_data.display_name}</span>
                <div className="flex gap-0.5">
                  {Array.from({ length: r.rating }).map((_, i) => <Star key={i} size={12} className="text-buddy-gold fill-buddy-gold" />)}
                </div>
              </div>
              {r.body && <p className="text-xs text-buddy-text-secondary">{r.body}</p>}
            </Card>
          ))}
          {reviews.length === 0 && <p className="text-xs text-buddy-text-secondary text-center py-8">No reviews yet.</p>}
        </div>
      </div>
    </div>
  );
}
