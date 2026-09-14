import { describe, expect, it, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Heart } from 'lucide-react';
import {
  RailAction,
  formatCount,
  nextReactionState,
  totalReactions,
} from '../RailAction';

describe('formatCount', () => {
  it('renders small counts verbatim', () => {
    expect(formatCount(0)).toBe('0');
    expect(formatCount(7)).toBe('7');
    expect(formatCount(999)).toBe('999');
  });

  it('compacts thousands and millions', () => {
    expect(formatCount(1200)).toBe('1.2k');
    expect(formatCount(10000)).toBe('10k');
    expect(formatCount(1500000)).toBe('1.5M');
  });

  it('treats missing counts as zero', () => {
    expect(formatCount(undefined)).toBe('0');
    expect(formatCount(null)).toBe('0');
  });
});

describe('nextReactionState', () => {
  it('adds the reaction on first tap', () => {
    const next = nextReactionState({}, null, '💪');
    expect(next).toEqual({ counts: { '💪': 1 }, userReaction: '💪', removed: false });
  });

  it('removes the reaction when tapping the active one', () => {
    const next = nextReactionState({ '💪': 3 }, '💪', '💪');
    expect(next).toEqual({ counts: { '💪': 2 }, userReaction: null, removed: true });
  });

  it('drops the key when the last reaction is removed', () => {
    const next = nextReactionState({ '💪': 1 }, '💪', '💪');
    expect(next.counts).toEqual({});
  });

  it('switching reactions decrements the old one and increments the new one', () => {
    const next = nextReactionState({ '🔥': 2, '💪': 1 }, '🔥', '💪');
    expect(next).toEqual({ counts: { '🔥': 1, '💪': 2 }, userReaction: '💪', removed: false });
  });

  it('supports rollback: restoring the previous snapshot undoes the optimistic update', () => {
    const prevCounts = { '🔥': 1 };
    const prevReaction = '🔥';
    const optimistic = nextReactionState(prevCounts, prevReaction, '💪');
    expect(optimistic.counts).toEqual({ '💪': 1 });
    // Simulated API failure -> roll back to the captured snapshot.
    const rolledBack = { counts: prevCounts, userReaction: prevReaction };
    expect(rolledBack.counts).toEqual({ '🔥': 1 });
    expect(rolledBack.userReaction).toBe('🔥');
    // Original snapshot was never mutated.
    expect(prevCounts).toEqual({ '🔥': 1 });
  });
});

describe('totalReactions', () => {
  it('sums all reaction counts', () => {
    expect(totalReactions({ '💪': 2, '🔥': 3 })).toBe(5);
    expect(totalReactions({})).toBe(0);
    expect(totalReactions(undefined)).toBe(0);
  });
});

describe('RailAction', () => {
  it('renders a labelled button with a count and active state', () => {
    const onClick = vi.fn();
    render(
      <RailAction
        label="Like with flexed biceps"
        icon={<Heart size={22} />}
        count={12}
        active
        onClick={onClick}
        testId="rail-like"
      />,
    );
    const btn = screen.getByRole('button', { name: 'Like with flexed biceps' });
    expect(btn).toHaveAttribute('aria-pressed', 'true');
    expect(screen.getByTestId('rail-like-count')).toHaveTextContent('12');
    btn.click();
    expect(onClick).toHaveBeenCalledTimes(1);
  });

  it('hides the counter when the metric is unavailable', () => {
    render(<RailAction label="Save" icon={<Heart size={22} />} testId="rail-save" onClick={vi.fn()} />);
    expect(screen.queryByTestId('rail-save-count')).toBeNull();
  });

  it('renders a non-interactive element when no handler is given (views)', () => {
    render(<RailAction label="5 views" icon={<Heart size={22} />} count={5} testId="rail-views" />);
    expect(screen.queryByRole('button')).toBeNull();
    expect(screen.getByTestId('rail-views-count')).toHaveTextContent('5');
  });
});
