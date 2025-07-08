import { test, expect } from "@playwright/test";

test.describe("Smoketest", () => {
  test("home page loads and has a heading", async ({ page }) => {
    // Navigate to the home page
    await page.goto("/");

    // Wait for the page to load
    await page.waitForLoadState("networkidle");

    // Check that the page has an h3 element
    const h3 = page.getByRole("heading", {
      name: "🚀 React Router + Vite Setup Complete!",
    });
    await expect(h3).toBeVisible();

    // Verify the page title is set correctly
    await expect(page).toHaveTitle(/New React Router App/);
  });
});
