/**
 * Folding a user's moderation notifications into one row per action.
 *
 * A `.ts` module with no React import, for the same reason `pages/admin/format.ts`
 * is one: this is a pure transformation of API data, and keeping it out of the
 * component file satisfies `react-refresh/only-export-components` while leaving
 * it directly unit-testable.
 *
 * The input is the user's own notification feed, because that is the only
 * user-readable surface the platform has. `ModerationAction` is staff-only
 * (`IsAdminUser`), and `apps.moderation.services.notify_action_taken` writes
 * everything the appeal form needs into the notification metadata:
 * `moderation_action_id`, `reason`, `duration_days`, `suspended_until`,
 * `permanent` and `can_appeal`.
 */
import type { Notification } from '@/api/notifications';

/** Notification types that represent something a moderator did to the account. */
export const STANDING_NOTIFICATION_TYPES: ReadonlySet<string> = new Set([
  'moderation_warning',
  'moderation_content_removed',
  'moderation_suspension',
  'moderation_ban',
  'moderation_action_reversed',
]);

/** The subset that describes an action which is punitive and therefore appealable. */
export const PUNITIVE_NOTIFICATION_TYPES: ReadonlySet<string> = new Set([
  'moderation_warning',
  'moderation_content_removed',
  'moderation_suspension',
  'moderation_ban',
]);

export interface StandingEntry {
  /** The `ModerationAction` id. This is what `POST /appeals/` takes. */
  actionId: string;
  action: string;
  notificationType: string;
  title: string;
  reason: string;
  createdAt: string;
  /** ISO end of a temporary suspension, or null when there is no end date. */
  until: string | null;
  permanent: boolean;
  durationDays: number | null;
  /** True when a later notification reversed this action. */
  reversed: boolean;
}

function asString(value: unknown): string | null {
  return typeof value === 'string' && value.trim() ? value.trim() : null;
}

function asNumber(value: unknown): number | null {
  return typeof value === 'number' && Number.isFinite(value) ? value : null;
}

/**
 * One row per `moderation_action_id`, newest notification winning, with
 * reversal resolved across the whole feed.
 *
 * Two things this has to get right, both of which are user-facing mistakes
 * rather than crashes:
 *
 * - **Reversal.** A lifted ban must stop showing "your account has been banned"
 *   and must not offer an appeal button for an action that no longer exists.
 *   The reversal notice carries the *original* action's id under
 *   `original_action_id`, so it is collected in a first pass.
 * - **Reversals are not themselves listable.** A reversal is not something to
 *   appeal, so only punitive notification types survive the final filter.
 */
export function buildStanding(notifications: Notification[]): StandingEntry[] {
  const moderation = notifications.filter(
    (n) => STANDING_NOTIFICATION_TYPES.has(n.notification_type) && asString(n.metadata?.moderation_action_id),
  );
  const reversedIds = new Set(
    moderation
      .filter((n) => n.notification_type === 'moderation_action_reversed')
      .map((n) => asString(n.metadata?.original_action_id))
      .filter((id): id is string => Boolean(id)),
  );

  const byAction = new Map<string, StandingEntry>();
  for (const n of moderation) {
    const actionId = asString(n.metadata?.moderation_action_id);
    if (!actionId) continue;
    const isReversal = n.notification_type === 'moderation_action_reversed';
    const entry: StandingEntry = {
      actionId,
      action: asString(n.metadata?.action) || (isReversal ? 'action_reversed' : n.notification_type),
      notificationType: n.notification_type,
      title: n.title,
      reason: asString(n.metadata?.reason) || n.body || '',
      createdAt: n.created_at,
      until: asString(n.metadata?.suspended_until),
      permanent: n.metadata?.permanent === true,
      durationDays: asNumber(n.metadata?.duration_days),
      reversed: reversedIds.has(actionId),
    };
    const existing = byAction.get(actionId);
    // The feed is newest-first, so an existing row is the older one.
    if (!existing || existing.createdAt < entry.createdAt) byAction.set(actionId, entry);
  }
  return Array.from(byAction.values())
    .filter((e) => PUNITIVE_NOTIFICATION_TYPES.has(e.notificationType))
    .sort((a, b) => (a.createdAt < b.createdAt ? 1 : -1));
}

/** "Until 12 Mar 2026" / "Permanent" / "No end date recorded". */
export function endDateLabel(entry: StandingEntry): string {
  if (entry.reversed) return 'Reversed — this action no longer applies';
  if (entry.until) return `Until ${formatTimestamp(entry.until)}`;
  if (entry.permanent) return 'Permanent — there is no end date';
  if (entry.durationDays) return `${entry.durationDays} day term`;
  return 'No end date recorded';
}

/** Em dash for missing/invalid rather than "Invalid Date". */
export function formatTimestamp(value: string | null | undefined): string {
  if (!value) return '—';
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return value;
  return d.toLocaleString();
}
