/**
 * SessionDetail.tsx – Rich session control page.
 * Allows client & trainer to:
 *   - View session details (type, duration, schedule, price/min breakdown)
 *   - Start, complete, or cancel sessions
 *   - See escrow status and refund info
 *   - Leave a review once completed
 *   - Jump into a video/audio call directly
 */
import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  ArrowLeft, Calendar, Clock, Video, MapPin, Star, XCircle,
  CheckCircle, PhoneCall, AlertTriangle, DollarSign, Shield, User,
  PlayCircle, Lock,
} from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Modal } from '@/components/ui/Modal';
import { useAuthStore } from '@/store/authStore';
import { sessionsApi } from '@/api/sessions';
import type { BookingSession } from '@/api/sessions';
import { useToast } from '@/components/ui/Toast';

const SESSION_TYPE_LABELS: Record<string, string> = {
  '1on1_live': '1-on-1 Live',
  group_live: 'Group Live',
  async: 'Async Programme',
  nutrition: 'Nutrition Consultation',
  in_person: 'In-Person',
};

const STATUS_CONFIG: Record<string, { label: string; color: string; icon: React.ReactNode }> = {
  pending:              { label: 'Pending',       color: 'text-yellow-400', icon: <Clock size={16} /> },
  confirmed:            { label: 'Confirmed',     color: 'text-buddy-green', icon: <CheckCircle size={16} /> },
  in_progress:          { label: 'In Progress',   color: 'text-blue-400', icon: <PlayCircle size={16} /> },
  completed:            { label: 'Completed',     color: 'text-gray-400', icon: <CheckCircle size={16} /> },
  cancelled_by_client:  { label: 'Cancelled',     color: 'text-red-400', icon: <XCircle size={16} /> },
  cancelled_by_trainer: { label: 'Cancelled',     color: 'text-red-400', icon: <XCircle size={16} /> },
  disputed:             { label: 'Disputed',      color: 'text-orange-400', icon: <AlertTriangle size={16} /> },
  no_show:              { label: 'No Show',       color: 'text-orange-400', icon: <AlertTriangle size={16} /> },
};

