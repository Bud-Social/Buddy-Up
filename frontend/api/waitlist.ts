/**
 * Vercel serverless function: POST /api/waitlist
 *
 * Replaces the Django waitlist endpoint pre-launch. Same-origin from the
 * frontend, so the browser needs no CORS preflight; the origin checks below
 * exist only as a safety net for cross-origin tools/curl.
 *
 * Secrets (Supabase service key, Google Sheets webhook URLs, mirror key)
 * live in Vercel ENVIRONMENT VARIABLES — plain names, NOT VITE_-prefixed,
 * so they are never inlined into the client bundle. Required:
 *   SUPABASE_URL                 e.g. https://xxxx.supabase.co
 *   SUPABASE_SERVICE_ROLE_KEY    service key (bypasses RLS; server-side only)
 *   GOOGLE_SHEETS_WEBHOOK_URL    optional — users-sheet Apps Script exec URL
 *   CONS_ALL_SHEETS              optional — consolidated-sheet exec URL
 *                                (non-user interests; falls back to the
 *                                users webhook when unset)
 *   SHEETS_MIRROR_KEY            optional — secret sent only to the
 *                                consolidated webhook
 *
 * Writes to Supabase table `waitlist_entry`
 * (email PK, name, country, source, interest, details, created_at default
 * now(), RLS on, no policies). Required Supabase columns beyond the original
 * four: `interest text default 'user'`, `details jsonb default '{}'`.
 */

interface WaitlistBody {
  email?: unknown;
  name?: unknown;
  country?: unknown;
  source?: unknown;
  interest?: unknown;
  metadata?: unknown;
}

type VercelReq = {
  method?: string;
  headers: Record<string, string | string[] | undefined>;
  body?: unknown;
};

type VercelRes = {
  statusCode: number;
  setHeader(key: string, value: string): void;
  end(data?: string): void;
};

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;
const ALLOWED_ORIGINS = new Set([
  'https://buddyupfit.com',
  'https://www.buddyupfit.com',
  'https://buddyupfit.co.ke',
  'https://www.buddyupfit.co.ke',
]);
const MIRROR_TIMEOUT_MS = 4000;

function json(res: VercelRes, status: number, body: unknown): void {
  res.statusCode = status;
  res.setHeader('Content-Type', 'application/json');
  res.end(JSON.stringify(body));
}

function fail(res: VercelRes, status: number, message: string): void {
  json(res, status, { success: false, message, data: null, errors: null });
}

/** Race the fire-and-forget sheet mirror against a hard timeout so a hung
 * webhook can never delay the signup response (same policy as the Django
 * version's daemon thread). Failures are swallowed by design.
 *
 * Dual-sheet routing (mirrors backend/apps/waitlist/sheets.py):
 * - `user` interest → users sheet (GOOGLE_SHEETS_WEBHOOK_URL, no key).
 * - every other interest → consolidated sheet (CONS_ALL_SHEETS),
 *   authenticated with SHEETS_MIRROR_KEY. Falls back to the users sheet
 *   when CONS_ALL_SHEETS is unset so a lead is never silently dropped. */
const CONSOLIDATED_INTERESTS = new Set([
  'gym', 'trainer', 'corporate', 'organiser', 'supplier',
  'distributor', 'partnership', 'investor',
]);

async function mirrorToSheets(entry: { email: string; name: string; country: string; source: string; interest: string; details: string }): Promise<void> {
  const usersUrl = (process.env.GOOGLE_SHEETS_WEBHOOK_URL || '').trim();
  const consUrl = (process.env.CONS_ALL_SHEETS || '').trim();
  const consKey = (process.env.SHEETS_MIRROR_KEY || '').trim();
  let url = usersUrl;
  let key = '';
  if (CONSOLIDATED_INTERESTS.has(entry.interest) && consUrl) {
    url = consUrl;
    key = consKey;
  }
  if (!url) return;
  const params: Record<string, string> = {
    email: entry.email,
    name: entry.name,
    country: entry.country,
    source: entry.source,
    interest: entry.interest,
    details: entry.details,
  };
  if (key) params.key = key;
  await Promise.race([
    fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams(params),
    }).catch(() => undefined),
    new Promise((resolve) => setTimeout(resolve, MIRROR_TIMEOUT_MS)),
  ]);
}

