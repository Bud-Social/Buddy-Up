import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, Calendar, MapPin, Tag, Users, Video, ShoppingCart, Clock, Store, ShieldCheck, CheckCircle2, ChevronLeft, ChevronRight, Minus, Plus } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { useToast } from '@/components/ui/Toast';
import { marketplaceApi } from '@/api/marketplace';
import { EVENT_CATEGORIES } from '@/config/eventCategories';

export default function EventDetail() {
  const { eventId } = useParams();
  const navigate = useNavigate();
  const { toast } = useToast();
  const [event, setEvent] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isAdding, setIsAdding] = useState(false);
  const [qty, setQty] = useState(1);
  const [mediaIndex, setMediaIndex] = useState(0);

  useEffect(() => {
    if (!eventId) return;
    marketplaceApi.getEvent(eventId)
      .then(res => setEvent(res.data))
      .catch(() => navigate('/marketplace'))
      .finally(() => setIsLoading(false));
  }, [eventId, navigate]);

  const handleAddToCart = async () => {
    if (!event || !eventId) return;
    setIsAdding(true);
    try {
      await marketplaceApi.addToCart('event_ticket', { event_id: eventId }, qty);
      toast('success', 'Added to cart!');
      window.dispatchEvent(new CustomEvent('cart-updated'));
    } catch {
      toast('error', 'Failed to add to cart');
    } finally {
      setIsAdding(false);
    }
  };

  const allMedia: { type: 'image' | 'video'; url: string }[] = [];
  if (event?.media?.length > 0) {
    event.media.forEach((m: any) => {
      if (m.media_type === 'video' || m.url) allMedia.push({ type: m.media_type, url: m.url });
    });
  }
  if (event?.gallery_urls?.length > 0) {
    event.gallery_urls.forEach((url: string) => {
      if (!allMedia.find(m => m.url === url)) allMedia.push({ type: 'image', url });
    });
  }
  if (event?.cover_image_url && !allMedia.find(m => m.url === event.cover_image_url)) {
    allMedia.unshift({ type: 'image', url: event.cover_image_url });
  }
  if (event?.promo_video_url && !allMedia.find(m => m.url === event.promo_video_url)) {
    allMedia.push({ type: 'video', url: event.promo_video_url });
  }

  const hasCarousel = allMedia.length > 1;

  const prevMedia = () => setMediaIndex(i => (i === 0 ? allMedia.length - 1 : i - 1));
  const nextMedia = () => setMediaIndex(i => (i === allMedia.length - 1 ? 0 : i + 1));

  if (isLoading) return (
    <div className="max-w-xl lg:max-w-3xl xl:max-w-4xl mx-auto p-4 animate-pulse">
       <div className="flex items-center gap-3 mb-6"><div className="w-10 h-10 bg-buddy-surface rounded-xl" /><div className="h-8 w-48 bg-buddy-surface rounded" /></div>
       <Card className="p-0 overflow-hidden"><div className="h-64 bg-buddy-surface-raised w-full" /><div className="p-5 space-y-4"><div className="h-6 w-3/4 bg-buddy-surface rounded" /><div className="h-20 w-full bg-buddy-surface rounded" /></div></Card>
    </div>
  );
  if (!event) return <div className="p-4 text-center">Event not found.</div>;

  const capacityPct = event.capacity > 0 ? Math.round((event.attendee_count / event.capacity) * 100) : 0;
  const isSoldOut = event.capacity > 0 && event.attendee_count >= event.capacity;
  
  const startDate = new Date(event.start_datetime);
  const now = new Date();
  const isPast = startDate < now;

  return (
    <div className="max-w-xl lg:max-w-3xl xl:max-w-4xl mx-auto p-4 pb-24">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => navigate('/marketplace')} className="p-2 rounded-xl bg-buddy-surface hover:bg-buddy-surface-raised transition-colors"><ArrowLeft size={20} /></button>
        <h1 className="font-display text-2xl font-extrabold truncate tracking-tight">Event Details</h1>
      </div>

      <Card className="p-0 overflow-hidden mb-6 border-none shadow-xl bg-buddy-surface/50 backdrop-blur-md">
        {/* Carousel */}
        {allMedia.length > 0 && (
          <div className="relative w-full h-48 sm:h-64 bg-buddy-black group">
            {allMedia[mediaIndex].type === 'video' ? (
              <video
                src={allMedia[mediaIndex].url}
                className="w-full h-full object-contain"
                controls
                poster={event.cover_image_url || undefined}
              />
            ) : (
              <img src={allMedia[mediaIndex].url} alt={event.title} className="w-full h-full object-cover opacity-90" />
            )}
            <div className="absolute inset-0 bg-gradient-to-t from-buddy-black via-buddy-black/40 to-transparent pointer-events-none" />

            {allMedia[mediaIndex].type === 'video' && (
              <div className="absolute top-3 left-3 bg-buddy-black/60 backdrop-blur-sm px-2 py-0.5 rounded text-[10px] text-white font-medium flex items-center gap-1">
                <Video size={12} /> Video
              </div>
            )}

            {hasCarousel && (
              <>
                <button onClick={prevMedia} className="absolute left-2 top-1/2 -translate-y-1/2 p-1.5 bg-black/40 hover:bg-black/60 text-white rounded-full opacity-0 group-hover:opacity-100 transition-all">
                  <ChevronLeft size={18} />
                </button>
                <button onClick={nextMedia} className="absolute right-2 top-1/2 -translate-y-1/2 p-1.5 bg-black/40 hover:bg-black/60 text-white rounded-full opacity-0 group-hover:opacity-100 transition-all">
                  <ChevronRight size={18} />
                </button>
                <div className="absolute bottom-3 left-1/2 -translate-x-1/2 flex gap-1.5">
                  {allMedia.map((_, i) => (
                    <button key={i} onClick={() => setMediaIndex(i)} className={`w-2 h-2 rounded-full transition-all ${i === mediaIndex ? 'bg-white w-4' : 'bg-white/40'}`} />
                  ))}
                </div>
              </>
            )}

            <div className="absolute bottom-4 left-4 right-4">
              <div className="flex items-center gap-2 mb-2">
                <Badge variant="blue" label={event.event_type.replace('_', ' ')} size="sm" className="shadow-lg capitalize" />
                {event.category && (
                  <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-buddy-green/90 text-buddy-black shadow-lg flex items-center gap-1">
                    <span>{EVENT_CATEGORIES.find(c => c.key === event.category)?.icon || '📌'}</span>
                    <span>{EVENT_CATEGORIES.find(c => c.key === event.category)?.label || event.category}</span>
                  </span>
                )}
              </div>
              <h1 className="text-2xl font-bold text-white leading-tight">{event.title}</h1>
            </div>
            
            <Badge
              variant={event.is_free ? 'green' : 'gold'}
              label={event.is_free ? 'Free' : 'Paid'}
              size="sm"
              className="absolute top-4 right-4 shadow-lg"
            />
          </div>
        )}

        <div className="p-5 space-y-6">
          
          <div className="flex items-start justify-between">
             <div>
                <p className="text-sm text-buddy-text-secondary">Organized by <span className="font-bold text-buddy-text-primary">{event.creator_data.display_name}</span></p>
             </div>
          </div>
          
          {event.shop_data && (
            <div className="flex items-center gap-3 bg-buddy-surface rounded-xl p-4 border border-buddy-surface-raised cursor-pointer hover:border-buddy-electric transition-colors" onClick={() => navigate(`/shops/${event.shop_data?.handle}`)}>
              <div className="w-10 h-10 rounded-full bg-buddy-electric/10 flex items-center justify-center text-buddy-electric">
                <Store size={20} />
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-1">
                  <p className="font-bold text-sm">{event.shop_data.name}</p>
                </div>
                <p className="text-xs text-buddy-text-secondary">Host Shop</p>
              </div>
              <ArrowLeft size={16} className="text-buddy-text-secondary rotate-180" />
            </div>
          )}

          <div className="flex flex-col gap-3 bg-buddy-black rounded-xl p-4 border border-buddy-surface-raised">
            <div className="flex items-start gap-3">
              <div className="w-10 h-10 rounded-full bg-buddy-green/10 flex items-center justify-center shrink-0">
                <Calendar size={18} className="text-buddy-green" />
              </div>
              <div>
                <p className="text-sm font-bold">{startDate.toLocaleDateString(undefined, { weekday: 'long', month: 'long', day: 'numeric' })}</p>
                <p className="text-xs text-buddy-text-secondary font-medium mt-0.5">
                  {startDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })} - {new Date(event.end_datetime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                  {event.timezone && ` ${event.timezone}`}
                </p>
              </div>
            </div>

            {event.location && event.event_type !== 'online' && (
              <div className="flex items-center gap-3 border-t border-buddy-surface-raised pt-3">
                <div className="w-10 h-10 rounded-full bg-buddy-electric/10 flex items-center justify-center shrink-0">
                  <MapPin size={18} className="text-buddy-electric" />
                </div>
                <div>
                  <p className="text-sm font-bold">{event.location}</p>
                  <a href={`https://maps.google.com/?q=${encodeURIComponent(event.location)}`} target="_blank" rel="noreferrer" className="text-xs text-buddy-electric hover:underline font-medium">View on Map</a>
                </div>
              </div>
            )}

            {event.online_url && event.event_type !== 'in_person' && (
              <div className="flex items-center gap-3 border-t border-buddy-surface-raised pt-3">
                <div className="w-10 h-10 rounded-full bg-buddy-orange/10 flex items-center justify-center shrink-0">
                  <Video size={18} className="text-buddy-orange" />
                </div>
                <div>
                  <p className="text-sm font-bold">Online Event</p>
                  {event.is_registered ? (
                    <a href={event.online_url} target="_blank" rel="noopener noreferrer" className="text-xs text-buddy-orange hover:underline font-medium">Join Meeting Link</a>
                  ) : (
                    <p className="text-xs text-buddy-text-secondary">Link hidden (Register to view)</p>
                  )}
                </div>
              </div>
            )}

            <div className="flex items-center gap-3 border-t border-buddy-surface-raised pt-3">
              <div className="w-10 h-10 rounded-full bg-buddy-gold/10 flex items-center justify-center shrink-0">
                <Users size={18} className="text-buddy-gold" />
              </div>
              <div className="flex-1">
                <div className="flex justify-between items-end mb-1">
                  <p className="text-sm font-bold">{event.attendee_count} attending</p>
                  {event.capacity > 0 && <p className="text-xs text-buddy-text-secondary">{event.capacity - event.attendee_count} spots left</p>}
                </div>
                {event.capacity > 0 && (
                  <div className="h-2 bg-buddy-surface-raised rounded-full overflow-hidden">
                    <div className={`h-full rounded-full transition-all ${isSoldOut ? 'bg-buddy-red shadow-[0_0_8px_rgba(239,68,68,0.5)]' : 'bg-buddy-green shadow-[0_0_8px_rgba(23,248,154,0.5)]'}`} style={{ width: `${Math.min(capacityPct, 100)}%` }} />
                  </div>
                )}
              </div>
            </div>
          </div>

          {event.tags && event.tags.length > 0 && (
            <div className="flex flex-wrap gap-2">
              {event.tags.map((tag: string, i: number) => (
                <Badge key={i} variant="silver" label={tag} size="sm" className="capitalize" />
              ))}
            </div>
          )}

          <div>
            <h3 className="font-bold text-lg mb-2 flex items-center gap-2"><Tag size={18} className="text-buddy-electric" /> About Event</h3>
            <p className="text-sm text-buddy-text-secondary whitespace-pre-wrap leading-relaxed">{event.description}</p>
          </div>

          {event.recurrence && event.recurrence !== 'none' && (
            <div className="flex items-center gap-2 text-xs font-medium bg-buddy-electric/10 text-buddy-electric rounded-lg px-3 py-2 w-fit">
              <Clock size={14} />
              {event.recurrence === 'daily' ? 'Repeats daily' : event.recurrence === 'weekly' ? 'Repeats weekly' : event.recurrence === 'monthly' ? 'Repeats monthly' : event.recurrence}
            </div>
          )}

          {event.ticket_tiers && event.ticket_tiers.length > 0 && (
            <div>
              <h3 className="font-bold text-lg mb-2 flex items-center gap-2"><Tag size={18} className="text-buddy-gold" /> Ticket Tiers</h3>
              <div className="space-y-2">
                {event.ticket_tiers.map((tier: any, i: number) => (
                  <div key={i} className="flex items-start justify-between bg-buddy-surface rounded-xl p-3">
                    <div>
                      <p className="text-sm font-semibold">{tier.name}</p>
                      {tier.perks && tier.perks.length > 0 && (
                        <p className="text-xs text-buddy-text-secondary mt-0.5">{tier.perks.join(' · ')}</p>
                      )}
                    </div>
                    <span className="text-sm font-bold text-buddy-green flex-shrink-0 ml-3">
                      {tier.price_artifacts && Object.keys(tier.price_artifacts).length > 0
                        ? Object.entries(tier.price_artifacts).map(([k, v]) => `${v} ${k}s`).join(', ')
                        : tier.price != null ? `${tier.price}` : ''}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {event.early_bird_enabled && (
            <div className="bg-buddy-gold/10 border border-buddy-gold/30 rounded-xl p-3">
              <p className="text-xs font-bold text-buddy-gold uppercase tracking-wide">Early Bird</p>
              {event.early_bird_deadline && (
                <p className="text-[10px] text-buddy-text-secondary mt-0.5">
                  Until {new Date(event.early_bird_deadline).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}
                </p>
              )}
              <p className="text-sm font-semibold mt-1">
                {Object.entries(event.early_bird_price_artifacts || {}).map(([k, v]) => `${v} ${k}s`).join(', ')}
              </p>
            </div>
          )}

          {event.agenda && event.agenda.length > 0 && (
            <div>
              <h3 className="font-bold text-lg mb-2 flex items-center gap-2"><Clock size={18} className="text-buddy-green" /> Agenda</h3>
              <div className="space-y-2">
                {event.agenda.map((item: any, i: number) => (
                  <div key={i} className="flex items-start gap-3 bg-buddy-surface rounded-xl p-3">
                    <span className="text-xs font-bold text-buddy-green bg-buddy-green/10 rounded-md px-2 py-1 w-16 text-center shrink-0">{item.time || '—'}</span>
                    <div className="min-w-0">
                      <p className="text-sm font-semibold">{item.title}</p>
                      {item.description && <p className="text-xs text-buddy-text-secondary">{item.description}</p>}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {event.cancellation_policy && (
            <div className="flex items-start gap-2 text-xs text-buddy-text-secondary bg-buddy-surface rounded-xl p-3">
              <ShieldCheck size={14} className="mt-0.5 shrink-0 text-buddy-electric" />
              <span><span className="font-bold text-buddy-text-primary">Cancellation policy:</span> {event.cancellation_policy}</span>
            </div>
          )}
        </div>
      </Card>

      <div className="fixed bottom-0 left-0 right-0 p-4 bg-buddy-black/95 backdrop-blur-xl border-t border-buddy-surface flex justify-center z-50">
        <div className="w-full max-w-xl flex items-center justify-between px-2">
          <div className="flex flex-col">
            <span className="text-xs font-semibold text-buddy-text-secondary uppercase tracking-wider mb-0.5">Price</span>
            <span className="text-xl font-bold text-buddy-green">
              {event.is_free ? 'Free' : Object.entries(event.ticket_price_artifacts || {}).map(([k, v]) => `${v} ${k}s`).join(', ')}
            </span>
            {!event.is_free && event.ticket_price_artifacts && (() => {
              const values: Record<string, number> = { dumbbell: 0.10, barbell: 0.50, burpee: 1.00, squat: 2.50, sprint: 5.00, pr: 10.00, champion: 25.00 };
              const usd = Object.entries(event.ticket_price_artifacts).reduce((s, [k, v]) => s + (values[k] || 0) * (v as number), 0);
              return <span className="text-[10px] text-buddy-text-secondary font-medium">~${usd.toFixed(2)} USD</span>;
            })()}
          </div>
          <div className="flex items-center gap-3">
            {!event.is_registered && !event.is_cancelled && !isPast && !isSoldOut && (
              <div className="flex items-center border border-buddy-surface-raised rounded-xl">
                <button onClick={() => setQty(q => Math.max(1, q - 1))} className="p-2.5 hover:bg-buddy-surface transition-colors rounded-l-xl"><Minus size={14} /></button>
                <span className="px-3 text-sm font-medium min-w-[24px] text-center">{qty}</span>
                <button onClick={() => setQty(q => q + 1)} className="p-2.5 hover:bg-buddy-surface transition-colors rounded-r-xl"><Plus size={14} /></button>
              </div>
            )}
            <Button
              className={`min-w-[170px] h-12 text-buddy-black font-bold text-base shadow-lg ${event.is_registered ? 'bg-buddy-surface text-buddy-text-primary' : 'bg-buddy-green hover:bg-buddy-green/90 shadow-[0_0_15px_rgba(23,248,154,0.3)]'}`}
              onClick={event.is_registered ? () => navigate('/marketplace/events/my-tickets') : handleAddToCart}
              disabled={isAdding || event.is_cancelled || isSoldOut || isPast}
              isLoading={isAdding}
            >
              {event.is_cancelled ? 'Cancelled' : 
               isPast ? 'Ended' : 
               event.is_registered ? <><CheckCircle2 size={18} className="mr-2 text-buddy-green" /> My Ticket</> : 
               isSoldOut ? 'Sold Out' : 
               <><ShoppingCart size={18} className="mr-2" /> Get Ticket</>}
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
