import { apiClient } from './client';
import type { ApiResponse } from '@/types/api';

export interface WaitlistEntry {
  id: number;
  email: string;
  name: string;
  country: string;
  source: string;
  created_at: string;
}

export async function joinWaitlist(payload: {
  email: string;
  name?: string;
  country: string;
  source?: string;
}): Promise<ApiResponse<WaitlistEntry>> {
  const { data } = await apiClient.post<ApiResponse<WaitlistEntry>>('/waitlist/', {
    source: 'landing',
    ...payload,
  });
  return data;
}
