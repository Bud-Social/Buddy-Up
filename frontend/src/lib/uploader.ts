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
import {
  fingerprintFile,
  normalizeTrimExport,
  shouldExportTrimmedVideo,
  trimCacheKeyFor,
  trimmedVideoBitrate,
  trimmedVideoFilename,
  type TrimExportPlan,
} from './createStudio';

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
 * Client-side video trimming for Bud Press publishes.
 *
 * TikTok uploads only the selected snippet: when a trim removes footage from
 * either end, this re-encodes just [start_ms, end_ms) with MediaRecorder and
 * returns the smaller file. It never throws for recoverable failures — callers
 * fall back to the original file and keep the parametric trim instead.
 */
export interface TrimVideoOptions {
  durationMs?: number | null;
  signal?: AbortSignal;
  onProgress?: (ratio: number) => void;
  timeoutMs?: number;
}

export interface TrimVideoResult {
  file: File;
  trimmed: boolean;
  duration_ms: number | null;
}

const TRIM_EXPORT_TOLERANCE_MS = 250;
const TRIM_METADATA_TIMEOUT_MS = 15_000;
const TRIM_SEEK_TIMEOUT_MS = 15_000;

function trimAbortError(): DOMException {
  return new DOMException('The trim was aborted.', 'AbortError');
}

function throwIfTrimAborted(signal?: AbortSignal | null): void {
  if (signal?.aborted) throw trimAbortError();
}

export function pickSupportedMimeType(
  candidates: string[],
  isTypeSupported?: (mimeType: string) => boolean,
): string {
  const check = isTypeSupported ?? ((mimeType: string) => {
    try {
      return typeof MediaRecorder !== 'undefined' && MediaRecorder.isTypeSupported(mimeType);
    } catch {
      return false;
    }
  });
  for (const candidate of candidates) {
    try {
      if (check(candidate)) return candidate;
    } catch {
      // Try the next container/codec combination.
    }
  }
  return '';
}

function waitForVideoEvent(
  video: HTMLVideoElement,
  name: 'loadedmetadata' | 'seeked' | 'error',
  signal: AbortSignal | undefined,
  timeoutMs: number,
): Promise<void> {
  return new Promise((resolve, reject) => {
    let settled = false;
    const timeout = { id: undefined as ReturnType<typeof setTimeout> | undefined };
    const cleanup = () => {
      if (timeout.id) clearTimeout(timeout.id);
      video.removeEventListener(name, onEvent);
      video.removeEventListener('error', onError);
      signal?.removeEventListener('abort', onAbort);
    };
    const finish = (fn: () => void) => {
      if (settled) return;
      settled = true;
      cleanup();
      fn();
    };
    const onEvent = () => finish(() => resolve());
    const onError = () => finish(() => reject(new Error(`Video ${name} failed.`)));
    const onAbort = () => finish(() => reject(trimAbortError()));
    const onTimeout = () => finish(() => reject(new Error(`Video ${name} timed out.`)));
    if (signal?.aborted) {
      onAbort();
      return;
    }
    video.addEventListener(name, onEvent, { once: true });
    video.addEventListener('error', onError, { once: true });
    signal?.addEventListener('abort', onAbort, { once: true });
    timeout.id = setTimeout(onTimeout, timeoutMs);
  });
}

async function resumeExportAudio(signal: AbortSignal | undefined, ctx: AudioContext): Promise<boolean> {
  try {
    await Promise.race([
      ctx.resume().catch(() => undefined),
      new Promise<void>((resolve, reject) => {
        const timer = setTimeout(() => resolve(), 1500);
        const onAbort = () => {
          clearTimeout(timer);
          reject(trimAbortError());
        };
        if (signal?.aborted) {
          clearTimeout(timer);
          onAbort();
          return;
        }
        signal?.addEventListener('abort', onAbort, { once: true });
      }),
    ]);
  } catch (err) {
    throwIfTrimAborted(signal);
    return false;
  }
  return ctx.state === 'running';
}

