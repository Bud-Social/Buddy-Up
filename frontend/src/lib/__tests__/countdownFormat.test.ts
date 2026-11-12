import { describe, it, expect } from 'vitest';
import {
  checkInState, countdownHeadline, formatDuration, progressPct, signalLabel, typeTag,
} from '../countdownFormat';
import type { CountdownSignal, UserCountdown } from '@/types/countdowns';

function makeCountdown(overrides: Partial<UserCountdown> = {}): UserCountdown {
  return {
    id: 'cd-1',
    template: 'tpl-1',
    template_detail: null,
    custom_reason: '',
    countdown_type: 'manual',
    unit: 'days',
    current_count: 0,
    target_count: 0,
    start_date: '2026-01-01',
    last_checkin_at: null,
    last_auto_advance_at: null,
    auto_advance_signal: null,
    is_active: true,
    completed_at: null,
    days_since_start: 0,
    display_reason: 'Sobriety',
    display_icon: '🍻',
    created_at: '2026-01-01T00:00:00Z',
    updated_at: '2026-01-01T00:00:00Z',
    elapsed_units: 0,
    run_started_at: null,
    run_elapsed_seconds: 0,
    next_checkin_at: null,
    last_reset_at: null,
    ...overrides,
  } as UserCountdown;
}

const SIGNALS: CountdownSignal[] = [
  { key: 'activity_walk', label: 'A logged walk', unit: 'days' },
  { key: 'gym_checkin', label: 'A gym check-in', unit: 'days' },
];

describe('formatDuration', () => {
  it('formats days and hours', () => {
    expect(formatDuration(86400 * 2 + 3600 * 3)).toBe('2d 3h');
  });

  it('formats hours and minutes', () => {
    expect(formatDuration(3600 * 2 + 60 * 12)).toBe('2h 12m');
  });

  it('formats minutes alone', () => {
    expect(formatDuration(600)).toBe('10m');
  });

  it('never goes negative', () => {
    expect(formatDuration(-5)).toBe('0s');
  });
});

describe('checkInState', () => {
  const now = new Date('2026-06-01T12:00:00Z');

  it('is open when the countdown has never been checked in', () => {
    const state = checkInState(makeCountdown(), now);
    expect(state.locked).toBe(false);
    expect(state.label).toBe('Check in');
  });

  it('is locked until the next check-in opens', () => {
    const state = checkInState(
      makeCountdown({ next_checkin_at: '2026-06-01T14:30:00Z' }),
      now,
    );
    expect(state.locked).toBe(true);
    expect(state.label).toBe('Opens in 2h 30m');
  });

  it('is open once the unlock time has passed', () => {
    const state = checkInState(
      makeCountdown({ next_checkin_at: '2026-06-01T11:00:00Z' }),
      now,
    );
    expect(state.locked).toBe(false);
  });

  it('is not offered on an automatic countdown', () => {
    const state = checkInState(makeCountdown({ countdown_type: 'automatic' }), now);
    expect(state.locked).toBe(true);
    expect(state.label).toBe('Automatic');
  });
});

describe('countdownHeadline', () => {
  it('leads with the counter the user completed', () => {
    const head = countdownHeadline(makeCountdown({ current_count: 7, elapsed_units: 9 }));
    expect(head.value).toBe(7);
    expect(head.unit).toBe('days');
  });

  it('carries the streak length separately', () => {
    const head = countdownHeadline(makeCountdown({ current_count: 7, elapsed_units: 9 }));
    expect(head.streakUnits).toBe(9);
  });

  it('falls back to the counter when there is no elapsed figure', () => {
    const head = countdownHeadline(makeCountdown({ current_count: 4, elapsed_units: 0 }));
    expect(head.streakUnits).toBe(0);
  });
});

describe('signalLabel', () => {
  it('uses the label the API gave', () => {
    expect(signalLabel(SIGNALS, 'activity_walk')).toBe('A logged walk');
  });

  it('falls back to a readable form when the signal is unknown', () => {
    expect(signalLabel([], 'gym_checkin')).toBe('Gym Checkin');
  });

  it('handles a missing signal', () => {
    expect(signalLabel(SIGNALS, null)).toBe('Automatic');
  });
});

describe('typeTag', () => {
  it('names the signal on an automatic countdown', () => {
    const tag = typeTag(
      makeCountdown({ countdown_type: 'automatic', auto_advance_signal: 'activity_walk' }),
      SIGNALS,
    );
    expect(tag.text).toBe('Auto · A logged walk');
  });

  it('says Manual on a manual countdown', () => {
    const tag = typeTag(makeCountdown(), SIGNALS);
    expect(tag.text).toBe('Manual');
  });
});

describe('progressPct', () => {
  it('measures against the target when there is one', () => {
    expect(progressPct(makeCountdown({ current_count: 15, target_count: 30 }))).toBe(50);
  });

  it('never exceeds 100', () => {
    expect(progressPct(makeCountdown({ current_count: 40, target_count: 30 }))).toBe(100);
  });

  it('measures against a window when there is no target', () => {
    expect(progressPct(makeCountdown({ current_count: 15, target_count: 0 }))).toBe(50);
  });
});
