import { apiClient } from './client';
import type { ApiResponse } from '@/types/api';

export interface SuggestionPayload {
  title: string;
  description: string;
  category?: string;
  email?: string;
  name?: string;
}

export interface ContactPayload {
  name: string;
  email: string;
  topic?: string;
  subject?: string;
  message: string;
}

export async function submitSuggestion(
  payload: SuggestionPayload,
): Promise<ApiResponse<{ id: number }>> {
  const { data } = await apiClient.post<ApiResponse<{ id: number }>>(
    '/waitlist/suggestions/', payload,
  );
  return data;
}

export async function submitContact(
  payload: ContactPayload,
): Promise<ApiResponse<{ id: number }>> {
  const { data } = await apiClient.post<ApiResponse<{ id: number }>>(
    '/waitlist/contact/', payload,
  );
  return data;
}
