import type { Post } from '@/types';
import { parseWorkoutMetrics, type WorkoutMetrics } from './workoutMetrics';

/**
 * Social share card: a 4:5 canvas with the post content inside a BuddyUp
 * post frame, a BuddyUp Fit watermark header, a bottom-left watermark, and
 * the post permalink embedded as PNG/XMP metadata (not printed on the card).
 *
 * Two outputs share one layout:
 *   - `createShareCard`       → PNG card (still image, photo or video poster)
 *   - `renderShareCardLayers` → chrome + overlay layers for a video card.
 *     The server composites the *whole* clip between those layers, so the
 *     exported video plays in full with its original audio track.
 *
 * Sharing the file through the native share sheet (WhatsApp Status,
 * Instagram Stories, AirDrop, …) keeps the branding intact when the post is
 * re-shared as an image or a clip. The link also travels in the share text
 * so apps that only read captions still get it.
 */

const CARD_WIDTH = 1080;
const CARD_HEIGHT = 1350;

/** Corner radius of the media block and the post frame. */
const MEDIA_RADIUS = 36;

const GREEN = '#22C55E';
const INK = '#0B0F0D';
const TEXT = '#F4F7F5';
const MUTED = '#9BA69F';

/** Media block heights, in card pixels. */
const IMAGE_MEDIA_HEIGHT = 540;
const MAX_VIDEO_MEDIA_HEIGHT = 780;
const MIN_VIDEO_MEDIA_HEIGHT = 320;

type Media = {
  type: 'image' | 'video';
  url: string;
  poster?: string | null;
  /** Natural pixel size of the attachment, when the API reports it. */
  width?: number | null;
  height?: number | null;
};

interface Rect { x: number; y: number; w: number; h: number }

interface CardLayout {
  frameX: number;
  frameY: number;
  frameW: number;
  frameH: number;
  padding: number;
  /** Media region inside the post frame (null for text-only posts). */
  media: Rect | null;
  mediaKind: 'image' | 'video' | null;
  bodyLines: string[];
  metrics: WorkoutMetrics | null;
  hasCommunity: boolean;
  communityLabel: string;
  communityPillW: number;
}

/** What we know about the post's media before anything is rendered. */
interface MediaPlan {
  kind: 'image' | 'video' | null;
  url: string | null;
  poster: string | null;
  /** Natural pixel size of the clip, when it could be determined. */
  naturalWidth: number | null;
  naturalHeight: number | null;
}

/**
 * The media the card should show.
 *
 * A post can carry several attachments; the server composites the first
 * *video* one into a video card, so the card picks the same item. That
 * keeps the media block the right shape for the clip that ends up in it.
 */
export function selectCardMedia(post: Post): Media | null {
  const items = post.media ?? [];
  const video = items.find((m) => m.media_type === 'video' && m.url);
  const structured = video ?? items[0];
  if (structured?.url) {
    return {
      type: structured.media_type === 'video' ? 'video' : 'image',
      url: structured.url,
      poster: structured.poster_url,
      width: structured.width ?? null,
      height: structured.height ?? null,
    };
  }
  const url = post.media_urls?.[0];
  if (!url) return null;
  const isVideo = post.post_type === 'short_video'
    || post.post_type === 'long_video'
    || /\.(mp4|mov|webm|m4v|mpeg|mkv)(\?|$)/i.test(url);
  return { type: isVideo ? 'video' : 'image', url, width: null, height: null };
}

/** True when the post carries a video we can render into a card. */
export function hasVideoMedia(post: Post): boolean {
  return selectCardMedia(post)?.type === 'video';
}

function loadImage(src: string): Promise<HTMLImageElement> {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.crossOrigin = 'anonymous';
    img.onload = () => resolve(img);
    img.onerror = () => reject(new Error('image load failed'));
    img.src = src;
  });
}

async function loadBitmap(src: string): Promise<ImageBitmap | HTMLImageElement | null> {
  // Fetch first so cross-origin media is retried as a blob; drawing a plain
  // cross-origin <img> taints the canvas and makes toBlob() fail.
  try {
    const res = await fetch(src, { mode: 'cors' });
    if (!res.ok) throw new Error(`media ${res.status}`);
    const blob = await res.blob();
    if ('createImageBitmap' in window) {
      return await createImageBitmap(blob);
    }
    const objectUrl = URL.createObjectURL(blob);
    try {
      return await loadImage(objectUrl);
    } finally {
      setTimeout(() => URL.revokeObjectURL(objectUrl), 30_000);
    }
  } catch {
    try {
      return await loadImage(src);
    } catch {
      return null;
    }
  }
}

