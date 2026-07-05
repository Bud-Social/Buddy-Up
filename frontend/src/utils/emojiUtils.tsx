/**
 * Converts a unicode emoji string to its Apple CDN image URL.
 * Uses emoji-datasource-apple served via jsDelivr CDN.
 */
export function getAppleEmojiUrl(emojiStr: string): string {
  // Convert emoji string to codepoints
  const codepoints: string[] = [];
  const chars = [...emojiStr]; // spread handles surrogate pairs
  for (const char of chars) {
    const cp = char.codePointAt(0);
    if (cp !== undefined && cp !== 0xFE0F && cp !== 0x200D) {
      // Skip variation selector-16 (FE0F) and ZWJ from the codepoint list 
      // but keep them for multi-codepoint sequences like flags
    }
    if (cp !== undefined) {
      codepoints.push(cp.toString(16));
    }
  }
  // Remove variation selector FE0F from single-char emojis if present at end
  const filtered = codepoints.filter((cp, i) => {
    if (cp === 'fe0f' && i === codepoints.length - 1 && codepoints.length > 1) return false;
    return true;
  });
  const codeStr = filtered.join('-');
  return `https://cdn.jsdelivr.net/npm/emoji-datasource-apple/img/apple/64/${codeStr}.png`;
}

interface EmojiImgProps {
  emoji: string;
  size?: number;
  className?: string;
}

export function EmojiImg({ emoji, size = 20, className = '' }: EmojiImgProps) {
  const url = getAppleEmojiUrl(emoji);
  return (
    <img
      src={url}
      alt={emoji}
      width={size}
      height={size}
      className={`inline-block align-middle select-none ${className}`}
      style={{ objectFit: 'contain' }}
      onError={(e) => {
        // Fallback to text emoji if image fails to load
        const target = e.currentTarget;
        target.style.display = 'none';
        const span = document.createElement('span');
        span.textContent = emoji;
        target.parentNode?.insertBefore(span, target);
      }}
    />
  );
}
