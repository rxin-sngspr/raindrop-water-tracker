import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import '../../data/repositories/water_repository.dart';

final widgetServiceProvider = Provider<WidgetService>((ref) {
  return WidgetService(ref);
});

class WidgetService {
  final Ref _ref;

  WidgetService(this._ref);

  Future<void> init() async {
    if (kIsWeb) return;

    // Register background callback for widget taps
    try {
      await HomeWidget.registerInteractivityCallback((uri) async {
        if (uri != null) {
          // Handle widget interaction - add 250ml on tap
          final notifier = _ref.read(todayProvider.notifier);
          await notifier.addWater(250);
          await updateWidget();
        }
      });
    } catch (e) {
      debugPrint('Widget callback registration error: $e');
    }
  }

  Future<void> updateWidget() async {
    if (kIsWeb) return;
    try {
      final state = _ref.read(todayProvider);
      final progress = state.goal > 0
          ? ((state.total / state.goal) * 100).toInt()
          : 0;
      await HomeWidget.saveWidgetData(
        'widget_progress',
        '${state.total} / ${state.goal} ml ($progress%)',
      );
      await HomeWidget.updateWidget(
        androidName: 'HomeWidgetProvider',
      );
    } catch (e) {
      debugPrint('Widget update error: $e');
    }
  }
}
