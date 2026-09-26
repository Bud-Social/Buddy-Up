/**
 * Vercel serverless function: POST /api/career
 *
 * Careers-page job applications → Supabase, no backend required. Same-origin
 * from the frontend, so the browser needs no CORS preflight; the origin
 * checks below exist only as a safety net for cross-origin tools/curl.
 *
 * Secrets live in Vercel ENVIRONMENT VARIABLES — plain names, NOT
 * VITE_-prefixed, so they are never inlined into the client bundle:
 *   SUPABASE_URL                 e.g. https://xxxx.supabase.co
 *   SUPABASE_SERVICE_ROLE_KEY    service key (bypasses RLS; server-side only)
 *
 * Writes to Supabase table `career_application`
 * (name, email, role, portfolio_url, resume_url, message,
 * created_at default now(), RLS on, no policies — reachable only through
 * the service-role key). Resumes go to the private `career-resumes`
 * storage bucket; only the storage path is stored on the row.
 */

interface ResumeFile {
  name?: unknown;
  type?: unknown;
  data?: unknown;
}

interface CareerBody {
  name?: unknown;
  email?: unknown;
  role?: unknown;
  portfolio_url?: unknown;
  resume?: unknown;
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
const MAX_ROLE_LEN = 120;
const ALLOWED_RESUME_TYPES = new Set([
  'application/pdf',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
]);
const MAX_RESUME_BYTES = 5 * 1024 * 1024;
const RESUME_BUCKET = 'career-resumes';

function json(res: VercelRes, status: number, body: unknown): void {
  res.statusCode = status;
  res.setHeader('Content-Type', 'application/json');
  res.end(JSON.stringify(body));
}

function fail(res: VercelRes, status: number, message: string): void {
  json(res, status, { success: false, message, data: null, errors: null });
}

function safeParse(raw: string): unknown {
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

function validUrl(value: string): boolean {
  if (!value) return true;
  try {
    const url = new URL(value);
    return url.protocol === 'http:' || url.protocol === 'https:';
  } catch {
    return false;
  }
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
    console.error('career: SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY not configured');
    fail(res, 500, 'Service is not configured. Please try again later.');
    return;
  }

  const body = (typeof req.body === 'string' ? safeParse(req.body) : req.body) as CareerBody | null;
  if (!body) {
    fail(res, 400, 'Invalid request body.');
    return;
  }

  const name = typeof body.name === 'string' ? body.name.trim().slice(0, 80) : '';
  const email = typeof body.email === 'string' ? body.email.trim().toLowerCase() : '';
  const role = typeof body.role === 'string' ? body.role.trim().slice(0, MAX_ROLE_LEN) : '';
  const portfolioUrl = typeof body.portfolio_url === 'string' ? body.portfolio_url.trim().slice(0, 500) : '';
  const message = typeof body.message === 'string' ? body.message.trim().slice(0, 2000) : '';

  if (!name) {
    fail(res, 400, 'Please tell us your name.');
    return;
  }
  if (!EMAIL_RE.test(email) || email.length > 254) {
    fail(res, 400, 'Please enter a valid email address.');
    return;
  }
  if (!role) {
    fail(res, 400, 'Please choose a role.');
    return;
  }
  if (!validUrl(portfolioUrl)) {
    fail(res, 400, 'Portfolio link must be a valid http(s) URL.');
    return;
  }
  if (!message) {
    fail(res, 400, 'Please write a short cover note.');
    return;
  }

  // Optional resume: base64 JSON payload (Vercel request cap is ~4.5MB, so
  // 5MB pre-encoding would already fail — the client pre-checks size).
  let resumeUrl: string | null = null;
  const resume = body.resume as ResumeFile | null | undefined;
  if (resume) {
    const rawName = typeof resume.name === 'string' ? resume.name : '';
    const mime = typeof resume.type === 'string' ? resume.type : '';
    const b64 = typeof resume.data === 'string' ? resume.data : '';
    const cleanName = rawName.replace(/[^a-zA-Z0-9._-]/g, '').slice(-80) || 'resume';
    if (!ALLOWED_RESUME_TYPES.has(mime)) {
      fail(res, 400, 'Resume must be a PDF or Word document.');
      return;
    }
    let bytes: Buffer;
    try {
      bytes = Buffer.from(b64, 'base64');
    } catch {
      fail(res, 400, 'Resume file could not be read.');
      return;
    }
    if (bytes.length === 0 || bytes.length > MAX_RESUME_BYTES) {
      fail(res, 400, 'Resume must be under 5MB.');
      return;
    }
    const objectPath = `${Date.now()}-${Math.random().toString(36).slice(2, 10)}/${cleanName}`;
    try {
      const upRes = await fetch(`${sbUrl}/storage/v1/object/${RESUME_BUCKET}/${objectPath}`, {
        method: 'POST',
        headers: {
          apikey: sbKey,
          Authorization: `Bearer ${sbKey}`,
          'Content-Type': mime,
          'x-upsert': 'false',
        },
        body: new Uint8Array(bytes),
      });
      if (!upRes.ok) {
        console.error('career: resume upload failed', upRes.status, (await upRes.text()).slice(0, 300));
        fail(res, 502, 'Could not save your resume. Please try again in a moment.');
        return;
      }
      resumeUrl = `${RESUME_BUCKET}/${objectPath}`;
    } catch (err) {
      console.error('career: resume upload threw', err);
      fail(res, 502, 'Could not save your resume. Please try again in a moment.');
      return;
    }
  }

  const application = { name, email, role, portfolio_url: portfolioUrl || null, resume_url: resumeUrl, message };

  let saved = false;
  try {
    const sbRes = await fetch(`${sbUrl}/rest/v1/career_application`, {
      method: 'POST',
      headers: {
        apikey: sbKey,
        Authorization: `Bearer ${sbKey}`,
        'Content-Type': 'application/json',
        Prefer: 'return=minimal',
      },
      body: JSON.stringify(application),
    });
    saved = sbRes.ok;
    if (!saved) {
      console.error('career: supabase insert failed', sbRes.status, (await sbRes.text()).slice(0, 300));
    }
  } catch (err) {
    console.error('career: supabase insert threw', err);
  }

  if (!saved) {
    fail(res, 502, 'Could not save your application. Please try again in a moment.');
    return;
  }

  json(res, 200, {
    success: true,
    message: 'Application received — we reply to shortlisted candidates.',
    data: null,
    errors: null,
    pagination: null,
  });
}
