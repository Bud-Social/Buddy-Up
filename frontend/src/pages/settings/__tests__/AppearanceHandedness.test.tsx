import { beforeEach, describe, expect, it } from 'vitest';
import { render, screen, fireEvent, cleanup } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import Appearance from '@/pages/settings/Appearance';
import { useHandednessStore } from '@/store/handednessStore';

describe('Appearance — left-handed mode', () => {
  beforeEach(() => {
    cleanup();
    localStorage.clear();
    useHandednessStore.setState({ handedness: 'right' });
  });

  it('starts right-handed, mirrors the preview when enabled, and persists', () => {
    render(
      <MemoryRouter>
        <Appearance />
      </MemoryRouter>,
    );

    const preview = screen.getByTestId('handedness-preview');
    expect(preview.className).not.toContain('flex-row-reverse');

    fireEvent.click(screen.getByRole('switch', { name: 'Left-handed mode' }));

    expect(preview.className).toContain('flex-row-reverse');
    expect(localStorage.getItem('buddyup-handedness')).toBe('left');
  });

  it('renders the mirrored preview for a left-handed preference', () => {
    localStorage.setItem('buddyup-handedness', 'left');
    useHandednessStore.setState({ handedness: 'left' });
    render(
      <MemoryRouter>
        <Appearance />
      </MemoryRouter>,
    );

    expect(screen.getByTestId('handedness-preview').className).toContain(
      'flex-row-reverse',
    );
    expect(
      screen.getByRole('switch', { name: 'Left-handed mode' }),
    ).toHaveAttribute('aria-checked', 'true');
  });
});