/** Natural size of a video, so the card can frame it without cropping. */
async function loadVideoSize(url: string): Promise<{ width: number; height: number } | null> {
  return new Promise((resolve) => {
    const el = document.createElement('video');
    el.crossOrigin = 'anonymous';
    el.muted = true;
    el.playsInline = true;
    el.preload = 'metadata';
    let settled = false;
    const finish = (value: { width: number; height: number } | null) => {
      if (settled) return;
      settled = true;
      resolve(value);
    };
    el.onloadedmetadata = () => {
      finish(el.videoWidth && el.videoHeight
        ? { width: el.videoWidth, height: el.videoHeight }
        : null);
    };
    el.onerror = () => finish(null);
    el.src = url;
    setTimeout(() => finish(null), 8000);
  });
}

async function loadVideoPoster(video: Media): Promise<ImageBitmap | HTMLImageElement | HTMLVideoElement | null> {
  if (video.poster) {
    const poster = await loadBitmap(video.poster);
    if (poster) return poster;
  }
  return new Promise((resolve) => {
    const el = document.createElement('video');
    el.crossOrigin = 'anonymous';
    el.muted = true;
    el.playsInline = true;
    el.preload = 'auto';
    el.src = video.url;
    let settled = false;
    const finish = (value: HTMLVideoElement | null) => {
      if (settled) return;
      settled = true;
      resolve(value);
    };
    el.onloadeddata = () => {
      try {
        el.currentTime = Math.min(0.2, (el.duration || 1) / 10);
      } catch {
        finish(el);
      }
    };
    el.onseeked = () => finish(el);
    el.onerror = () => finish(null);
    setTimeout(() => finish(null), 8000);
  });
}

function roundedRect(
  ctx: CanvasRenderingContext2D,
  x: number,
  y: number,
  w: number,
  h: number,
  r: number,
) {
  const radius = Math.min(r, w / 2, h / 2);
  ctx.beginPath();
  ctx.moveTo(x + radius, y);
  ctx.arcTo(x + w, y, x + w, y + h, radius);
  ctx.arcTo(x + w, y + h, x, y + h, radius);
  ctx.arcTo(x, y + h, x, y, radius);
  ctx.arcTo(x, y, x + w, y, radius);
  ctx.closePath();
}

/** Cover-fit `source` into the box, preserving aspect ratio. */
function drawCover(
  ctx: CanvasRenderingContext2D,
  source: CanvasImageSource,
  x: number,
  y: number,
  w: number,
  h: number,
) {
  const sized = source as unknown as {
    naturalWidth?: number; naturalHeight?: number;
    videoWidth?: number; videoHeight?: number;
    width?: number; height?: number;
  };
  const sw = sized.naturalWidth || sized.videoWidth || Number(sized.width) || CARD_WIDTH;
  const sh = sized.naturalHeight || sized.videoHeight || Number(sized.height) || CARD_HEIGHT;
  const scale = Math.max(w / sw, h / sh);
  const dw = sw * scale;
  const dh = sh * scale;
  ctx.drawImage(source, x + (w - dw) / 2, y + (h - dh) / 2, dw, dh);
}

/**
 * Fit-fit `source` into the box, preserving the whole frame.
 *
 * The video is centred and the leftover space is filled with a blurred copy
 * of it, so the shot stays whole — a crop could slice the subject in half.
 */
function drawFitted(
  ctx: CanvasRenderingContext2D,
  source: CanvasImageSource,
  x: number,
  y: number,
  w: number,
  h: number,
) {
  const sized = source as unknown as {
    naturalWidth?: number; naturalHeight?: number;
    videoWidth?: number; videoHeight?: number;
    width?: number; height?: number;
  };
  const sw = sized.naturalWidth || sized.videoWidth || Number(sized.width) || CARD_WIDTH;
  const sh = sized.naturalHeight || sized.videoHeight || Number(sized.height) || CARD_HEIGHT;

  // Blurred backdrop so the letterbox area is not a dead black bar.
  ctx.save();
  ctx.filter = 'blur(28px)';
  ctx.globalAlpha = 0.55;
  drawCover(ctx, source, x, y, w, h);
  ctx.restore();

  const scale = Math.min(w / sw, h / sh);
  const dw = sw * scale;
  const dh = sh * scale;
  ctx.drawImage(source, x + (w - dw) / 2, y + (h - dh) / 2, dw, dh);
}

