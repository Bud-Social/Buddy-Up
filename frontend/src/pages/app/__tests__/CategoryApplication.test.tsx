import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { verificationApi, type VerificationSubmission } from '@/api/verification';
import CategoryApplication from '@/pages/app/CategoryApplication';

/**
 * The apply flow that replaced "choose Trainer at sign-up".
 *
 * Registration now always creates a `user`; `trainer` / `practitioner` are
 * granted when a verification decision is approved by two members of staff. This
 * page is the front door to that, and the list beside it is what tells an
 * applicant the truth about where their application has got to — including the
 * window where a reviewer has recommended a decision and a second approver has
 * not yet acted, during which nothing has been granted.
 */

vi.mock('@/api/verification', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/api/verification')>();
  return {
    ...actual,
    verificationApi: {
      listSubmissions: vi.fn(),
      getMyApplications: vi.fn(),
      uploadDocument: vi.fn(),
      applyForCategory: vi.fn(),
    },
  };
});

const api = verificationApi;
const getMyApplications = api.getMyApplications as unknown as ReturnType<typeof vi.fn>;
const uploadDocument = api.uploadDocument as unknown as ReturnType<typeof vi.fn>;
const applyForCategory = api.applyForCategory as unknown as ReturnType<typeof vi.fn>;

const base: VerificationSubmission = {
  id: 'sub-1',
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

const renderPage = () =>
  render(
    <MemoryRouter>
      <CategoryApplication />
    </MemoryRouter>,
  );

const fillCredentials = () => {
  fireEvent.change(screen.getByLabelText('Credential title'), { target: { value: 'Certified Personal Trainer' } });
  fireEvent.change(screen.getByLabelText('Issuing body'), { target: { value: 'REPs Kenya' } });
  fireEvent.change(screen.getByLabelText('Credential / registration number'), { target: { value: 'REPS-9931' } });
  fireEvent.change(screen.getByLabelText('Date issued'), { target: { value: '2024-02-01' } });
  fireEvent.change(screen.getByLabelText('Scope of practice'), { target: { value: 'general_fitness' } });
};

const attachDocument = async () => {
  fireEvent.change(screen.getByLabelText('Supporting document'), {
    target: { value: 'https://cdn.example.com/cert.pdf' },
  });
  await fireEvent.click(screen.getByRole('button', { name: /Attach/i }));
};

beforeEach(() => {
  vi.clearAllMocks();
  getMyApplications.mockResolvedValue({ success: true, count: 0, data: [] });
  uploadDocument.mockResolvedValue({ data: { id: 'doc-1' } });
  applyForCategory.mockResolvedValue(base);
});

describe('CategoryApplication', () => {
  it('refuses to submit an incomplete trainer application and says what is missing', async () => {
    renderPage();
    await screen.findByText(/Professional categories/i);

    const submit = screen.getByRole('button', { name: /Submit application/i });
    expect(submit).toBeDisabled();
    expect(screen.getByText(/Still needed: credential title/)).toBeInTheDocument();
    expect(applyForCategory).not.toHaveBeenCalled();
  });

  it('sends every field the trainer category requires, plus the attached document id', async () => {
    renderPage();
    await screen.findByText(/Professional categories/i);

    fillCredentials();

    // Credentials alone are not an application: a certificate number with
    // nothing behind it cannot be reviewed.
    expect(screen.getByText(/Attach a supporting document\./)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /Submit application/i })).toBeDisabled();

    await attachDocument();
    await waitFor(() => expect(screen.getByText(/1 document\(s\) attached/)).toBeInTheDocument());

    await fireEvent.click(screen.getByRole('button', { name: /Submit application/i }));

    await waitFor(() => expect(applyForCategory).toHaveBeenCalledTimes(1));
    expect(applyForCategory.mock.calls[0][0]).toMatchObject({
      category: 'trainer',
      credential_title: 'Certified Personal Trainer',
      credential_issuer: 'REPs Kenya',
      credential_id: 'REPS-9931',
      issued_date: '2024-02-01',
      scope_of_practice: 'general_fitness',
      document_ids: ['doc-1'],
    });
  });

  it('asks for a gym handle only for the gym_owner category', async () => {
    renderPage();
    await screen.findByText(/Professional categories/i);

    expect(screen.queryByLabelText('Gym handle')).not.toBeInTheDocument();

    await fireEvent.click(screen.getByRole('button', { name: /Gym owner/i }));
    expect(screen.getByLabelText('Gym handle')).toBeInTheDocument();

    // The professional-only fields are not asked for on a business application.
    expect(screen.queryByLabelText('Scope of practice')).not.toBeInTheDocument();
  });

  it('lists applications, showing a pending one as still ungranted', async () => {
    getMyApplications.mockResolvedValue({
      success: true,
      count: 2,
      data: [
        {
          ...base,
          id: 'sub-pending',
          status: 'under_review',
          approval_state: { id: 'aar-1', status: 'pending', decision: 'approve' },
          pending_approval: { id: 'aar-1', status: 'pending', decision: 'approve' },
        },
        {
          ...base,
          id: 'sub-settled',
          status: 'approved',
          approval_state: {
            id: 'aar-2',
            status: 'approved',
            decision: 'approve',
            decided_at: '2026-03-04T10:00:00Z',
            decision_note: 'Checked against the REPs register.',
          },
          pending_approval: null,
        },
      ],
    });

    renderPage();
    await fireEvent.click(screen.getByRole('button', { name: 'My applications' }));

    const rows = await screen.findAllByTestId('my-application');
    expect(rows).toHaveLength(2);

    expect(rows[0]).toHaveTextContent('With a reviewer');
    expect(rows[0]).toHaveTextContent(/A second approver still has to settle it/);
    expect(rows[0]).toHaveTextContent(/nothing has been granted yet/i);

    expect(rows[1]).toHaveTextContent('Approved');
    // The applicant's decision and the note explaining it.
    expect(rows[1]).toHaveTextContent('Reviewer\'s note');
    expect(rows[1]).toHaveTextContent('Checked against the REPs register.');
  });
});