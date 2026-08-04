/**
 * Emoji helpers.
 *
 * Reactions may be stored either as an actual emoji ("😂") or as a legacy
 * short-name ("haha"). Everywhere we display a reaction we normalize it to the
 * emoji glyph first, then render the Apple CDN image (system-text fallback if
 * the CDN is unreachable).
 */

export const REACTION_EMOJI_MAP: Record<string, string> = {
  pump: '💪',
  fire: '🔥',
  respect: '🤝',
  grind: '😤',
  lets_go: '🏋️',
  haha: '😂',
  too_hard: '💀',
  heart: '❤️',
  love: '❤️',
  clap: '👏',
  applause: '👏',
  muscle: '💪',
  strength: '💪',
};

export function toEmoji(value: string): string {
  if (!value) return value;
  return REACTION_EMOJI_MAP[value] || value;
}

/**
 * Converts a unicode emoji string to its Apple CDN image URL.
 * Uses emoji-datasource-apple served via jsDelivr CDN.
 * Variation selectors (FE0F) and zero-width joiners are stripped so common
 * emoji resolve to a single file. Falls back to the text glyph if not found.
 */
export function getAppleEmojiUrl(emojiStr: string): string {
  const resolved = toEmoji(emojiStr);
  const codepoints: number[] = [];
  for (const char of resolved) {
    const cp = char.codePointAt(0);
    if (cp === undefined || cp === 0xFE0F || cp === 0x200D) continue;
    codepoints.push(cp);
  }
  const codeStr = codepoints.map((cp) => cp.toString(16)).join('-');
  return `https://cdn.jsdelivr.net/npm/emoji-datasource-apple/img/apple/64/${codeStr}.png`;
}

interface EmojiImgProps {
  emoji: string;
  size?: number;
  className?: string;
}

export function EmojiImg({ emoji, size = 20, className = '' }: EmojiImgProps) {
  const resolved = toEmoji(emoji);
  const url = getAppleEmojiUrl(resolved);
  return (
    <img
      src={url}
      alt={resolved}
      width={size}
      height={size}
      className={`inline-block align-middle select-none ${className}`}
      style={{ objectFit: 'contain' }}
      onError={(e) => {
        // Fallback to the text emoji glyph if the image fails to load
        const target = e.currentTarget;
        target.style.display = 'none';
        const span = document.createElement('span');
        span.textContent = resolved;
        target.parentNode?.insertBefore(span, target);
      }}
    />
  );
}
