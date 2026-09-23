import { describe, it, expect, vi } from 'vitest';
import { verifyOnline } from '@/lib/connectivity';

describe('verifyOnline', () => {
  it('returns true when the heartbeat succeeds', async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true });
    await expect(verifyOnline(fetchMock)).resolves.toBe(true);
    expect(fetchMock).toHaveBeenCalledWith(
      '/offline.html',
      expect.objectContaining({ method: 'HEAD', cache: 'no-store' }),
    );
  });

  it('returns false on non-ok responses', async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: false });
    await expect(verifyOnline(fetchMock)).resolves.toBe(false);
  });

  it('returns false when the request throws (genuine outage)', async () => {
    const fetchMock = vi.fn().mockRejectedValue(new TypeError('Failed to fetch'));
    await expect(verifyOnline(fetchMock)).resolves.toBe(false);
  });
});
