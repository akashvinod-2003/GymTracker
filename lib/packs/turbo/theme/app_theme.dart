import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Turbo pack design tokens.
///
/// Visual world: gym ink on milk paper. Milk Paper carries grounds and
/// surfaces (60%), Grill Charcoal carries text, the hero slab, nav and dark
/// surfaces (30%), and Turbo Blue marks the one thing to act on (10%).
/// Headings are heavy Inter Tight; body is Inter. Contrast ratios are noted
/// beside each text token.
class AppTheme {
  // ── Core palette (brief) ──────────────────────────────────────────────────
  static const Color milk = Color(0xFFE9E6DF); // Milk Paper, 60%
  static const Color charcoal = Color(0xFF2E2B28); // Grill Charcoal, 30%
  static const Color turbo = Color(0xFF1F4BFF); // Turbo Blue, 10%

  // ── Warm neutral ramp: milk → charcoal (n050 lightest) ────────────────────
  static const Color n050 = Color(0xFFF4F2ED);
  static const Color n100 = milk;
  static const Color n150 = Color(0xFFDEDAD1);
  static const Color n200 = Color(0xFFCFCAC0);
  static const Color n300 = Color(0xFFB4AEA5);
  static const Color n400 = Color(0xFF9A948B);
  static const Color n500 = Color(0xFF7A746C);
  static const Color n550 = Color(0xFF69635C);
  static const Color n600 = Color(0xFF5C5751);
  static const Color n700 = Color(0xFF45403B);
  static const Color n750 = Color(0xFF3A3633);
  static const Color n800 = charcoal;
  static const Color n850 = Color(0xFF262421);
  static const Color n900 = Color(0xFF211F1D);
  static const Color n950 = Color(0xFF1B1917);

  // ── Turbo ramp ────────────────────────────────────────────────────────────
  static const Color t050 = Color(0xFFE3E8FF);
  static const Color t100 = Color(0xFFD6DCF7);
  static const Color t200 = Color(0xFFC9D4FF);
  static const Color t300 = Color(0xFF8FA5FF); // accent text on dark: 6.0:1 on charcoal
  static const Color t400 = Color(0xFF5A78FF);
  static const Color t500 = turbo; // 4.8:1 on milk; white on it 6.0:1
  static const Color t600 = Color(0xFF1638C8);
  static const Color t800 = Color(0xFF23284A);
  static const Color t900 = Color(0xFF1A1F3D);

  // ── Brand accent ────────────────────────────────────────────────────────
  // Fills use exact Turbo in both modes with white on top. Accent used as
  // text or icon colour on dark grounds takes the lighter t300.
  static const Color accentDark = t300;
  static const Color accentLight = turbo;
  static const Color onAccentDark = n950; // 9.4:1 on t300
  static const Color onAccentLight = Colors.white; // 6.0:1 on turbo

  // ── Completion ──────────────────────────────────────────────────────────
  static const Color successDark = Color(0xFF3DD68C); // 8.1:1 on charcoal
  static const Color successLight = Color(0xFF0E7040); // 5.1:1 on milk
  static const Color onSuccessDark = Color(0xFF0B1A12);
  static const Color onSuccessLight = Colors.white;

  // ── Destructive ─────────────────────────────────────────────────────────
  static const Color dangerDark = Color(0xFFFF7A70); // 5.9:1 on charcoal
  static const Color dangerLight = Color(0xFFB8202A); // 5.3:1 on milk

  // ── Light palette (milk paper) ──────────────────────────────────────────
  static const Color lightBg = milk;
  static const Color lightCard = n050;
  static const Color lightCardSub = n150;
  static const Color lightTextPrimary = charcoal; // 11.3:1 on milk
  static const Color lightTextSecondary = n600; // 5.6:1 on milk
  static const Color lightTextTertiary = n550; // 4.8:1 on milk
  static const Color lightBorder = n200;

  // ── Dark palette (grill charcoal) ───────────────────────────────────────
  static const Color darkBg = n900;
  static const Color darkCard = charcoal;
  static const Color darkCardSub = n750;
  static const Color darkTextPrimary = milk; // 11.3:1 on charcoal
  static const Color darkTextSecondary = n300; // 6.4:1 on charcoal
  static const Color darkTextTertiary = n400; // 4.7:1 on charcoal
  static const Color darkBorder = n700;

  // ── Legacy names kept so pack widgets resolve to Turbo roles ────────────
  static const Color tealPrimary = accentLight;
  static const Color tealLight = accentDark;
  static const Color tealBg = t050;
  static const Color orangeStart = turbo;
  static const Color orangeEnd = t600;
  static const Color heroBlue1 = n750;
  static const Color heroBlue2 = charcoal;
  static const Color heroBlue3 = n900;

  // ── Shape ───────────────────────────────────────────────────────────────
  static const double radiusS = 6;
  static const double radiusM = 8;
  static const double radiusL = 12;
  static const double radiusXL = 14;
  static const double borderWidth = 1.5;

