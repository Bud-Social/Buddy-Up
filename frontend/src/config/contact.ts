/**
 * Central contact addresses (single source of truth — every mailto link in the
 * app should come from here so domain changes are a one-file edit).
 * Primary/global addresses live on buddyup.com; regional (Kenya) and
 * safety-reporting inboxes live on buddyup.co.ke.
 */
export const CONTACT_EMAILS = {
  /** General enquiries (About page, press-adjacent). */
  info: 'info@buddyup.com',
  /** Account & technical help (Settings → Help, accessibility). */
  support: 'support@buddyup.com',
  /** Help-centre quick contact (How-it-works / FAQ pages). */
  help: 'help@buddyup.co.ke',
  /** Abuse, safety & content reports (replaces the old safety@ inbox). */
  report: 'report@buddyup.co.ke',
  /** Sponsorships, partnerships & brand collaborations. */
  sponsor: 'sponsor@buddyup.com',
  /** Media, press & general contact form destination. */
  contact: 'contact@buddyup.co.ke',
  // Specialised compliance inboxes (kept distinct from the six above):
  privacy: 'privacy@buddyup.com',
  security: 'security@buddyup.com',
  legal: 'legal@buddyup.com',
  dpo: 'dpo@buddyup.com',
} as const;

export type ContactEmailKey = keyof typeof CONTACT_EMAILS;

/** Build a mailto: link, optionally with a pre-filled subject. */
export function mailtoLink(key: ContactEmailKey, subject?: string): string {
  const email = CONTACT_EMAILS[key];
  return subject ? `mailto:${email}?subject=${encodeURIComponent(subject)}` : `mailto:${email}`;
}
