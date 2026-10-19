import { apiClient } from './client';
import type { ApiResponse } from '@/types';
import type { PickupStation, StationApplication, StationWritePayload } from './stations';

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
  average_rating: number;
  review_count: number;
  stock_quantity: number;
  stock_tracking_enabled: boolean;
  is_active?: boolean;
  is_draft?: boolean;
  abandoned_cart_count?: number;
  shop_data?: { id: string; name: string; handle: string; verification_status: string };
  delivery_modes?: string[];
  fulfillment_details?: Record<string, string>;
  /** True when this account has an order for the product. */
  is_purchased?: boolean;
  /** Orders that bought this product, so the badge can link to one. */
  purchase_order_ids?: string[];
  created_at: string;
}

export interface ProductReview {
  id: string;
  rating: number;
  body: string;
  buyer_data: { username: string; display_name: string; avatar_url: string };
  created_at: string;
}

export interface MarketplaceEvent {
  id: string;
  creator_data: { username: string; display_name: string; avatar_url: string; verification_status?: string };
  gym_data: { id: string; name: string; handle: string; logo_url: string; is_verified?: boolean } | null;
  shop_data: { id: string; name: string; handle: string; verification_status?: string } | null;
  shop_id: string | null;
  gym_id: string | null;
  title: string;
  description: string;
  cover_image_url: string;
  promo_video_url: string;
  gallery_urls: string[];
  event_type: string;
  location: string;
  location_lat?: number | null;
  location_lng?: number | null;
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
  product_performance: {
    id: string; title: string; clicks: number; units_sold: number; revenue_usd: number;
    conversion_rate: number; average_rating: number; review_count: number;
    stock_quantity: number; stock_tracking_enabled: boolean;
  }[];
}

