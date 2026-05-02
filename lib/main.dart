// ─────────────────────────────────────────────────────────────────────────────
// ENPC Mobile — main.dart
// App entry point, provider setup, router
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'services/api.dart';
import 'screens/screens.dart';
import 'widgets/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Arabic/French timeago locale support
  timeago.setLocaleMessages('fr', timeago.FrMessages());

  runApp(
    ChangeNotifierProvider(
      create: (_) => ApiService(),
      child: const EnpcApp(),
    ),
  );
}

class EnpcApp extends StatelessWidget {
  const EnpcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ENPC',
      debugShowCheckedModeBanner: false,
      theme: EnpcTheme.theme,
      home: const _Root(),
    );
  }
}

// ── Root: handles auto-login then routes to correct screen ───────────────────

class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final api = context.read<ApiService>();
    await api.tryAutoLogin();
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) return const _SplashScreen();

    return Consumer<ApiService>(
      builder: (_, api, __) {
        if (!api.isAuthenticated) return const AuthScreen();
        return const HomeShell();
      },
    );
  }
}

// ── Splash Screen ─────────────────────────────────────────────────────────────

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnpcTheme.ink,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Text(
                'ENPC',
                style: EnpcTheme.theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Official Communication System',
              style: EnpcTheme.theme.textTheme.bodySmall?.copyWith(
                color: Colors.white38,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white30,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
