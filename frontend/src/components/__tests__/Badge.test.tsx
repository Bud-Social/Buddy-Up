import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Badge } from '@/components/ui/Badge';

describe('Badge', () => {
  it('renders with label', () => {
    render(<Badge variant="green" label="Verified" />);
    expect(screen.getByText('Verified')).toBeDefined();
  });

  it('renders with icon', () => {
    render(<Badge variant="gold" label="Premium" icon="✓" />);
    expect(screen.getByText('✓')).toBeDefined();
    expect(screen.getByText('Premium')).toBeDefined();
  });
});
