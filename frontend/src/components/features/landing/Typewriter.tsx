import { useEffect, useState } from 'react';

const DEFAULT_PHRASES = [
  'Buddy Up Fit(Bud)',
  'Your Bud is waiting',
  'Find your fitness family',
  'Train together. Stay accountable',
  'Live workouts, real buddies',
];

interface TypewriterProps {
  phrases?: string[];
  className?: string;
  typeMs?: number;
  deleteMs?: number;
  holdMs?: number;
}

export function Typewriter({
  phrases = DEFAULT_PHRASES,
  className = '',
  typeMs = 70,
  deleteMs = 35,
  holdMs = 1800,
}: TypewriterProps) {
  const [phraseIndex, setPhraseIndex] = useState(0);
  const [subIndex, setSubIndex] = useState(0);
  const [deleting, setDeleting] = useState(false);

  useEffect(() => {
    const current = phrases[phraseIndex % phrases.length];
    let timeout: number | undefined;

    if (!deleting && subIndex < current.length) {
      timeout = window.setTimeout(() => setSubIndex((i) => i + 1), typeMs);
    } else if (!deleting && subIndex === current.length) {
      timeout = window.setTimeout(() => setDeleting(true), holdMs);
    } else if (deleting && subIndex > 0) {
      timeout = window.setTimeout(() => setSubIndex((i) => i - 1), deleteMs);
    } else {
      setDeleting(false);
      setPhraseIndex((i) => (i + 1) % phrases.length);
    }

    return () => window.clearTimeout(timeout);
  }, [subIndex, deleting, phraseIndex, phrases, typeMs, deleteMs, holdMs]);

  return (
    <span className={className} aria-hidden="true">
      {phrases[phraseIndex % phrases.length].slice(0, subIndex)}
      <span className="type-caret">▍</span>
    </span>
  );
}