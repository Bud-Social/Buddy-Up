/**
 * Normalised media pages for post rendering (PostCard carousel, Bud Press
 * photo mode). Prefers structured post.media and falls back to the legacy
 * media_urls list with extension-based type detection.
 */
import type { PostMedia } from '@/types';

export type MediaPageType = 'image' | 'video' | 'audio' | 'document';

export interface MediaPage {
  url: string;
  type: MediaPageType;
  poster_url?: string | null;
  alt_text?: string | null;
  duration_ms?: number | null;
  trim_start_ms?: number | null;
  trim_end_ms?: number | null;
  sound_id?: string | null;
  sound_volume?: number | null;
}

const VIDEO_EXT = /\.(mp4|mov|webm|m4v|mpeg|mkv)(\?|$)/i;
const AUDIO_EXT = /\.(mp3|wav|ogg|m4a|aac)(\?|$)/i;
const DOCUMENT_EXT = /\.(pdf|doc|docx|xls|xlsx|ppt|pptx|txt|md|csv)(\?|$)/i;

export function detectUrlType(url: string): MediaPageType {
  if (VIDEO_EXT.test(url)) return 'video';
  if (AUDIO_EXT.test(url)) return 'audio';
  if (DOCUMENT_EXT.test(url)) return 'document';
  return 'image';
}

function pageFromMedia(m: PostMedia): MediaPage {
  return {
    url: m.url,
    type: m.media_type === 'video' ? 'video' : 'image',
    poster_url: m.poster_url ?? null,
    alt_text: m.alt_text ?? null,
    duration_ms: m.duration_ms ?? null,
    trim_start_ms: m.trim_start_ms ?? null,
    trim_end_ms: m.trim_end_ms ?? null,
    sound_id: m.sound_id ?? null,
    sound_volume: m.sound_volume ?? null,
  };
}

/** Minimal post slice needed to derive pages (works for repost originals too). */
interface PostMediaSlice {
  media?: PostMedia[] | null;
  media_urls?: string[] | null;
}

export function mediaPagesFromPost(post: PostMediaSlice): MediaPage[] {
  if (post.media && post.media.length > 0) return post.media.map(pageFromMedia);
  return (post.media_urls || []).map((url) => ({ url, type: detectUrlType(url) }));
}

/**
 * Bud Press photo mode: multi-item posts and any post containing a
 * photo are swiped as a carousel instead of played as a single video.
 */
export function postIsPhotoMode(pages: MediaPage[]): boolean {
  return pages.length > 1 || pages.some((p) => p.type === 'image');
}

export function firstVideoPage(pages: MediaPage[]): MediaPage | null {
  return pages.find((p) => p.type === 'video') ?? null;
}
