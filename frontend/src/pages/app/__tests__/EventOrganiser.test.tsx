import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import EventOrganiser from '@/pages/app/EventOrganiser';
import { marketplaceApi } from '@/api/marketplace';

vi.mock('@/api/marketplace', async (importOriginal) => ({
  ...(await importOriginal<typeof import('@/api/marketplace')>()),
  marketplaceApi: {
    getOrganisedEvents: vi.fn(),
    getEventAttendees: vi.fn(),
    getEventStats: vi.fn(),
    checkInAttendee: vi.fn(),
    checkOutAttendee: vi.fn(),
  },
}));

const api = marketplaceApi as unknown as Record<string, ReturnType<typeof vi.fn>>;

/** Axios-shaped rejection so status-code branches are exercised for real. */
const httpError = (status: number, message = '') =>
  Object.assign(new Error(message || `HTTP ${status}`), { response: { status, data: { message } } });

const envelope = (data: unknown) => ({ success: true, data, message: '', errors: null, pagination: null });

const EVENTS = [
  { id: 'ev-1', title: 'Sunrise Run', start_datetime: '2026-06-01T06:00:00Z', end_datetime: '2026-06-01T09:00:00Z', capacity: 100, attendee_count: 40, tickets_sold_count: 45, is_published: true, is_cancelled: false },
];

const STATS = {
  capacity: 100,
  tickets_sold: 45,
  checked_in: 12,
  gross_artifacts: { champion: 3 },
  sold_by_tier: [{ tier: 'early_bird', count: 20, gross_artifacts: { burpee: 40 } }, { tier: 'standard', count: 25, gross_artifacts: { burpee: 75 } }],
};

const attendee = (over: Record<string, unknown> = {}) => ({
  id: 't-1',
  ticket_code: 'BUD-EV-AAAA',
  tier: 'standard',
  status: 'valid',
  is_checked_in: false,
  checked_in_at: null,
  price_paid_artifacts: { burpee: 3 },
  display_name: 'Wanjiku',
  username: 'wanjiku',
  ...over,
});

function renderPage(attendees: unknown[] = []) {
  api.getOrganisedEvents.mockResolvedValue(envelope(EVENTS));
  api.getEventStats.mockResolvedValue(envelope(STATS));
  api.getEventAttendees.mockResolvedValue(envelope(attendees));
  return render(
    <MemoryRouter initialEntries={['/marketplace/events']}>
      <EventOrganiser />
    </MemoryRouter>,
  );
}

describe('EventOrganiser — check-in', () => {
  beforeEach(() => vi.clearAllMocks());

  it('checks a pasted ticket code in and surfaces success', async () => {
    api.checkInAttendee.mockResolvedValue(envelope({ message: 'Checked in Wanjiku.' }));
    renderPage([attendee()]);

    await screen.findByText('Wanjiku');
    await userEvent.type(screen.getByLabelText('Ticket code'), 'BUD-EV-AAAA');
    await userEvent.click(screen.getByRole('button', { name: 'Check in', exact: true }));

    await waitFor(() => expect(api.checkInAttendee).toHaveBeenCalledWith('ev-1', 'BUD-EV-AAAA'));
    expect(await screen.findByRole('status')).toHaveTextContent('Checked in Wanjiku.');
  });

  it('surfaces the 409 "already checked in" message verbatim, including who and when', async () => {
    api.checkInAttendee.mockRejectedValue(
      httpError(409, 'This ticket was already checked in by Njeri at 2026-06-01T06:12:00Z.'),
    );
    renderPage([attendee()]);

    await screen.findByText('Wanjiku');
    await userEvent.type(screen.getByLabelText('Ticket code'), 'BUD-EV-AAAA');
    await userEvent.click(screen.getByRole('button', { name: 'Check in', exact: true }));

    const alert = await screen.findByRole('alert');
    expect(alert).toHaveTextContent('This ticket was already checked in by Njeri at 2026-06-01T06:12:00Z.');
    // The attendee is not added to the list on a rejected check-in.
    expect(screen.queryByText('Checked in Wanjiku.')).not.toBeInTheDocument();
  });

  it('surfaces the 404 for an unknown ticket code', async () => {
    api.checkInAttendee.mockRejectedValue(httpError(404, 'No ticket matches that code.'));
    renderPage([attendee()]);

    await screen.findByText('Wanjiku');
    await userEvent.type(screen.getByLabelText('Ticket code'), 'NOPE-0000');
    await userEvent.click(screen.getByRole('button', { name: 'Check in', exact: true }));

    expect(await screen.findByRole('alert')).toHaveTextContent('No ticket matches that code.');
  });

  it('surfaces the 400 for a cancelled ticket', async () => {
    api.checkInAttendee.mockRejectedValue(httpError(400, 'This ticket was cancelled and cannot be checked in.'));
    renderPage([attendee()]);

    await screen.findByText('Wanjiku');
    await userEvent.type(screen.getByLabelText('Ticket code'), 'BUD-EV-CANC');
    await userEvent.click(screen.getByRole('button', { name: 'Check in', exact: true }));

    expect(await screen.findByRole('alert')).toHaveTextContent('This ticket was cancelled and cannot be checked in.');
  });

  it('reverses a mistaken check-in', async () => {
    api.checkOutAttendee.mockResolvedValue(envelope({}));
    renderPage([attendee({ is_checked_in: true, checked_in_at: '2026-06-01T06:12:00Z' })]);

    await screen.findByText('Wanjiku');
    await userEvent.click(screen.getByRole('button', { name: 'Undo' }));

    await waitFor(() => expect(api.checkOutAttendee).toHaveBeenCalledWith('ev-1', 'BUD-EV-AAAA'));
    expect(await screen.findByRole('status')).toHaveTextContent('Reversed check-in for BUD-EV-AAAA.');
  });
});

