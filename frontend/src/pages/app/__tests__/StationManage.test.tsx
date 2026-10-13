import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import StationManage from '@/pages/app/StationManage';
import { stationsApi, deriveOwnedStations, isStationOwnedBy, isPendingApplication } from '@/api/stations';
import { useAuthStore } from '@/store/authStore';

vi.mock('@/api/stations', async (importOriginal) => ({
  ...(await importOriginal<typeof import('@/api/stations')>()),
  stationsApi: { list: vi.fn(), create: vi.fn(), update: vi.fn(), apply: vi.fn() },
}));

vi.mock('@/components/ui/Toast', async (importOriginal) => ({
  ...(await importOriginal<typeof import('@/components/ui/Toast')>()),
  useToast: () => ({ toast: vi.fn() }),
}));

const api = stationsApi as unknown as Record<string, ReturnType<typeof vi.fn>>;
const httpError = (status: number, message = '') =>
  Object.assign(new Error(message), { response: { status, data: { message } } });

const ME = { id: 'u-me', username: 'karen' };

const SHOP_STATION = {
  id: 's-shop', name: 'Westlands Hub', address: 'Sarita Centre', city: 'Nairobi', country: 'KE',
  owner_type: 'shop', is_primary: true,
  shop: { id: 'sh-1', name: 'FitGear', handle: 'fitgear', owner: 'u-me' },
  opening_hours: { monday: { open: '08:00', close: '20:00' }, tuesday: { open: '08:00', close: '20:00' } },
};

const OTHER_SHOP_STATION = {
  id: 's-other-shop', name: 'Karen Junction', address: 'Thika Rd', city: 'Nairobi', country: 'KE',
  owner_type: 'shop',
  shop: { id: 'sh-2', name: 'Other Fitness', handle: 'otherfitness', owner: 'u-someone-else' },
};

const GYM_STATION = {
  id: 's-gym', name: 'Gym Locker', address: 'Langata', city: 'Nairobi', country: 'KE',
  owner_type: 'gym',
  gym: {
    id: 'g-1', name: 'Legit Gym', handle: 'legitgym',
    owner_data: [
      { user_id: 'u-me', username: 'karen', role: 'co_owner' },
      { user_id: 'u-other', username: 'other', role: 'member' },
    ],
  },
};

function signIn() {
  useAuthStore.setState({
    isAuthenticated: true,
    user: { id: ME.id, is_staff: false } as never,
    profile: { username: ME.username } as never,
  });
}

function renderPage(rows: unknown[]) {
  api.list.mockResolvedValue({ success: true, data: rows, message: '', errors: null, pagination: null });
  return render(
    <MemoryRouter initialEntries={['/marketplace/stations']}>
      <StationManage />
    </MemoryRouter>,
  );
}

describe('deriveOwnedStations — ownership from the list response', () => {
  it('keeps only the stations the caller may edit', () => {
    const owned = deriveOwnedStations([SHOP_STATION, OTHER_SHOP_STATION, GYM_STATION] as never[], ME);
    expect(owned.map((s) => s.id)).toEqual(['s-shop', 's-gym']);
  });

  it('matches a shop owner by username as well as id', () => {
    const station = { ...SHOP_STATION, shop: { owner_username: 'karen' } };
    expect(isStationOwnedBy(station as never, ME)).toBe(true);
    expect(isStationOwnedBy(station as never, { username: 'someone-else' })).toBe(false);
  });

  it('treats a gym co-owner as an owner but not a plain member', () => {
    const coOwner = { owner_type: 'gym', gym: { owner_data: [{ user_id: 'u-me', role: 'co_owner' }] } };
    const member = { owner_type: 'gym', gym: { owner_data: [{ user_id: 'u-me', role: 'member' }] } };
    const moderator = { owner_type: 'gym', gym: { owner_data: [{ user_id: 'u-me', role: 'moderator' }] } };
    expect(isStationOwnedBy(coOwner as never, ME)).toBe(true);
    expect(isStationOwnedBy(member as never, ME)).toBe(false);
    expect(isStationOwnedBy(moderator as never, ME)).toBe(false);
  });

  it('claims nothing when the identity is unknown', () => {
    expect(isStationOwnedBy(SHOP_STATION as never, null)).toBe(false);
    expect(isStationOwnedBy(SHOP_STATION as never, {})).toBe(false);
    expect(deriveOwnedStations([SHOP_STATION] as never[], undefined)).toEqual([]);
  });

  it('claims nothing for a station with no owner reference', () => {
    expect(isStationOwnedBy({ id: 'x', owner_type: 'shop' } as never, ME)).toBe(false);
    expect(isStationOwnedBy({ id: 'x' } as never, ME)).toBe(false);
  });

  it('does not claim a station whose owner type is unknown to the contract', () => {
    expect(isStationOwnedBy({ owner_type: 'community', shop: { owner: 'u-me' } } as never, ME)).toBe(false);
  });
});

