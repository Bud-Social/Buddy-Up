import { apiClient } from './client';
import type { ApiResponse } from '@/types';

export interface Shop {
  id: string;
  handle: string;
  name: string;
  description: string;
  logo_url: string;
  cover_url: string;
  is_certified: boolean;
  owner: string;
  created_at: string;
}

export interface BuddyUpCertification {
  id: string;
  shop_id: string;
  status: string;
  notes: string;
}

export interface MealPlan {
  id: string;
  creator_id: string;
  title: string;
  description: string;
  cover_image_url: string;
  diet_type: string;
  duration_weeks: number;
  meals_per_day: number;
  calorie_range: string;
  macro_targets?: { protein_pct: number; carbs_pct: number; fat_pct: number };
  price_artifacts: Record<string, number>;
  preview_day: Record<string, unknown>;
  full_plan?: Record<string, unknown>;
  shopping_list?: string[];
  purchase_count: number;
  average_rating: number;
  review_count: number;
  creator_data: { username: string; display_name: string; avatar_url: string; verification_status: string };
  is_purchased: boolean;
  is_draft?: boolean;
  is_active?: boolean;
  abandoned_cart_count?: number;
  shop_data?: { id: string; name: string; handle: string };
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
  cover_image_url: string;
  category: string;
  duration_weeks: number;
  sessions_per_week?: number;
  equipment_list?: string[];
  content_rating?: string;
  schedule?: Record<string, Record<string, unknown[]>>;
  price_artifacts: Record<string, number>;
  purchase_count: number;
  average_rating: number;
  review_count: number;
  creator_data: { username: string; display_name: string; avatar_url: string; verification_status: string };
  is_purchased: boolean;
  is_draft?: boolean;
  is_active?: boolean;
  abandoned_cart_count?: number;
  shop_data?: { id: string; name: string; handle: string; verification_status: string };
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
  is_active?: boolean;
  is_draft?: boolean;
  abandoned_cart_count?: number;
  shop_data?: { id: string; name: string; handle: string; verification_status: string };
  created_at: string;
}

export interface MarketplaceEvent {
  id: string;
  creator_data: { username: string; display_name: string; avatar_url: string };
  gym_data: { id: string; name: string; handle: string; logo_url: string } | null;
  shop_data: { id: string; name: string; handle: string } | null;
  shop_id: string | null;
  title: string;
  description: string;
  cover_image_url: string;
  promo_video_url: string;
  gallery_urls: string[];
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
  media: EventMediaItem[];
  agenda?: { title: string; time: string }[];
  recurrence?: string;
  ticket_tiers?: { name: string; price_artifacts?: Record<string, number>; price?: number; perks?: string[] }[];
  early_bird_enabled?: boolean;
  early_bird_deadline?: string | null;
  early_bird_price_artifacts?: Record<string, number>;
  cancellation_policy?: string;
  is_draft?: boolean;
  created_at: string;
}

export interface EventMediaItem {
  id: string;
  media_type: 'image' | 'video';
  url: string;
  thumbnail_url: string;
  alt_text: string;
  sort_order: number;
}

export interface ShopDetail {
  id: string;
  handle: string;
  name: string;
  description: string;
  logo_url: string;
  banner_url: string;
  is_certified: boolean;
  accent_color: string;
  contact_email: string;
  contact_phone: string;
  website_url: string;
  social_links: Record<string, string>;
  category: string;
  verification_status: string;
  is_active: boolean;
  created_at: string;
}

export interface UserShopResponse {
  shop: ShopDetail;
  meal_plans: MealPlan[];
  programmes: TrainingProgrammeMP[];
  events: MarketplaceEvent[];
  products: ProductMP[];
}

export interface FoodItem {
  item: string;
  confidence: number;
  nutrition: { calories: number; protein: number; carbs: number; fat: number; health_benefits?: string[] };
}

