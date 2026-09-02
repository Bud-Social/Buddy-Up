import { beforeEach, describe, expect, it, vi, type Mock } from 'vitest';
import { feedApi } from '@/api/feed';
import { uploadToCloudinary, compressImage, mapCloudinaryResponse, UploadError } from './uploader';

vi.mock('@/api/feed', () => ({
  feedApi: {
    signUpload: vi.fn(),
    uploadPostMedia: vi.fn(),
  },
}));

const mockedSign = feedApi.signUpload as Mock;
const mockedFallback = feedApi.uploadPostMedia as Mock;

const SIGN_RESPONSE = {
  success: true,
  data: {
    cloud_name: 'demo',
    api_key: 'key123',
    timestamp: 1720000000,
    signature: 'sig',
    folder: 'feed',
    resource_type: 'image',
    eager: 'c_limit,w_1440/q_auto',
    upload_url: 'https://api.cloudinary.com/v1_1/demo/image/upload',
  },
};

beforeEach(() => {
  mockedSign.mockReset();
  mockedFallback.mockReset();
});

describe('mapCloudinaryResponse', () => {
  it('maps secure_url, eager poster and duration', () => {
    expect(mapCloudinaryResponse({
      secure_url: 'https://cdn/v.mp4',
      eager: [{ secure_url: 'https://cdn/v.jpg' }],
      width: 1920,
      height: 1080,
      duration: 12.34,
      bytes: 555,
    })).toEqual({
      url: 'https://cdn/v.mp4',
      poster_url: 'https://cdn/v.jpg',
      width: 1920,
      height: 1080,
      duration_ms: 12_340,
      bytes: 555,
    });
  });

  it('tolerates missing optional fields', () => {
    expect(mapCloudinaryResponse({ secure_url: 'https://cdn/i.png' })).toEqual({
      url: 'https://cdn/i.png',
      poster_url: undefined,
      width: undefined,
      height: undefined,
      duration_ms: undefined,
      bytes: undefined,
    });
  });
});

