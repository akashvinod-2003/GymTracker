import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_tracker/providers/workout_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/motion.dart';
import '../../widgets/exercise_card.dart';
import '../../widgets/hero_volume_card.dart';
import '../../widgets/quick_entry_sheet.dart';
import 'package:gym_tracker/models/split_group.dart';
import 'package:gym_tracker/screens/todays_workout_flow_screen.dart';
import 'package:gym_tracker/widgets/last_workout_sheet.dart';
import 'package:gym_tracker/widgets/daily_tab_skeleton.dart';

/// Today: one job — log the sets in front of you, one-handed, between lifts.
class DailyTab extends StatelessWidget {
  final VoidCallback onNavigateToSplits;

  const DailyTab({super.key, required this.onNavigateToSplits});

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

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              sliver: SliverToBoxAdapter(
                child: HeroVolumeCard(
                  volume: session.totalVolume,
                  exercisesCount: exercises.length,
                  totalSets: session.totalSets,
                  completedSets: session.completedSets,
                  currentStreak: wp.currentStreak,
                  muscleSetCounts: muscles,
                  onManageSplits: onNavigateToSplits,
                ),
              ),
            ),
            if (exercises.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: Row(
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
                      const Spacer(),
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
                ),
              ),
            if (exercises.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _EmptyState(
                    onStart: () => _openQuickEntry(context),
                    onGuided: () => TodaysWorkoutFlowScreen.start(context),
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
  final VoidCallback onGuided;
  const _EmptyState({required this.onStart, required this.onGuided});

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
            'Start today\'s workout with the guided flow or add exercises directly.',
            textAlign: TextAlign.center,
            style: t.bodyMedium,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onGuided,
              icon: const Icon(Icons.play_circle_fill_rounded),
              label: const Text('Start Guided Workout'),
            ),
          ),
          const SizedBox(height: 10),
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
