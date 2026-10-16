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
  gym: string | null;
  gym_name: string | null;
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
  /**
   * The latest `AccountActionRequest(action='verification_decision')` for this
   * submission, whether still pending or already settled.
   *
   * `pending_approval` is the same object, non-null *only* while a second
   * approver is still owed. That is what the review queue keys its Decide
   * button off.
   */
  approval_state?: VerificationApprovalState | null;
  pending_approval?: VerificationApprovalState | null;
}

export interface VerificationApprovalState {
  id: string;
  status: string;
  decision?: 'approve' | 'reject' | string | null;
  required_scope?: string | null;
  requested_by_profile?: string | null;
  requested_at?: string | null;
  decided_by?: string | null;
  decided_at?: string | null;
  decision_note?: string | null;
  applied_at?: string | null;
}

/**
 * The **202** body of `POST /verification/submissions/{id}/review/`.
 *
 * This endpoint applies nothing. It raises a decision request and moves the
 * submission to `under_review`; a *different* member of staff settles it with
 * `decide/`. `reviewed_by` / `reviewed_at` deliberately stay empty at this
 * point — the reviewer who raised the request has reviewed nothing.
 *
 * Reading this shape as "approved" is the bug this type exists to prevent, so
 * it is a distinct type rather than a `VerificationSubmission` with an extra
 * field.
 */
export interface VerificationReviewAccepted {
  submission: VerificationSubmission;
  approval_request?: {
    id?: string;
    status?: string | null;
    requested_by_profile?: string | null;
    required_scope?: string | null;
    created_at?: string | null;
  } | null;
}

/** The **200** body of `POST /verification/submissions/{id}/decide/`. */
export interface VerificationDecided extends VerificationSubmission {
  approval?: {
    id?: string;
    status?: string | null;
    decision_note?: string | null;
    decided_by?: string | null;
    decided_at?: string | null;
    applied_at?: string | null;
    effect?: string | null;
  } | null;
}

/**
 * Categories a member of the public may apply for.
 *
 * Mirrors `apps.verification.decisions.CATEGORY_APPLICATION_TYPES`. Identity
 * (`id`) is excluded — the multistep wizard owns it — and so are `shop`/`gym`,
 * which verify a business rather than granting a person a role.
 */
export type CategoryApplicationType =
  | 'trainer'
  | 'practitioner'
  | 'distributor'
  | 'gym_owner'
  | 'shop_owner'
  | 'delivery_partner';

export interface CategoryApplicationPayload {
  category: CategoryApplicationType;
  credential_title?: string;
  credential_issuer?: string;
  credential_id?: string;
  /** `YYYY-MM-DD`. Required for trainer and practitioner. */
  issued_date?: string;
  /** Required for trainer and practitioner. */
  scope_of_practice?: string;
  /** Required for `gym_owner`: the gym being applied to run. */
  gym_handle?: string;
  /** At least one, owned by the applicant. Required for every category. */
  document_ids?: string[];
  notes?: string;
}

/**
 * `GET /verification/my-applications/` answers `{count, results}`, not the
 * `{success,data}` envelope every other endpoint here uses.
 *
 * Normalised to the same `{success,data}` shape so callers do not have to hold
 * two shapes in their head for the same list.
 */
export interface MyApplicationsResponse {
  success: boolean;
  count: number;
  data: VerificationSubmission[];
  message?: string;
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
    issued_date?: string; scope_of_practice?: string; gym_handle?: string;
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

  /**
   * Raise a decision on a submission. **Applies nothing.**
   *
   * Answers **202** with the submission plus an `approval_request`. The
   * submission moves to `under_review` and stays there until a second member of
   * staff calls {@link decideSubmission} — and the server refuses if that second
   * person is the same account.
   *
   * Do not read a resolution as an approval. The UI has to say "awaiting a
   * second approver" here, not "approved".
   */
  reviewSubmission: (id: string, action: 'approve' | 'reject', rejectionReason?: string, documentIds?: string[]) =>
    apiClient.post<VerificationSubmission & { approval_request?: VerificationReviewAccepted['approval_request'] }>(
      `/verification/submissions/${id}/review/`,
      { action, rejection_reason: rejectionReason, document_ids: documentIds },
    ).then((r) => r.data),

  /**
   * Settle the pending decision. This is the call that applies the effect.
   *
   * Refuses when the caller is the person who raised the request, when the
   * request is already settled, and when a rejection carries no note.
   */
  decideSubmission: (id: string, action: 'approve' | 'reject', note?: string) =>
    apiClient.post<VerificationDecided>(`/verification/submissions/${id}/decide/`, { action, note }).then((r) => r.data),

  /**
   * Apply for an elevated role.
   *
   * Produces a `submitted` submission in one call: the fields are validated per
   * category *before* the row is created, so an application missing its
   * credential number is refused at the door instead of arriving in a reviewer's
   * queue as an administrative rejection.
   */
  applyForCategory: (payload: CategoryApplicationPayload) =>
    apiClient.post<VerificationSubmission>('/verification/category-applications/', payload).then((r) => r.data),

  /** The caller's own applications, newest first, with the decision note. */
  getMyApplications: (params?: { category?: string }) =>
    apiClient
      .get<{ count?: number; results?: VerificationSubmission[] } | VerificationSubmission[]>('/verification/my-applications/', { params })
      .then((r) => {
        const body = r.data as { count?: number; results?: VerificationSubmission[] } | VerificationSubmission[];
        const results = Array.isArray(body) ? body : body?.results;
        return {
          success: true,
          count: Array.isArray(body) ? body.length : body?.count ?? results?.length ?? 0,
          data: Array.isArray(results) ? results : [],
        } satisfies MyApplicationsResponse;
      }),
};