export async function trimVideoFile(
  file: File,
  startMs: number,
  endMs: number,
  opts: TrimVideoOptions = {},
): Promise<TrimVideoResult> {
  const signal = opts.signal;
  throwIfTrimAborted(signal);
  const fallbackDuration = opts.durationMs ?? null;
  if (!file.type.startsWith('video/')) return { file, trimmed: false, duration_ms: fallbackDuration };
  if (typeof document === 'undefined' || typeof MediaRecorder === 'undefined') {
    return { file, trimmed: false, duration_ms: fallbackDuration };
  }

  let objectUrl: string | null = null;
  let video: HTMLVideoElement | null = null;
  let audioCtx: AudioContext | null = null;
  let stream: MediaStream | null = null;
  const cleanup = () => {
    try {
      video?.pause();
    } catch {
      // Already stopped.
    }
    stream?.getTracks().forEach((track) => {
      try {
        track.stop();
      } catch {
        // Already stopped.
      }
    });
    if (audioCtx) {
      void audioCtx.close().catch(() => undefined);
      audioCtx = null;
    }
    if (objectUrl) {
      URL.revokeObjectURL(objectUrl);
      objectUrl = null;
    }
    video = null;
    stream = null;
  };

  try {
    video = document.createElement('video');
    video.preload = 'auto';
    video.playsInline = true;
    video.disablePictureInPicture = true;
    // Muted playback is autoplay-friendly while loading/seeking. The element
    // is unmuted below for export: once a media-element source exists, its
    // output is rerouted into the graph, so connecting only the recorder
    // destination keeps the export silent while preserving the audio track.
    video.muted = true;
    video.volume = 0;
    objectUrl = URL.createObjectURL(file);
    video.src = objectUrl;
    await waitForVideoEvent(video, 'loadedmetadata', signal, opts.timeoutMs ?? TRIM_METADATA_TIMEOUT_MS);

    const probedDuration =
      Number.isFinite(video.duration) && video.duration > 0 ? Math.round(video.duration * 1000) : null;
    const sourceDuration = probedDuration ?? opts.durationMs ?? null;
    const plan: TrimExportPlan | null = normalizeTrimExport(startMs, endMs, sourceDuration);
    if (!plan || !shouldExportTrimmedVideo(plan, TRIM_EXPORT_TOLERANCE_MS)) {
      return { file, trimmed: false, duration_ms: plan?.duration_ms ?? sourceDuration };
    }

    throwIfTrimAborted(signal);
    const startSec = plan.start_ms / 1000;
    const segmentSec = plan.duration_ms / 1000;
    try {
      video.currentTime = Math.min(startSec, Math.max(0, (video.duration || startSec) - 0.05));
    } catch {
      return { file, trimmed: false, duration_ms: sourceDuration };
    }
    await waitForVideoEvent(video, 'seeked', signal, opts.timeoutMs ?? TRIM_SEEK_TIMEOUT_MS);

    const capture = (
      video as HTMLVideoElement & {
        captureStream?: () => MediaStream;
        mozCaptureStream?: () => MediaStream;
      }
    ).captureStream ?? (
      video as HTMLVideoElement & { mozCaptureStream?: () => MediaStream }
    ).mozCaptureStream;
    if (!capture) return { file, trimmed: false, duration_ms: sourceDuration };

    // Prefer a silent Web Audio graph so exporting does not play the snippet
    // out loud while still capturing its audio track. Do not connect the
    // source to the speakers: once the source exists, the element output is
    // rerouted, so the recorder destination alone stays silent and complete.
    // Fall back to an audible capture stream only when no running
    // AudioContext is available.
    let recordStream: MediaStream | null = null;
    if (typeof AudioContext !== 'undefined') {
      try {
        audioCtx = new AudioContext();
        if (await resumeExportAudio(signal, audioCtx)) {
          const source = audioCtx.createMediaElementSource(video);
          const destination = audioCtx.createMediaStreamDestination();
          source.connect(destination);
          // Keep the source at full level: muting/volume would also mute the
          // graph feed. Direct speaker output stays rerouted and silent.
          video.muted = false;
          video.volume = 1;
          const captured = capture.call(video);
          if (!captured.getVideoTracks().length) {
            return { file, trimmed: false, duration_ms: sourceDuration };
          }
          recordStream = new MediaStream([
            ...captured.getVideoTracks(),
            ...destination.stream.getAudioTracks(),
          ]);
        } else {
          await audioCtx.close().catch(() => undefined);
          audioCtx = null;
        }
      } catch {
        if (audioCtx) {
          await audioCtx.close().catch(() => undefined);
          audioCtx = null;
        }
      }
    }
    if (!recordStream) {
      video.muted = false;
      video.volume = 1;
      const captured = capture.call(video);
      if (!captured.getVideoTracks().length) {
        return { file, trimmed: false, duration_ms: sourceDuration };
      }
      recordStream = captured;
    }
    stream = recordStream;

    const mimeType = pickSupportedMimeType([
      'video/webm;codecs=vp9,opus',
      'video/webm;codecs=vp8,opus',
      'video/webm',
      'video/mp4',
    ]);
    const recorderOptions: MediaRecorderOptions = {
      videoBitsPerSecond: trimmedVideoBitrate(file.size, plan.duration_ms, sourceDuration),
      audioBitsPerSecond: 128_000,
    };
    if (mimeType) recorderOptions.mimeType = mimeType;
    let recorder: MediaRecorder;
    try {
      recorder = new MediaRecorder(stream, recorderOptions);
    } catch {
      return { file, trimmed: false, duration_ms: sourceDuration };
    }

    const chunks: BlobPart[] = [];
    const recorderDone = new Promise<void>((resolve, reject) => {
      recorder.ondataavailable = (event) => {
        if (event.data && event.data.size > 0) chunks.push(event.data);
      };
      recorder.onerror = () => reject(new Error('Video trim recording failed.'));
      recorder.onstop = () => resolve();
    });
    const waitForSegment = () => new Promise<void>((resolve, reject) => {
      let settled = false;
      const timer = setTimeout(() => {
        try {
          if (recorder.state !== 'inactive') recorder.stop();
        } catch {
          // Recorder already stopped.
        }
        finish(() => resolve());
      }, Math.min(plan.duration_ms + 20_000, 200_000));
      const finish = (fn: () => void) => {
        if (settled) return;
        settled = true;
        clearTimeout(timer);
        video?.removeEventListener('timeupdate', onTimeUpdate);
        signal?.removeEventListener('abort', onAbort);
        fn();
      };
      const onTimeUpdate = () => {
        if (!video) return;
        opts.onProgress?.(
          Math.min(1, Math.max(0, (video.currentTime - startSec) / segmentSec)),
        );
        if (video.currentTime >= startSec + segmentSec - 0.03) {
          try {
            if (recorder.state !== 'inactive') recorder.stop();
          } catch {
            // Recorder already stopped.
          }
        }
      };
      const onAbort = () => {
        try {
          if (recorder.state !== 'inactive') recorder.stop();
        } catch {
          // Recorder already stopped.
        }
        finish(() => reject(trimAbortError()));
      };
      video?.addEventListener('timeupdate', onTimeUpdate);
      if (signal?.aborted) {
        onAbort();
        return;
      }
      signal?.addEventListener('abort', onAbort, { once: true });
      recorderDone.then(
        () => finish(() => resolve()),
        () => finish(() => reject(new Error('Video trim recording failed.'))),
      );
    });

    try {
      await video.play().catch(() => {
        throwIfTrimAborted(signal);
        throw new Error('Video trim playback was blocked.');
      });
    } catch (err) {
      throwIfTrimAborted(signal);
      return { file, trimmed: false, duration_ms: sourceDuration };
    }
    recorder.start(250);
    await waitForSegment();

    const blobType = (recorder.mimeType || mimeType || 'video/webm').split(';')[0];
    const blob = new Blob(chunks, { type: blobType });
    if (!blob.size) return { file, trimmed: false, duration_ms: sourceDuration };
    const trimmed = new File([blob], trimmedVideoFilename(file.name, blob.type || file.type), {
      type: blob.type || file.type,
    });
    return { file: trimmed, trimmed: true, duration_ms: plan.duration_ms };
  } catch (err) {
    throwIfTrimAborted(signal);
    return { file, trimmed: false, duration_ms: fallbackDuration };
  } finally {
    cleanup();
  }
}

