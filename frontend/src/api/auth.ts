import { apiClient } from './client';
import type { ApiResponse, User, Profile } from '@/types';

export interface RegisterPayload {
  email: string; phone?: string; password: string; dob: string;
  username: string; display_name: string; role: string;
  accepted_terms: boolean; accepted_privacy: boolean; accepted_guidelines: boolean; is_16_plus: boolean;
  guardian_name?: string; guardian_email?: string; guardian_phone?: string;
}

export interface LoginPayload { email: string; password: string; remember_me?: boolean; }

export interface TokenResponse { access: string; refresh: string; user: User; profile: Profile; }

export interface OnboardingPayload {
  primary_goal: string[]; activity_level: string; preferred_workouts: string[];
  dietary_preference: string; preferred_time: string; discovery_source?: string;
  terms_version?: string;
  marketing_consent?: boolean;
  display_name?: string;
  username?: string;
  location_city?: string;
  bio?: string;
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

export interface PolicyVersionMeta {
  version: string;
  updated_at: string;
}

export interface ConsentStatus {
  consent_log: Record<string, unknown>;
  requires_parental_coowner: boolean;
  guardian_verified: boolean;
  policies: Record<string, { current_version: string; accepted_version: string; up_to_date: boolean; updated_at: string }>;
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
  resendRegistrationOtp: (registration_token: string, channel: 'email' | 'phone') =>
    apiClient.post<ApiResponse<null>>('/auth/resend-registration-otp/', { registration_token, channel }).then((r) => r.data),
  completeOnboarding: (data: OnboardingPayload) => apiClient.post<ApiResponse<Profile>>('/auth/onboarding/', data).then((r) => r.data),

  /** Authenticated DOB submission (social signups / age setup). */
  socialAgeSetup: (date_of_birth: string) =>
    apiClient.post<ApiResponse<{ profile: Profile; age: number; is_adult: boolean }>>(
      '/auth/social/age-setup/',
      { date_of_birth },
    ).then((r) => r.data),
  forgotPassword: (email: string) => apiClient.post<ApiResponse<null>>('/auth/forgot-password/', { email }).then((r) => r.data),
  resetPassword: (email: string, token: string, new_password: string) => apiClient.post<ApiResponse<null>>('/auth/reset-password/', { email, token, new_password }).then((r) => r.data),
  googleLogin: (credential: string) => apiClient.post<ApiResponse<TokenResponse>>('/auth/google/', { credential }).then((r) => r.data),
  appleLogin: (access_token: string) => apiClient.post<ApiResponse<TokenResponse>>('/auth/apple/', { access_token }).then((r) => r.data),

  changePassword: (current_password: string, new_password: string) =>
    apiClient.post<ApiResponse<null>>('/auth/change-password/', { current_password, new_password }).then((r) => r.data),

  deactivateAccount: () =>
    apiClient.post<ApiResponse<{ reactivatable_until: string }>>('/auth/deactivate/').then((r) => r.data),

  deleteAccount: (confirm: string) =>
    apiClient.post<ApiResponse<{ hard_deletion_scheduled: string }>>('/auth/delete/', { confirm }).then((r) => r.data),

  exportData: () =>
    apiClient.post<ApiResponse<null>>('/auth/export-data/').then((r) => r.data),

  getSessions: () =>
    apiClient.get<ApiResponse<Array<{ id: string; device_name: string; ip_address: string; location: string; last_active: string; created_at: string; is_current: boolean }>>>('/auth/sessions/').then((r) => r.data),

  logoutAllSessions: () =>
    apiClient.post<ApiResponse<null>>('/auth/logout-all/').then((r) => r.data),

  verifyAge: (date_of_birth: string) =>
    apiClient.post<ApiResponse<{ age: number; is_adult: boolean; is_16_plus: boolean; dob_hash: string }>>('/auth/verify-age/', { date_of_birth }).then((r) => r.data),

  getPolicyVersions: () =>
    apiClient.get<ApiResponse<Record<string, PolicyVersionMeta>>>('/auth/policies/').then((r) => r.data),

  getConsentStatus: () =>
    apiClient.get<ApiResponse<ConsentStatus>>('/auth/consent-status/').then((r) => r.data),
};
