import React from 'react';

// Regex to capture emoji sequences (ZWJ, flags, modifiers, variation selectors)
const EMOJI_REGEX = /(\p{Emoji_Presentation}|\p{Extended_Pictographic})(?:\uFE0F)?(?:\u20D0-\u20FF)?(?:\u200D(?:\p{Emoji_Presentation}|\p{Extended_Pictographic})(?:\uFE0F)?(?:\u20D0-\u20FF)?)*/gu;

function emojiToAppleUrl(emojiStr: string): string {
  const codepoints: string[] = [];
  for (const char of [...emojiStr]) {
    const cp = char.codePointAt(0);
    if (cp !== undefined) {
      codepoints.push(cp.toString(16));
    }
  }
  // Remove trailing FE0F (variation selector) if more than one codepoint
  const filtered =
    codepoints.length > 1 && codepoints[codepoints.length - 1] === 'fe0f'
      ? codepoints.slice(0, -1)
      : codepoints;
  return `https://cdn.jsdelivr.net/npm/emoji-datasource-apple/img/apple/64/${filtered.join('-')}.png`;
}

interface RichTextProps {
  text: string;
  className?: string;
}

export function RichText({ text, className }: RichTextProps) {
  if (!text) return null;

  const parts: React.ReactNode[] = [];
  let lastIndex = 0;
  let match: RegExpExecArray | null;
  const re = new RegExp(EMOJI_REGEX.source, 'gu');

  while ((match = re.exec(text)) !== null) {
    if (match.index > lastIndex) {
      parts.push(text.slice(lastIndex, match.index));
    }
    const emojiStr = match[0];
    const url = emojiToAppleUrl(emojiStr);
    parts.push(
      <img
        key={`${match.index}-${emojiStr}`}
        src={url}
        alt={emojiStr}
        className="inline-block w-[1.2em] h-[1.2em] align-text-bottom mx-[0.05em] select-none"
        style={{ objectFit: 'contain' }}
        onError={(e) => {
          // Fallback: hide image and show raw emoji text
          const el = e.currentTarget;
          el.style.display = 'none';
          const span = document.createElement('span');
          span.textContent = emojiStr;
          el.parentNode?.insertBefore(span, el);
        }}
      />
    );
    lastIndex = re.lastIndex;
  }

  if (lastIndex < text.length) {
    parts.push(text.slice(lastIndex));
  }

  return <span className={className}>{parts}</span>;
}
