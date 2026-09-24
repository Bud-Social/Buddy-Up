/**
 * Vercel serverless function: POST /api/contact
 *
 * Landing-page contact form → Supabase, no backend required. Same-origin
 * from the frontend, so the browser needs no CORS preflight; the origin
 * checks below exist only as a safety net for cross-origin tools/curl.
 *
 * Secrets live in Vercel ENVIRONMENT VARIABLES — plain names, NOT
 * VITE_-prefixed, so they are never inlined into the client bundle:
 *   SUPABASE_URL                 e.g. https://xxxx.supabase.co
 *   SUPABASE_SERVICE_ROLE_KEY    service key (bypasses RLS; server-side only)
 *
 * Writes to Supabase table `contact_inquiry`
 * (name, email, topic, subject, message, created_at default now(), RLS on,
 * no policies — reachable only through the service-role key).
 */

interface ContactBody {
  name?: unknown;
  email?: unknown;
  topic?: unknown;
  subject?: unknown;
  message?: unknown;
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
const ALLOWED_TOPICS = new Set(['general', 'support', 'gyms', 'trainers', 'press']);

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
    console.error('contact: SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY not configured');
    fail(res, 500, 'Service is not configured. Please try again later.');
    return;
  }

  const body = (typeof req.body === 'string' ? safeParse(req.body) : req.body) as ContactBody | null;
  if (!body) {
    fail(res, 400, 'Invalid request body.');
    return;
  }

  const name = typeof body.name === 'string' ? body.name.trim().slice(0, 80) : '';
  const email = typeof body.email === 'string' ? body.email.trim().toLowerCase() : '';
  const topic = typeof body.topic === 'string' && ALLOWED_TOPICS.has(body.topic) ? body.topic : 'general';
  const subject = typeof body.subject === 'string' ? body.subject.trim().slice(0, 120) : '';
  const message = typeof body.message === 'string' ? body.message.trim().slice(0, 2000) : '';

  if (!name) {
    fail(res, 400, 'Please tell us your name.');
    return;
  }
  if (!EMAIL_RE.test(email) || email.length > 254) {
    fail(res, 400, 'Please enter a valid email address.');
    return;
  }
  if (!message) {
    fail(res, 400, 'Please write a short message.');
    return;
  }

  const inquiry = { name, email, topic, subject: subject || null, message };

  let saved = false;
  try {
    const sbRes = await fetch(`${sbUrl}/rest/v1/contact_inquiry`, {
      method: 'POST',
      headers: {
        apikey: sbKey,
        Authorization: `Bearer ${sbKey}`,
        'Content-Type': 'application/json',
        Prefer: 'return=minimal',
      },
      body: JSON.stringify(inquiry),
    });
    saved = sbRes.ok;
    if (!saved) {
      console.error('contact: supabase insert failed', sbRes.status, (await sbRes.text()).slice(0, 300));
    }
  } catch (err) {
    console.error('contact: supabase insert threw', err);
  }

  if (!saved) {
    fail(res, 502, 'Could not send your message. Please try again in a moment.');
    return;
  }

  json(res, 200, {
    success: true,
    message: 'Message received — we reply within two business days.',
    data: inquiry,
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