export default function SessionDetail() {
  const { bookingId } = useParams<{ bookingId: string }>();
  const navigate = useNavigate();
  const profile = useAuthStore((s) => s.profile);
  const { toast } = useToast();

  const [booking, setBooking] = useState<BookingSession | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState(false);
  const [showReview, setShowReview] = useState(false);
  const [rating, setRating] = useState(5);
  const [reviewBody, setReviewBody] = useState('');

  useEffect(() => {
    if (!bookingId) return;
    setIsLoading(true);
    sessionsApi.getBooking(bookingId)
      .then((res) => setBooking(res.data ?? null))
      .catch(() => toast('error', 'Failed to load session'))
      .finally(() => setIsLoading(false));
  }, [bookingId, toast]);

  const doAction = async (action: 'start' | 'complete' | 'cancel') => {
    if (!bookingId) return;
    setActionLoading(true);
    try {
      await sessionsApi.bookingAction(bookingId, action);
      const actionMessages = {
        start: 'Session started!',
        complete: 'Session marked as completed. Escrow released!',
        cancel: 'Session cancelled.',
      };
      toast('success', actionMessages[action]);
      const res = await sessionsApi.getBooking(bookingId);
      setBooking(res.data ?? null);
    } catch {
      toast('error', 'Action failed. Please try again.');
    } finally {
      setActionLoading(false);
    }
  };

  const handleSubmitReview = async () => {
    if (!bookingId) return;
    try {
      await sessionsApi.submitReview(bookingId, rating, reviewBody);
      toast('success', 'Review submitted! Thank you.');
      setShowReview(false);
    } catch {
      toast('error', 'Failed to submit review.');
    }
  };

  const isTrainer = profile?.user_id === booking?.trainer_data?.user_id;
  const isClient = profile?.user_id === booking?.client_data?.user_id;
  const status = booking?.status ?? 'pending';
  const statusInfo = STATUS_CONFIG[status] ?? { label: status, color: 'text-gray-400', icon: <Clock size={16} /> };

  // Pricing breakdown
  const fee = booking?.artifact_fee ?? {};
  const feeEntries = Object.entries(fee);
  const durationHrs = (booking?.duration_minutes ?? 60) / 60;
  const pricePerHour = feeEntries.map(([type, qty]) => ({
    type,
    total: qty as number,
    perHour: Math.round((qty as number) / durationHrs * 100) / 100,
    perMin: Math.round((qty as number) / (booking?.duration_minutes ?? 60) * 100) / 100,
  }));

  if (isLoading) {
    return (
      <div className="max-w-lg mx-auto p-4 space-y-4 animate-pulse">
        <div className="h-8 w-40 bg-buddy-surface rounded-xl" />
        <div className="h-48 bg-buddy-surface rounded-2xl" />
        <div className="h-32 bg-buddy-surface rounded-2xl" />
      </div>
    );
  }

  if (!booking) {
    return (
      <div className="max-w-lg mx-auto p-4 text-center py-24">
        <AlertTriangle size={48} className="mx-auto text-buddy-text-secondary/30 mb-4" />
        <p className="text-buddy-text-secondary">Session not found.</p>
        <Button variant="ghost" className="mt-4" onClick={() => navigate('/sessions')}>← Back to Sessions</Button>
      </div>
    );
  }

  const otherParty = isTrainer ? booking.client_data : booking.trainer_data;
  const scheduledDate = new Date(booking.scheduled_at);

  return (
    <div className="max-w-lg mx-auto p-4 pb-12">
      {/* Back */}
      <button
        onClick={() => navigate('/sessions')}
        className="flex items-center gap-2 text-buddy-text-secondary hover:text-buddy-text-primary transition-colors mb-5 group"
      >
        <ArrowLeft size={18} className="group-hover:-translate-x-0.5 transition-transform" />
        <span className="text-sm font-medium">Sessions</span>
      </button>

      {/* Header Card */}
      <Card className="p-5 mb-4 relative overflow-hidden">
        <div className="absolute inset-x-0 top-0 h-0.5 bg-gradient-to-r from-transparent via-buddy-green to-transparent" />

        <div className="flex items-start gap-4 mb-4">
          <Avatar
            src={otherParty?.avatar_url}
            alt={otherParty?.display_name ?? ''}
            size="lg"
            verificationStatus={otherParty?.verification_status}
            className="ring-2 ring-buddy-surface-raised shrink-0"
          />
          <div className="flex-1 min-w-0">
            <div className="flex items-start justify-between gap-2">
              <div className="min-w-0">
                <p className="font-semibold text-buddy-text-primary truncate">{otherParty?.display_name}</p>
                <p className="text-xs text-buddy-text-secondary truncate">@{otherParty?.username}</p>
                <p className="text-xs text-buddy-text-secondary mt-0.5 flex items-center gap-1">
                  <User size={11} /> {isTrainer ? 'Client' : 'Trainer / Expert'}
                </p>
              </div>
              <span className={`flex items-center gap-1 text-xs font-semibold shrink-0 ${statusInfo.color}`}>
                {statusInfo.icon}
                {statusInfo.label}
              </span>
            </div>
          </div>
        </div>

        {/* Session Details Grid */}
        <div className="grid grid-cols-2 gap-3">
          <div className="bg-buddy-surface rounded-xl p-3">
            <p className="text-[10px] text-buddy-text-secondary uppercase tracking-wider mb-1">Type</p>
            <p className="text-sm font-medium flex items-center gap-1.5">
              {booking.session_type === 'in_person' ? <MapPin size={13} /> : <Video size={13} />}
              {SESSION_TYPE_LABELS[booking.session_type] ?? booking.session_type}
            </p>
          </div>
          <div className="bg-buddy-surface rounded-xl p-3">
            <p className="text-[10px] text-buddy-text-secondary uppercase tracking-wider mb-1">Duration</p>
            <p className="text-sm font-medium flex items-center gap-1.5">
              <Clock size={13} />
              {booking.duration_minutes} min
            </p>
          </div>
          <div className="bg-buddy-surface rounded-xl p-3">
            <p className="text-[10px] text-buddy-text-secondary uppercase tracking-wider mb-1">Date</p>
            <p className="text-sm font-medium flex items-center gap-1.5">
              <Calendar size={13} />
              {scheduledDate.toLocaleDateString(undefined, { day: 'numeric', month: 'short', year: 'numeric' })}
            </p>
          </div>
          <div className="bg-buddy-surface rounded-xl p-3">
            <p className="text-[10px] text-buddy-text-secondary uppercase tracking-wider mb-1">Time</p>
            <p className="text-sm font-medium flex items-center gap-1.5">
              <Clock size={13} />
              {scheduledDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
            </p>
          </div>
        </div>

        {booking.notes && (
          <div className="mt-3 bg-buddy-surface rounded-xl p-3">
            <p className="text-[10px] text-buddy-text-secondary uppercase tracking-wider mb-1">Notes</p>
            <p className="text-sm text-buddy-text-primary italic">"{booking.notes}"</p>
          </div>
        )}
      </Card>

      {/* Pricing & Escrow Card */}
      {feeEntries.length > 0 && (
        <Card className="p-5 mb-4">
          <div className="flex items-center gap-2 mb-4">
            <DollarSign size={16} className="text-buddy-green" />
            <h3 className="font-semibold text-sm">Session Fee & Escrow</h3>
            <Shield size={13} className="text-buddy-green ml-auto" />
            <span className="text-[11px] text-buddy-green font-medium">Protected</span>
          </div>
          <div className="space-y-3">
            {pricePerHour.map(({ type, total, perHour, perMin }) => (
              <div key={type} className="bg-buddy-surface rounded-xl p-3">
                <div className="flex items-center justify-between mb-1">
                  <p className="text-xs font-semibold capitalize text-buddy-text-primary">{type.replace('_', ' ')} Artifacts</p>
                  <p className="text-sm font-bold text-buddy-green">{total} total</p>
                </div>
                <div className="flex items-center gap-4 text-[11px] text-buddy-text-secondary">
                  <span>{perMin} / min</span>
                  <span className="text-buddy-text-secondary/40">·</span>
                  <span>{perHour} / hr</span>
                </div>
              </div>
            ))}
          </div>
          {booking.escrow_tx_id && (
            <div className="mt-3 flex items-center gap-2 bg-buddy-green/10 border border-buddy-green/20 rounded-xl px-3 py-2">
              <Lock size={12} className="text-buddy-green shrink-0" />
              <p className="text-[11px] text-buddy-green/80">
                {status === 'completed'
                  ? 'Escrow released to trainer after completion.'
                  : status.startsWith('cancelled')
                    ? 'Escrow refunded based on cancellation policy.'
                    : 'Funds held securely in escrow until session is completed.'}
              </p>
            </div>
          )}
        </Card>
      )}

      {/* Action Buttons */}
      <Card className="p-5 mb-4 space-y-3">
        <h3 className="font-semibold text-sm text-buddy-text-secondary uppercase tracking-wider">Actions</h3>

        {/* Start Session – Trainer only, confirmed */}
        {isTrainer && status === 'confirmed' && (
          <Button
            className="w-full bg-buddy-green text-buddy-black font-bold flex items-center justify-center gap-2"
            onClick={() => doAction('start')}
            isLoading={actionLoading}
          >
            <PlayCircle size={18} />
            Start Session
          </Button>
        )}

        {/* Complete Session – Trainer only, in progress */}
        {isTrainer && status === 'in_progress' && (
          <Button
            className="w-full bg-buddy-green text-buddy-black font-bold flex items-center justify-center gap-2"
            onClick={() => doAction('complete')}
            isLoading={actionLoading}
          >
            <CheckCircle size={18} />
            Mark as Completed & Release Escrow
          </Button>
        )}

        {/* Launch Call – both parties, in progress */}
        {(status === 'in_progress' || status === 'confirmed') && (
          <Button
            variant="outline"
            className="w-full flex items-center justify-center gap-2"
            onClick={() => navigate(`/messages?call=${otherParty?.username}&type=video`)}
          >
            <PhoneCall size={16} />
            {status === 'in_progress' ? 'Join Video Call' : 'Start Video Call'}
          </Button>
        )}

        {/* Cancel – Client and trainer, confirmed/pending */}
        {(status === 'confirmed' || status === 'pending') && (
          <Button
            variant="ghost"
            className="w-full text-red-400 hover:bg-red-500/10 flex items-center justify-center gap-2"
            onClick={() => doAction('cancel')}
            isLoading={actionLoading}
          >
            <XCircle size={16} />
            {isClient ? 'Cancel Session' : 'Cancel (Full Refund to Client)'}
          </Button>
        )}

        {/* Leave Review – Client, completed */}
        {isClient && status === 'completed' && (
          <Button
            variant="outline"
            className="w-full flex items-center justify-center gap-2"
            onClick={() => setShowReview(true)}
          >
            <Star size={16} />
            Leave a Review
          </Button>
        )}

        {(status === 'completed' || status.startsWith('cancelled')) && (
          <p className="text-center text-xs text-buddy-text-secondary/50 mt-2">
            {status === 'completed'
              ? '✅ Session completed and escrow released.'
              : '🔴 This session has been cancelled.'}
          </p>
        )}
      </Card>

      {/* Cancellation Policy */}
      <Card className="p-4">
        <p className="text-[11px] text-buddy-text-secondary leading-relaxed">
          <span className="font-semibold text-buddy-text-primary block mb-1">Cancellation Policy</span>
          Cancellations made more than 24 hours in advance receive a 100% refund.
          Cancellations within 24 hours receive a 50% refund. Trainer cancellations
          always result in a full refund to the client.
        </p>
      </Card>

      {/* Review Modal */}
      <Modal isOpen={showReview} onClose={() => setShowReview(false)} title={`Rate ${booking.trainer_data?.display_name}`}>
        <div className="space-y-4">
          <div className="flex justify-center gap-1">
            {[1, 2, 3, 4, 5].map((r) => (
              <button key={r} onClick={() => setRating(r)} className={`transition-transform hover:scale-110 ${r <= rating ? 'text-yellow-400' : 'text-buddy-text-secondary/30'}`}>
                <Star size={28} fill={r <= rating ? 'currentColor' : 'none'} />
              </button>
            ))}
          </div>
          <p className="text-center text-xs text-buddy-text-secondary">
            {['', 'Poor', 'Fair', 'Good', 'Great', 'Excellent'][rating]} · {rating}/5
          </p>
          <textarea
            value={reviewBody}
            onChange={(e) => setReviewBody(e.target.value)}
            placeholder="Share your experience with this trainer..."
            className="w-full bg-buddy-surface border border-buddy-surface rounded-xl px-4 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none h-28"
            maxLength={500}
          />
          <div className="flex gap-2">
            <Button variant="ghost" onClick={() => setShowReview(false)} className="flex-1">Cancel</Button>
            <Button onClick={handleSubmitReview} className="flex-1">Submit Review</Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}
