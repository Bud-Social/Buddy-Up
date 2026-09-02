/**
 * Cloudinary signed uploads for the create studio.
 *
 * Flow: POST /uploads/sign/ → XHR multipart POST to the signed upload URL
 * (progress + abort + one automatic retry on network error) → mapped
 * UploadedMedia. If the backend answers 503 for the sign step we
 * feature-detect that Cloudinary is unavailable and fall back to the
 * existing direct-upload endpoint with the same resulting shape.
 */
import { feedApi } from '@/api/feed';

export interface UploadedMedia {
  url: string;
  poster_url?: string;
  width?: number;
  height?: number;
  duration_ms?: number;
  bytes?: number;
}

/** Byte-accurate upload progress snapshot (XHR/Axios give loaded + total). */
export interface UploadProgress {
  pct: number;
  loadedBytes: number;
  totalBytes: number;
}

export interface UploadOptions {
  onProgress?: (progress: UploadProgress) => void;
  signal?: AbortSignal;
}

interface CloudinaryUploadResponse {
  secure_url: string;
  eager?: Array<{ secure_url?: string }>;
  width?: number;
  height?: number;
  /** Seconds — video only. */
  duration?: number;
  bytes?: number;
}

export class UploadError extends Error {
  /** True when the request never reached the server (offline, CORS, reset). */
  network: boolean;
  status?: number;
  constructor(message: string, opts: { network?: boolean; status?: number } = {}) {
    super(message);
    this.name = 'UploadError';
    this.network = opts.network ?? false;
    this.status = opts.status;
  }
}

/** Map a Cloudinary upload response to our media shape (pure — unit tested). */
export function mapCloudinaryResponse(json: CloudinaryUploadResponse): UploadedMedia {
  return {
    url: json.secure_url,
    poster_url: json.eager?.[0]?.secure_url,
    width: json.width,
    height: json.height,
    duration_ms: typeof json.duration === 'number' ? Math.round(json.duration * 1000) : undefined,
    bytes: json.bytes,
  };
}

function resourceTypeFor(file: File): 'image' | 'video' {
  if (file.type.startsWith('video/')) return 'video';
  return 'image';
}

function isHttp503(err: unknown): boolean {
  return (
    typeof err === 'object' &&
    err !== null &&
    'response' in err &&
    typeof (err as { response?: { status?: number } }).response === 'object' &&
    (err as { response?: { status?: number } }).response?.status === 503
  );
}

/**
 * Pull a human-readable message out of an error response body so the UI can
 * surface the server's actual reason (Cloudinary `{error:{message}}`,
 * DRF `{detail}` / `{message}` / field errors, or a plain JSON string).
 */
export function extractServerError(data: unknown, fallback = ''): string {
  if (typeof data === 'string') {
    const s = data.trim();
    if (!s) return fallback;
    try {
      return extractServerError(JSON.parse(s), fallback);
    } catch {
      return s.slice(0, 300);
    }
  }
  if (Array.isArray(data)) {
    for (const entry of data) {
      const msg = extractServerError(entry, '');
      if (msg) return msg;
    }
    return fallback;
  }
  if (data && typeof data === 'object') {
    const obj = data as Record<string, unknown>;
    for (const key of ['detail', 'message', 'error']) {
      if (key in obj) {
        const msg = extractServerError(obj[key], '');
        if (msg) return msg;
      }
    }
    for (const value of Object.values(obj)) {
      const msg = extractServerError(value, '');
      if (msg) return msg;
    }
  }
  return fallback;
}

function xhrErrorMessage(xhr: XMLHttpRequest): string | undefined {
  return extractServerError(xhr.responseText, '') || undefined;
}

function sendOnce(
  url: string,
  form: FormData,
  opts: UploadOptions,
): Promise<CloudinaryUploadResponse> {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    xhr.open('POST', url);

    let settled = false;
    const settle = (fn: () => void) => {
      if (settled) return;
      settled = true;
      if (opts.signal) opts.signal.removeEventListener('abort', onAbort);
      fn();
    };

    const onAbort = () => xhr.abort();
    if (opts.signal) {
      if (opts.signal.aborted) {
        reject(new DOMException('The upload was aborted.', 'AbortError'));
        return;
      }
      opts.signal.addEventListener('abort', onAbort);
    }

    xhr.upload.onprogress = (e) => {
      if (e.lengthComputable && opts.onProgress) {
        opts.onProgress({
          pct: Math.min(100, Math.round((e.loaded / e.total) * 100)),
          loadedBytes: e.loaded,
          totalBytes: e.total,
        });
      }
    };
    xhr.onload = () => {
      if (xhr.status >= 200 && xhr.status < 300) {
        let json: CloudinaryUploadResponse | null = null;
        try {
          json = JSON.parse(xhr.responseText) as CloudinaryUploadResponse;
        } catch {
          json = null;
        }
        if (json?.secure_url) settle(() => resolve(json!));
        else settle(() => reject(new UploadError('Malformed upload response.', { status: xhr.status })));
      } else {
        const serverMsg = xhrErrorMessage(xhr);
        settle(() =>
          reject(
            new UploadError(serverMsg ?? `Upload failed (${xhr.status}).`, { status: xhr.status }),
          ),
        );
      }
    };
    xhr.onerror = () => settle(() => reject(new UploadError('Network error during upload.', { network: true })));
    xhr.onabort = () => settle(() => reject(new DOMException('The upload was aborted.', 'AbortError')));

    xhr.send(form);
  });
}

