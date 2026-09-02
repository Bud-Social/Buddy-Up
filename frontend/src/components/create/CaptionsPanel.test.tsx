import { describe, expect, it, vi } from 'vitest';
import { fireEvent, render, screen } from '@testing-library/react';
import { CaptionsPanel, type CaptionSegment } from './CaptionsPanel';

describe('CaptionsPanel', () => {
  it('renders the auto-captions toggle for video posts', () => {
    render(
      <CaptionsPanel
        hasVideo
        autoCaptions
        onToggleAuto={vi.fn()}
        segments={[]}
        onChangeSegments={vi.fn()}
      />,
    );
    expect(screen.getByText('Auto-captions')).toBeDefined();
    expect(screen.getByRole('button', { pressed: true })).toBeDefined();
  });

  it('toggling auto-captions reports the new value', () => {
    const onToggleAuto = vi.fn();
    render(
      <CaptionsPanel
        hasVideo
        autoCaptions
        onToggleAuto={onToggleAuto}
        segments={[]}
        onChangeSegments={vi.fn()}
      />,
    );
    fireEvent.click(screen.getByRole('button', { pressed: true }));
    expect(onToggleAuto).toHaveBeenCalledWith(false);
  });

  it('adds and removes manual segments', () => {
    const onChangeSegments = vi.fn();
    const segments: CaptionSegment[] = [
      { id: 's1', start_ms: 1000, end_ms: 2000, text: 'hello' },
    ];
    const { rerender } = render(
      <CaptionsPanel
        hasVideo
        autoCaptions
        onToggleAuto={vi.fn()}
        segments={segments}
        onChangeSegments={onChangeSegments}
      />,
    );

    // Add: prefilled with nothing (empty text input)
    fireEvent.click(screen.getByRole('button', { name: /add/i }));
    const added = onChangeSegments.mock.calls[0][0] as CaptionSegment[];
    expect(added).toHaveLength(2);
    expect(added[1].text).toBe('');
    expect(added[1].start_ms).toBe(0);

    // Remove with the updated list
    rerender(
      <CaptionsPanel
        hasVideo
        autoCaptions
        onToggleAuto={vi.fn()}
        segments={added}
        onChangeSegments={onChangeSegments}
      />,
    );
    const removeButtons = screen.getAllByRole('button', { name: /remove segment/i });
    fireEvent.click(removeButtons[1]); // remove the newly added segment
    const removed = onChangeSegments.mock.calls[1][0] as CaptionSegment[];
    expect(removed).toHaveLength(1);
    expect(removed[0].id).toBe('s1');
  });

  it('hides the auto toggle for image-only posts', () => {
    render(
      <CaptionsPanel
        hasVideo={false}
        autoCaptions={false}
        onToggleAuto={vi.fn()}
        segments={[]}
        onChangeSegments={vi.fn()}
      />,
    );
    expect(screen.queryByText('Auto-captions')).toBeNull();
  });
});
