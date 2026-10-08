import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import type { ApiResponse, Pagination } from '@/types';
import { adminPortalErrorMessage, portalListItems } from '@/api/adminPortal';

export const PAGE_SIZE = 25;

export interface PortalListState<T> {
  items: T[];
  count: number;
  page: number;
  pageCount: number;
  loading: boolean;
  error: string;
  reload: (silent?: boolean) => void;
  goToPage: (page: number) => void;
}

/**
 * One hook for every paginated admin list so loading / empty / error / paging
 * behave identically across the console.
 *
 * Deliberate choices:
 * - an in-flight request is never allowed to overwrite a newer one (a stale
 *   slow response must not clobber the result of a filter change);
 * - `silent` reloads (post-mutation) keep the current rows on screen instead of
 *   flashing the skeleton;
 * - errors carry the server's own `message`, not a generic string.
 */
export function usePortalList<T>(
  fetcher: (params: Record<string, unknown>) => Promise<ApiResponse<T[]>>,
  filters: Record<string, unknown>,
): PortalListState<T> {
  const [items, setItems] = useState<T[]>([]);
  const [count, setCount] = useState(0);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [nonce, setNonce] = useState(0);
  const requestId = useRef(0);
  // Held in a ref so an inline (unstable) fetcher never re-triggers the effect.
  const fetcherRef = useRef(fetcher);
  fetcherRef.current = fetcher;

  const filterKey = useMemo(() => JSON.stringify(filters), [filters]);

  const reload = useCallback((silent = false) => {
    if (!silent) setLoading(true);
    setError('');
    setNonce((n) => n + 1);
  }, []);

  useEffect(() => {
    const id = ++requestId.current;
    let cancelled = false;
    const params = { ...JSON.parse(filterKey) as Record<string, unknown>, page, page_size: PAGE_SIZE };
    fetcherRef.current(params)
      .then((res) => {
        if (cancelled || id !== requestId.current) return;
        setItems(portalListItems<T>(res?.data));
        const pagination = res?.pagination as Pagination | null | undefined;
        setCount(typeof pagination?.count === 'number' ? pagination.count : portalListItems<T>(res?.data).length);
        setError('');
      })
      .catch((e) => {
        if (cancelled || id !== requestId.current) return;
        setItems([]);
        setError(adminPortalErrorMessage(e, 'Failed to load.'));
      })
      .finally(() => {
        if (cancelled || id !== requestId.current) return;
        setLoading(false);
      });
    return () => { cancelled = true; };
  }, [filterKey, page, nonce]);

  // Any filter change invalidates the current page offset.
  useEffect(() => { setPage(1); }, [filterKey]);

  const goToPage = useCallback((next: number) => {
    setPage(Math.max(1, next));
  }, []);

  const pageCount = Math.max(1, Math.ceil(count / PAGE_SIZE));

  return { items, count, page, pageCount, loading, error, reload, goToPage };
}

/** Debounce a fast-changing value (search boxes) so we don't spam the API. */
export function useDebounced<T>(value: T, delay = 350): T {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const t = window.setTimeout(() => setDebounced(value), delay);
    return () => window.clearTimeout(t);
  }, [value, delay]);
  return debounced;
}

/**
 * Single in-flight mutation helper: tracks the row being acted on, surfaces the
 * server message on failure, and reports success so callers can reload.
 */
export function usePortalAction() {
  const [actingId, setActingId] = useState<string | null>(null);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');

  const run = useCallback(async <T,>(
    id: string,
    fn: () => Promise<T>,
    messages: { success?: string; failure?: string } = {},
  ): Promise<boolean> => {
    setActingId(id);
    setError('');
    setNotice('');
    try {
      await fn();
      if (messages.success) setNotice(messages.success);
      return true;
    } catch (e) {
      setError(adminPortalErrorMessage(e, messages.failure || 'Action failed.'));
      return false;
    } finally {
      setActingId(null);
    }
  }, []);

  return { actingId, error, notice, run, clearError: () => setError(''), clearNotice: () => setNotice('') };
}