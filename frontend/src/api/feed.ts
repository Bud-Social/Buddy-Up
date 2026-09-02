import type { AxiosProgressEvent } from 'axios';
import { apiClient } from './client';
import type { ApiResponse, Post, Comment } from '@/types';

export type FeedTab = 'for_you' | 'following' | 'videos' | 'videos_following' | 'meals' | 'progress' | 'communities';

/** A sound available in the create studio's sound picker. */
export interface Sound {
  id: string;
  name: string;
  artist: string;
  audio_url: string;
  duration_ms: number;
  source: string;
  license: string;
  usage_count: number;
}

export type SoundOrdering = 'trending' | 'recent';

/** Cloudinary-style signed upload parameters from POST /uploads/sign/. */
export interface SignUploadData {
  cloud_name: string;
  api_key: string;
  timestamp: number;
  signature: string;
  folder: string;
  resource_type: 'image' | 'video';
  eager?: string;
  upload_url: string;
}

export const feedApi = {
  getFeed: (tab: FeedTab = 'for_you', cursor?: string, opts?: { excludePostTypes?: string[] }) =>
    apiClient.get<ApiResponse<Post[]>>('/feed/', {
      params: {
        tab,
        cursor,
        ...(opts?.excludePostTypes?.length ? { exclude_post_types: opts.excludePostTypes.join(',') } : {}),
      },
    }).then((r) => r.data),

  getVideoFeed: (variant: 'fyp' | 'following' = 'fyp', cursor?: string) =>
    apiClient
      .get<ApiResponse<Post[]>>('/feed/', { params: { tab: variant === 'following' ? 'videos_following' : 'videos', cursor } })
      .then((r) => r.data),

  getPost: (postId: string) =>
    apiClient.get<ApiResponse<Post>>(`/feed/${postId}/`).then((r) => r.data),

  createPost: (data: FormData, idempotencyKey?: string) =>
    apiClient.post<ApiResponse<Post>>('/feed/create/', data, {
      headers: {
        'Content-Type': 'multipart/form-data',
        ...(idempotencyKey ? { 'Idempotency-Key': idempotencyKey } : {}),
      },
      // Large media payloads routinely exceed the default 15s client timeout;
      // the server may still complete the post, so give uploads real headroom.
      timeout: 120_000,
    }).then((r) => r.data),

  deletePost: (postId: string) =>
    apiClient.delete(`/feed/${postId}/`).then((r) => r.data),

  react: (postId: string, reaction_type: string) =>
    apiClient.post<ApiResponse<Record<string, number>>>(`/feed/${postId}/react/`, { reaction_type }).then((r) => r.data),

  unreact: (postId: string) =>
    apiClient.delete(`/feed/${postId}/react/`).then((r) => r.data),

  reactComment: (postId: string, commentId: string, reaction_type: string) =>
    apiClient.post<ApiResponse<Record<string, number>>>(`/feed/${postId}/comments/${commentId}/react/`, { reaction_type }).then((r) => r.data),

  unreactComment: (postId: string, commentId: string) =>
    apiClient.delete(`/feed/${postId}/comments/${commentId}/react/`).then((r) => r.data),

  getComments: (postId: string) =>
    apiClient.get<ApiResponse<Comment[]>>(`/feed/${postId}/comments/`).then((r) => r.data),

  comment: (postId: string, payload: { body: string; parent_id?: string }) =>
    apiClient.post<ApiResponse<Comment>>(`/feed/${postId}/comments/`, payload).then((r) => r.data),

  deleteComment: (postId: string, commentId: string) =>
    apiClient.delete(`/feed/${postId}/comments/${commentId}/`).then((r) => r.data),

  repost: (postId: string, quote_body?: string) =>
    apiClient.post<ApiResponse<{ action: 'reposted' | 'unreposted'; repost_count: number }>>(`/feed/${postId}/repost/`, { quote_body }).then((r) => r.data),

  save: (postId: string, collection?: string) =>
    apiClient.post<ApiResponse<null>>(`/feed/${postId}/save/`, { collection }).then((r) => r.data),

  voteOnPoll: (postId: string, optionIds: string[]) =>
    apiClient.post<ApiResponse<any>>(`/feed/${postId}/poll/vote/`, { option_ids: optionIds }).then((r) => r.data),

  pin: (postId: string) =>
    apiClient.post<ApiResponse<{ is_pinned: boolean }>>(`/feed/${postId}/pin/`).then((r) => r.data),

  unsave: (postId: string) =>
    apiClient.delete(`/feed/${postId}/save/`).then((r) => r.data),

  getSaved: (collection?: string) =>
    apiClient.get<ApiResponse<Post[]>>('/feed/saved/', { params: collection ? { collection } : {} }).then((r) => r.data),

  getDrafts: () =>
    apiClient.get<ApiResponse<unknown[]>>('/feed/drafts/').then((r) => r.data),

  saveDraft: (data: Record<string, unknown>) =>
    apiClient.post<ApiResponse<unknown>>('/feed/drafts/', data).then((r) => r.data),

  deleteDraft: (draftId: string) =>
    apiClient.delete(`/feed/drafts/${draftId}/`).then((r) => r.data),

  /** Upload composer media immediately so drafts can reference stable URLs. */
  uploadPostMedia: (
    file: File,
    opts?: {
      onProgress?: (progress: { pct: number; loadedBytes: number; totalBytes: number }) => void;
      signal?: AbortSignal;
    },
  ) => {
    const form = new FormData();
    form.append('file', file);
    return apiClient
      .post<ApiResponse<{ url: string; mime: string; file_name: string; size: number }>>(
        '/messaging/upload/',
        form,
        {
          headers: { 'Content-Type': 'multipart/form-data' },
          timeout: 60_000,
          onUploadProgress: (e: AxiosProgressEvent) => {
            if (opts?.onProgress && e.total) {
              opts.onProgress({
                pct: Math.min(100, Math.round((e.loaded / e.total) * 100)),
                loadedBytes: e.loaded,
                totalBytes: e.total,
              });
            }
          },
          ...(opts?.signal ? { signal: opts.signal } : {}),
        },
      )
      .then((r) => r.data);
  },

  /** Request signed Cloudinary upload params (503 ⇒ direct-upload fallback). */
  signUpload: (resource_type: 'image' | 'video', filename: string) =>
    apiClient
      .post<ApiResponse<SignUploadData>>('/uploads/sign/', { resource_type, filename })
      .then((r) => r.data),

  listSounds: (params?: { q?: string; ordering?: SoundOrdering }) =>
    apiClient.get<ApiResponse<Sound[]>>('/sounds/', { params }).then((r) => r.data),

  createOriginalSound: (payload: { name: string; audio_url: string; duration_ms?: number; original_post?: boolean }) =>
    apiClient.post<ApiResponse<Sound>>('/sounds/', payload).then((r) => r.data),

  /** Count a usage when a sound is selected in the create studio. */
  useSound: (soundId: string) =>
    apiClient.post<ApiResponse<unknown>>(`/sounds/${soundId}/use/`).then((r) => r.data),

  analyzeWorkout: () =>
    apiClient.get<ApiResponse<any>>('/feed/workout/analyze/').then((r) => r.data),

  getHealthInsights: (period: 'weekly' | 'monthly' = 'weekly') =>
    apiClient.get<ApiResponse<any>>('/feed/health-insights/', { params: { period } }).then((r) => r.data),

  analyzeWorkoutForm: (file: File, exercise?: string) => {
    const formData = new FormData();
    formData.append('image', file);
    if (exercise) formData.append('exercise', exercise);
    return apiClient.post<ApiResponse<any>>('/feed/workout-form/', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
      timeout: 30000,
    }).then((r) => r.data);
  },
};
