import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/workout_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_pills_row.dart';
import '../../widgets/hero_volume_card.dart';
import '../../widgets/quick_entry_sheet.dart';
import '../../widgets/daily_tab_skeleton.dart';

/// Home dashboard: today's progress at a glance. Logging lives in the
/// Workout tab.
class DailyTab extends StatelessWidget {
  final VoidCallback onNavigateToSplits;
  final VoidCallback onNavigateToWorkout;

  const DailyTab({
    super.key,
    required this.onNavigateToSplits,
    required this.onNavigateToWorkout,
  });

  void _openQuickEntry(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const QuickEntrySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    final session = workoutProvider.currentSession;
    final exercises = session.exercises;

    if (workoutProvider.isLoading && exercises.isEmpty) {
      return const DailyTabSkeleton();
    }

    final c = _DashColors(isDark);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 96),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Volume Card (with Live Streak Counter & IST)
              HeroVolumeCard(
                volume: session.totalVolume,
                exercisesCount: exercises.length,
                totalSets: session.totalSets,
                completedSets: session.completedSets,
                currentStreak: workoutProvider.currentStreak,
                date: workoutProvider.currentDate,
                onAddPressed: () => _openQuickEntry(context),
                onQuickActionPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🔥 ${workoutProvider.currentStreak} Day Streak! Keep crushing it.'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              _TodaySplitCard(
                colors: c,
                splitName: workoutProvider.getSplitNameForDate(workoutProvider.currentDate, session: session),
                completedSets: session.completedSets,
                totalSets: session.totalSets,
                inProgress: workoutProvider.hasActiveWorkoutDraft,
                onOpen: onNavigateToWorkout,
              ),
              const SizedBox(height: 16),

              LayoutBuilder(
                builder: (context, constraints) {
                  final streak = _StatTile(
                    colors: c,
                    icon: Icons.local_fire_department_rounded,
                    label: 'STREAK',
                    value: '${workoutProvider.currentStreak} d',
                    caption: 'Best ${workoutProvider.bestStreak} d',
                  );
                  final weight = _weightTile(context, workoutProvider, c);
                  if (constraints.maxWidth < 340) {
                    return Column(children: [streak, const SizedBox(height: 12), weight]);
                  }
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: streak),
                        const SizedBox(width: 12),
                        Expanded(child: weight),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              _WeekVolumeStrip(
                colors: c,
                loaded: workoutProvider.isAnalyticsLoaded,
                loading: workoutProvider.isLoadingAnalytics,
                days: workoutProvider.lastSevenCalendarDayVolumes,
                onLoad: workoutProvider.loadAnalyticsData,
              ),
              const SizedBox(height: 16),

              // Muscle Category Ring Carousel
              CategoryPillsRow(
                muscleSetCounts: workoutProvider.muscleSetCountsForCurrentSession,
                onManageTap: onNavigateToSplits,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _weightTile(BuildContext context, WorkoutProvider wp, _DashColors c) {
    if (!wp.isAnalyticsLoaded) {
      return _StatTile(
        colors: c,
        icon: Icons.monitor_weight_rounded,
        label: 'BODY WEIGHT',
        value: wp.isLoadingAnalytics ? '…' : '—',
        caption: wp.isLoadingAnalytics ? 'Loading' : 'Tap to load',
        onTap: wp.isLoadingAnalytics ? null : wp.loadAnalyticsData,
      );
    }
    final current = wp.currentWeightKg;
    final change = wp.totalWeightChangeKg;
    return _StatTile(
      colors: c,
      icon: Icons.monitor_weight_rounded,
      label: 'BODY WEIGHT',
      value: current == null ? '—' : '${current.toStringAsFixed(1)} kg',
      caption: change == null
          ? (current == null ? 'No check-ins yet' : 'First check-in')
          : '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)} kg since start',
    );
  }
}

class _DashColors {
  final bool isDark;
  _DashColors(this.isDark);

  Color get title => isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
  Color get sub => isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B);
  Color get card => isDark ? AppTheme.darkCard : AppTheme.lightCard;
  Color get border => isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
  Color get accent => isDark ? AppTheme.tealLight : AppTheme.tealPrimary;
  Color get accentBg => isDark ? const Color(0xFF0F3635) : AppTheme.tealBg;

  BoxDecoration get cardDecoration => BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      );

  TextStyle get eyebrow => GoogleFonts.plusJakartaSans(
        color: sub,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      );
}

class _TodaySplitCard extends StatelessWidget {
  final _DashColors colors;
  final String splitName;
  final int completedSets;
  final int totalSets;
  final bool inProgress;
  final VoidCallback onOpen;

  const _TodaySplitCard({
    required this.colors,
    required this.splitName,
    required this.completedSets,
    required this.totalSets,
    required this.inProgress,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final progress = totalSets == 0 ? 0.0 : completedSets / totalSets;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: c.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(inProgress ? "TODAY'S SPLIT · IN PROGRESS" : "TODAY'S SPLIT", style: c.eyebrow),
                    const SizedBox(height: 2),
                    Text(
                      splitName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: c.title,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: onOpen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.accent,
                  foregroundColor: c.isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  inProgress ? 'Resume' : 'Go to workout',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: c.accentBg,
              valueColor: AlwaysStoppedAnimation(c.accent),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            totalSets == 0 ? 'No sets planned yet' : '$completedSets/$totalSets sets done',
            style: GoogleFonts.plusJakartaSans(color: c.sub, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final _DashColors colors;
  final IconData icon;
  final String label;
  final String value;
  final String caption;
  final VoidCallback? onTap;

  const _StatTile({
    required this.colors,
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: c.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: c.accent),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: c.eyebrow),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  color: c.title,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(color: c.sub, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekVolumeStrip extends StatelessWidget {
  final _DashColors colors;
  final bool loaded;
  final bool loading;
  final List<MapEntry<DateTime, double>> days;
  final Future<void> Function() onLoad;

  const _WeekVolumeStrip({
    required this.colors,
    required this.loaded,
    required this.loading,
    required this.days,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final maxVol = days.fold<double>(0, (m, e) => e.value > m ? e.value : m);
    final total = days.fold<double>(0, (s, e) => s + e.value);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: c.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('LAST 7 DAYS', style: c.eyebrow)),
              if (loaded)
                Text(
                  '${NumberFormat.compact().format(total)} kg',
                  style: GoogleFonts.plusJakartaSans(color: c.title, fontSize: 13, fontWeight: FontWeight.w800),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (!loaded)
            Center(
              child: TextButton.icon(
                onPressed: loading ? null : onLoad,
                icon: loading
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: c.accent),
                      )
                    : Icon(Icons.bar_chart_rounded, size: 18, color: c.accent),
                label: Text(
                  loading ? 'Loading history' : 'Load weekly volume',
                  style: GoogleFonts.plusJakartaSans(color: c.accent, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            )
          else
            SizedBox(
              height: 92,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < days.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: maxVol == 0 ? 0.04 : (days[i].value / maxVol).clamp(0.04, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: i == days.length - 1 ? c.accent : c.accent.withValues(alpha: 0.35),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat('E').format(days[i].key).substring(0, 1),
                            style: GoogleFonts.plusJakartaSans(color: c.sub, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