export interface FoodRecognitionResult {
  items: FoodItem[];
  total_calories: number;
  total_protein: number;
  total_carbs: number;
  total_fat: number;
  health_benefits: string[];
  method: string;
}

export interface DiscountCode {
  id: string;
  creator: string;
  code: string;
  discount_type: 'percentage' | 'fixed_artifacts';
  discount_pct: number;
  discount_artifacts: Record<string, number>;
  code_type: 'text' | 'qr';
  qr_code: string | null;
  description: string;
  campaign: string;
  valid_from: string | null;
  valid_until: string | null;
  usage_limit: number;
  max_uses_per_user: number;
  times_used: number;
  min_purchase_artifacts: Record<string, number>;
  is_active: boolean;
  is_retired: boolean;
  retired_at: string | null;
  retired_reason: string;
  share_count: number;
  usage_count: number;
  is_expired: boolean;
  created_at: string;
  updated_at: string;
}

export interface DiscountUsageRecord {
  id: string;
  code: string;
  user_display: string;
  discount: string;
  user: string;
  cart: string | null;
  order_artifacts: Record<string, number>;
  discount_pct_applied: number;
  discount_artifacts_applied: Record<string, number>;
  savings_artifacts: Record<string, number>;
  savings_usd: number;
  was_successful: boolean;
  created_at: string;
}

export interface DiscountAnalytics {
  total_uses: number;
  successful_uses: number;
  total_savings_usd: number;
  share_count: number;
  times_used: number;
  usage_over_time: { date: string; count: number }[];
  unique_users: number;
  returning_users: number;
  retention_rate: number;
  repeat_usage_distribution: { uses: number; users: number }[];
  avg_savings_per_user: number;
  total_order_value_usd: number;
  top_users: { user__username: string; user__display_name: string; uses: number; savings: number | null }[];
  code: DiscountCode;
}

export interface CreatorAnalytics {
  total_revenue_usd: number;
  total_sales: number;
  total_views: number;
  category_sales: Record<string, number>;
  category_revenue: Record<string, number>;
  revenue_over_time: { month: string; total: number }[];
  top_services: { id: string; title: string; type: string; sales: number }[];
}

export interface OrderItem {
  item_type: string;
  title: string;
  quantity: number;
  price_artifacts: Record<string, number>;
  paid_artifacts: Record<string, number>;
  creator_name: string | null;
  created_at: string;
}

export interface OrderFulfillment {
  carrier: string;
  tracking_number: string;
  tracking_url: string;
  pickup_location: string;
  notes: string;
  timeline: { status: string; at: string | null; note: string }[];
  shipped_at: string | null;
  out_for_delivery_at: string | null;
  ready_for_pickup_at: string | null;
  delivered_at: string | null;
}

export interface Order {
  id: string;
  order_number: string;
  status: string;
  status_label: string;
  fulfillment_type: string;
  delivery_address: Record<string, unknown>;
  pickup_details: Record<string, unknown>;
  items_total_artifacts: Record<string, number>;
  discount_artifacts: Record<string, number>;
  total_artifacts: Record<string, number>;
  total_usd: number;
  spent_usd: number;
  discount_code: string | null;
  status_history: { status: string; at: string | null; note: string }[];
  items: OrderItem[];
  fulfillment: OrderFulfillment | null;
  is_seller?: boolean;
  paid_at: string | null;
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

  getEvents: (scope: 'upcoming' | 'past' | 'all' = 'upcoming') =>
    apiClient.get<ApiResponse<any[]>>('/marketplace/events/', { params: { scope } }).then((r) => r.data),

  getEvent: (eventId: string) =>
    apiClient.get<ApiResponse<any>>(`/marketplace/events/${eventId}/`).then((r) => r.data),

  purchaseEventTicket: (eventId: string) =>
    apiClient.post<ApiResponse<any>>(`/marketplace/events/${eventId}/tickets/`).then((r) => r.data),

  getMyTickets: () =>
    apiClient.get<ApiResponse<any[]>>('/marketplace/events/my-tickets/').then((r) => r.data),

