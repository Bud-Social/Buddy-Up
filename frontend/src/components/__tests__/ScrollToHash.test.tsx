import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { ScrollToHash } from '@/components/ScrollToHash';

describe('ScrollToHash', () => {
  it('scrolls to the hash target on navigation', async () => {
    const scrollIntoView = vi.fn();
    Element.prototype.scrollIntoView = scrollIntoView;
    render(
      <MemoryRouter initialEntries={['/#target']}>
        <ScrollToHash />
        <div id="target">here</div>
      </MemoryRouter>,
    );
    await waitFor(() => {
      expect(scrollIntoView).toHaveBeenCalled();
    });
  });

  it('scrolls to top when there is no hash', () => {
    const scrollTo = vi.fn();
    window.scrollTo = scrollTo;
    render(
      <MemoryRouter initialEntries={['/about']}>
        <ScrollToHash />
      </MemoryRouter>,
    );
    expect(scrollTo).toHaveBeenCalledWith(0, 0);
  });
});