describe('StationManage — station list', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    signIn();
  });

  it('lists only the stations the caller owns and counts the rest', async () => {
    renderPage([SHOP_STATION, OTHER_SHOP_STATION, GYM_STATION]);

    expect(await screen.findByText('Westlands Hub')).toBeInTheDocument();
    expect(screen.getByText('Gym Locker')).toBeInTheDocument();
    expect(screen.queryByText('Karen Junction')).not.toBeInTheDocument();
    expect(screen.getByText('2 of 3')).toBeInTheDocument();
  });

  it('says plainly when the caller owns none of the stations that exist', async () => {
    renderPage([OTHER_SHOP_STATION]);
    expect(await screen.findByText('You do not own any of the stations on this server yet.')).toBeInTheDocument();
    expect(screen.queryByText('Westlands Hub')).not.toBeInTheDocument();
  });

  it('explains a not-yet-deployed stations endpoint instead of showing an empty list', async () => {
    api.list.mockRejectedValue(httpError(404, 'Not found.'));
    render(
      <MemoryRouter initialEntries={['/marketplace/stations']}>
        <StationManage />
      </MemoryRouter>,
    );
    expect(await screen.findByText('Pickup stations are not available on this server yet.')).toBeInTheDocument();
  });
});

describe('StationManage — create, edit and apply', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    signIn();
  });

  it('creates a station with the fields the operator entered', async () => {
    api.create.mockResolvedValue({ success: true, data: { id: 's-new' } });
    renderPage([SHOP_STATION]);

    await screen.findByText('Westlands Hub');
    await userEvent.click(screen.getByRole('button', { name: 'New station' }));

    await userEvent.type(screen.getByLabelText('Name'), 'Karen Junction');
    await userEvent.type(screen.getByLabelText('City'), 'Nairobi');
    await userEvent.type(screen.getByLabelText('Latitude'), '-1.2864');
    await userEvent.type(screen.getByLabelText('monday opening time'), '08:00');
    await userEvent.click(screen.getByRole('button', { name: 'Create station' }));

    await waitFor(() => expect(api.create).toHaveBeenCalled());
    const payload = api.create.mock.calls[0][0];
    expect(payload.name).toBe('Karen Junction');
    expect(payload.city).toBe('Nairobi');
    expect(payload.latitude).toBeCloseTo(-1.2864);
    expect(payload.opening_hours).toEqual({ monday: { open: '08:00', close: '' } });
  });

  it('edits an existing station through the PATCH path', async () => {
    api.update.mockResolvedValue({ success: true, data: SHOP_STATION });
    renderPage([SHOP_STATION]);

    await screen.findByText('Westlands Hub');
    await userEvent.click(screen.getByRole('button', { name: 'Edit Westlands Hub' }));

    const nameField = screen.getByLabelText('Name');
    await userEvent.clear(nameField);
    await userEvent.type(nameField, 'Westlands Hub 2');
    await userEvent.click(screen.getByRole('button', { name: 'Save changes' }));

    await waitFor(() => expect(api.update).toHaveBeenCalledWith('s-shop', expect.objectContaining({ name: 'Westlands Hub 2' })));
  });

  it('applies to become a station and surfaces the pending approval status', async () => {
    api.apply.mockResolvedValue({ success: true, data: { id: 'app-1', status: 'pending', station_name: 'Karen Junction' } });
    renderPage([SHOP_STATION]);

    await screen.findByText('Westlands Hub');
    await userEvent.click(screen.getByRole('button', { name: 'Apply to become a station' }));

    expect(await screen.findByText('Application status')).toBeInTheDocument();
    expect(screen.getByText('pending')).toBeInTheDocument();
    expect(screen.getByText(/awaiting review/i)).toBeInTheDocument();
  });

  it('reports the outcome of a decision rather than leaving a stale pending state', async () => {
    api.apply.mockResolvedValue({ success: true, data: { id: 'app-1', status: 'rejected', rejection_reason: 'Site visit required first.' } });
    renderPage([SHOP_STATION]);

    await screen.findByText('Westlands Hub');
    await userEvent.click(screen.getByRole('button', { name: 'Apply to become a station' }));

    expect(await screen.findByText('Site visit required first.')).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Apply to become a station' })).not.toBeInTheDocument();
  });

  it('keeps an approved application from offering a second submission', async () => {
    api.apply.mockResolvedValue({ success: true, data: { id: 'app-1', status: 'approved' } });
    renderPage([SHOP_STATION]);

    await screen.findByText('Westlands Hub');
    await userEvent.click(screen.getByRole('button', { name: 'Apply to become a station' }));

    expect(await screen.findByText(/Add the station details/)).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Apply to become a station' })).not.toBeInTheDocument();
  });
});

describe('isPendingApplication', () => {
  it.each(['pending', 'submitted', 'under_review'])('treats %s as pending', (status) => {
    expect(isPendingApplication(status)).toBe(true);
  });

  it.each(['approved', 'rejected', undefined, null, 42])('treats %s as decided', (status) => {
    expect(isPendingApplication(status)).toBe(false);
  });
});