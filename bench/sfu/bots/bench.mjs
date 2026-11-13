// SFU benchmark bot: one synthetic publisher, N silent subscribers.
// Usage: node bench.mjs --stack <livekit|jitsi|mediasoup|janus|pion> --viewers 10 [--duration 30] [--runs 3]
import { chromium } from '@playwright/test';
import { createServer } from 'http';
import { readFile, writeFile, mkdir } from 'fs/promises';
import { readFileSync } from 'fs';
import { execSync } from 'child_process';
import path from 'path';

const args = Object.fromEntries(process.argv.slice(2).map((a) => {
  const [k, v] = a.replace(/^--/, '').split('=');
  return [k, v ?? true];
}));
const STACK = args.stack;
const VIEWERS = Number(args.viewers ?? 10);
const DURATION_S = Number(args.duration ?? 30);
const RUNS = Number(args.runs ?? 3);
const ROOM = args.room || `benchroom-${Date.now().toString(36)}`;
const STATIC_PORT = 8899;

if (!STACK) { console.error('missing --stack'); process.exit(1); }

const MIME = { '.html': 'text/html', '.js': 'application/javascript', '.mjs': 'application/javascript', '.map': 'application/json', '.css': 'text/css', '.png': 'image/png' };
// Anchor to the script's own location — the server must serve pages and
// node_modules from beside itself, regardless of the caller's cwd.
const ROOT = path.dirname(new URL(import.meta.url).pathname);
const WWW = path.join(ROOT, 'www');

import { createHmac } from 'crypto';

/* HS256 JWT signed at runtime — LiveKit Cloud creds come from the env,
 * never from the repo. Self-hosted bench can still call this with its own
 * benchkey/benchsecret pair exported the same way. */
