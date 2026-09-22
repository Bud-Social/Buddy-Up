import axios from 'axios';
import type { ApiResponse } from '@/types/api';

export type WaitlistInterest = 'user' | 'gym' | 'trainer';

export interface WaitlistEntry {
  id: number;
  email: string;
  name: string;
  country: string;
  source: string;
  interest: WaitlistInterest;
  metadata: Record<string, unknown>;
  created_at: string;
}

/**
 * Joins the waitlist via the same-origin Vercel serverless function
 * (`api/waitlist.ts`), which writes to Supabase and mirrors to Google
 * Sheets server-side. Same-origin ⇒ no CORS involved; the sheet webhook
 * URL and Supabase service key never reach the client bundle.
 */
export async function joinWaitlist(payload: {
  email: string;
  name?: string;
  country: string;
  source?: string;
  interest?: WaitlistInterest;
  metadata?: Record<string, unknown>;
}): Promise<ApiResponse<WaitlistEntry>> {
  const { data } = await axios.post<ApiResponse<WaitlistEntry>>('/api/waitlist', {
    source: 'landing',
    interest: 'user',
    ...payload,
  });
  return data;
}
