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

  getProducts: (category?: string) =>
    apiClient.get<ApiResponse<ProductMP[]>>('/marketplace/products/', { params: category ? { category } : {} }).then((r) => r.data),
};
