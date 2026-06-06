import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/repositories/water_repository.dart';
import '../../core/utils/date_utils_app.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    // Auto-refresh month data when today's data changes
    ref.listen(todayProvider, (previous, next) {
      if (previous != null && next.total != previous.total) {
        ref.invalidate(monthProvider(_currentMonth));
      }
    });

    final entries = ref.watch(monthProvider(_currentMonth));
    final today = ref.watch(todayProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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

    // Calculate average daily intake
    final daysWithData = dailyTotals.values.where((v) => v > 0).length;
    final totalAllDays = dailyTotals.values.fold(0, (a, b) => a + b);
    final avgIntake = daysWithData > 0 ? (totalAllDays / daysWithData).round() : 0;

    // Generate advice line
    final advice = _getAdvice(avgIntake, goal);

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
                    Text('History', style: theme.textTheme.headlineLarge),
                    const SizedBox(height: 20),

                    // Summary card with average + advice
                    if (hasData)
                      _SummaryCard(
                        avgIntake: avgIntake,
                        goal: goal,
                        advice: advice,
                        daysTracked: daysWithData,
                      ),
                    if (hasData) const SizedBox(height: 12),

                    // Month selector with chart
                    Container(
                      padding: const EdgeInsets.all(16),
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
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.chevron_left_rounded),
                                onPressed: () => setState(() {
                                  _currentMonth = DateTime(
                                    _currentMonth.year,
                                    _currentMonth.month - 1,
                                  );
                                  _selectedDay = null;
                                }),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      colorScheme.primaryContainer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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
                                icon: Icon(Icons.chevron_right_rounded),
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
                                  backgroundColor:
                                      colorScheme.primaryContainer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Chart
                          SizedBox(
                            height: 200,
                            child: hasData
                                ? BarChart(
                                    BarChartData(
                                      alignment:
                                          BarChartAlignment.spaceAround,
                                      maxY: max(
                                        (maxTotal * 1.2).clamp(
                                            goal.toDouble(), double.infinity),
                                        goal * 1.3,
                                      ),
                                      barTouchData: BarTouchData(
                                        enabled: true,
                                        touchTooltipData:
                                            BarTouchTooltipData(
                                          tooltipMargin: 4,
                                          getTooltipColor: (_) =>
                                              colorScheme.surface,
                                          getTooltipItem:
                                              (group, groupIndex, rod,
                                                  rodIndex) {
                                            final day =
                                                days[group.x.toInt()];
                                            return BarTooltipItem(
                                              '${DateUtilsApp.formatShortDay(day)}\n${rod.toY.toInt()} ml',
                                              TextStyle(
                                                color: colorScheme
                                                    .onSurface,
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
                                                return const SizedBox
                                                    .shrink();
                                              }
                                              if (days[index].day % 5 !=
                                                      0 &&
                                                  days[index].day != 1) {
                                                return const SizedBox
                                                    .shrink();
                                              }
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4),
                                                child: Text(
                                                  '${days[index].day}',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    color: colorScheme
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
                                            reservedSize: 34,
                                            getTitlesWidget: (value, meta) {
                                              if (value == 0) {
                                                return const SizedBox
                                                    .shrink();
                                              }
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 4),
                                                child: Text(
                                                  '${value.toInt()}',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                    color: colorScheme
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
                                        horizontalInterval:
                                            goal > 0 ? goal / 2 : 500,
                                        drawVerticalLine: false,
                                        getDrawingHorizontalLine: (value) =>
                                            FlLine(
                                          color: colorScheme.outlineVariant
                                              .withValues(alpha: 0.2),
                                          strokeWidth: 1,
                                        ),
                                      ),
                                      extraLinesData: ExtraLinesData(
                                        horizontalLines: [
                                          HorizontalLine(
                                            y: goal.toDouble(),
                                            color: colorScheme.tertiary,
                                            strokeWidth: 1.5,
                                            dashArray: [8, 4],
                                            label: HorizontalLineLabel(
                                              show: true,
                                              alignment: Alignment.topRight,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: colorScheme.tertiary,
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
                                        final isSelected = _selectedDay != null &&
                                            DateUtilsApp.isSameDay(
                                                day, _selectedDay!);
                                        final reached =
                                            total >= goal;
                                        return BarChartGroupData(
                                          x: entry.key,
                                          barRods: [
                                            BarChartRodData(
                                              toY: total.toDouble(),
                                              color: reached
                                                  ? const Color(0xFF30D158)
                                                  : (isSelected
                                                      ? colorScheme.tertiary
                                                      : colorScheme.primary),
                                              width:
                                                  days.length > 25 ? 5 : 8,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(3),
                                                topRight: Radius.circular(3),
                                              ),
                                              gradient: reached
                                                  ? LinearGradient(
                                                      begin: Alignment
                                                          .topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                      colors: [
                                                        const Color(
                                                            0xFF30D158),
                                                        const Color(
                                                            0xFF2BC44F),
                                                      ],
                                                    )
                                                  : null,
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primaryContainer,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.bar_chart_outlined,
                                            size: 36,
                                            color: colorScheme.primary
                                                .withValues(alpha: 0.5),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No data for this month',
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            color: colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Legend
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _Legend(
                            color: colorScheme.primary,
                            label: 'Below goal',
                          ),
                          const SizedBox(width: 20),
                          _Legend(
                            color: const Color(0xFF30D158),
                            label: 'Goal met',
                          ),
                          const SizedBox(width: 20),
                          _DashedLegend(
                            color: colorScheme.tertiary,
                            label: 'Goal line',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Daily notes section (when a day is selected)
                    if (_selectedDay != null)
                      _DailyNoteCard(
                        date: _selectedDay!,
                        dayTotal: dailyTotals[_selectedDay] ?? 0,
                        goal: goal,
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

  String _getAdvice(int avg, int goal) {
    if (avg == 0) return 'Start logging to see your habits';
    final ratio = avg / goal;
    if (ratio >= 1.0) return 'You are meeting your daily goal. Keep it up!';
    if (ratio >= 0.75) return 'Almost there! Just a bit more to reach your goal.';
    if (ratio >= 0.5) return 'You are below the recommended intake. Try to drink more.';
    return 'You are significantly below your hydration goal. Time to step it up!';
  }
}

// --- Summary Card ---
class _SummaryCard extends StatelessWidget {
  final int avgIntake;
  final int goal;
  final String advice;
  final int daysTracked;

  const _SummaryCard({
    required this.avgIntake,
    required this.goal,
    required this.advice,
    required this.daysTracked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ratio = goal > 0 ? (avgIntake / goal) : 0.0;

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
          color: colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.trending_up,
              color: colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Avg $avgIntake ml',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: ratio >= 1
                            ? const Color(0xFF30D158).withValues(alpha: 0.15)
                            : colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(ratio * 100).toInt()}%',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: ratio >= 1
                              ? const Color(0xFF30D158)
                              : colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  advice,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$daysTracked day${daysTracked == 1 ? '' : 's'} logged',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
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
    final colorScheme = theme.colorScheme;
    final note = ref.watch(noteProvider(widget.date));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
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
                child: Icon(Icons.notes, color: Colors.white, size: 16),
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
                  icon: Icon(Icons.edit_outlined, size: 20,
                      color: colorScheme.onSurfaceVariant),
                  onPressed: () {
                    _noteController.text = note;
                    setState(() => _isEditing = true);
                  },
                ),
              if (_isEditing)
                IconButton(
                  icon: Icon(Icons.close, size: 20,
                      color: colorScheme.onSurfaceVariant),
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
                      onPressed: () {
                        _noteController.clear();
                        ref.read(noteProvider(widget.date).notifier).deleteNote();
                        setState(() => _isEditing = false);
                      },
                      child: Text(
                        'Delete',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        ref.read(noteProvider(widget.date).notifier)
                            .setNote(_noteController.text);
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
                color: colorScheme.onSurfaceVariant,
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
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant
                        .withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, size: 18,
                        color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      'Add a note',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
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
