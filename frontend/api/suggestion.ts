/**
 * Vercel serverless function: POST /api/suggestion
 *
 * Feature-suggestion form → Supabase, no backend required. Same-origin
 * from the frontend, so the browser needs no CORS preflight; the origin
 * checks below exist only as a safety net for cross-origin tools/curl.
 *
 * Secrets live in Vercel ENVIRONMENT VARIABLES — plain names, NOT
 * VITE_-prefixed, so they are never inlined into the client bundle:
 *   SUPABASE_URL                 e.g. https://xxxx.supabase.co
 *   SUPABASE_SERVICE_ROLE_KEY    service key (bypasses RLS; server-side only)
 *
 * Writes to Supabase table `feature_suggestion`
 * (title, description, category, email, name, status default 'new',
 * created_at default now(), RLS on, no policies — reachable only through
 * the service-role key).
 */

interface SuggestionBody {
  title?: unknown;
  description?: unknown;
  category?: unknown;
  email?: unknown;
  name?: unknown;
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
const ALLOWED_CATEGORIES = new Set([
  'gyms', 'trainers', 'events', 'programmes', 'analytics', 'app', 'other',
]);

function json(res: VercelRes, status: number, body: unknown): void {
  res.statusCode = status;
  res.setHeader('Content-Type', 'application/json');
  res.end(JSON.stringify(body));
}

function fail(res: VercelRes, status: number, message: string): void {
  json(res, status, { success: false, message, data: null, errors: null });
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
    console.error('suggestion: SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY not configured');
    fail(res, 500, 'Service is not configured. Please try again later.');
    return;
  }

  const body = (typeof req.body === 'string' ? safeParse(req.body) : req.body) as SuggestionBody | null;
  if (!body) {
    fail(res, 400, 'Invalid request body.');
    return;
  }

  const title = typeof body.title === 'string' ? body.title.trim().slice(0, 120) : '';
  const description = typeof body.description === 'string' ? body.description.trim().slice(0, 2000) : '';
  const category = typeof body.category === 'string' && ALLOWED_CATEGORIES.has(body.category)
    ? body.category
    : 'other';
  const email = typeof body.email === 'string' ? body.email.trim().toLowerCase() : '';
  const name = typeof body.name === 'string' ? body.name.trim().slice(0, 80) : '';

  if (!title) {
    fail(res, 400, 'Please give your suggestion a title.');
    return;
  }
  if (!description) {
    fail(res, 400, 'Please tell us a bit more about the feature.');
    return;
  }
  if (email && (!EMAIL_RE.test(email) || email.length > 254)) {
    fail(res, 400, 'Please enter a valid email address (or leave it empty).');
    return;
  }

  const suggestion = {
    title,
    description,
    category,
    email: email || null,
    name: name || null,
    status: 'new',
  };

  let saved = false;
  try {
    const sbRes = await fetch(`${sbUrl}/rest/v1/feature_suggestion`, {
      method: 'POST',
      headers: {
        apikey: sbKey,
        Authorization: `Bearer ${sbKey}`,
        'Content-Type': 'application/json',
        Prefer: 'return=minimal',
      },
      body: JSON.stringify(suggestion),
    });
    saved = sbRes.ok;
    if (!saved) {
      console.error('suggestion: supabase insert failed', sbRes.status, (await sbRes.text()).slice(0, 300));
    }
  } catch (err) {
    console.error('suggestion: supabase insert threw', err);
  }

  if (!saved) {
    fail(res, 502, 'Could not save your suggestion. Please try again in a moment.');
    return;
  }

  json(res, 200, {
    success: true,
    message: 'Thanks — your suggestion is in.',
    data: suggestion,
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