export default async function handler(req: VercelReq, res: VercelRes): Promise<void> {
  const origin = Array.isArray(req.headers.origin) ? req.headers.origin[0] : req.headers.origin;
  if (origin && ALLOWED_ORIGINS.has(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Vary', 'Origin');
  }

  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    res.statusCode = 204;
    res.end();
    return;
  }

  if (req.method !== 'POST') {
    fail(res, 405, 'Method not allowed');
    return;
  }

  const sbUrl = (process.env.SUPABASE_URL || '').trim().replace(/\/+$/, '');
  const sbKey = (process.env.SUPABASE_SERVICE_ROLE_KEY || '').trim();
  if (!sbUrl || !sbKey) {
    console.error('waitlist: SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY not configured');
    fail(res, 500, 'Service is not configured. Please try again later.');
    return;
  }

  const body = (typeof req.body === 'string' ? safeParse(req.body) : req.body) as WaitlistBody | null;
  if (!body) {
    fail(res, 400, 'Invalid request body.');
    return;
  }

  const email = typeof body.email === 'string' ? body.email.trim().toLowerCase() : '';
  const name = typeof body.name === 'string' ? body.name.trim().slice(0, 80) : '';
  const country = typeof body.country === 'string' ? body.country.trim().slice(0, 56) : '';
  const source = typeof body.source === 'string' && body.source.trim() ? body.source.trim().slice(0, 40) : 'landing';
  const ALLOWED_INTERESTS = new Set(['gym', 'trainer', 'corporate', 'organiser', 'supplier', 'distributor']);
  const interest = typeof body.interest === 'string' && ALLOWED_INTERESTS.has(body.interest) ? body.interest : 'user';
  // Free-form lead details, size-capped; required keys per interest so gym
  // and trainer signups carry analysable intent, not just an email.
  const metadata = body.metadata && typeof body.metadata === 'object' && !Array.isArray(body.metadata)
    ? body.metadata as Record<string, unknown>
    : {};
  const details = JSON.stringify(metadata).slice(0, 4000);

  if (!EMAIL_RE.test(email) || email.length > 254) {
    fail(res, 400, 'Please enter a valid email address.');
    return;
  }
  if (!country) {
    fail(res, 400, 'Please select your country.');
    return;
  }
  if (interest === 'gym') {
    const gymName = typeof metadata.gym_name === 'string' ? metadata.gym_name.trim() : '';
    const city = typeof metadata.city === 'string' ? metadata.city.trim() : '';
    if (!gymName || !city) {
      fail(res, 400, 'Please tell us your gym name and city.');
      return;
    }
  }
  if (interest === 'trainer') {
    const city = typeof metadata.city === 'string' ? metadata.city.trim() : '';
    if (!city) {
      fail(res, 400, 'Please tell us your city.');
      return;
    }
  }
  if (interest === 'corporate') {
    const company = typeof metadata.company_name === 'string' ? metadata.company_name.trim() : '';
    const city = typeof metadata.city === 'string' ? metadata.city.trim() : '';
    if (!company || !city) {
      fail(res, 400, 'Please tell us your company name and city.');
      return;
    }
  }
  if (interest === 'organiser' || interest === 'supplier' || interest === 'distributor') {
    const who = interest === 'organiser'
      ? (typeof metadata.brand === 'string' ? metadata.brand.trim() : '')
      : (typeof metadata.business === 'string' ? metadata.business.trim() : '');
    const city = typeof metadata.city === 'string' ? metadata.city.trim() : '';
    if (!who || !city) {
      fail(res, 400, 'Please tell us your business name and city.');
      return;
    }
  }

  const entry = { email, name, country, source, interest, details };

  // Upsert on the email primary key: re-joining never duplicates or errors.
  // Staged insert: some deployments predate the interest/details columns, so
  // fall back to slimmer payloads instead of failing the signup. The Sheets
  // mirror always carries the full payload regardless of stage.
  const headers = {
    apikey: sbKey,
    Authorization: `Bearer ${sbKey}`,
    'Content-Type': 'application/json',
    Prefer: 'resolution=merge-duplicates,return=minimal',
  };
  const stages: { label: string; body: unknown }[] = [
    { label: 'full', body: entry },
    { label: 'no-details', body: { email, name, country, source, interest } },
    { label: 'legacy', body: { email, name, country, source } },
  ];
  let saved = false;
  try {
    for (const stage of stages) {
      const sbRes = await fetch(`${sbUrl}/rest/v1/waitlist_entry?on_conflict=email`, {
        method: 'POST',
        headers,
        body: JSON.stringify(stage.body),
      });
      saved = sbRes.ok;
      if (saved) {
        if (stage.label !== 'full') {
          console.error(`waitlist: supabase saved at fallback stage=${stage.label} interest=${interest}`);
        }
        break;
      }
      console.error(`waitlist: supabase stage=${stage.label} failed`, sbRes.status, (await sbRes.text()).slice(0, 300));
    }
  } catch (err) {
    console.error('waitlist: supabase insert threw', err);
  }

  if (!saved) {
    fail(res, 502, 'Could not save your signup. Please try again in a moment.');
    return;
  }

  await mirrorToSheets(entry);

  json(res, 200, {
    success: true,
    message: "You're on the list. We'll email you when it's your turn.",
    data: entry,
    errors: null,
    pagination: null,
  });
}

function safeParse(raw: string): unknown {
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
}