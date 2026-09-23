import { describe, expect, it } from 'vitest';
import {
  getSupportLinks,
  isGymSuiteConfigured,
  isSupportConfigured,
  isTrainerIntakeConfigured,
} from '@/config/support';

describe('support links', () => {
  it('reads and trims configured URLs', () => {
    const links = getSupportLinks({
      VITE_FUNDRAISER_URL: ' https://example.com/fund ',
      VITE_PLEDGE_FORM_URL: 'https://example.com/pledge',
      VITE_GYM_SUITE_FORM_URL: 'https://example.com/gym',
      VITE_TRAINER_INTAKE_FORM_URL: 'https://example.com/trainers',
      VITE_PARTNERSHIP_FORM_URL: 'https://example.com/partners',
      VITE_INVESTOR_FORM_URL: 'https://example.com/invest',
    });
    expect(links).toEqual({
      fundraiserUrl: 'https://example.com/fund',
      pledgeFormUrl: 'https://example.com/pledge',
      gymSuiteFormUrl: 'https://example.com/gym',
      trainerIntakeFormUrl: 'https://example.com/trainers',
      partnershipFormUrl: 'https://example.com/partners',
      investorFormUrl: 'https://example.com/invest',
    });
    expect(isSupportConfigured(links)).toBe(true);
    expect(isGymSuiteConfigured(links)).toBe(true);
    expect(isTrainerIntakeConfigured(links)).toBe(true);
  });

  it('treats missing URLs as unconfigured', () => {
    const links = getSupportLinks({});
    expect(links).toEqual({
      fundraiserUrl: '',
      pledgeFormUrl: '',
      gymSuiteFormUrl: '',
      trainerIntakeFormUrl: '',
      partnershipFormUrl: '',
      investorFormUrl: '',
    });
    expect(isSupportConfigured(links)).toBe(false);
    expect(isGymSuiteConfigured(links)).toBe(false);
    expect(isTrainerIntakeConfigured(links)).toBe(false);
  });
});
