import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, act } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import WorkoutForm from '@/pages/app/WorkoutForm';
import { analyticsApi } from '@/api/analytics';

vi.mock('@/api/analytics', () => ({
  analyticsApi: {
    getWorkoutTypes: vi.fn(),
    createWorkout: vi.fn(),
  },
}));

vi.mock('@/lib/alarmPlayer', () => ({
  playAlarmSound: vi.fn(() => vi.fn()),
  stopAllAlarms: vi.fn(),
}));

const api = analyticsApi as unknown as Record<string, ReturnType<typeof vi.fn>>;

const createWrapper = () => ({ children }: { children: React.ReactNode }) => (
  <MemoryRouter>{children}</MemoryRouter>
);

beforeEach(() => {
  vi.clearAllMocks();
  // The catalogue fetch fails so the local fallback drives the UI.
  api.getWorkoutTypes.mockRejectedValue(new Error('offline'));
  api.createWorkout.mockResolvedValue({ data: {} });
});

describe('WorkoutForm', () => {
  it('renders exercise selector buttons', () => {
    render(<WorkoutForm />, { wrapper: createWrapper() });
    expect(screen.getByText(/Auto Detect/i)).toBeDefined();
    expect(screen.getByText(/Squat/i)).toBeDefined();
    expect(screen.getByText(/Deadlift/i)).toBeDefined();
  });

  it('shows camera and upload buttons', () => {
    render(<WorkoutForm />, { wrapper: createWrapper() });
    expect(screen.getByRole('button', { name: 'Camera' })).toBeDefined();
    expect(screen.getByRole('button', { name: /Upload/i })).toBeDefined();
  });
});

describe('WorkoutForm — start workout without typing', () => {
  it('offers a camera and a timer-only entry with no text inputs required', () => {
    render(<WorkoutForm />, { wrapper: createWrapper() });
    expect(screen.getByRole('button', { name: 'Start workout with camera' })).toBeDefined();
    expect(screen.getByRole('button', { name: /Timer only/i })).toBeDefined();
    expect(screen.queryByRole('textbox')).toBeNull();
  });

  it('starts the countdown straight from the chosen type, category and duration', async () => {
    vi.useFakeTimers({ shouldAdvanceTime: true });
    try {
      render(<WorkoutForm />, { wrapper: createWrapper() });

      fireEvent.click(screen.getByRole('button', { name: 'Yoga' }));
      fireEvent.click(screen.getByRole('button', { name: 'Balance' }));
      fireEvent.click(screen.getByRole('button', { name: '15 min' }));
      fireEvent.click(screen.getByRole('button', { name: /Timer only/i }));

      await act(async () => { vi.advanceTimersByTime(16 * 60 * 1000); });

      // Alarm fired — the finish panel is up.
      expect(screen.getByText(/Time! Nice work/)).toBeDefined();

      await act(async () => { fireEvent.click(screen.getByRole('button', { name: /Log 15 min workout/ })); });

      expect(api.createWorkout).toHaveBeenCalledWith({
        workout_type: 'yoga',
        category: 'balance',
        duration_minutes: 15,
      });
    } finally {
      vi.useRealTimers();
    }
  });

  it('sends an empty category for a type that has none', async () => {
    vi.useFakeTimers({ shouldAdvanceTime: true });
    try {
      render(<WorkoutForm />, { wrapper: createWrapper() });

      fireEvent.click(screen.getByRole('button', { name: 'Running' }));
      fireEvent.click(screen.getByRole('button', { name: '30 min' }));
      fireEvent.click(screen.getByRole('button', { name: /Timer only/i }));

      await act(async () => { vi.advanceTimersByTime(31 * 60 * 1000); });
      await act(async () => { fireEvent.click(screen.getByRole('button', { name: /Log 30 min workout/ })); });

      expect(api.createWorkout).toHaveBeenCalledWith({
        workout_type: 'running',
        category: '',
        duration_minutes: 30,
      });
    } finally {
      vi.useRealTimers();
    }
  });

  it('clears a category that the newly picked type does not allow', () => {
    render(<WorkoutForm />, { wrapper: createWrapper() });
    fireEvent.click(screen.getByRole('button', { name: 'Yoga' }));
    fireEvent.click(screen.getByRole('button', { name: 'Balance' }));
    fireEvent.click(screen.getByRole('button', { name: 'Running' }));
    // Running has no categories, so the picker is gone entirely.
    expect(screen.queryByRole('button', { name: 'Balance' })).toBeNull();
  });
});