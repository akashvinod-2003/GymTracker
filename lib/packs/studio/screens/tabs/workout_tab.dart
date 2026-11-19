import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:gym_tracker/providers/workout_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/motion.dart';
import '../../widgets/exercise_card.dart';
import '../../widgets/quick_entry_sheet.dart';
import 'package:gym_tracker/models/split_group.dart';
import 'package:gym_tracker/screens/todays_workout_flow_screen.dart';
import 'package:gym_tracker/widgets/last_workout_sheet.dart';
import 'package:gym_tracker/widgets/daily_tab_skeleton.dart';

/// Workout: one job — log the sets in front of you, one-handed, between lifts.
class WorkoutTab extends StatelessWidget {
  const WorkoutTab({super.key});

  void _openQuickEntry(BuildContext context) {
    Haptics.commit();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      showDragHandle: false,
      builder: (ctx) => const QuickEntrySheet(),
    );
  }

  void _finish(BuildContext context, WorkoutProvider wp) {
    Haptics.success();
    final s = wp.currentSession;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(
          'Workout saved · ${s.completedSets} sets · '
          '${wp.currentStreak} day streak',
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final t = Theme.of(context).textTheme;
    final wp = context.watch<WorkoutProvider>();
    final session = wp.currentSession;
    final exercises = session.exercises;
    final muscles = wp.muscleSetCountsForCurrentSession;
    final muscleOrder = muscles.keys.toList();
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final activeSplit = session.splitId != null
        ? wp.splitGroups.firstWhere(
            (g) => g.id == session.splitId,
            orElse: () => wp.getSplitForDate(wp.currentDate) ?? (wp.splitGroups.isNotEmpty ? wp.splitGroups.first : SplitGroup.defaultGroups.first),
          )
        : (wp.getSplitForDate(wp.currentDate) ?? (wp.splitGroups.isNotEmpty ? wp.splitGroups.first : null));

    if (wp.isLoading && exercises.isEmpty) {
      return const DailyTabSkeleton();
    }
    final splitName = wp.getSplitNameForDate(wp.currentDate, session: session);

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverToBoxAdapter(
                child: _SessionCard(
                  hasDraft: wp.hasActiveWorkoutDraft,
                  title: wp.hasActiveWorkoutDraft
                      ? (wp.activeWorkoutDraft?.splitName ?? splitName)
                      : splitName,
                  detail: wp.hasActiveWorkoutDraft
                      ? '${wp.activeWorkoutDraft!.exercises.length} exercises · '
                          '${wp.activeWorkoutDraft!.completedSets}/${wp.activeWorkoutDraft!.totalSets} sets done'
                      : null,
                  onGuided: () => TodaysWorkoutFlowScreen.start(context),
                  onQuickSetup: () => _openQuickEntry(context),
                ),
              ),
            ),
            if (exercises.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('Exercises', style: t.titleLarge),
                          const SizedBox(width: 8),
                          Text(
                            '${exercises.length}',
                            style: t.titleLarge?.copyWith(
                              color: p.text3,
                              fontFeatures: tabularFigures,
                            ),
                          ),
                          if (activeSplit != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: p.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: p.separator),
                              ),
                              child: Text(
                                activeSplit.effectiveShortName,
                                style: GoogleFonts.plusJakartaSans(
                                  color: p.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (activeSplit != null) ...[
                            TextButton.icon(
                              onPressed: () => LastWorkoutSheet.show(context, activeSplit),
                              icon: const Icon(Icons.history_rounded, size: 16),
                              label: const Text('Last Workout'),
                            ),
                            const SizedBox(width: 8),
                          ],
                          _AddButton(onTap: () => _openQuickEntry(context)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            if (exercises.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _EmptyState(
                    onStart: () => _openQuickEntry(context),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverLayoutBuilder(
                  builder: (context, c) {
                    final wide = c.crossAxisExtent >= 720;
                    Widget card(int i) => ExerciseCard(
                          key: ValueKey(exercises[i].id),
                          exercise: exercises[i],
                          index: i,
                          plateIndex: muscleOrder.indexOf(exercises[i].part),
                        );
                    if (wide) {
                      // Two columns that size to content, so long set lists
                      // never clip the way a fixed-aspect grid does.
                      final left = [for (var i = 0; i < exercises.length; i += 2) i];
                      final right = [for (var i = 1; i < exercises.length; i += 2) i];
                      Widget col(List<int> idx) => Column(
                            children: [
                              for (final i in idx)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: card(i),
                                ),
                            ],
                          );
                      return SliverToBoxAdapter(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: col(left)),
                            const SizedBox(width: 12),
                            Expanded(child: col(right)),
                          ],
                        ),
                      );
                    }
                    return SliverList.separated(
                      itemCount: exercises.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => card(i),
                    );
                  },
                ),
              ),
            if (exercises.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // The next exercise is added where the last one ended,
                      // low on screen within thumb reach.
                      FilledButton.icon(
                        onPressed: () => _openQuickEntry(context),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Exercise'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: session.completedSets == 0
                            ? null
                            : () => _finish(context, wp),
                        icon: const Icon(Icons.flag_rounded, size: 20),
                        label: const Text('Finish Workout'),
                      ),
                    ],
                  ),
                ),
              ),
            // Room for the floating tab bar.
            SliverToBoxAdapter(child: SizedBox(height: 104 + bottomInset)),
          ],
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final t = Theme.of(context).textTheme;
    // Compact tonal button for the section header; the filled one sits below.
    return Pressable(
      onTap: onTap,
      semanticLabel: 'Add Exercise',
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: p.accentTint,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: p.accent, size: 20),
            const SizedBox(width: 4),
            Text('Add', style: t.labelLarge?.copyWith(color: p.accent)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onStart;
  const _EmptyState({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: p.separator),
      ),
      child: Column(
        children: [
          Icon(Icons.fitness_center_rounded, size: 40, color: p.text3),
          const SizedBox(height: 14),
          Text('Nothing logged yet', style: t.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Start the guided workout above, or add exercises directly.',
            textAlign: TextAlign.center,
            style: t.bodyMedium,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Exercise'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final bool hasDraft;
  final String title;
  final String? detail;
  final VoidCallback onGuided;
  final VoidCallback onQuickSetup;

  const _SessionCard({
    required this.hasDraft,
    required this.title,
    required this.detail,
    required this.onGuided,
    required this.onQuickSetup,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [p.accent.withValues(alpha: 0.15), p.surface],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasDraft ? p.accent : p.separator,
          width: hasDraft ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasDraft ? Icons.play_arrow_rounded : Icons.fitness_center_rounded,
                  color: p.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasDraft ? 'IN PROGRESS' : "TODAY'S WORKOUT",
                      style: GoogleFonts.plusJakartaSans(
                        color: p.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.titleMedium,
                    ),
                    if (detail != null)
                      Text(
                        detail!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySmall?.copyWith(color: p.text2),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onGuided,
              icon: Icon(hasDraft ? Icons.play_arrow_rounded : Icons.play_circle_fill_rounded),
              label: Text(hasDraft ? 'Resume' : 'Start Guided Workout'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onQuickSetup,
              icon: const Icon(Icons.bolt_rounded),
              label: const Text('Quick Setup'),
            ),
          ),
        ],
      ),
    );
  }
}
