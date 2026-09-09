import { describe, it, expect } from 'vitest';
import { COMMON_TIMEZONES, buildTimezoneOptions, getDeviceTimezone } from '@/lib/timezones';

describe('timezones', () => {
  it('curated list includes Africa/Nairobi', () => {
    expect(COMMON_TIMEZONES).toContain('Africa/Nairobi');
  });

  it('puts the device zone first with a "(device)" label and no duplicate', () => {
    const options = buildTimezoneOptions('Africa/Nairobi');
    expect(options[0]).toEqual({ value: 'Africa/Nairobi', label: 'Africa/Nairobi (device)' });
    expect(options.filter((o) => o.value === 'Africa/Nairobi')).toHaveLength(1);
  });

  it('adds an unknown device zone and still lists all curated zones', () => {
    const options = buildTimezoneOptions('Mars/Olympus');
    expect(options[0]).toEqual({ value: 'Mars/Olympus', label: 'Mars/Olympus (device)' });
    expect(options.slice(1).map((o) => o.value)).toEqual([...COMMON_TIMEZONES]);
  });

  it('getDeviceTimezone returns a non-empty string', () => {
    expect(getDeviceTimezone().length).toBeGreaterThan(0);
  });
});
