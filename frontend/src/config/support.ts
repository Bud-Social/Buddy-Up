export const FUNDRAISER_URL = (import.meta.env.VITE_FUNDRAISER_URL as string | undefined) ?? '';
export const PLEDGE_FORM_URL = (import.meta.env.VITE_PLEDGE_FORM_URL as string | undefined) ?? '';

// NOTE: the Google Sheets webhook is intentionally NOT exposed to the client.
// Waitlist signups are relayed to the sheet server-side by the backend
// (apps.waitlist.sheets) using its own GOOGLE_SHEETS_WEBHOOK_URL env var.

export function isSupportConfigured(): boolean {
  return Boolean(FUNDRAISER_URL || PLEDGE_FORM_URL);
}
