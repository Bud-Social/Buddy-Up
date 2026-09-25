import axios, { type AxiosError, type InternalAxiosRequestConfig } from 'axios';
import { useAuthStore } from '@/store/authStore';
import { getDeviceId } from '@/lib/device';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8002/api/v1';

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: { 'Content-Type': 'application/json', 'X-Device-Id': getDeviceId() },
  timeout: 15000,
});

let isRefreshing = false;
let failedQueue: Array<{ resolve: (token: string) => void; reject: (error: unknown) => void }> = [];

const processQueue = (error: unknown, token: string | null = null) => {
  failedQueue.forEach((p) => { if (error) p.reject(error); else p.resolve(token!); });
  failedQueue = [];
};

const doRefresh = async (): Promise<string> => {
  const refreshToken = useAuthStore.getState().refreshToken;
  // SECURITY: the web client authenticates the refresh via the httpOnly
  // refresh cookie (backend sets it at login and re-sets it, rotated, on
  // every refresh). A body token is sent ONLY while migrating legacy
  // sessions that still have one in storage — after the first successful
  // refresh the cookie takes over and nothing token-shaped is persisted.
  // X-Device-Id is required for cookie-authenticated refreshes: being a
  // custom header it forces a CORS preflight, which bounds CSRF to the
  // backend's origin allowlist.
  const res = await axios.post(
    `${API_BASE_URL}/auth/token/refresh/`,
    refreshToken ? { refresh: refreshToken } : {},
    { withCredentials: true, headers: { 'Content-Type': 'application/json', 'X-Device-Id': getDeviceId() } },
  );
  const { access, refresh: newRefresh } = res.data?.data || res.data;
  if (!access) throw new Error('No access token in response');
  // The rotated refresh token (when present — body/migration path) stays in
  // memory only; cookie clients never receive it in the body at all.
  useAuthStore.getState().setTokens(access, newRefresh ?? null);
  return access;
};

/**
 * Refresh the access token. Deduplicated: concurrent callers share one
 * in-flight refresh (the backend rotates refresh tokens, so firing two in
 * parallel would invalidate the first rotation).
 */
export const refreshAccessToken = (): Promise<string> => {
  if (isRefreshing) {
    return new Promise((resolve, reject) => { failedQueue.push({ resolve, reject }); });
  }
  isRefreshing = true;
  return doRefresh()
    .then((access) => { processQueue(null, access); return access; })
    .catch((e) => { processQueue(e, null); throw e; })
    .finally(() => { isRefreshing = false; });
};

/** True when the refresh failed with a definitive client error (session gone). */
export const isAuthRefreshRejection = (e: unknown): boolean => {
  const status = (e as { response?: { status?: number } })?.response?.status;
  return !!status && status >= 400 && status < 500;
};

apiClient.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  const token = useAuthStore.getState().accessToken;
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

apiClient.interceptors.response.use(
  (r) => r,
  async (error: AxiosError) => {
    const orig = error.config as InternalAxiosRequestConfig & { _retry?: boolean };
    // Never attempt token refresh for the auth flow itself — a failed login
    // must surface its own error ("Invalid credentials"), not a refresh 400.
    const url = orig?.url || '';
    const isAuthFlow = /\/auth\/(login|register|token\/refresh|google|apple|verify-login-otp|verify-registration-otp|totp\/challenge|forgot-password|reset-password|social\/age-setup)\//.test(url);
    if (error.response?.status === 401 && !orig._retry && !isAuthFlow) {
      orig._retry = true;
      try {
        const access = await refreshAccessToken();
        orig.headers.Authorization = `Bearer ${access}`;
        return apiClient(orig);
      } catch (e) {
        // Only a definitive auth rejection (4xx) ends the session — a
        // network hiccup must not log the user out.
        if (isAuthRefreshRejection(e)) {
          useAuthStore.getState().logout();
        }
        throw error;
      }
    }
    // Consent gate: the backend blocks app APIs until the current policies are
    // accepted. Route the user to onboarding, where the acceptance happens.
    if (error.response?.status === 403) {
      const payload = error.response.data as { data?: { consent_required?: boolean } } | undefined;
      if (payload?.data?.consent_required && !window.location.pathname.startsWith('/onboarding')) {
        window.location.href = '/onboarding';
      }
    }
    throw error;
  },
);
