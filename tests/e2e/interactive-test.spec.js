// @ts-check
const { test, expect } = require('@playwright/test');

const APP_URL = 'http://localhost:3001';

test.describe('Rain Drop - Interactive QA Audit', () => {

  test.beforeEach(async ({ page }) => {
    // Collect all console messages
    const consoleLogs = [];
    page.on('console', msg => consoleLogs.push(`[${msg.type()}] ${msg.text()}`));
    page.on('pageerror', err => consoleLogs.push(`[ERROR] ${err.message}`));
    
    await page.setViewportSize({ width: 430, height: 932 });
    await page.goto(APP_URL, { waitUntil: 'networkidle' });
    await page.waitForTimeout(10000);
    
    // Store logs on page context for later assertions
    page.__consoleLogs = consoleLogs;
  });

  test('1. App loads without console errors', async ({ page }) => {
    // Wait for Flutter canvas to render
    await page.waitForSelector('canvas', { timeout: 15000 });
    await page.waitForTimeout(3000);
    
    const hasCanvas = await page.$('canvas');
    expect(hasCanvas).toBeTruthy();
    
    // Take screenshot of initial state
    await page.screenshot({ 
      path: 'screenshots/qa-01-initial-load.png',
      fullPage: true 
    });

    // Check for errors in console logs
    const errors = page.__consoleLogs.filter(l => l.startsWith('[ERROR]'));
    expect(errors.length).toBe(0, `Console errors found: ${errors.join(', ')}`);
  });

  test('2. Navigation bar renders and tabs are accessible', async ({ page }) => {
    await page.waitForSelector('canvas', { timeout: 15000 });
    await page.waitForTimeout(5000);

    // Look for Flutter's semantics tree
    const fltScene = await page.$('flt-scene');
    const semantics = await page.$('flt-semantics');
    
    if (semantics) {
      const text = await semantics.textContent();
      console.log('Semantics text:', text?.substring(0, 500));
    }

    // Check that the app has loaded by looking at the render tree
    const pageContent = await page.content();
    const hasFlutterBootstrap = pageContent.includes('flutter_bootstrap');
    expect(hasFlutterBootstrap).toBeTruthy();

    // Take screenshot of navigation area (bottom)
    await page.screenshot({ 
      path: 'screenshots/qa-02-nav-bar.png',
      fullPage: true 
    });
  });

  test('3. Quick-add buttons visible on home screen', async ({ page }) => {
    await page.waitForSelector('canvas', { timeout: 15000 });
    await page.waitForTimeout(8000);
    
    await page.screenshot({ 
      path: 'screenshots/qa-03-home-screen.png',
      fullPage: true 
    });
  });

  test('4. Theme switching test', async ({ page }) => {
    await page.waitForSelector('canvas', { timeout: 15000 });
    await page.waitForTimeout(8000);
    
    // Navigate to Settings (4th tab bottom nav) by clicking at bottom area
    // Flutter bottom nav has fixed positions
    const viewport = page.viewportSize();
    const navCenterY = viewport.height - 36; // ~72px nav / 2
    const tabWidth = viewport.width / 4;
    const settingsTabX = tabWidth * 3.5;
    const historyTabX = tabWidth * 1.5;
    const badgesTabX = tabWidth * 2.5;

    // Click Settings tab
    await page.mouse.click(settingsTabX, navCenterY);
    await page.waitForTimeout(3000);
    await page.screenshot({ 
      path: 'screenshots/qa-04-settings-light.png',
      fullPage: true 
    });

    // Toggle dark mode if possible - click on dark mode option
    // The dark mode option would be at approx 1/3 down the screen
    await page.mouse.click(viewport.width / 2, 420);
    await page.waitForTimeout(2000);
    await page.screenshot({ 
      path: 'screenshots/qa-05-settings-dark-attempt.png',
      fullPage: true 
    });

    // Go to History tab
    await page.mouse.click(historyTabX, navCenterY);
    await page.waitForTimeout(3000);
    await page.screenshot({ 
      path: 'screenshots/qa-06-history-screen.png',
      fullPage: true 
    });

    // Go to Badges tab
    await page.mouse.click(badgesTabX, navCenterY);
    await page.waitForTimeout(3000);
    await page.screenshot({ 
      path: 'screenshots/qa-07-badges-screen.png',
      fullPage: true 
    });
  });

  test('5. Desktop viewport test', async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 900 });
    await page.goto(APP_URL, { waitUntil: 'networkidle' });
    await page.waitForTimeout(12000);
    
    await page.screenshot({ 
      path: 'screenshots/qa-08-desktop-viewport.png',
      fullPage: true 
    });

    // Check for horizontal scroll
    const scrollWidth = await page.evaluate(() => document.documentElement.scrollWidth);
    const clientWidth = await page.evaluate(() => document.documentElement.clientWidth);
    expect(scrollWidth).toBeLessThanOrEqual(clientWidth + 5);
  });

  test('6. Small mobile viewport test (375px)', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 812 });
    await page.goto(APP_URL, { waitUntil: 'networkidle' });
    await page.waitForTimeout(12000);
    
    await page.screenshot({ 
      path: 'screenshots/qa-09-mobile-375px.png',
      fullPage: true 
    });

    // Check no horizontal scroll at mobile
    const scrollWidth = await page.evaluate(() => document.documentElement.scrollWidth);
    const clientWidth = await page.evaluate(() => document.documentElement.clientWidth);
    expect(scrollWidth).toBeLessThanOrEqual(clientWidth + 5);
  });

  test('7. Tab navigation via keyboard', async ({ page }) => {
    await page.waitForSelector('canvas', { timeout: 15000 });
    await page.waitForTimeout(8000);
    
    // Try using the Flutter semantics tree for accessibility
    const hasSemantics = await page.$('flt-semantics');
    if (hasSemantics) {
      // Flutter with semantics enabled exposes the accessibility tree
      const semanticsContent = await page.evaluate(() => {
        // Query all semantic nodes
        const nodes = document.querySelectorAll('flt-semantics');
        return Array.from(nodes).map(n => {
          const rect = n.getBoundingClientRect();
          return {
            tag: n.tagName,
            text: n.textContent?.substring(0, 100),
            x: rect.x,
            y: rect.y,
            width: rect.width,
            height: rect.height
          };
        });
      });
      console.log('Semantics nodes found:', semanticsContent.length);
    } else {
      console.log('No flt-semantics found (semantics disabled)');
    }
    
    await page.screenshot({ 
      path: 'screenshots/qa-10-keyboard-nav.png',
      fullPage: true 
    });
  });

  test('8. Quick add water interaction test', async ({ page }) => {
    await page.waitForSelector('canvas', { timeout: 15000 });
    await page.waitForTimeout(8000);
    
    // Try to interact with the app by clicking where quick-add buttons should be
    // Quick-add buttons are in a row below the progress section
    // Approximate positions based on layout:
    // - 200ml, 350ml, 500ml pills in a row
    // - Custom Amount button below them

    // Take initial screenshot
    await page.screenshot({ 
      path: 'screenshots/qa-11-before-add.png',
      fullPage: true 
    });

    // Click in the quick-add area (approximately middle of screen, upper half)
    const viewport = page.viewportSize();
    // Quick add section is roughly at 40-50% from top
    await page.mouse.click(viewport.width * 0.3, viewport.height * 0.42);
    await page.waitForTimeout(2000);
    
    await page.screenshot({ 
      path: 'screenshots/qa-12-after-add.png',
      fullPage: true 
    });
  });

  test('9. Console error check across all screens', async ({ page }) => {
    const errors = [];
    page.on('pageerror', err => errors.push(err.message));
    page.on('console', msg => {
      if (msg.type() === 'error') errors.push(`[console.error] ${msg.text()}`);
    });

    await page.waitForSelector('canvas', { timeout: 15000 });
    await page.waitForTimeout(8000);

    // Navigate through all 4 tabs using coordinates
    const viewport = page.viewportSize();
    const navY = viewport.height - 36;
    const tabPositions = [0.5, 1.5, 2.5, 3.5].map(i => i * (viewport.width / 4));
    
    for (let i = 0; i < tabPositions.length; i++) {
      await page.mouse.click(tabPositions[i], navY);
      await page.waitForTimeout(3000);
      console.log(`Navigated to tab ${i}, errors so far: ${errors.length}`);
    }

    expect(errors.length).toBe(0, `Errors found: ${errors.join('\n')}`);
  });
});
