import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/constants/app_constants.dart';
import 'data/repositories/water_repository.dart';
import 'features/home/home_screen.dart';
import 'features/history/history_screen.dart';
import 'features/settings/settings_screen.dart';

class RainDropApp extends ConsumerWidget {
  const RainDropApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final lightAccent = ref.watch(lightAccentProvider);
    final darkAccent = ref.watch(darkAccentProvider);

    return MaterialApp(
      title: 'RainDrop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightThemeFor(lightAccent),
      darkTheme: AppTheme.darkThemeFor(darkAccent),
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

  void _showNameDialog() {
    final controller = TextEditingController();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
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
              child: Icon(Icons.water_drop,
                  color: colorScheme.primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome to RainDrop',
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
                prefixIcon: const Icon(Icons.person_outline),
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
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Get Started'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
