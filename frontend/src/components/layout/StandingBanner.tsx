import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { CalendarClock, Gavel, ShieldAlert } from 'lucide-react';
import { notificationsApi } from '@/api/notifications';
import { buildStanding, endDateLabel, type StandingEntry } from '@/pages/settings/standing';

/**
 * Account-standing notice across the whole app.
 *
 * A suspension or ban that only exists on a Settings sub-page is a suspension a
 * user finds out about by failing to post. This banner puts the three facts
 * that matter — what a moderator did, why, and when it ends — in front of every
 * signed-in member who has one, and links straight to the appeal surface.
 *
 * It does **not** post the appeal itself. `POST /moderation/appeals/` requires
 * the `ModerationAction` id and a written reason, and it refuses an action that
 * was not applied to this account; the form in
 * `pages/settings/AccountSafety.tsx` already has all three. The banner's job is
 * to make sure that form is reachable in one tap from wherever the user is.
 *
 * Facts come from the user's own notification feed — see `./standing.ts` for
 * why that is the only user-readable surface that carries them. A failed load
 * renders nothing at all rather than an alarming empty state.
 */
export function StandingBanner() {
  const [entries, setEntries] = useState<StandingEntry[]>([]);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    let cancelled = false;
    notificationsApi
      .getList()
      .then((res) => {
        if (!cancelled) setEntries(buildStanding(res.data || []));
      })
      .catch(() => {
        if (!cancelled) setEntries([]);
      })
      .finally(() => {
        if (!cancelled) setLoaded(true);
      });
    return () => { cancelled = true; };
  }, []);

  // Reversed actions are history, not standing: they must stop showing and must
  // not offer an appeal for something that no longer exists.
  const active = useMemo(() => entries.filter((entry) => !entry.reversed), [entries]);
  const current = active[0];

  if (!loaded || !current) return null;

  return (
    <div
      role="status"
      data-testid="standing-banner"
      className="border-b border-buddy-orange/30 bg-buddy-orange/5 px-4 py-3"
    >
      <div className="mx-auto max-w-6xl flex flex-wrap items-start gap-3">
        <ShieldAlert size={18} className="text-buddy-orange mt-0.5 shrink-0" />
        <div className="min-w-0 flex-1">
          <p className="text-sm font-semibold text-buddy-text-primary">{current.title}</p>
          {current.reason && (
            <p className="text-xs text-buddy-text-secondary mt-0.5 break-words">
              <span className="font-medium text-buddy-text-primary">Reason: </span>{current.reason}
            </p>
          )}
          <p className="text-[11px] text-buddy-text-secondary mt-1 flex items-center gap-1">
            <CalendarClock size={11} /> {endDateLabel(current)}
          </p>
        </div>
        <Link
          to="/settings/help"
          className="inline-flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-lg border border-buddy-orange/40 text-buddy-orange hover:bg-buddy-orange/10 transition-colors flex-shrink-0"
        >
          <Gavel size={13} /> Appeal this
        </Link>
      </div>
    </div>
  );
}

export default StandingBanner;