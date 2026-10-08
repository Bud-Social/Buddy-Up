import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { adminPortalApi, type PortalUser } from '@/api/adminPortal';
import AdminUsers from '@/pages/admin/AdminUsers';

vi.mock('@/api/adminPortal', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/api/adminPortal')>();
  return {
    ...actual,
    adminPortalApi: {
      getUsers: vi.fn(),
      updateUser: vi.fn(),
      suspendUser: vi.fn(),
      reinstateUser: vi.fn(),
    },
  };
});

const getUsers = adminPortalApi.getUsers as unknown as ReturnType<typeof vi.fn>;
const suspendUser = adminPortalApi.suspendUser as unknown as ReturnType<typeof vi.fn>;
const reinstateUser = adminPortalApi.reinstateUser as unknown as ReturnType<typeof vi.fn>;

const envelope = (data: unknown[], pagination?: { count: number; next: string | null; previous: string | null }) => ({
  success: true,
  data,
  message: '',
  errors: null,
  pagination: pagination ?? null,
});

const USERS: PortalUser[] = [
  {
    id: '11111111-2222-3333-4444-555555555555',
    email: 'ada@example.com',
    username: 'ada',
    display_name: 'Ada Lovelace',
    role: 'trainer',
    verification_status: 'trainer',
    is_active: true,
    is_staff: false,
    email_verified: true,
    has_search_profile: true,
    member_count: undefined,
  },
  {
    id: '99999999-8888-7777-6666-555555555555',
    email: 'grace@example.com',
    username: 'grace',
    role: 'user',
    verification_status: 'none',
    is_active: false,
    is_suspended: true,
    suspension_reason: 'repeated chargeback fraud',
  },
];

const renderPage = () =>
  render(
    <MemoryRouter>
      <AdminUsers />
    </MemoryRouter>,
  );

beforeEach(() => {
  vi.clearAllMocks();
  getUsers.mockResolvedValue(envelope(USERS, { count: 2, next: null, previous: null }));
  suspendUser.mockResolvedValue(envelope(USERS[0]));
  reinstateUser.mockResolvedValue(envelope(USERS[1]));
});

describe('AdminUsers list rendering', () => {
  it('shows the skeleton before data arrives', () => {
    getUsers.mockReturnValue(new Promise(() => {}));
    renderPage();
    expect(screen.getByRole('status', { name: /loading/i })).toBeInTheDocument();
  });

  it('renders one row per user with their email and role', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByText('ada@example.com')).toBeInTheDocument());
    expect(screen.getByText('ada')).toBeInTheDocument();
    expect(screen.getByText('grace@example.com')).toBeInTheDocument();
    // Status badges are humanised: role + verification per row. Options in the
    // filter <select> share the same words, so scope the query to the table body.
    const badges = screen.getAllByText('Trainer').filter((el) => el.tagName === 'SPAN' && !el.closest('select'));
    expect(badges.length).toBeGreaterThan(0);
    expect(screen.getAllByText('User').some((el) => !el.closest('select'))).toBe(true);
    expect(screen.getAllByText('None').some((el) => !el.closest('select'))).toBe(true);
  });

  it('shows the match count and pagination summary', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByText(/Page 1 of 1/)).toBeInTheDocument());
    expect(screen.getByText(/2 total/)).toBeInTheDocument();
  });

  it('surfaces the suspension reason and the reinstate action', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByText(/repeated chargeback fraud/)).toBeInTheDocument());
    expect(screen.getByRole('button', { name: /reinstate/i })).toBeInTheDocument();
  });

  it('renders the empty state when nothing matches', async () => {
    getUsers.mockResolvedValue(envelope([], { count: 0, next: null, previous: null }));
    renderPage();
    await waitFor(() => expect(screen.getByText(/No users match the current filters/i)).toBeInTheDocument());
  });

  it('surfaces the server error message and a retry', async () => {
    getUsers.mockRejectedValue(
      Object.assign(new Error('Request failed'), {
        response: { status: 500, data: { success: false, message: 'Portal service unavailable.' } },
      }),
    );
    renderPage();
    await waitFor(() => expect(screen.getByText(/Portal service unavailable/)).toBeInTheDocument());
    expect(screen.getByRole('button', { name: /retry/i })).toBeInTheDocument();
  });

  it('falls back to a generic message when the failure carries no envelope', async () => {
    getUsers.mockRejectedValue(new Error('Network Error'));
    renderPage();
    await waitFor(() => expect(screen.getByText(/Failed to load/)).toBeInTheDocument());
  });

  it('does not crash when fields are missing or renamed', async () => {
    getUsers.mockResolvedValue(envelope([{ id: 'x' }], { count: 1, next: null, previous: null }));
    renderPage();
    await waitFor(() => expect(screen.getByText(/Unnamed user/)).toBeInTheDocument());
    // The short id renders inside the meta line.
    expect(document.body.textContent).toContain('#x');
    expect(screen.getAllByText('Unknown').length).toBeGreaterThan(0);
    expect(screen.getAllByText('—').length).toBeGreaterThan(0);
  });

  it('renders a row with no id at all without throwing', async () => {
    getUsers.mockResolvedValue(envelope([{}], { count: 1, next: null, previous: null }));
    renderPage();
    await waitFor(() => expect(screen.getByText(/Unnamed user/)).toBeInTheDocument());
  });
});

