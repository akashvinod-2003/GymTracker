import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_tracker/providers/theme_provider.dart';

/// A theme-adaptive logo & brand icon widget for GymTracker / PulseFit.
/// 
/// Renders the logo directly with zero extra artificial boxes or borders.
class AppLogo extends StatelessWidget {
  /// The width and height of the logo widget.
  final double size;

  /// Optional manual override for dark mode (defaults to context-aware theme).
  final bool? isDark;

  /// How the image should be inscribed into the box.
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.size = 36,
    this.isDark,
    this.fit = BoxFit.contain,
    // Kept for backward compatibility with previous call sites
    double? borderRadius,
    bool showContainer = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    final effectiveDark = isDark ?? themeProvider.isDarkLogo(context);

    final assetPath =
        effectiveDark ? 'assets/logo_v2_dark.png' : 'assets/logo_v2_light.png';

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Image.asset(
          assetPath,
          key: ValueKey<String>(assetPath),
          width: size,
          height: size,
          fit: fit,
          errorBuilder: (_, _, _) => Image.asset(
            'assets/logo.png',
            width: size,
            height: size,
            fit: fit,
          ),
        ),
      ),
    );
  }
}