async function xhrUploadWithRetry(
  url: string,
  form: FormData,
  opts: UploadOptions,
): Promise<CloudinaryUploadResponse> {
  try {
    return await sendOnce(url, form, opts);
  } catch (err) {
    // Abort and HTTP-level failures surface immediately; exactly one
    // automatic retry is granted for network-level errors.
    if (err instanceof DOMException && err.name === 'AbortError') throw err;
    if (err instanceof UploadError && err.network) {
      return sendOnce(url, form, opts);
    }
    throw err;
  }
}

function isAxiosCancel(err: unknown): boolean {
  return (
    typeof err === 'object' &&
    err !== null &&
    'code' in err &&
    (err as { code?: unknown }).code === 'ERR_CANCELED'
  );
}

async function fallbackUpload(file: File, opts: UploadOptions): Promise<UploadedMedia> {
  try {
    const res = await feedApi.uploadPostMedia(file, { onProgress: opts.onProgress, signal: opts.signal });
    const data = res.data;
    if (!data?.url) throw new UploadError('Fallback upload returned no URL.', { network: true });
    return { url: data.url, bytes: data.size };
  } catch (err) {
    // Normalize axios cancel to the same AbortError the XHR path throws.
    if (isAxiosCancel(err)) throw new DOMException('The upload was aborted.', 'AbortError');
    const status = (err as { response?: { status?: number } })?.response?.status;
    const serverMsg = extractServerError((err as { response?: { data?: unknown } })?.response?.data, '');
    if (serverMsg) throw new UploadError(serverMsg, { status });
    throw err;
  }
}

/**
 * Upload a picked file, reporting byte-accurate progress via `onProgress`.
 * Cancelling `signal` rejects with an AbortError.
 */
export async function uploadToCloudinary(file: File, opts: UploadOptions = {}): Promise<UploadedMedia> {
  let sign;
  try {
    const res = await feedApi.signUpload(resourceTypeFor(file), file.name);
    sign = res.data;
  } catch (err) {
    // Feature-detect: no Cloudinary wiring on this deployment yet.
    if (isHttp503(err)) return fallbackUpload(file, opts);
    throw err;
  }
  if (!sign?.upload_url) return fallbackUpload(file, opts);

  const form = new FormData();
  form.append('file', file);
  form.append('api_key', sign.api_key);
  form.append('timestamp', String(sign.timestamp));
  form.append('signature', sign.signature);
  form.append('folder', sign.folder);
  if (sign.eager) form.append('eager', sign.eager);

  const json = await xhrUploadWithRetry(sign.upload_url, form, opts);
  return mapCloudinaryResponse(json);
}

// ─── Image compression ───────────────────────────────────────────────────────

const MAX_DIMENSION = 1440;
const COMPRESS_MIN_BYTES = 300 * 1024;

function loadImage(file: File): Promise<{
  width: number;
  height: number;
  draw: (ctx: CanvasRenderingContext2D, w: number, h: number) => void;
  cleanup: () => void;
}> {
  if (typeof createImageBitmap === 'function') {
    return createImageBitmap(file).then((bmp) => ({
      width: bmp.width,
      height: bmp.height,
      draw: (ctx, w, h) => ctx.drawImage(bmp, 0, 0, w, h),
      cleanup: () => bmp.close(),
    }));
  }
  return new Promise((resolve, reject) => {
    const img = new Image();
    const url = URL.createObjectURL(file);
    // Some embedded environments never fire load/error events — bound the wait.
    const timeout = setTimeout(() => {
      URL.revokeObjectURL(url);
      reject(new Error('Image decode timed out.'));
    }, 4000);
    img.onload = () => {
      clearTimeout(timeout);
      resolve({
        width: img.naturalWidth,
        height: img.naturalHeight,
        draw: (ctx, w, h) => ctx.drawImage(img, 0, 0, w, h),
        cleanup: () => URL.revokeObjectURL(url),
      });
    };
    img.onerror = () => {
      clearTimeout(timeout);
      URL.revokeObjectURL(url);
      reject(new Error('Could not decode image.'));
    };
    img.src = url;
  });
}

/**
 * Downscale images to at most 1440px on the long edge and re-encode as
 * WebP (quality 0.85) to keep uploads small. Skips anything that is not
 * an image or already under 300KB; never throws — falls back to the
 * original file on any decoding/encoding failure.
 */
export async function compressImage(file: File): Promise<File> {
  if (!file.type.startsWith('image/') || file.size < COMPRESS_MIN_BYTES) return file;
  try {
    const img = await loadImage(file);
    try {
      const scale = Math.min(1, MAX_DIMENSION / Math.max(img.width, img.height));
      const w = Math.max(1, Math.round(img.width * scale));
      const h = Math.max(1, Math.round(img.height * scale));
      const canvas = document.createElement('canvas');
      const ctx = canvas.getContext('2d');
      if (!ctx) return file;
      canvas.width = w;
      canvas.height = h;
      img.draw(ctx, w, h);
      const blob = await new Promise<Blob | null>((resolve) =>
        canvas.toBlob(resolve, 'image/webp', 0.85),
      );
      if (!blob) return file;
      const base = file.name.replace(/\.[^.]+$/, '');
      return new File([blob], `${base || 'image'}.webp`, { type: 'image/webp' });
    } finally {
      img.cleanup();
    }
  } catch {
    return file;
  }
}
