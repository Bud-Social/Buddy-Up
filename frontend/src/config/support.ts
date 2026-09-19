export const FUNDRAISER_URL = (import.meta.env.VITE_FUNDRAISER_URL as string | undefined) ?? '';
export const PLEDGE_FORM_URL = (import.meta.env.VITE_PLEDGE_FORM_URL as string | undefined) ?? '';

// Set unprefixed (GOOGLE_SHEETS_WEBHOOK_URL) on Vercel; VITE_-prefixed name is
// the local/dev fallback. Both are statically inlined at build time.
export const SHEETS_WEBHOOK_URL =
  (import.meta.env.GOOGLE_SHEETS_WEBHOOK_URL as string | undefined)
  || (import.meta.env.VITE_GOOGLE_SHEETS_WEBHOOK_URL as string | undefined)
  || '';

export function isSupportConfigured(): boolean {
  return Boolean(FUNDRAISER_URL || PLEDGE_FORM_URL);
}
