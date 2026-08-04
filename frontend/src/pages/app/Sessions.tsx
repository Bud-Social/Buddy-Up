import { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useAuthStore } from '@/store/authStore';
import { useToast } from '@/components/ui/Toast';
import { Calendar, Clock, MapPin, Video, Download, RefreshCw, ChevronRight } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Avatar } from '@/components/ui/Avatar';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Modal } from '@/components/ui/Modal';
import { Input } from '@/components/ui/Input';
import { sessionsApi } from '@/api/sessions';
import type { BookingSession } from '@/api/sessions';

const SESSION_TYPES = [
  { value: 'in_person', label: 'In Person' },
  { value: '1on1_live', label: '1:1 Live (Video)' },
  { value: 'group_live', label: 'Group Live' },
  { value: 'async', label: 'Async Programme' },
  { value: 'nutrition', label: 'Nutrition Consultation' },
];

const RECURRENCE_OPTIONS = [
  { value: '', label: 'One-time' },
  { value: 'weekly', label: 'Weekly' },
  { value: 'monthly', label: 'Monthly' },
  { value: 'daily', label: 'Daily' },
];

export default function Sessions() {
  const navigate = useNavigate();
  const profile = useAuthStore((s) => s.profile);
  const [bookings, setBookings] = useState<BookingSession[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [tab, setTab] = useState<'upcoming' | 'past'>('upcoming');
  const [viewRole, setViewRole] = useState<'client' | 'trainer'>('client');
  const [searchParams, setSearchParams] = useSearchParams();
  const bookTrainerUsername = searchParams.get('book');
  const { toast } = useToast();

  // Booking form state
  const [sessionType, setSessionType] = useState('in_person');
  const [duration, setDuration] = useState(60);
  const [scheduledAt, setScheduledAt] = useState('');
  const [notes, setNotes] = useState('');
  const [recurrencePattern, setRecurrencePattern] = useState('');
  const [recurringWeeks, setRecurringWeeks] = useState(4);
  const [bookingLoading, setBookingLoading] = useState(false);

  const fetchBookings = () => {
    if (!profile) return;
    setIsLoading(true);
    const roleParam = viewRole === 'trainer' ? 'trainer' : undefined;
    sessionsApi.getMyBookings(roleParam, tab === 'upcoming' ? 'confirmed' : 'completed')
      .then((res) => setBookings(res.data || []))
      .catch(() => {})
      .finally(() => setIsLoading(false));
  };

  useEffect(() => { fetchBookings(); }, [profile, tab, viewRole]);

  const handleBook = async () => {
    if (!bookTrainerUsername || !scheduledAt) return;
    setBookingLoading(true);
    try {
      await sessionsApi.bookSession(bookTrainerUsername, {
        session_type: sessionType,
        duration_minutes: duration,
        notes,
        scheduled_at: new Date(scheduledAt).toISOString(),
        recurrence_pattern: recurrencePattern || undefined,
        recurring_weeks: recurrencePattern ? recurringWeeks : undefined,
      });
      toast('success', recurrencePattern
        ? `Recurring sessions booked (${recurringWeeks}× ${recurrencePattern})!`
        : 'Session booked!');
      setSearchParams({});
      fetchBookings();
    } catch {
      toast('error', 'Failed to book session. Check your wallet balance.');
    } finally {
      setBookingLoading(false);
    }
  };

  const downloadICS = (booking: BookingSession, e: React.MouseEvent) => {
    e.stopPropagation();
    const link = document.createElement('a');
    link.href = `/api/v1/sessions/bookings/${booking.id}/calendar.ics`;
    link.setAttribute('download', `session-${booking.id}.ics`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const statusBadge = (status: string) => {
    const map: Record<string, { variant: 'green' | 'orange' | 'red' | 'silver'; label: string }> = {
      confirmed: { variant: 'green', label: 'Confirmed' },
      completed: { variant: 'silver', label: 'Completed' },
      cancelled_by_client: { variant: 'red', label: 'Cancelled' },
      cancelled_by_trainer: { variant: 'red', label: 'Cancelled' },
      no_show: { variant: 'orange', label: 'No Show' },
      in_progress: { variant: 'orange', label: 'In Progress' },
    };
    const b = map[status] || { variant: 'silver' as const, label: status };
    return <Badge variant={b.variant} label={b.label} size="sm" />;
  };

  const sessionIcon = (type: string) => {
    if (type === 'in_person') return <MapPin size={14} />;
    return <Video size={14} />;
  };

  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mb-6">
        <h1 className="font-display text-2xl font-extrabold">Sessions</h1>
        {profile?.role !== 'user' && (
          <Button variant="outline" size="sm" onClick={() => navigate('/sessions/offering')}>
            Manage Offerings
          </Button>
        )}
      </div>

      {profile?.role !== 'user' && (
        <div className="flex rounded-xl bg-buddy-surface p-1 mb-4">
          {[
            { key: 'client' as const, label: 'Client Bookings' },
            { key: 'trainer' as const, label: 'Trainer Bookings' },
          ].map(({ key, label }) => (
            <button key={key} onClick={() => setViewRole(key)}
              className={`flex-1 py-2 text-sm font-medium rounded-lg transition-colors ${viewRole === key ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary hover:text-buddy-text-primary'}`}>{label}</button>
          ))}
        </div>
      )}

      <div className="flex rounded-xl bg-buddy-surface p-1 mb-5">
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
            <Card key={i} className="p-4 animate-pulse"><div className="h-20 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : bookings.length === 0 ? (
        <div className="text-center py-20">
          <Calendar size={48} className="mx-auto text-buddy-text-secondary/30 mb-4" />
          <p className="text-buddy-text-secondary">No sessions booked yet.</p>
          <p className="text-buddy-text-secondary/50 text-sm mt-1">Find a trainer and book your first session!</p>
          <Button className="mt-6" onClick={() => navigate('/trainers')}>Browse Trainers</Button>
        </div>
      ) : (
        <div className="space-y-3">
          {bookings.map((b) => {
            const otherParty = viewRole === 'trainer' ? b.client_data : b.trainer_data;
            const isRecurring = !!(b as any).recurrence_pattern;
            return (
              <Card
                key={b.id}
                className="p-0 overflow-hidden hover:ring-2 hover:ring-buddy-green/50 transition-all cursor-pointer group"
                onClick={() => navigate(`/sessions/${b.id}`)}
              >
                <div className="p-4">
                  <div className="flex items-start justify-between mb-3">
                    <div className="flex items-center gap-2.5">
                      <Avatar src={otherParty.avatar_url} alt={otherParty.display_name} size="sm" />
                      <div>
                        <p className="text-sm font-semibold leading-tight">{otherParty.display_name}</p>
                        <p className="text-xs text-buddy-text-secondary">@{otherParty.username}</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      {isRecurring && (
                        <span title="Recurring" className="text-buddy-green"><RefreshCw size={13} /></span>
                      )}
                      {statusBadge(b.status)}
                    </div>
                  </div>

                  <div className="flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-buddy-text-secondary">
                    <span className="flex items-center gap-1">{sessionIcon(b.session_type)} {b.session_type.replace(/_/g, ' ')}</span>
                    <span className="flex items-center gap-1"><Clock size={12} /> {b.duration_minutes} min</span>
                    <span className="flex items-center gap-1"><Calendar size={12} /> {b.scheduled_at ? new Date(b.scheduled_at).toLocaleString([], { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' }) : 'TBD'}</span>
                  </div>

                  {b.notes && <p className="text-xs text-buddy-text-secondary/70 mt-2 italic line-clamp-1">"{b.notes}"</p>}
                </div>

                <div className="border-t border-buddy-surface/60 px-4 py-2 flex items-center justify-between">
                  <button
                    onClick={(e) => downloadICS(b, e)}
                    className="flex items-center gap-1 text-[11px] text-buddy-text-secondary hover:text-buddy-green transition-colors"
                  >
                    <Download size={12} /> Add to Calendar
                  </button>
                  <span className="text-[11px] text-buddy-text-secondary flex items-center gap-0.5 group-hover:text-buddy-green transition-colors">
                    Details <ChevronRight size={12} />
                  </span>
                </div>
              </Card>
            );
          })}
        </div>
      )}

      {/* Book Session Modal */}
      <Modal isOpen={!!bookTrainerUsername} onClose={() => setSearchParams({})} title="Book a Session">
        <div className="space-y-4">
          <div>
            <label className="text-sm font-medium mb-1 block">Session Type</label>
            <select value={sessionType} onChange={(e) => setSessionType(e.target.value)}
              className="w-full bg-buddy-surface rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30">
              {SESSION_TYPES.map(({ value, label }) => (
                <option key={value} value={value}>{label}</option>
              ))}
            </select>
          </div>

          <div>
            <label className="text-sm font-medium mb-1 block">Duration (minutes)</label>
            <select value={duration} onChange={(e) => setDuration(Number(e.target.value))}
              className="w-full bg-buddy-surface rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30">
              {[30, 45, 60, 90, 120].map((d) => (
                <option key={d} value={d}>{d} min</option>
              ))}
            </select>
          </div>

          <div>
            <label className="text-sm font-medium mb-1 block">Date & Time</label>
            <Input type="datetime-local" value={scheduledAt} onChange={(e) => setScheduledAt(e.target.value)} />
          </div>

          <div>
            <label className="text-sm font-medium mb-1 block">Recurrence</label>
            <select value={recurrencePattern} onChange={(e) => setRecurrencePattern(e.target.value)}
              className="w-full bg-buddy-surface rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30">
              {RECURRENCE_OPTIONS.map(({ value, label }) => (
                <option key={value} value={value}>{label}</option>
              ))}
            </select>
          </div>

          {recurrencePattern && (
            <div>
              <label className="text-sm font-medium mb-1 block">Number of sessions</label>
              <select value={recurringWeeks} onChange={(e) => setRecurringWeeks(Number(e.target.value))}
                className="w-full bg-buddy-surface rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30">
                {[2, 4, 6, 8, 10, 12].map((n) => (
                  <option key={n} value={n}>{n} sessions</option>
                ))}
              </select>
              <p className="text-[11px] text-buddy-text-secondary mt-1">
                Escrow will be held for the first session; subsequent sessions booked at same rate.
              </p>
            </div>
          )}

          <div>
            <label className="text-sm font-medium mb-1 block">Notes (optional)</label>
            <textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder="Any specific goals or requests?"
              className="w-full bg-buddy-surface rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none h-20"
            />
          </div>

          <div className="flex gap-2 pt-1">
            <Button variant="ghost" onClick={() => setSearchParams({})} className="flex-1">Cancel</Button>
            <Button onClick={handleBook} isLoading={bookingLoading} className="flex-1" disabled={!scheduledAt}>
              {recurrencePattern ? `Book ${recurringWeeks} Sessions` : 'Book Session'}
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}

