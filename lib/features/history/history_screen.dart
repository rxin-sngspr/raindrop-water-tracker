import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data/models/water_entry.dart';
import '../../data/repositories/water_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/date_utils_app.dart';
import '../../shared/widgets/rain_page_header.dart';
import '../../shared/widgets/rain_card.dart';
import '../../shared/widgets/rain_empty_state.dart';
import '../../shared/widgets/rain_stat_card.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late DateTime _currentMonth;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    ref.listenManual(todayProvider, (previous, next) {
      if (previous != null && next.total != previous.total) {
        ref.invalidate(monthProvider(_currentMonth));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(monthProvider(_currentMonth));
    final today = ref.watch(todayProvider);
    final quickAddAmounts = ref.watch(quickAddProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final days = DateUtilsApp.getDaysInMonth(
      _currentMonth.year,
      _currentMonth.month,
    );

    final dailyTotals = <DateTime, int>{};
    for (final day in days) {
      final dayTotal = entries
          .where((e) => DateUtilsApp.isSameDay(e.timestamp, day))
          .fold(0, (sum, e) => sum + e.amountMl);
      dailyTotals[day] = dayTotal;
    }

    final maxTotal = dailyTotals.values.fold(0, (a, b) => a > b ? a : b);
    final goal = today.goal;
    final hasData = dailyTotals.values.any((v) => v > 0);

    final daysWithData = dailyTotals.values.where((v) => v > 0).length;
    final totalAllDays = dailyTotals.values.fold(0, (a, b) => a + b);
    final avgIntake =
        daysWithData > 0 ? (totalAllDays / daysWithData).round() : 0;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBackfillDialog(context, quickAddAmounts),
        icon: const Icon(LucideIcons.calendarRange, size: 20),
        label: const Text('Log past date'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.pageH,
                  AppDimensions.pageV,
                  AppDimensions.pageH,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RainPageHeader(
                      title: 'History',
                      subtitle: hasData
                          ? '$daysWithData day${daysWithData == 1 ? '' : 's'} logged this month'
                          : null,
                    ),
                    SizedBox(height: AppDimensions.sectionGap),

                    // Summary stat card
                    if (hasData)
                      RainStatCard(
                        value: '$avgIntake',
                        unit: 'ml',
                        label: 'Average daily intake',
                        badge: _buildPercentageBadge(
                          context,
                          avgIntake,
                          goal,
                        ),
                      ),
                    if (hasData)
                      SizedBox(height: AppDimensions.sectionGap),

                    // Month selector + chart
                    RainCard(
                      child: Column(
                        children: [
                          // Month navigation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(LucideIcons.chevronLeft),
                                onPressed: () => setState(() {
                                  final prev = DateTime(
                                    _currentMonth.year,
                                    _currentMonth.month - 1,
                                  );
                                  if (!prev.isBefore(DateTime(2024))) {
                                    _currentMonth = prev;
                                    _selectedDay = null;
                                  }
                                }),
                                style: IconButton.styleFrom(
                                  backgroundColor: cs.primaryContainer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusLg,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                DateUtilsApp.formatMonth(_currentMonth),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              IconButton(
                                icon: Icon(LucideIcons.chevronRight),
                                onPressed: () {
                                  final next = DateTime(
                                    _currentMonth.year,
                                    _currentMonth.month + 1,
                                  );
                                  if (!next.isAfter(DateTime.now())) {
                                    setState(() {
                                      _currentMonth = next;
                                      _selectedDay = null;
                                    });
                                  }
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: cs.primaryContainer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusLg,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppDimensions.sectionGap),

                          // Chart
                          SizedBox(
                            height: 280,
                            child: hasData
                                ? BarChart(
                                    BarChartData(
                                      alignment:
                                          BarChartAlignment.spaceAround,
                                      maxY: _niceMaxY(
                                          maxTotal.toDouble(), goal),
                                      barTouchData: BarTouchData(
                                        enabled: true,
                                        touchTooltipData:
                                            BarTouchTooltipData(
                                          tooltipMargin: 4,
                                          getTooltipColor: (_) => cs.surface,
                                          getTooltipItem:
                                              (group, groupIndex, rod,
                                                  rodIndex) {
                                            final day =
                                                days[group.x.toInt()];
                                            return BarTooltipItem(
                                              '${DateUtilsApp.formatShortDay(day)}\n${rod.toY.toInt()} ml',
                                              TextStyle(
                                                color: cs.onSurface,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            );
                                          },
                                        ),
                                        touchCallback: (event, response) {
                                          if (response?.spot != null &&
                                              event is FlTapUpEvent) {
                                            final idx = response!
                                                .spot!.touchedBarGroupIndex;
                                            if (idx >= 0 &&
                                                idx < days.length) {
                                              setState(() {
                                                _selectedDay = days[idx];
                                              });
                                            }
                                          }
                                        },
                                      ),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              final index = value.toInt();
                                              if (index < 0 ||
                                                  index >= days.length) {
                                                return const SizedBox.shrink();
                                              }
                                              if (days[index].day % 5 !=
                                                      0 &&
                                                  days[index].day != 1) {
                                                return const SizedBox.shrink();
                                              }
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        top: 4),
                                                child: Text(
                                                  '${days[index].day}',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    color: cs
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                              );
                                            },
                                            reservedSize: 16,
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 48,
                                            interval: _intervalFor(
                                                _niceMaxY(
                                                    maxTotal.toDouble(),
                                                    goal)),
                                            getTitlesWidget: (value, meta) {
                                              if (value == 0) {
                                                return const SizedBox.shrink();
                                              }
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        right: 4),
                                                child: Text(
                                                  '${value.toInt()}',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                    color: cs
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        topTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                              showTitles: false),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                              showTitles: false),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      gridData: FlGridData(
                                        show: true,
                                        horizontalInterval: _intervalFor(
                                            _niceMaxY(
                                                maxTotal.toDouble(), goal)),
                                        drawVerticalLine: false,
                                        getDrawingHorizontalLine: (value) =>
                                            FlLine(
                                          color: cs.outlineVariant
                                              .withValues(alpha: 0.2),
                                          strokeWidth: 1,
                                        ),
                                      ),
                                      extraLinesData: ExtraLinesData(
                                        horizontalLines: [
                                          HorizontalLine(
                                            y: goal.toDouble(),
                                            color: cs.tertiary,
                                            strokeWidth: 1.5,
                                            dashArray: [8, 4],
                                            label: HorizontalLineLabel(
                                              show: true,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: cs.tertiary,
                                              ),
                                              labelResolver: (_) =>
                                                  'Goal ${goal}ml',
                                            ),
                                          ),
                                        ],
                                      ),
                                      barGroups:
                                          days.asMap().entries.map((entry) {
                                        final day = entry.value;
                                        final total = dailyTotals[day] ?? 0;
                                        final reached = total >= goal;
                                        return BarChartGroupData(
                                          x: entry.key,
                                          barRods: [
                                            BarChartRodData(
                                              toY: total.toDouble(),
                                              color: reached
                                                  ? cs.tertiary
                                                  : cs.primary,
                                              width: 5,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(3),
                                                topRight:
                                                    Radius.circular(3),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  )
                                : RainEmptyState(
                                    icon: LucideIcons.barChart,
                                    title: 'No data for this month',
                                    message:
                                        'Start logging water to see your history',
                                  ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.sectionGap),

                    // Legend
                    RainCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _Legend(
                            color: cs.primary,
                            label: 'Below goal',
                          ),
                          SizedBox(width: AppDimensions.sp5),
                          _Legend(
                            color: cs.tertiary,
                            label: 'Goal met',
                          ),
                          SizedBox(width: AppDimensions.sp5),
                          _DashedLegend(
                            color: cs.tertiary,
                            label: 'Goal line',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.sectionGap),

                    // Daily note section
                    if (_selectedDay != null)
                      _DailyNoteCard(
                        date: _selectedDay!,
                        dayTotal: dailyTotals[_selectedDay] ?? 0,
                        goal: goal,
                      ),
                    SizedBox(height: AppDimensions.sp8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentageBadge(
      BuildContext context, int avgIntake, int goal) {
    final cs = Theme.of(context).colorScheme;
    final ratio = goal > 0 ? (avgIntake / goal) : 0.0;
    final pct = (ratio * 100).toInt();
    final badgeColor = ratio >= 1 ? cs.tertiary : cs.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Text(
        '$pct%',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: badgeColor,
            ),
      ),
    );
  }

  double _niceMaxY(double maxTotal, int goal) {
    final rawMax = max(maxTotal, goal.toDouble());
    final withHeadroom = rawMax * 1.2;
    return ((withHeadroom / 500).ceil() * 500).toDouble();
  }

  double _intervalFor(double maxY) {
    if (maxY <= 1000) return 250;
    if (maxY <= 3000) return 500;
    return 1000;
  }

  Future<void> _showBackfillDialog(
      BuildContext context, List<int> quickAmounts) async {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    DateTime selectedDate = DateTime.now();
    int selectedAmount = quickAmounts.isNotEmpty ? quickAmounts.first : 200;
    final amountController = TextEditingController();
    bool useCustomAmount = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(LucideIcons.calendarRange, color: cs.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Log water for past date',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date picker row
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2024),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                  child: Row(
                    children: [
                      Icon(LucideIcons.calendar,
                          size: 18, color: cs.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          DateUtilsApp.formatDate(selectedDate),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(LucideIcons.chevronRight,
                          color: cs.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text('Amount',
                  style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),

              // Quick-add buttons
              Row(
                children: quickAmounts.map((amount) {
                  final isActive =
                      !useCustomAmount && selectedAmount == amount;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: amount == quickAmounts.first ? 0 : 4,
                        right: amount == quickAmounts.last ? 0 : 4,
                      ),
                      child: ChoiceChip(
                        label: Text('${amount}ml'),
                        selected: isActive,
                        onSelected: (_) {
                          setDialogState(() {
                            useCustomAmount = false;
                            selectedAmount = amount;
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Custom amount field
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Custom amount (ml)',
                  prefixIcon: Icon(LucideIcons.droplet,
                      size: 18, color: cs.primary),
                  suffixText: 'ml',
                ),
                onChanged: (_) {
                  setDialogState(() => useCustomAmount = true);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel',
                  style: TextStyle(color: cs.onSurfaceVariant)),
            ),
            FilledButton.icon(
              icon: const Icon(LucideIcons.save, size: 18),
              label: const Text('Save'),
              onPressed: () async {
                final amount = useCustomAmount
                    ? int.tryParse(amountController.text) ?? 0
                    : selectedAmount;

                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Enter a valid amount'),
                      backgroundColor: cs.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                if (amount > AppConstants.maxPerEntryMl) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Max ${AppConstants.maxPerEntryMl}ml per entry'),
                      backgroundColor: cs.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                try {
                  final storage = ref.read(storageProvider);
                  final entry = WaterEntry(
                    timestamp: selectedDate,
                    amountMl: amount,
                  );
                  await storage.addEntry(entry);

                  // Refresh chart
                  ref.invalidate(monthProvider(_currentMonth));

                  // Also refresh today if the date is today
                  if (DateUtilsApp.isSameDay(
                      selectedDate, DateTime.now())) {
                    ref.invalidate(todayProvider);
                  }

                  // Trigger streak and achievement recalculation
                  await ref
                      .read(streakProvider.notifier)
                      .recalculate();
                  await ref
                      .read(achievementsProvider.notifier)
                      .recalculate();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Logged ${amount}ml for ${DateUtilsApp.formatDate(selectedDate)}',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to save: $e'),
                        backgroundColor: cs.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
    amountController.dispose();
  }
}

// --- Daily Note Card ---
class _DailyNoteCard extends ConsumerStatefulWidget {
  final DateTime date;
  final int dayTotal;
  final int goal;

  const _DailyNoteCard({
    required this.date,
    required this.dayTotal,
    required this.goal,
  });

  @override
  ConsumerState<_DailyNoteCard> createState() => _DailyNoteCardState();
}

class _DailyNoteCardState extends ConsumerState<_DailyNoteCard> {
  bool _isEditing = false;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final note = ref.watch(noteProvider(widget.date));

    return RainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMd,
                  ),
                ),
                child: Icon(LucideIcons.fileText, color: cs.primary, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Note for ${DateUtilsApp.formatDate(widget.date)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (note.isNotEmpty && !_isEditing)
                IconButton(
                  icon: Icon(LucideIcons.edit,
                      size: 20, color: cs.onSurfaceVariant),
                  onPressed: () {
                    _noteController.text = note;
                    setState(() => _isEditing = true);
                  },
                ),
              if (_isEditing)
                IconButton(
                  icon: Icon(LucideIcons.x,
                      size: 20, color: cs.onSurfaceVariant),
                  onPressed: () {
                    _noteController.clear();
                    setState(() => _isEditing = false);
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (_isEditing)
            Column(
              children: [
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Write a note for this day...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        try {
                          await ref
                              .read(noteProvider(widget.date).notifier)
                              .deleteNote();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Failed to delete note: $e'),
                              ),
                            );
                          }
                        }
                        setState(() => _isEditing = false);
                      },
                      child: Text('Delete',
                          style: TextStyle(color: cs.error)),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () async {
                        try {
                          await ref
                              .read(noteProvider(widget.date).notifier)
                              .setNote(_noteController.text);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Failed to save note: $e'),
                              ),
                            );
                          }
                        }
                        setState(() => _isEditing = false);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            )
          else if (note.isNotEmpty)
            Text(
              note,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            )
          else
            GestureDetector(
              onTap: () => setState(() => _isEditing = true),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusLg,
                  ),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.plus,
                        size: 18, color: cs.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      'Add a note',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- Legend ---
class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

// --- Dashed Legend (goal line) ---
class _DashedLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _DashedLegend({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(16, 2),
          painter: _DashedLinePainter(color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashGap = 3.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(
          (startX + dashWidth).clamp(0, size.width),
          size.height / 2,
        ),
        paint,
      );
      startX += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) =>
      old.color != color;
}
