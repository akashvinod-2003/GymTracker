import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gym_tracker/providers/workout_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/motion.dart';
import '../../widgets/hero_volume_card.dart';
import 'package:gym_tracker/widgets/daily_tab_skeleton.dart';

/// Today: a glance at the day's progress. Logging lives in the Workout tab.
class DailyTab extends StatelessWidget {
  final VoidCallback onNavigateToSplits;
  final VoidCallback onNavigateToWorkout;

  const DailyTab({
    super.key,
    required this.onNavigateToSplits,
    required this.onNavigateToWorkout,
  });

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkoutProvider>();
    final session = wp.currentSession;
    final exercises = session.exercises;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    if (wp.isLoading && exercises.isEmpty) {
      return const DailyTabSkeleton();
    }

    final streak = _StatTile(
      icon: Icons.local_fire_department_rounded,
      label: 'Streak',
      value: '${wp.currentStreak} d',
      caption: 'Best ${wp.bestStreak} d',
    );
    final weight = _weightTile(wp);

    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(16, 4, 16, 104 + bottomInset),
      children: [
        HeroVolumeCard(
          volume: session.totalVolume,
          exercisesCount: exercises.length,
          totalSets: session.totalSets,
          completedSets: session.completedSets,
          currentStreak: wp.currentStreak,
          muscleSetCounts: wp.muscleSetCountsForCurrentSession,
          onManageSplits: onNavigateToSplits,
        ),
        const SizedBox(height: 16),
        _TodaySplitCard(
          splitName: wp.getSplitNameForDate(wp.currentDate, session: session),
          completedSets: session.completedSets,
          totalSets: session.totalSets,
          inProgress: wp.hasActiveWorkoutDraft,
          onOpen: () {
            Haptics.select();
            onNavigateToWorkout();
          },
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth < 340) {
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
        const SizedBox(height: 12),
        _WeekVolumeStrip(
          loaded: wp.isAnalyticsLoaded,
          loading: wp.isLoadingAnalytics,
          days: wp.lastSevenCalendarDayVolumes,
          onLoad: wp.loadAnalyticsData,
        ),
      ],
    );
  }

  Widget _weightTile(WorkoutProvider wp) {
    if (!wp.isAnalyticsLoaded) {
      return _StatTile(
        icon: Icons.monitor_weight_outlined,
        label: 'Body weight',
        value: wp.isLoadingAnalytics ? '…' : '—',
        caption: wp.isLoadingAnalytics ? 'Loading' : 'Tap to load',
        onTap: wp.isLoadingAnalytics ? null : wp.loadAnalyticsData,
      );
    }
    final current = wp.currentWeightKg;
    final change = wp.totalWeightChangeKg;
    return _StatTile(
      icon: Icons.monitor_weight_outlined,
      label: 'Body weight',
      value: current == null ? '—' : '${current.toStringAsFixed(1)} kg',
      caption: change == null
          ? (current == null ? 'No check-ins yet' : 'First check-in')
          : '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)} kg since start',
    );
  }
}

BoxDecoration _cardDecoration(Pal p) => BoxDecoration(
      color: p.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: p.separator),
    );

class _TodaySplitCard extends StatelessWidget {
  final String splitName;
  final int completedSets;
  final int totalSets;
  final bool inProgress;
  final VoidCallback onOpen;

  const _TodaySplitCard({
    required this.splitName,
    required this.completedSets,
    required this.totalSets,
    required this.inProgress,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final t = Theme.of(context).textTheme;
    final progress = totalSets == 0 ? 0.0 : completedSets / totalSets;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            inProgress ? "Today's split · in progress" : "Today's split",
            style: t.labelMedium?.copyWith(color: p.text3),
          ),
          const SizedBox(height: 2),
          Text(
            splitName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.titleLarge,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: p.accentTint,
              valueColor: AlwaysStoppedAnimation(p.accent),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            totalSets == 0 ? 'No sets planned yet' : '$completedSets/$totalSets sets done',
            style: t.bodySmall?.copyWith(
              color: p.text2,
              fontFeatures: tabularFigures,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onOpen,
              icon: Icon(inProgress ? Icons.play_arrow_rounded : Icons.arrow_forward_rounded),
              label: Text(inProgress ? 'Resume workout' : 'Go to workout'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String caption;
  final VoidCallback? onTap;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final t = Theme.of(context).textTheme;
    final tile = Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: p.accent),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelMedium?.copyWith(color: p.text3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.titleLarge?.copyWith(fontFeatures: tabularFigures),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.bodySmall?.copyWith(color: p.text2),
          ),
        ],
      ),
    );
    if (onTap == null) return tile;
    return Pressable(onTap: onTap!, semanticLabel: '$label: $caption', child: tile);
  }
}

class _WeekVolumeStrip extends StatelessWidget {
  final bool loaded;
  final bool loading;
  final List<MapEntry<DateTime, double>> days;
  final Future<void> Function() onLoad;

  const _WeekVolumeStrip({
    required this.loaded,
    required this.loading,
    required this.days,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final t = Theme.of(context).textTheme;
    final maxVol = days.fold<double>(0, (m, e) => e.value > m ? e.value : m);
    final total = days.fold<double>(0, (s, e) => s + e.value);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Last 7 days', style: t.labelMedium?.copyWith(color: p.text3)),
              ),
              if (loaded)
                Text(
                  '${NumberFormat.compact().format(total)} kg',
                  style: t.labelLarge?.copyWith(fontFeatures: tabularFigures),
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
                        child: CircularProgressIndicator(strokeWidth: 2, color: p.accent),
                      )
                    : const Icon(Icons.bar_chart_rounded, size: 18),
                label: Text(loading ? 'Loading history' : 'Load weekly volume'),
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
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: maxVol == 0 ? 0.04 : (days[i].value / maxVol).clamp(0.04, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: i == days.length - 1 ? p.accent : p.accent.withValues(alpha: 0.35),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat('E').format(days[i].key).substring(0, 1),
                            style: t.labelSmall?.copyWith(color: p.text3),
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
