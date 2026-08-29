/**
 * Behavioral event tracking for algorithm refinement.
 *
 * Privacy contract: never pass message bodies, raw search text, GPS
 * coordinates, health values, tokens or emails into `properties`.
 */

const CONSENT_KEY = 'bu_analytics_consent';
const ANON_KEY = 'bu_analytics_anon';
const SESSION_KEY = 'bu_analytics_session';

export function analyticsConsent(): boolean {
  try {
    return localStorage.getItem(CONSENT_KEY) !== 'false';
  } catch {
    return false;
  }
}

export function setAnalyticsConsent(enabled: boolean): void {
  try {
    localStorage.setItem(CONSENT_KEY, enabled ? 'true' : 'false');
  } catch {
    /* storage unavailable — tracking stays session-only */
  }
}

function anonymousId(): string {
  try {
    let id = localStorage.getItem(ANON_KEY);
    if (!id) {
      id = crypto.randomUUID();
      localStorage.setItem(ANON_KEY, id);
    }
    return id;
  } catch {
    return 'anon-unavailable';
  }
}

function sessionId(): string {
  try {
    let id = sessionStorage.getItem(SESSION_KEY);
    if (!id) {
      id = crypto.randomUUID();
      sessionStorage.setItem(SESSION_KEY, id);
    }
    return id;
  } catch {
    return 'session-unavailable';
  }
}

export function platformTag(): string {
  const ua = navigator.userAgent.toLowerCase();
  if (/android/.test(ua)) return 'android-web';
  if (/iphone|ipad|ipod/.test(ua)) return 'ios-web';
  return 'web';
}

interface QueuedEvent {
  event_name: string;
  event_version: number;
  occurred_at: string;
  anonymous_id: string;
  session_id: string;
  platform: string;
  surface?: string;
  object_type?: string;
  object_id?: string;
  properties?: Record<string, unknown>;
  consent: { analytics: boolean };
  schema_version: number;
}

const queue: QueuedEvent[] = [];
let flushTimer: ReturnType<typeof setTimeout> | null = null;

function flush(): void {
  if (queue.length === 0) return;
  const events = queue.splice(0, queue.length);
  const base = import.meta.env.VITE_API_BASE_URL || '/api/v1';
  try {
    void fetch(`${base}/analytics/events/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ events }),
      keepalive: true,
    }).catch(() => {});
  } catch {
    /* tracking must never break the app */
  }
}

function scheduleFlush(): void {
  if (queue.length >= 10) {
    flush();
    return;
  }
  if (flushTimer) return;
  flushTimer = setTimeout(() => {
    flushTimer = null;
    flush();
  }, 5000);
}

if (typeof window !== 'undefined') {
  window.addEventListener('pagehide', flush);
}

/** Track a behavioral event (fire-and-forget, consent-gated). */
export function track(
  eventName: string,
  props: {
    surface?: string;
    object_type?: string;
    object_id?: string;
    properties?: Record<string, unknown>;
  } = {},
): void {
  if (!analyticsConsent()) return;
  try {
    queue.push({
      event_name: eventName,
      event_version: 1,
      occurred_at: new Date().toISOString(),
      anonymous_id: anonymousId(),
      session_id: sessionId(),
      platform: platformTag(),
      surface: props.surface,
      object_type: props.object_type,
      object_id: props.object_id,
      properties: props.properties,
      consent: { analytics: true },
      schema_version: 1,
    });
    scheduleFlush();
  } catch {
    /* never break the calling UI */
  }
}
