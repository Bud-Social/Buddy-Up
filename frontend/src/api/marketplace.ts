import { apiClient } from './client';
import type { ApiResponse } from '@/types';

export interface MealPlan {
  id: string;
  creator_id: string;
  title: string;
  description: string;
  diet_type: string;
  duration_weeks: number;
  calorie_range: string;
  price_artifacts: Record<string, number>;
  preview_day: Record<string, unknown>;
  full_plan?: Record<string, unknown>;
  shopping_list?: string[];
  purchase_count: number;
  average_rating: number;
  review_count: number;
  creator_data: { username: string; display_name: string; avatar_url: string; verification_status: string };
  is_purchased: boolean;
  created_at: string;
}

export interface MealPlanReview {
  id: string;
  rating: number;
  body: string;
  buyer_data: { username: string; display_name: string; avatar_url: string };
  created_at: string;
}

export interface TrainingProgrammeMP {
  id: string;
  creator_id: string;
  title: string;
  description: string;
  category: string;
  duration_weeks: number;
  price_artifacts: Record<string, number>;
  purchase_count: number;
  creator_data: { username: string; display_name: string; avatar_url: string; verification_status: string };
  is_purchased: boolean;
  created_at: string;
}

export interface TrainingProgrammeReview {
  id: string;
  rating: number;
  body: string;
  buyer_data: { username: string; display_name: string; avatar_url: string };
  created_at: string;
}

export interface ProductMP {
  id: string;
  name: string;
  brand: string;
  description: string;
  category: string;
  image_url: string;
  affiliate_url: string;
  price_display: string;
  recommended_by: string | null;
  recommender_data: { username: string; display_name: string } | null;
  click_count: number;
  created_at: string;
}

export interface MarketplaceEvent {
  id: string;
  creator_data: { username: string; display_name: string; avatar_url: string };
  gym_data: { id: string; name: string; handle: string; logo_url: string } | null;
  title: string;
  description: string;
  cover_image_url: string;
  event_type: string;
  location: string;
  online_url: string;
  start_datetime: string;
  end_datetime: string;
  timezone: string;
  capacity: number;
  ticket_price_artifacts: Record<string, number>;
  is_free: boolean;
  is_published: boolean;
  is_cancelled: boolean;
  attendee_count: number;
  tags: string[];
  category: string;
  is_registered: boolean;
  spots_remaining: number | null;
  created_at: string;
}

