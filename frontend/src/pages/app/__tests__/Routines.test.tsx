import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import Routines from '@/pages/app/Routines';
import { countdownsApi, type Routine } from '@/api/countdowns';

vi.mock('@/api/countdowns', async (importOriginal) => ({
  ...(await importOriginal<typeof import('@/api/countdowns')>()),
  countdownsApi: {
    listRoutines: vi.fn(),
    createRoutine: vi.fn(),
    updateRoutine: vi.fn(),
    deleteRoutine: vi.fn(),
    reorderRoutines: vi.fn(),
    checkInRoutine: vi.fn(),
    listRoutineHighlights: vi.fn(),
    uploadRoutineHighlight: vi.fn(),
    deleteRoutineHighlight: vi.fn(),
    shareRoutine: vi.fn(),
  },
}));

const api = countdownsApi as unknown as Record<string, ReturnType<typeof vi.fn>>;

const baseRoutine = {
  id: 'r1',
  type: 'gym',
  type_label: 'Gym',
  custom_name: '',
  display_name: 'Gym',
  name: 'Gym',
  target: 4,
  unit: 'sessions',
  days: [0, 3],
  target_day: null,
  time_of_day: null,
  reminder_minutes: [],
  activation: 'week',
  tracking: 'app',
  sort_order: 0,
  streak: 2,
  completed_today: false,
  last_checkin_at: null,
  is_active: true,
  checkin_count: 0,
  highlights: [],
  created_at: '',
  updated_at: '',
} as unknown as Routine;

describe('Routines', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    api.listRoutines.mockResolvedValue([baseRoutine]);
    api.listRoutineHighlights.mockResolvedValue([]);
  });

  it('offers gym and other as first-class routine types', async () => {
    render(<Routines />);
    expect(await screen.findByRole('button', { name: /Gym/ })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /Other/ })).toBeInTheDocument();
  });

  it('requires a custom name before creating an "other" routine', async () => {
    const user = userEvent.setup();
    api.createRoutine.mockResolvedValue({ ...baseRoutine, id: 'r2' });
    render(<Routines />);
    await screen.findByRole('button', { name: /Gym/ });

    await user.click(screen.getByRole('button', { name: /Other/ }));
    expect(screen.getByPlaceholderText(/Cold shower/)).toBeInTheDocument();
    await user.type(screen.getByPlaceholderText(/Cold shower/), 'Cold shower');
    await user.click(screen.getByRole('button', { name: 'Add' }));

    await waitFor(() => expect(api.createRoutine).toHaveBeenCalledWith(
      expect.objectContaining({ type: 'other', custom_name: 'Cold shower' }),
    ));
  });

  it('checks a routine in and refreshes the streak', async () => {
    const user = userEvent.setup();
    api.checkInRoutine.mockResolvedValue({
      routine: { ...baseRoutine, streak: 3, completed_today: true },
      check_in: { id: 'c1', routine: 'r1', value: null, note: '', source: 'app', occurred_at: '', created_at: '' },
    });
    render(<Routines />);
    await screen.findByText('Gym');

    await user.click(screen.getByLabelText('Check in Gym'));

    await waitFor(() => expect(api.checkInRoutine).toHaveBeenCalledWith('r1'));
    expect(await screen.findByText(/3 day streak/)).toBeInTheDocument();
  });
});
