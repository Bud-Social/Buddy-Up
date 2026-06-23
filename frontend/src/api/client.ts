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
    if (error.response?.status === 401 && !orig._retry) {
      if (isRefreshing) {
        return new Promise((resolve, reject) => {
          failedQueue.push({ resolve: (t: string) => { orig.headers.Authorization = `Bearer ${t}`; resolve(apiClient(orig)); }, reject });
        });
      }
      orig._retry = true; isRefreshing = true;
      try {
        const refreshToken = useAuthStore.getState().refreshToken;
        const r = await axios.post(`${API_BASE_URL}/auth/token/refresh/`, { refresh: refreshToken });
        const { access } = r.data;
        useAuthStore.getState().setAccessToken(access);
        processQueue(null, access);
        orig.headers.Authorization = `Bearer ${access}`;
        return apiClient(orig);
      } catch (e) {
        processQueue(e, null);
        useAuthStore.getState().logout();
        throw e;
      } finally { isRefreshing = false; }
    }
    throw error;
  },
);
