# SFU Bake-off — LiveKit vs Jitsi Videobridge (Phase 6)

**Question:** which SFU should host Buddy Up's audience-style rooms (1 host +
N silent viewers)? LiveKit is the incumbent — it already powers calls and
lives (self-hosted container for dev, LiveKit Cloud for production, egress →
Mux for replays). This bench tests whether a challenger displaces it.

## Decision (final)

**LiveKit stays the SFU. No migration.**

The gate, agreed before any benchmark ran (do not move it retroactively):

> LiveKit stays incumbent unless a challenger beats it decisively — ≥2× lower
> time-to-first-frame at 50 viewers, **or** ≥2× lower SFU CPU per viewer at
> equal quality, **or** ≥2× better packet loss at 50 viewers — with no
> regression on what Phases 1–5 need (web + Flutter SDKs, Mux replay egress,
> simulcast/adaptive streams). If results are within ~20–30%, keep LiveKit.

Measured outcome (localhost SFU vs localhost SFU, same synthetic load):

| Stack (self-host, localhost) | ttff (median) | ttff p95 | RTT | jitter | loss | CPU | SFU mem |
|---|---|---|---|---|---|---|---|
| LiveKit self-host | 1v **579 ms** | 579 | 1 ms | 5 ms | 0 % | 4.2 %* | 95 MB |
| LiveKit self-host | 10v **1073 ms** | 1343 | 2 ms | 3 ms | 0 % | 7.7 %* | 120 MB |
| LiveKit self-host | 25v **1105 ms** | 2117 | 4 ms | 8 ms | 0 % | 12.4 %* | 156 MB |
| LiveKit self-host | 50v **1906 ms** | 4038 | 44 ms | 37 ms | 0 % | 10.9 %* | 170 MB |
| Jitsi (JVB) | 2v 3278 ms | 3278 | n/d | n/d | n/d | 5.1 %† | n/d |
| Jitsi (JVB) | 10v 5100 ms | n/d | n/d | n/d | n/d | 4.7 %† | n/d |
| Jitsi (JVB) | 25v 6066 ms | n/d | n/d | n/d | n/d | 4.1 %† | n/d |
| Jitsi (JVB) | 50v 4541 ms | n/d | n/d | n/d | n/d | 3.3 %† | n/d |

\* LiveKit CPU = % of one core, sampled from `/proc/<host-pid>` (the SFU ran
on the host because rootless podman cannot carry browser ICE to containers).
† Jitsi CPU = podman `AvgCPU` for `bench_jitsi_jvb`. Different rulers —
treat as approximate, ordinal. Neither is near saturation either way
(4-core box).

**Reading:** LiveKit delivers first frame ~2.4–5.5× faster at every tier
(1.1 s vs 5.1 s @10v, 1.1 s vs 6.1 s @25v, 1.9 s vs 4.5 s @50v) with zero
measured loss and complete RTCP visibility. Jitsi's only win is ~2–3× lower
SFU CPU per viewer — but the gate requires that at *equal quality*, and a
4–6 s time-to-first-frame with no client-accessible loss/jitter telemetry is
not equal quality. Jitsi's p2p mode (used for 1-on-1 rooms) is fine, but for
the audience scenario the XMPP → conference-request → JVB allocate →
session-initiate chain is why everything is slow. The gate result is
unambiguous, not within noise.

**Reference data, LiveKit Cloud (Jeddah/Saudi Arabia edge), same harness:**
1v 3099 ms (rtt 192 ms, loss 0 %) · 10v 13303 ms (loss 17.8 %) · 25v
7583 ms (loss 17.5 %) · 50v 4820 ms median, p95 23 s (loss 19.0 %). The
Cloud leg is confounded by WAN + a 4-CPU host carrying 50 Chromium tabs, so
it is **reference only, not a decision input** — but nothing about it
challenges the conclusion either.

**Not run, and why:**

| Challenger | Status |
|---|---|
| Janus | **Unavailable here** — every public registry image denied (`cangol/janus`, `meetecho/janus-gateway`, `janusconflux/janus`, …). No local build attempted. |
| mediasoup | Not built this phase. With the gate already decisively settled for the incumbent, and Jitsi's loss on the decisive axis (ttff ×3–5, quality metadata null), there is no rational budget to build a third challenger whose realistic outcome is "also loses on ttff, maybe wins on CPU." Recommend as future work only if self-host cost becomes a real constraint. |
| Pion | Same as mediasoup. Also a larger lift (Go SIM server + new client SDK integration + Mux-egress replacement research). |

## What was actually built (this phase)

- `compose.yml` — livekit (container) + Jitsi stack (prosody/jicofo/jvb/web).
- `livekit.yaml` — container livekit config (works for signaling; media ICE
  to containers does **not** work under rootless podman — see below).
