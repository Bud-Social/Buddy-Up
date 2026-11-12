/**
 * A draft being reviewed in the composer.
 *
 * A countdown, activity or workout is prepared as a draft and handed to the
 * composer, where the user edits the caption, attaches media and chooses who
 * sees it before it is published.
 */

export type SharedDraftSourceKind = 'countdown' | 'activity' | 'workout';

export interface SharedDraftSource {
  kind: SharedDraftSourceKind;
  id: string;
  title: string;
  icon?: string;
  /** Countdown */
  count?: number;
  unit?: string;
  target_count?: number;
  elapsed_units?: number;
  countdown_type?: string;
  /** Activity */
  distance_km?: number;
  duration_minutes?: number;
  calories?: number | null;
  steps?: number | null;
  /** Workout */
  sets?: number | null;
  reps?: number | null;
  weight_kg?: number | null;
}

export interface SharedDraft {
  id: string;
  post_type: string;
  body: string;
  visibility: string;
  tags: string[];
  media_urls: string[];
  source_kind: string;
  source: SharedDraftSource | null;
}
