import { apiClient } from './client';
import type { ApiResponse } from '@/types';
import type {
  CountdownTemplate,
  UserCountdown,
  CountdownEvent,
  CountdownSignal,
  CreateUserCountdown,
  UpdateUserCountdown,
  Routine,
  CreateRoutine,
  RoutineCheckIn,
  RoutineHighlight,
  HighlightKind,
} from '@/types/countdowns';

export const countdownsApi = {
  listTemplates: () =>
    apiClient
      .get<ApiResponse<CountdownTemplate[]>>('/countdowns/templates/')
      .then((r) => r.data.data),

  seedTemplates: () =>
    apiClient.post<ApiResponse<{ created: number; total: number }>>('/countdowns/templates/seed/').then((r) => r.data.data),

  /** The signals an automatic countdown can advance on. */
  listSignals: () =>
    apiClient
      .get<ApiResponse<CountdownSignal[]>>('/countdowns/signals/')
      .then((r) => r.data.data),

  listCountdowns: (params?: { is_active?: boolean }) =>
    apiClient
      .get<ApiResponse<UserCountdown[]>>('/countdowns/', { params })
      .then((r) => r.data.data),

  createCountdown: (payload: CreateUserCountdown) =>
    apiClient.post<ApiResponse<UserCountdown>>('/countdowns/', payload).then((r) => r.data.data),

  getCountdown: (id: string) =>
    apiClient.get<ApiResponse<UserCountdown>>(`/countdowns/${id}/`).then((r) => r.data.data),

  /** A countdown's stream — every check-in, advance and reset. */
  listEvents: (id: string, params?: { event_type?: string; limit?: number }) =>
    apiClient
      .get<ApiResponse<CountdownEvent[]>>(`/countdowns/${id}/events/`, { params })
      .then((r) => r.data.data),

  updateCountdown: (id: string, payload: UpdateUserCountdown) =>
    apiClient.patch<ApiResponse<UserCountdown>>(`/countdowns/${id}/`, payload).then((r) => r.data.data),

  deleteCountdown: (id: string) =>
    apiClient.delete(`/countdowns/${id}/`).then((r) => r.data),

  checkIn: (id: string) =>
    apiClient.post<ApiResponse<UserCountdown>>(`/countdowns/${id}/checkin/`).then((r) => r.data.data),

  reset: (id: string) =>
    apiClient.post<ApiResponse<UserCountdown>>(`/countdowns/${id}/reset/`).then((r) => r.data.data),

  autoAdvance: (signal: string) =>
    apiClient
      .post<ApiResponse<{ advanced_ids: string[]; count: number }>>('/countdowns/auto-advance/', { signal })
      .then((r) => r.data.data),

  listRoutines: () =>
    apiClient
      .get<ApiResponse<Routine[]>>('/countdowns/routines/')
      .then((r) => r.data.data),

  createRoutine: (payload: CreateRoutine) =>
    apiClient.post<ApiResponse<Routine>>('/countdowns/routines/', payload).then((r) => r.data.data),

  updateRoutine: (id: string, payload: Partial<CreateRoutine>) =>
    apiClient.patch<ApiResponse<Routine>>(`/countdowns/routines/${id}/`, payload).then((r) => r.data.data),

  deleteRoutine: (id: string) =>
    apiClient.delete(`/countdowns/routines/${id}/`).then((r) => r.data),

  /** Persist a drag-and-drop order for the routines list. */
  reorderRoutines: (orderedIds: string[]) =>
    apiClient
      .post<ApiResponse<Routine[]>>('/countdowns/routines/reorder/', { ordered_ids: orderedIds })
      .then((r) => r.data.data),

  /** Logged for in-app and off-app routines alike. */
  checkInRoutine: (id: string, data: { value?: number; note?: string; occurred_at?: string } = {}) =>
    apiClient
      .post<ApiResponse<{ routine: Routine; check_in: RoutineCheckIn }>>(`/countdowns/routines/${id}/checkin/`, data)
      .then((r) => r.data.data),

  listRoutineCheckIns: (id: string) =>
    apiClient
      .get<ApiResponse<RoutineCheckIn[]>>(`/countdowns/routines/${id}/checkins/`)
      .then((r) => r.data.data),

  listRoutineHighlights: (id: string, kind?: HighlightKind) =>
    apiClient
      .get<ApiResponse<RoutineHighlight[]>>(`/countdowns/routines/${id}/highlights/`, { params: kind ? { kind } : undefined })
      .then((r) => r.data.data),

  uploadRoutineHighlight: (id: string, kind: HighlightKind, file: File, caption?: string) => {
    const form = new FormData();
    form.append('kind', kind);
    form.append('file', file);
    if (caption) form.append('caption', caption);
    return apiClient
      .post<ApiResponse<RoutineHighlight>>(`/countdowns/routines/${id}/highlights/`, form, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
      .then((r) => r.data.data);
  },

  deleteRoutineHighlight: (id: string, highlightId: string) =>
    apiClient.delete(`/countdowns/routines/${id}/highlights/${highlightId}/`).then((r) => r.data),

  /** Share the routine as a moment (story) or a workout_log post. */
  shareRoutine: (
    id: string,
    data: { as_story?: boolean; overlay_position?: 'top' | 'middle' | 'bottom'; visibility?: string; media_url?: string; body?: string },
  ) =>
    apiClient
      .post<ApiResponse<{ post_id: string; post_type: string; overlay_position: string }>>(
        `/countdowns/routines/${id}/share/`,
        data,
      )
      .then((r) => r.data.data),
};
