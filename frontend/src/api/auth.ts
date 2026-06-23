import { apiClient } from './client';
import type { ApiResponse, User, Profile } from '@/types';

export interface RegisterPayload {
  email: string; phone?: string; password: string; dob: string;
  username: string; display_name: string; role: string;
  accepted_terms: boolean; accepted_privacy: boolean; accepted_guidelines: boolean; is_16_plus: boolean;
}

export interface LoginPayload { email: string; password: string; remember_me?: boolean; }

export interface TokenResponse { access: string; refresh: string; user: User; profile: Profile; }

export interface OnboardingPayload {
  primary_goal: string[]; activity_level: string; preferred_workouts: string[];
  dietary_preference: string; preferred_time: string; discovery_source?: string;
}

export const authApi = {
  register: (data: RegisterPayload) => apiClient.post<ApiResponse<TokenResponse>>('/auth/register/', data).then((r) => r.data),
  login: (data: LoginPayload) => apiClient.post<ApiResponse<TokenResponse>>('/auth/login/', data).then((r) => r.data),
  logout: () => apiClient.post('/auth/logout/').then((r) => r.data),
  refreshToken: (refresh: string) => apiClient.post<ApiResponse<{ access: string }>>('/auth/token/refresh/', { refresh }).then((r) => r.data),
  verifyOtp: (otp: string, channel: 'email' | 'phone') => apiClient.post<ApiResponse<null>>('/auth/verify-otp/', { otp, channel }).then((r) => r.data),
  resendOtp: (channel: 'email' | 'phone') => apiClient.post<ApiResponse<null>>('/auth/resend-otp/', { channel }).then((r) => r.data),
  completeOnboarding: (data: OnboardingPayload) => apiClient.post<ApiResponse<Profile>>('/auth/onboarding/', data).then((r) => r.data),
  forgotPassword: (email: string) => apiClient.post<ApiResponse<null>>('/auth/forgot-password/', { email }).then((r) => r.data),
  resetPassword: (token: string, new_password: string) => apiClient.post<ApiResponse<null>>('/auth/reset-password/', { token, new_password }).then((r) => r.data),
  googleLogin: (access_token: string) => apiClient.post<ApiResponse<TokenResponse>>('/auth/google/', { access_token }).then((r) => r.data),
  appleLogin: (access_token: string) => apiClient.post<ApiResponse<TokenResponse>>('/auth/apple/', { access_token }).then((r) => r.data),
};
