import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/workout_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'packs/studio/screens/auth_screen.dart' as studio;
import 'packs/studio/screens/home_screen.dart' as studio;
import 'packs/studio/theme/app_theme.dart' as studio;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization note: $e (App will run with offline & local fallback if needed)");
  }

  runApp(const GymTrackerApp());
}

class GymTrackerApp extends StatelessWidget {
  const GymTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
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
          final isStudio = themeProvider.themePack == AppThemePack.studio;
          final Widget home;
          if (authProvider.isAuthenticated) {
            home = isStudio ? const studio.HomeScreen() : const HomeScreen();
          } else {
            home = isStudio ? const studio.AuthScreen() : const AuthScreen();
          }
          return MaterialApp(
            title: 'PulseFit - Gym Tracker',
            debugShowCheckedModeBanner: false,
            theme: isStudio ? studio.AppTheme.lightTheme : AppTheme.lightTheme,
            darkTheme: isStudio ? studio.AppTheme.darkTheme : AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: home,
          );
        },
      ),
    );
  }
}