function wrapLines(
  ctx: CanvasRenderingContext2D,
  text: string,
  maxWidth: number,
  maxLines: number,
): string[] {
  const words = text.replace(/\s+/g, ' ').trim().split(' ');
  const lines: string[] = [];
  let current = '';
  for (const word of words) {
    const candidate = current ? `${current} ${word}` : word;
    if (ctx.measureText(candidate).width <= maxWidth) {
      current = candidate;
      continue;
    }
    if (current) lines.push(current);
    current = word;
    if (lines.length === maxLines) break;
  }
  if (lines.length < maxLines && current) lines.push(current);
  if (lines.length === maxLines) {
    const last = lines[maxLines - 1];
    let trimmed = last;
    while (trimmed.length > 1 && ctx.measureText(`${trimmed}…`).width > maxWidth) {
      trimmed = trimmed.slice(0, -1);
    }
    if (trimmed !== last) lines[maxLines - 1] = `${trimmed}…`;
  }
  return lines.slice(0, maxLines);
}

function drawAvatar(
  ctx: CanvasRenderingContext2D,
  image: HTMLImageElement | null,
  name: string,
  x: number,
  y: number,
  size: number,
) {
  ctx.save();
  ctx.beginPath();
  ctx.arc(x + size / 2, y + size / 2, size / 2, 0, Math.PI * 2);
  ctx.clip();
  if (image) {
    drawCover(ctx, image, x, y, size, size);
  } else {
    ctx.fillStyle = '#1B2A21';
    ctx.fillRect(x, y, size, size);
    ctx.fillStyle = GREEN;
    ctx.font = '700 30px Inter, sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText((name || 'B').trim().charAt(0).toUpperCase(), x + size / 2, y + size / 2);
  }
  ctx.restore();
  ctx.save();
  ctx.beginPath();
  ctx.arc(x + size / 2, y + size / 2, size / 2 - 1, 0, Math.PI * 2);
  ctx.strokeStyle = 'rgba(255,255,255,0.16)';
  ctx.lineWidth = 2;
  ctx.stroke();
  ctx.restore();
}

/** A tiny dumbbell glyph for the workout metrics block. */
function drawDumbbell(ctx: CanvasRenderingContext2D, x: number, y: number, color: string) {
  ctx.save();
  ctx.fillStyle = color;
  ctx.fillRect(x, y - 3, 20, 6);
  ctx.fillRect(x - 2, y - 10, 6, 20);
  ctx.fillRect(x + 16, y - 10, 6, 20);
  ctx.restore();
}

/** Header watermark: BuddyUp wordmark + FIT TOGETHER. */
function drawHeader(ctx: CanvasRenderingContext2D) {
  ctx.save();
  ctx.font = '800 38px Syne, Inter, sans-serif';
  ctx.textAlign = 'left';
  ctx.textBaseline = 'middle';
  ctx.fillStyle = TEXT;
  ctx.fillText('BuddyUp', 48, 62);
  const width = ctx.measureText('BuddyUp').width;
  ctx.beginPath();
  ctx.arc(48 + width + 13, 52, 8, 0, Math.PI * 2);
  ctx.fillStyle = GREEN;
  ctx.fill();
  ctx.font = '600 16px Inter, sans-serif';
  ctx.fillStyle = MUTED;
  ctx.fillText('FIT TOGETHER', 48, 96);
  ctx.restore();
}

/** Bottom-left watermark inside the post frame. */
function drawWatermark(ctx: CanvasRenderingContext2D, x: number, y: number, onMedia = false) {
  ctx.save();
  ctx.font = '700 22px Syne, Inter, sans-serif';
  ctx.textAlign = 'left';
  ctx.textBaseline = 'bottom';
  ctx.fillStyle = onMedia ? 'rgba(255,255,255,0.82)' : 'rgba(244,247,245,0.55)';
  const label = 'BuddyUp Fit';
  ctx.fillText(label, x + 16, y);
  const width = ctx.measureText(label).width;
  ctx.beginPath();
  ctx.arc(x + width + 26, y - 8, 5, 0, Math.PI * 2);
  ctx.fillStyle = onMedia ? 'rgba(34,197,94,0.95)' : 'rgba(34,197,94,0.8)';
  ctx.fill();
  ctx.restore();
}

// --- PNG metadata (tEXt / iTXt + XMP) -------------------------------------

let crcTable: number[] | null = null;

function crc32(bytes: Uint8Array): number {
  if (!crcTable) {
    crcTable = [];
    for (let n = 0; n < 256; n++) {
      let c = n;
      for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
      crcTable[n] = c >>> 0;
    }
  }
  let crc = 0xffffffff;
  for (const byte of bytes) crc = crcTable[(crc ^ byte) & 0xff] ^ (crc >>> 8);
  return (crc ^ 0xffffffff) >>> 0;
}

