/**
 * Client-side profanity masking for post bodies (Settings → Content).
 * Device-level preference: persisted in localStorage, never sent to the API.
 */
export const PROFANITY_FILTER_KEY = 'bu_profanity_filter';

const PROFANITY_WORDS = [
  'arse', 'arsehole', 'ass', 'asshole', 'bastard', 'bitch', 'bollocks',
  'bullshit', 'crap', 'cunt', 'damn', 'dick', 'dickhead', 'fuck', 'fucker',
  'goddamn', 'hell', 'motherfucker', 'piss', 'prick', 'pussy', 'shit',
  'slut', 'twat', 'wanker', 'whore',
] as const;

function escapeRegExp(word: string): string {
  return word.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

const WORD_PATTERNS = PROFANITY_WORDS.map(
  (w) => new RegExp(`\\b${escapeRegExp(w)}\\b`, 'gi'),
);

/** Pure: mask each profanity, keeping the first letter and masking the rest
 * with asterisks ("hell" → "h***"). Non-matching text is returned unchanged. */
export function maskProfanity(text: string): string {
  if (!text) return text;
  let masked = text;
  for (const pattern of WORD_PATTERNS) {
    masked = masked.replace(pattern, (match) => {
      if (match.length <= 1) return '*'.repeat(match.length);
      return match[0] + '*'.repeat(match.length - 1);
    });
  }
  return masked;
}

export function isProfanityFilterEnabled(): boolean {
  try {
    return window.localStorage.getItem(PROFANITY_FILTER_KEY) !== 'off';
  } catch {
    return true;
  }
}

export function setProfanityFilterEnabled(enabled: boolean): void {
  try {
    window.localStorage.setItem(PROFANITY_FILTER_KEY, enabled ? 'on' : 'off');
  } catch {
    // Storage unavailable — preference simply won't persist.
  }
}
