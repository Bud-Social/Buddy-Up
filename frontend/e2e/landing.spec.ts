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

test('landing navbar links to about, careers, contact', async ({ page }) => {
  await page.goto('/');
  const nav = page.locator('nav[aria-label="Primary"]');
  await expect(nav.getByText('About Us')).toBeVisible();
  await expect(nav.getByText('Careers')).toBeVisible();
  await expect(nav.getByText('Contact Us')).toBeVisible();
});

test('careers page loads with roles and form', async ({ page }) => {
  await page.goto('/careers');
  await expect(page.locator('h1')).toContainText('fitness family');
  await expect(page.getByText('Founding Mobile Engineer').first()).toBeVisible();
});

test('contact page loads with form', async ({ page }) => {
  await page.goto('/contact');
  await expect(page.locator('h1')).toContainText('human');
  await expect(page.getByRole('button', { name: 'Send message' })).toBeVisible();
});

test('services page loads with all eight services', async ({ page }) => {
  await page.goto('/services');
  await expect(page.locator('h1')).toContainText('in one place');
  await expect(page.getByText('Activity Analytics').first()).toBeVisible();
  await expect(page.getByText('Training Programmes').first()).toBeVisible();
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
