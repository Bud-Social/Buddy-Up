/** Curated list of common IANA timezones for Settings → Notifications. */
export const COMMON_TIMEZONES = [
  'Africa/Nairobi',
  'Africa/Lagos',
  'Africa/Cairo',
  'Africa/Johannesburg',
  'Europe/London',
  'Europe/Paris',
  'Europe/Berlin',
  'Europe/Istanbul',
  'Europe/Moscow',
  'Asia/Dubai',
  'Asia/Karachi',
  'Asia/Kolkata',
  'Asia/Dhaka',
  'Asia/Bangkok',
  'Asia/Singapore',
  'Asia/Shanghai',
  'Asia/Tokyo',
  'Asia/Seoul',
  'Australia/Sydney',
  'Pacific/Auckland',
  'America/New_York',
  'America/Chicago',
  'America/Denver',
  'America/Los_Angeles',
  'America/Phoenix',
  'America/Sao_Paulo',
  'America/Toronto',
  'UTC',
] as const;

/** Best-effort device timezone; falls back to UTC when unavailable. */
export function getDeviceTimezone(): string {
  try {
    return Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC';
  } catch {
    return 'UTC';
  }
}

/** Timezone options for the select: the detected device zone first (labelled),
 * then the curated list. Pure given a fixed deviceZone. */
export function buildTimezoneOptions(deviceZone: string): Array<{ value: string; label: string }> {
  const seen = new Set<string>();
  const options: Array<{ value: string; label: string }> = [];
  const push = (zone: string, label: string) => {
    if (!zone || seen.has(zone)) return;
    seen.add(zone);
    options.push({ value: zone, label });
  };
  push(deviceZone, `${deviceZone.replaceAll('_', ' ')} (device)`);
  for (const zone of COMMON_TIMEZONES) {
    push(zone, zone.replaceAll('_', ' '));
  }
  return options;
}
