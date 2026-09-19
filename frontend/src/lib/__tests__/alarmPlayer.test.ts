import { describe, it, expect, vi, afterEach } from 'vitest';
import { MAX_SOUND_MS, scheduleAlarm, stopAllAlarms } from '@/lib/alarmPlayer';
import { DAY_LABELS, formatDays, maskToDays, nextFireDate, toggleDayBit } from '@/pages/settings/AlarmCenter';

afterEach(() => {
  vi.useRealTimers();
});

describe('alarmPlayer', () => {
  it('caps sounds at 30s', () => {
    expect(MAX_SOUND_MS).toBe(30000);
  });

  it('stopAllAlarms is safe with nothing playing', () => {
    expect(() => stopAllAlarms()).not.toThrow();
  });

  it('scheduleAlarm fires a past date on the next tick', () => {
    vi.useFakeTimers();
    const onFire = vi.fn();
    scheduleAlarm(new Date(Date.now() - 1000), onFire);
    expect(onFire).not.toHaveBeenCalled();
    vi.runAllTimers();
    expect(onFire).toHaveBeenCalledTimes(1);
  });

  it('scheduleAlarm fires a future date after the delay', () => {
    vi.useFakeTimers();
    const onFire = vi.fn();
    scheduleAlarm(new Date(Date.now() + 60_000), onFire);
    vi.advanceTimersByTime(59_999);
    expect(onFire).not.toHaveBeenCalled();
    vi.advanceTimersByTime(1);
    vi.runAllTimers(); // flush the 0ms fire tick
    expect(onFire).toHaveBeenCalledTimes(1);
  });

  it('scheduleAlarm cancel prevents firing', () => {
    vi.useFakeTimers();
    const onFire = vi.fn();
    const cancel = scheduleAlarm(new Date(Date.now() + 1000), onFire);
    cancel();
    vi.runAllTimers();
    expect(onFire).not.toHaveBeenCalled();
  });
});

describe('day-mask helpers', () => {
  it('has Mon..Sun labels', () => {
    expect(DAY_LABELS).toEqual(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);
  });

  it('maskToDays expands Mon=1..Sun=64', () => {
    expect(maskToDays(1)).toEqual([true, false, false, false, false, false, false]);
    expect(maskToDays(64)).toEqual([false, false, false, false, false, false, true]);
    expect(maskToDays(127)).toEqual([true, true, true, true, true, true, true]);
    expect(maskToDays(0)).toEqual([false, false, false, false, false, false, false]);
  });

  it('toggleDayBit flips a single bit', () => {
    expect(toggleDayBit(0, 0)).toBe(1);
    expect(toggleDayBit(1, 0)).toBe(0);
    expect(toggleDayBit(0, 6)).toBe(64);
    expect(toggleDayBit(127, 6)).toBe(63);
  });

  it('formatDays summarizes common masks', () => {
    expect(formatDays(0)).toBe('Once');
    expect(formatDays(127)).toBe('Every day');
    expect(formatDays(31)).toBe('Weekdays');
    expect(formatDays(96)).toBe('Weekends');
    expect(formatDays(1 | 8)).toBe('Mon, Thu');
  });

  it('nextFireDate picks the next matching weekday', () => {
    // Monday 2026-01-05 06:00 local
    const monday = new Date(2026, 0, 5, 6, 0, 0, 0);
    // Tuesdays only (bit 1) at 07:00 -> next day
    const tue = nextFireDate('07:00', 2, monday);
    expect(tue).not.toBeNull();
    expect(tue!.getDay()).toBe(2);
    expect(tue!.getHours()).toBe(7);
    // Same-day later time fires today
    const today = nextFireDate('08:30', 1, monday);
    expect(today!.getDate()).toBe(5);
    // Same-day earlier time rolls to next Monday
    const nextWeek = nextFireDate('05:00', 1, monday);
    expect(nextWeek!.getDate()).toBe(12);
    // Mask 0 = next occurrence regardless of weekday
    const once = nextFireDate('05:00', 0, monday);
    expect(once!.getDate()).toBe(6);
    // Garbage time returns null
    expect(nextFireDate('nope', 127, monday)).toBeNull();
  });
});
