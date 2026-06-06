import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/water_entry.dart';
import '../../data/repositories/water_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils_app.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final userName = ref.watch(userNameProvider);

    final progress =
        today.goal > 0 ? (today.total / today.goal).clamp(0.0, 1.0) : 0.0;
    final remaining = (today.goal - today.total).clamp(0, today.goal);
    final isGoalReached = today.total >= today.goal && today.total > 0;
    final isOverLimit = today.total >= AppConstants.maxDailyTotalMl;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(todayProvider.notifier).addWater(0),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting header with glass card
                      _GreetingHeader(
                        userName: userName,
                        progress: progress,
                      ),
                      const SizedBox(height: 24),

                      // Progress Ring
                      Center(
                        child: _ProgressRing(
                          progress: progress,
                          total: today.total,
                          goal: today.goal,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Quick Add glass card
                      _QuickAddCard(
                        onAdd: (ml) => _addWaterWithCheck(context, ref, ml),
                        onCustom: () => _showCustomDialog(context, ref),
                      ),
                      const SizedBox(height: 16),

                      // Status card
                      if (today.total > 0 || isGoalReached)
                        _StatusCard(
                          remaining: remaining,
                          isGoalReached: isGoalReached,
                          isOverLimit: isOverLimit,
                          todayTotal: today.total,
                          todayGoal: today.goal,
                        ),
                    ],
                  ),
                ),
              ),

              // Water log list
              if (today.entries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = today.entries.reversed.toList()[index];
                        return _WaterLogTile(
                          entry: entry,
                          onUndo: () =>
                              ref.read(todayProvider.notifier).undoLast(),
                          isLast: index == 0,
                        );
                      },
                      childCount: today.entries.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  void _addWaterWithCheck(
      BuildContext context, WidgetRef ref, int ml) async {
    final state = ref.read(todayProvider);
    final newTotal = state.total + ml;

    if (ml > AppConstants.maxPerEntryMl) {
      _showLimitSnackbar(
          context, 'Max ${AppConstants.maxPerEntryMl}ml per entry');
      return;
    }

    if (newTotal > AppConstants.maxDailyTotalMl) {
      _showLimitSnackbar(context,
          'Daily limit is ${AppConstants.maxDailyTotalMl}ml');
      return;
    }

    await ref.read(todayProvider.notifier).addWater(ml);
  }

  void _showLimitSnackbar(BuildContext context, String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline,
                color: theme.colorScheme.onErrorContainer, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: theme.colorScheme.errorContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showCustomDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.add, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Custom Amount',
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter amount between 1 and ${AppConstants.maxPerEntryMl}ml',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Amount',
                hintText: 'e.g. 350',
                suffixText: 'ml',
                prefixIcon: const Icon(Icons.water_drop_outlined),
              ),
              onSubmitted: (value) => _submitCustomAmount(
                  ctx, context, ref, controller.text),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          FilledButton(
            onPressed: () =>
                _submitCustomAmount(ctx, context, ref, controller.text),
            child: const Text('Add Water'),
          ),
        ],
      ),
    );
  }

  void _submitCustomAmount(
    BuildContext dialogCtx,
    BuildContext context,
    WidgetRef ref,
    String text,
  ) {
    final ml = int.tryParse(text);
    if (ml == null || ml <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid amount'),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (ml > AppConstants.maxPerEntryMl) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum ${AppConstants.maxPerEntryMl}ml per entry'),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final state = ref.read(todayProvider);
    final newTotal = state.total + ml;
    if (newTotal > AppConstants.maxDailyTotalMl) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Daily limit is ${AppConstants.maxDailyTotalMl}ml'),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref.read(todayProvider.notifier).addWater(ml);
    Navigator.pop(dialogCtx);
  }
}

// --- Greeting Header ---
class _GreetingHeader extends StatelessWidget {
  final String userName;
  final double progress;

  const _GreetingHeader({
    required this.userName,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.08),
            colorScheme.secondary.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'F',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hey $userName',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _motivationalMessage(progress),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.water_drop,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  String _motivationalMessage(double progress) {
    if (progress == 0) return 'Start your hydration journey';
    if (progress < 0.25) return 'Every drop counts';
    if (progress < 0.5) return 'Keep it going';
    if (progress < 0.75) return 'More than halfway there';
    if (progress < 1) return 'Almost there';
    return 'Stay hydrated, stay healthy';
  }
}

// --- Quick Add Card ---
class _QuickAddCard extends StatelessWidget {
  final void Function(int ml) onAdd;
  final VoidCallback onCustom;

