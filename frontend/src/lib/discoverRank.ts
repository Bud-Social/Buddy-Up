/**
 * Category-specific Discover ranking (client-side affinity layer).
 *
 * People already come pre-ranked from the AI embeddings recommender.
 * Gyms/lives/topics/communities arrive in global order (members, viewers,
 * counts), so we blend in a lightweight interest-affinity score from the
 * viewer's own onboarding preferences. Stable: ties keep server order.
 */

export interface InterestPrefs {
  primary_goal?: string[];
  preferred_workouts?: string[];
  custom_interests?: string;
}

function tokens(prefs: InterestPrefs | null | undefined): Set<string> {
  const out = new Set<string>();
  if (!prefs) return out;
  const add = (s: string) =>
    s.toLowerCase().split(/[^a-z0-9]+/).filter((w) => w.length > 2).forEach((w) => out.add(w));
  (prefs.primary_goal || []).forEach(add);
  (prefs.preferred_workouts || []).forEach(add);
  if (prefs.custom_interests) add(prefs.custom_interests);
  // Alias gym->weights style pairs both ways for matching.
  if (out.has('gym')) out.add('weights');
  if (out.has('weights')) out.add('gym');
  if (out.has('hike')) out.add('hiking');
  if (out.has('hiking')) out.add('hike');
  return out;
}

export function affinityScore(text: string, prefs: InterestPrefs | null | undefined): number {
  const toks = tokens(prefs);
  if (toks.size === 0) return 0;
  const words = text.toLowerCase().split(/[^a-z0-9]+/).filter((w) => w.length > 2);
  let score = 0;
  for (const w of words) {
    if (toks.has(w)) score += 1;
  }
  return score;
}

/** Stable affinity re-rank: higher overlap first, server order on ties. */
export function rankByAffinity<T>(items: T[], textOf: (item: T) => string, prefs: InterestPrefs | null | undefined): T[] {
  if (!prefs) return items;
  return items
    .map((item, index) => ({ item, index, score: affinityScore(textOf(item), prefs) }))
    .sort((a, b) => b.score - a.score || a.index - b.index)
    .map((r) => r.item);
}
