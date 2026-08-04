import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, Star, ShoppingCart, MessageCircle, Clock, Video, Lock, CheckCircle2, Activity, ShieldAlert, Zap } from 'lucide-react';
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
      <div className="max-w-xl lg:max-w-3xl xl:max-w-4xl mx-auto p-4 pb-24 animate-pulse">
        <div className="flex items-center gap-3 mb-6"><div className="w-10 h-10 bg-buddy-surface rounded-xl" /><div className="h-8 w-48 bg-buddy-surface rounded" /></div>
        <Card className="p-0 overflow-hidden"><div className="h-64 bg-buddy-surface-raised w-full" /><div className="p-5 space-y-4"><div className="h-6 w-3/4 bg-buddy-surface rounded" /><div className="h-4 w-full bg-buddy-surface rounded" /><div className="h-20 w-full bg-buddy-surface rounded" /></div></Card>
      </div>
    );
  }

  if (!programme) return null;

  return (
    <div className="max-w-xl lg:max-w-3xl xl:max-w-4xl mx-auto p-4 pb-24">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => navigate('/marketplace')} className="p-2 rounded-xl bg-buddy-surface hover:bg-buddy-surface-raised transition-colors"><ArrowLeft size={20} /></button>
        <h1 className="font-display text-2xl font-extrabold truncate tracking-tight">{programme.title}</h1>
      </div>

      <Card className="p-0 overflow-hidden mb-6 border-none shadow-xl bg-buddy-surface/50 backdrop-blur-md">
        {programme.cover_image_url && (
          <div className="w-full h-48 sm:h-64 relative bg-buddy-black">
            <img src={programme.cover_image_url} alt={programme.title} className="w-full h-full object-cover" />
            <div className="absolute inset-0 bg-gradient-to-t from-buddy-black/90 via-buddy-black/20 to-transparent" />
            <div className="absolute bottom-4 left-4">
              <Badge variant="electric" label={programme.category.charAt(0).toUpperCase() + programme.category.slice(1)} size="sm" className="mb-2 shadow-lg" />
              <h2 className="text-xl font-bold text-white">{programme.title}</h2>
              <p className="text-sm text-buddy-text-secondary mt-1 flex items-center gap-2">
                <Clock size={14} className="text-buddy-electric" /> {programme.duration_weeks} Weeks Training
              </p>
            </div>
            {programme.is_purchased && (
              <div className="absolute top-4 right-4 bg-buddy-electric text-buddy-black px-3 py-1 rounded-full text-xs font-bold flex items-center gap-1 shadow-[0_0_15px_rgba(23,154,248,0.5)]">
                <CheckCircle2 size={14} /> Enrolled
              </div>
            )}
          </div>
        )}

        <div className="p-5 space-y-6">
          <div className="flex items-start justify-between">
            <div>
              <p className="text-sm text-buddy-text-secondary">Created by <span className="font-bold text-buddy-text-primary">{programme.creator_data.display_name}</span></p>
              {programme.shop_data && (
                <p className="text-xs text-buddy-text-secondary mt-0.5">Host: <span className="text-buddy-electric font-medium cursor-pointer" onClick={() => navigate(`/shops/${programme.shop_data?.handle}`)}>{programme.shop_data.name}</span></p>
              )}
            </div>
            <div className="text-right">
              <div className="flex items-center gap-1 text-xs font-semibold">
                <Star size={14} className="text-buddy-gold fill-buddy-gold" /> {programme.average_rating} ({programme.review_count})
              </div>
              <p className="text-xs text-buddy-text-secondary mt-0.5">{programme.purchase_count} enrolled</p>
            </div>
          </div>

          <div>
            <h3 className="font-bold text-lg mb-2">About this Programme</h3>
            <p className="text-sm text-buddy-text-secondary leading-relaxed">{programme.description}</p>
          </div>

          {!programme.is_purchased && (
            <div className="bg-buddy-electric/10 border border-buddy-electric/20 rounded-xl p-4">
              <h4 className="font-bold text-sm text-buddy-electric flex items-center gap-2 mb-2"><Lock size={16} /> Premium Training Content Locked</h4>
              <p className="text-xs text-buddy-text-secondary">Enroll to unlock the full {programme.duration_weeks}-week training schedule, including workout videos, timing specifications, and guided tips & warnings.</p>
            </div>
          )}

          {programme.is_purchased && programme.schedule && (
            <div className="space-y-4">
              <h4 className="font-bold text-lg flex items-center gap-2"><Activity size={20} className="text-buddy-electric" /> Training Schedule</h4>
              <div className="space-y-4">
                {Object.entries(programme.schedule as Record<string, Record<string, any[]>>).map(([weekKey, daysMap]) => (
                  <div key={weekKey} className="bg-buddy-black border border-buddy-surface-raised rounded-xl overflow-hidden">
                    <div className="bg-buddy-surface px-4 py-3 font-bold text-sm border-b border-buddy-surface-raised capitalize flex items-center gap-2">
                      <Zap size={16} className="text-buddy-electric" /> {weekKey.replace('_', ' ')}
                    </div>
                    
                    <div className="divide-y divide-buddy-surface-raised">
                      {Object.entries(daysMap).map(([dayKey, activities]) => (
                        <div key={dayKey} className="p-4">
                          <h5 className="font-bold text-xs text-buddy-text-secondary mb-3 uppercase tracking-wider">{dayKey.replace('_', ' ')}</h5>
                          
                          <div className="space-y-3">
                            {activities.map((activity, idx) => (
                              <div 
                                key={idx} 
                                className="bg-buddy-surface/50 border border-buddy-surface-raised rounded-lg p-3 cursor-pointer hover:border-buddy-electric transition-colors"
                                onClick={() => navigate(`/marketplace/programmes/${programmeId}/activity/${weekKey}/${dayKey}/${idx}`)}
                              >
                                <div className="flex justify-between items-start mb-2">
                                  <h6 className="font-bold text-sm">{activity.title || 'Workout Session'}</h6>
                                  <div className="flex gap-2">
                                    <Badge variant="blue" label={`${activity.duration_mins} min`} size="sm" />
                                    {activity.timing && <Badge variant="silver" label={activity.timing} size="sm" />}
                                  </div>
                                </div>
                                
                                {activity.description && (
                                  <p className="text-xs text-buddy-text-secondary mb-3 leading-relaxed whitespace-pre-wrap">{activity.description}</p>
                                )}
                                
                                {activity.video_url && (
                                  <a href={activity.video_url} target="_blank" rel="noreferrer" className="flex items-center gap-1.5 text-xs font-semibold text-buddy-orange bg-buddy-orange/10 px-2 py-1.5 rounded w-max mb-3 hover:bg-buddy-orange/20 transition-colors">
                                    <Video size={14} /> Watch Tutorial
                                  </a>
                                )}
                                
                                {(activity.tips || activity.warnings) && (
                                  <div className="grid grid-cols-1 md:grid-cols-2 gap-2 mt-2 pt-3 border-t border-buddy-surface-raised">
                                    {activity.tips && (
                                      <div className="flex gap-2 text-xs">
                                        <Star size={14} className="text-buddy-gold shrink-0 mt-0.5" />
                                        <p className="text-buddy-text-secondary"><span className="font-bold text-buddy-gold">Tips: </span>{activity.tips}</p>
                                      </div>
                                    )}
                                    {activity.warnings && (
                                      <div className="flex gap-2 text-xs">
                                        <ShieldAlert size={14} className="text-buddy-red shrink-0 mt-0.5" />
                                        <p className="text-buddy-text-secondary"><span className="font-bold text-buddy-red">Caution: </span>{activity.warnings}</p>
                                      </div>
                                    )}
                                  </div>
                                )}
                              </div>
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

        </div>
      </Card>

      <div className="mt-6">
        <h2 className="font-bold text-xl mb-4 flex items-center gap-2">
          <MessageCircle className="text-buddy-electric" size={20} /> Reviews ({reviews.length})
        </h2>

        {programme.is_purchased && (
          <Card className="p-4 mb-4 space-y-3 border-none bg-buddy-surface/50 backdrop-blur-md">
            <p className="text-sm font-semibold">Write a Review</p>
            <div className="flex gap-1.5">
              {[1, 2, 3, 4, 5].map((s) => (
                <button key={s} onClick={() => setReviewRating(s)} className="transition-transform hover:scale-110">
                  <Star size={24} className={s <= reviewRating ? 'text-buddy-gold fill-buddy-gold drop-shadow-[0_0_8px_rgba(255,215,0,0.5)]' : 'text-buddy-surface-raised'} />
                </button>
              ))}
            </div>
            <textarea className="w-full rounded-xl bg-buddy-black border border-buddy-surface-raised px-4 py-3 text-sm focus:outline-none focus:border-buddy-electric transition-colors resize-none" rows={3} value={reviewBody} onChange={(e) => setReviewBody(e.target.value)} placeholder="How is the programme working for you?" />
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

      {!programme.is_purchased && (
        <div className="fixed bottom-0 left-0 right-0 p-4 bg-buddy-black/95 backdrop-blur-xl border-t border-buddy-surface flex justify-center z-50">
          <div className="w-full max-w-xl flex items-center justify-between px-2">
            <div className="flex flex-col">
              <span className="text-xs font-semibold text-buddy-text-secondary uppercase tracking-wider mb-0.5">Price</span>
              <span className="text-xl font-bold text-buddy-electric">
                {(!programme.price_artifacts || Object.keys(programme.price_artifacts).length === 0) ? 'Free' : Object.entries(programme.price_artifacts).map(([k, v]) => `${v} ${k}s`).join(', ')}
              </span>
            </div>
            <Button
              className="w-1/2 h-12 shadow-[0_0_15px_rgba(23,154,248,0.3)] bg-buddy-electric text-buddy-black font-bold text-base hover:bg-buddy-electric/90"
              onClick={handlePurchase}
              disabled={purchasing}
              isLoading={purchasing}
            >
              <ShoppingCart size={18} className="mr-2" />
              Enroll Now
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}
