import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, Star, ShoppingCart, MessageCircle, Dumbbell } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { ArtifactIcon } from '@/components/ui/ArtifactIcon';
import { marketplaceApi } from '@/api/marketplace';
import type { TrainingProgrammeMP, TrainingProgrammeReview } from '@/api/marketplace';

export default function ProgrammeDetail() {
  const { programmeId } = useParams<{ programmeId: string }>();
  const navigate = useNavigate();
  const [programme, setProgramme] = useState<TrainingProgrammeMP | null>(null);
  const [reviews, setReviews] = useState<TrainingProgrammeReview[]>([]);
  const [loading, setLoading] = useState(true);
  const [purchasing, setPurchasing] = useState(false);
  const [reviewRating, setReviewRating] = useState(5);
  const [reviewBody, setReviewBody] = useState('');
  const [reviewing, setReviewing] = useState(false);

  useEffect(() => {
    if (!programmeId) return;
    setLoading(true);
    Promise.all([
      marketplaceApi.getProgramme(programmeId),
      marketplaceApi.getProgrammeReviews(programmeId).catch(() => ({ data: [] } as unknown as { data: TrainingProgrammeReview[] })),
    ]).then(([p, r]) => {
      setProgramme(p.data);
      setReviews(r.data || []);
    }).catch(() => navigate('/marketplace'))
    .finally(() => setLoading(false));
  }, [programmeId, navigate]);

  const handlePurchase = async () => {
    if (!programmeId) return;
    setPurchasing(true);
    try {
      const res = await marketplaceApi.purchaseProgramme(programmeId);
      setProgramme(res.data);
    } catch {
      /* ignore */
    } finally {
      setPurchasing(false);
    }
  };

  const handleReview = async () => {
    if (!programmeId) return;
    setReviewing(true);
    try {
      await marketplaceApi.reviewProgramme(programmeId, reviewRating, reviewBody);
      const r = await marketplaceApi.getProgrammeReviews(programmeId);
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

  if (!programme) return null;

  return (
    <div className="max-w-lg mx-auto p-4">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => navigate('/marketplace')} className="p-2 rounded-xl hover:bg-buddy-surface"><ArrowLeft size={20} /></button>
        <h1 className="font-display text-2xl font-extrabold truncate">{programme.title}</h1>
      </div>

      <Card className="p-4 space-y-4">
        <div className="flex items-start justify-between">
          <div>
            <p className="text-xs text-buddy-text-secondary">by {programme.creator_data.display_name}</p>
            <div className="flex gap-2 mt-1">
              <Badge variant="green" label={programme.category} size="sm" />
              <Badge variant="blue" label={`${programme.duration_weeks} weeks`} size="sm" />
            </div>
          </div>
          {programme.creator_data.verification_status === 'practitioner' && <Badge variant="gold" label="Trainer" size="sm" />}
        </div>

        <p className="text-sm text-buddy-text-secondary">{programme.description}</p>

        <div className="flex items-center text-xs text-buddy-text-secondary">
          <span>{programme.purchase_count} enrolled</span>
        </div>

        {programme.price_artifacts && Object.keys(programme.price_artifacts).length > 0 && (
          <div className="flex flex-wrap gap-2">
            {Object.entries(programme.price_artifacts).map(([k, v]) => (
              <span key={k} className="inline-flex items-center gap-1 rounded-full bg-buddy-green/10 px-2.5 py-1 text-xs font-medium text-buddy-green"><ArtifactIcon artifact={k} size={14} /> {v}</span>
            ))}
          </div>
        )}

        <div className="flex gap-2">
          {!programme.is_purchased && (
            <Button className="flex-1" onClick={handlePurchase} disabled={purchasing}>
              <ShoppingCart size={16} className="mr-2" />
              {purchasing ? 'Processing...' : 'Enroll'}
            </Button>
          )}
        </div>
      </Card>

      <div className="mt-6">
        <h2 className="font-heading font-semibold text-lg mb-3 flex items-center gap-2">
          <MessageCircle size={18} /> Reviews ({reviews.length})
        </h2>

        {programme.is_purchased && (
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
