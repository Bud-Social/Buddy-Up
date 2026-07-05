/**
 * Smart relative timestamp for posts.
 * < 1h  → "42 min ago at 09:15"
 * < 24h → "6h ago at 09:15"
 * < 7d  → "Mon, 30 Jun at 09:15"
 * else  → "30 Jun 2026"
 */
export function formatPostDate(dateStr: string): string {
  const date = new Date(dateStr);
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  const diffMins = Math.floor(diffMs / 60_000);
  const diffHours = Math.floor(diffMs / 3_600_000);
  const diffDays = Math.floor(diffMs / 86_400_000);

  const timeStr = date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

  if (diffMins < 60) {
    return diffMins <= 1 ? `just now` : `${diffMins} min ago at ${timeStr}`;
  }
  if (diffHours < 24) {
    return `${diffHours}h ago at ${timeStr}`;
  }
  if (diffDays < 7) {
    const dayName = date.toLocaleDateString([], { weekday: 'short' });
    const dateLabel = date.toLocaleDateString([], { day: 'numeric', month: 'short' });
    return `${dayName}, ${dateLabel} at ${timeStr}`;
  }
  return date.toLocaleDateString([], { day: 'numeric', month: 'short', year: 'numeric' });
}
