/**
 * Generates a simple ring tone using the Web Audio API.
 * Used as a fallback when no ringtone.mp3 is available.
 */
export function playRingtone(): () => void {
  const ctx = new (window.AudioContext || (window as any).webkitAudioContext)();
  let stopped = false;

  const ring = () => {
    if (stopped) return;
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.connect(gain);
    gain.connect(ctx.destination);

    osc.type = 'sine';
    osc.frequency.setValueAtTime(880, ctx.currentTime);
    osc.frequency.setValueAtTime(660, ctx.currentTime + 0.2);
    gain.gain.setValueAtTime(0.3, ctx.currentTime);
    gain.gain.linearRampToValueAtTime(0, ctx.currentTime + 0.4);

    osc.start(ctx.currentTime);
    osc.stop(ctx.currentTime + 0.5);

    if (!stopped) {
      setTimeout(ring, 1200);
    }
  };

  ring();

  return () => {
    stopped = true;
    ctx.close();
  };
}
