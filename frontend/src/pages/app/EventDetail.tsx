import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, Calendar, MapPin, Tag, Users, CheckCircle, Video } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { marketplaceApi } from '@/api/marketplace';

export default function EventDetail() {
  const { eventId } = useParams();
  const navigate = useNavigate();
  const [event, setEvent] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isPurchasing, setIsPurchasing] = useState(false);

  useEffect(() => {
    if (!eventId) return;
    marketplaceApi.getEvent(eventId)
      .then(res => setEvent(res.data))
      .catch(() => navigate('/marketplace'))
      .finally(() => setIsLoading(false));
  }, [eventId, navigate]);

  const handlePurchase = async () => {
    if (!event) return;
    setIsPurchasing(true);
    try {
      await marketplaceApi.purchaseEventTicket(event.id);
      const res = await marketplaceApi.getEvent(event.id);
      setEvent(res.data);
      // Navigate to tickets page
      navigate('/marketplace/events/my-tickets');
    } catch (e: any) {
      alert(e?.response?.data?.message || 'Failed to purchase ticket.');
    } finally {
      setIsPurchasing(false);
    }
  };

  if (isLoading) return <div className="p-4 text-center">Loading...</div>;
  if (!event) return <div className="p-4 text-center">Event not found.</div>;

  return (
    <div className="max-w-lg mx-auto p-4 pb-24">
      <button onClick={() => navigate(-1)} className="flex items-center gap-2 text-buddy-text-secondary hover:text-buddy-text-primary mb-4 transition-colors">
        <ArrowLeft size={20} /> Back
      </button>

      <Card className="p-0 overflow-hidden mb-6 border-none">
        {event.cover_image_url && (
          <div className="w-full h-48 sm:h-64 bg-buddy-surface-raised relative">
            <img src={event.cover_image_url} alt={event.title} className="w-full h-full object-cover" />
            <div className="absolute top-4 left-4 px-3 py-1 bg-buddy-black/80 backdrop-blur-sm rounded text-xs font-bold uppercase tracking-wider text-buddy-gold">
              {event.event_type.replace('_', ' ')}
            </div>
          </div>
        )}
        
        <div className="p-5">
          <h1 className="text-2xl font-bold mb-2">{event.title}</h1>
          <div className="flex items-center gap-2 mb-4 text-sm text-buddy-text-secondary">
            <span>By <span className="text-buddy-text-primary font-medium">{event.creator_data.display_name}</span></span>
            {event.gym_data && (
              <>
                <span>•</span>
                <span>At <span className="text-buddy-green cursor-pointer" onClick={() => navigate(`/gyms/${event.gym_data.handle}`)}>{event.gym_data.name}</span></span>
              </>
            )}
          </div>

          <div className="flex flex-col gap-3 mb-6 bg-buddy-surface rounded-xl p-4">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded-full bg-buddy-green/10 flex items-center justify-center">
                <Calendar size={16} className="text-buddy-green" />
              </div>
              <div>
                <p className="text-sm font-semibold">{new Date(event.start_datetime).toLocaleDateString(undefined, { weekday: 'long', month: 'long', day: 'numeric' })}</p>
                <p className="text-xs text-buddy-text-secondary">
                  {new Date(event.start_datetime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })} - {new Date(event.end_datetime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                </p>
              </div>
            </div>

            {event.location && event.event_type !== 'online' && (
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-buddy-electric/10 flex items-center justify-center">
                  <MapPin size={16} className="text-buddy-electric" />
                </div>
                <div>
                  <p className="text-sm font-semibold">{event.location}</p>
                </div>
              </div>
            )}
            
            {event.online_url && event.event_type !== 'in_person' && (
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-buddy-orange/10 flex items-center justify-center">
                  <Video size={16} className="text-buddy-orange" />
                </div>
                <div>
                  <p className="text-sm font-semibold">Online Event</p>
                  <a href={event.online_url} target="_blank" rel="noopener noreferrer" className="text-xs text-buddy-electric hover:underline">Join Link</a>
                </div>
              </div>
            )}

            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded-full bg-buddy-gold/10 flex items-center justify-center">
                <Users size={16} className="text-buddy-gold" />
              </div>
              <div>
                <p className="text-sm font-semibold">{event.attendee_count} attending</p>
                {event.capacity > 0 && <p className="text-xs text-buddy-text-secondary">{event.capacity - event.attendee_count} spots left</p>}
              </div>
            </div>
          </div>

          <div className="mb-6">
            <h3 className="font-semibold mb-2 flex items-center gap-2"><Tag size={16} className="text-buddy-electric" /> About Event</h3>
            <p className="text-sm text-buddy-text-secondary whitespace-pre-wrap leading-relaxed">{event.description}</p>
          </div>

        </div>
      </Card>

      <div className="fixed bottom-0 left-0 right-0 p-4 bg-buddy-black/90 backdrop-blur-md border-t border-buddy-surface flex justify-center z-50">
        <div className="w-full max-w-lg flex items-center justify-between">
          <div className="flex flex-col">
            <span className="text-xs text-buddy-text-secondary">Price</span>
            <span className="text-lg font-bold text-buddy-green">
              {event.is_free ? 'Free' : Object.entries(event.ticket_price_artifacts || {}).map(([k, v]) => `${v} ${k}s`).join(', ')}
            </span>
          </div>
          <Button 
            className="w-1/2" 
            onClick={handlePurchase} 
            disabled={isPurchasing || event.is_registered || (event.capacity > 0 && event.attendee_count >= event.capacity) || event.is_cancelled}
            isLoading={isPurchasing}
          >
            {event.is_cancelled ? 'Cancelled' : event.is_registered ? <span className="flex items-center gap-1"><CheckCircle size={16}/> Registered</span> : (event.capacity > 0 && event.attendee_count >= event.capacity) ? 'Sold Out' : 'Get Ticket'}
          </Button>
        </div>
      </div>
    </div>
  );
}
