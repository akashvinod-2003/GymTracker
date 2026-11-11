import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand & Accent Colors
  static const Color tealPrimary = Color(0xFF0D9488);
  static const Color tealLight = Color(0xFF2DD4BF);
  static const Color tealBg = Color(0xFFE0F7F3);

  static const Color orangeStart = Color(0xFFFF944D);
  static const Color orangeEnd = Color(0xFFFA5C1B);

  static const Color heroBlue1 = Color(0xFF1D4ED8);
  static const Color heroBlue2 = Color(0xFF0C2563);
  static const Color heroBlue3 = Color(0xFF06153D);

  // Light Palette
  static const Color lightBg = Color(0xFFF1F5F9);
  static const Color lightCard = Colors.white;
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Dark Palette
  static const Color darkBg = Color(0xFF0B1329);
  static const Color darkCard = Color(0xFF131E38);
  static const Color darkCardSub = Color(0xFF1B284B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF1E293B);

  // Pastels
  static const List<PastelChipStyle> pastelStyles = [
    PastelChipStyle(
      bgLight: Color(0xFFE0F7F3),
      borderLight: Color(0xFF99F6E4),
      textLight: Color(0xFF0D9488),
      bgDark: Color(0xFF0F3635),
      borderDark: Color(0xFF134E4A),
      textDark: Color(0xFF2DD4BF),
      icon: Icons.fitness_center_rounded,
    ),
    PastelChipStyle(
      bgLight: Color(0xFFE0F2FE),
      borderLight: Color(0xFFBAE6FD),
      textLight: Color(0xFF0284C7),
      bgDark: Color(0xFF0C2E4E),
      borderDark: Color(0xFF0369A1),
      textDark: Color(0xFF38BDF8),
      icon: Icons.album_rounded,
    ),
    PastelChipStyle(
      bgLight: Color(0xFFFEF3C7),
      borderLight: Color(0xFFFDE68A),
      textLight: Color(0xFFD97706),
      bgDark: Color(0xFF452B05),
      borderDark: Color(0xFFB45309),
      textDark: Color(0xFFFBBF24),
      icon: Icons.bolt_rounded,
    ),
    PastelChipStyle(
      bgLight: Color(0xFFFFE4E6),
      borderLight: Color(0xFFFECDD3),
      textLight: Color(0xFFE11D48),
      bgDark: Color(0xFF4C0519),
      borderDark: Color(0xFFBE123C),
      textDark: Color(0xFFFB7185),
      icon: Icons.favorite_rounded,
    ),
    PastelChipStyle(
      bgLight: Color(0xFFF3E8FF),
      borderLight: Color(0xFFE9D5FF),
      textLight: Color(0xFF9333EA),
      bgDark: Color(0xFF3B0764),
      borderDark: Color(0xFF7E22CE),
      textDark: Color(0xFFC084FC),
      icon: Icons.layers_rounded,
    ),
  ];

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: tealPrimary,
      colorScheme: const ColorScheme.light(
        primary: tealPrimary,
        secondary: orangeEnd,
        surface: lightCard,
        surfaceContainerHighest: Color(0xFFF8FAFC),
        onPrimary: Colors.white,
        onSurface: lightTextPrimary,
        outline: lightBorder,
      ),
      cardColor: lightCard,
      dividerColor: lightBorder,
      appBarTheme: AppBarTheme(
        backgroundColor: lightBg,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: lightTextPrimary,
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        titleLarge: GoogleFonts.plusJakartaSans(
          color: lightTextPrimary,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          color: lightTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: lightTextSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: tealLight,
      colorScheme: const ColorScheme.dark(
        primary: tealLight,
        secondary: orangeStart,
        surface: darkCard,
        surfaceContainerHighest: darkCardSub,
        onPrimary: Colors.black,
        onSurface: darkTextPrimary,
        outline: darkBorder,
      ),
      cardColor: darkCard,
      dividerColor: darkBorder,
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: darkTextPrimary,
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        titleLarge: GoogleFonts.plusJakartaSans(
          color: darkTextPrimary,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          color: darkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: darkTextSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

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
