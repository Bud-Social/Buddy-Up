import { describe, it, expect } from 'vitest';
import { matchRoutes } from 'react-router-dom';
import { router } from '@/router';

/**
 * Route-registration regression guard.
 *
 * Several pages and sidebar entries link to destinations that were never
 * registered — `CreatorStudio` navigated to `/marketplace/shops/create`, and
 * `GymDetail`'s "Manage" button pointed at `/gyms/:slug/manage`. Both fell
 * through to the catch-all and silently landed the user somewhere else. These
 * assertions pin the paths the role dashboards and seller hub depend on, so a
 * future rename cannot quietly reintroduce a dead link.
 */
const routes = router.routes;

function resolve(path: string): string | null {
  const match = matchRoutes(routes, path);
  return match ? match[match.length - 1].route.path : null;
}

describe('route registration', () => {
  it.each([
    ['/marketplace/events', '/marketplace/events'],
    ['/marketplace/events/create', '/marketplace/events/create'],
    ['/marketplace/events/my-tickets', '/marketplace/events/my-tickets'],
    ['/marketplace/events/abc-123', '/marketplace/events/:eventId'],
    ['/marketplace/stations', '/marketplace/stations'],
    ['/marketplace/delivery', '/marketplace/delivery'],
    ['/marketplace/delivery/register', '/marketplace/delivery/register'],
  ])('registers %s', (path, expected) => {
    expect(resolve(path)).toBe(expected);
  });

  it('keeps the organiser hub from being swallowed by the event detail route', () => {
    // `/marketplace/events` is a static sibling of `/marketplace/events/:eventId`;
    // react-router must rank the static segment first.
    expect(resolve('/marketplace/events')).not.toBe('/marketplace/events/:eventId');
  });

  it('wires up the two dead shop links', () => {
    // `CreatorStudio` → "Set up a custom shop" / "+ New Shop".
    expect(resolve('/marketplace/shops/create')).toBe('/marketplace/shops/create');
    // `MyShops` page.
    expect(resolve('/marketplace/shops')).toBe('/marketplace/shops');
  });

  it('registers the gym manage page GymDetail links to', () => {
    expect(resolve('/gyms/legitgym')).toBe('/gyms/:slug');
    expect(resolve('/gyms/legitgym/manage')).toBe('/gyms/:slug/manage');
  });

  it('keeps every destination the sidebar business entries link to routable', () => {
    for (const path of ['/marketplace/creator', '/marketplace/events', '/marketplace/stations', '/marketplace/delivery', '/gyms/some-gym/manage']) {
      expect(resolve(path)).not.toBeNull();
    }
  });
});