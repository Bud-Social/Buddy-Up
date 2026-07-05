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

export interface RegisterResponse {
  registration_token: string;
  email: string;
  user_id: string;
  message: string;
}

export interface LoginInitResponse {
  require_otp: boolean;
  login_token: string;
  masked_email: string;
}

export interface LoginOTPResponse extends TokenResponse {
  new_device?: boolean;
}

export interface TOTPChallengeResponse extends TokenResponse {}

export interface TOTPSetupResponse {
  secret: string;
  provisioning_uri: string;
  qr_code: string;
}

export interface TOTPChallengeInitResponse {
  require_totp: boolean;
  temp_token: string;
}

export const authApi = {
  register: (data: RegisterPayload) =>
    apiClient.post<ApiResponse<RegisterResponse>>('/auth/register/', data).then((r) => r.data),

  verifyRegistrationOtp: (registration_token: string, otp: string) =>
    apiClient.post<ApiResponse<TokenResponse>>('/auth/verify-registration-otp/', { registration_token, otp }).then((r) => r.data),

  login: (data: LoginPayload) =>
    apiClient.post<ApiResponse<LoginInitResponse>>('/auth/login/', data).then((r) => r.data),

  verifyLoginOtp: (login_token: string, otp: string, remember_me?: boolean) =>
    apiClient.post<ApiResponse<LoginOTPResponse | TOTPChallengeInitResponse>>('/auth/verify-login-otp/', { login_token, otp, remember_me }).then((r) => r.data),

  totpChallenge: (temp_token: string, code: string) =>
    apiClient.post<ApiResponse<TOTPChallengeResponse>>('/auth/totp/challenge/', { temp_token, code }).then((r) => r.data),

  setupTotp: () =>
    apiClient.get<ApiResponse<TOTPSetupResponse>>('/auth/totp/setup/').then((r) => r.data),

  verifyTotp: (secret: string, code: string) =>
    apiClient.post<ApiResponse<null>>('/auth/totp/verify/', { secret, code }).then((r) => r.data),

  disableTotp: (password: string) =>
    apiClient.post<ApiResponse<null>>('/auth/totp/disable/', { password }).then((r) => r.data),

  logout: () => apiClient.post('/auth/logout/').then((r) => r.data),
  refreshToken: (refresh: string) => apiClient.post<ApiResponse<{ access: string; refresh?: string }>>('/auth/token/refresh/', { refresh }).then((r) => r.data),
  verifyOtp: (otp: string, channel: 'email' | 'phone') => apiClient.post<ApiResponse<null>>('/auth/verify-otp/', { otp, channel }).then((r) => r.data),
  resendOtp: (channel: 'email' | 'phone') => apiClient.post<ApiResponse<null>>('/auth/resend-otp/', { channel }).then((r) => r.data),
  completeOnboarding: (data: OnboardingPayload) => apiClient.post<ApiResponse<Profile>>('/auth/onboarding/', data).then((r) => r.data),
  forgotPassword: (email: string) => apiClient.post<ApiResponse<null>>('/auth/forgot-password/', { email }).then((r) => r.data),
  resetPassword: (token: string, new_password: string) => apiClient.post<ApiResponse<null>>('/auth/reset-password/', { token, new_password }).then((r) => r.data),
  googleLogin: (credential: string) => apiClient.post<ApiResponse<TokenResponse>>('/auth/google/', { credential }).then((r) => r.data),
  appleLogin: (access_token: string) => apiClient.post<ApiResponse<TokenResponse>>('/auth/apple/', { access_token }).then((r) => r.data),
};
