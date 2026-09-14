import { describe, expect, it, vi } from 'vitest';
import { fireEvent, render, screen } from '@testing-library/react';
import { CaptionsPanel, type CaptionSegment } from './CaptionsPanel';

describe('CaptionsPanel', () => {
  it('renders the backfill toggle for video posts', () => {
    render(
      <CaptionsPanel
        hasVideo
        autoCaptions
        onToggleAuto={vi.fn()}
        segments={[]}
        onChangeSegments={vi.fn()}
      />,
    );
    expect(screen.getByText('Backfill empty clips')).toBeDefined();
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
    fireEvent.click(screen.getByRole('button', { name: 'Add' }));
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
    expect(screen.queryByText('Backfill empty clips')).toBeNull();
  });

  it('uses review/style copy, never "generated after publish"', () => {
    const { container } = render(
      <CaptionsPanel
        hasVideo
        autoCaptions
        onToggleAuto={vi.fn()}
        segments={[]}
        onChangeSegments={vi.fn()}
        onGenerateAuto={vi.fn()}
      />,
    );
    expect(screen.getByText(/Review & style/i)).toBeDefined();
    expect(container.textContent).not.toMatch(/generated after publish/i);
  });

  it('shows the auto-caption action with progress/cancel/retry/error states', () => {
    const onGenerateAuto = vi.fn();
    const onCancelAuto = vi.fn();
    const base = {
      hasVideo: true,
      autoCaptions: true,
      onToggleAuto: vi.fn(),
      segments: [],
      onChangeSegments: vi.fn(),
      onGenerateAuto,
      onCancelAuto,
    } as const;

    const { rerender, container } = render(<CaptionsPanel {...base} autoJob={{ status: 'idle' }} />);
    fireEvent.click(screen.getByRole('button', { name: /auto-captions/i }));
    expect(onGenerateAuto).toHaveBeenCalledTimes(1);

    rerender(<CaptionsPanel {...base} autoJob={{ status: 'working' }} />);
    fireEvent.click(screen.getByRole('button', { name: /cancel/i }));
    expect(onCancelAuto).toHaveBeenCalledTimes(1);

    rerender(<CaptionsPanel {...base} autoJob={{ status: 'error', error: 'mic blew up' }} />);
    expect(screen.getByText('mic blew up')).toBeDefined();
    expect(container.textContent).not.toMatch(/generated after publish/i);
    fireEvent.click(screen.getByRole('button', { name: /retry auto-captions/i }));
    expect(onGenerateAuto).toHaveBeenCalledTimes(2);

    rerender(<CaptionsPanel {...base} autoJob={{ status: 'done' }} />);
    expect(screen.getByText(/review the lines below/i)).toBeDefined();
  });

  it('edits caption size and placement via style changes', () => {
    const onStyleChange = vi.fn();
    render(
      <CaptionsPanel
        hasVideo
        autoCaptions
        onToggleAuto={vi.fn()}
        segments={[]}
        onChangeSegments={vi.fn()}
        style={{ preset: 'classic' }}
        onStyleChange={onStyleChange}
      />,
    );
    fireEvent.click(screen.getByRole('button', { name: 'Top' }));
    expect(onStyleChange).toHaveBeenCalledWith(expect.objectContaining({ placement: 'top' }));
    const size = screen.getByRole('slider', { name: /caption size/i }) as HTMLInputElement;
    fireEvent.change(size, { target: { value: '1.3' } });
    expect(onStyleChange).toHaveBeenCalledWith(expect.objectContaining({ size: 1.3 }));
  });
});
