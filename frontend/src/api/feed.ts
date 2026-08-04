import { apiClient } from './client';
import type { ApiResponse, Post, Comment } from '@/types';

export type FeedTab = 'for_you' | 'following' | 'videos';

export const feedApi = {
  getFeed: (tab: FeedTab = 'for_you', cursor?: string) =>
    apiClient.get<ApiResponse<Post[]>>('/feed/', { params: { tab, cursor } }).then((r) => r.data),

  getVideoFeed: () =>
    apiClient.get<ApiResponse<Post[]>>('/feed/', { params: { tab: 'videos' } }).then((r) => r.data),

  getPost: (postId: string) =>
    apiClient.get<ApiResponse<Post>>(`/feed/${postId}/`).then((r) => r.data),

  createPost: (data: FormData) =>
    apiClient.post<ApiResponse<Post>>('/feed/create/', data, {
      headers: { 'Content-Type': 'multipart/form-data' },
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
    apiClient.post<ApiResponse<Post>>(`/feed/${postId}/repost/`, { quote_body }).then((r) => r.data),

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
