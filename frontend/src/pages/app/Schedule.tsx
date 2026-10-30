import { useEffect, useMemo, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import {
  BookOpen, CalendarDays, ChevronRight, Clock, Dumbbell, MapPin, Salad, ShoppingBag, Video,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { sessionsApi, type BookingSession } from '@/api/sessions';
import { gymsApi } from '@/api/gyms';
import { marketplaceApi, type MealPlan, type TrainingProgrammeMP } from '@/api/marketplace';
import type { Gym, GymRoutinePost } from '@/types';

/**
 * Everything with a date, in one place.
 *
 * Bookings, gym slots the member enrolled in, and the programmes/meal plans
 * they own were previously split across `/sessions`, each gym's own schedule,
 * and the marketplace library. The schedule is the answer to "what am I doing
 * this week", so it reads bookings and gym enrolments together, sorted by
 * time, and keeps owned plans as an always-on section rather than pretending
 * a six-week programme has one appointment.
 */

type ScheduleItem = {
  id: string;
  title: string;
  when: string | null;
  kind: 'booking' | 'gym';
  subtitle: string;
  meta?: string;
  href: string;
};

type Enrollment = {
  id: string;
  schedule_post: string;
  schedule_post_data?: {
    id: string;
    title: string;
    activity_type: string;
    start_time: string | null;
  };
};

const SESSION_TYPE_LABELS: Record<string, string> = {
  in_person: 'In person',
  '1on1_live': '1:1 live',
  group_live: 'Group live',
  async: 'Async',
  nutrition: 'Nutrition',
};

function startOfToday(): number {
  const d = new Date();
  d.setHours(0, 0, 0, 0);
  return d.getTime();
}

function dayLabel(iso: string): string {
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return 'Unscheduled';
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const target = new Date(date);
  target.setHours(0, 0, 0, 0);
  const diff = Math.round((target.getTime() - today.getTime()) / 86_400_000);
  if (diff === 0) return 'Today';
  if (diff === 1) return 'Tomorrow';
  if (diff > 1 && diff < 7) {
    return target.toLocaleDateString(undefined, { weekday: 'long' });
  }
  return target.toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
}

function timeLabel(iso: string | null): string {
  if (!iso) return 'Time to be confirmed';
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return 'Time to be confirmed';
  return date.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' });
}

export default function Schedule() {
  const navigate = useNavigate();
  const [bookings, setBookings] = useState<BookingSession[]>([]);
  const [slots, setSlots] = useState<ScheduleItem[]>([]);
  const [programmes, setProgrammes] = useState<TrainingProgrammeMP[]>([]);
  const [mealPlans, setMealPlans] = useState<MealPlan[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    let cancelled = false;

    async function load() {
      setIsLoading(true);
      setError('');

      const [bookingsResult, programmesResult, plansResult, gymsResult] = await Promise.allSettled([
        sessionsApi.getMyBookings(undefined, 'confirmed'),
        marketplaceApi.getMyProgrammes(),
        marketplaceApi.getMyMealPlans(),
        gymsApi.list({ my: true }),
      ]);

      if (cancelled) return;

      if (bookingsResult.status === 'fulfilled') {
        setBookings(bookingsResult.value.data || []);
      }
      if (programmesResult.status === 'fulfilled') {
        setProgrammes(programmesResult.value.data || []);
      }
      if (plansResult.status === 'fulfilled') {
        setMealPlans(plansResult.value.data || []);
      }

      if (gymsResult.status === 'fulfilled') {
        const gyms = (gymsResult.value.data || []) as Gym[];
        const enrollmentResults = await Promise.allSettled(
          gyms.map((gym) => gymsApi.getMyEnrollments(gym.handle)),
        );
        if (cancelled) return;
        const cutoff = startOfToday();
        const next: ScheduleItem[] = [];
        enrollmentResults.forEach((result, index) => {
          if (result.status !== 'fulfilled') return;
          const gym = gyms[index];
          const enrollments = (result.value.data || []) as Enrollment[];
          for (const enrollment of enrollments) {
            const post = enrollment.schedule_post_data as
              | GymRoutinePost
              | undefined;
            const when = post?.start_time ?? null;
            if (when && new Date(when).getTime() < cutoff) continue;
            next.push({
              id: `gym-${enrollment.id}`,
              title: post?.title || 'Gym session',
              when,
              kind: 'gym',
              subtitle: gym.name,
              meta: post?.activity_type?.replace(/_/g, ' '),
              href: `/gyms/${gym.handle}`,
            });
          }
        });
        setSlots(next);
      }

      if (bookingsResult.status === 'rejected' && gymsResult.status === 'rejected') {
        setError('Could not load your schedule. Check your connection.');
      }
      if (!cancelled) setIsLoading(false);
    }

    void load();
    return () => {
      cancelled = true;
    };
  }, []);

  const items = useMemo<ScheduleItem[]>(() => {
    const bookingItems: ScheduleItem[] = bookings
      .filter((booking) => booking.scheduled_at)
      .map((booking) => ({
        id: `booking-${booking.id}`,
        title: `Session with ${booking.trainer_data?.display_name || 'your trainer'}`,
        when: booking.scheduled_at,
        kind: 'booking',
        subtitle: SESSION_TYPE_LABELS[booking.session_type] || booking.session_type,
        meta: `${booking.duration_minutes} min`,
        href: `/sessions/${booking.id}`,
      }));
    return [...bookingItems, ...slots]
      .filter((item) => !item.when || new Date(item.when).getTime() >= startOfToday())
      .sort((a, b) => {
        if (!a.when) return 1;
        if (!b.when) return -1;
        return new Date(a.when).getTime() - new Date(b.when).getTime();
      });
  }, [bookings, slots]);

  const grouped = useMemo(() => {
    const groups: { label: string; items: ScheduleItem[] }[] = [];
    for (const item of items) {
      const label = item.when ? dayLabel(item.when) : 'Unscheduled';
      const last = groups[groups.length - 1];
      if (last && last.label === label) last.items.push(item);
      else groups.push({ label, items: [item] });
    }
    return groups;
  }, [items]);

  const ownedCount = programmes.length + mealPlans.length;

  return (
    <div className="max-w-3xl mx-auto px-4 py-6 pb-24 space-y-6">
      <div className="flex items-start justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold flex items-center gap-2">
            <CalendarDays size={22} className="text-buddy-green" /> Schedule
          </h1>
          <p className="text-sm text-buddy-text-secondary mt-1">
            Sessions you booked, gym slots you joined, and the plans you own.
          </p>
        </div>
        <Link
          to="/sessions?tab=orders"
          className="text-xs font-medium text-buddy-green hover:underline flex items-center gap-1 shrink-0"
        >
          <ShoppingBag size={13} /> Purchases <ChevronRight size={13} />
        </Link>
      </div>

      {error && (
        <Card className="p-3 border-buddy-red/40">
          <p className="text-xs text-buddy-red">{error}</p>
        </Card>
      )}

      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse">
              <div className="h-12 rounded bg-buddy-surface-raised" />
            </Card>
          ))}
        </div>
      ) : items.length === 0 ? (
        <Card className="p-8 text-center">
          <CalendarDays size={40} className="mx-auto mb-3 opacity-30" />
          <p className="font-medium">Nothing scheduled yet</p>
          <p className="text-sm text-buddy-text-secondary mt-1 mb-4">
            Book a trainer or join a gym slot and it will appear here.
          </p>
          <div className="flex items-center justify-center gap-2">
            <Link to="/trainers" className="text-xs font-medium text-buddy-green hover:underline">
              Find a trainer
            </Link>
            <span className="text-buddy-text-secondary">·</span>
            <Link to="/gyms" className="text-xs font-medium text-buddy-green hover:underline">
              Browse gyms
            </Link>
          </div>
        </Card>
      ) : (
        <div className="space-y-5">
          {grouped.map((group) => (
            <section key={group.label} className="space-y-2">
              <h2 className="text-xs font-semibold uppercase tracking-wider text-buddy-text-secondary px-1">
                {group.label}
              </h2>
              {group.items.map((item) => (
                <Card
                  key={item.id}
                  className="p-3 cursor-pointer hover:border-buddy-green/40 transition-colors"
                  onClick={() => navigate(item.href)}
                >
                  <div className="flex items-center gap-3">
                    <div className="h-10 w-10 rounded-xl bg-buddy-green/10 flex items-center justify-center shrink-0">
                      {item.kind === 'booking' ? (
                        <Video size={18} className="text-buddy-green" />
                      ) : (
                        <Dumbbell size={18} className="text-buddy-green" />
                      )}
                    </div>
                    <div className="min-w-0 flex-1">
                      <div className="flex flex-wrap items-center gap-2">
                        <p className="text-sm font-semibold truncate">{item.title}</p>
                        <Badge variant={item.kind === 'booking' ? 'electric' : 'green'} label={item.kind === 'booking' ? 'Booking' : 'Gym'} size="sm" />
                      </div>
                      <p className="text-[11px] text-buddy-text-secondary mt-0.5 flex items-center gap-1.5 flex-wrap">
                        <Clock size={11} /> {timeLabel(item.when)}
                        <span>·</span>
                        <MapPin size={11} /> {item.subtitle}
                        {item.meta && (
                          <>
                            <span>·</span>
                            <span className="capitalize">{item.meta}</span>
                          </>
                        )}
                      </p>
                    </div>
                    <ChevronRight size={16} className="text-buddy-text-secondary shrink-0" />
                  </div>
                </Card>
              ))}
            </section>
          ))}
        </div>
      )}

      <section className="space-y-2">
        <div className="flex items-center justify-between px-1">
          <h2 className="text-xs font-semibold uppercase tracking-wider text-buddy-text-secondary">
            Your plans
          </h2>
          <span className="text-[11px] text-buddy-text-secondary">{ownedCount} owned</span>
        </div>
        {ownedCount === 0 ? (
          <Card className="p-4">
            <p className="text-sm text-buddy-text-secondary">
              Programmes and meal plans you buy will stay here, ready to follow.
            </p>
            <Link to="/marketplace" className="text-xs font-medium text-buddy-green hover:underline mt-2 inline-block">
              Browse the marketplace
            </Link>
          </Card>
        ) : (
          <div className="space-y-2">
            {programmes.map((programme) => (
              <Card
                key={programme.id}
                className="p-3 cursor-pointer hover:border-buddy-green/40 transition-colors"
                onClick={() => navigate(`/marketplace/programmes/${programme.id}`)}
              >
                <div className="flex items-center gap-3">
                  <BookOpen size={17} className="text-buddy-green shrink-0" />
                  <div className="min-w-0 flex-1">
                    <p className="text-sm font-semibold truncate">{programme.title}</p>
                    <p className="text-[11px] text-buddy-text-secondary">
                      Programme · {programme.duration_weeks} weeks
                    </p>
                  </div>
                  <ChevronRight size={16} className="text-buddy-text-secondary shrink-0" />
                </div>
              </Card>
            ))}
            {mealPlans.map((plan) => (
              <Card
                key={plan.id}
                className="p-3 cursor-pointer hover:border-buddy-green/40 transition-colors"
                onClick={() => navigate(`/marketplace/meal-plans/${plan.id}`)}
              >
                <div className="flex items-center gap-3">
                  <Salad size={17} className="text-buddy-green shrink-0" />
                  <div className="min-w-0 flex-1">
                    <p className="text-sm font-semibold truncate">{plan.title}</p>
                    <p className="text-[11px] text-buddy-text-secondary">
                      Meal plan · {plan.duration_weeks} weeks
                    </p>
                  </div>
                  <ChevronRight size={16} className="text-buddy-text-secondary shrink-0" />
                </div>
              </Card>
            ))}
          </div>
        )}
      </section>
    </div>
  );
}
