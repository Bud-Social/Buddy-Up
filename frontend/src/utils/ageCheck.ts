export function calculateAge(dob: Date): number {
  const today = new Date();
  let age = today.getFullYear() - dob.getFullYear();
  const m = today.getMonth() - dob.getMonth();
  if (m < 0 || (m === 0 && today.getDate() < dob.getDate())) age--;
  return age;
}

export function isUserAdult(dob: Date): boolean {
  return calculateAge(dob) >= 18;
}

export function isUser16Plus(dob: Date): boolean {
  return calculateAge(dob) >= 16;
}

export type ContentRating = 'general' | 'mature';

// Countries where the local law sets the mature-content floor at 16.
// Empty by default — the platform defaults to 18+ everywhere unless legal
// review confirms a lower threshold for a specific country.
export const MATURE_MIN_AGE_16_COUNTRIES = new Set<string>();

export const MATURE_DEFAULT_MIN_AGE = 18;

export function matureContentMinAge(country?: string | null): number {
  const normalized = (country || '').trim().toLowerCase();
  if (MATURE_MIN_AGE_16_COUNTRIES.has(normalized)) return 16;
  return MATURE_DEFAULT_MIN_AGE;
}

export function canAccessMatureContent(age: number | null | undefined, country?: string | null): boolean {
  if (age == null) return false;
  return age >= matureContentMinAge(country);
}