/**
 * Upload a picked file, reporting byte-accurate progress via `onProgress`.
 * Cancelling `signal` rejects with an AbortError.
 */
export async function uploadToCloudinary(file: File, opts: UploadOptions = {}): Promise<UploadedMedia> {  let sign;
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

  let json;
  try {
    json = await xhrUploadWithRetry(sign.upload_url, form, opts);
  } catch (err) {
    // Cloudinary rejections that the direct endpoint can genuinely fix
    // (413 too-large, 409 conflicts, 429 rate limits) fall back to the
    // Django upload path; signature/config errors surface as-is.
    if (err instanceof UploadError && [409, 413, 429] .includes(err.status as number)) {
      return fallbackUpload(file, opts);
    }
    throw err;
  }
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
export async function compressImage(file: File): Promise<File> {  if (!file.type.startsWith('image/') || file.size < COMPRESS_MIN_BYTES) return file;
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

// ─── Trimmed-export cache ────────────────────────────────────────────────────
//
// Re-encoding a trimmed snippet is the slowest finalize step. Exports are
// cached by source fingerprint + exact trim bounds, so re-publishes, retries
// and studio↔transcribe round-trips reuse the bytes. Any source or trim
// change misses the key (natural invalidation); the map is count-bounded so
// a long session cannot grow memory without limit.

export const TRIM_EXPORT_CACHE_MAX = 8;

const trimExportCache = new Map<string, { file: File; duration_ms: number | null }>();

export function getCachedTrimExport(key: string): { file: File; duration_ms: number | null } | null {
  return trimExportCache.get(key) ?? null;
}

export function setCachedTrimExport(
  key: string,
  entry: { file: File; duration_ms: number | null },
): void {
  trimExportCache.delete(key); // refresh recency
  trimExportCache.set(key, entry);
  while (trimExportCache.size > TRIM_EXPORT_CACHE_MAX) {
    const oldest = trimExportCache.keys().next();
    if (oldest.done) break;
    trimExportCache.delete(oldest.value);
  }
}

export function clearTrimExportCache(): void {
  trimExportCache.clear();
}

export function trimExportCacheSize(): number {
  return trimExportCache.size;
}

/**
 * Trimmed export with cache lookup. Returns the cached file when the same
 * source + bounds were exported before; otherwise runs trimVideoFile and
 * caches successful exports. Never throws — falls back to the original file
 * exactly like trimVideoFile.
 */
export async function getOrExportTrimmedVideo(
  file: File,
  startMs: number,
  endMs: number,
  opts: TrimVideoOptions = {},
): Promise<TrimVideoResult> {
  const plan = normalizeTrimExport(startMs, endMs, opts.durationMs ?? null);
  if (!plan || !shouldExportTrimmedVideo(plan, TRIM_EXPORT_TOLERANCE_MS)) {
    return { file, trimmed: false, duration_ms: plan?.duration_ms ?? opts.durationMs ?? null };
  }
  const key = trimCacheKeyFor(fingerprintFile(file), plan.start_ms, plan.end_ms);
  const hit = trimExportCache.get(key);
  if (hit) return { file: hit.file, trimmed: true, duration_ms: hit.duration_ms };
  const res = await trimVideoFile(file, plan.start_ms, plan.end_ms, opts);
  if (res.trimmed) setCachedTrimExport(key, { file: res.file, duration_ms: res.duration_ms });
  return res;
}

// ─── Finalize (compress / trim-export) for the background upload queue ───────

export interface FinalizedItem {
  file: File;
  /** True when the file is a physically trimmed snippet. */
  exported: boolean;
  /** Absolute offset of the snippet in the source media (ms). */
  offsetMs: number;
  /** Duration of the finalized file (ms). */
  durationMs: number;
}

/**
 * Prepare one studio item for upload: images are downscaled, videos are cut
 * to the selected snippet (via the trim-export cache). Never throws for
 * recoverable failures — falls back to the original file with parametric
 * trim metadata preserved by the caller.
 */
export async function finalizeStudioItem(
  input: {
    file: File;
    kind: 'image' | 'video';
    trimStartMs?: number | null;
    trimEndMs?: number | null;
    durationMs?: number | null;
  },
  opts: TrimVideoOptions = {},
): Promise<FinalizedItem> {
  const duration = Math.round(input.durationMs ?? 0);
  if (input.kind === 'image') {
    return { file: await compressImage(input.file), exported: false, offsetMs: 0, durationMs: duration };
  }
  const plan = normalizeTrimExport(input.trimStartMs, input.trimEndMs, input.durationMs ?? null);
  if (!plan) return { file: input.file, exported: false, offsetMs: 0, durationMs: duration };
  if (!shouldExportTrimmedVideo(plan, TRIM_EXPORT_TOLERANCE_MS)) {
    return { file: input.file, exported: false, offsetMs: plan.start_ms, durationMs: plan.duration_ms };
  }
  const res = await getOrExportTrimmedVideo(input.file, plan.start_ms, plan.end_ms, {
    ...opts,
    durationMs: input.durationMs ?? null,
  });
  if (!res.trimmed) {
    return { file: input.file, exported: false, offsetMs: plan.start_ms, durationMs: plan.duration_ms };
  }
  return { file: res.file, exported: true, offsetMs: plan.start_ms, durationMs: res.duration_ms ?? plan.duration_ms };
}

// ─── Chunked / resumable video upload ────────────────────────────────────────
//
// Large videos upload in sequential ~6 MB chunks using Cloudinary's
// Content-Range protocol (same signed params + X-Unique-Upload-Id per
// upload). Progress aggregates across chunks, each chunk gets one automatic
// network retry, and AbortSignal cancels between/inside chunks. Anything the
// deployment cannot serve (no sign endpoint, chunk rejection) falls back to
// the single-shot uploadToCloudinary path via uploadFileWithResume.

export const UPLOAD_CHUNK_BYTES = 6 * 1024 * 1024;
export const RESUMABLE_VIDEO_MIN_BYTES = 10 * 1024 * 1024;

export interface UploadChunk {
  index: number;
  count: number;
  /** Inclusive byte range [start, end] of this chunk. */
  start: number;
  end: number;
  total: number;
}

/** Split a file size into sequential inclusive byte ranges (pure). */
export function planUploadChunks(fileSize: number, chunkBytes: number = UPLOAD_CHUNK_BYTES): UploadChunk[] {
  const total = Math.max(0, Math.round(fileSize));
  const size = Math.max(1, Math.round(chunkBytes));
  if (total <= 0) return [];
  const count = Math.max(1, Math.ceil(total / size));
  const chunks: UploadChunk[] = [];
  for (let i = 0; i < count; i++) {
    const start = i * size;
    chunks.push({ index: i, count, start, end: Math.min(total - 1, start + size - 1), total });
  }
  return chunks;
}

/** `bytes 0-6291455/12582912` for the Content-Range header (pure). */
export function formatContentRange(start: number, endInclusive: number, total: number): string {
  return `bytes ${start}-${endInclusive}/${total}`;
}

interface SignParams {
  api_key: string;
  timestamp: number;
  signature: string;
  folder: string;
  eager?: string;
  upload_url: string;
}

function chunkForm(sign: SignParams, chunk: Blob, filename: string): FormData {
  const form = new FormData();
  form.append('file', chunk, filename);
  form.append('api_key', sign.api_key);
  form.append('timestamp', String(sign.timestamp));
  form.append('signature', sign.signature);
  form.append('folder', sign.folder);
  if (sign.eager) form.append('eager', sign.eager);
  return form;
}

function sendChunk(
  url: string,
  form: FormData,
  chunk: UploadChunk,
  uploadId: string,
  opts: UploadOptions,
  baseLoaded: number,
): Promise<CloudinaryUploadResponse> {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    xhr.open('POST', url);
    try {
      xhr.setRequestHeader('Content-Range', formatContentRange(chunk.start, chunk.end, chunk.total));
      xhr.setRequestHeader('X-Unique-Upload-Id', uploadId);
    } catch {
      // Very old XHR stacks may reject custom headers — the server decides.
    }

    let settled = false;
    const settle = (fn: () => void) => {
      if (settled) return;
      settled = true;
      if (opts.signal) opts.signal.removeEventListener('abort', onAbort);
      fn();
    };
    const onAbort = () => {
      try {
        xhr.abort();
      } catch {
        // Already finished.
      }
    };
    if (opts.signal) {
      if (opts.signal.aborted) {
        reject(new DOMException('The upload was aborted.', 'AbortError'));
        return;
      }
      opts.signal.addEventListener('abort', onAbort);
    }

    xhr.upload.onprogress = (e) => {
      if (e.lengthComputable && opts.onProgress) {
        const loaded = baseLoaded + e.loaded;
        const total = chunk.total;
        opts.onProgress({
          pct: total > 0 ? Math.min(100, Math.round((loaded / total) * 100)) : 0,
          loadedBytes: Math.min(total, loaded),
          totalBytes: total,
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
        // Intermediate chunks may answer 200 with a partial body; only the
        // final chunk carries secure_url.
        if (chunk.index < chunk.count - 1) {
          settle(() => resolve({} as CloudinaryUploadResponse));
        } else if (json?.secure_url) {
          settle(() => resolve(json as CloudinaryUploadResponse));
        } else {
          settle(() => reject(new UploadError('Malformed chunked upload response.', { status: xhr.status })));
        }
      } else {
        const serverMsg = xhrErrorMessage(xhr);
        settle(() =>
          reject(new UploadError(serverMsg ?? `Chunk upload failed (${xhr.status}).`, { status: xhr.status })),
        );
      }
    };
    xhr.onerror = () => settle(() => reject(new UploadError('Network error during chunked upload.', { network: true })));
    xhr.onabort = () => settle(() => reject(new DOMException('The upload was aborted.', 'AbortError')));
    xhr.send(form);
  });
}

/**
 * Chunked video upload with per-chunk retry. Rejects with AbortError on
 * cancel; any other failure should be treated as "chunked unsupported" by
 * the caller (single-shot fallback).
 */
export async function uploadToCloudinaryChunked(file: File, opts: UploadOptions = {}): Promise<UploadedMedia> {
  let sign: SignParams;
  try {
    const res = await feedApi.signUpload('video', file.name);
    sign = res.data as SignParams;
  } catch (err) {
    if (isHttp503(err)) return fallbackUpload(file, opts);
    throw err;
  }
  if (!sign?.upload_url) return fallbackUpload(file, opts);

  const chunks = planUploadChunks(file.size);
  if (chunks.length <= 1) return uploadToCloudinary(file, opts);
  const uploadId = (() => {
    try {
      return crypto.randomUUID();
    } catch {
      return `up-${Date.now()}-${Math.floor(Math.random() * 1e9)}`;
    }
  })();

  let done = 0;
  let last: CloudinaryUploadResponse | null = null;
  for (const chunk of chunks) {
    if (opts.signal?.aborted) throw new DOMException('The upload was aborted.', 'AbortError');
    const blob = file.slice(chunk.start, chunk.end + 1, file.type);
    const form = chunkForm(sign, blob, file.name);
    try {
      last = await sendChunk(sign.upload_url, form, chunk, uploadId, opts, done);
    } catch (err) {
      if (err instanceof DOMException && err.name === 'AbortError') throw err;
      if (err instanceof UploadError && err.network) {
        last = await sendChunk(sign.upload_url, form, chunk, uploadId, opts, done); // one retry
      } else {
        throw err;
      }
    }
    done = chunk.end + 1;
    opts.onProgress?.({
      pct: Math.min(100, Math.round((done / chunk.total) * 100)),
      loadedBytes: done,
      totalBytes: chunk.total,
    });
  }
  if (!last?.secure_url) throw new UploadError('Chunked upload returned no URL.', { network: true });
  return mapCloudinaryResponse(last);
}

/**
 * Smart entry point for the upload queue: large videos go chunked (with
 * single-shot fallback when the deployment cannot serve ranges); everything
 * else uploads single-shot. AbortErrors always propagate.
 */
export async function uploadFileWithResume(file: File, opts: UploadOptions = {}): Promise<UploadedMedia> {
  const resumable = file.type.startsWith('video/') && file.size >= RESUMABLE_VIDEO_MIN_BYTES;
  if (!resumable) return uploadToCloudinary(file, opts);
  try {
    return await uploadToCloudinaryChunked(file, opts);
  } catch (err) {
    if (err instanceof DOMException && err.name === 'AbortError') throw err;
    return uploadToCloudinary(file, opts);
  }
}
