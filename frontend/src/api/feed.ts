import { apiClient } from './client';
import type { ApiResponse, Post, Comment } from '@/types';

export type FeedTab = 'for_you' | 'following' | 'nearby';

export const feedApi = {
  getFeed: (tab: FeedTab = 'for_you', cursor?: string) =>
    apiClient.get<ApiResponse<Post[]>>('/feed/', { params: { tab, cursor } }).then((r) => r.data),

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

  getComments: (postId: string) =>
    apiClient.get<ApiResponse<Comment[]>>(`/feed/${postId}/comments/`).then((r) => r.data),

  comment: (postId: string, body: string, parent_id?: string) =>
    apiClient.post<ApiResponse<Comment>>(`/feed/${postId}/comments/`, { body, parent_id }).then((r) => r.data),

  deleteComment: (postId: string, commentId: string) =>
    apiClient.delete(`/feed/${postId}/comments/${commentId}/`).then((r) => r.data),

  repost: (postId: string, quote_body?: string) =>
    apiClient.post<ApiResponse<Post>>(`/feed/${postId}/repost/`, { quote_body }).then((r) => r.data),

  save: (postId: string, collection?: string) =>
    apiClient.post<ApiResponse<null>>(`/feed/${postId}/save/`, { collection }).then((r) => r.data),

  unsave: (postId: string) =>
    apiClient.delete(`/feed/${postId}/save/`).then((r) => r.data),

  getSaved: (collection?: string) =>
    apiClient.get<ApiResponse<Post[]>>('/feed/saved/', { params: collection ? { collection } : {} }).then((r) => r.data),
};
