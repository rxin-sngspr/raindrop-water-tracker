import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/repositories/water_repository.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _saveName() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      ref.read(userNameProvider.notifier).setName(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final today = ref.watch(todayProvider);
    final currentTheme = ref.watch(themeModeProvider);
    final userName = ref.watch(userNameProvider);

    // Sync controller with provider value
    if (userName != _nameController.text) {
      _nameController.text = userName;
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Settings', style: theme.textTheme.headlineLarge),
                    const SizedBox(height: 20),

                    // Your Name
                    _SettingsCard(
                      children: [
                        _CardHeader(
                          icon: Icons.person_outline,
                          label: 'Your Name',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          maxLength: AppConstants.maxNameLength,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z\s]')),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Name',
                            hintText: 'Enter your name',
                            counterText: '',
                            prefixIcon:
                                const Icon(Icons.person_outline),
                          ),
                          onFieldSubmitted: (value) {
                            _saveName();
                            _nameFocusNode.unfocus();
                          },
                          onTapOutside: (_) {
                            _saveName();
                            _nameFocusNode.unfocus();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Daily Water Goal
                    _SettingsCard(
                      children: [
                        _CardHeader(
                          icon: Icons.flag_outlined,
                          label: 'Daily Water Goal',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Set your daily hydration target',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              '${AppConstants.minDailyGoalMl}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Expanded(
                              child: Slider(
                                value: today.goal.toDouble(),
                                min: AppConstants.minDailyGoalMl
                                    .toDouble(),
                                max: AppConstants.maxDailyGoalMl
                                    .toDouble(),
                                divisions: 9,
                                label: '${today.goal} ml',
                                onChanged: (value) {
                                  ref
                                      .read(todayProvider.notifier)
                                      .setGoal(value.toInt());
                                },
                              ),
                            ),
                            Text(
                              '${AppConstants.maxDailyGoalMl}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.secondary,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              '${today.goal} ml',
                              style:
                                  theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Appearance
                    _SettingsCard(
                      children: [
                        _CardHeader(
                          icon: Icons.palette_outlined,
                          label: 'Appearance',
                        ),
                        const SizedBox(height: 16),
                        _ThemeOption(
                          icon: Icons.brightness_auto,
                          label: 'Follow system',
                          selected: currentTheme == ThemeMode.system,
                          onTap: () => ref
                              .read(themeModeProvider.notifier)
                              .setTheme(ThemeMode.system),
                        ),
                        Divider(
                          height: 1,
                          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                        _ThemeOption(
                          icon: Icons.light_mode,
                          label: 'Light',
                          selected: currentTheme == ThemeMode.light,
                          onTap: () => ref
                              .read(themeModeProvider.notifier)
                              .setTheme(ThemeMode.light),
                        ),
                        Divider(
                          height: 1,
                          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                        _ThemeOption(
                          icon: Icons.dark_mode,
                          label: 'Dark',
                          selected: currentTheme == ThemeMode.dark,
                          onTap: () => ref
                              .read(themeModeProvider.notifier)
                              .setTheme(ThemeMode.dark),
                        ),
                        const SizedBox(height: 16),

                        // Light accent picker
                        _AccentSection<LightAccent>(
                          label: 'Light mode color',
                          isActive: currentTheme == ThemeMode.light ||
                              (currentTheme == ThemeMode.system &&
                                  WidgetsBinding.instance.platformDispatcher.platformBrightness != Brightness.dark),
                          current: ref.watch(lightAccentProvider),
                          options: const [
                            _AccentChip(LightAccent.blue, 'Default Blue', Color(0xFF0A84FF)),
                            _AccentChip(LightAccent.lavender, 'Soft Lavender', Color(0xFF8B7BD6)),
                            _AccentChip(LightAccent.sand, 'Warm Sand', Color(0xFFC28B5E)),
                          ],
                          onSelect: (accent) => ref.read(lightAccentProvider.notifier).setAccent(accent),
                        ),
                        const SizedBox(height: 12),

                        // Dark accent picker
                        _AccentSection<DarkAccent>(
                          label: 'Dark mode color',
                          isActive: currentTheme == ThemeMode.dark ||
                              (currentTheme == ThemeMode.system &&
                                  WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark),
                          current: ref.watch(darkAccentProvider),
                          options: const [
                            _AccentChip(DarkAccent.navy, 'Deep Navy', Color(0xFF4A9EFF)),
                            _AccentChip(DarkAccent.black, 'Midnight Black', Color(0xFF6B7280)),
                            _AccentChip(DarkAccent.charcoal, 'Charcoal', Color(0xFF8E8E93)),
                            _AccentChip(DarkAccent.maroon, 'Maroon', Color(0xFFBF5B5B)),
                          ],
                          onSelect: (accent) => ref.read(darkAccentProvider.notifier).setAccent(accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Feedback
                    _SettingsCard(
                      children: [
                        _CardHeader(
                          icon: Icons.feedback_outlined,
                          label: 'Feedback',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Help make RainDrop better',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _showFeedbackDialog(),
                            icon: const Icon(Icons.send_outlined,
                                size: 18),
                            label: const Text('Send Feedback'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Data
                    _SettingsCard(
                      children: [
                        _CardHeader(
                          icon: Icons.storage_outlined,
                          label: 'Data',
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _confirmReset(context),
                            icon: const Icon(Icons.delete_outline,
                                size: 18),
                            label: const Text('Reset All Data'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.error,
                              side: BorderSide(
                                color: colorScheme.error
                                    .withValues(alpha: 0.5),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // App info
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primaryContainer,
                                  colorScheme.primary.withValues(alpha: 0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.water_drop,
                              color: colorScheme.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'RainDrop v1.1.0',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFeedbackDialog() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentName = ref.read(userNameProvider);
    final nameController = TextEditingController(text: currentName);
    final messageController = TextEditingController();
    int rating = 5;
    bool isSending = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.feedback_outlined,
                    color: colorScheme.primary, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                'Send Feedback',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Your name',
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Rating',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final starIdx = i + 1;
                    return IconButton(
                      icon: Icon(
                        starIdx <= rating
                            ? Icons.star
                            : Icons.star_border,
                        color: starIdx <= rating
                            ? Colors.amber
                            : colorScheme.onSurfaceVariant,
                        size: 32,
                      ),
                      onPressed: () {
                        setDialogState(() => rating = starIdx);
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Your message',
                    hintText: 'What do you think about RainDrop?',
                    alignLabelWithHint: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 72),
                      child: Icon(Icons.message_outlined, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSending ? null : () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            FilledButton(
              onPressed: isSending
                  ? null
                  : () async {
                      final name = nameController.text.trim();
                      final message = messageController.text.trim();
                      if (name.isEmpty || message.isEmpty) return;

                      setDialogState(() => isSending = true);

                      try {
                        await http.post(
                          Uri.parse(AppConstants.formspreeEndpoint),
                          headers: {
                            'Content-Type': 'application/json',
                            'Accept': 'application/json',
                          },
                          body: jsonEncode({
                            'name': name,
                            'rating': rating,
                            'message': message,
                          }),
                        );

                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          if (this.context.mounted) {
                            ScaffoldMessenger.of(this.context)
                                .showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.white, size: 20),
                                    SizedBox(width: 10),
                                    Text('Feedback sent! Thank you'),
                                  ],
                                ),
                                backgroundColor:
                                    const Color(0xFF30D158),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        setDialogState(() => isSending = false);
                        if (this.context.mounted) {
                          ScaffoldMessenger.of(this.context)
                              .showSnackBar(
                            SnackBar(
                              content: const Text(
                                  'Could not send feedback. Try again.'),
                              backgroundColor:
                                  colorScheme.errorContainer,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
              child: isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Send'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    messageController.dispose();
  }

  void _confirmReset(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will delete all your water intake history. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final storage = ref.read(storageProvider);
              await storage.clearAll();
              ref.read(todayProvider.notifier).refresh();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

// --- Settings Card ---
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

// --- Card Header ---
class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CardHeader({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// --- Accent Section ---
class _AccentSection<T> extends StatelessWidget {
  final String label;
  final bool isActive;
  final T current;
  final List<_AccentChip<T>> options;
  final void Function(T accent) onSelect;

  const _AccentSection({
    required this.label,
    required this.isActive,
    required this.current,
    required this.options,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Opacity(
      opacity: isActive ? 1.0 : 0.45,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) {
              final isSelected = opt.value == current;
              return GestureDetector(
                onTap: isActive ? () => onSelect(opt.value) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? opt.color.withValues(alpha: 0.15)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? opt.color
                          : colorScheme.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: opt.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: opt.color.withValues(alpha: 0.4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        opt.label,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? opt.color
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// --- Accent Chip Data ---
class _AccentChip<T> {
  final T value;
  final String label;
  final Color color;

  const _AccentChip(this.value, this.label, this.color);
}

// --- Theme Option ---
class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Icon(icon,
                size: 22,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            if (selected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check,
                    color: colorScheme.primary, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
