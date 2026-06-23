import { describe, it, expect } from 'vitest';
import { getPasswordStrength } from '@/utils/passwordStrength';

describe('getPasswordStrength', () => {
  it('rates weak password', () => {
    const result = getPasswordStrength('abc');
    expect(result.level).toBe('weak');
  });

  it('rates strong password', () => {
    const result = getPasswordStrength('Str0ng!Pass');
    expect(result.level).toBe('strong');
  });

  it('rates very strong password', () => {
    const result = getPasswordStrength('V3ry$tr0ngP@ss!');
    expect(result.level).toBe('very_strong');
  });
});