export interface OrderItem {
  item_type: string;
  title: string;
  quantity: number;
  price_artifacts: Record<string, number>;
  paid_artifacts: Record<string, number>;
  creator_name: string | null;
  created_at: string;
  /** The bought object's id, or null once it has been deleted. */
  target: string | null;
  cover_url: string | null;
  /** In-app route to the bought object, or null if it is gone. */
  detail_route: string | null;
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

/* ------------------------------------------------------------------ */
/* Cart & checkout                                                     */
/* ------------------------------------------------------------------ */

export type FulfillmentType = 'digital' | 'pickup' | 'delivery';

/** Settlement rails for an order. Artifacts is the wallet rail, settled inline. */
export type CheckoutPaymentMethod = 'artifacts' | 'mpesa' | 'card';

/** Keys mirror `Order.delivery_address`, which is a free-form JSONField. */
export interface CheckoutDeliveryAddress {
  line1?: string;
  line2?: string;
  city?: string;
  postal_code?: string;
  country?: string;
  phone?: string;
  notes?: string;
}

export interface CheckoutPickupDetails {
  venue?: string;
  location?: string;
  instructions?: string;
}

/**
 * `POST /marketplace/cart/checkout/`.
 *
 * Every member is optional: the artifact-only shape callers have always sent
 * (`{fulfillment_type: 'digital'}`) stays valid, and the physical-logistics and
 * payment fields are additive so a caller against an older backend still
 * checks out cleanly — the server ignores what it does not read.
 */
export interface CheckoutPayload {
  fulfillment_type?: FulfillmentType;
  delivery_address?: CheckoutDeliveryAddress;
  pickup_details?: CheckoutPickupDetails;
  /** `null`/absent for digital and delivery orders. */
  pickup_station_id?: string | null;
  payment_method?: CheckoutPaymentMethod;
  idempotency_key?: string;
}

export interface CheckoutCartItem {
  item_type: string;
  title: string;
  quantity: number;
  price_artifacts?: Record<string, number>;
  paid_artifacts?: Record<string, number>;
  total_artifacts?: Record<string, number>;
  creator_name?: string | null;
}

export interface CheckoutResult {
  order_id: string;
  order_number: string;
  status: string;
  fulfillment_type: string;
  items: CheckoutCartItem[];
  total_artifacts: Record<string, number>;
  original_artifacts?: Record<string, number>;
  savings_artifacts?: Record<string, number>;
  savings_usd?: number;
  discount_code?: string | null;
  spent_usd?: number;
  new_balance?: Record<string, number>;
  /** New settlement columns — absent until the backend persists them. */
  payment_method?: CheckoutPaymentMethod | null;
  payment_status?: string | null;
  pickup_station?: string | { id?: string; name?: string } | null;
  delivery_address?: CheckoutDeliveryAddress | null;
  pickup_details?: CheckoutPickupDetails | null;
}

export interface CartItemPayload {
  id: string;
  item_type: string;
  quantity: number;
  meal_plan?: string | null;
  programme?: string | null;
  product?: string | null;
  event?: string | null;
  meal_plan_detail?: { id?: string; title?: string; cover_image_url?: string | null } | null;
  programme_detail?: { id?: string; title?: string; cover_image_url?: string | null } | null;
  /** Products are the only cart item type that carries `delivery_modes`. */
  product_detail?: {
    id?: string;
    name?: string;
    image_url?: string | null;
    delivery_modes?: string[];
    fulfillment_details?: Record<string, string>;
  } | null;
  event_detail?: { id?: string; title?: string; cover_image_url?: string | null } | null;
  item_total_artifacts?: Record<string, number>;
  item_total_usd?: number;
}

export interface CartSuggestedFulfillment {
  type?: string;
  available?: string[];
  detail?: Record<string, unknown>;
}

export interface CartPayload {
  id?: string;
  items?: CartItemPayload[];
  discount_code?: {
    code?: string;
    discount_type?: string;
    discount_pct?: number;
    discount_artifacts?: Record<string, number>;
  } | null;
  total_artifacts?: Record<string, number>;
  subtotals?: CartItemPayload[];
  total_usd?: number;
  total_local_currency?: number;
  base_currency?: string;
  local_currency?: string;
  conversion_rate?: number;
  suggested_fulfillment?: CartSuggestedFulfillment | null;
}

interface CheckoutErrorPayload {
  message?: string;
  detail?: string;
  errors?: Record<string, unknown> | unknown[] | null;
}

/**
 * Best-effort human message for a rejected checkout.
 *
 * The ledger rejections the buyer can act on (`Insufficient dumbbell tokens.`,
 * `Cart is empty.`, an event that sold out) arrive as `{success:false,
 * message:'...'}` with a 4xx, so the body is the source of truth and the server
 * wording is surfaced verbatim rather than replaced with generic copy.
 */
export function checkoutErrorMessage(error: unknown, fallback = 'Checkout failed. Please try again.'): string {
  const payload = (error as { response?: { data?: CheckoutErrorPayload } } | undefined)?.response?.data;
  const flat = payload?.errors
    ? (Array.isArray(payload.errors)
        ? payload.errors.map(String)
        : Object.entries(payload.errors).map(([k, v]) => `${k}: ${Array.isArray(v) ? v.join(' ') : String(v)}`))
    : [];
  return [payload?.message, payload?.detail, flat.join(' ')].filter(Boolean).join(' — ') || fallback;
}

/* ------------------------------------------------------------------ */
/* Courier (delivery personnel)                                        */
/* ------------------------------------------------------------------ */

/**
 * The only four status moves the delivery endpoint accepts.
 *
 * `POST/PATCH /marketplace/delivery/my-orders/<id>/` rejects everything else
 * with a 400 that names the illegal move, so this map is rendered verbatim and
 * is never widened — a courier cannot cancel, refund, or re-open a shipment.
 * `processing` is reachable both as a pickup handoff (`shipped → out for
 * delivery`) and as the rollback from a failed delivery attempt.
 */
export const COURIER_STATUS_ACTIONS = {
  processing: [{ to: 'out_for_delivery', label: 'Start delivery' }],
  shipped: [{ to: 'out_for_delivery', label: 'Start delivery' }],
  out_for_delivery: [
    { to: 'delivered', label: 'Mark delivered' },
    { to: 'processing', label: 'Return to processing' },
  ],
} as const satisfies Record<string, readonly { to: string; label: string }[]>;

export type CourierSourceStatus = keyof typeof COURIER_STATUS_ACTIONS;
export type CourierTargetStatus = (typeof COURIER_STATUS_ACTIONS)[CourierSourceStatus][number]['to'];

/**
 * The legal actions for a status, or an empty list.
 *
 * An unknown status (a value the backend adds later) yields no buttons at all
 * rather than a guess — the server is the authority on legality and offering a
 * move it will reject is worse than offering none.
 */
export function courierActionsFor(status: string | null | undefined): { to: string; label: string }[] {
  if (!status) return [];
  const actions = (COURIER_STATUS_ACTIONS as Record<string, readonly { to: string; label: string }[]>)[status];
  return actions ? actions.map((a) => ({ ...a })) : [];
}

export interface CourierProfile {
  vehicle_type?: string | null;
  service_zones?: string[] | null;
  is_active?: boolean;
  rating?: number | null;
  commission_rate?: number | null;
  counts?: Record<string, number> | null;
  /** True when this courier has any order in a non-terminal state. */
  active?: boolean;
}

export interface CourierOrderItem {
  title?: string;
  quantity?: number;
  creator_name?: string | null;
}

export interface CourierPickupStation {
  name?: string;
  address?: string | null;
}

export interface CourierOrder {
  id: string;
  order_number?: string;
  status?: string;
  status_label?: string;
  fulfillment_status?: string | null;
  created_at?: string;
  paid_at?: string | null;
  items?: CourierOrderItem[];
  delivery_address?: Record<string, unknown> | string | null;
  pickup_station?: CourierPickupStation | null;
  commission_artifacts?: Record<string, number> | null;
}

/**
 * An informational estimate computed from completed orders. It is explicitly
 * NOT a payable balance — the wallet ledger is the only thing that pays out,
 * and the dashboard labels this figure as an estimate for that reason.
 */
export interface CourierEarnings {
  delivered_count?: number;
  delivered_value_artifacts?: Record<string, number> | null;
  commission_artifacts?: Record<string, number> | null;
  window?: { from?: string | null; to?: string | null } | null;
}

export interface CourierRegistrationPayload {
  vehicle_type?: string;
  vehicle_plate?: string;
  phone?: string;
  station?: string;
  service_zones?: string[];
  is_active?: boolean;
}

/* ------------------------------------------------------------------ */
/* Event organiser                                                     */
/* ------------------------------------------------------------------ */

export interface OrganiserEvent {
  id: string;
  title?: string;
  start_datetime?: string;
  end_datetime?: string;
  capacity?: number;
  attendee_count?: number;
  tickets_sold_count?: number;
  is_published?: boolean;
  is_cancelled?: boolean;
}

export interface EventAttendee {
  id: string;
  ticket_code?: string;
  tier?: string | null;
  status?: string;
  is_checked_in?: boolean;
  checked_in_at?: string | null;
  price_paid_artifacts?: Record<string, number> | null;
  display_name?: string | null;
  username?: string | null;
}

export interface EventTierSales {
  tier?: string;
  count?: number;
  gross_artifacts?: Record<string, number> | null;
}

export interface EventStats {
  capacity?: number;
  tickets_sold?: number;
  checked_in?: number;
  gross_artifacts?: Record<string, number> | null;
  sold_by_tier?: EventTierSales[];
}

export interface EventAttendeeFilters {
  checked_in?: boolean | '';
  status?: string;
  tier?: string;
  page?: number;
  page_size?: number;
}

export interface CheckInResult {
  attendee?: EventAttendee;
  checked_in_at?: string;
  is_checked_in?: boolean;
  message?: string;
}

/** Extract the server's own wording from a 400/404/409, verbatim. */
export function eventActionErrorMessage(error: unknown, fallback = 'That did not work.'): string {
  const payload = (error as { response?: { data?: { message?: string; detail?: string; errors?: Record<string, unknown> | unknown[] | null } } } | undefined)?.response?.data;
  const flat = payload?.errors
    ? (Array.isArray(payload.errors)
        ? payload.errors.map(String)
        : Object.entries(payload.errors).map(([k, v]) => `${k}: ${Array.isArray(v) ? v.join(' ') : String(v)}`))
    : [];
  return [payload?.message, payload?.detail, flat.join(' ')].filter(Boolean).join(' — ') || fallback;
}

export const marketplaceApi = {
  getMealPlans: (diet_type?: string) =>
    apiClient.get<ApiResponse<MealPlan[]>>('/marketplace/meal-plans/', { params: diet_type ? { diet_type } : {} }).then((r) => r.data),

  getMealPlan: (planId: string) =>
    apiClient.get<ApiResponse<MealPlan>>(`/marketplace/meal-plans/${planId}/`).then((r) => r.data),

  /** Meal plans this account owns. Server-side, so pagination cannot hide one. */
  getMyMealPlans: () =>
    apiClient.get<ApiResponse<MealPlan[]>>('/marketplace/meal-plans/mine/').then((r) => r.data),

  /** `order_id` names the receipt the server just created; it was always in the
   *  response and the client simply dropped it. */
  purchaseMealPlan: (planId: string) =>
    apiClient.post<ApiResponse<MealPlan> & { order_id?: string; order_number?: string }>(`/marketplace/meal-plans/${planId}/purchase/`).then((r) => r.data),

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

  /** Programmes this account owns. Server-side, so pagination cannot hide one. */
  getMyProgrammes: () =>
    apiClient.get<ApiResponse<TrainingProgrammeMP[]>>('/marketplace/programmes/mine/').then((r) => r.data),

  purchaseProgramme: (programmeId: string) =>
    apiClient.post<ApiResponse<TrainingProgrammeMP> & { order_id?: string; order_number?: string }>(`/marketplace/programmes/${programmeId}/purchase/`).then((r) => r.data),

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

  getProductReviews: (productId: string) =>
    apiClient.get<ApiResponse<ProductReview[]>>(`/marketplace/products/${productId}/reviews/`).then((r) => r.data),

  reviewProduct: (productId: string, rating: number, body?: string) =>
    apiClient.post<ApiResponse<ProductReview>>(`/marketplace/products/${productId}/reviews/`, { rating, body }).then((r) => r.data),

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

  getEvents: (
    scope: 'upcoming' | 'past' | 'all' = 'upcoming',
    filters: {
      q?: string; category?: string; event_type?: string; city?: string;
      gym?: string; shop_id?: string; verified?: boolean; is_free?: boolean;
      lat?: number; lng?: number; radius_km?: number;
    } = {},
  ) =>
    apiClient.get<ApiResponse<any[]>>('/marketplace/events/', {
      params: { scope, ...filters },
    }).then((r) => r.data),

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
    apiClient.get<ApiResponse<CartPayload>>('/marketplace/cart/').then((r) => r.data),

  addToCart: (item_type: string, idData: Record<string, string>, quantity: number = 1, extra?: Record<string, string>) =>
    apiClient.post<ApiResponse<any>>('/marketplace/cart/', { item_type, ...idData, quantity, ...extra }).then((r) => r.data),

  removeFromCart: (item_id?: string) =>
    apiClient.delete<ApiResponse<any>>('/marketplace/cart/', { data: { item_id } }).then((r) => r.data),

  checkoutCart: (data?: CheckoutPayload) =>
    apiClient.post<ApiResponse<CheckoutResult>>('/marketplace/cart/checkout/', data || {}).then((r) => r.data),

  getOrders: (status?: string) =>
    apiClient.get<ApiResponse<Order[]>>('/marketplace/orders/', { params: status ? { status } : {} }).then((r) => r.data),

  getSellerOrders: (status?: string) =>
    apiClient.get<ApiResponse<Order[]>>('/marketplace/orders/seller/', { params: status ? { status } : {} }).then((r) => r.data),

  getOrder: (orderId: string) =>
    apiClient.get<ApiResponse<Order>>(`/marketplace/orders/${orderId}/`).then((r) => r.data),

  updateOrderFulfillment: (orderId: string, data: Record<string, unknown>) =>
    apiClient.patch<ApiResponse<Order>>(`/marketplace/orders/${orderId}/fulfillment/`, data).then((r) => r.data),

  updateOrderStatus: (orderId: string, status: string, note?: string) =>
    apiClient.patch<ApiResponse<Order>>(`/marketplace/orders/${orderId}/status/`, { status, note }).then((r) => r.data),


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

  /* ---------------------------------------------------------------- */
  /* Courier                                                           */
  /* ---------------------------------------------------------------- */

  /**
   * Courier profile + status counts for the signed-in rider.
   *
   * A 404 here means "this user has no `DeliveryPersonnel` row" — the endpoint
   * is scoped to the signed-in courier, so it cannot 404 for a missing id. That
   * is the signal the dashboard uses to route to the registration wizard rather
   * than render an empty shell.
   */
  getCourierSummary: () =>
    apiClient.get<ApiResponse<CourierProfile>>('/marketplace/delivery/summary/').then((r) => r.data),

  getCourierOrders: (status?: string, page?: number) =>
    apiClient.get<ApiResponse<CourierOrder[]>>('/marketplace/delivery/my-orders/', {
      params: {
        ...(status ? { status } : {}),
        ...(page ? { page } : {}),
      },
    }).then((r) => r.data),

  /**
   * Move an order through one of the four legal courier transitions.
   *
   * Deliberately typed to `CourierTargetStatus`: the UI can only compile a call
   * for a status the endpoint accepts, so an illegal move is a type error rather
   * than a 400 at runtime.
   */
  updateCourierOrderStatus: (orderId: string, status: CourierTargetStatus) =>
    apiClient.patch<ApiResponse<CourierOrder>>(`/marketplace/delivery/my-orders/${orderId}/`, { status }).then((r) => r.data),

  /**
   * Informational commission estimate over a window — not a payable balance.
   */
  getCourierEarnings: (params?: { from?: string; to?: string }) =>
    apiClient.get<ApiResponse<CourierEarnings>>('/marketplace/delivery/earnings/', {
      params: params || undefined,
    }).then((r) => r.data),

  /**
   * Self-registration. Also doubles as the active-toggle write: posting
   * `{is_active}` against an existing row flips the rider's availability.
   */
  registerDeliveryPersonnel: (data: CourierRegistrationPayload) =>
    apiClient.post<ApiResponse<any>>('/marketplace/delivery-personnel/', data).then((r) => r.data),

  toggleCourierActive: (is_active: boolean, extra?: CourierRegistrationPayload) =>
    apiClient.post<ApiResponse<any>>('/marketplace/delivery-personnel/', { ...(extra || {}), is_active }).then((r) => r.data),

  /* ---------------------------------------------------------------- */
  /* Event organiser                                                   */
  /* ---------------------------------------------------------------- */

  /** Events the signed-in user organises. 403 for anyone else. */
  getOrganisedEvents: () =>
    apiClient.get<ApiResponse<OrganiserEvent[]>>('/marketplace/events/mine/').then((r) => r.data),

  getEventAttendees: (eventId: string, filters: EventAttendeeFilters = {}) => {
    const params: Record<string, unknown> = {};
    if (filters.checked_in !== undefined && filters.checked_in !== '') params.checked_in = filters.checked_in;
    if (filters.status) params.status = filters.status;
    if (filters.tier) params.tier = filters.tier;
    if (filters.page) params.page = filters.page;
    if (filters.page_size) params.page_size = filters.page_size;
    return apiClient.get<ApiResponse<EventAttendee[]>>(`/marketplace/events/${eventId}/attendees/`, { params }).then((r) => r.data);
  },

  /**
   * Check a ticket in.
   *
   * The status codes are meaningful and surfaced inline by the UI rather than
   * being flattened: 404 = unknown code, 409 = already checked in (the server
   * reports who and when), 400 = cancelled ticket.
   */
  checkInAttendee: (eventId: string, ticket_code: string) =>
    apiClient.post<ApiResponse<CheckInResult>>(`/marketplace/events/${eventId}/check-in/`, { ticket_code }).then((r) => r.data),

  /** Reverses a mistaken check-in. */
  checkOutAttendee: (eventId: string, ticket_code: string) =>
    apiClient.post<ApiResponse<CheckInResult>>(`/marketplace/events/${eventId}/check-out/`, { ticket_code }).then((r) => r.data),

  getEventStats: (eventId: string) =>
    apiClient.get<ApiResponse<EventStats>>(`/marketplace/events/${eventId}/stats/`).then((r) => r.data),

  /* ---------------------------------------------------------------- */
  /* Pickup stations                                                   */
  /* ---------------------------------------------------------------- */

  createStation: (data: StationWritePayload) =>
    apiClient.post<ApiResponse<PickupStation>>('/marketplace/stations/', data).then((r) => r.data),

  updateStation: (stationId: string, data: Partial<StationWritePayload>) =>
    apiClient.patch<ApiResponse<PickupStation>>(`/marketplace/stations/${stationId}/`, data).then((r) => r.data),

  /** Apply to become a station owner. Admin reviews; status is surfaced back. */
  applyForStation: (data: Record<string, unknown>) =>
    apiClient.post<ApiResponse<StationApplication>>('/marketplace/station-applications/', data).then((r) => r.data),
};
