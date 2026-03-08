import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'app_router.dart';
import 'theme/theme.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/services/profile_service.dart';
import 'core/providers/auth_provider.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  // Ensure bindings before using platform plugins (SharedPreferences etc.)
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Mobile Ads (uses test IDs by default)
  await MobileAds.instance.initialize();

  // Initialize Firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

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
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Builder(
        builder: (context) {
          final authProvider = context.watch<AuthProvider>();
          return MaterialApp.router(
            title: 'PrepPro',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            routerConfig: createRouter(authProvider),
            debugShowCheckedModeBanner: false,
            locale: null, // Uses device locale automatically
            supportedLocales: const [
              Locale('en'),
              Locale('en', 'US'),
              Locale('es'),
              Locale('fr'),
              Locale('de'),
              Locale('zh'),
              Locale('hi'),
            ],
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
          );
        },
      ),
    );
  }
}
