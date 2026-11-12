import { apiClient } from './client';
import type { ApiResponse } from '@/types';
import type {
  AnalyticsPeriod,
  AnalyticsSummaryData,
  AnalyticsReportResult,
  ShareReportPayload,
  ShareReportResult,
  ActivityRecordInput,
  ActivitySummary,
  WorkoutLogInput,
  MealLogInput,
  BodyMetricInput,
} from '@/types/analytics';

export const analyticsApi = {
  getSummary: (period: AnalyticsPeriod = 'all') =>
    apiClient.get<ApiResponse<AnalyticsSummaryData>>('/analytics/summary/', { params: { period } }).then((r) => r.data),

  getActivities: (params?: { activity_type?: string; start?: string; end?: string }) =>
    apiClient.get<ApiResponse<ActivitySummary['recent']>>('/analytics/activities/', { params }).then((r) => r.data),

  createActivity: (payload: ActivityRecordInput) =>
    apiClient.post<ApiResponse<ActivitySummary['recent'][number]>>('/analytics/activities/', payload).then((r) => r.data),

  deleteActivity: (id: string) =>
    apiClient.delete(`/analytics/activities/${id}/`).then((r) => r.data),

  createWorkout: (payload: WorkoutLogInput) =>
    apiClient.post<ApiResponse<unknown>>('/analytics/workouts/', payload).then((r) => r.data),

  /** Per-workout-type field/category taxonomy. Cached by lib/workoutTypes. */
  getWorkoutTypes: () =>
    apiClient
      .get<ApiResponse<{ workout_types: Record<string, unknown>; categories: string[] }>>('/analytics/workout-types/')
      .then((r) => r.data),

  shareActivity: (kind: 'activity' | 'workout', id: string, body?: string) =>
    apiClient.post<ApiResponse<{ post_id: string }>>(`/analytics/${kind}/${id}/share/`, body ? { body } : {}).then((r) => r.data),

  /** Prepare a share draft (edit caption/media before publishing). */
  sharePrepare: (payload: { kind: 'activity' | 'workout' | 'countdown'; obj_id: string; visibility?: string; body?: string }) =>
    apiClient.post<ApiResponse<{ draft_id: string; body: string; visibility: string; source_kind: string; post_type: string; tags: string[] }>>('/analytics/share/prepare/', payload).then((r) => r.data.data),

  /** Publish a prepared share draft to the feed. */
  sharePublish: (draftId: string, payload: { body?: string; visibility?: string; media_urls?: string[]; tags?: string[] }) =>
    apiClient.post<ApiResponse<{ post_id: string; draft_id: string }>>(`/analytics/share/draft/${draftId}/publish/`, payload).then((r) => r.data.data),

  /** Correct grammar in a caption before posting. */
  captionCorrect: (payload: { caption: string; context?: string }) =>
    apiClient.post<ApiResponse<{ corrected: string; changes: string[] }>>('/analytics/caption/correct/', payload).then((r) => r.data.data),

  /** Get a download URL for a video attached to a post. Triggers async watermarking if needed. */
  videoDownload: (postId: string) =>
    apiClient.get<ApiResponse<{ video_url: string; download: boolean; watermark: string; post_id: string; status: 'ready' | 'processing' | 'failed' }>>(`/analytics/video/${postId}/download/`).then((r) => r.data.data),

  /** Poll for watermark readiness. */
  pollWatermark: (postId: string) =>
    apiClient.get<ApiResponse<{ video_url: string; download: boolean; watermark: string; post_id: string; status: 'ready' | 'processing' | 'failed' }>>(`/analytics/video/${postId}/download/`).then((r) => r.data.data),

  /** Auto-detect activity type from GPS route or summary stats. */
  detectActivity: (payload: {
    route?: number[][]; duration_seconds?: number; distance_meters?: number;
    avg_speed_kmh?: number | null; elevation_gain_m?: number | null;
  }) =>
    apiClient.post<ApiResponse<{ activity_type: string; confidence: string; method: string }>>('/analytics/activity/detect/', payload).then((r) => r.data.data),

  getWorkouts: (params?: { category?: string; start?: string; end?: string }) =>
    apiClient.get<ApiResponse<unknown[]>>('/analytics/workouts/', { params }).then((r) => r.data),

  createMeal: (payload: MealLogInput) =>
    apiClient.post<ApiResponse<unknown>>('/analytics/meals/', payload).then((r) => r.data),

  getMeals: () =>
    apiClient.get<ApiResponse<unknown[]>>('/analytics/meals/').then((r) => r.data),

  createBodyMetric: (payload: BodyMetricInput) =>
    apiClient.post<ApiResponse<unknown>>('/analytics/body/', payload).then((r) => r.data),

  createBodyMetricWithPhoto: (payload: BodyMetricInput, photo: File) => {
    const fd = new FormData();
    Object.entries(payload).forEach(([k, v]) => {
      if (v !== undefined && v !== null) fd.append(k, String(v));
    });
    fd.append('photo', photo);
    return apiClient.post<ApiResponse<unknown>>('/analytics/body/', fd, {
      headers: { 'Content-Type': 'multipart/form-data' },
    }).then((r) => r.data);
  },

  getBodyMetrics: () =>
    apiClient.get<ApiResponse<unknown[]>>('/analytics/body/').then((r) => r.data),

  generateReport: (period: AnalyticsPeriod = 'all') =>
    apiClient.get<ApiResponse<AnalyticsReportResult>>('/analytics/report/', { params: { period } }).then((r) => r.data),

  downloadReport: (period: AnalyticsPeriod = 'all') =>
    apiClient.get<ApiResponse<{ image_url: string }>>('/analytics/report/download/', { params: { period } }).then((r) => r.data),

  shareReport: (payload: ShareReportPayload) =>
    apiClient.post<ApiResponse<ShareReportResult>>('/analytics/report/share/', payload).then((r) => r.data),
};
