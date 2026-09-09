import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Toggle } from '@/components/ui/Toggle';
import { useState } from 'react';

function Controlled({ disabled = false }: { disabled?: boolean }) {
  const [checked, setChecked] = useState(false);
  return (
    <Toggle
      checked={checked}
      onCheckedChange={setChecked}
      label="Show activity status"
      disabled={disabled}
    />
  );
}

describe('Toggle', () => {
  it('renders as a switch with accessible state and name', () => {
    render(<Toggle checked onCheckedChange={() => {}} label="Mature content" />);
    const el = screen.getByRole('switch', { name: 'Mature content' });
    expect(el).toHaveAttribute('aria-checked', 'true');
  });

  it('reflects unchecked state', () => {
    render(<Toggle checked={false} onCheckedChange={() => {}} label="X" />);
    expect(screen.getByRole('switch', { name: 'X' })).toHaveAttribute('aria-checked', 'false');
  });

  it('calls onCheckedChange with the next state on click', async () => {
    const user = userEvent.setup();
    let next: boolean | undefined;
    render(<Toggle checked={false} onCheckedChange={(v) => (next = v)} label="X" />);
    await user.click(screen.getByRole('switch', { name: 'X' }));
    expect(next).toBe(true);
  });

  it('toggles a controlled instance via click', async () => {
    const user = userEvent.setup();
    render(<Controlled />);
    const el = screen.getByRole('switch', { name: 'Show activity status' });
    expect(el).toHaveAttribute('aria-checked', 'false');
    await user.click(el);
    expect(el).toHaveAttribute('aria-checked', 'true');
  });

  it('activates with the keyboard (Space and Enter)', async () => {
    const user = userEvent.setup();
    render(<Controlled />);
    const el = screen.getByRole('switch', { name: 'Show activity status' });
    el.focus();
    await user.keyboard(' ');
    expect(el).toHaveAttribute('aria-checked', 'true');
    await user.keyboard('{Enter}');
    expect(el).toHaveAttribute('aria-checked', 'false');
  });

  it('does not fire when disabled', async () => {
    const user = userEvent.setup();
    let next: boolean | undefined;
    render(
      <Toggle checked={false} onCheckedChange={(v) => (next = v)} label="X" disabled />,
    );
    const el = screen.getByRole('switch', { name: 'X' });
    expect(el).toBeDisabled();
    await user.click(el);
    expect(next).toBeUndefined();
  });

  it('applies 40% opacity styling when disabled', () => {
    render(<Toggle checked={false} onCheckedChange={() => {}} label="X" disabled />);
    expect(screen.getByRole('switch', { name: 'X' }).className).toContain('opacity-40');
  });
});
