import 'package:flutter/material.dart';
import 'app_router.dart';
import 'theme/theme.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/services/profile_service.dart';

Future<void> main() async {
  // Ensure bindings before using platform plugins (SharedPreferences etc.)
  WidgetsFlutterBinding.ensureInitialized();

  const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  // Start the app normally; initialize Sentry only if DSN present and user consented
  // Protect startup in case profile load hangs — use a short timeout fallback
  try {
    final profile = await ProfileService.loadProfile().timeout(const Duration(seconds: 3));
    final consent = profile?.consentTelemetry ?? false;
    if (sentryDsn.isNotEmpty && consent) {
      await SentryFlutter.init((options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 0.1;
      }, appRunner: () => runApp(const PrepProApp()));
      return;
    }
  } catch (_) {
    // ignore timeouts and proceed to run the app
  }

  runApp(const PrepProApp());
}

class PrepProApp extends StatelessWidget {
  const PrepProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PrepPro',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
