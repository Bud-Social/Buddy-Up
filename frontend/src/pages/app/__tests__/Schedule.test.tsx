import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import Schedule from '../Schedule';
import { sessionsApi } from '@/api/sessions';
import { gymsApi } from '@/api/gyms';
import { marketplaceApi } from '@/api/marketplace';

vi.mock('@/api/sessions', () => ({ sessionsApi: { getMyBookings: vi.fn() } }));
vi.mock('@/api/gyms', () => ({
  gymsApi: { list: vi.fn(), getMyEnrollments: vi.fn() },
}));
vi.mock('@/api/marketplace', () => ({
  marketplaceApi: { getMyProgrammes: vi.fn(), getMyMealPlans: vi.fn() },
}));

const sessions = sessionsApi as unknown as Record<string, ReturnType<typeof vi.fn>>;
const gyms = gymsApi as unknown as Record<string, ReturnType<typeof vi.fn>>;
const market = marketplaceApi as unknown as Record<string, ReturnType<typeof vi.fn>>;

function later(hours: number): string {
  return new Date(Date.now() + hours * 3_600_000).toISOString();
}

function renderPage() {
  return render(
    <MemoryRouter>
      <Schedule />
    </MemoryRouter>,
  );
}

describe('Schedule', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    sessions.getMyBookings.mockResolvedValue({
      data: [{
        id: 'b1', client_id: 'c1', trainer_id: 't1', session_type: 'in_person',
        status: 'confirmed', scheduled_at: later(3), duration_minutes: 60,
        artifact_fee: {}, notes: '', escrow_tx_id: '', completed_at: null,
        cancelled_at: null, created_at: later(-20),
        client_data: { user_id: 'c1', username: 'me', display_name: 'Me', avatar_url: '', verification_status: 'verified' },
        trainer_data: { user_id: 't1', username: 'sam', display_name: 'Sam Trainer', avatar_url: '', verification_status: 'verified' },
      }],
    });
    gyms.list.mockResolvedValue({ data: [{ handle: 'iron', name: 'Iron Gym' }] });
    gyms.getMyEnrollments.mockResolvedValue({
      data: [{
        id: 'e1', schedule_post: 'p1',
        schedule_post_data: { id: 'p1', title: 'Morning HIIT', activity_type: 'hiit', start_time: later(27) },
      }],
    });
    market.getMyProgrammes.mockResolvedValue({
      data: [{ id: 'pr1', title: 'Strength 8', duration_weeks: 8, category: 'strength' }],
    });
    market.getMyMealPlans.mockResolvedValue({
      data: [{ id: 'mp1', title: 'Lean Week', duration_weeks: 4, diet_type: 'balanced' }],
    });
  });

  it('merges bookings and gym enrolments onto one timeline', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByText('Session with Sam Trainer')).toBeInTheDocument());
    expect(screen.getByText('Morning HIIT')).toBeInTheDocument();
    expect(screen.getByText(/Iron Gym/)).toBeInTheDocument();
    expect(screen.getByText('Booking')).toBeInTheDocument();
    expect(screen.getByText('Gym')).toBeInTheDocument();
  });

  it('keeps owned programmes and meal plans visible as ongoing plans', async () => {
    renderPage();
    await waitFor(() => expect(screen.getByText('Strength 8')).toBeInTheDocument());
    expect(screen.getByText('Lean Week')).toBeInTheDocument();
    expect(screen.getByText('2 owned')).toBeInTheDocument();
  });

  it('links purchases back to the orders tab', async () => {
    renderPage();
    const link = await screen.findByRole('link', { name: /purchases/i });
    expect(link).toHaveAttribute('href', '/sessions?tab=orders');
  });

  it('still renders the page when one source fails', async () => {
    gyms.list.mockRejectedValue(new Error('down'));
    renderPage();
    await waitFor(() => expect(screen.getByText('Session with Sam Trainer')).toBeInTheDocument());
    expect(screen.getByText('Strength 8')).toBeInTheDocument();
  });
});
