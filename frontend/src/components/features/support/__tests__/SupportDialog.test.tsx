import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import { SupportDialog } from '@/components/features/support/SupportDialog';

vi.mock('@/config/support', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/config/support')>();
  return {
    ...actual,
    SUPPORT_LINKS: {
      fundraiserUrl: '',
      pledgeFormUrl: '',
      gymSuiteFormUrl: '',
      trainerIntakeFormUrl: '',
      partnershipFormUrl: '',
      investorFormUrl: '',
    },
  };
});

describe('SupportDialog', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('shows a safe coming-soon state when links are unconfigured', () => {
    render(<SupportDialog open onClose={() => {}} />);
    expect(screen.getByText('Donate')).toBeDefined();
    expect(screen.getByText('Pledge Funding')).toBeDefined();
    expect(screen.getByText('Partnership Proposal for Brands')).toBeDefined();
    expect(screen.getByText('Investor Relations')).toBeDefined();
    expect(screen.getAllByText(/Coming soon/).length).toBe(4);
    expect(screen.queryByRole('link')).toBeNull();
  });
});
