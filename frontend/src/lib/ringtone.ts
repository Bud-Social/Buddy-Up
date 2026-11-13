/**
 * Ring sounds synthesised with the Web Audio API — no assets, no network.
 *
 * `playRingtone` is the callee's phone: an old desk-bell / ethernet telephone
 * bell — two hammer strikes of a detuned inharmonic partial set with a fast
 * decay, repeating on the North American 2 s-on / 4 s-off cadence.
 *
 * `playRingback` is what the caller hears: the classic 440 + 480 Hz recall
 * tone, same cadence.
 *
 * `playFaintChime` is the soft nudge used when someone asks to switch a
 * voice call to video — present but not demanding.
 *
 * Each returns a stop() function that silences everything and closes the
 * AudioContext.
 */

type AudioContextCtor = typeof AudioContext;

function makeCtx(): AudioContext {
  const Ctor: AudioContextCtor | undefined =
    window.AudioContext ?? (window as unknown as { webkitAudioContext?: AudioContextCtor }).webkitAudioContext;
  if (!Ctor) throw new Error('Web Audio is not supported in this browser');
  return new Ctor();
}

export function playRingtone(): () => void {
  const ctx = makeCtx();
  const master = ctx.createGain();
  master.gain.value = 0.5;
  master.connect(ctx.destination);

  let stopped = false;
  let timer: ReturnType<typeof setTimeout> | null = null;

  const strike = (t: number, freq: number, peak: number, decay: number) => {
    // An inharmonic partial stack reads as metal rather than synth.
    const partials: Array<[number, number]> = [
      [1.0, 1.0],
      [2.76, 0.55],
      [5.40, 0.22],
      [8.93, 0.08],
    ];
    for (const [ratio, amp] of partials) {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'sine';
      osc.frequency.value = freq * ratio;
      gain.gain.setValueAtTime(0, t);
      gain.gain.linearRampToValueAtTime(peak * amp, t + 0.004);
      gain.gain.exponentialRampToValueAtTime(0.0001, t + decay * (1 / Math.sqrt(ratio)));
      osc.connect(gain).connect(master);
      osc.start(t);
      osc.stop(t + decay + 0.05);
    }
  };

  const burst = (t: number) => {
    // "brrring": two rapid strikes, a classic double-ring bell doublet.
    strike(t, 1450, 0.9, 0.9);
    strike(t + 0.075, 1750, 0.7, 0.8);
    strike(t + 0.16, 1450, 0.55, 0.6);
  };

  const tick = () => {
    if (stopped) return;
    const t = ctx.currentTime + 0.05;
    burst(t);
    burst(t + 0.32);
    timer = setTimeout(tick, 2600);
  };
  tick();

  return () => {
    stopped = true;
    if (timer) clearTimeout(timer);
    try {
      master.gain.linearRampToValueAtTime(0, ctx.currentTime + 0.15);
      window.setTimeout(() => void ctx.close().catch(() => {}), 250);
    } catch {
      void ctx.close().catch(() => {});
    }
  };
}

export function playRingback(): () => void {
  const ctx = makeCtx();
  const master = ctx.createGain();
  master.gain.value = 0.25;
  master.connect(ctx.destination);

  let stopped = false;
  let timer: ReturnType<typeof setTimeout> | null = null;

  const tick = () => {
    if (stopped) return;
    const t = ctx.currentTime + 0.05;
    // US ringback: 440 + 480 Hz, 2 s on.
    const o1 = ctx.createOscillator();
    const o2 = ctx.createOscillator();
    const gain = ctx.createGain();
    o1.frequency.value = 440;
    o2.frequency.value = 480;
    gain.gain.setValueAtTime(0, t);
    gain.gain.linearRampToValueAtTime(1, t + 0.02);
    gain.gain.setValueAtTime(1, t + 1.95);
    gain.gain.linearRampToValueAtTime(0, t + 2.0);
    o1.connect(gain);
    o2.connect(gain);
    gain.connect(master);
    o1.start(t);
    o2.start(t);
    o1.stop(t + 2.1);
    o2.stop(t + 2.1);
    timer = setTimeout(tick, 5000);
  };
  tick();

  return () => {
    stopped = true;
    if (timer) clearTimeout(timer);
    try {
      master.gain.linearRampToValueAtTime(0, ctx.currentTime + 0.1);
      window.setTimeout(() => void ctx.close().catch(() => {}), 200);
    } catch {
      void ctx.close().catch(() => {});
    }
  };
}

export function playFaintChime(): void {
  try {
    const ctx = makeCtx();
    const t = ctx.currentTime + 0.05;
    const o = ctx.createOscillator();
    const g = ctx.createGain();
    o.type = 'sine';
    o.frequency.value = 660;
    g.gain.setValueAtTime(0, t);
    g.gain.linearRampToValueAtTime(0.12, t + 0.02);
    g.gain.exponentialRampToValueAtTime(0.0001, t + 0.9);
    o.connect(g).connect(ctx.destination);
    o.start(t);
    o.stop(t + 1.0);
    window.setTimeout(() => void ctx.close().catch(() => {}), 1500);
  } catch {
    /* audio unavailable — stay silent */
  }
}
