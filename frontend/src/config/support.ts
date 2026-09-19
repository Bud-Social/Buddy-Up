export const FUNDRAISER_URL = (import.meta.env.VITE_FUNDRAISER_URL as string | undefined) ?? '';
export const PLEDGE_FORM_URL = (import.meta.env.VITE_PLEDGE_FORM_URL as string | undefined) ?? '';

export function isSupportConfigured(): boolean {
  return Boolean(FUNDRAISER_URL || PLEDGE_FORM_URL);
}
