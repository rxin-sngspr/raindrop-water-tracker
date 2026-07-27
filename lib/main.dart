import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'data/repositories/water_repository.dart';
import 'data/storage/hive_storage.dart';
import 'core/services/notification_service.dart';
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
      child: const _RainDropAppWithInit(),
    ),
  );
}

class _RainDropAppWithInit extends ConsumerStatefulWidget {
  const _RainDropAppWithInit();

  @override
  ConsumerState<_RainDropAppWithInit> createState() => _RainDropAppWithInitState();
}

class _RainDropAppWithInitState extends ConsumerState<_RainDropAppWithInit> {
  bool _ready = false;

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
      final storage = ref.read(storageProvider);
      final mHour = storage.getNotifHour('morning_hour', 9);
      final mMin = storage.getNotifMinute('morning_minute', 0);
      final eHour = storage.getNotifHour('evening_hour', 18);
      final eMin = storage.getNotifMinute('evening_minute', 0);
      await notif.scheduleDailyReminder(hour: mHour, minute: mMin, id: 1);
      await notif.scheduleMotivationalReminder(hour: eHour, minute: eMin, id: 2);

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
    if (!_ready) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0D9488),
            brightness: Brightness.light,
          ),
        ),
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 16),
                Text(
                  'Rain Drop',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF0D9488),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 32),
                const SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your daily hydration companion',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const RainDropApp();
  }
}
