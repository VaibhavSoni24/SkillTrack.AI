import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/config/env_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/settings/presentation/settings_page.dart';
import 'routes/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Sentry if DSN is provided
  if (EnvConfig.isSentryEnabled) {
    await SentryFlutter.init(
      (options) {
        options.dsn = EnvConfig.sentryDsn;
        options.tracesSampleRate = 1.0;
        options.environment =
            const String.fromEnvironment('ENV', defaultValue: 'development');
      },
      appRunner: () => _runApp(),
    );
  } else {
    _runApp();
  }
}

void _runApp() {
  runApp(
    const ProviderScope(
      child: SkillTrackApp(),
    ),
  );
}

class SkillTrackApp extends ConsumerStatefulWidget {
  const SkillTrackApp({super.key});

  @override
  ConsumerState<SkillTrackApp> createState() => _SkillTrackAppState();
}

class _SkillTrackAppState extends ConsumerState<SkillTrackApp> {
  @override
  void initState() {
    super.initState();
    // Check existing session on startup
    Future.microtask(() {
      ref.read(authProvider.notifier).checkSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'SkillTrack.AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
