import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PwaIconMode {
  auto,  // Match active app theme
  dark,  // Always Dark icon
  light, // Always Light icon
}

/// Which UI pack the app renders: the original look, the Studio redesign, or
/// the Turbo pack (milk paper, charcoal, Turbo Blue).
enum AppThemePack { classic, studio, turbo }

class ThemeProvider extends ChangeNotifier {
  AppThemePack _themePack = AppThemePack.classic;
  static const String _prefThemePackKey = 'app_theme_pack';
  AppThemePack get themePack => _themePack;

  ThemeMode _themeMode = ThemeMode.system;
  PwaIconMode _pwaIconMode = PwaIconMode.auto;

  static const String _prefThemeKey = 'app_theme_mode';
  static const String _prefPwaIconKey = 'app_pwa_icon_mode';

  ThemeMode get themeMode => _themeMode;
  PwaIconMode get pwaIconMode => _pwaIconMode;

  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  /// Determines whether the active logo/PWA icon should be dark.
  /// Respects manual PWA icon mode override, otherwise follows [isDarkMode].
  bool isDarkLogo(BuildContext context) {
    if (_pwaIconMode == PwaIconMode.dark) return true;
    if (_pwaIconMode == PwaIconMode.light) return false;
    return isDarkMode(context);
  }

  /// Returns the matching logo asset path based on active theme & icon settings.
  String getLogoAsset(BuildContext context) {
    return isDarkLogo(context) ? 'assets/logo_v2_dark.png' : 'assets/logo_v2_light.png';
  }

  ThemeProvider([SharedPreferences? initialPrefs]) {
    if (initialPrefs != null) {
      _applyPreferences(initialPrefs);
    } else {
      _loadPreferences();
    }
  }

  void _applyPreferences(SharedPreferences prefs) {
    // Load Theme Mode
    final savedTheme = prefs.getString(_prefThemeKey);
    if (savedTheme != null) {
      if (savedTheme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (savedTheme == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
    }

    // Load PWA Icon Mode
    final savedIcon = prefs.getString(_prefPwaIconKey);
    if (savedIcon != null) {
      if (savedIcon == 'dark') {
        _pwaIconMode = PwaIconMode.dark;
      } else if (savedIcon == 'light') {
        _pwaIconMode = PwaIconMode.light;
      } else {
        _pwaIconMode = PwaIconMode.auto;
      }
    }

    // Load Theme Pack
    final savedPack = prefs.getString(_prefThemePackKey);
    _themePack = AppThemePack.values.firstWhere(
      (p) => p.name == savedPack,
      orElse: () => AppThemePack.classic,
    );
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _applyPreferences(prefs);
    notifyListeners();
  }

  Future<void> setThemePack(AppThemePack pack) async {
    _themePack = pack;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefThemePackKey, pack.name);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.dark) {
      await prefs.setString(_prefThemeKey, 'dark');
    } else if (mode == ThemeMode.light) {
      await prefs.setString(_prefThemeKey, 'light');
    } else {
      await prefs.setString(_prefThemeKey, 'system');
    }
  }

  Future<void> setPwaIconMode(PwaIconMode mode) async {
    _pwaIconMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (mode == PwaIconMode.dark) {
      await prefs.setString(_prefPwaIconKey, 'dark');
    } else if (mode == PwaIconMode.light) {
      await prefs.setString(_prefPwaIconKey, 'light');
    } else {
      await prefs.setString(_prefPwaIconKey, 'auto');
    }
  }

  void toggleTheme(BuildContext context) {
    if (isDarkMode(context)) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}
