import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/exercise_progress_comparison.dart';
import '../models/split_group.dart';
import '../models/workout_session.dart';
import '../providers/theme_provider.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';

/// Modal bottom sheet displaying the last completed workout session for a split,
/// with exercise details, sets, reps, weights, and progress comparison metrics.
class LastWorkoutSheet extends StatelessWidget {
  final SplitGroup split;
  final WorkoutSession? session;

  const LastWorkoutSheet({
    super.key,
    required this.split,
    this.session,
  });

  static Future<void> show(BuildContext context, SplitGroup split, {WorkoutSession? session}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LastWorkoutSheet(split: split, session: session),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);

    final resolvedSession = session ??
        workoutProvider.getLastWorkoutForSplit(split.id, splitName: split.name);

    final bg = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subColor = isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B);

    // If session exists, find the session before it for progress comparisons
    WorkoutSession? precedingSession;
    SessionProgressComparison? progress;
    if (resolvedSession != null) {
      precedingSession = workoutProvider.getPreviousWorkoutBeforeSession(
        resolvedSession,
        splitId: split.id,
        splitName: split.name,
      );
      progress = SessionProgressComparison.compute(
        current: resolvedSession,
        previous: precedingSession,
        allHistoricalSessions: workoutProvider.sessions.values.toList(),
      );
    }

    String formattedDate = '';
    String relativeTime = '';
    if (resolvedSession != null) {
      try {
        final parsedDate = DateTime.parse(resolvedSession.date);
        formattedDate = DateFormat('EEEE, MMM d, yyyy').format(parsedDate);
        final diffDays = DateTime.now().difference(parsedDate).inDays;
        if (diffDays == 0) {
          relativeTime = 'Today';
        } else if (diffDays == 1) {
          relativeTime = 'Yesterday';
        } else {
          relativeTime = '$diffDays days ago';
        }
      } catch (_) {
        formattedDate = resolvedSession.date;
      }
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        maxWidth: 750,
      ),
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F3635) : AppTheme.tealBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Last Workout',
                              style: GoogleFonts.plusJakartaSans(
                                color: titleColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF162344) : const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? const Color(0xFF312E81) : const Color(0xFFC7D2FE),
                              ),
                            ),
                            child: Text(
                              split.name,
                              style: GoogleFonts.plusJakartaSans(
                                color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4F46E5),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (formattedDate.isNotEmpty)
                        Text(
                          '$formattedDate • $relativeTime',
                          style: GoogleFonts.plusJakartaSans(
                            color: subColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: subColor,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Flexible(
            child: resolvedSession == null
                ? _buildEmptyState(isDark, titleColor, subColor)
                : _buildSessionDetails(
                    context,
                    resolvedSession,
                    precedingSession,
                    progress,
                    isDark,
                    titleColor,
                    subColor,
                    borderColor,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color titleColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162344) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_note_rounded,
              size: 32,
              color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No previous workout found for this split',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: titleColor,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This will be your first session for ${split.name}. Log your exercises today to establish your benchmark.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: subColor,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSessionDetails(
    BuildContext context,
    WorkoutSession session,
    WorkoutSession? preceding,
    SessionProgressComparison? progress,
    bool isDark,
    Color titleColor,
    Color subColor,
    Color borderColor,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat Highlights
          Row(
            children: [
              _buildStatCard(
                title: 'Volume',
                value: '${session.totalVolume.toStringAsFixed(0)} kg',
                subtitle: progress?.volumeDiff != null && progress!.volumeDiff != 0
                    ? '${progress.volumeDiff! > 0 ? "+" : ""}${progress.volumeDiff!.toStringAsFixed(0)} kg'
                    : null,
                isPositive: (progress?.volumeDiff ?? 0) >= 0,
                icon: Icons.fitness_center_rounded,
                isDark: isDark,
                borderColor: borderColor,
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                title: 'Sets',
                value: '${session.completedSets} / ${session.totalSets}',
                subtitle: progress?.setsDiff != null && progress!.setsDiff != 0
                    ? '${progress.setsDiff! > 0 ? "+" : ""}${progress.setsDiff} sets'
                    : null,
                isPositive: (progress?.setsDiff ?? 0) >= 0,
                icon: Icons.repeat_rounded,
                isDark: isDark,
                borderColor: borderColor,
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                title: 'Exercises',
                value: '${session.exercises.length}',
                subtitle: progress != null && progress.personalBestsCount > 0
                    ? '${progress.personalBestsCount} PBs 🏆'
                    : null,
                isPositive: true,
                icon: Icons.trending_up_rounded,
                isDark: isDark,
                borderColor: borderColor,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Exercises Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EXERCISES PERFORMED',
                style: GoogleFonts.plusJakartaSans(
                  color: subColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${session.exercises.length} total',
                style: GoogleFonts.plusJakartaSans(
                  color: subColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Exercise List Cards
          ...session.exercises.map((exercise) {
            final comp = progress?.comparisons.firstWhere(
              (c) => c.exerciseName.trim().toLowerCase() == exercise.name.trim().toLowerCase(),
              orElse: () => ExerciseProgressComparison.compute(currentExercise: exercise),
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF162344) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise Name & Equipment / PR Tag
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          exercise.name,
                          style: GoogleFonts.plusJakartaSans(
                            color: titleColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (comp != null && comp.isPersonalBest) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🏆', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 4),
                              Text(
                                'Personal Best',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF92400E),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F3635) : AppTheme.tealBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          exercise.equipment,
                          style: GoogleFonts.plusJakartaSans(
                            color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Progress Comparison Badge (if historical comparison available)
                  if (comp != null && comp.hasPreviousData) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (comp.weightDiff != null && comp.weightDiff != 0) ...[
                          _buildDiffBadge(
                            label: '${comp.weightDiff! > 0 ? "+" : ""}${comp.weightDiff!.toStringAsFixed(1)} kg',
                            isPositive: comp.weightDiff! > 0,
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (comp.repsDiff != null && comp.repsDiff != 0) ...[
                          _buildDiffBadge(
                            label: '${comp.repsDiff! > 0 ? "+" : ""}${comp.repsDiff} reps',
                            isPositive: comp.repsDiff! > 0,
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (comp.setsDiff != null && comp.setsDiff != 0) ...[
                          _buildDiffBadge(
                            label: '${comp.setsDiff! > 0 ? "+" : ""}${comp.setsDiff} sets',
                            isPositive: comp.setsDiff! > 0,
                          ),
                        ],
                      ],
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Sets Wrap / Grid
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: exercise.sets.map((s) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: s.completed
                                ? (isDark ? const Color(0xFF134E4A) : const Color(0xFF99F6E4))
                                : borderColor,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Set ${s.setNumber}: ',
                              style: GoogleFonts.plusJakartaSans(
                                color: subColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${s.weight.toStringAsFixed(s.weight % 1 == 0 ? 0 : 1)} kg × ${s.reps}',
                              style: GoogleFonts.plusJakartaSans(
                                color: titleColor,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (s.completed) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF10B981)),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? subtitle,
    required bool isPositive,
    required IconData icon,
    required bool isDark,
    required Color borderColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF162344) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDiffBadge({required String label, required bool isPositive}) {
    final color = isPositive ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
