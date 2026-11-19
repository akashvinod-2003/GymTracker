import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/pwa_update_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/workout_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'packs/studio/screens/auth_screen.dart' as studio;
import 'packs/studio/screens/home_screen.dart' as studio;
import 'packs/studio/theme/app_theme.dart' as studio;
import 'packs/turbo/screens/auth_screen.dart' as turbo;
import 'packs/turbo/screens/home_screen.dart' as turbo;
import 'packs/turbo/theme/app_theme.dart' as turbo;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-load SharedPreferences concurrently for instant theme resolution
  final prefsFuture = SharedPreferences.getInstance();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization note: $e (App will run with offline & local fallback if needed)");
  }

  final prefs = await prefsFuture;

  // Do NOT block runApp() with Firestore queries.
  // Only Firebase.initializeApp() and SharedPreferences for theme are awaited before runApp().
  runApp(GymTrackerApp(prefs: prefs));
}

class GymTrackerApp extends StatelessWidget {
  final SharedPreferences? prefs;

  const GymTrackerApp({super.key, this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(prefs),
        ),
        ChangeNotifierProvider<PwaUpdateProvider>(
          create: (_) => PwaUpdateProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, WorkoutProvider>(
          create: (_) => WorkoutProvider(),
          update: (_, auth, workout) {
            final provider = workout ?? WorkoutProvider();
            final uid = auth.user?.uid ?? '';
            provider.updateUserId(uid);
            return provider;
          },
        ),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, _) {
          final pack = themePack(themeProvider.themePack);
          final home = authProvider.isAuthenticated ? pack.home : pack.auth;
          return MaterialApp(
            title: 'PulseFit - Gym Tracker',
            debugShowCheckedModeBanner: false,
            theme: pack.light,
            darkTheme: pack.dark,
            themeMode: themeProvider.themeMode,
            home: home,
          );
        },
      ),
    );
  }
}

/// Screens and themes for one UI pack.
typedef PackScreens = ({Widget home, Widget auth, ThemeData light, ThemeData dark});

PackScreens themePack(AppThemePack pack) => switch (pack) {
      AppThemePack.classic => (
          home: const HomeScreen(),
          auth: const AuthScreen(),
          light: AppTheme.lightTheme,
          dark: AppTheme.darkTheme,
        ),
      AppThemePack.studio => (
          home: const studio.HomeScreen(),
          auth: const studio.AuthScreen(),
          light: studio.AppTheme.lightTheme,
          dark: studio.AppTheme.darkTheme,
        ),
      AppThemePack.turbo => (
          home: const turbo.HomeScreen(),
          auth: const turbo.AuthScreen(),
          light: turbo.AppTheme.lightTheme,
          dark: turbo.AppTheme.darkTheme,
        ),
    };