  /// Muscle-group colours: printed ink swatches, kept functional (data).
  static const List<PastelChipStyle> pastelStyles = [
    PastelChipStyle(
      // Turbo ink
      bgLight: Color(0xFFDDE3FB),
      borderLight: Color(0xFFB9C6F7),
      textLight: Color(0xFF1638C8),
      bgDark: Color(0xFF23284A),
      borderDark: Color(0xFF34407A),
      textDark: Color(0xFF8FA5FF),
      icon: Icons.fitness_center_sharp,
    ),
    PastelChipStyle(
      // Charcoal ink
      bgLight: Color(0xFFDEDAD1),
      borderLight: Color(0xFFCFCAC0),
      textLight: Color(0xFF2E2B28),
      bgDark: Color(0xFF3A3633),
      borderDark: Color(0xFF45403B),
      textDark: Color(0xFFE9E6DF),
      icon: Icons.layers_sharp,
    ),
    PastelChipStyle(
      // Ochre ink
      bgLight: Color(0xFFEFE3C6),
      borderLight: Color(0xFFDCC891),
      textLight: Color(0xFF7A5200),
      bgDark: Color(0xFF3D331C),
      borderDark: Color(0xFF5E4C24),
      textDark: Color(0xFFF2C14E),
      icon: Icons.bolt_sharp,
    ),
    PastelChipStyle(
      // Green ink
      bgLight: Color(0xFFD9E8DC),
      borderLight: Color(0xFFB3D2BA),
      textLight: Color(0xFF0E7040),
      bgDark: Color(0xFF1C3426),
      borderDark: Color(0xFF2A503A),
      textDark: Color(0xFF3DD68C),
      icon: Icons.favorite_sharp,
    ),
    PastelChipStyle(
      // Red ink
      bgLight: Color(0xFFF3DCD7),
      borderLight: Color(0xFFE6BAB1),
      textLight: Color(0xFFB8202A),
      bgDark: Color(0xFF41241F),
      borderDark: Color(0xFF63342C),
      textDark: Color(0xFFFF7A70),
      icon: Icons.album_sharp,
    ),
  ];

  // ── Type ────────────────────────────────────────────────────────────────
  // Inter Tight 800–900 for display and headings, tight tracking; Inter for
  // body and labels. Nothing on screen goes below 11.
  static TextStyle heading({
    double? fontSize,
    FontWeight fontWeight = FontWeight.w800,
    Color? color,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.interTight(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing ?? (fontSize != null && fontSize >= 20 ? -0.03 * fontSize : -0.2),
      );

  static TextTheme _textTheme(Color primary, Color secondary) {
    TextStyle h(double size, FontWeight w, double height, double tracking, Color c) =>
        GoogleFonts.interTight(fontSize: size, fontWeight: w, height: height, letterSpacing: tracking, color: c);
    TextStyle b(double size, FontWeight w, double height, double tracking, Color c) =>
        GoogleFonts.inter(fontSize: size, fontWeight: w, height: height, letterSpacing: tracking, color: c);
    return TextTheme(
      displayLarge: h(46, FontWeight.w900, 1.0, -1.8, primary),
      displayMedium: h(36, FontWeight.w900, 1.05, -1.3, primary),
      headlineLarge: h(30, FontWeight.w800, 1.08, -0.9, primary),
      headlineMedium: h(26, FontWeight.w800, 1.12, -0.7, primary),
      headlineSmall: h(22, FontWeight.w800, 1.15, -0.5, primary),
      titleLarge: h(20, FontWeight.w800, 1.2, -0.4, primary),
      titleMedium: h(17, FontWeight.w800, 1.25, -0.2, primary),
      titleSmall: h(15, FontWeight.w700, 1.3, -0.1, primary),
      bodyLarge: b(16, FontWeight.w500, 1.45, -0.1, primary),
      bodyMedium: b(14.5, FontWeight.w500, 1.45, -0.05, secondary),
      bodySmall: b(13, FontWeight.w500, 1.4, 0, secondary),
      labelLarge: b(15, FontWeight.w700, 1.2, -0.1, primary),
      labelMedium: b(13, FontWeight.w600, 1.2, 0, secondary),
      labelSmall: b(11, FontWeight.w600, 1.2, 0.2, secondary),
    );
  }

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final dark = b == Brightness.dark;
    final p = Pal(dark);
    final text = _textTheme(p.text, p.text2);
    final r = BorderRadius.circular(radiusM);

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      scaffoldBackgroundColor: p.bg,
      primaryColor: p.accent,
      splashFactory: InkRipple.splashFactory,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: turbo,
        selectionColor: turbo.withValues(alpha: 0.28),
        selectionHandleColor: turbo,
      ),
      focusColor: turbo.withValues(alpha: 0.18),
      colorScheme: ColorScheme(
        brightness: b,
        primary: p.accent,
        onPrimary: p.onAccent,
        secondary: p.success,
        onSecondary: p.onSuccess,
        error: p.danger,
        onError: Colors.white,
        surface: p.surface,
        onSurface: p.text,
        surfaceContainerHighest: p.surface2,
        outline: p.separator,
        outlineVariant: p.separator,
      ),
      cardColor: p.surface,
      dividerColor: p.separator,
      dividerTheme: DividerThemeData(color: p.separator, thickness: 1, space: 1),
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: p.bg,
        foregroundColor: p.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      iconTheme: IconThemeData(color: p.text2, size: 22),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: turbo,
          foregroundColor: Colors.white,
          minimumSize: const Size(44, 50),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: r),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: turbo,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(44, 50),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: r),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accentText,
          minimumSize: const Size(44, 44),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: r),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.text,
          minimumSize: const Size(44, 50),
          side: BorderSide(color: p.text, width: borderWidth),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: r),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface2,
        hintStyle: text.bodyLarge?.copyWith(color: p.text3),
        labelStyle: text.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: r, borderSide: BorderSide(color: p.separator, width: borderWidth)),
        enabledBorder:
            OutlineInputBorder(borderRadius: r, borderSide: BorderSide(color: p.separator, width: borderWidth)),
        focusedBorder: OutlineInputBorder(borderRadius: r, borderSide: const BorderSide(color: turbo, width: 2)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: p.text3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXL)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
          side: BorderSide(color: p.separator, width: borderWidth),
        ),
        titleTextStyle: text.titleMedium,
        contentTextStyle: text.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? milk : charcoal,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: dark ? charcoal : milk,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: dark ? turbo : t300,
        shape: RoundedRectangleBorder(borderRadius: r),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: p.bg,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? turbo : null,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: turbo),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: charcoal,
        headerForegroundColor: milk,
        todayBorder: const BorderSide(color: turbo),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

