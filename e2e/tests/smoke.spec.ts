import { test, expect } from '@playwright/test';

test('Adminer odpowiada', async ({ page }) => {
  const res = await page.goto('http://localhost:8080');
  expect(res?.status()).toBe(200);
  await expect(page.locator('body')).toContainText(/Adminer/i);
});

test('Laravel welcome page', async ({ page }) => {
  const res = await page.goto('http://localhost:8000');
  expect(res?.status()).toBe(200);
  await expect(page.locator('body')).toContainText(/Laravel/i);
});

test('Symfony welcome page', async ({ page }) => {
  const res = await page.goto('http://localhost:8001');
  expect(res?.status()).toBe(200);
});
