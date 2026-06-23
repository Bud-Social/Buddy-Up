import { test, expect } from '@playwright/test';

test('landing page loads', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('h1')).toContainText('fitness family');
});

test('landing page has CTA buttons', async ({ page }) => {
  await page.goto('/');
  const getStarted = page.locator('a:has-text("Get Started")');
  await expect(getStarted).toBeVisible();
});

test('landing page has value prop cards', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('text=Find Your Buddy')).toBeVisible();
  await expect(page.locator('text=Live Workouts')).toBeVisible();
});

test('terms page loads', async ({ page }) => {
  await page.goto('/terms');
  await expect(page.locator('h1')).toContainText('Terms of Service');
});

test('privacy page loads', async ({ page }) => {
  await page.goto('/privacy');
  await expect(page.locator('h1')).toContainText('Privacy Policy');
});

test('community guidelines page loads', async ({ page }) => {
  await page.goto('/community-guidelines');
  await expect(page.locator('h1')).toContainText('Community Guidelines');
});
