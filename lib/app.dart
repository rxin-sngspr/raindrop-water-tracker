import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme_provider.dart';
import 'core/constants/app_constants.dart';
import 'data/repositories/water_repository.dart';
import 'features/home/home_screen.dart';
import 'features/history/history_screen.dart';
import 'features/achievements/achievements_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'features/settings/settings_screen.dart';

class RainDropApp extends ConsumerWidget {
  const RainDropApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themes = ref.watch(appThemeProvider);

    return MaterialApp(
      title: 'Rain Drop',
      debugShowCheckedModeBanner: false,
      theme: themes.light,
      darkTheme: themes.dark,
      themeMode: themeMode,
      home: const _MainShell(),
    );
  }
}

class _MainShell extends ConsumerStatefulWidget {
  const _MainShell();

  @override
  ConsumerState<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<_MainShell> {
  int _currentIndex = 0;
  bool _namePromptShown = false;

  final _screens = const [
    HomeScreen(),
    HistoryScreen(),
    AchievementsScreen(),
    SettingsScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeShowNamePrompt();
  }

  void _maybeShowNamePrompt() {
    if (_namePromptShown) return;
    final name = ref.read(userNameProvider);
    if (name.isEmpty || name == 'Friend') {
      _namePromptShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNameDialog();
      });
    } else {
      _namePromptShown = true;
    }
  }

  Future<void> _showNameDialog() async {
    final controller = TextEditingController();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.droplet,
                  color: colorScheme.primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome to Rain Drop',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'What should I call you?',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: AppConstants.maxNameLength,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
              ],
              decoration: InputDecoration(
                labelText: 'Your name',
                hintText: 'Enter your name',
                counterText: '',
                prefixIcon: const Icon(LucideIcons.user),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  ref
                      .read(userNameProvider.notifier)
                      .setName(value.trim());
                  Navigator.pop(ctx);
                }
              },
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 24, right: 24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    ref.read(userNameProvider.notifier).setName(name);
                    Navigator.pop(ctx);
                  }
                },
                icon: const Icon(LucideIcons.arrowRight, size: 18),
                label: const Text('Get Started'),
              ),
            ),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reducedMotion = MediaQuery.of(context).accessibleNavigation;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: reducedMotion
            ? Duration.zero
            : const Duration(milliseconds: 150),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          if (reducedMotion) return child;
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.dividerTheme.color ?? Colors.transparent,
              width: 0.5,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          height: 72,
          destinations: const [
            NavigationDestination(
              icon: Icon(LucideIcons.droplets),
              selectedIcon: Icon(LucideIcons.droplet),
              label: 'Today',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.barChart),
              selectedIcon: Icon(LucideIcons.barChart),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.trophy),
              selectedIcon: Icon(LucideIcons.trophy),
              label: 'Badges',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.settings),
              selectedIcon: Icon(LucideIcons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
