import { test, expect } from '@playwright/test';

test.describe('Authenticated Flows', () => {
  test('user can log in and navigate to feed', async ({ page }) => {
    await page.goto('/login');
    
    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="password"]', 'TestPassword123!');
    await page.click('button[type="submit"]');
    
    await expect(page).toHaveURL('/feed');
    await expect(page.locator('h1')).toContainText(/feed/i);
  });

  test('user can navigate to health insights', async ({ page }) => {
    await page.goto('/login');
    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="password"]', 'TestPassword123!');
    await page.click('button[type="submit"]');
    
    await page.goto('/health-insights');
    await expect(page.locator('h1')).toContainText('Health Insights');
    await expect(page.locator('button:has-text("Weekly")')).toBeVisible();
    await expect(page.locator('button:has-text("Monthly")')).toBeVisible();
  });

  test('user can navigate to workout form analyzer', async ({ page }) => {
    await page.goto('/login');
    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="password"]', 'TestPassword123!');
    await page.click('button[type="submit"]');
    
    await page.goto('/workout-form');
    await expect(page.locator('h1')).toContainText('Form Analyzer');
    await expect(page.locator('button:has-text("Camera")')).toBeVisible();
    await expect(page.locator('button:has-text("Upload")')).toBeVisible();
  });

  test('user can view profile page', async ({ page }) => {
    await page.goto('/login');
    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="password"]', 'TestPassword123!');
    await page.click('button[type="submit"]');
    
    await page.goto('/profile');
    await expect(page.locator('h1')).toContainText(/profile/i);
  });

  test('user can view buddies page', async ({ page }) => {
    await page.goto('/login');
    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="password"]', 'TestPassword123!');
    await page.click('button[type="submit"]');
    
    await page.goto('/buddies');
    await expect(page.locator('h1')).toContainText(/buddies/i);
  });

  test('user can view marketplace', async ({ page }) => {
    await page.goto('/login');
    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="password"]', 'TestPassword123!');
    await page.click('button[type="submit"]');
    
    await page.goto('/marketplace');
    await expect(page.locator('h1')).toContainText(/marketplace/i);
  });

  test('unauthenticated user is redirected to login', async ({ page }) => {
    await page.goto('/feed');
    await expect(page).toHaveURL('/login');
  });

  test('unauthenticated user cannot access health insights', async ({ page }) => {
    await page.goto('/health-insights');
    await expect(page).toHaveURL('/login');
  });

  test('unauthenticated user cannot access workout form', async ({ page }) => {
    await page.goto('/workout-form');
    await expect(page).toHaveURL('/login');
  });
});