  buyEventTicket: (eventId: string) =>
    apiClient.post<ApiResponse<any>>(`/marketplace/events/${eventId}/tickets/`).then((r) => r.data),

  getTicket: (ticketId: string) =>
    apiClient.get<ApiResponse<any>>(`/marketplace/events/tickets/${ticketId}/`).then((r) => r.data),

  recognizeFood: (file: File) => {
    const formData = new FormData();
    formData.append('file', file);
    return apiClient.post<ApiResponse<FoodRecognitionResult>>('/marketplace/food-recognize/', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
      timeout: 30000,
    }).then((r) => r.data);
  },

  getCreatorAnalytics: () =>
    apiClient.get<ApiResponse<CreatorAnalytics>>('/marketplace/my-services/analytics/').then((r) => r.data),

  getMyServices: () =>
    apiClient.get<ApiResponse<{ shop: ShopDetail | null; meal_plans: MealPlan[]; programmes: TrainingProgrammeMP[]; events: MarketplaceEvent[]; products: ProductMP[]; discount_codes: DiscountCode[] }>>('/marketplace/my-services/').then((r) => r.data),

  updateEvent: (eventId: string, data: Record<string, unknown>) =>
    apiClient.put<ApiResponse<MarketplaceEvent>>(`/marketplace/events/${eventId}/`, data).then((r) => r.data),

  deleteEvent: (eventId: string) =>
    apiClient.delete<ApiResponse<null>>(`/marketplace/events/${eventId}/`).then((r) => r.data),

  getCart: () =>
    apiClient.get<ApiResponse<any>>('/marketplace/cart/').then((r) => r.data),

  addToCart: (item_type: string, idData: Record<string, string>, quantity: number = 1) =>
    apiClient.post<ApiResponse<any>>('/marketplace/cart/', { item_type, ...idData, quantity }).then((r) => r.data),

  removeFromCart: (item_id?: string) =>
    apiClient.delete<ApiResponse<any>>('/marketplace/cart/', { data: { item_id } }).then((r) => r.data),

  checkoutCart: (data?: Record<string, unknown>) =>
    apiClient.post<ApiResponse<any>>('/marketplace/cart/checkout/', data || {}).then((r) => r.data),

  getOrders: (status?: string) =>
    apiClient.get<ApiResponse<Order[]>>('/marketplace/orders/', { params: status ? { status } : {} }).then((r) => r.data),

  getSellerOrders: (status?: string) =>
    apiClient.get<ApiResponse<Order[]>>('/marketplace/orders/seller/', { params: status ? { status } : {} }).then((r) => r.data),

  getOrder: (orderId: string) =>
    apiClient.get<ApiResponse<Order>>(`/marketplace/orders/${orderId}/`).then((r) => r.data),

  updateOrderFulfillment: (orderId: string, data: Record<string, unknown>) =>
    apiClient.patch<ApiResponse<Order>>(`/marketplace/orders/${orderId}/fulfillment/`, data).then((r) => r.data),

  applyDiscount: (code: string) =>
    apiClient.post<ApiResponse<any>>('/marketplace/cart/discount/', { code }).then((r) => r.data),

  removeDiscount: () =>
    apiClient.delete<ApiResponse<any>>('/marketplace/cart/discount/').then((r) => r.data),

  getDiscountCodes: () =>
    apiClient.get<ApiResponse<DiscountCode[]>>('/marketplace/discount-codes/').then((r) => r.data),

  getDiscountCode: (codeId: string) =>
    apiClient.get<ApiResponse<DiscountCode>>(`/marketplace/discount-codes/${codeId}/`).then((r) => r.data),

  createDiscountCode: (data: Record<string, unknown>) =>
    apiClient.post<ApiResponse<DiscountCode>>('/marketplace/discount-codes/', data).then((r) => r.data),

  updateDiscountCode: (codeId: string, data: Record<string, unknown>) =>
    apiClient.put<ApiResponse<DiscountCode>>(`/marketplace/discount-codes/${codeId}/`, data).then((r) => r.data),

  patchDiscountCode: (codeId: string, data: Record<string, unknown>) =>
    apiClient.patch<ApiResponse<DiscountCode>>(`/marketplace/discount-codes/${codeId}/`, data).then((r) => r.data),

  deleteDiscountCode: (codeId: string) =>
    apiClient.delete<ApiResponse<null>>(`/marketplace/discount-codes/${codeId}/`).then((r) => r.data),

  getDiscountCodeAnalytics: (codeId: string) =>
    apiClient.get<ApiResponse<DiscountAnalytics>>(`/marketplace/discount-codes/${codeId}/analytics/`).then((r) => r.data),

  shareDiscountCode: (codeId: string) =>
    apiClient.post<ApiResponse<any>>(`/marketplace/discount-codes/${codeId}/share/`).then((r) => r.data),

  uploadImage: (file: File) => {
    const formData = new FormData();
    formData.append('image', file);
    return apiClient.post<ApiResponse<{ url: string }>>('/marketplace/upload-cover/', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    }).then((r) => r.data);
  },

  getShops: () =>
    apiClient.get<ApiResponse<Shop[]>>('/marketplace/shops/').then((r) => r.data),
  
  getMyShops: () =>
    apiClient.get<ApiResponse<Shop[]>>('/marketplace/shops/my/').then((r) => r.data),

  registerCreator: (data?: Record<string, unknown>) =>
    apiClient.post<ApiResponse<Shop>>('/marketplace/register-creator/', data || {}).then((r) => r.data),

  getShop: (handle: string) =>
    apiClient.get<ApiResponse<Shop>>(`/marketplace/shops/${handle}/`).then((r) => r.data),

  getUserShop: (handle: string) =>
    apiClient.get<ApiResponse<UserShopResponse>>(`/marketplace/shops/${handle}/public/`).then((r) => r.data),

  getEventMedia: (eventId: string) =>
    apiClient.get<ApiResponse<EventMediaItem[]>>(`/marketplace/events/${eventId}/media/`).then((r) => r.data),

  addEventMedia: (eventId: string, data: FormData) =>
    apiClient.post<ApiResponse<EventMediaItem>>(`/marketplace/events/${eventId}/media/`, data, {
      headers: { 'Content-Type': 'multipart/form-data' },
    }).then((r) => r.data),

  deleteEventMedia: (eventId: string, mediaId: string) =>
    apiClient.delete<ApiResponse<null>>(`/marketplace/events/${eventId}/media/${mediaId}/`).then((r) => r.data),

  createShop: (data: Record<string, unknown>) =>
    apiClient.post<ApiResponse<Shop>>('/marketplace/shops/', data, {
      headers: { 'Content-Type': 'multipart/form-data' }
    }).then((r) => r.data),

  updateShop: (handle: string, data: Record<string, unknown>) =>
    apiClient.patch<ApiResponse<Shop>>(`/marketplace/shops/${handle}/`, data, {
      headers: { 'Content-Type': 'multipart/form-data' }
    }).then((r) => r.data),

  applyForCertification: (handle: string, data: Record<string, unknown>) =>
    apiClient.post<ApiResponse<BuddyUpCertification>>(`/marketplace/shops/${handle}/certification/`, data, {
      headers: { 'Content-Type': 'multipart/form-data' }
    }).then((r) => r.data),

  updateActivityProgress: (programmeId: string, data: Record<string, unknown>) =>
    apiClient.patch<ApiResponse<any>>(`/marketplace/programmes/${programmeId}/progress/`, data).then((r) => r.data),

  registerPushToken: (token: string, platform: string = 'web', device_name: string = 'Browser') =>
    apiClient.post<ApiResponse<any>>('/marketplace/push-devices/', { token, platform, device_name }).then((r) => r.data),
};
