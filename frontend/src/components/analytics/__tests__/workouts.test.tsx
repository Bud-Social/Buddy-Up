import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { WorkoutsTab } from '../WorkoutsTab';
import { analyticsApi } from '@/api/analytics';

vi.mock('@/api/analytics', () => ({
  analyticsApi: {
    getSummary: vi.fn(),
    getWorkouts: vi.fn(),
    createWorkout: vi.fn(),
    getWorkoutTypes: vi.fn(),
    shareActivity: vi.fn(),
  },
}));

const api = analyticsApi as unknown as Record<string, ReturnType<typeof vi.fn>>;

const YOGA_ROW = {
  id: 'w-yoga',
  workout_type: 'yoga',
  category: 'balance',
  exercise: 'Flow',
  duration_minutes: 45,
  calories_burned: 180,
  performed_at: '2026-02-01T06:30:00Z',
};

function renderTab() {
  return render(<MemoryRouter><WorkoutsTab period="month" /></MemoryRouter>);
}

beforeEach(() => {
  vi.clearAllMocks();
  api.getSummary.mockResolvedValue({ data: { workouts: { count: 1, total_calories_burned: 180, total_volume: 0, by_type: [], most_trained: null, recent: [] } } });
  api.getWorkouts.mockResolvedValue({ data: [YOGA_ROW] });
  api.createWorkout.mockResolvedValue({ data: {} });
  // Catalog fetch fails so the form renders from the local fallback.
  api.getWorkoutTypes.mockRejectedValue(new Error('offline'));
  Object.defineProperty(navigator, 'clipboard', {
    value: { writeText: vi.fn().mockResolvedValue(undefined) },
    configurable: true,
  });
});

describe('WorkoutsTab field visibility', () => {
  it('shows sets/reps/weight for the default strength type', async () => {
    renderTab();
    await waitFor(() => expect(screen.getByLabelText('Sets')).toBeDefined());
    expect(screen.getByLabelText('Reps')).toBeDefined();
    expect(screen.getByLabelText('Weight kg')).toBeDefined();
    expect(screen.queryByLabelText('Rounds')).toBeNull();
  });

  it('swaps to style + duration for yoga and drops every measured field', async () => {
    renderTab();
    await waitFor(() => expect(screen.getByLabelText('Sets')).toBeDefined());

    fireEvent.click(screen.getByRole('button', { name: 'Yoga' }));

    expect(screen.getByLabelText('Style')).toBeDefined();
    expect(screen.getByLabelText('Duration (min)')).toBeDefined();
    expect(screen.queryByLabelText('Sets')).toBeNull();
    expect(screen.queryByLabelText('Reps')).toBeNull();
    expect(screen.queryByLabelText('Weight kg')).toBeNull();
    expect(screen.getByText('Flexibility')).toBeDefined();
    expect(screen.getByText('Mindfulness')).toBeDefined();
    expect(screen.getByText(/isn't tracked in sets or reps/)).toBeDefined();
  });

  it('shows distance + calories and no category chips for cardio', async () => {
    renderTab();
    await waitFor(() => expect(screen.getByLabelText('Sets')).toBeDefined());

    fireEvent.click(screen.getByRole('button', { name: 'Cardio' }));

    expect(screen.getByLabelText('Distance km')).toBeDefined();
    expect(screen.getByLabelText('Calories')).toBeDefined();
    expect(screen.queryByText('Category')).toBeNull();
  });

  it('shows rounds for hiit and a sport field for sport', async () => {
    renderTab();
    await waitFor(() => expect(screen.getByLabelText('Sets')).toBeDefined());

    fireEvent.click(screen.getByRole('button', { name: 'HIIT' }));
    expect(screen.getByLabelText('Rounds')).toBeDefined();
    expect(screen.queryByLabelText('Distance km')).toBeNull();

    fireEvent.click(screen.getByRole('button', { name: 'Sport' }));
    expect(screen.getByLabelText('Sport')).toBeDefined();
    expect(screen.queryByLabelText('Rounds')).toBeNull();
  });
});

describe('WorkoutsTab submit', () => {
  it('never submits stale strength numbers after switching to a run', async () => {
    renderTab();
    await waitFor(() => expect(screen.getByLabelText('Sets')).toBeDefined());

    fireEvent.change(screen.getByLabelText('Sets'), { target: { value: '5' } });
    fireEvent.change(screen.getByLabelText('Reps'), { target: { value: '10' } });
    fireEvent.click(screen.getByRole('button', { name: 'Running' }));
    fireEvent.change(screen.getByLabelText('Distance km'), { target: { value: '5.5' } });
    fireEvent.click(screen.getByRole('button', { name: '30 min' }));
    fireEvent.click(screen.getByRole('button', { name: 'Save Workout' }));

    await waitFor(() => expect(api.createWorkout).toHaveBeenCalledTimes(1));
    expect(api.createWorkout).toHaveBeenCalledWith({
      workout_type: 'running',
      category: '',
      distance_meters: 5500,
      duration_minutes: 30,
    });
  });

  it('sends the yoga category the backend expects for that type', async () => {
    renderTab();
    await waitFor(() => expect(screen.getByLabelText('Sets')).toBeDefined());

    fireEvent.click(screen.getByRole('button', { name: 'Yoga' }));
    fireEvent.click(screen.getByRole('button', { name: 'Mindfulness' }));
    fireEvent.click(screen.getByRole('button', { name: 'Save Workout' }));

    await waitFor(() => expect(api.createWorkout).toHaveBeenCalledWith(
      expect.objectContaining({ workout_type: 'yoga', category: 'mindfulness' }),
    ));
  });
});

describe('WorkoutsTab share', () => {
  it('copies the analytics link and confirms inline when there is no share sheet', async () => {
    renderTab();
    await waitFor(() => expect(screen.getByLabelText('Share Yoga workout')).toBeDefined());

    fireEvent.click(screen.getByLabelText('Share Yoga workout'));

    await waitFor(() => expect(navigator.clipboard.writeText).toHaveBeenCalled());
    const [url] = (navigator.clipboard.writeText as ReturnType<typeof vi.fn>).mock.calls[0];
    expect(url).toContain('/app/analytics');
    expect(await screen.findByLabelText('Link copied')).toBeDefined();
  });

  it('still offers the share-to-feed post action', async () => {
    renderTab();
    await waitFor(() => expect(screen.getByLabelText('Post Yoga to feed')).toBeDefined());
    expect(screen.getByLabelText('Share Yoga workout')).toBeDefined();
  });
});