- `bots/bench.mjs` — the harness: fake-media Chromium publisher + N silent
  subscribers (playwright), in-page `__ttffMs`/`__published` poller injected
  pre-navigation (page-load → first decoded frame), docker-stats or
  `/proc/<pid>` SFU sampling, JSON results to `results/`.
- `bots/www/livekit/*`, `bots/www/jitsi/*` — bot pages. The Jitsi bots
  redirect into the **real Jitsi Meet webapp** (`www/jitsi-app/`, 122 MB,
  git-ignored, copied from the `bench_jitsi_web` container) so the full
  production client path (XMPP signaling, jicofo, SCTP bridge channel) is
  measured, not a hand-rolled client.
- `custom jicofo.conf` → **replaced by env**: `JICOFO_CONF_MAX_AUDIO_SENDERS`
  / `JICOFO_CONF_MAX_VIDEO_SENDERS=1000` in `compose.yml`. The stock template
  leaves these **empty, resolving to 0**, which makes Jicofo report
  `audio-limit-reached=true` from the first participant — every client joins
  with zero tracks and can never unmute. Root-caused through the Jicofo jar
  (`JitsiMeetConferenceImpl.onNum*SendersChanged`, `senderCount >= maxSenders`).
- `jitsi-app/config.js` — same-origin webapp config; **do not** re-add
  `#config.prejoinConfig.enabled=false` to the URL: the client merges that
  hash as a config overwrite and treats it as "starting without media"
  (`disableInitialGUM=true`), silently joining with 0 tracks. That was the
  single hardest bug in this phase.
- `results/*.json` — raw outputs for the tables above.

## Hard-won environment facts (podman rootless)

- Containers' `eth0` IPs are **unreachable from the host browser**; only
  published ports work (slirp). LiveKit ICE and JVB↔browser ICE both fail
  that way. This killed the containerized LiveKit self-host leg; the
  self-host leg therefore runs the official `livekit-server` binary **on
  the host** (v1.13.11) — same machine, same network namespace as the JVB.
- `docker stats` under podman reports `AvgCPU`/`MemPerc`/`Network.*`, not
  docker's `CPUPerc`/`MemPerc`/`NetIO` — the sampler handles both.
- The Jitsi stack must run with `XMPP_DOMAIN=meet.jitsi` (the prosody image
  ignores `XMPP_DOMAIN` and provisions against its built-in `meet.jitsi`).
- MUC rooms persist with all zombie XMPP sessions; keep test room names
  unique per run (the harness does).
- Fake media (`--use-fake-device-for-media-stream`) yields a static-ish
  stream → very low bitrates → SFU CPU numbers are a **lower bound** for
  both stacks equally. Comparisons remain valid; absolutes are not "specs."

## Method

Scenario: 1 publisher (synthetic 720p camera + fake mic) → N silent viewers.
4-core / 24 GB host. 15–20 s steady state per run, Chromium headless with
fake media + autoplay allowed. ttff = page-load → first decoded frame,
measured in-page by a pre-navigation poller (uniform across stacks). SFU CPU
sampled once per second (podman or `/proc`). Loss/RTT/jitter from subscriber
`getStats()` RTCP (LiveKit only — Jitsi exposes nothing equivalent to the
page). Results are ordinal: 4-CPU machine, single runs per cell, Cloud leg
confounded by WAN — see caveats above. Full per-viewer ttff arrays are kept
in `results/*.json` (`ttffValues`).

## Reproduce

```bash
cd bench/sfu
docker compose up -d                       # Jitsi stack (+ livekit container)
docker cp bench_jitsi_web:/usr/share/jitsi-meet/. bots/www/jitsi-app/
cp reference/jitsi-app-config.js bots/www/jitsi-app/config.js
cp reference/jitsi-app-interface_config.js bots/www/jitsi-app/interface_config.js
cd bots && npm install

# LiveKit self-host (host binary — container ICE doesn't work here)
./livekit-server --config /path/to/livekit-host.yaml &   # port 7900
LIVEKIT_SFU_PID=$! LIVEKIT_BENCH_URL=ws://127.0.0.1:7900 \
  LIVEKIT_BENCH_API_KEY=benchkey LIVEKIT_BENCH_API_SECRET=benchsecret \
  node bench.mjs --stack=livekit --viewers=50 --duration=15 --runs=1

# Jitsi
node bench.mjs --stack=jitsi --viewers=50 --duration=20 --runs=1

# LiveKit Cloud (reference only; needs app creds from the backend container)
LIVEKIT_BENCH_URL=wss://buddy-up-hf40obqn.livekit.cloud \
LIVEKIT_BENCH_API_KEY=... LIVEKIT_BENCH_API_SECRET=... \
  node bench.mjs --stack=livekit --viewers=50 --duration=15 --runs=1
```

Note: `results/` is 100 KB of JSON — committed as evidence. `www/jitsi-app/`
(122 MB) and `node_modules/` are not.
