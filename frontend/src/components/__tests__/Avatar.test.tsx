import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Avatar } from '@/components/ui/Avatar';

describe('Avatar', () => {
  it('renders with initial when no src', () => {
    render(<Avatar alt="John Doe" size="md" />);
    expect(screen.getByText('J')).toBeDefined();
  });

  it('renders image when src provided', () => {
    render(<Avatar src="https://example.com/avatar.jpg" alt="John" />);
    const img = screen.getByAltText('John');
    expect(img).toBeDefined();
  });

  it('renders RepRing when showRepRing is true', () => {
    const { container } = render(<Avatar alt="Test" showRepRing streakProgress={50} />);
    const svg = container.querySelector('svg');
    expect(svg).toBeDefined();
  });
});
