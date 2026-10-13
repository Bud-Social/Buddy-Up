import { describe, it, expect } from 'vitest';
import { businessEntries, type BusinessRoleFlags } from '@/components/layout/sidebarBusiness';

const NONE: BusinessRoleFlags = {
  hasShop: false,
  hasEvents: false,
  gymSlug: null,
  hasStation: false,
  isCourier: false,
};

describe('businessEntries', () => {
  it('unlocks nothing when no role is held', () => {
    expect(businessEntries(NONE)).toEqual([]);
  });

  it('unlocks each destination independently', () => {
    expect(businessEntries({ ...NONE, hasShop: true }).map((e) => e.key)).toEqual(['shop']);
    expect(businessEntries({ ...NONE, hasEvents: true }).map((e) => e.key)).toEqual(['events']);
    expect(businessEntries({ ...NONE, gymSlug: 'legitgym' }).map((e) => e.key)).toEqual(['gym']);
    expect(businessEntries({ ...NONE, hasStation: true }).map((e) => e.key)).toEqual(['stations']);
    expect(businessEntries({ ...NONE, isCourier: true }).map((e) => e.key)).toEqual(['courier']);
  });

  it('builds the gym destination from the owned gym\'s slug', () => {
    expect(businessEntries({ ...NONE, gymSlug: 'legit-gym' })[0].to).toBe('/gyms/legit-gym/manage');
  });

  it('does not unlock the gym destination without a slug', () => {
    expect(businessEntries({ ...NONE, gymSlug: '' })).toEqual([]);
  });

  it('orders a multi-role operator by working priority', () => {
    const all = businessEntries({
      hasShop: true,
      hasEvents: true,
      gymSlug: 'legitgym',
      hasStation: true,
      isCourier: true,
    });
    expect(all.map((e) => e.key)).toEqual(['shop', 'events', 'gym', 'stations', 'courier']);
  });

  it('gives every destination a route, a nav label and a switcher label', () => {
    for (const entry of businessEntries({ ...NONE, hasShop: true, hasEvents: true, gymSlug: 'g', hasStation: true, isCourier: true })) {
      expect(entry.to.startsWith('/')).toBe(true);
      expect(entry.label).toBeTruthy();
      expect(entry.shortLabel).toBeTruthy();
    }
  });

  it('shortens the two labels that would otherwise wrap in the switcher', () => {
    const entries = businessEntries({ ...NONE, hasShop: true, hasEvents: true, gymSlug: 'g', hasStation: true });
    expect(entries.map((e) => e.shortLabel)).toEqual(['Shop', 'Events', 'Gym', 'Stations']);
    expect(entries.map((e) => e.label)).toEqual(['Creator Studio', 'My Events', 'My Gym', 'My Stations']);
  });
});