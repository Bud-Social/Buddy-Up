import { apiClient } from './client';
import type { ApiResponse } from '@/types';

export interface TrainerProfile {
  profile_id: string;
  specialties: string[];
  certifications: { name: string; issuer: string; year: number }[];
  years_experience: number;
  languages: string[];
  session_types: string[];
  pricing: Record<string, { artifact_type: string; quantity: number }>;
  average_rating: number;
  review_count: number;
  total_sessions_completed: number;
  profile_data: {
    username: string;
    display_name: string;
    avatar_url: string;
    bio: string;
    location_city: string;
    location_country: string;
    verification_status: string;
  };
}

export interface BookingSession {
  id: string;
  client_id: string;
  trainer_id: string;
  session_type: string;
  status: string;
  scheduled_at: string;
  duration_minutes: number;
  artifact_fee: Record<string, number>;
  notes: string;
  client_data: { username: string; display_name: string; avatar_url: string };
  trainer_data: { username: string; display_name: string; avatar_url: string; verification_status: string };
  completed_at: string | null;
  cancelled_at: string | null;
  created_at: string;
}

export interface Review {
  id: string;
  session_id: string;
  client_id: string;
  trainer_id: string;
  rating: number;
  body: string;
  client_data: { username: string; display_name: string; avatar_url: string };
  created_at: string;
}

export interface AsyncProgramme {
  id: string;
  trainer_id: string;
  title: string;
  description: string;
  duration_weeks: number;
  price_artifacts: Record<string, number>;
  is_active: boolean;
  enrolled_count: number;
  trainer_data: { username: string; display_name: string; avatar_url: string };
  created_at: string;
}

export const sessionsApi = {
  getTrainers: (specialty?: string) =>
    apiClient.get<ApiResponse<TrainerProfile[]>>('/sessions/trainers/', { params: specialty ? { specialty } : {} }).then((r) => r.data),

  getTrainer: (username: string) =>
    apiClient.get<ApiResponse<TrainerProfile>>(`/sessions/trainers/${username}/`).then((r) => r.data),

  updateTrainer: (username: string, data: Partial<TrainerProfile>) =>
    apiClient.patch<ApiResponse<TrainerProfile>>(`/sessions/trainers/${username}/`, data).then((r) => r.data),

  getAvailability: (username: string) =>
    apiClient.get<ApiResponse<unknown[]>>(`/sessions/trainers/${username}/availability/`).then((r) => r.data),

  getTrainerReviews: (username: string) =>
    apiClient.get<ApiResponse<Review[]>>(`/sessions/trainers/${username}/reviews/`).then((r) => r.data),

  bookSession: (username: string, data: { session_type: string; scheduled_at: string; duration_minutes: number; notes?: string }) =>
    apiClient.post<ApiResponse<BookingSession>>(`/sessions/book/${username}/`, data).then((r) => r.data),

  getMyBookings: (role?: string, status?: string) =>
    apiClient.get<ApiResponse<BookingSession[]>>('/sessions/my/', { params: { role, status } }).then((r) => r.data),

  getBooking: (bookingId: string) =>
    apiClient.get<ApiResponse<BookingSession>>(`/sessions/bookings/${bookingId}/`).then((r) => r.data),

  cancelBooking: (bookingId: string) =>
    apiClient.post<ApiResponse<{ refund_pct: number }>>(`/sessions/bookings/${bookingId}/`, { action: 'cancel' }).then((r) => r.data),

  completeBooking: (bookingId: string) =>
    apiClient.post<ApiResponse<null>>(`/sessions/bookings/${bookingId}/`, { action: 'complete' }).then((r) => r.data),

  submitReview: (bookingId: string, rating: number, body?: string) =>
    apiClient.post<ApiResponse<Review>>(`/sessions/bookings/${bookingId}/review/`, { rating, body }).then((r) => r.data),
};