describe('AdminUsers filter interaction', () => {
  it('re-queries the API with the filter value and drops to page 1', async () => {
    renderPage();
    await waitFor(() => expect(getUsers).toHaveBeenCalledTimes(1));

    fireEvent.change(screen.getByLabelText('Role'), { target: { value: 'trainer' } });

    await waitFor(() => expect(getUsers).toHaveBeenCalledTimes(2));
    expect(getUsers.mock.calls[1][0]).toMatchObject({ role: 'trainer', page: 1 });
    expect(getUsers.mock.calls[1][0]).not.toHaveProperty('q', expect.anything());
  });

  it('passes the debounced search term as q', async () => {
    renderPage();
    await waitFor(() => expect(getUsers).toHaveBeenCalledTimes(1));

    fireEvent.change(screen.getByLabelText('Search users'), { target: { value: 'ada' } });

    await waitFor(
      () => {
        const last = getUsers.mock.calls[getUsers.mock.calls.length - 1][0];
        expect(last.q).toBe('ada');
      },
      { timeout: 3000 },
    );
  });

  it('clears every filter back to defaults', async () => {
    renderPage();
    await waitFor(() => expect(getUsers).toHaveBeenCalledTimes(1));

    fireEvent.change(screen.getByLabelText('Role'), { target: { value: 'trainer' } });
    await waitFor(() => expect(screen.getByRole('button', { name: /clear filters/i })).toBeInTheDocument());

    fireEvent.click(screen.getByRole('button', { name: /clear filters/i }));

    await waitFor(() => {
      const last = getUsers.mock.calls[getUsers.mock.calls.length - 1][0];
      expect(last.role).toBe('all');
    });
  });

  it('shows a pagination control and advances the page when there is a next page', async () => {
    getUsers.mockResolvedValue(envelope(USERS, { count: 60, next: 'n', previous: null }));
    renderPage();
    await waitFor(() => expect(screen.getByText(/Page 1 of 3/)).toBeInTheDocument());

    fireEvent.click(screen.getByRole('button', { name: /next/i }));

    await waitFor(() => {
      const last = getUsers.mock.calls[getUsers.mock.calls.length - 1][0];
      expect(last.page).toBe(2);
    });
  });
});

describe('AdminUsers moderation actions', () => {
  it('requires a reason before suspending and posts it', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByRole('button', { name: /suspend/i })).toBeInTheDocument());

    fireEvent.click(screen.getByRole('button', { name: /suspend/i }));

    const confirm = await screen.findByRole('button', { name: /suspend account/i });
    expect(confirm).toBeDisabled();

    fireEvent.change(screen.getByLabelText('Rejection reason'), { target: { value: 'spam network' } });
    expect(confirm).toBeEnabled();

    fireEvent.click(confirm);
    await waitFor(() => expect(suspendUser).toHaveBeenCalledWith(USERS[0].id, { reason: 'spam network' }));
  });

  it('reinstates a suspended user with no reason', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByRole('button', { name: /reinstate/i })).toBeInTheDocument());

    fireEvent.click(screen.getByRole('button', { name: /reinstate/i }));
    await waitFor(() => expect(reinstateUser).toHaveBeenCalledWith(USERS[1].id, {}));
  });

  it('shows the server message when a suspend is refused', async () => {
    suspendUser.mockRejectedValue(
      Object.assign(new Error('nope'), {
        response: { status: 400, data: { success: false, message: 'Cannot suspend the last staff account.' } },
      }),
    );
    renderPage();
    await waitFor(() => expect(screen.getByRole('button', { name: /suspend/i })).toBeInTheDocument());

    fireEvent.click(screen.getByRole('button', { name: /suspend/i }));
    const confirm = await screen.findByRole('button', { name: /suspend account/i });
    fireEvent.change(screen.getByLabelText('Rejection reason'), { target: { value: 'testing' } });
    fireEvent.click(confirm);

    await waitFor(() => expect(screen.getByText(/Cannot suspend the last staff account/)).toBeInTheDocument());
  });
});