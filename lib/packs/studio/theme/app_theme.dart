import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// GymTracker v2 design tokens.
///
/// Visual world: a lifting floor. Graphite rubber surfaces, chalk-white text,
/// one brand accent (orange, kept from the logo) reserved for primary actions,
/// and the competition-plate colours (red, blue, yellow, green, steel) used to
/// code muscle groups. Every text pairing below was checked for WCAG contrast;
/// ratios are noted beside each token.
class AppTheme {
  // ── Brand accent ────────────────────────────────────────────────────────
  static const Color accentDark = Color(0xFFFF7A2F); // 6.5:1 on darkCard
  static const Color accentLight = Color(0xFFBF460A); // 5.1:1 on white
  static const Color onAccentDark = Color(0xFF16120F); // 7.2:1 on accentDark
  static const Color onAccentLight = Colors.white; // 5.1:1 on accentLight

  // ── Completion (plate green) ────────────────────────────────────────────
  static const Color successDark = Color(0xFF3DD68C); // 9.0:1 on darkCard
  static const Color successLight = Color(0xFF11804A); // 5.0:1 on white
  static const Color onSuccessDark = Color(0xFF0B1A12);
  static const Color onSuccessLight = Colors.white;

  // ── Destructive ─────────────────────────────────────────────────────────
  static const Color dangerDark = Color(0xFFFF6B6B); // 6.1:1 on darkCard
  static const Color dangerLight = Color(0xFFD1242F); // 5.2:1 on white

  // ── Light palette (chalk) ───────────────────────────────────────────────
  static const Color lightBg = Color(0xFFF3F2EE);
  static const Color lightCard = Colors.white;
  static const Color lightCardSub = Color(0xFFEDECE8);
  static const Color lightTextPrimary = Color(0xFF141416); // 18.4:1
  static const Color lightTextSecondary = Color(0xFF5F5F66); // 6.3:1
  static const Color lightTextTertiary = Color(0xFF76767E); // 4.5:1
  static const Color lightBorder = Color(0xFFE0DED8);

  // ── Dark palette (graphite) ─────────────────────────────────────────────
  static const Color darkBg = Color(0xFF111214);
  static const Color darkCard = Color(0xFF1C1D20);
  static const Color darkCardSub = Color(0xFF27282C);
  static const Color darkTextPrimary = Color(0xFFF2F1EE); // 14.9:1
  static const Color darkTextSecondary = Color(0xFFA1A1A8); // 6.6:1
  static const Color darkTextTertiary = Color(0xFF8B8B93); // 5.0:1
  static const Color darkBorder = Color(0xFF2E3034);

  // ── Legacy names, remapped so every older screen adopts the new palette.
  // "teal" was the old interactive colour; it is now the brand accent.
  static const Color tealPrimary = accentLight;
  static const Color tealLight = accentDark;
  static const Color tealBg = Color(0xFFFBEDE4);
  static const Color orangeStart = accentDark;
  static const Color orangeEnd = Color(0xFFF2600F);
  static const Color heroBlue1 = darkCardSub;
  static const Color heroBlue2 = darkCard;
  static const Color heroBlue3 = darkBg;

  /// Competition plate colours, one per muscle group slot.
  static const List<PastelChipStyle> pastelStyles = [
    PastelChipStyle(
      // Red plate
      bgLight: Color(0xFFFDECEC),
      borderLight: Color(0xFFF6C9CB),
      textLight: Color(0xFFC9262F),
      bgDark: Color(0xFF3A1E20),
      borderDark: Color(0xFF5C2A2D),
      textDark: Color(0xFFFF6B6B),
      icon: Icons.fitness_center_rounded,
    ),
    PastelChipStyle(
      // Blue plate
      bgLight: Color(0xFFE8EFFE),
      borderLight: Color(0xFFC5D6FB),
      textLight: Color(0xFF2457C5),
      bgDark: Color(0xFF1C2840),
      borderDark: Color(0xFF2B3E66),
      textDark: Color(0xFF6EA2FF),
      icon: Icons.album_rounded,
    ),
    PastelChipStyle(
      // Yellow plate
      bgLight: Color(0xFFFDF4DC),
      borderLight: Color(0xFFF3DFA6),
      textLight: Color(0xFF8A5A00),
      bgDark: Color(0xFF3A3019),
      borderDark: Color(0xFF5A4A22),
      textDark: Color(0xFFF5C451),
      icon: Icons.bolt_rounded,
    ),
    PastelChipStyle(
      // Green plate
      bgLight: Color(0xFFE3F6EC),
      borderLight: Color(0xFFB7E6CC),
      textLight: Color(0xFF11804A),
      bgDark: Color(0xFF173226),
      borderDark: Color(0xFF24503A),
      textDark: Color(0xFF3DD68C),
      icon: Icons.favorite_rounded,
    ),
    PastelChipStyle(
      // Steel plate
      bgLight: Color(0xFFECEDEF),
      borderLight: Color(0xFFD5D7DC),
      textLight: Color(0xFF4B4F58),
      bgDark: Color(0xFF2E3035),
      borderDark: Color(0xFF45484F),
      textDark: Color(0xFFD4D6DB),
      icon: Icons.layers_rounded,
    ),
  ];

