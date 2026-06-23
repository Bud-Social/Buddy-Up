import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Star, Award, Clock, MapPin, MessageCircle, Calendar, BookOpen, Shield, Languages } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Avatar } from '@/components/ui/Avatar';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { sessionsApi, profilesApi } from '@/api';
import type { TrainerProfile, Review } from '@/api/sessions';

export default function TrainerProfilePage() {
  const { slug } = useParams();
  const navigate = useNavigate();
  const [trainer, setTrainer] = useState<TrainerProfile | null>(null);
  const [reviews, setReviews] = useState<Review[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (!slug) return;
    setIsLoading(true);
    Promise.all([
      sessionsApi.getTrainer(slug),
      sessionsApi.getTrainerReviews(slug),
    ]).then(([tRes, rRes]) => {
      setTrainer(tRes.data);
      setReviews(rRes.data || []);
    }).catch(() => {}).finally(() => setIsLoading(false));
  }, [slug]);

  if (isLoading) return <div className="max-w-lg mx-auto p-4"><div className="animate-pulse space-y-4"><div className="bg-buddy-surface rounded-2xl h-48" /><div className="bg-buddy-surface rounded-2xl h-64" /></div></div>;
  if (!trainer) return <div className="max-w-lg mx-auto p-4 text-center py-20"><p className="text-buddy-text-secondary">Trainer not found</p></div>;

  const { profile_data: p } = trainer;
  const isPractitioner = p.verification_status === 'practitioner';

  return (
    <div className="max-w-lg mx-auto p-4">
      <Card className="p-6 mb-4">
        <div className="text-center mb-4">
          <Avatar src={p.avatar_url} alt={p.display_name} size="xl" className="mx-auto mb-3" />
          <h2 className="font-heading text-xl font-semibold">{p.display_name}</h2>
          <p className="text-buddy-text-secondary text-sm">@{p.username}</p>
          <div className="flex justify-center gap-2 mt-2">
            {p.verification_status === 'trainer' && <Badge variant="green" label="Certified Trainer" icon="✓" />}
            {p.verification_status === 'practitioner' && <Badge variant="gold" label="Health Practitioner" icon="✓" />}
          </div>
          {p.bio && <p className="text-sm mt-3 px-4">{p.bio}</p>}
          {p.location_city && <p className="text-xs text-buddy-text-secondary mt-1"><MapPin size={12} className="inline mr-1" />{p.location_city}{p.location_country && `, ${p.location_country}`}</p>}
        </div>

        <div className="flex gap-3 mb-4">
          <div className="flex-1 text-center bg-buddy-surface-raised rounded-xl py-2">
            <p className="font-mono font-bold text-lg text-buddy-gold">{trainer.average_rating > 0 ? trainer.average_rating : '—'}</p>
            <div className="flex justify-center"><Star size={12} className="text-buddy-gold fill-buddy-gold" /></div>
            <p className="text-xs text-buddy-text-secondary">{trainer.review_count} reviews</p>
          </div>
          <div className="flex-1 text-center bg-buddy-surface-raised rounded-xl py-2">
            <p className="font-mono font-bold text-lg">{trainer.years_experience}</p>
            <Award size={12} className="mx-auto text-buddy-electric" />
            <p className="text-xs text-buddy-text-secondary">Years exp.</p>
          </div>
          <div className="flex-1 text-center bg-buddy-surface-raised rounded-xl py-2">
            <p className="font-mono font-bold text-lg">{trainer.total_sessions_completed}</p>
            <Calendar size={12} className="mx-auto text-buddy-green" />
            <p className="text-xs text-buddy-text-secondary">Sessions</p>
          </div>
        </div>

        <Button className="w-full" size="lg" onClick={() => navigate(`/sessions?book=${slug}`)}>
          <Calendar size={16} className="mr-2" /> Book a Session
        </Button>
        <Button variant="outline" className="w-full mt-2" size="sm">
          <MessageCircle size={14} className="mr-1" /> Message
        </Button>
      </Card>

      {trainer.specialties?.length > 0 && (
        <Card className="p-4 mb-4">
          <h3 className="font-heading font-semibold text-sm mb-2">Specialties</h3>
          <div className="flex flex-wrap gap-2">
            {trainer.specialties.map((s) => (
              <span key={s} className="text-xs bg-buddy-green/10 text-buddy-green px-3 py-1.5 rounded-full capitalize">{s.replace('_', ' ')}</span>
            ))}
          </div>
        </Card>
      )}

      {trainer.certifications?.length > 0 && (
        <Card className="p-4 mb-4">
          <h3 className="font-heading font-semibold text-sm mb-2"><Award size={14} className="inline mr-1" /> Certifications</h3>
          <div className="space-y-2">
            {trainer.certifications.map((c, i) => (
              <div key={i} className="text-sm flex justify-between">
                <span className="font-medium">{c.name}</span>
                <span className="text-buddy-text-secondary text-xs">{c.issuer} · {c.year}</span>
              </div>
            ))}
          </div>
        </Card>
      )}

      {trainer.languages?.length > 0 && (
        <Card className="p-4 mb-4">
          <h3 className="font-heading font-semibold text-sm mb-2"><Languages size={14} className="inline mr-1" /> Languages</h3>
          <div className="flex flex-wrap gap-2">
            {trainer.languages.map((l) => (
              <span key={l} className="text-xs bg-buddy-surface-raised px-3 py-1.5 rounded-full">{l}</span>
            ))}
          </div>
        </Card>
      )}

      <Card className="p-4">
        <h3 className="font-heading font-semibold text-sm mb-3"><Star size={14} className="inline mr-1 text-buddy-gold" /> Reviews ({reviews.length})</h3>
        {reviews.length === 0 ? (
          <p className="text-sm text-buddy-text-secondary text-center py-4">No reviews yet.</p>
        ) : (
          <div className="space-y-4">
            {reviews.map((r) => (
              <div key={r.id} className="border-t border-buddy-surface pt-3 first:border-0 first:pt-0">
                <div className="flex items-center gap-2 mb-1">
                  <Avatar src={r.client_data.avatar_url} alt={r.client_data.display_name} size="sm" />
                  <div>
                    <p className="text-sm font-medium">{r.client_data.display_name}</p>
                    <div className="flex gap-0.5">
                      {Array.from({ length: 5 }).map((_, i) => (
                        <Star key={i} size={10} className={i < r.rating ? 'text-buddy-gold fill-buddy-gold' : 'text-buddy-surface-raised'} />
                      ))}
                    </div>
                  </div>
                </div>
                {r.body && <p className="text-sm text-buddy-text-secondary mt-1">{r.body}</p>}
              </div>
            ))}
          </div>
        )}
      </Card>
    </div>
  );
}