function asciiBytes(value: string): Uint8Array {
  const bytes = new Uint8Array(value.length);
  for (let i = 0; i < value.length; i++) bytes[i] = value.charCodeAt(i) & 0x7f;
  return bytes;
}

function utf8Bytes(value: string): Uint8Array {
  return new TextEncoder().encode(value);
}

function concatBytes(parts: Uint8Array[]): Uint8Array {
  const total = parts.reduce((sum, part) => sum + part.length, 0);
  const out = new Uint8Array(total);
  let offset = 0;
  for (const part of parts) {
    out.set(part, offset);
    offset += part.length;
  }
  return out;
}

function pngChunk(type: string, data: Uint8Array): Uint8Array {
  const out = new Uint8Array(12 + data.length);
  const view = new DataView(out.buffer);
  view.setUint32(0, data.length);
  out.set(asciiBytes(type), 4);
  out.set(data, 8);
  view.setUint32(8 + data.length, crc32(out.slice(4, 8 + data.length)));
  return out;
}

function textChunk(keyword: string, value: string): Uint8Array {
  return pngChunk('tEXt', concatBytes([asciiBytes(keyword), new Uint8Array([0]), asciiBytes(value)]));
}

function itxtChunk(keyword: string, value: string): Uint8Array {
  return pngChunk('iTXt', concatBytes([
    utf8Bytes(keyword),
    new Uint8Array([0, 0, 0]), // null separator, no compression, method 0
    new Uint8Array([0]), // empty language tag + null
    new Uint8Array([0]), // empty translated keyword + null
    utf8Bytes(value),
  ]));
}

