import { useCallback, useEffect, useMemo, useState } from 'react';
import { Award, CalendarClock, Gavel, Loader, RefreshCw, ShieldAlert, Trash2 } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { useToast } from '@/components/ui/Toast';
import { notificationsApi } from '@/api/notifications';
import { moderationApi, type Commendation, type ModerationAppeal } from '@/api/moderation';
import { buildStanding, endDateLabel, formatTimestamp, type StandingEntry } from './standing';

/**
 * "Your account standing", appeals and commendations.
 *
 * This panel exists because of a gap that made moderation decorative: the API
 * had a complete appeal path — create, review, and on approval a real reversal
 * through the same service that applied the ban — and **no UI caller for the
 * create endpoint at all**. A user who was suspended had no way to contest it
 * except email, which is not a record anybody keeps.
 *
 * Where the facts come from:
 *
 * - **Standing** is read out of the user's own notification feed, which carries
 *   the `moderation_action_id` the appeal endpoint needs. See `./standing.ts`
 *   for why that is the only user-readable surface that exists.
 * - **Appeals** are `GET /moderation/appeals/`, which the server already scopes
 *   to the caller, and `POST /moderation/appeals/`, which refuses an action
 *   that was not applied to this account.
 * - **Commendations** are the other half of moderation, and a user can remove
 *   one from their own view with a single tap.
 *
 * Each of the three loads independently: a failure to load commendations must
 * not hide the appeal form, which is the urgent half of this panel.
 */

function asString(value: unknown): string | null {
  return typeof value === 'string' && value.trim() ? value.trim() : null;
}

