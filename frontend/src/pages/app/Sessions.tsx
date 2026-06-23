import { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { Calendar, Clock, MapPin, Video, Star, XCircle, CheckCircle } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Avatar } from '@/components/ui/Avatar';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Modal } from '@/components/ui/Modal';
import { Input } from '@/components/ui/Input';
import { sessionsApi } from '@/api/sessions';
import type { BookingSession } from '@/api/sessions';

export default function Sessions() {
  const [bookings, setBookings] = useState<BookingSession[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [tab, setTab] = useState<'upcoming' | 'past'>('upcoming');
  const [reviewModal, setReviewModal] = useState<{ bookingId: string; trainerName: string } | null>(null);
  const [rating, setRating] = useState(5);
  const [reviewBody, setReviewBody] = useState('');

  useEffect(() => {
    setIsLoading(true);
    sessionsApi.getMyBookings(undefined, tab === 'upcoming' ? 'confirmed' : 'completed')
      .then((res) => setBookings(res.data || []))
      .catch(() => {})
      .finally(() => setIsLoading(false));
  }, [tab]);

  const handleCancel = async (bookingId: string) => {
    try {
      await sessionsApi.cancelBooking(bookingId);
      setBookings((prev) => prev.map((b) => b.id === bookingId ? { ...b, status: 'cancelled_by_client' } : b));
    } catch {}
  };

  const handleSubmitReview = async () => {
    if (!reviewModal) return;
    try {
      await sessionsApi.submitReview(reviewModal.bookingId, rating, reviewBody);
      setReviewModal(null);
    } catch {}
  };

  const statusBadge = (status: string) => {
    const map: Record<string, { variant: 'green' | 'orange' | 'red' | 'silver'; label: string }> = {
      confirmed: { variant: 'green', label: 'Confirmed' },
      completed: { variant: 'silver', label: 'Completed' },
      cancelled_by_client: { variant: 'red', label: 'Cancelled' },
      cancelled_by_trainer: { variant: 'red', label: 'Cancelled' },
      no_show: { variant: 'orange', label: 'No Show' },
    };
    const b = map[status] || { variant: 'silver' as const, label: status };
    return <Badge variant={b.variant} label={b.label} size="sm" />;
  };

  const sessionIcon = (type: string) => {
    if (type === 'in_person') return <MapPin size={16} />;
    return <Video size={16} />;
  };

  return (
    <div className="max-w-lg mx-auto p-4">
      <h1 className="font-display text-2xl font-extrabold mb-4">Sessions</h1>

      <div className="flex rounded-xl bg-buddy-surface p-1 mb-4">
        {[
          { key: 'upcoming' as const, label: 'Upcoming' },
          { key: 'past' as const, label: 'Past' },
        ].map(({ key, label }) => (
          <button key={key} onClick={() => setTab(key)}
            className={`flex-1 py-2 text-sm font-medium rounded-lg transition-colors ${tab === key ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary hover:text-buddy-text-primary'}`}>{label}</button>
        ))}
      </div>

      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse"><div className="h-16 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : bookings.length === 0 ? (
        <div className="text-center py-20">
          <Calendar size={48} className="mx-auto text-buddy-text-secondary/30 mb-4" />
          <p className="text-buddy-text-secondary">No sessions booked yet.</p>
          <p className="text-buddy-text-secondary/50 text-sm mt-1">Find a trainer and book your first session!</p>
        </div>
      ) : (
        <div className="space-y-3">
          {bookings.map((b) => (
            <Card key={b.id} className="p-4">
              <div className="flex items-start justify-between mb-2">
                <div className="flex items-center gap-2">
                  <Avatar src={b.trainer_data.avatar_url} alt={b.trainer_data.display_name} size="sm" />
                  <div>
                    <p className="text-sm font-medium">{b.trainer_data.display_name}</p>
                    <p className="text-xs text-buddy-text-secondary">@{b.trainer_data.username}</p>
                  </div>
                </div>
                {statusBadge(b.status)}
              </div>

              <div className="flex items-center gap-4 text-xs text-buddy-text-secondary mt-2">
                <span className="flex items-center gap-1">{sessionIcon(b.session_type)} {b.session_type.replace('_', ' ')}</span>
                <span className="flex items-center gap-1"><Clock size={12} /> {b.duration_minutes} min</span>
                <span className="flex items-center gap-1"><Calendar size={12} /> {new Date(b.scheduled_at).toLocaleDateString()}</span>
              </div>

              {b.notes && <p className="text-xs text-buddy-text-secondary mt-2 italic">"{b.notes}"</p>}

              <div className="flex gap-2 mt-3">
                {b.status === 'confirmed' && (
                  <Button size="sm" variant="ghost" className="text-buddy-red" onClick={() => handleCancel(b.id)}>
                    <XCircle size={14} className="mr-1" /> Cancel
                  </Button>
                )}
                {b.status === 'completed' && (
                  <Button size="sm" variant="outline" onClick={() => setReviewModal({ bookingId: b.id, trainerName: b.trainer_data.display_name })}>
                    <Star size={14} className="mr-1" /> Review
                  </Button>
                )}
              </div>
            </Card>
          ))}
        </div>
      )}

      <Modal isOpen={!!reviewModal} onClose={() => setReviewModal(null)} title={`Review ${reviewModal?.trainerName}`}>
        <div className="space-y-4">
          <div className="flex justify-center gap-1">
            {[1, 2, 3, 4, 5].map((r) => (
              <button key={r} onClick={() => setRating(r)} className={`text-2xl ${r <= rating ? 'text-buddy-gold' : 'text-buddy-text-secondary/30'}`}>
                <Star size={28} fill={r <= rating ? 'currentColor' : 'none'} />
              </button>
            ))}
          </div>
          <textarea
            value={reviewBody}
            onChange={(e) => setReviewBody(e.target.value)}
            placeholder="Share your experience..."
            className="w-full bg-buddy-surface rounded-xl px-4 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none h-24"
            maxLength={500}
          />
          <div className="flex gap-2">
            <Button variant="ghost" onClick={() => setReviewModal(null)} className="flex-1">Cancel</Button>
            <Button onClick={handleSubmitReview} className="flex-1">Submit Review</Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}
