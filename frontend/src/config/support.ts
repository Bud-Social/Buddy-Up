export interface SupportLinks {
  fundraiserUrl: string;
  pledgeFormUrl: string;
  gymSuiteFormUrl: string;
  trainerIntakeFormUrl: string;
}

type EnvRecord = Record<string, string | undefined>;

function readUrl(env: EnvRecord, key: string): string {
  return (env[key] ?? '').trim();
}

export function getSupportLinks(env: EnvRecord = (import.meta.env as unknown as EnvRecord)): SupportLinks {
  return {
    fundraiserUrl: readUrl(env, 'VITE_FUNDRAISER_URL'),
    pledgeFormUrl: readUrl(env, 'VITE_PLEDGE_FORM_URL'),
    gymSuiteFormUrl: readUrl(env, 'VITE_GYM_SUITE_FORM_URL'),
    trainerIntakeFormUrl: readUrl(env, 'VITE_TRAINER_INTAKE_FORM_URL'),
  };
}

export const SUPPORT_LINKS = getSupportLinks();
export const FUNDRAISER_URL = SUPPORT_LINKS.fundraiserUrl;
export const PLEDGE_FORM_URL = SUPPORT_LINKS.pledgeFormUrl;
export const GYM_SUITE_FORM_URL = SUPPORT_LINKS.gymSuiteFormUrl;
export const TRAINER_INTAKE_FORM_URL = SUPPORT_LINKS.trainerIntakeFormUrl;

// NOTE: the Google Sheets webhook is intentionally NOT exposed to the client.
// Waitlist signups are relayed to the sheet server-side by the backend
// (apps.waitlist.sheets) using its own GOOGLE_SHEETS_WEBHOOK_URL env var.

export function isSupportConfigured(links: SupportLinks = SUPPORT_LINKS): boolean {
  return Boolean(links.fundraiserUrl || links.pledgeFormUrl);
}

export function isGymSuiteConfigured(links: SupportLinks = SUPPORT_LINKS): boolean {
  return Boolean(links.gymSuiteFormUrl);
}

export function isTrainerIntakeConfigured(links: SupportLinks = SUPPORT_LINKS): boolean {
  return Boolean(links.trainerIntakeFormUrl);
}
