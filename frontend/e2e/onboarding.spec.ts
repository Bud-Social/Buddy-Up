import { test, expect } from '@playwright/test';

test.describe('Onboarding Flow', () => {
  test('user can complete onboarding steps', async ({ page }) => {
    await page.goto('/onboarding');
    
    expect(await page.locator('h1').textContent()).toContain('Goals');
    expect(await page.locator('p:has-text("Step 1 of")').isVisible()).toBe(true);
    
    await page.click('button:has-text("Weight Loss")');
    await page.click('button:has-text("Next")');
    
    await expect(page.locator('p:has-text("Step 2 of")')).toBeVisible();
    await page.click('button:has-text("Moderately Active")');
    await page.click('button:has-text("Next")');
    
    await expect(page.locator('p:has-text("Step 3 of")')).toBeVisible();
    await page.click('button:has-text("Weights")');
    await page.click('button:has-text("Next")');
    
    await expect(page.locator('p:has-text("Step 4 of")')).toBeVisible();
    await page.click('button:has-text("None")');
    await page.click('button:has-text("Next")');
    
    await expect(page.locator('p:has-text("Step 5 of")')).toBeVisible();
    await page.click('button:has-text("Morning")');
    
    await expect(page.locator('button:has-text("Complete Setup")')).toBeVisible();
  });
});