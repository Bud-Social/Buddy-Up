import axios, { type AxiosError, type InternalAxiosRequestConfig } from 'axios';
import { useAuthStore } from '@/store/authStore';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8002/api/v1';

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: { 'Content-Type': 'application/json' },
  timeout: 15000,
});

let isRefreshing = false;
let failedQueue: Array<{ resolve: (token: string) => void; reject: (error: unknown) => void }> = [];

const processQueue = (error: unknown, token: string | null = null) => {
  failedQueue.forEach((p) => { if (error) p.reject(error); else p.resolve(token!); });
  failedQueue = [];
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
      const refreshToken = useAuthStore.getState().refreshToken;
      if (!refreshToken) {
        useAuthStore.getState().logout();
        throw error;
      }
      if (isRefreshing) {
        return new Promise((resolve, reject) => {
          failedQueue.push({ resolve: (t: string) => { orig.headers.Authorization = `Bearer ${t}`; resolve(apiClient(orig)); }, reject });
        });
      }
      orig._retry = true; isRefreshing = true;
      try {
        const r = await axios.post(`${API_BASE_URL}/auth/token/refresh/`, { refresh: refreshToken });
        const { access, refresh: newRefresh } = r.data?.data || r.data;
        if (!access) throw new Error('No access token in response');
        useAuthStore.getState().setTokens(access, newRefresh || refreshToken);
        processQueue(null, access);
        orig.headers.Authorization = `Bearer ${access}`;
        return apiClient(orig);
      } catch (e) {
        processQueue(e, null);
        useAuthStore.getState().logout();
        throw error;
      } finally { isRefreshing = false; }
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
