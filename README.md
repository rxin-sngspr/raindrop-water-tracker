# RainDrop

> Your daily hydration companion. Track, visualize, and stay on top of your water intake.

A cross-platform Flutter water intake tracker with Material Design 3, dark/light mode with multiple accent colors, interactive progress ring, monthly bar charts, Android home screen widget, and daily hydration reminders.

---

## Features

### Core Tracking
- **Quick-add water logging** -- Preset buttons (200ml, 350ml, 500ml) plus custom amount entry
- **Interactive progress ring** -- Animated circular ring with glow effect showing daily progress
- **Personalized greeting** -- Enter your name on first launch for a tailored experience
- **Undo last entry** -- Mistaken tap? Undo your last logged entry instantly
- **Daily goal management** -- Adjustable slider from 500ml to 5000ml

### History & Analytics
- **Monthly bar charts** -- Visualize your hydration patterns with fl_chart
- **Goal line overlay** -- Dashed line on charts showing your daily target
- **Average daily intake** -- See your average consumption across tracked days
- **Daily notes** -- Tap any day on the chart to add or edit personal notes
- **Color-coded bars** -- Green bars for goal-reached days, blue for below goal

### Themes & Appearance
- **Material Design 3** -- Modern UI with dynamic color schemes
- **Dark / Light / System mode** -- Follow your system preference or choose manually
- **Light mode accents** -- Default Blue, Soft Lavender, Warm Sand
- **Dark mode accents** -- Deep Navy, Midnight Black, Charcoal, Maroon
- **Custom typography** -- Inter font family for clean readability
- **Animated transitions** -- Smooth entry animations for water log tiles

### Platform Features
- **Android home screen widget** -- Check your progress without opening the app
- **Daily reminders** -- Morning and evening motivational notifications
- **Cross-platform** -- Android, iOS, Windows, and Web from a single codebase

### Data & Feedback
- **Local storage** -- All data persisted locally via Hive (no account needed)
- **Feedback system** -- Send star ratings and comments via Formspree
- **Reset data** -- Clear all history with a single tap
- **Input validation** -- Smart limits on names, entry amounts, and daily totals

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x + Dart 3.x |
| State Management | Riverpod 2.x (StateNotifier + Provider) |
| Local Storage | Hive + hive_flutter |
| Charts | fl_chart |
| Local Notifications | flutter_local_notifications |
| Home Widget | home_widget (Android) |
| Typography | Google Fonts (Inter) |
| HTTP Client | http (Formspree feedback) |
| Android | Kotlin, Android SDK 34+ |
| iOS | Swift, iOS 12+ |
| Windows | C++ via Flutter desktop |
| Web | HTML5 Canvas (canvaskit/skwasm) |

---

## Architecture

The project follows a **feature-first clean architecture** pattern:

```
lib/
  core/           -- Shared infrastructure
    constants/    -- App-wide constants
    services/     -- Notifications, widget updates
    theme/        -- MD3 themes, color palettes
    utils/        -- Date formatting helpers
  data/
    models/       -- Data entities (WaterEntry)
    repositories/ -- Riverpod providers, business logic
    storage/      -- Hive persistence layer
  features/
    home/         -- Today's intake, progress ring, quick add
    history/      -- Monthly charts, daily notes, averages
    settings/     -- Name, goal, theme, feedback, data management
  shared/
    widgets/      -- Reusable UI components
  app.dart        -- App shell with navigation
  main.dart       -- Entry point
```

### Data Flow

1. **HiveStorage** handles all local persistence (entries, settings, notes)
2. **Riverpod providers** expose reactive state to the UI layer
3. **Widgets** consume providers and rebuild automatically on state changes
4. **Notifications** and **widget updates** are triggered through dedicated service classes

---

## Screenshots

Screenshots and demo videos are available on the [project portfolio page](https://rxin-sngspr.github.io/johnsangaspar-portfolio/work.html).

---

## Getting Started

### Prerequisites

- Flutter SDK 3.12+ ([install guide](https://docs.flutter.dev/get-started/install))
- Dart 3.x (bundled with Flutter)
- Android Studio or VS Code with Flutter plugins

### Installation

```bash
# Clone the repository
git clone https://github.com/rxin-sngspr/raindrop-water-tracker.git

# Navigate to the project
cd raindrop-water-tracker

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build for Release

```bash
# Android APK
flutter build apk --release

# iOS (requires macOS + Xcode)
flutter build ios --release

# Web
flutter build web

# Windows
flutter build windows --release
```

---

## About the Developer

Built by [John Pheter San Gaspar](https://rxin-sngspr.github.io/johnsangaspar-portfolio/), an Executive Operations Partner and full-stack developer based in the Philippines. John combines operational excellence with technical craftsmanship to build tools that make daily life better.

- Portfolio: [rxin-sngspr.github.io/johnsangaspar-portfolio](https://rxin-sngspr.github.io/johnsangaspar-portfolio/)
- LinkedIn: [linkedin.com/in/ea-johnsngspr](https://linkedin.com/in/ea-johnsngspr)
- Email: rainsngspr@gmail.com

---

## License

MIT License. See [LICENSE](LICENSE) for details.

---

*Stay hydrated. Stay healthy.*