function b64url(buf) {
  return Buffer.from(buf).toString('base64url');
}
function livekitToken(room, identity, canPublish) {
  const now = Math.floor(Date.now() / 1000);
  const key = process.env.LIVEKIT_BENCH_API_KEY || 'benchkey';
  const secret = process.env.LIVEKIT_BENCH_API_SECRET || 'benchsecret';
  const header = b64url(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
  const payload = b64url(JSON.stringify({
    exp: now + 6 * 3600,
    nbf: now - 10,
    iss: key,
    sub: identity,
    video: { roomJoin: true, room, canPublish, canSubscribe: true },
  }));
  const sig = createHmac('sha256', secret).update(`${header}.${payload}`).digest('base64url');
  return `${header}.${payload}.${sig}`;
}

function serveStatic() {
  const server = createServer(async (req, res) => {
    try {
      const url = new URL(req.url ?? '/', 'http://localhost');
      const pathname = decodeURIComponent(url.pathname);
      if (pathname === '/livekit-bench/token') {
        const role = url.searchParams.get('role') || 'subscriber';
        const room = url.searchParams.get('room') || 'benchroom';
        const identity = `${role}-${Math.random().toString(36).slice(2, 10)}`;
        res.writeHead(200, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
        res.end(JSON.stringify({ url: process.env.LIVEKIT_BENCH_URL || 'ws://localhost:7890', token: livekitToken(room, identity, role === 'publisher'), room, role }));
        return;
      }
      let urlPath = pathname;
      if (urlPath.endsWith('/')) urlPath += 'index.html';
      // Resolve: www file → node_modules → nearest ancestor index.html (so
      // `/jitsi-app/<room>` serves the Jitsi Meet shell, SPA-style).
      const candidates = [path.join(WWW, urlPath), path.join(ROOT, 'node_modules', urlPath)];
      let file = null;
      for (const c of candidates) {
        try { await readFile(c); file = c; break; } catch { /* try next */ }
      }
      if (!file) {
        let dir = path.dirname(path.join(WWW, urlPath));
        while (true) {
          const candidate = path.join(dir, 'index.html');
          try { await readFile(candidate); file = candidate; break; } catch { /* keep walking */ }
          const parent = path.dirname(dir);
          if (parent === dir) break;
          dir = parent;
        }
      }
      if (!file) { res.writeHead(404); res.end('not found'); return; }
      const body = await readFile(file);
      res.writeHead(200, { 'Content-Type': MIME[path.extname(file)] ?? 'application/octet-stream', 'Access-Control-Allow-Origin': '*' });
      res.end(body);
    } catch (e) {
      res.writeHead(404); res.end('not found: ' + e.message);
    }
  });
  server.listen(STATIC_PORT);
  return server;
}

function hostSfuSample(pid) {
  try {
    const stat = readFileSync(`/proc/${pid}/stat`, 'utf8');
    const after = stat.slice(stat.lastIndexOf(')') + 2).split(' ');
    const utime = Number(after[11]);
    const stime = Number(after[12]);
    const status = readFileSync(`/proc/${pid}/status`, 'utf8');
    const rssLine = status.split('\n').find((l) => l.startsWith('VmRSS'));
    const rssKb = rssLine ? parseInt(rssLine.split(/\s+/)[1], 10) : 0;
    return { ticks: utime + stime, rssMb: Math.round(rssKb / 1024) };
  } catch { return null; }
}

async function dockerStats(containerPrefix, seconds) {
  // Host-process mode: when LIVEKIT_SFU_PID is set, sample that pid from
  // /proc instead of docker — used for the livekit self-host leg running on
  // the host (rootless podman can't carry browser ICE to containers).
  const sfuPid = process.env.LIVEKIT_SFU_PID ? Number(process.env.LIVEKIT_SFU_PID) : null;
  if (sfuPid) {
    const samples = [];
    let prev = hostSfuSample(sfuPid);
    const hz = 100;
    for (let i = 0; i < seconds; i++) {
      await new Promise((r) => setTimeout(r, 1000));
      const cur = hostSfuSample(sfuPid);
      if (cur && prev) {
        samples.push({ cpu: ((cur.ticks - prev.ticks) / hz) * 100, memPerc: 0, rssMb: cur.rssMb });
        prev = cur;
      }
    }
    const sum = samples.reduce((a, s) => a + s.cpu, 0);
    return { samples: samples.length, avgCpu: samples.length ? sum / samples.length : 0, peakCpu: Math.max(0, ...samples.map((s) => s.cpu)), peakMemPerc: 0, sfuMemRssMb: Math.max(0, ...samples.map((s) => s.rssMb ?? 0)) };
  }
  const samples = [];
  for (let i = 0; i < seconds; i++) {
    try {
      const out = execSync(`docker stats --no-stream --format '{{json .}}' --no-stream 2>/dev/null || true`, { stdio: ['ignore', 'pipe', 'ignore'] }).toString();
      for (const line of out.split('\n')) {
        if (!line.trim()) continue;
        const s = JSON.parse(line);
        if (s.Name.startsWith(containerPrefix)) {
          // docker uses CPUPerc/MemPerc/NetIO; podman uses AvgCPU(=CPU)/MemPerc/Network.*
          const cpu = parseFloat(String((s.CPUPerc ?? s.AvgCPU ?? s.CPU) ?? 0).replace('%', '')) || 0;
          const mem = parseFloat(s.MemPerc) || 0;
          const netRaw = typeof s.NetIO === 'string'
            ? s.NetIO
            : `rx=${Object.values(s.Network ?? {}).reduce((a, n) => a + (n.RxBytes || 0), 0)} tx=${Object.values(s.Network ?? {}).reduce((a, n) => a + (n.TxBytes || 0), 0)}`;
          samples.push({ cpu, memPerc: mem, net: netRaw });
        }
      }
    } catch { /* stats hiccup */ }
    await new Promise((r) => setTimeout(r, 1000));
  }
  const sum = samples.reduce((a, s) => a + s.cpu, 0);
  return { samples: samples.length, avgCpu: samples.length ? sum / samples.length : 0, peakCpu: Math.max(0, ...samples.map((s) => s.cpu)), peakMemPerc: Math.max(0, ...samples.map((s) => s.memPerc)) };
}

async function runOnce(mediaCPUPrefix) {
  const statsPromise = dockerStats(mediaCPUPrefix, DURATION_S + 10);
  const browser = await chromium.launch({
    executablePath: process.env.CHROME_BIN || '/home/peter/.cache/ms-playwright/chromium-1208/chrome-linux64/chrome',
    args: ['--use-fake-device-for-media-stream', '--use-fake-ui-for-media-stream', '--autoplay-policy=no-user-gesture-required'],
  });
  const pubPage = await browser.newPage();
  const pubErrors = [];
  pubPage.on('pageerror', (e) => pubErrors.push(String(e).slice(0, 200)));
  pubPage.on('console', (m) => { if (process.env.BENCH_VERBOSE) console.log('[pub]', m.type(), m.text().slice(0, 160)); });
  pubPage.on('console', (m) => { if (m.type() === 'error') pubErrors.push(m.text().slice(0, 200)); });
  if (process.env.BENCH_VERBOSE) {
    pubPage.on('requestfailed', (r) => console.log('[pub REQFAIL]', r.url().slice(0, 140), r.failure()?.errorText));
    pubPage.on('response', (r) => { if (r.status() >= 400) console.log('[pub ' + r.status() + ']', r.url().slice(0, 140)); });
  }
  // Bot pages (used by both jitsi and livekit) get a tiny poller injected
  // pre-navigation that sets __published / __ttffMs — page-load→first-frame.
  const jitsiPoller = `
    window.__published = window.__published || false;
    window.__ttffMs = window.__ttffMs || null;
    setInterval(() => {
      for (const v of document.querySelectorAll('video')) {
        if (v.readyState >= 2 && v.videoWidth > 0) {
          window.__published = true;
          if (window.__ttffMs == null) window.__ttffMs = Math.round(performance.now());
        }
      }
    }, 250);
  `;
  await pubPage.addInitScript(jitsiPoller);
  await pubPage.goto(`http://localhost:${STATIC_PORT}/${STACK}/publisher.html?room=${ROOM}`, { waitUntil: 'domcontentloaded', timeout: 30000 });
  await pubPage.waitForFunction('window.__published === true', { timeout: 45000 });

  const subscribers = [];
  const subs = [];
  for (let i = 0; i < VIEWERS; i++) {
    const page = await browser.newPage();
    const sub = { i, errors: [], ttff: null, stats: null };
    page.on('pageerror', (e) => sub.errors.push(String(e).slice(0, 200)));
    page.on('console', (m) => { if (m.type() === 'error') sub.errors.push(m.text().slice(0, 200)); });
    if (STACK === 'jitsi' || STACK === 'livekit') await page.addInitScript(jitsiPoller);
    await page.goto(`http://localhost:${STATIC_PORT}/${STACK}/subscriber.html?room=${ROOM}&v=${i}`, { waitUntil: 'domcontentloaded', timeout: 30000 });
    subs.push({ page, sub });
  }

  for (const { page, sub } of subs) {
    const ttff = await page.evaluate(() => new Promise((resolve) => {
      // ttff is written in-page by the pre-navigation poller (time from page
      // load to first decoded frame). Poll for it; do NOT fall back to a
      // readyState check here — that resolves ~0 the moment the video is
      // already playing and would clobber the real measurement.
      const iv = setInterval(() => {
        if (typeof window.__ttffMs === 'number') { clearInterval(iv); resolve(window.__ttffMs); }
      }, 100);
      setTimeout(() => {
        clearInterval(iv);
        resolve(typeof window.__ttffMs === 'number' ? window.__ttffMs : null);
      }, 15000);
    }));
    sub.ttff = ttff;
  }

  // steady-state media + stats
  await new Promise((r) => setTimeout(r, DURATION_S * 1000));
  for (const { page, sub } of subs) {
    sub.stats = await page.evaluate(async () => {
      const pcMap = window.__pcs ?? [];
      const result = { rttMs: null, jitterMs: null, lossPct: null, framesDecoded: 0, bytesReceived: 0, tracks: 0 };
      for (const pc of pcMap) {
        try {
          const stats = await pc.getStats();
          stats.forEach((r) => {
            if (r.type === 'inbound-rtp' && r.kind === 'video') {
              result.jitterMs = r.jitter != null ? Math.round(r.jitter * 1000) : result.jitterMs;
              result.framesDecoded += r.framesDecoded ?? 0;
              result.bytesReceived += r.bytesReceived ?? 0;
              result.lossPct = r.packetsLost != null && r.packetsReceived > 0
                ? Math.round((100 * r.packetsLost) / (r.packetsReceived + r.packetsLost) * 100) / 100
                : result.lossPct;
            }
            if (r.type === 'candidate-pair' && r.state === 'succeeded' && r.currentRoundTripTime != null) {
              result.rttMs = Math.round(r.currentRoundTripTime * 1000);
            }
          });
          result.tracks += pc.getReceivers().filter((x) => x.track.kind === 'video').length;
        } catch { /* ignore one pc */ }
      }
      return result;
    });
  }

  for (const { page } of subs) await page.close();
  await pubPage.close();
  await browser.close();
  const stats = await statsPromise;
  const ttffValues = subs.map((s) => s.sub.ttff).filter((v) => typeof v === 'number');
  const rttValues = subs.map((s) => s.sub.stats?.rttMs).filter((v) => typeof v === 'number');
  const jitterValues = subs.map((s) => s.sub.stats?.jitterMs).filter((v) => typeof v === 'number');
  const lossValues = subs.map((s) => s.sub.stats?.lossPct).filter((v) => typeof v === 'number');
  const median = (arr) => arr.length ? [...arr].sort((a, b) => a - b)[Math.floor(arr.length / 2)] : null;
  return {
    stack: STACK,
    viewers: VIEWERS,
    publisherErrors: pubErrors,
    subscriberErrors: subs.map((s) => s.sub.errors).filter((e) => e.length),
    ttffMedianMs: median(ttffValues),
    ttffP95Ms: ttffValues.length ? [...ttffValues].sort((a, b) => a - b)[Math.floor(ttffValues.length * 0.95)] : null,
    ttffValues,
    rttMedianMs: median(rttValues),
    jitterMedianMs: median(jitterValues),
    lossMedianPct: median(lossValues),
    sfuCpuAvgPct: Math.round(stats.avgCpu * 100) / 100,
    sfuCpuPeakPct: Math.round(stats.peakCpu * 100) / 100,
    sfuMemPeakPerc: Math.round(stats.peakMemPerc * 100) / 100,
    sfuMemRssMb: stats.sfuMemRssMb ?? null,
    samples: stats.samples,
  };
}

(async () => {
  const server = serveStatic();
  const prefix = { livekit: 'bench_livekit', jitsi: 'bench_jitsi_jvb', mediasoup: '', janus: 'bench_janus', pion: '' }[STACK] ?? '';
  await mkdir(path.join(ROOT, '..', 'results'), { recursive: true });
  const allRuns = [];
  for (let run = 1; run <= RUNS; run++) {
    console.error(`run ${run}/${RUNS} — starting`);
    const r = await runOnce(prefix);
    r.run = run;
    allRuns.push(r);
    console.error(`run ${run}: ttff=${r.ttffMedianMs}ms cpu=${r.sfuCpuAvgPct}% viewers=${VIEWERS}`);
  }
  server.close();
  const out = { stack: STACK, viewers: VIEWERS, durationS: DURATION_S, runs: allRuns, at: new Date().toISOString() };
  const file = path.join(ROOT, '..', 'results', `${STACK}-${VIEWERS}v-${Date.now()}.json`);
  await writeFile(file, JSON.stringify(out, null, 2));
  console.log('WROTE', file);
})().catch((e) => { console.error('BENCH FAILED', e); process.exit(1); });
