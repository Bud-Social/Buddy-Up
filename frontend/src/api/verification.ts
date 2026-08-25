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
  current_step: string;
  completed_steps: string[];
  face_match_status: 'pending' | 'auto_matched' | 'manual_review' | 'failed' | 'skipped';
  face_match_score: number | null;
  credential_title: string;
  credential_issuer: string;
  credential_id: string;
  issued_date: string | null;
  scope_of_practice: string;
}

export const verificationApi = {
  uploadDocument: (documentType: string, fileUrl: string) =>
    apiClient.post<ApiResponse<VerificationDocument>>('/verification/documents/', { document_type: documentType, file_url: fileUrl }).then((r) => r.data),

  listDocuments: () =>
    apiClient.get<ApiResponse<VerificationDocument[]>>('/verification/documents/').then((r) => r.data),

  getDocument: (id: string) =>
    apiClient.get<ApiResponse<VerificationDocument>>(`/verification/documents/${id}/`).then((r) => r.data),

  createSubmission: (verificationType: string, documentIds: string[], notes?: string, credential?: {
    credential_title?: string; credential_issuer?: string; credential_id?: string;
    issued_date?: string; scope_of_practice?: string;
  }) =>
    apiClient.post<ApiResponse<VerificationSubmission>>('/verification/submissions/', {
      verification_type: verificationType, document_ids: documentIds, notes, ...credential,
    }).then((r) => r.data),

  listSubmissions: () =>
    apiClient.get<ApiResponse<VerificationSubmission[]>>('/verification/submissions/').then((r) => r.data),

  getSubmission: (id: string) =>
    apiClient.get<ApiResponse<VerificationSubmission>>(`/verification/submissions/${id}/`).then((r) => r.data),

  submitDraft: (id: string) =>
    apiClient.post<ApiResponse<VerificationSubmission>>(`/verification/submissions/${id}/submit/`).then((r) => r.data),

  startIdWizard: (id: string) =>
    apiClient.post<ApiResponse<VerificationSubmission>>(`/verification/submissions/${id}/start/`).then((r) => r.data),

  uploadStep: (id: string, step: 'id_document' | 'selfie_liveness', file: Blob, filename: string, documentType?: string) => {
    const form = new FormData();
    form.append('step', step);
    form.append('file', file, filename);
    if (documentType) form.append('document_type', documentType);
    return apiClient.post<ApiResponse<VerificationSubmission & { uploaded_document: VerificationDocument; face_match: { status: string; score: number | null } | null }>>(
      `/verification/submissions/${id}/upload_step/`, form,
      { headers: { 'Content-Type': 'multipart/form-data' } },
    ).then((r) => r.data);
  },

  reviewSubmission: (id: string, action: 'approve' | 'reject', rejectionReason?: string, documentIds?: string[]) =>
    apiClient.post<ApiResponse<VerificationSubmission>>(`/verification/submissions/${id}/review/`, {
      action, rejection_reason: rejectionReason, document_ids: documentIds,
    }).then((r) => r.data),
};
