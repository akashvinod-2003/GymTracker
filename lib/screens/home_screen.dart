import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/quick_entry_sheet.dart';
import 'profile_drawer.dart';
import 'tabs/analytics_tab.dart';
import 'tabs/daily_tab.dart';
import 'tabs/splits_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  bool _hasLoadedAnalytics = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onTabSelected(int index) {
    if (index == 2 && !_hasLoadedAnalytics) {
      _hasLoadedAnalytics = true;
    }
    setState(() {
      _currentTabIndex = index;
    });
  }

  void _openQuickEntry() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const QuickEntrySheet(),
    );
  }

  void _triggerFinishSession() {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 20),
            const SizedBox(width: 8),
            Text(
              'Session saved! 🔥 ${workoutProvider.currentStreak} Day Streak in progress.',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF0F172A),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    final picked = await showDatePicker(
      context: context,
      initialDate: workoutProvider.currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
        return Theme(
          data: isDark ? ThemeData.dark() : ThemeData.light(),
          child: child!,
        );
      },
    );

    if (picked != null) {
      workoutProvider.setDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    final bg = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final cardBg = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

    final formattedDateBtn = DateFormat('MMM d, yyyy').format(workoutProvider.currentDate);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bg,
      drawer: const ProfileDrawer(),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Menu Button
                      InkWell(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.menu_rounded,
                            color: titleColor,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Logo & App Name
                      Expanded(
                        child: Row(
                          children: [
                            const AppLogo(
                              size: 36,
                              borderRadius: 10,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'GymTracker',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  color: titleColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Streak Counter in Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 4),
                            Text(
                              '${workoutProvider.currentStreak}',
                              style: GoogleFonts.plusJakartaSans(
                                color: isDark ? const Color(0xFFFDBA74) : const Color(0xFFEA580C),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Theme Toggle Button
                      InkWell(
                        onTap: () => themeProvider.toggleTheme(context),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor),
                          ),
                          child: Icon(
                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            color: isDark ? const Color(0xFFFBBF24) : AppTheme.tealPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Date Picker Pill
                      InkWell(
                        onTap: () => _pickDate(context),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month_rounded,
                                size: 16,
                                color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                formattedDateBtn,
                                style: GoogleFonts.plusJakartaSans(
                                  color: titleColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab Views
                Expanded(
                  child: IndexedStack(
                    index: _currentTabIndex,
                    children: [
                      DailyTab(
                        onNavigateToSplits: () => _onTabSelected(1),
                      ),
                      const SplitsTab(),
                      _hasLoadedAnalytics
                          ? AnalyticsTab(
                              onSelectSession: () => _onTabSelected(0),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentTabIndex,
        onTabSelected: _onTabSelected,
        onCenterFabPressed: _openQuickEntry,
        onFinishPressed: _triggerFinishSession,
      ),
    );
  }
}
