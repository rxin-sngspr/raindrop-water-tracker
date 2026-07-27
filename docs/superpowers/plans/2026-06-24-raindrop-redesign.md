# Rain Drop Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform the "Kira" water tracker into "Rain Drop" with a complete UI overhaul, new theme system, streak/achievement mechanics, smart notifications, home widget improvements, and micro-animations.

**Architecture:** Feature-first Flutter architecture with Riverpod state, Hive storage. 5 implementation phases: Foundation → Core UI → Logic & Notifications → Polish → QA.

**Tech Stack:** Flutter 3.x, Dart 3.x, Riverpod 2.x, Hive, fl_chart, flutter_local_notifications, home_widget, lottie/rive (Phase 4), confetti (Phase 4)

**Spec reference:** `C:\Users\LENOVO\drafts\raindrop-spec.md` (1588 lines)

**Theme note:** The architect should determine the final color palette using expert judgment — not strictly following the pink-purple example in the spec. Use ColorScheme.fromSeed() with the best seed color for a premium wellness app feel. Research competing hydration/wellness apps for palette inspiration.

---

### Phase 1: Foundation — Theme System, Models, Rename

**Files:**
- Create: `lib/core/theme/raindrop_theme.dart`
- Modify: `lib/core/theme/theme_provider.dart`
- Modify: `lib/core/constants/app_constants.dart`
- Modify: `lib/app.dart`
- Modify: `lib/main.dart`
- Modify: `pubspec.yaml`
- Create: `lib/data/models/streak.dart`
- Create: `lib/data/models/achievement.dart`
- Modify: `lib/data/repositories/water_repository.dart`
- Modify: `lib/data/storage/hive_storage.dart`

- [ ] **Step 1: Create unified theme system**

Create `lib/core/theme/raindrop_theme.dart` replacing the old `app_theme.dart`. Use `ColorScheme.fromSeed()` for a single light + dark pair. Remove the 7-accent picker system. Define all color tokens, typography (Plus Jakarta Sans for headings + Inter for body), spacing scale, border radius, elevation, and animation tokens. The architect/designer should choose the seed color based on what makes the best premium wellness app — research competitors and pick deliberately.

- [ ] **Step 2: Simplify theme provider**

Modify `lib/core/theme/theme_provider.dart` to only offer light/dark/system mode. Remove `LightAccent` and `DarkAccent` enum providers. Keep `themeModeProvider`, remove `lightAccentProvider` and `darkAccentProvider`.

- [ ] **Step 3: Create Streak model**

Create `lib/data/models/streak.dart`:
```dart
class Streak {
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActiveDate;
  final List<DateTime> streakDates;
  
  // with copyWith, toJson, fromJson, factory
}
```

- [ ] **Step 4: Create Achievement model**

Create `lib/data/models/achievement.dart` with 12 built-in achievements:
- FirstWeek (7 consecutive days), TwoWeek (14), ThirtyDay (30)
- HundredGlasses, HalfGallon (1890ml in a day), GallonClub (3780ml)
- EarlyBird (log before 8 AM x5), NightOwl (log after 10 PM x3)
- SteadySip (7 days straight), HydrationHero (30 days), WaterWizard (365 days)
- PerfectWeek (hit goal every day for a week)

Each with id, title, description, icon, targetCount, type (streak/volume/special), progress getter.

- [ ] **Step 5: Extend storage layer**

Add `streakProvider`, `achievementsProvider` and related Riverpod providers to `water_repository.dart`. Add save/load methods to `hive_storage.dart`.

- [ ] **Step 6: Rename app to "Rain Drop"**

Update `pubspec.yaml` description. Update `main.dart` loading screen text from "Kira" to "Rain Drop". Update `app.dart` title. Update all references in settings, notifications, and constants.

- [ ] **Step 7: Update version to 2.0.0**

`pubspec.yaml` version field, settings screen display.

---

### Phase 2: Core UI Redesign

**Files:**
- Modify: `lib/app.dart` — new nav, crossfade tabs
- Modify: `lib/features/home/home_screen.dart` — complete rewrite
- Modify: `lib/features/history/history_screen.dart` — enhanced
- Create: `lib/features/achievements/achievements_screen.dart` — new
- Modify: `lib/features/settings/settings_screen.dart` — simplified
- Modify: `lib/shared/widgets/` — new shared components

- [ ] **Step 1: Redesign app shell**

Update `app.dart` with new purple-theme navigation bar. Replace `IndexedStack` with `AnimatedSwitcher` + `FadeTransition` for tab switching (300ms). Add 4th tab: Achievements.

