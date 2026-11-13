import { useCallback, useEffect, useState } from 'react';
import {
  CalendarPlus, CheckCircle2, Star, Loader2, Clock, MapPin, X,
} from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { useToast } from '@/components/ui/Toast';
import { profilesApi, type BuddyMeetup } from '@/api/profiles';

interface Props {
  /** The other person — the meetup is with them. */
  username: string;
  displayName?: string;
}

function formatWhen(iso: string | null): string {
  if (!iso) return '';
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return '';
  return d.toLocaleString(undefined, {
    weekday: 'short', day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit',
  });
}

/**
 * Meetups with a buddy.
 *
 * Plan one, mark it as met when it has happened, and rate it after. Each
 * side rates on their own, and the rating reaches the other person a few
 * days later — so what is shown here is always something you can stand
 * behind.
 */
export function BuddyMeetups({ username, displayName }: Props) {
  const { toast } = useToast();
  const [meetups, setMeetups] = useState<BuddyMeetup[]>([]);
  const [loading, setLoading] = useState(true);
  const [planning, setPlanning] = useState(false);
  const [place, setPlace] = useState('');
  const [when, setWhen] = useState('');
  const [note, setNote] = useState('');
  const [busy, setBusy] = useState<string | null>(null);
  // The meetup being rated, and the rating being written.
  const [ratingId, setRatingId] = useState<string | null>(null);
  const [score, setScore] = useState(5);
  const [ratingNote, setRatingNote] = useState('');

  const load = useCallback(async () => {
    try {
      const all = await profilesApi.listMeetups();
      setMeetups(all.filter((m) => m.partner_username === username));
    } catch {
      setMeetups([]);
    } finally {
      setLoading(false);
    }
  }, [username]);

  useEffect(() => { load(); }, [load]);

  const plan = async () => {
    setBusy('plan');
    try {
      await profilesApi.createMeetup({
        username,
        place: place.trim(),
        note: note.trim(),
        scheduled_at: when ? new Date(when).toISOString() : null,
      });
      setPlace('');
      setNote('');
      setWhen('');
      setPlanning(false);
      toast('success', 'Meetup planned.');
      await load();
    } catch (err) {
      const msg = (err as { response?: { data?: { message?: string } } })?.response?.data?.message;
      toast('error', msg || 'Could not plan the meetup.');
    } finally {
      setBusy(null);
    }
  };

  const markMet = async (id: string) => {
    setBusy(id);
    try {
      await profilesApi.markMeetup(id, 'met');
      toast('success', 'Marked as met. Say how it went when you are ready.');
      await load();
    } catch (err) {
      const msg = (err as { response?: { data?: { message?: string } } })?.response?.data?.message;
      toast('error', msg || 'Could not update the meetup.');
    } finally {
      setBusy(null);
    }
  };

  const submitRating = async (id: string) => {
    setBusy(id);
    try {
      await profilesApi.rateMeetup(id, score, ratingNote.trim());
      setRatingId(null);
      setRatingNote('');
      toast('success', 'Thanks — your rating is recorded.');
      await load();
    } catch (err) {
      const msg = (err as { response?: { data?: { message?: string } } })?.response?.data?.message;
      toast('error', msg || 'Could not save the rating.');
    } finally {
      setBusy(null);
    }
  };

  return (
    <Card className="p-4 space-y-3">
      <div className="flex items-center justify-between">
        <h3 className="font-semibold text-buddy-text-primary flex items-center gap-2">
          <CalendarPlus size={16} className="text-buddy-green" /> Meetups
        </h3>
        <Button
          size="sm"
          variant={planning ? 'ghost' : 'outline'}
          onClick={() => setPlanning((v) => !v)}
          aria-expanded={planning}
        >
          {planning ? <X size={14} /> : <CalendarPlus size={14} />}
          {planning ? 'Cancel' : 'Plan one'}
        </Button>
      </div>

      {planning && (
        <div className="space-y-2 rounded-xl border border-buddy-border bg-buddy-surface/50 p-3">
          <label className="block text-xs text-buddy-text-secondary">
            Where
            <input
              type="text"
              value={place}
              onChange={(e) => setPlace(e.target.value)}
              placeholder="Karen, the track, the coffee place…"
              maxLength={140}
              className="mt-1 w-full bg-buddy-surface-raised rounded-xl px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-buddy-green/40"
            />
          </label>
          <label className="block text-xs text-buddy-text-secondary">
            When (optional)
            <input
              type="datetime-local"
              value={when}
              onChange={(e) => setWhen(e.target.value)}
              className="mt-1 w-full bg-buddy-surface-raised rounded-xl px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-buddy-green/40"
            />
          </label>
          <label className="block text-xs text-buddy-text-secondary">
            Note (optional)
            <input
              type="text"
              value={note}
              onChange={(e) => setNote(e.target.value)}
              placeholder="Saturday morning run"
              maxLength={280}
              className="mt-1 w-full bg-buddy-surface-raised rounded-xl px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-buddy-green/40"
            />
          </label>
          <Button
            size="sm"
            className="w-full"
            onClick={plan}
            disabled={busy === 'plan' || !place.trim()}
          >
            {busy === 'plan' && <Loader2 size={14} className="animate-spin mr-1.5" />}
            Plan with {displayName || username}
          </Button>
        </div>
      )}

      {loading ? (
        <p className="text-sm text-buddy-text-secondary">Loading meetups…</p>
      ) : meetups.length === 0 ? (
        <p className="text-sm text-buddy-text-secondary">
          No meetups yet. Plan one when you have agreed to meet up.
        </p>
      ) : (
        <ul className="space-y-2">
          {meetups.map((m) => (
            <li key={m.id} className="rounded-xl border border-buddy-border bg-buddy-surface/50 p-3 space-y-2">
              <div className="flex items-start justify-between gap-2">
                <div className="min-w-0">
                  <p className="text-sm font-medium text-buddy-text-primary flex items-center gap-1.5">
                    {m.place || 'Meetup'}
                    {m.state === 'met' && (
                      <span className="inline-flex items-center gap-1 text-[10px] px-1.5 py-0.5 rounded-full bg-buddy-green/15 text-buddy-green font-semibold">
                        <CheckCircle2 size={10} /> Met
                      </span>
                    )}
                    {m.state === 'cancelled' && (
                      <span className="text-[10px] px-1.5 py-0.5 rounded-full bg-buddy-surface-raised text-buddy-text-secondary">
                        Cancelled
                      </span>
                    )}
                  </p>
                  {m.scheduled_at && (
                    <p className="text-xs text-buddy-text-secondary flex items-center gap-1 mt-0.5">
                      <Clock size={11} /> {formatWhen(m.scheduled_at)}
                    </p>
                  )}
                  {m.place && (
                    <p className="text-xs text-buddy-text-secondary flex items-center gap-1 mt-0.5">
                      <MapPin size={11} /> {m.place}
                    </p>
                  )}
                  {m.note && (
                    <p className="text-xs text-buddy-text-secondary mt-1">{m.note}</p>
                  )}
                </div>
              </div>

              {/* How it went. */}
              {m.state === 'met' && (
                <div className="space-y-1.5">
                  {m.average_score != null && (
                    <p className="text-xs text-buddy-text-primary flex items-center gap-1.5">
                      <Star size={12} className="text-buddy-gold fill-buddy-gold" />
                      {m.average_score}
                      <span className="text-buddy-text-secondary">
                        ({m.rating_count} rating{m.rating_count === 1 ? '' : 's'})
                      </span>
                    </p>
                  )}
                  {m.ratings.map((r) => (
                    <p key={r.id} className="text-xs text-buddy-text-secondary">
                      {r.pending ? (
                        <span className="italic">
                          @{r.rater_username} has rated it — you will see it in a few days.
                        </span>
                      ) : (
                        <>
                          <span className="text-buddy-gold">
                            {'★'.repeat(r.score ?? 0)}
                          </span>{' '}
                          @{r.rater_username}
                          {r.note ? ` — ${r.note}` : ''}
                        </>
                      )}
                    </p>
                  ))}

                  {m.can_rate && ratingId !== m.id && (
                    <Button size="sm" variant="outline" onClick={() => { setRatingId(m.id); setScore(5); }}>
                      <Star size={14} /> Rate it
                    </Button>
                  )}

                  {ratingId === m.id && (
                    <div className="space-y-2 rounded-lg border border-buddy-border bg-buddy-surface p-3">
                      <div className="flex items-center gap-1">
                        {[1, 2, 3, 4, 5].map((n) => (
                          <button
                            key={n}
                            type="button"
                            onClick={() => setScore(n)}
                            aria-label={`${n} star${n === 1 ? '' : 's'}`}
                            aria-pressed={score === n}
                            className="p-1"
                          >
                            <Star
                              size={22}
                              className={n <= score ? 'text-buddy-gold fill-buddy-gold' : 'text-buddy-text-secondary/40'}
                            />
                          </button>
                        ))}
                        <span className="ml-2 text-xs text-buddy-text-secondary">{score} of 5</span>
                      </div>
                      <input
                        type="text"
                        value={ratingNote}
                        onChange={(e) => setRatingNote(e.target.value)}
                        placeholder="How did it go? (optional)"
                        maxLength={280}
                        className="w-full bg-buddy-surface-raised rounded-lg px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-buddy-green/40"
                      />
                      <p className="text-[11px] text-buddy-text-secondary">
                        Your rating reaches {displayName || username} in a few days.
                      </p>
                      <div className="flex gap-2">
                        <Button size="sm" className="flex-1" onClick={() => submitRating(m.id)} disabled={busy === m.id}>
                          {busy === m.id && <Loader2 size={14} className="animate-spin mr-1.5" />}
                          Save rating
                        </Button>
                        <Button size="sm" variant="ghost" onClick={() => setRatingId(null)}>
                          Cancel
                        </Button>
                      </div>
                    </div>
                  )}

                  {m.my_rating && !m.can_rate && (
                    <p className="text-xs text-buddy-text-secondary">
                      Your rating: <span className="text-buddy-gold">{'★'.repeat(m.my_rating.score ?? 0)}</span>
                      {m.my_rating.note ? ` — ${m.my_rating.note}` : ''}
                    </p>
                  )}
                </div>
              )}

              {m.state === 'planned' && (
                <Button size="sm" variant="outline" onClick={() => markMet(m.id)} disabled={busy === m.id}>
                  {busy === m.id ? <Loader2 size={14} className="animate-spin mr-1.5" /> : <CheckCircle2 size={14} />}
                  Mark as met
                </Button>
              )}
            </li>
          ))}
        </ul>
      )}
    </Card>
  );
}