describe('uploadToCloudinary', () => {
  it('falls back to the direct-upload endpoint when sign returns 503', async () => {
    mockedSign.mockRejectedValue({ response: { status: 503 } });
    mockedFallback.mockResolvedValue({
      data: { url: 'https://backend/f.png', mime: 'image/png', file_name: 'f.png', size: 321 },
    });
    const file = new File(['x'], 'f.png', { type: 'image/png' });
    const res = await uploadToCloudinary(file);
    expect(res).toEqual({ url: 'https://backend/f.png', bytes: 321 });
    expect(mockedFallback).toHaveBeenCalledWith(file, expect.objectContaining({ signal: undefined }));
  });

  it('rethrows non-503 sign errors', async () => {
    mockedSign.mockRejectedValue({ response: { status: 401 } });
    await expect(
      uploadToCloudinary(new File(['x'], 'f.png', { type: 'image/png' })),
    ).rejects.toBeTruthy();
    expect(mockedFallback).not.toHaveBeenCalled();
  });

  it('falls back when the sign payload has no upload_url', async () => {
    mockedSign.mockResolvedValue({ success: true, data: null });
    mockedFallback.mockResolvedValue({ data: { url: 'https://backend/f.png', size: 1 } });
    const res = await uploadToCloudinary(new File(['x'], 'v.mp4', { type: 'video/mp4' }));
    expect(res.url).toBe('https://backend/f.png');
  });

  it('performs a signed XHR upload and maps the response', async () => {
    mockedSign.mockResolvedValue(SIGN_RESPONSE);

    const requests: XMLHttpRequest[] = [];
    const originalXhr = globalThis.XMLHttpRequest;
    class FakeXhr {
      upload = { onprogress: null as unknown };
      onload: (() => void) | null = null;
      onerror: (() => void) | null = null;
      onabort: (() => void) | null = null;
      status = 200;
      responseText = JSON.stringify({
        secure_url: 'https://cdn/up.mp4',
        eager: [{ secure_url: 'https://cdn/up.jpg' }],
        duration: 5,
        width: 720,
        height: 1280,
        bytes: 999,
      });
      open() {}
      send(form: FormData) {
        requests.push(this as unknown as XMLHttpRequest);
        expect(form.get('api_key')).toBe('key123');
        expect(form.get('signature')).toBe('sig');
        expect(form.get('folder')).toBe('feed');
        expect(form.get('eager')).toBe('c_limit,w_1440/q_auto');
        expect(form.get('file')).toBeTruthy();
        queueMicrotask(() => this.onload?.());
      }
      addEventListener() {}
      removeEventListener() {}
    }
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (globalThis as any).XMLHttpRequest = FakeXhr;
    try {
      const res = await uploadToCloudinary(new File(['x'], 'v.mp4', { type: 'video/mp4' }));
      expect(res).toEqual({
        url: 'https://cdn/up.mp4',
        poster_url: 'https://cdn/up.jpg',
        width: 720,
        height: 1280,
        duration_ms: 5000,
        bytes: 999,
      });
      expect(requests).toHaveLength(1);
    } finally {
      globalThis.XMLHttpRequest = originalXhr;
    }
  });

  it('surfaces UploadError without retrying on HTTP failures', async () => {
    mockedSign.mockResolvedValue(SIGN_RESPONSE);
    const originalXhr = globalThis.XMLHttpRequest;
    class FakeXhr {
      upload = { onprogress: null as unknown };
      onload: (() => void) | null = null;
      onerror: (() => void) | null = null;
      status = 401;
      responseText = '';
      open() {}
      send() {
        queueMicrotask(() => this.onload?.());
      }
      addEventListener() {}
      removeEventListener() {}
    }
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (globalThis as any).XMLHttpRequest = FakeXhr;
    try {
      await expect(
        uploadToCloudinary(new File(['x'], 'f.png', { type: 'image/png' })),
      ).rejects.toMatchObject({ name: 'UploadError', status: 401 });
    } finally {
      globalThis.XMLHttpRequest = originalXhr;
    }
  });

  it('retries once on network error and then succeeds', async () => {
    mockedSign.mockResolvedValue(SIGN_RESPONSE);
    const originalXhr = globalThis.XMLHttpRequest;
    let attempts = 0;
    class FakeXhr {
      upload = { onprogress: null as unknown };
      onload: (() => void) | null = null;
      onerror: (() => void) | null = null;
      status = 0;
      responseText = '';
      open() {}
      send() {
        attempts += 1;
        const fail = attempts === 1;
        queueMicrotask(() => {
          if (fail) this.onerror?.();
          else {
            this.status = 200;
            this.responseText = JSON.stringify({ secure_url: 'https://cdn/ok.png' });
            this.onload?.();
          }
        });
      }
      addEventListener() {}
      removeEventListener() {}
    }
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (globalThis as any).XMLHttpRequest = FakeXhr;
    try {
      const res = await uploadToCloudinary(new File(['x'], 'f.png', { type: 'image/png' }));
      expect(attempts).toBe(2);
      expect(res.url).toBe('https://cdn/ok.png');
    } finally {
      globalThis.XMLHttpRequest = originalXhr;
    }
  });
});

describe('compressImage', () => {
  it('skips non-image files', async () => {
    const file = new File([new Uint8Array(400_000)], 'a.mp4', { type: 'video/mp4' });
    expect(await compressImage(file)).toBe(file);
  });

  it('skips small images', async () => {
    const file = new File(['tiny'], 'a.png', { type: 'image/png' });
    expect(await compressImage(file)).toBe(file);
  });

  it('falls back to the original file when canvas is unavailable', async () => {
    const big = new File([new Uint8Array(310 * 1024)], 'big.jpg', { type: 'image/jpeg' });
    expect(await compressImage(big)).toBe(big);
  });
});

describe('UploadError', () => {
  it('flags network errors', () => {
    const err = new UploadError('boom', { network: true });
    expect(err.network).toBe(true);
    expect(err.name).toBe('UploadError');
  });
});
