import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'data/repositories/water_repository.dart';
import 'data/storage/hive_storage.dart';
import 'core/services/notification_service.dart';
import 'core/services/widget_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    final appDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDir.path);
  }

  final storage = HiveStorage();
  await storage.init();

  runApp(
    ProviderScope(
      overrides: [
        storageProvider.overrideWithValue(storage),
      ],
      child: const _AppWithInit(),
    ),
  );
}

class _AppWithInit extends ConsumerStatefulWidget {
  const _AppWithInit();

  @override
  ConsumerState<_AppWithInit> createState() => _AppWithInitState();
}

class _AppWithInitState extends ConsumerState<_AppWithInit> {
  bool _ready = false;
  bool _listenerAttached = false;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    try {
      final notif = ref.read(notificationServiceProvider);
      await notif.init();
      await notif.requestPermissions();
      await notif.scheduleDailyReminder(hour: 9, minute: 0, id: 1);
      await notif.scheduleMotivationalReminder(hour: 18, minute: 0, id: 2);

      final widget = ref.read(widgetServiceProvider);
      await widget.init();
    } catch (e) {
      debugPrint('Service init error: $e');
    }

    if (mounted) {
      setState(() => _ready = true);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Auto-update widget when water data changes
    if (_ready && !_listenerAttached) {
      _listenerAttached = true;
      ref.listen(todayProvider, (previous, next) {
        ref.read(widgetServiceProvider).updateWidget();
      });
    }

    if (!_ready) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.water_drop,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'RainDrop',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      );
    }

    return const RainDropApp();
  }
}
