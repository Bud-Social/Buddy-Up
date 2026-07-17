import { useMemo, useEffect, useState, useRef } from 'react';
import type { AttendeeInfo } from '@/types/live';

const NAMES = [
  'Alice Johnson', 'Bob Smith', 'Charlie Brown', 'Diana Prince',
  'Eve Adams', 'Frank Castle', 'Grace Hopper', 'Hank Pym',
  'Ivy League', 'Jack Sparrow', 'Kate Bishop', 'Leo Messi',
  'Mona Lisa', 'Nick Fury', 'Oscar Wilde', 'Pam Beesly',
  'Quinn Fabray', 'Ray Holt', 'Sarah Connor', 'Tom Sawyer',
  'Uma Thurman', 'Victor Hugo', 'Wade Wilson', 'Xena Warrior',
  'Yara Greyjoy', 'Zoe Barnes',
];
function makeSimAttendee(index: number): AttendeeInfo {
  const name = NAMES[index % NAMES.length];
  const hasMic = Math.random() > 0.3;
  const hasVideo = Math.random() > 0.4;
  return {
    id: `sim-${index}-${Date.now()}`,
    displayName: name,
    avatarUrl: '',
    isSpeaking: false,
    hasMicOn: hasMic,
    hasVideoOn: hasVideo,
    isLocal: false,
    audioLevel: 0,
  };
}

export default function useSimulatedAttendees(): AttendeeInfo[] {
  const count = useMemo(() => {
    if (import.meta.env.PROD) return 0;
    const params = new URLSearchParams(window.location.search);
    const n = parseInt(params.get('dev_sim') || '0', 10);
    return isNaN(n) ? 0 : Math.min(n, 30);
  }, []);

  const [sims, setSims] = useState<AttendeeInfo[]>(() =>
    Array.from({ length: count }, (_, i) => makeSimAttendee(i))
  );
  const intervalRef = useRef<ReturnType<typeof setInterval>>();

  useEffect(() => {
    if (count === 0) return;
    intervalRef.current = setInterval(() => {
      setSims((prev) =>
        prev.map((s) => {
          const speaking = Math.random() > 0.7;
          return {
            ...s,
            isSpeaking: speaking,
            audioLevel: speaking ? Math.random() * 0.8 + 0.2 : 0,
            hasMicOn: Math.random() > 0.2,
            hasVideoOn: Math.random() > 0.3,
          };
        })
      );
    }, 2500);
    return () => clearInterval(intervalRef.current);
  }, [count]);

  return sims;
}