  const _QuickAddCard({
    required this.onAdd,
    required this.onCustom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
        children: [
          Row(
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
                child: Icon(Icons.add_circle_outline,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                'Quick Add',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final amount in AppConstants.quickAddAmounts) ...[
                Expanded(
                  child: _AddButton(
                    amount: amount,
                    icon: amount <= 200
                        ? Icons.water_drop
                        : amount <= 350
                            ? Icons.water
                            : Icons.local_drink,
                    onTap: () => onAdd(amount),
                  ),
                ),
                if (amount != AppConstants.quickAddAmounts.last)
                  const SizedBox(width: 10),
              ],
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onCustom,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Custom Amount'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Status Card ---
class _StatusCard extends StatelessWidget {
  final int remaining;
  final bool isGoalReached;
  final bool isOverLimit;
  final int todayTotal;
  final int todayGoal;

  const _StatusCard({
    required this.remaining,
    required this.isGoalReached,
    required this.isOverLimit,
    required this.todayTotal,
    required this.todayGoal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color gradientStart;
    final Color gradientEnd;
    final IconData icon;
    final String title;
    final String subtitle;
    final Color iconBg;

    if (isOverLimit) {
      gradientStart = const Color(0xFFFF453A);
      gradientEnd = const Color(0xFFFF6961);
      icon = Icons.warning_rounded;
      title = 'Daily limit reached';
      subtitle = 'You have hit the ${AppConstants.maxDailyTotalMl}ml maximum';
      iconBg = Colors.white.withValues(alpha: 0.25);
    } else if (isGoalReached) {
      gradientStart = const Color(0xFF30D158);
      gradientEnd = const Color(0xFF34E859);
      icon = Icons.celebration_outlined;
      title = 'Goal reached!';
      subtitle = 'Great job staying hydrated';
      iconBg = Colors.white.withValues(alpha: 0.25);
    } else {
      gradientStart = colorScheme.primary;
      gradientEnd = colorScheme.secondary;
      icon = Icons.trending_up;
      title = '$remaining ml remaining';
      subtitle = 'Keep going to reach your goal';
      iconBg = Colors.white.withValues(alpha: 0.2);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientStart.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Empty State ---
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.water_drop_outlined,
                size: 48, color: colorScheme.primary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),
          Text(
            'No water logged yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap a button above to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Progress Ring ---
class _ProgressRing extends StatelessWidget {
  final double progress;
  final int total;
  final int goal;

  const _ProgressRing({
    required this.progress,
    required this.total,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, 240.0);
        final strokeWidth = size * 0.09;

        return SizedBox(
          width: size + 32,
          height: size + 32,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              if (progress > 0)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return CustomPaint(
                      size: Size(size + 32, size + 32),
                      painter: _RingGlowPainter(
                        progress: value,
                        glowColor: colorScheme.primary.withValues(alpha: 0.15),
                        strokeWidth: strokeWidth + 10,
                      ),
                    );
                  },
                ),
              // Progress ring
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return CustomPaint(
                    size: Size(size + 32, size + 32),
                    painter: _RingPainter(
                      progress: value,
                      trackColor: colorScheme.surfaceContainerHighest,
                      progressColor: colorScheme.primary,
                      strokeWidth: strokeWidth,
                    ),
                  );
                },
              ),
              // Center content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: total),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return Text(
                        '$value',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontSize: size * 0.18,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          height: 1.1,
                        ),
                      );
                    },
                  ),
                  Text(
                    'of $goal ml',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- Ring Painters ---
class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      // Progress arc
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: const [
            Color(0xFF0A84FF),
            Color(0xFF30D158),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

class _RingGlowPainter extends CustomPainter {
  final double progress;
  final Color glowColor;
  final double strokeWidth;

  _RingGlowPainter({
    required this.progress,
    required this.glowColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;

    final paint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingGlowPainter old) => old.progress != progress;
}

// --- Add Button ---
class _AddButton extends StatefulWidget {
  final int amount;
  final IconData icon;
  final VoidCallback onTap;

  const _AddButton({
    required this.amount,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer,
                colorScheme.primary.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(widget.icon, color: colorScheme.primary, size: 26),
              const SizedBox(height: 6),
              Text(
                '${widget.amount}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'ml',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Water Log Tile ---
class _WaterLogTile extends StatefulWidget {
  final WaterEntry entry;
  final VoidCallback onUndo;
  final bool isLast;

  const _WaterLogTile({
    required this.entry,
    required this.onUndo,
    required this.isLast,
  });

  @override
  State<_WaterLogTile> createState() => _WaterLogTileState();
}

class _WaterLogTileState extends State<_WaterLogTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.primary.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.water_drop,
                      color: colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.entry.amountMl} ml',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateUtilsApp.formatTime(widget.entry.timestamp),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isLast)
                  Material(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: widget.onUndo,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.undo,
                            color: colorScheme.error, size: 20),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
