// @ts-check
const { test, expect } = require('@playwright/test');

const APP_URL = 'http://localhost:3001';

test.describe('Rain Drop - Water Tracker', () => {

  test('take screenshots of app for visual review', async ({ page }) => {
    // Set a reasonable viewport
    await page.setViewportSize({ width: 430, height: 932 });

    // Navigate and wait for the page to fully load
    await page.goto(APP_URL, { waitUntil: 'networkidle' });
    
    // Flutter web takes time to initialize and render
    // Wait for the main Flutter engine canvas to appear
    await page.waitForTimeout(8000);

    // Take screenshot at this point - should show splash or main screen
    await page.screenshot({ 
      path: 'screenshots/01-initial-load.png',
      fullPage: true 
    });
    console.log('Captured: 01-initial-load.png');
    
    // Wait longer for splash to finish and app to render
    await page.waitForTimeout(5000);
    
    // Take screenshot of the rendered app
    await page.screenshot({ 
      path: 'screenshots/02-app-rendered.png',
      fullPage: true 
    });
    console.log('Captured: 02-app-rendered.png');

    // Verify the page loaded (should have some content)
    const content = await page.content();
    expect(content.length).toBeGreaterThan(0);
  });

  test('desktop viewport screenshot', async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 900 });
    await page.goto(APP_URL, { waitUntil: 'networkidle' });
    await page.waitForTimeout(10000);
    
    await page.screenshot({ 
      path: 'screenshots/03-desktop-view.png',
      fullPage: true 
    });
    console.log('Captured: 03-desktop-view.png');
  });

  test('capture page source for debugging', async ({ page }) => {
    await page.goto(APP_URL, { waitUntil: 'networkidle' });
    await page.waitForTimeout(8000);
    
    // Log what's on the page for debugging
    const title = await page.title();
    console.log('Page title:', title);
    
    // Check for Flutter-specific elements
    const hasFlutterScene = await page.$('flt-scene');
    const hasCanvas = await page.$('canvas');
    console.log('Has flt-scene:', !!hasFlutterScene);
    console.log('Has canvas:', !!hasCanvas);
    
    if (hasFlutterScene) {
      const isVisible = await hasFlutterScene.isVisible();
      console.log('flt-scene visible:', isVisible);
    }
    
    // Take a debug screenshot
    await page.screenshot({ 
      path: 'screenshots/04-debug-screenshot.png',
      fullPage: true 
    });
    console.log('Captured: 04-debug-screenshot.png');
  });
});
