import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/log_weight_dialog.dart';
import '../widgets/update_prompt_button.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final user = authProvider.user;

    final currentWeight = workoutProvider.currentWeightKg;
    final latestWeightEntry = workoutProvider.latestBodyWeightEntry;

    final drawerBg = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subColor = isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B);

    return Drawer(
      backgroundColor: drawerBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AppLogo(
                        size: 28,
                        borderRadius: 8,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'GymTracker',
                        style: GoogleFonts.plusJakartaSans(
                          color: titleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.orangeStart, AppTheme.orangeEnd],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.orangeEnd.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          (user?.displayName.isNotEmpty ?? false)
                              ? user!.displayName[0].toUpperCase()
                              : 'A',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'Athlete',
                              style: GoogleFonts.plusJakartaSans(
                                color: titleColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              user?.email ?? 'athlete@gymtracker.app',
                              style: GoogleFonts.plusJakartaSans(
                                color: subColor,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Body Weight Quick Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF162344) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F1A33) : const Color(0xFFEEF2F6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.monitor_weight_outlined,
                            size: 18,
                            color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BODY WEIGHT',
                                style: GoogleFonts.plusJakartaSans(
                                  color: subColor,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentWeight != null
                                    ? '${currentWeight.toStringAsFixed(1)} kg'
                                    : 'Not recorded yet',
                                style: GoogleFonts.plusJakartaSans(
                                  color: titleColor,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (latestWeightEntry != null)
                                Text(
                                  'Checked ${DateFormat('MMM d').format(latestWeightEntry.date)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: subColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // close drawer
                            showDialog(
                              context: context,
                              builder: (ctx) => LogWeightDialog(initialWeight: currentWeight),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: isDark ? const Color(0xFF0F3635) : AppTheme.tealBg,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            currentWeight != null ? 'Update' : 'Log',
                            style: GoogleFonts.plusJakartaSans(
                              color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: borderColor, height: 1),

            // Settings & Preferences
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'APPEARANCE',
                    style: GoogleFonts.plusJakartaSans(
                      color: subColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Theme Pack Selector
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF162344) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        _ThemeOptionButton(
                          title: 'Classic',
                          icon: Icons.palette_outlined,
                          isSelected: themeProvider.themePack == AppThemePack.classic,
                          onTap: () => themeProvider.setThemePack(AppThemePack.classic),
                        ),
                        _ThemeOptionButton(
                          title: 'Studio',
                          icon: Icons.auto_awesome_rounded,
                          isSelected: themeProvider.themePack == AppThemePack.studio,
                          onTap: () => themeProvider.setThemePack(AppThemePack.studio),
                        ),
                        _ThemeOptionButton(
                          title: 'Classic',
                          icon: Icons.bolt_rounded,
                          isSelected: themeProvider.themePack == AppThemePack.classic,
                          onTap: () => themeProvider.setThemePack(AppThemePack.classic),
                        ),
                        _ThemeOptionButton(
                          title: 'Turbo',
                          icon: Icons.bolt_rounded,
                          isSelected: themeProvider.themePack == AppThemePack.turbo,
                          onTap: () => themeProvider.setThemePack(AppThemePack.turbo),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Dark / Light Mode Selector
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF162344) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        _ThemeOptionButton(
                          title: 'Light',
                          icon: Icons.light_mode_rounded,
                          isSelected: themeProvider.themeMode == ThemeMode.light,
                          onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                        ),
                        _ThemeOptionButton(
                          title: 'Dark',
                          icon: Icons.dark_mode_rounded,
                          isSelected: themeProvider.themeMode == ThemeMode.dark,
                          onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                        ),
                        _ThemeOptionButton(
                          title: 'System',
                          icon: Icons.brightness_auto_rounded,
                          isSelected: themeProvider.themeMode == ThemeMode.system,
                          onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // PWA & App Logo Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PWA & App Logo',
                            style: GoogleFonts.plusJakartaSans(
                              color: titleColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Icon for PWA install (Android & iOS)',
                            style: GoogleFonts.plusJakartaSans(
                              color: subColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const AppLogo(size: 26, showContainer: false),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF162344) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        _ThemeOptionButton(
                          title: 'Auto',
                          icon: Icons.sync_rounded,
                          isSelected: themeProvider.pwaIconMode == PwaIconMode.auto,
                          onTap: () => themeProvider.setPwaIconMode(PwaIconMode.auto),
                        ),
                        _ThemeOptionButton(
                          title: 'Dark',
                          icon: Icons.shield_moon_rounded,
                          isSelected: themeProvider.pwaIconMode == PwaIconMode.dark,
                          onTap: () => themeProvider.setPwaIconMode(PwaIconMode.dark),
                        ),
                        _ThemeOptionButton(
                          title: 'Light',
                          icon: Icons.wb_sunny_rounded,
                          isSelected: themeProvider.pwaIconMode == PwaIconMode.light,
                          onTap: () => themeProvider.setPwaIconMode(PwaIconMode.light),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const UpdatePromptButton(),

            const Spacer(),

            Divider(color: borderColor, height: 1),

            // Sign Out Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: isDark ? const Color(0xFF1E1424) : const Color(0xFFFFF1F2),
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: Text(
                  'Sign Out',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.redAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  authProvider.signOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOptionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF0F1A33) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