export default function AccountSafety() {
  const { toast } = useToast();
  const [standing, setStanding] = useState<StandingEntry[]>([]);
  const [appeals, setAppeals] = useState<ModerationAppeal[]>([]);
  const [commendations, setCommendations] = useState<Commendation[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState('');
  const [commendationError, setCommendationError] = useState('');

  // Appeal composition.
  const [appealFor, setAppealFor] = useState<string | null>(null);
  const [appealReason, setAppealReason] = useState('');
  const [appealBusy, setAppealBusy] = useState(false);
  const [appealError, setAppealError] = useState('');

  const [deleting, setDeleting] = useState<string | null>(null);

  const load = useCallback(async (showRefreshing = false) => {
    if (showRefreshing) setRefreshing(true);
    else setLoading(true);
    setError('');
    setCommendationError('');
    // Each of these degrades on its own: a failure to load commendations must
    // not hide the appeal form, which is the urgent half of this panel.
    const [notes, appealRes, commendRes] = await Promise.allSettled([
      notificationsApi.getList(),
      moderationApi.getAppeals(),
      moderationApi.getCommendations(),
    ]);
    if (notes.status === 'fulfilled') {
      setStanding(buildStanding(notes.value?.data || []));
    } else {
      setStanding([]);
    }
    if (appealRes.status === 'fulfilled') {
      setAppeals(appealRes.value?.data || []);
    } else {
      setError('Could not load your appeals.');
    }
    if (commendRes.status === 'fulfilled') {
      setCommendations(commendRes.value?.data || []);
    } else {
      setCommendationError('Could not load your commendations.');
    }
    setLoading(false);
    setRefreshing(false);
  }, []);

  useEffect(() => { load(); }, [load]);

  const appealable = useMemo(() => standing.filter((e) => !e.reversed), [standing]);
  const appealedActionIds = useMemo(
    () => new Set(appeals.map((a) => asString(a.action)).filter((id): id is string => Boolean(id))),
    [appeals],
  );
  const stillAppealable = useMemo(
    () => appealable.filter((e) => !appealedActionIds.has(e.actionId)),
    [appealable, appealedActionIds],
  );

  const submitAppeal = useCallback(async () => {
    if (!appealFor || !appealReason.trim() || appealBusy) return;
    setAppealBusy(true);
    setAppealError('');
    try {
      await moderationApi.createAppeal({ action: appealFor, reason: appealReason.trim() });
      toast('success', 'Appeal submitted. A moderator will review it independently.');
      setAppealFor(null);
      setAppealReason('');
      load(true);
    } catch {
      // The API's own refusal — most often "You may only appeal actions applied
      // to your account" — is more useful than anything we could invent.
      setAppealError(
        'Your appeal could not be submitted. It may already exist for this action, or the action may not be one against your account.',
      );
    } finally {
      setAppealBusy(false);
    }
  }, [appealFor, appealReason, appealBusy, toast, load]);

  const removeCommendation = useCallback(async (row: Commendation) => {
    const id = row.id;
    if (!id) return;
    setDeleting(id);
    setCommendationError('');
    try {
      await moderationApi.deleteCommendation(id);
      setCommendations((list) => list.filter((c) => c.id !== id));
      toast('success', 'Removed from your profile.');
    } catch {
      setCommendationError('Could not remove that commendation.');
    } finally {
      setDeleting(null);
    }
  }, [toast]);

  if (loading) {
    return (
      <Card className="p-8 text-center">
        <Loader size={24} className="animate-spin text-buddy-text-secondary mx-auto" />
      </Card>
    );
  }

  return (
    <div className="space-y-6">
      {/* ---------------------------------------------------------- Standing */}
      <section>
        <div className="flex items-center justify-between gap-3 mb-2">
          <h3 className="text-sm font-semibold flex items-center gap-1.5">
            <ShieldAlert size={15} /> Moderation actions on your account
          </h3>
          <Button size="sm" variant="ghost" onClick={() => load(true)} disabled={refreshing} aria-label="Refresh moderation history">
            <RefreshCw size={14} className={`mr-1 ${refreshing ? 'animate-spin' : ''}`} /> Refresh
          </Button>
        </div>

        {appealable.length === 0 ? (
          <Card className="p-5 text-center">
            <ShieldAlert size={28} className="mx-auto text-buddy-green/40 mb-2" />
            <p className="text-sm text-buddy-text-secondary">No moderation action has been taken on your account.</p>
          </Card>
        ) : (
          <div className="space-y-2">
            {appealable.map((entry) => {
              const alreadyAppealed = appealedActionIds.has(entry.actionId);
              const open = appealFor === entry.actionId;
              return (
                <Card key={entry.actionId} className="p-4">
                  <p className="text-sm font-semibold break-words">{entry.title}</p>
                  {entry.reason && (
                    <p className="text-sm mt-1.5 break-words text-buddy-text-secondary">
                      <span className="text-buddy-text-primary font-medium">Reason: </span>{entry.reason}
                    </p>
                  )}
                  <p className="text-[11px] text-buddy-text-secondary mt-1.5 flex items-center gap-1">
                    <CalendarClock size={11} /> {endDateLabel(entry)} · {formatTimestamp(entry.createdAt)}
                  </p>

                  <div className="mt-3 flex items-center gap-2 flex-wrap">
                    {alreadyAppealed ? (
                      <p className="text-xs text-buddy-text-secondary">
                        You have already appealed this. You will be notified of the outcome.
                      </p>
                    ) : open ? null : (
                      <Button size="sm" variant="outline" onClick={() => { setAppealFor(entry.actionId); setAppealError(''); }}>
                        <Gavel size={14} className="mr-1" /> Appeal this
                      </Button>
                    )}
                  </div>

                  {open && (
                    <div className="mt-3 pt-3 border-t border-buddy-surface">
                      <label className="block text-xs text-buddy-text-secondary mb-1.5">
                        Why should this action be reversed? <span className="text-buddy-red">*</span>
                      </label>
                      <textarea
                        autoFocus
                        rows={4}
                        value={appealReason}
                        onChange={(e) => setAppealReason(e.target.value)}
                        placeholder="Explain what happened, or what the moderator may have missed. This is read by a reviewer who did not issue the original action."
                        aria-label="Appeal reason"
                        className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
                      />
                      <div className="flex items-center gap-2 mt-2">
                        <Button size="sm" disabled={!appealReason.trim()} isLoading={appealBusy} onClick={submitAppeal}>
                          Submit appeal
                        </Button>
                        <Button size="sm" variant="ghost" onClick={() => { setAppealFor(null); setAppealError(''); }}>
                          Cancel
                        </Button>
                      </div>
                      {appealError && <p className="text-[11px] text-buddy-red mt-2">{appealError}</p>}
                    </div>
                  )}
                </Card>
              );
            })}
          </div>
        )}

        {standing.some((e) => e.reversed) && (
          <Card className="p-3 mt-2 bg-buddy-surface-raised">
            <p className="text-xs text-buddy-text-secondary">
              {standing.filter((e) => e.reversed).length} earlier action(s) were reversed and no longer apply.
            </p>
          </Card>
        )}
      </section>

      {/* ----------------------------------------------------------- Appeals */}
      <section>
        <h3 className="text-sm font-semibold flex items-center gap-1.5 mb-2">
          <Gavel size={15} /> Your appeals
        </h3>
        {error && <p className="text-xs text-buddy-red mb-2">{error}</p>}
        {appeals.length === 0 ? (
          <Card className="p-5 text-center">
            <p className="text-sm text-buddy-text-secondary">
              You have not appealed any action. An appeal is reviewed by someone other than the moderator
              who issued it.
            </p>
          </Card>
        ) : (
          <div className="space-y-2">
            {appeals.map((a) => (
              <Card key={a.id} className="p-4">
                <div className="flex flex-wrap items-center gap-2">
                  <span className="text-xs font-semibold capitalize">{a.status.replace(/_/g, ' ')}</span>
                  <span className="text-[11px] text-buddy-text-secondary">{formatTimestamp(a.created_at)}</span>
                </div>
                {a.reason && <p className="text-sm mt-1.5 break-words">{a.reason}</p>}
                {a.resolution_note && (
                  <p className="text-xs text-buddy-text-secondary mt-1.5 break-words">
                    <span className="font-medium">Decision: </span>{a.resolution_note}
                  </p>
                )}
                {a.reviewed_at && (
                  <p className="text-[11px] text-buddy-text-secondary mt-1">Reviewed {formatTimestamp(a.reviewed_at)}</p>
                )}
              </Card>
            ))}
          </div>
        )}
        {stillAppealable.length === 0 && appealable.length > 0 && appeals.length === 0 && (
          <p className="text-[11px] text-buddy-text-secondary mt-2">
            Every action on your account already has an appeal in flight.
          </p>
        )}
      </section>

      {/* ------------------------------------------------------ Commendations */}
      <section>
        <h3 className="text-sm font-semibold flex items-center gap-1.5 mb-2">
          <Award size={15} /> Commendations
        </h3>
        {commendationError && <p className="text-xs text-buddy-red mb-2">{commendationError}</p>}
        {commendations.length === 0 ? (
          <Card className="p-5 text-center">
            <Award size={28} className="mx-auto text-buddy-gold/40 mb-2" />
            <p className="text-sm text-buddy-text-secondary">
              No commendations yet. Staff record these when a member does something the platform wants to
              name.
            </p>
          </Card>
        ) : (
          <div className="space-y-2">
            {commendations.map((c) => (
              <Card key={c.id} className="p-3 flex items-start justify-between gap-3">
                <div className="min-w-0">
                  <p className="text-sm font-medium">{c.category_display || c.category}</p>
                  {c.message && <p className="text-xs text-buddy-text-secondary mt-0.5 break-words">{c.message}</p>}
                  {c.created_at && (
                    <p className="text-[11px] text-buddy-text-secondary mt-0.5">{formatTimestamp(c.created_at)}</p>
                  )}
                </div>
                <Button
                  size="sm"
                  variant="ghost"
                  isLoading={deleting === c.id}
                  onClick={() => removeCommendation(c)}
                  aria-label={`Remove commendation ${c.category_display || c.category}`}
                  className="flex-shrink-0"
                >
                  <Trash2 size={14} className="mr-1" /> Remove
                </Button>
              </Card>
            ))}
          </div>
        )}
      </section>
    </div>
  );
}
