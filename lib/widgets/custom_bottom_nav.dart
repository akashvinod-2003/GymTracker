import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final VoidCallback onCenterFabPressed;
  final VoidCallback onFinishPressed;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onCenterFabPressed,
    required this.onFinishPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);

    final navBg = isDark
        ? const Color(0xFF131D36).withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.95);
    final borderColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);
    final activeColor = isDark ? AppTheme.tealLight : AppTheme.tealPrimary;
    final inactiveColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Pill Container
            Container(
              height: 64,
              decoration: BoxDecoration(
                color: navBg,
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Tab 0: Daily
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Daily',
                    isSelected: currentIndex == 0,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    onTap: () => onTabSelected(0),
                  ),

                  // Tab 1: Splits
                  _NavItem(
                    icon: Icons.grid_view_rounded,
                    label: 'Splits',
                    isSelected: currentIndex == 1,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    onTap: () => onTabSelected(1),
                  ),

                  // Center Spacer for FAB
                  const SizedBox(width: 54),

                  // Tab 2: Analytics
                  _NavItem(
                    icon: Icons.pie_chart_rounded,
                    label: 'Analytics',
                    isSelected: currentIndex == 2,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    onTap: () => onTabSelected(2),
                  ),

                  // Tab 3: Finish
                  _NavItem(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Finish',
                    isSelected: false,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    onTap: onFinishPressed,
                  ),
                ],
              ),
            ),

            // Iconic Center Floating Orange FAB Button
            Positioned(
              top: -18,
              child: GestureDetector(
                onTap: onCenterFabPressed,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.orangeStart,
                        AppTheme.orangeEnd,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.orangeEnd.withValues(alpha: 0.50),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
