import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { verificationApi, type VerificationSubmission } from '@/api/verification';
import AdminVerification from '@/pages/app/AdminVerification';

/**
 * Regression coverage for the two-person verification flow.
 *
 * `POST /review/` answers **202** and applies nothing: it raises a decision
 * request and moves the submission to `under_review`. The old queue called it,
 * saw a 2xx, and reported success — so a reviewer was told they had approved a
 * trainer while the applicant was still unverified and held no role.
 *
 * These tests pin the three states that must be distinguishable on screen:
 *
 * 1. a review that has only been *requested*,
 * 2. a decision settled by the second person, and
 * 3. the server's refusal when the requester tries to decide their own request.
 */

vi.mock('@/api/verification', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/api/verification')>();
  return {
    ...actual,
    verificationApi: {
      listSubmissions: vi.fn(),
      reviewSubmission: vi.fn(),
      decideSubmission: vi.fn(),
    },
  };
});

const api = verificationApi;
const listSubmissions = api.listSubmissions as unknown as ReturnType<typeof vi.fn>;
const reviewSubmission = api.reviewSubmission as unknown as ReturnType<typeof vi.fn>;
const decideSubmission = api.decideSubmission as unknown as ReturnType<typeof vi.fn>;

const envelope = (data: unknown[]) => ({ success: true, data, message: '', errors: null, pagination: null });

const BASE: VerificationSubmission = {
  id: 'sub-abcdef01-2345-6789-abcd-ef0123456789',
  profile: 'p-1',
  verification_type: 'trainer',
  status: 'submitted',
  documents: [],
  notes: '',
  gym: null,
  gym_name: null,
  reviewed_by: null,
  reviewed_at: null,
  submitted_at: '2026-03-01T09:00:00Z',
  created_at: '2026-03-01T08:00:00Z',
  current_step: '',
  completed_steps: [],
  face_match_status: 'skipped',
  face_match_score: null,
  credential_title: 'Certified Personal Trainer',
  credential_issuer: 'REPs Kenya',
  credential_id: 'REPS-9931',
  issued_date: '2024-02-01',
  scope_of_practice: 'general_fitness',
  approval_state: null,
  pending_approval: null,
};

const REQUESTED: VerificationSubmission = {
  ...BASE,
  status: 'under_review',
  approval_state: {
    id: 'aar-1',
    status: 'pending',
    decision: 'approve',
    required_scope: 'shops.certifications',
    requested_by_profile: 'Reviewer One',
    requested_at: '2026-03-02T10:00:00Z',
    decided_by: null,
    decided_at: null,
    decision_note: null,
    applied_at: null,
  },
  // Still unverified and still role-less: the reviewer who raised the request
  // has reviewed nothing.
  reviewed_by: null,
  reviewed_at: null,
};

const REQUESTED_BADGE = (requested: VerificationSubmission) => ({
  ...requested,
  pending_approval: requested.approval_state,
});

const renderPage = () =>
  render(
    <MemoryRouter>
      <AdminVerification />
    </MemoryRouter>,
  );

beforeEach(() => {
  vi.clearAllMocks();
  listSubmissions.mockResolvedValue(envelope([BASE]));
  reviewSubmission.mockResolvedValue({ ...REQUESTED_BADGE(REQUESTED) });
  decideSubmission.mockResolvedValue({
    ...BASE,
    status: 'approved',
    approval: {
      id: 'aar-1',
      status: 'approved',
      decision_note: 'Checked against the REPs register.',
      decided_by: 'second@example.com',
      decided_at: '2026-03-02T12:00:00Z',
      applied_at: '2026-03-02T12:00:01Z',
      effect: 'verification_status=trainer',
    },
  });
});

describe('AdminVerification — two-person decisions', () => {
  it('says "awaiting a second approver" after a review, never "approved"', async () => {
    // The queue re-reads after the review, and the server now reports the
    // pending approval.
    listSubmissions
      .mockResolvedValueOnce(envelope([BASE]))
      .mockResolvedValue(envelope([REQUESTED_BADGE(REQUESTED)]));

    renderPage();
    await screen.findByText('Request approval');

    await fireEvent.click(screen.getByRole('button', { name: /Request approval/i }));
    await fireEvent.click(await screen.findByRole('button', { name: /Request decision/i }));

    // The review call happened, with the decision and no invented outcome.
    await waitFor(() =>
      expect(reviewSubmission).toHaveBeenCalledWith(BASE.id, 'approve', undefined),
    );

    // And the page says the application is still unapplied.
    const notice = await screen.findByText(/nothing has been approved yet/i);
    expect(notice).toBeInTheDocument();

    const panel = await screen.findByTestId(`awaiting-second-${BASE.id}`);
    expect(panel).toHaveTextContent('Awaiting a second approver');
    expect(panel).toHaveTextContent('Reviewer One');
    expect(panel).toHaveTextContent(/Nothing has been applied/);

    // Crucially: nothing claims the applicant was approved.
    expect(screen.queryByText('Approved')).not.toBeInTheDocument();
  });

  it('settles the decision through decide/, not review/', async () => {
    listSubmissions.mockResolvedValue(envelope([REQUESTED_BADGE(REQUESTED)]));

    renderPage();
    await screen.findByTestId(`awaiting-second-${BASE.id}`);

    await fireEvent.click(screen.getByRole('button', { name: /Decide: approve/i }));
    await fireEvent.click(await screen.findByRole('button', { name: /Settle decision/i }));

    await waitFor(() =>
      expect(decideSubmission).toHaveBeenCalledWith(BASE.id, 'approve', ''),
    );
    expect(reviewSubmission).not.toHaveBeenCalled();

    expect(await screen.findByText(/Approved by second@example.com/)).toBeInTheDocument();
  });

  it('requires a reason before a rejection can be settled', async () => {
    listSubmissions.mockResolvedValue(envelope([REQUESTED_BADGE(REQUESTED)]));

    renderPage();
    await screen.findByTestId(`awaiting-second-${BASE.id}`);

    await fireEvent.click(screen.getByRole('button', { name: /Decide: reject/i }));
    const submit = await screen.findByRole('button', { name: /Settle decision/i });
    expect(submit).toBeDisabled();

    await fireEvent.change(screen.getByLabelText('Rejection reason'), {
      target: { value: 'The credential number is not on the REPs register.' },
    });
    await fireEvent.click(submit);

    await waitFor(() =>
      expect(decideSubmission).toHaveBeenCalledWith(
        BASE.id,
        'reject',
        'The credential number is not on the REPs register.',
      ),
    );
  });

  it("shows the server's requester-is-not-the-approver refusal verbatim", async () => {
    const refusal =
      'The person who raised this request cannot be the one who decides it. Two-person approval requires a different member of staff.';
    decideSubmission.mockRejectedValue({ response: { status: 403, data: { detail: refusal } } });
    listSubmissions.mockResolvedValue(envelope([REQUESTED_BADGE(REQUESTED)]));

    renderPage();
    await screen.findByTestId(`awaiting-second-${BASE.id}`);

    await fireEvent.click(screen.getByRole('button', { name: /Decide: approve/i }));
    await fireEvent.click(await screen.findByRole('button', { name: /Settle decision/i }));

    expect(await screen.findByText(refusal)).toBeInTheDocument();
  });
});