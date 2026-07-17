import { apiClient } from './client';
import type { ApiResponse } from '@/types';

export interface VerificationDocument {
  id: string;
  profile: string;
  document_type: string;
  file_url: string;
  status: string;
  rejection_reason: string;
  reviewed_at: string | null;
  expires_at: string | null;
  created_at: string;
}

export interface VerificationSubmission {
  id: string;
  profile: string;
  verification_type: string;
  status: string;
  documents: VerificationDocument[];
  notes: string;
  reviewed_by: string | null;
  reviewed_at: string | null;
  submitted_at: string | null;
  created_at: string;
}

export const verificationApi = {
  uploadDocument: (documentType: string, fileUrl: string) =>
    apiClient.post<ApiResponse<VerificationDocument>>('/verification/documents/', { document_type: documentType, file_url: fileUrl }).then((r) => r.data),

  listDocuments: () =>
    apiClient.get<ApiResponse<VerificationDocument[]>>('/verification/documents/').then((r) => r.data),

  getDocument: (id: string) =>
    apiClient.get<ApiResponse<VerificationDocument>>(`/verification/documents/${id}/`).then((r) => r.data),

  createSubmission: (verificationType: string, documentIds: string[], notes?: string) =>
    apiClient.post<ApiResponse<VerificationSubmission>>('/verification/submissions/', { verification_type: verificationType, document_ids: documentIds, notes }).then((r) => r.data),

  listSubmissions: () =>
    apiClient.get<ApiResponse<VerificationSubmission[]>>('/verification/submissions/').then((r) => r.data),

  getSubmission: (id: string) =>
    apiClient.get<ApiResponse<VerificationSubmission>>(`/verification/submissions/${id}/`).then((r) => r.data),

  submitDraft: (id: string) =>
    apiClient.post<ApiResponse<VerificationSubmission>>(`/verification/submissions/${id}/submit/`).then((r) => r.data),
};