  // ── Type ────────────────────────────────────────────────────────────────
  // Plus Jakarta Sans carries the brand. Size, weight, leading and tracking
  // move together: large text tightens, small text opens slightly. Nothing on
  // screen goes below 11.
  static TextTheme _textTheme(Color primary, Color secondary) {
    TextStyle s(double size, FontWeight w, double height, double tracking,
            Color c) =>
        GoogleFonts.plusJakartaSans(
          fontSize: size,
          fontWeight: w,
          height: height,
          letterSpacing: tracking,
          color: c,
        );
    return TextTheme(
      displayLarge: s(44, FontWeight.w800, 1.05, -1.2, primary),
      displayMedium: s(34, FontWeight.w800, 1.1, -0.8, primary),
      headlineLarge: s(30, FontWeight.w800, 1.1, -0.6, primary),
      headlineMedium: s(26, FontWeight.w800, 1.15, -0.5, primary),
      headlineSmall: s(22, FontWeight.w700, 1.2, -0.3, primary),
      titleLarge: s(20, FontWeight.w700, 1.25, -0.2, primary),
      titleMedium: s(17, FontWeight.w700, 1.3, -0.1, primary),
      titleSmall: s(15, FontWeight.w700, 1.3, 0, primary),
      bodyLarge: s(17, FontWeight.w500, 1.4, 0, primary),
      bodyMedium: s(15, FontWeight.w500, 1.4, 0, secondary),
      bodySmall: s(13, FontWeight.w500, 1.35, 0.1, secondary),
      labelLarge: s(15, FontWeight.w700, 1.2, 0, primary),
      labelMedium: s(13, FontWeight.w600, 1.2, 0.1, secondary),
      labelSmall: s(11, FontWeight.w600, 1.2, 0.4, secondary),
    );
  }

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final dark = b == Brightness.dark;
    final p = Pal(dark);
    final text = _textTheme(p.text, p.text2);

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      scaffoldBackgroundColor: p.bg,
      primaryColor: p.accent,
      splashFactory: InkSparkle.splashFactory,
      colorScheme: ColorScheme(
        brightness: b,
        primary: p.accent,
        onPrimary: p.onAccent,
        secondary: p.success,
        onSecondary: p.onSuccess,
        error: p.danger,
        onError: dark ? Colors.black : Colors.white,
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
          backgroundColor: p.accent,
          foregroundColor: p.onAccent,
          minimumSize: const Size(44, 50),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: p.onAccent,
          elevation: 0,
          minimumSize: const Size(44, 50),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent,
          minimumSize: const Size(44, 44),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.text,
          minimumSize: const Size(44, 50),
          side: BorderSide(color: p.separator),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface2,
        hintStyle: text.bodyLarge?.copyWith(color: p.text3),
        labelStyle: text.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.accent, width: 2),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: p.text3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: text.titleMedium,
        contentTextStyle: text.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? const Color(0xFFF2F1EE) : const Color(0xFF1C1D20),
        contentTextStyle: text.bodyMedium?.copyWith(
          color: dark ? const Color(0xFF141416) : const Color(0xFFF2F1EE),
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: dark ? accentLight : accentDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: p.bg,
        surfaceTintColor: Colors.transparent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.success : null,
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: p.surface,
        headerForegroundColor: p.text,
        todayBorder: BorderSide(color: p.accent),
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

  static Pal of(BuildContext context) =>
      Pal(Theme.of(context).brightness == Brightness.dark);

  Color get bg => dark ? AppTheme.darkBg : AppTheme.lightBg;
  Color get surface => dark ? AppTheme.darkCard : AppTheme.lightCard;
  Color get surface2 => dark ? AppTheme.darkCardSub : AppTheme.lightCardSub;
  Color get separator => dark ? AppTheme.darkBorder : AppTheme.lightBorder;
  Color get text => dark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
  Color get text2 =>
      dark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
  Color get text3 =>
      dark ? AppTheme.darkTextTertiary : AppTheme.lightTextTertiary;
  Color get accent => dark ? AppTheme.accentDark : AppTheme.accentLight;
  Color get onAccent => dark ? AppTheme.onAccentDark : AppTheme.onAccentLight;
  Color get accentTint =>
      dark ? const Color(0xFF3A2416) : const Color(0xFFFBEDE4);
  Color get success => dark ? AppTheme.successDark : AppTheme.successLight;
  Color get onSuccess =>
      dark ? AppTheme.onSuccessDark : AppTheme.onSuccessLight;
  Color get successTint =>
      dark ? const Color(0xFF173226) : const Color(0xFFE3F6EC);
  Color get danger => dark ? AppTheme.dangerDark : AppTheme.dangerLight;
  Color get dangerTint =>
      dark ? const Color(0xFF3A1E20) : const Color(0xFFFDECEC);

  /// Floating chrome (tab bar, header) material colour, drawn over a blur.
  Color get chrome => dark
      ? const Color(0xFF1C1D20).withValues(alpha: 0.78)
      : Colors.white.withValues(alpha: 0.80);
  Color get chromeEdge => dark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.06);

  /// Plate colour for a muscle-group slot.
  PastelChipStyle plate(int index) =>
      AppTheme.pastelStyles[index % AppTheme.pastelStyles.length];
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
