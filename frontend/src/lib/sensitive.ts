import type { Post } from '@/types';

export type SensitiveKind = 'flagged' | 'mature' | 'nsfw' | 'toxic' | null;

const ALWAYS_SHOW_KEY = 'buddyup-sensitive-always-show';
const REVEALED_KEY = 'buddyup-sensitive-revealed';

function readJson(key: string): Record<string, boolean> {
  try {
    const raw = localStorage.getItem(key);
    if (!raw) return {};
    const data = JSON.parse(raw);
    return typeof data === 'object' && data !== null ? data : {};
  } catch {
    return {};
  }
}

export function getAlwaysShowSensitive(): boolean {
  try {
    return localStorage.getItem(ALWAYS_SHOW_KEY) === '1';
  } catch {
    return false;
  }
}

export function setAlwaysShowSensitive(value: boolean) {
  try {
    localStorage.setItem(ALWAYS_SHOW_KEY, value ? '1' : '0');
  } catch {}
}

export function isRevealed(postId: string): boolean {
  return !!readJson(REVEALED_KEY)[postId];
}

export function markRevealed(postId: string) {
  try {
    const map = readJson(REVEALED_KEY);
    map[postId] = true;
    // Cap growth: keep last 200 entries.
    const keys = Object.keys(map);
    if (keys.length > 200) {
      for (const k of keys.slice(0, keys.length - 200)) delete map[k];
    }
    localStorage.setItem(REVEALED_KEY, JSON.stringify(map));
  } catch {}
}

/** Best-effort reason from moderation_status / content_rating / ai_analysis. */
export function sensitiveKind(post: Pick<Post, 'moderation_status' | 'content_rating' | 'ai_analysis'>): SensitiveKind {
  if (post.moderation_status === 'flagged' || post.moderation_status === 'removed') return 'flagged';
  const analysis = (post.ai_analysis || {}) as Record<string, any>;
  const images = analysis.images as Array<{ gated?: boolean }> | undefined;
  if (post.content_rating === 'mature' || (Array.isArray(images) && images.some((i) => i?.gated))) return 'mature';
  const text = analysis.text as { label?: string } | undefined;
  if (typeof text?.label === 'string') {
    if (/nsfw/i.test(text.label)) return 'nsfw';
    if (/toxic/i.test(text.label)) return 'toxic';
  }
  return null;
}

export function isSensitive(post: Pick<Post, 'moderation_status' | 'content_rating' | 'ai_analysis'>): boolean {
  return sensitiveKind(post) !== null;
}

export function sensitiveLabel(kind: SensitiveKind): { title: string; detail: string } {
  switch (kind) {
    case 'flagged':
      return { title: 'Flagged by moderation', detail: 'Our systems flagged this for review. Tap to view anyway.' };
    case 'mature':
      return { title: 'Mature content (18+)', detail: 'Marked for adults only. Tap to view if you’re 18+.' };
    case 'nsfw':
      return { title: 'Sensitive media', detail: 'May contain nudity or sexual content. Tap to view.' };
    case 'toxic':
      return { title: 'Potentially offensive', detail: 'May contain harsh or offensive language. Tap to view.' };
    default:
      return { title: 'Sensitive content', detail: 'Tap to reveal.' };
  }
}