describe('EventOrganiser — attendee filters', () => {
  beforeEach(() => vi.clearAllMocks());

  it('requests every attendee when no filter is set', async () => {
    renderPage([attendee()]);
    await screen.findByText('Wanjiku');
    await waitFor(() =>
      expect(api.getEventAttendees).toHaveBeenLastCalledWith('ev-1', { checked_in: '', status: undefined, tier: undefined }),
    );
  });

  it('sends checked_in=false when filtering to attendees not yet in', async () => {
    renderPage([attendee()]);
    await screen.findByText('Wanjiku');

    await userEvent.click(screen.getByRole('button', { name: 'Not in' }));

    await waitFor(() =>
      expect(api.getEventAttendees).toHaveBeenLastCalledWith('ev-1', expect.objectContaining({ checked_in: false })),
    );
    expect(screen.getByRole('button', { name: 'Not in' })).toHaveAttribute('aria-pressed', 'true');
  });

  it('sends checked_in=true when filtering to attendees already in', async () => {
    renderPage([attendee({ is_checked_in: true })]);
    await screen.findByText('Wanjiku');

    await userEvent.click(screen.getByRole('button', { name: 'In' }));

    await waitFor(() =>
      expect(api.getEventAttendees).toHaveBeenLastCalledWith('ev-1', expect.objectContaining({ checked_in: true })),
    );
  });

  it('sends the ticket status filter', async () => {
    renderPage([attendee()]);
    await screen.findByText('Wanjiku');

    await userEvent.selectOptions(screen.getByLabelText('Filter by ticket status'), 'cancelled');

    await waitFor(() =>
      expect(api.getEventAttendees).toHaveBeenLastCalledWith('ev-1', expect.objectContaining({ status: 'cancelled' })),
    );
  });

  it('sends the tier filter', async () => {
    renderPage([attendee()]);
    await screen.findByText('Wanjiku');

    await userEvent.type(screen.getByLabelText('Filter by tier'), 'vip');

    await waitFor(() =>
      expect(api.getEventAttendees).toHaveBeenLastCalledWith('ev-1', expect.objectContaining({ tier: 'vip' })),
    );
  });

  it('combines all three filters into one request', async () => {
    renderPage([attendee()]);
    await screen.findByText('Wanjiku');

    await userEvent.click(screen.getByRole('button', { name: 'Not in' }));
    await userEvent.selectOptions(screen.getByLabelText('Filter by ticket status'), 'valid');
    await userEvent.type(screen.getByLabelText('Filter by tier'), 'standard');

    await waitFor(() =>
      expect(api.getEventAttendees).toHaveBeenLastCalledWith('ev-1', { checked_in: false, status: 'valid', tier: 'standard' }),
    );
  });

  it('shows an empty state rather than a stale list when filters match nothing', async () => {
    renderPage([]);
    await screen.findByRole('heading', { name: /Attendees/ });
    expect(screen.getByText('No attendees match these filters.')).toBeInTheDocument();
  });

  it('degrades the attendee table alone when the endpoint fails', async () => {
    renderPage([]);
    api.getEventAttendees.mockRejectedValue(httpError(500, 'Attendee service unavailable.'));

    expect(await screen.findByText('Attendee service unavailable.')).toBeInTheDocument();
    // Stats still render — one failing panel must not blank the page.
    expect(screen.getByText('Checked in')).toBeInTheDocument();
  });
});

describe('EventOrganiser — stats and events', () => {
  beforeEach(() => vi.clearAllMocks());

  it('shows ticket, check-in, capacity and tier breakdown for the selected event', async () => {
    renderPage([attendee()]);
    await screen.findByText('Wanjiku');

    expect(screen.getByText('Tickets sold')).toBeInTheDocument();
    expect(screen.getByText('45')).toBeInTheDocument();
    expect(screen.getByText('12')).toBeInTheDocument();
    expect(screen.getByText('100')).toBeInTheDocument();
    expect(screen.getByText('Sold by tier')).toBeInTheDocument();
    expect(screen.getByText('20 sold')).toBeInTheDocument();
  });

  it('offers a create path when the operator has no events', async () => {
    api.getOrganisedEvents.mockResolvedValue(envelope([]));
    render(
      <MemoryRouter initialEntries={['/marketplace/events']}>
        <EventOrganiser />
      </MemoryRouter>,
    );

    expect(await screen.findByText('You have not created any events yet.')).toBeInTheDocument();
  });

  it('explains a 403 rather than rendering an empty organiser shell', async () => {
    api.getOrganisedEvents.mockRejectedValue(httpError(403, 'Only event organisers may do this.'));
    render(
      <MemoryRouter initialEntries={['/marketplace/events']}>
        <EventOrganiser />
      </MemoryRouter>,
    );

    expect(await screen.findByText('Only event organisers may do this.')).toBeInTheDocument();
  });
});