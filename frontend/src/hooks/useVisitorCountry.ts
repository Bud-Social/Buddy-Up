import { useMemo } from 'react';

/**
 * Best-effort two-letter country code of the current visitor.
 *
 * VITE_USER_COUNTRY can be injected at build time (e.g. a CI step that
 * bakes in the edge's geo header) and always wins; otherwise we infer the
 * country from the visitor's browser locale (e.g. en-KE → "KE") via Intl.
 * Returns undefined when neither is conclusive — callers must treat that
 * as "unknown" and let the user pick, never as a specific country.
 */
export function useVisitorCountry(): string | undefined {
  return useMemo(() => {
    const fromEnv = import.meta.env.VITE_USER_COUNTRY;
    if (fromEnv && /^[A-Z]{2}$/.test(fromEnv)) return fromEnv;

    if (typeof navigator !== 'undefined') {
      const locales = [
        ...(navigator.languages ?? []),
        navigator.language,
      ].filter(Boolean) as string[];
      try {
        const dn = new Intl.DisplayNames(['en'], { type: 'region' });
        for (const tag of locales) {
          const m = tag.match(/-([A-Z]{2})\b/);
          if (m) {
            // Round-trip through DisplayNames: 'en-496' or junk after the
            // dash would otherwise be echoed back verbatim.
            const name = dn.of(m[1]);
            if (name && name.toUpperCase() !== m[1].toUpperCase()) return m[1];
          }
        }
      } catch {
        /* Intl.DisplayNames unavailable — fall through to undefined */
      }
    }
    return undefined;
  }, []);
}