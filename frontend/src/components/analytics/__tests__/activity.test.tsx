import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, act } from '@testing-library/react';
import { RouteReplayMap } from '@/components/analytics/RouteReplayMap';
import { ActivityTab } from '@/components/analytics/ActivityTab';
import { analyticsApi } from '@/api/analytics';

vi.mock('@/api/analytics', () => ({
  analyticsApi: {
    getActivities: vi.fn(),
    createActivity: vi.fn(),
    deleteActivity: vi.fn(),
  },
}));

const mockGet = analyticsApi.getActivities as unknown as ReturnType<typeof vi.fn>;
const mockCreate = analyticsApi.createActivity as unknown as ReturnType<typeof vi.fn>;
const mockDelete = analyticsApi.deleteActivity as unknown as ReturnType<typeof vi.fn>;

const ROUTE = [
  [36.8219, -1.2921, 1000],
  [36.8229, -1.2931, 2000],
  [36.8239, -1.2941, 3000],
];

beforeEach(() => {
  vi.clearAllMocks();
  mockGet.mockResolvedValue({ data: [] });
});

describe('RouteReplayMap', () => {
  it('plays, scrubs, and changes speed', async () => {
    render(<RouteReplayMap route={ROUTE} durationSeconds={120} />);
    expect(screen.getByLabelText('Play replay')).toBeDefined();
    expect(screen.getByText('1×')).toBeDefined();

    fireEvent.click(screen.getByLabelText('Play replay'));
    expect(screen.getByLabelText('Pause replay')).toBeDefined();

    fireEvent.click(screen.getByText('2×'));
    const slider = screen.getByLabelText('Replay position') as HTMLInputElement;
    fireEvent.change(slider, { target: { value: '500' } });
    expect(slider.value).toBe('500');
  });

  it('renders nothing for routes with fewer than two points', () => {
    const { container } = render(<RouteReplayMap route={[[1, 2, 3]]} durationSeconds={60} />);
    expect(container.textContent).toBe('');
  });
});

describe('ActivityTab auto-save', () => {
  beforeEach(() => {
    Object.defineProperty(window.navigator, 'geolocation', {
      value: { watchPosition: vi.fn(() => 7), clearWatch: vi.fn() },
      configurable: true,
    });
  });

  it('saves automatically on stop and offers undo', async () => {
    vi.useFakeTimers();
    try {
      mockCreate.mockResolvedValue({ data: { id: 'abc-123' } });
      mockGet.mockResolvedValue({ data: [] });

      render(<ActivityTab />);
      fireEvent.click(screen.getByRole('button', { name: 'Start' }));
      await act(async () => { vi.advanceTimersByTime(3100); });

      // Feed three GPS fixes through the captured watcher.
      const geo = window.navigator.geolocation as unknown as {
        watchPosition: { mock: { calls: unknown[][] } };
      };
      const cb = geo.watchPosition.mock.calls[0][0] as PositionCallback;
      const fix = (lat: number, lng: number) =>
        cb({ coords: { latitude: lat, longitude: lng, accuracy: 5 } } as GeolocationPosition);
      await act(async () => {
        fix(-1.2921, 36.8219);
        fix(-1.2931, 36.8229);
        fix(-1.2941, 36.8239);
      });

      await act(async () => {
        fireEvent.click(screen.getByRole('button', { name: /Stop & Save/ }));
      });
      expect(mockCreate).toHaveBeenCalledWith(
        expect.objectContaining({
          activity_type: 'run',
          route: expect.arrayContaining([
            expect.arrayContaining([-1.2921, 36.8219]),
          ]),
        }),
      );
      expect(screen.getByText('Undo')).toBeDefined();

      mockDelete.mockResolvedValue({ data: null });
      fireEvent.click(screen.getByText('Undo'));
      await act(async () => { vi.advanceTimersByTime(0); });
      expect(mockDelete).toHaveBeenCalledWith('abc-123');
    } finally {
      vi.useRealTimers();
    }
  });
});
