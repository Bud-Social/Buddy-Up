import axios from 'axios';
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

export interface CareerPayload {
  name: string;
  email: string;
  role: string;
  portfolio_url?: string;
  message: string;
}

export async function submitSuggestion(
  payload: SuggestionPayload,
): Promise<ApiResponse<{ id: number }>> {
  // Same-origin Vercel serverless function (`api/suggestion.ts`) → Supabase.
  // The Django backend is bypassed pre-launch: its host currently redirects
  // CORS preflights (308), so cross-origin apiClient calls fail entirely.
  const { data } = await axios.post<ApiResponse<{ id: number }>>(
    '/api/suggestion', payload,
  );
  return data;
}

export async function submitContact(
  payload: ContactPayload,
): Promise<ApiResponse<{ id: number }>> {
  // Same-origin Vercel serverless function (`api/contact.ts`) → Supabase.
  // Same-origin ⇒ no CORS preflight; see submitSuggestion for why this
  // bypasses the Django backend.
  const { data } = await axios.post<ApiResponse<{ id: number }>>(
    '/api/contact', payload,
  );
  return data;
}

export async function submitCareer(
  payload: CareerPayload,
): Promise<ApiResponse<{ id: number }>> {
  // Same-origin Vercel serverless function (`api/career.ts`) → Supabase.
  const { data } = await axios.post<ApiResponse<{ id: number }>>(
    '/api/career', payload,
  );
  return data;
}
