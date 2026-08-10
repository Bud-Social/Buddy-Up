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

  getWorkouts: () =>
    apiClient.get<ApiResponse<unknown[]>>('/analytics/workouts/').then((r) => r.data),

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
