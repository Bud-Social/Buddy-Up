import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Button } from '@/components/ui/Button';

describe('Button', () => {
  it('renders with text', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeDefined();
  });

  it('applies primary variant by default', () => {
    render(<Button>Test</Button>);
    const btn = screen.getByText('Test');
    expect(btn.className).toContain('bg-buddy-green');
  });

  it('shows loading state', () => {
    render(<Button isLoading>Loading</Button>);
    const btn = screen.getByRole('button');
    expect(btn).toHaveProperty('disabled', true);
  });

  it('applies destructive variant', () => {
    render(<Button variant="destructive">Delete</Button>);
    const btn = screen.getByText('Delete');
    expect(btn.className).toContain('bg-buddy-red');
  });
});