- [ ] **Step 2: Rewrite home screen**

New layout order: Streak banner (top) → Compact greeting + name → Progress ring (animated fill, 1000ms easeInOutQuint) → Quick-add pills (200/350/500ml, scale press feedback) → Status card (remaining ml or goal reached celebration) → Water log tiles (slide in + fade, 400ms). Empty state with illustration + prompt. All components use the new theme tokens.

- [ ] **Step 3: Enhance history screen**

Summary card (avg intake, best day, streak info). Color-coded bar chart (green=goal met, purple=below goal line). Goal line overlay as dashed line. Tap day for notes dialog. Smooth chart transitions.

- [ ] **Step 4: Create achievements screen**

3-column badge grid. Locked/unlocked visual states. Current streak counter at top. 12 badges with emoji icons, progress bars for in-progress ones. Empty state if no achievements yet.

- [ ] **Step 5: Simplify settings screen**

Remove accent color pickers. Keep: Name, Theme toggle (light/dark/system), Achievements entry (navigates to achievements), About (v2.0.0), Reset data. Clean layout with section dividers.

---

### Phase 3: Logic & Notifications

**Files:**
- Modify: `lib/core/services/notification_service.dart`
- Modify: `lib/data/repositories/water_repository.dart`
- Modify: `lib/data/storage/hive_storage.dart`

- [ ] **Step 1: Implement streak calculation**

Track daily totals. On each water log, check if today's total >= 800ml threshold. If yes and yesterday's date is in streakDates, increment. If gap, reset. Update longestStreak. Persist to Hive.

- [ ] **Step 2: Implement achievement checking**

On each water log and on app launch, check all achievements. If conditions met, mark as unlocked, trigger celebration notification. Persist unlocked state.

- [ ] **Step 3: Fix notification permissions**

Add proper Android 13+ `POST_NOTIFICATIONS` runtime permission flow with `requestPermissions()` call on first launch. Ensure channel is created before scheduling.

- [ ] **Step 4: Rewrite notification scheduling**

Replace current 2-reminder system with 3x daily (7AM, 12PM, 5PM). Smart skip: only schedule if user hasn't logged water in last 5 hours. Check on each app launch and cancel remaining if goal already met.

- [ ] **Step 5: Add Taglish message pool**

Create 24 randomized Taglish messages pool. Separate pools for morning (7AM), midday (12PM), evening (5PM). Random selection each time.

---

### Phase 4: Polish, Widget & Mascot Prep

**Files:**
- Modify: `lib/features/home/home_screen.dart`
- Create: `android/app/src/main/res/layout/widget_layout.xml`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `lib/core/services/widget_service.dart` (new)
- Add: `assets/animations/` (mascot asset when John provides it)

- [ ] **Step 1: Enhance Android widget**

Update widget layout to 4x2 showing: current total / goal, progress bar, "+250ml" button. Background callback on tap adds water. Guard Hive double-init. Optimistic UI update on widget.

- [ ] **Step 2: Add celebration animations**

Confetti on goal reached (confetti package, 50 particles, 3s). Streak milestone banner with glow effect. Smooth entrance for streak counter updates.

- [ ] **Step 3: Add reduced-motion support**

All animations check `MediaQuery.of(context).disableAnimations` or `prefers-reduced-motion`. Skip entrance animations, confetti, mascot bounces when reduced motion is enabled.

- [ ] **Step 4: Accessibility pass**

Add Semantics wrappers to custom widgets (quick-add pills, progress ring, streak counter, achievement badges). Ensure semantic labels exist for all interactive elements.

- [ ] **Step 5: Mascot integration (when asset ready)**

John will produce a Lottie JSON or Rive .riv of his character. Integrate into bottom-right of home screen. Idle animation loops. Trigger happy bounce on water log. Queue system: if celebrating and new water logged, bounce after celebration.

---

### Phase 5: QA & Ship

- [ ] **Step 1: Build and verify on web**

`flutter build web --release` and verify all screens render correctly.

- [ ] **Step 2: Check all animations**

Verify: tile slide-in, ring fill, tab crossfade, confetti, mascot (if available). Check with reduced motion enabled.

- [ ] **Step 3: Test streak/achievement logic**

Mock data with various scenarios: first-time user, returning user with streak, edge cases (midnight rollover).

- [ ] **Step 4: Final theme review**

Verify all 40+ color tokens render correctly in light and dark mode. Check contrast on interactive elements.

- [ ] **Step 5: Clean up old code**

Remove `app_theme.dart`, dead accent providers, old notification code. Remove temp debug statements.
