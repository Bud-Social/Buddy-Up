import { describe, it, expect } from 'vitest';
import { calculateAge, isUser16Plus, isUserAdult } from '@/utils/ageCheck';

describe('ageCheck', () => {
  it('calculates age correctly', () => {
    const dob = new Date(2000, 5, 15);
    const age = calculateAge(dob);
    expect(age).toBeGreaterThanOrEqual(24);
  });

  it('detects 16+ users', () => {
    const dob = new Date(2010, 0, 1);
    expect(isUser16Plus(dob)).toBe(true);
  });

  it('detects adult users', () => {
    const dob = new Date(2000, 0, 1);
    expect(isUserAdult(dob)).toBe(true);
  });

  it('blocks under-16', () => {
    const dob = new Date(2015, 0, 1);
    expect(isUser16Plus(dob)).toBe(false);
  });
});
