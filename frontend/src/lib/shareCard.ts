import type { Post } from '@/types';

/**
 * Social share card: a 4:5 PNG with the post content inside a BuddyUp post
 * frame, a BuddyUp Fit watermark header, a bottom-left watermark, and the
 * post permalink embedded as PNG/XMP metadata (not printed on the card).
 *
 * Sharing the file through the native share sheet (WhatsApp Status,
 * Instagram Stories, AirDrop, …) keeps the branding intact when the post is
 * re-shared as an image. The link also travels in the share text so apps that
 * only read captions still get it.
 */

const CARD_WIDTH = 1080;
const CARD_HEIGHT = 1350;

const GREEN = '#22C55E';
const INK = '#0B0F0D';
const TEXT = '#F4F7F5';
const MUTED = '#9BA69F';

type Media = { type: 'image' | 'video'; url: string; poster?: string | null };

function mediaOf(post: Post): Media | null {
  const structured = post.media?.[0];
  if (structured?.url) {
    return {
      type: structured.media_type === 'video' ? 'video' : 'image',
      url: structured.url,
      poster: structured.poster_url,
    };
  }
  const url = post.media_urls?.[0];
  if (!url) return null;
  const isVideo = post.post_type === 'short_video'
    || post.post_type === 'long_video'
    || /\.(mp4|mov|webm|m4v|mpeg|mkv)(\?|$)/i.test(url);
  return { type: isVideo ? 'video' : 'image', url };
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

async function loadVideoPoster(video: Media): Promise<ImageBitmap | HTMLImageElement | HTMLVideoElement | null> {
  if (video.poster) {
    const poster = await loadBitmap(video.poster);
    if (poster) return poster;
  }
  return new Promise<HTMLVideoElement | null>((resolve) => {
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
  source: CanvasImageSource & { width?: number; height?: number },
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
  const sw = sized.naturalWidth || sized.videoWidth || Number(source.width) || CARD_WIDTH;
  const sh = sized.naturalHeight || sized.videoHeight || Number(source.height) || CARD_HEIGHT;
  const scale = Math.max(w / sw, h / sh);
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

export interface ShareCardOptions {
  /** Canonical permalink embedded in the image metadata + share payload. */
  url: string;
}

export async function createShareCard(post: Post, options: ShareCardOptions): Promise<File> {
  if (typeof document !== 'undefined' && 'fonts' in document) {
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

  const canvas = document.createElement('canvas');
  canvas.width = CARD_WIDTH;
  canvas.height = CARD_HEIGHT;
  const ctx = canvas.getContext('2d');
  if (!ctx) throw new Error('Canvas not supported');

  // Background with a soft green glow.
  ctx.fillStyle = INK;
  ctx.fillRect(0, 0, CARD_WIDTH, CARD_HEIGHT);
  const glow = ctx.createRadialGradient(880, 120, 40, 880, 120, 620);
  glow.addColorStop(0, 'rgba(34,197,94,0.30)');
  glow.addColorStop(1, 'rgba(34,197,94,0)');
  ctx.fillStyle = glow;
  ctx.fillRect(0, 0, CARD_WIDTH, CARD_HEIGHT);

  drawHeader(ctx);

  const media = mediaOf(post);
  const frameX = 48;
  const frameW = CARD_WIDTH - 96;
  const padding = 32;
  const mediaH = media ? 540 : 0;
  const authorH = 92;
  const hasCommunity = !!post.community_name;
  const pillH = hasCommunity ? 50 : 0;
  const body = (post.body || '').trim();

  ctx.font = '500 34px Inter, sans-serif';
  const bodyLines = body ? wrapLines(ctx, body, frameW - padding * 2, 4) : [];
  const bodyH = bodyLines.length * 46;
  const topLabelH = media ? 0 : 54;
  const frameH = topLabelH + mediaH + 8 + authorH + (hasCommunity ? pillH + 8 : 0) + bodyH + 94;

  // Compact post cards sit centered in the space below the header.
  const frameY = media ? 150 : Math.max(150, 150 + (1060 - frameH) / 2);

  // Post frame.
  ctx.save();
  roundedRect(ctx, frameX, frameY, frameW, frameH, 36);
  ctx.clip();
  const panel = ctx.createLinearGradient(frameX, frameY, frameX + frameW, frameY + frameH);
  panel.addColorStop(0, '#13241A');
  panel.addColorStop(1, '#0E1712');
  ctx.fillStyle = panel;
  ctx.fillRect(frameX, frameY, frameW, frameH);

  let cursorY = frameY + padding;
  if (!media) {
    ctx.font = '700 20px Inter, sans-serif';
    ctx.fillStyle = 'rgba(34,197,94,0.9)';
    ctx.textAlign = 'left';
    ctx.textBaseline = 'middle';
    ctx.fillText('BUDDYUP POST', frameX + padding, cursorY + 10);
    cursorY += topLabelH;
  }

  if (media) {
    // Media fills the top of the post frame so the post content stays
    // wrapped in one BuddyUp post card.
    const mx = frameX;
    const my = frameY;
    ctx.save();
    roundedRect(ctx, mx, my, frameW, mediaH, 36);
    ctx.clip();
    ctx.fillStyle = '#14201A';
    ctx.fillRect(mx, my, frameW, mediaH);

    const mediaImage = media.type === 'video'
      ? await loadVideoPoster(media)
      : await loadBitmap(media.url);

    if (mediaImage) {
      drawCover(ctx, mediaImage, mx, my, frameW, mediaH);
      const fade = ctx.createLinearGradient(0, my + mediaH * 0.58, 0, my + mediaH);
      fade.addColorStop(0, 'rgba(0,0,0,0)');
      fade.addColorStop(1, 'rgba(0,0,0,0.68)');
      ctx.fillStyle = fade;
      ctx.fillRect(mx, my + mediaH * 0.58, frameW, mediaH * 0.42);
    } else {
      ctx.font = '800 60px Syne, Inter, sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillStyle = 'rgba(244,247,245,0.9)';
      ctx.fillText('BuddyUp', mx + frameW / 2, my + mediaH / 2 - 14);
      ctx.font = '500 24px Inter, sans-serif';
      ctx.fillStyle = 'rgba(155,166,159,0.9)';
      ctx.fillText(media.type === 'video' ? 'Video post' : 'Post', mx + frameW / 2, my + mediaH / 2 + 44);
    }

    if (media.type === 'video') {
      ctx.beginPath();
      ctx.arc(mx + frameW / 2, my + mediaH / 2, 48, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(0,0,0,0.55)';
      ctx.fill();
      ctx.beginPath();
      ctx.moveTo(mx + frameW / 2 - 13, my + mediaH / 2 - 20);
      ctx.lineTo(mx + frameW / 2 + 21, my + mediaH / 2);
      ctx.lineTo(mx + frameW / 2 - 13, my + mediaH / 2 + 20);
      ctx.closePath();
      ctx.fillStyle = TEXT;
      ctx.fill();
    }

    // Post-type badge over the media.
    ctx.font = '700 18px Inter, sans-serif';
    const badge = 'BUDDYUP POST';
    const badgeW = ctx.measureText(badge).width + 28;
    roundedRect(ctx, mx + padding, my + padding, badgeW, 36, 18);
    ctx.fillStyle = 'rgba(0,0,0,0.55)';
    ctx.fill();
    ctx.fillStyle = 'rgba(34,197,94,0.95)';
    ctx.textAlign = 'left';
    ctx.textBaseline = 'middle';
    ctx.fillText(badge, mx + padding + 14, my + padding + 19);

    // Bottom-left watermark on the media.
    drawWatermark(ctx, mx + padding, my + mediaH - 26, true);
    ctx.restore();

    cursorY = frameY + mediaH + 8;
  }

  // Author row inside the post frame.
  const author = post.author_data;
  const avatarImage = author?.avatar_url ? await loadBitmap(author.avatar_url) : null;
  drawAvatar(ctx, avatarImage as HTMLImageElement | null, author?.display_name || '', frameX + padding, cursorY + 12, 64);

  ctx.textAlign = 'left';
  ctx.textBaseline = 'alphabetic';
  ctx.font = '700 32px Inter, sans-serif';
  ctx.fillStyle = TEXT;
  ctx.fillText(author?.display_name || 'BuddyUp member', frameX + padding + 82, cursorY + 42);
  ctx.font = '500 23px Inter, sans-serif';
  ctx.fillStyle = MUTED;
  ctx.fillText(author?.username ? `@${author.username}` : '', frameX + padding + 82, cursorY + 74);
  cursorY += authorH;

  if (hasCommunity) {
    ctx.font = '600 20px Inter, sans-serif';
    const label = post.community_name as string;
    const pillW = Math.min(ctx.measureText(label).width + 34, 500);
    roundedRect(ctx, frameX + padding, cursorY - 4, pillW, 38, 19);
    ctx.fillStyle = 'rgba(34,197,94,0.14)';
    ctx.fill();
    ctx.strokeStyle = 'rgba(34,197,94,0.35)';
    ctx.lineWidth = 1.5;
    ctx.stroke();
    ctx.fillStyle = GREEN;
    ctx.textBaseline = 'middle';
    ctx.fillText(label, frameX + padding + 17, cursorY + 15, pillW - 34);
    cursorY += pillH + 8;
  }

  // Caption inside the post frame.
  if (bodyLines.length) {
    ctx.font = '500 34px Inter, sans-serif';
    ctx.fillStyle = TEXT;
    ctx.textBaseline = 'top';
    let y = cursorY + 10;
    for (const line of bodyLines) {
      ctx.fillText(line, frameX + padding, y);
      y += 46;
    }
    cursorY = y;
  }

  // Bottom-left watermark inside the post frame when there is no media.
  if (!media) {
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

  const blob = await new Promise<Blob>((resolve, reject) => {
    canvas.toBlob((result) => {
      if (result) resolve(result);
      else reject(new Error('Could not render the share card'));
    }, 'image/png');
  });

  const withMeta = await withPngMetadata(blob, post, options.url);
  return new File([withMeta], `buddyup-${post.id}.png`, { type: 'image/png' });
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
