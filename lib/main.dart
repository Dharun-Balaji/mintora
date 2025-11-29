import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/local_database.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'providers/data_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localDb = LocalDatabase();
  await localDb.init();

  runApp(
    ProviderScope(
      overrides: [localDatabaseProvider.overrideWithValue(localDb)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    ThemeMode themeMode;
    switch (settings.themeMode) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      case 'amoled':
        themeMode = ThemeMode.dark; // Handle AMOLED in theme data
        break;
      default:
        themeMode = ThemeMode.system;
    }

    // Theme logic handled directly in MaterialApp

    return MaterialApp.router(
      title: 'Finance AI',
      theme: AppTheme.lightTheme,
      darkTheme: settings.themeMode == 'amoled'
          ? AppTheme.amoledTheme
          : AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
