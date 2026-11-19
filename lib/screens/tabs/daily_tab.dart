import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/workout_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_pills_row.dart';
import '../../widgets/exercise_card.dart';
import '../../widgets/hero_volume_card.dart';
import '../../widgets/quick_entry_sheet.dart';
import '../../widgets/daily_tab_skeleton.dart';
import '../../widgets/last_workout_sheet.dart';
import '../todays_workout_flow_screen.dart';
import '../../models/split_group.dart';

class DailyTab extends StatelessWidget {
  final VoidCallback onNavigateToSplits;

  const DailyTab({
    super.key,
    required this.onNavigateToSplits,
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
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subColor = isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B);
    final cardBg = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    if (workoutProvider.isLoading && exercises.isEmpty) {
      return const DailyTabSkeleton();
    }

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

              // Muscle Category Ring Carousel
              CategoryPillsRow(
                muscleSetCounts: workoutProvider.muscleSetCountsForCurrentSession,
                onManageTap: onNavigateToSplits,
              ),
              const SizedBox(height: 20),

              // Today's Exercises Section Header
              Builder(
                builder: (context) {
                  final activeSplit = session.splitId != null
                      ? workoutProvider.splitGroups.firstWhere(
                          (g) => g.id == session.splitId,
                          orElse: () => workoutProvider.getSplitForDate(workoutProvider.currentDate) ?? (workoutProvider.splitGroups.isNotEmpty ? workoutProvider.splitGroups.first : SplitGroup.defaultGroups.first),
                        )
                      : (workoutProvider.getSplitForDate(workoutProvider.currentDate) ?? (workoutProvider.splitGroups.isNotEmpty ? workoutProvider.splitGroups.first : null));

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Today's Exercises",
                            style: GoogleFonts.plusJakartaSans(
                              color: titleColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F3635) : AppTheme.tealBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? const Color(0xFF134E4A) : const Color(0xFF99F6E4),
                              ),
                            ),
                            child: Text(
                              '${exercises.length}',
                              style: GoogleFonts.plusJakartaSans(
                                color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (activeSplit != null) ...[
                            InkWell(
                              onTap: () => LastWorkoutSheet.show(context, activeSplit),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: borderColor),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.history_rounded,
                                      size: 15,
                                      color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Last Workout',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: titleColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          InkWell(
                            onTap: () => _openQuickEntry(context),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add_rounded,
                                    size: 15,
                                    color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Add Exercise',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: titleColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),

              // Exercise Items or Empty State
              if (exercises.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F3635) : AppTheme.tealBg,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.fitness_center_rounded,
                          size: 30,
                          color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'No exercises logged yet',
                        style: GoogleFonts.plusJakartaSans(
                          color: titleColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap the orange plus button below or quick setup to start tracking your sets today.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: subColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => TodaysWorkoutFlowScreen.start(context),
                            icon: const Icon(Icons.play_circle_fill_rounded, size: 17),
                            label: const Text('Start Guided Workout'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                              foregroundColor: isDark ? Colors.black : Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              elevation: 2,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _openQuickEntry(context),
                            icon: const Icon(Icons.bolt_rounded, size: 16),
                            label: const Text('Quick Setup'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 720;
                    if (isDesktop) {
                      // 2-column grid layout on PC/Desktop
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.15,
                        ),
                        itemCount: exercises.length,
                        itemBuilder: (context, idx) {
                          return ExerciseCard(
                            exercise: exercises[idx],
                            index: idx,
                          );
                        },
                      );
                    } else {
                      // 1-column list layout on mobile
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: exercises.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, idx) {
                          return ExerciseCard(
                            exercise: exercises[idx],
                            index: idx,
                          );
                        },
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