/// Semantic palette resolved for the current brightness.
/// Use `Pal.of(context)` in widgets instead of branching on isDark.
class Pal {
  final bool dark;
  const Pal(this.dark);

  static Pal of(BuildContext context) => Pal(Theme.of(context).brightness == Brightness.dark);

  Color get bg => dark ? AppTheme.darkBg : AppTheme.lightBg;
  Color get surface => dark ? AppTheme.darkCard : AppTheme.lightCard;
  Color get surface2 => dark ? AppTheme.darkCardSub : AppTheme.lightCardSub;
  Color get separator => dark ? AppTheme.darkBorder : AppTheme.lightBorder;
  Color get text => dark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
  Color get text2 => dark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
  Color get text3 => dark ? AppTheme.darkTextTertiary : AppTheme.lightTextTertiary;

  /// Fill colour for the primary action: exact Turbo in both modes.
  Color get accent => AppTheme.turbo;
  Color get onAccent => Colors.white;

  /// Accent used as text or icon colour on this mode's grounds.
  Color get accentText => dark ? AppTheme.t300 : AppTheme.turbo;
  Color get accentTint => dark ? AppTheme.t800 : AppTheme.t050;
  Color get success => dark ? AppTheme.successDark : AppTheme.successLight;
  Color get onSuccess => dark ? AppTheme.onSuccessDark : AppTheme.onSuccessLight;
  Color get successTint => dark ? const Color(0xFF1C3426) : const Color(0xFFD9E8DC);
  Color get danger => dark ? AppTheme.dangerDark : AppTheme.dangerLight;
  Color get dangerTint => dark ? const Color(0xFF41241F) : const Color(0xFFF3DCD7);

  /// Floating chrome (tab bar): a charcoal slab in both modes.
  Color get chrome => dark ? AppTheme.charcoal.withValues(alpha: 0.98) : AppTheme.charcoal.withValues(alpha: 0.97);
  Color get chromeEdge => dark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.10);

  /// Text and icons drawn on the charcoal chrome.
  Color get onChrome => AppTheme.milk;
  Color get onChrome2 => AppTheme.n300;

  /// Ink swatch for a muscle-group slot.
  PastelChipStyle plate(int index) => AppTheme.pastelStyles[index % AppTheme.pastelStyles.length];
}

/// Numeric text: tabular figures so changing digits don't jitter.
const List<FontFeature> tabularFigures = [FontFeature.tabularFigures()];

class PastelChipStyle {
  final Color bgLight;
  final Color borderLight;
  final Color textLight;
  final Color bgDark;
  final Color borderDark;
  final Color textDark;
  final IconData icon;

  const PastelChipStyle({
    required this.bgLight,
    required this.borderLight,
    required this.textLight,
    required this.bgDark,
    required this.borderDark,
    required this.textDark,
    required this.icon,
  });

  Color bg(bool isDark) => isDark ? bgDark : bgLight;
  Color border(bool isDark) => isDark ? borderDark : borderLight;
  Color text(bool isDark) => isDark ? textDark : textLight;
}