function xmlEscape(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function buildXmp(post: Post, url: string): string {
  const name = post.author_data?.display_name || 'BuddyUp member';
  const username = post.author_data?.username || '';
  const title = `BuddyUp post by @${username || name}`;
  const description = (post.body || '').slice(0, 500);
  return [
    '<?xpacket begin="\uFEFF" id="W5M0MpCehiHzreSzNTczkc9d"?>',
    '<x:xmpmeta xmlns:x="adobe:ns:meta/">',
    '<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">',
    `<rdf:Description rdf:about="" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xmp="http://ns.adobe.com/xap/1.0/" xmlns:xmpRights="http://ns.adobe.com/xap/1.0/rights/" xmlns:photoshop="http://ns.adobe.com/photoshop/1.0/">`,
    `<dc:title><rdf:Alt><rdf:li xml:lang="x-default">${xmlEscape(title)}</rdf:li></rdf:Alt></dc:title>`,
    `<dc:creator><rdf:Seq><rdf:li>${xmlEscape(name)}</rdf:li></rdf:Seq></dc:creator>`,
    `<dc:description><rdf:Alt><rdf:li xml:lang="x-default">${xmlEscape(description)}</rdf:li></rdf:Alt></dc:description>`,
    `<dc:relation><rdf:Bag><rdf:li>${xmlEscape(url)}</rdf:li></rdf:Bag></dc:relation>`,
    `<xmpRights:WebStatement>${xmlEscape(url)}</xmpRights:WebStatement>`,
    '<photoshop:Credit>BuddyUp Fit</photoshop:Credit>',
    '<xmp:CreatorTool>BuddyUp Fit</xmp:CreatorTool>',
    '</rdf:Description>',
    '</rdf:RDF>',
    '</x:xmpmeta>',
    '<?xpacket end="w"?>',
  ].join('\n');
}

/** Embed the post link as recognizable image properties, not visible text. */
async function withPngMetadata(blob: Blob, post: Post, url: string): Promise<Blob> {
  const bytes = new Uint8Array(await blob.arrayBuffer());
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  const signature = bytes.slice(0, 8);
  const parts: Uint8Array[] = [signature];
  let offset = 8;

  while (offset < bytes.length) {
    const length = view.getUint32(offset);
    const end = offset + 12 + length;
    const type = String.fromCharCode(bytes[offset + 4], bytes[offset + 5], bytes[offset + 6], bytes[offset + 7]);
    if (type === 'IEND') {
      const name = post.author_data?.display_name || 'BuddyUp member';
      const username = post.author_data?.username || '';
      const caption = (post.body || '').slice(0, 400).replace(/[^\x20-\x7E]/g, ' ');
      parts.push(textChunk('Title', `BuddyUp post by @${username || name}`));
      parts.push(textChunk('Author', `${name} (@${username})`));
      parts.push(textChunk('Description', caption));
      parts.push(textChunk('URL', url));
      parts.push(textChunk('Source', url));
      parts.push(textChunk('Comment', 'Shared from BuddyUp Fit'));
      parts.push(textChunk('Software', 'BuddyUp Fit'));
      parts.push(itxtChunk('Description', post.body || ''));
      parts.push(itxtChunk('XML:com.adobe.xmp', buildXmp(post, url)));
    }
    parts.push(bytes.slice(offset, end));
    offset = end;
  }

  return new Blob(parts as unknown as BlobPart[], { type: 'image/png' });
}

// --- Card layout + painting ------------------------------------------------

async function ensureFonts() {
  if (typeof document === 'undefined' || !('fonts' in document)) return;
  try {
    await Promise.all([
      document.fonts.load('800 38px Syne'),
      document.fonts.load('700 34px Inter'),
      document.fonts.load('500 30px Inter'),
    ]);
    await document.fonts.ready;
  } catch {
    // System fallbacks are fine.
  }
}

async function planMedia(post: Post): Promise<MediaPlan> {
  const media = selectCardMedia(post);
  if (!media) {
    return { kind: null, url: null, poster: null, naturalWidth: null, naturalHeight: null };
  }
  if (media.type !== 'video') {
    return { kind: 'image', url: media.url, poster: null, naturalWidth: null, naturalHeight: null };
  }
  // The API already reports the clip's dimensions for structured media, so the
  // card can be laid out without probing the file. Only fall back to loading
  // the metadata when they are missing.
  if (media.width && media.height) {
    return {
      kind: 'video',
      url: media.url,
      poster: media.poster ?? null,
      naturalWidth: media.width,
      naturalHeight: media.height,
    };
  }
  const size = await loadVideoSize(media.url);
  return {
    kind: 'video',
    url: media.url,
    poster: media.poster ?? null,
    naturalWidth: size?.width ?? null,
    naturalHeight: size?.height ?? null,
  };
}

/**
 * Size the media block.
 *
 * Images fill the frame width and are cropped to a fixed band. Videos get a
 * block sized to the clip's aspect ratio (capped to the space the rest of
 * the card leaves), so a wide clip fills its block instead of floating in a
 * band of blurred filler.
 */
function mediaRectFor(
  plan: MediaPlan,
  frameX: number,
  frameY: number,
  frameW: number,
  available: number,
): Rect | null {
  if (!plan.kind || !plan.url) return null;
  if (plan.kind === 'image') {
    return { x: frameX, y: frameY, w: frameW, h: Math.min(IMAGE_MEDIA_HEIGHT, available) };
  }
  const aspect = plan.naturalWidth && plan.naturalHeight
    ? plan.naturalWidth / plan.naturalHeight
    : 9 / 16;
  const h = Math.round(
    Math.min(
      MAX_VIDEO_MEDIA_HEIGHT,
      available,
      Math.max(MIN_VIDEO_MEDIA_HEIGHT, frameW / aspect),
    ),
  );
  return { x: frameX, y: frameY, w: frameW, h };
}

function computeLayout(ctx: CanvasRenderingContext2D, post: Post, plan: MediaPlan): CardLayout {
  const frameX = 48;
  const frameW = CARD_WIDTH - 96;
  const padding = 32;
  const authorH = 92;
  const hasCommunity = !!post.community_name;
  const pillH = hasCommunity ? 50 : 0;
  const body = (post.body || '').trim();

  ctx.font = '500 34px Inter, sans-serif';
  const bodyLines = body ? wrapLines(ctx, body, frameW - padding * 2, 4) : [];
  const bodyH = bodyLines.length * 46;

  const metrics = post.post_type === 'workout_log'
    ? parseWorkoutMetrics(post.workout_log_data)
    : null;
  const metricsH = metrics ? 150 : 0;

  // Everything in the frame that is not the media block.
  const chromeH = 8
    + authorH
    + (hasCommunity ? pillH + 8 : 0)
    + bodyH
    + (metricsH ? metricsH + 10 : 0)
    + 94;

  const topLabelH = 54;
  const frameY = 150;
  // Leave room for the footer branding under the frame.
  const roomForMedia = Math.max(MIN_VIDEO_MEDIA_HEIGHT, CARD_HEIGHT - 64 - frameY - chromeH);

  const media = mediaRectFor(plan, frameX, frameY, frameW, roomForMedia);
  const mediaH = media?.h ?? 0;

  const frameH = (media ? 0 : topLabelH) + mediaH + chromeH;
  // Text-only posts float the frame in the space below the header.
  const settledFrameY = media
    ? frameY
    : Math.max(frameY, frameY + (1060 - frameH) / 2);

  ctx.font = '600 20px Inter, sans-serif';
  const communityLabel = post.community_name || '';
  const communityPillW = hasCommunity
    ? Math.min(ctx.measureText(communityLabel).width + 34, 500)
    : 0;

  return {
    frameX,
    frameY: settledFrameY,
    frameW,
    frameH,
    padding,
    media,
    mediaKind: plan.kind,
    bodyLines,
    metrics,
    hasCommunity,
    communityLabel,
    communityPillW,
  };
}

/**
 * Paint the card chrome: background, post frame, author, community tag,
 * caption, workout metrics and the footer.
 */
function paintChrome(
  ctx: CanvasRenderingContext2D,
  post: Post,
  layout: CardLayout,
  avatar: HTMLImageElement | null,
) {
  const { frameX, frameY, frameW, frameH, padding } = layout;

  // Background with a soft green glow.
  ctx.fillStyle = INK;
  ctx.fillRect(0, 0, CARD_WIDTH, CARD_HEIGHT);
  const glow = ctx.createRadialGradient(880, 120, 40, 880, 120, 620);
  glow.addColorStop(0, 'rgba(34,197,94,0.30)');
  glow.addColorStop(1, 'rgba(34,197,94,0)');
  ctx.fillStyle = glow;
  ctx.fillRect(0, 0, CARD_WIDTH, CARD_HEIGHT);

  drawHeader(ctx);

  // Post frame.
  ctx.save();
  roundedRect(ctx, frameX, frameY, frameW, frameH, MEDIA_RADIUS);
  ctx.clip();
  const panel = ctx.createLinearGradient(frameX, frameY, frameX + frameW, frameY + frameH);
  panel.addColorStop(0, '#13241A');
  panel.addColorStop(1, '#0E1712');
  ctx.fillStyle = panel;
  ctx.fillRect(frameX, frameY, frameW, frameH);

  let cursorY = frameY + padding;
  if (!layout.media) {
    ctx.font = '700 20px Inter, sans-serif';
    ctx.fillStyle = 'rgba(34,197,94,0.9)';
    ctx.textAlign = 'left';
    ctx.textBaseline = 'middle';
    ctx.fillText('BUDDYUP POST', frameX + padding, cursorY + 10);
    cursorY += 54;
  } else {
    cursorY = frameY + layout.media.h + 8;
  }

  // Author row inside the post frame.
  const author = post.author_data;
  drawAvatar(ctx, avatar, author?.display_name || '', frameX + padding, cursorY + 12, 64);

  ctx.textAlign = 'left';
  ctx.textBaseline = 'alphabetic';
  ctx.font = '700 32px Inter, sans-serif';
  ctx.fillStyle = TEXT;
  ctx.fillText(author?.display_name || 'BuddyUp member', frameX + padding + 82, cursorY + 42);
  ctx.font = '500 23px Inter, sans-serif';
  ctx.fillStyle = MUTED;
  ctx.fillText(author?.username ? `@${author.username}` : '', frameX + padding + 82, cursorY + 74);
  cursorY += 92;

  if (layout.hasCommunity) {
    ctx.font = '600 20px Inter, sans-serif';
    roundedRect(ctx, frameX + padding, cursorY - 4, layout.communityPillW, 38, 19);
    ctx.fillStyle = 'rgba(34,197,94,0.14)';
    ctx.fill();
    ctx.strokeStyle = 'rgba(34,197,94,0.35)';
    ctx.lineWidth = 1.5;
    ctx.stroke();
    ctx.fillStyle = GREEN;
    ctx.textBaseline = 'middle';
    ctx.fillText(layout.communityLabel, frameX + padding + 17, cursorY + 15, layout.communityPillW - 34);
    cursorY += 58;
  }

  // Caption inside the post frame.
  if (layout.bodyLines.length) {
    ctx.font = '500 34px Inter, sans-serif';
    ctx.fillStyle = TEXT;
    ctx.textBaseline = 'top';
    let y = cursorY + 10;
    for (const line of layout.bodyLines) {
      ctx.fillText(line, frameX + padding, y);
      y += 46;
    }
    cursorY = y;
  }

  // Workout metrics card inside the post frame.
  if (layout.metrics) {
    const cardX = frameX + padding;
    const cardW = frameW - padding * 2;
    const cardY = cursorY + 4;
    const cardH = 140;
    roundedRect(ctx, cardX, cardY, cardW, cardH, 24);
    ctx.fillStyle = 'rgba(255,255,255,0.05)';
    ctx.fill();
    ctx.strokeStyle = 'rgba(255,255,255,0.10)';
    ctx.lineWidth = 1.5;
    ctx.stroke();

    drawDumbbell(ctx, cardX + 24, cardY + 34, GREEN);
    ctx.font = '700 26px Inter, sans-serif';
    ctx.fillStyle = TEXT;
    ctx.textAlign = 'left';
    ctx.textBaseline = 'middle';
    ctx.fillText(layout.metrics.title, cardX + 60, cardY + 34, cardW - 84);

    const shown = layout.metrics.metrics.slice(0, 3);
    const colW = (cardW - 48) / Math.max(shown.length, 1);
    shown.forEach((metric, index) => {
      const cx = cardX + 24 + colW * index + colW / 2;
      ctx.textAlign = 'center';
      ctx.font = '700 40px JetBrains Mono, Inter, monospace';
      ctx.fillStyle = metric.tone === 'orange' ? '#F59E0B' : GREEN;
      ctx.textBaseline = 'alphabetic';
      ctx.fillText(metric.value, cx, cardY + 96);
      ctx.font = '500 19px Inter, sans-serif';
      ctx.fillStyle = MUTED;
      ctx.fillText(metric.label, cx, cardY + 122);
    });
  }

  // Bottom-left watermark inside the post frame when there is no media.
  if (!layout.media) {
    drawWatermark(ctx, frameX + padding, frameY + frameH - 28);
  }
  ctx.restore();

  // Footer branding only — the post link lives in the image metadata.
  ctx.font = '500 22px Inter, sans-serif';
  ctx.fillStyle = 'rgba(155,166,159,0.75)';
  ctx.textAlign = 'left';
  ctx.textBaseline = 'bottom';
  ctx.fillText('Shared from BuddyUp Fit', 48, CARD_HEIGHT - 42);
  ctx.textAlign = 'right';
  ctx.fillText('buddyup.fit', CARD_WIDTH - 48, CARD_HEIGHT - 42);

  // Green accent line along the top edge.
  const accent = ctx.createLinearGradient(0, 0, CARD_WIDTH, 0);
  accent.addColorStop(0, GREEN);
  accent.addColorStop(1, 'rgba(34,197,94,0)');
  ctx.fillStyle = accent;
  ctx.fillRect(0, 0, CARD_WIDTH, 6);
}

/** Paint the still image (photo or video poster) into the media block. */
function paintMediaImage(
  ctx: CanvasRenderingContext2D,
  layout: CardLayout,
  source: CanvasImageSource | null,
  isVideoFrame: boolean,
) {
  const rect = layout.media;
  if (!rect) return;

  ctx.save();
  roundedRect(ctx, rect.x, rect.y, rect.w, rect.h, MEDIA_RADIUS);
  ctx.clip();
  ctx.fillStyle = '#14201A';
  ctx.fillRect(rect.x, rect.y, rect.w, rect.h);

  if (source) {
    if (isVideoFrame) {
      drawFitted(ctx, source, rect.x, rect.y, rect.w, rect.h);
    } else {
      drawCover(ctx, source, rect.x, rect.y, rect.w, rect.h);
    }
  } else {
    // No media / media blocked: a branded panel still makes a valid card.
    const panel = ctx.createLinearGradient(rect.x, rect.y, rect.x + rect.w, rect.y + rect.h);
    panel.addColorStop(0, '#12261B');
    panel.addColorStop(1, '#0D1712');
    ctx.fillStyle = panel;
    ctx.fillRect(rect.x, rect.y, rect.w, rect.h);
    ctx.font = '800 60px Syne, Inter, sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillStyle = 'rgba(244,247,245,0.9)';
    ctx.fillText('BuddyUp', rect.x + rect.w / 2, rect.y + rect.h / 2 - 14);
    ctx.font = '500 24px Inter, sans-serif';
    ctx.fillStyle = 'rgba(155,166,159,0.9)';
    ctx.fillText(isVideoFrame ? 'Video post' : 'Post', rect.x + rect.w / 2, rect.y + rect.h / 2 + 44);
  }
  ctx.restore();
}

/**
 * Paint the decorations that sit *on top* of the media: the fade, the
 * post badge and the bottom-left watermark.
 */
function paintMediaDecorations(ctx: CanvasRenderingContext2D, layout: CardLayout) {
  const rect = layout.media;
  if (!rect) return;

  ctx.save();
  roundedRect(ctx, rect.x, rect.y, rect.w, rect.h, MEDIA_RADIUS);
  ctx.clip();

  const fade = ctx.createLinearGradient(0, rect.y + rect.h * 0.58, 0, rect.y + rect.h);
  fade.addColorStop(0, 'rgba(0,0,0,0)');
  fade.addColorStop(1, 'rgba(0,0,0,0.68)');
  ctx.fillStyle = fade;
  ctx.fillRect(rect.x, rect.y + rect.h * 0.58, rect.w, rect.h * 0.42);

  // Post-type badge over the media.
  ctx.font = '700 18px Inter, sans-serif';
  const badge = 'BUDDYUP POST';
  const badgeW = ctx.measureText(badge).width + 28;
  roundedRect(ctx, rect.x + layout.padding, rect.y + layout.padding, badgeW, 36, 18);
  ctx.fillStyle = 'rgba(0,0,0,0.55)';
  ctx.fill();
  ctx.fillStyle = 'rgba(34,197,94,0.95)';
  ctx.textAlign = 'left';
  ctx.textBaseline = 'middle';
  ctx.fillText(badge, rect.x + layout.padding + 14, rect.y + layout.padding + 19);

  // Bottom-left watermark on the media.
  drawWatermark(ctx, rect.x + layout.padding, rect.y + rect.h - 26, true);
  ctx.restore();
}

export interface ShareCardOptions {
  /** Canonical permalink embedded in the image metadata + share payload. */
  url: string;
}

function makeCanvas(): { canvas: HTMLCanvasElement; ctx: CanvasRenderingContext2D } {
  const canvas = document.createElement('canvas');
  canvas.width = CARD_WIDTH;
  canvas.height = CARD_HEIGHT;
  const ctx = canvas.getContext('2d');
  if (!ctx) throw new Error('Canvas not supported');
  return { canvas, ctx };
}

function canvasToBlob(canvas: HTMLCanvasElement, type = 'image/png'): Promise<Blob> {
  return new Promise((resolve, reject) => {
    canvas.toBlob((result) => {
      if (result) resolve(result);
      else reject(new Error('Could not render the share card'));
    }, type);
  });
}

/** Render the still card (PNG). */
export async function createShareCard(post: Post, options: ShareCardOptions): Promise<File> {
  await ensureFonts();

  const plan = await planMedia(post);
  const { canvas, ctx } = makeCanvas();
  const layout = computeLayout(ctx, post, plan);
  const author = post.author_data;
  const avatar = author?.avatar_url ? await loadBitmap(author.avatar_url) : null;

  paintChrome(ctx, post, layout, avatar as HTMLImageElement | null);

  const mediaSource = plan.kind === 'video'
    ? await loadVideoPoster({ type: 'video', url: plan.url as string, poster: plan.poster })
    : plan.kind === 'image'
      ? await loadBitmap(plan.url as string)
      : null;
  paintMediaImage(ctx, layout, mediaSource, plan.kind === 'video');
  paintMediaDecorations(ctx, layout);

  const blob = await canvasToBlob(canvas);
  const withMeta = await withPngMetadata(blob, post, options.url);
  return new File([withMeta], `buddyup-${post.id}.png`, { type: 'image/png' });
}

export interface ShareCardLayers {
  /** Card chrome: background, frame, author, caption, metrics, footer. */
  base: Blob;
  /** Decorations that belong on top of the clip. */
  over: Blob;
  /** Where the clip goes, in card pixels. */
  rect: { x: number; y: number; w: number; h: number };
  /** Corner radius of the media block. */
  radius: number;
}

/**
 * Render the card as two layers for a video card.
 *
 * The chrome carries the full card (the media area is left as the panel
 * background) and the decoration layer holds only what belongs *over* the
 * clip. The server composites the clip between them, so the exported video
 * plays the whole clip with its original audio.
 */
export async function renderShareCardLayers(post: Post): Promise<ShareCardLayers | null> {
  await ensureFonts();

  const plan = await planMedia(post);
  if (plan.kind !== 'video' || !plan.url) return null;

  const { canvas, ctx } = makeCanvas();
  const layout = computeLayout(ctx, post, plan);
  if (!layout.media) return null;

  const author = post.author_data;
  const avatar = author?.avatar_url ? await loadBitmap(author.avatar_url) : null;

  paintChrome(ctx, post, layout, avatar as HTMLImageElement | null);
  const base = await canvasToBlob(canvas);

  // Decoration layer: transparent except the media overlay.
  const { canvas: overCanvas, ctx: overCtx } = makeCanvas();
  overCtx.clearRect(0, 0, CARD_WIDTH, CARD_HEIGHT);
  paintMediaDecorations(overCtx, layout);
  const over = await canvasToBlob(overCanvas);

  return {
    base,
    over,
    rect: {
      x: layout.media.x,
      y: layout.media.y,
      w: layout.media.w,
      h: layout.media.h,
    },
    radius: MEDIA_RADIUS,
  };
}

/** Trigger a local file download for a generated card. */
export function downloadShareCard(file: File) {
  const url = URL.createObjectURL(file);
  const a = document.createElement('a');
  a.href = url;
  a.download = file.name;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}
