export type PasswordStrength = 'weak' | 'fair' | 'strong' | 'very_strong';

export function getPasswordStrength(password: string): { level: PasswordStrength; score: number; label: string; color: string } {
  let score = 0;
  if (password.length >= 8) score++;
  if (password.length >= 12) score++;
  if (/[A-Z]/.test(password)) score++;
  if (/[0-9]/.test(password)) score++;
  if (/[^A-Za-z0-9]/.test(password)) score++;

  if (score <= 1) return { level: 'weak', score: 25, label: 'Weak', color: 'bg-buddy-red' };
  if (score === 2) return { level: 'fair', score: 50, label: 'Fair', color: 'bg-buddy-orange' };
  if (score === 3) return { level: 'strong', score: 75, label: 'Strong', color: 'bg-buddy-electric' };
  return { level: 'very_strong', score: 100, label: 'Very Strong', color: 'bg-buddy-green' };
}