export const marketplaceApi = {
  getMealPlans: (diet_type?: string) =>
    apiClient.get<ApiResponse<MealPlan[]>>('/marketplace/meal-plans/', { params: diet_type ? { diet_type } : {} }).then((r) => r.data),

  getMealPlan: (planId: string) =>
    apiClient.get<ApiResponse<MealPlan>>(`/marketplace/meal-plans/${planId}/`).then((r) => r.data),

  purchaseMealPlan: (planId: string) =>
    apiClient.post<ApiResponse<MealPlan>>(`/marketplace/meal-plans/${planId}/purchase/`).then((r) => r.data),

  personaliseMealPlan: (planId: string) =>
    apiClient.post<ApiResponse<{ status: string }>>(`/marketplace/meal-plans/${planId}/personalise/`).then((r) => r.data),

  getMealPlanReviews: (planId: string) =>
    apiClient.get<ApiResponse<MealPlanReview[]>>(`/marketplace/meal-plans/${planId}/reviews/`).then((r) => r.data),

  reviewMealPlan: (planId: string, rating: number, body?: string) =>
    apiClient.post<ApiResponse<MealPlanReview>>(`/marketplace/meal-plans/${planId}/reviews/`, { rating, body }).then((r) => r.data),

  getProgrammes: (category?: string) =>
    apiClient.get<ApiResponse<TrainingProgrammeMP[]>>('/marketplace/programmes/', { params: category ? { category } : {} }).then((r) => r.data),

  getProgramme: (programmeId: string) =>
    apiClient.get<ApiResponse<TrainingProgrammeMP>>(`/marketplace/programmes/${programmeId}/`).then((r) => r.data),

  purchaseProgramme: (programmeId: string) =>
    apiClient.post<ApiResponse<TrainingProgrammeMP>>(`/marketplace/programmes/${programmeId}/purchase/`).then((r) => r.data),

  getProgrammeReviews: (programmeId: string) =>
    apiClient.get<ApiResponse<TrainingProgrammeReview[]>>(`/marketplace/programmes/${programmeId}/reviews/`).then((r) => r.data),

  reviewProgramme: (programmeId: string, rating: number, body?: string) =>
    apiClient.post<ApiResponse<TrainingProgrammeReview>>(`/marketplace/programmes/${programmeId}/reviews/`, { rating, body }).then((r) => r.data),

  getProducts: (category?: string) =>
    apiClient.get<ApiResponse<ProductMP[]>>('/marketplace/products/', { params: category ? { category } : {} }).then((r) => r.data),

  getProduct: (productId: string) =>
    apiClient.get<ApiResponse<ProductMP>>(`/marketplace/products/${productId}/`).then((r) => r.data),

  clickProduct: (productId: string) =>
    apiClient.post<ApiResponse<null>>(`/marketplace/products/${productId}/click/`).then((r) => r.data),

  createMealPlan: (data: Record<string, unknown>) =>
    apiClient.post<ApiResponse<MealPlan>>('/marketplace/meal-plans/', data).then((r) => r.data),

  updateMealPlan: (planId: string, data: Record<string, unknown>) =>
    apiClient.put<ApiResponse<MealPlan>>(`/marketplace/meal-plans/${planId}/`, data).then((r) => r.data),

  createEvent: (data: Record<string, unknown>) =>
    apiClient.post<ApiResponse<MarketplaceEvent>>('/marketplace/events/', data).then((r) => r.data),

  deleteMealPlan: (planId: string) =>
    apiClient.delete<ApiResponse<null>>(`/marketplace/meal-plans/${planId}/`).then((r) => r.data),

  createProgramme: (data: Record<string, unknown>) =>
    apiClient.post<ApiResponse<TrainingProgrammeMP>>('/marketplace/programmes/', data).then((r) => r.data),

  updateProgramme: (programmeId: string, data: Record<string, unknown>) =>
    apiClient.put<ApiResponse<TrainingProgrammeMP>>(`/marketplace/programmes/${programmeId}/`, data).then((r) => r.data),

  deleteProgramme: (programmeId: string) =>
    apiClient.delete<ApiResponse<null>>(`/marketplace/programmes/${programmeId}/`).then((r) => r.data),

  createProduct: (data: Record<string, unknown>) =>
    apiClient.post<ApiResponse<ProductMP>>('/marketplace/products/', data).then((r) => r.data),

  updateProduct: (productId: string, data: Record<string, unknown>) =>
    apiClient.put<ApiResponse<ProductMP>>(`/marketplace/products/${productId}/`, data).then((r) => r.data),

  deleteProduct: (productId: string) =>
    apiClient.delete<ApiResponse<null>>(`/marketplace/products/${productId}/`).then((r) => r.data),

  getEvents: (upcoming: boolean = true) =>
    apiClient.get<ApiResponse<any[]>>('/marketplace/events/', { params: { upcoming } }).then((r) => r.data),

  getEvent: (eventId: string) =>
    apiClient.get<ApiResponse<any>>(`/marketplace/events/${eventId}/`).then((r) => r.data),

  purchaseEventTicket: (eventId: string) =>
    apiClient.post<ApiResponse<any>>(`/marketplace/events/${eventId}/tickets/`).then((r) => r.data),

  getMyTickets: () =>
    apiClient.get<ApiResponse<any[]>>('/marketplace/events/my-tickets/').then((r) => r.data),

  getTicket: (ticketId: string) =>
    apiClient.get<ApiResponse<any>>(`/marketplace/events/tickets/${ticketId}/`).then((r) => r.data),
};
