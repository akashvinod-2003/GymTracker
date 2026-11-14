import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../theme/motion.dart';

/// Session summary. The signature element: a weight plate whose rim fills in
/// segments as sets are finished, one plate colour per muscle group. It merges
/// the old volume hero and the muscle-group card into one glanceable object.
class HeroVolumeCard extends StatelessWidget {
  final double volume;
  final int exercisesCount;
  final int totalSets;
  final int completedSets;
  final int currentStreak;
  final Map<String, int> muscleSetCounts;
  final VoidCallback onManageSplits;

  const HeroVolumeCard({
    super.key,
    required this.volume,
    required this.exercisesCount,
    required this.totalSets,
    required this.completedSets,
    required this.currentStreak,
    required this.muscleSetCounts,
    required this.onManageSplits,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final t = Theme.of(context).textTheme;
    final progress = totalSets == 0 ? 0.0 : completedSets / totalSets;
    final groups = muscleSetCounts.entries.toList();
    final sum = groups.fold<int>(0, (a, e) => a + e.value);
    final segments = [
      for (var i = 0; i < groups.length; i++)
        (sum == 0 ? 0.0 : groups[i].value / sum, p.plate(i).text(p.dark)),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: p.separator),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Semantics(
                label: '$completedSets of $totalSets sets finished',
                child: ExcludeSemantics(
                  child: SpringValue(
                    value: progress,
                    builder: (_, v) => _PlateRing(
                      progress: v.clamp(0.0, 1.0),
                      segments: segments,
                      track: p.surface2,
                      hub: p.bg,
                      fallback: p.success,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$completedSets/$totalSets',
                            style: t.titleLarge?.copyWith(
                              fontFeatures: tabularFigures,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text('sets', style: t.labelSmall),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Volume lifted', style: t.labelMedium),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: NumberFormat('#,###').format(volume.round()),
                            style: t.displayMedium
                                ?.copyWith(fontFeatures: tabularFigures),
                          ),
                          TextSpan(
                            text: ' kg',
                            style: t.titleMedium?.copyWith(color: p.text2),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Chip(
                          icon: Icons.local_fire_department_rounded,
                          text: currentStreak == 1
                              ? '1 day streak'
                              : '$currentStreak day streak',
                          fg: currentStreak > 0 ? p.accent : p.text2,
                          bg: currentStreak > 0 ? p.accentTint : p.surface2,
                        ),
                        _Chip(
                          icon: Icons.fitness_center_rounded,
                          text: exercisesCount == 1
                              ? '1 exercise'
                              : '$exercisesCount exercises',
                          fg: p.text2,
                          bg: p.surface2,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (groups.isNotEmpty) ...[
            const SizedBox(height: 18),
            Divider(color: p.separator, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 14,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < groups.length; i++)
                        _Legend(
                          color: p.plate(i).text(p.dark),
                          label: groups[i].key,
                          sets: groups[i].value,
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onManageSplits,
                  child: const Text('Splits'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color fg;
  final Color bg;

  const _Chip({
    required this.icon,
    required this.text,
    required this.fg,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: fg),
          const SizedBox(width: 5),
          Text(
            text,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final int sets;

  const _Legend({required this.color, required this.label, required this.sets});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final p = Pal.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          _cap(label),
          style: t.labelMedium?.copyWith(color: p.text, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 4),
        Text(
          '$sets',
          style: t.labelMedium?.copyWith(fontFeatures: tabularFigures),
        ),
      ],
    );
  }
}

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// A plate seen face-on: a thick rim (the track), a raised collar, and a hub.
/// The rim fills clockwise from 12 o'clock to [progress], coloured by segment.
class _PlateRing extends StatelessWidget {
  final double progress;
  final List<(double, Color)> segments;
  final Color track;
  final Color hub;
  final Color fallback;
  final Widget child;

  const _PlateRing({
    required this.progress,
    required this.segments,
    required this.track,
    required this.hub,
    required this.fallback,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 112,
      child: CustomPaint(
        painter: _PlatePainter(progress, segments, track, hub, fallback),
        child: Center(child: child),
      ),
    );
  }
}

class _PlatePainter extends CustomPainter {
  final double progress;
  final List<(double, Color)> segments;
  final Color track;
  final Color hub;
  final Color fallback;

  _PlatePainter(this.progress, this.segments, this.track, this.hub, this.fallback);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final c = size.center(Offset.zero);
    final r = size.width / 2 - stroke / 2;
    final rect = Rect.fromCircle(center: c, radius: r);

    // Rim track
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    // Filled rim, split into muscle-group colours along the swept arc.
    final sweepTotal = 2 * math.pi * progress;
    if (sweepTotal > 0) {
      final segs = segments.isEmpty ? [(1.0, fallback)] : segments;
      var start = -math.pi / 2;
      var remaining = sweepTotal;
      for (final (share, color) in segs) {
        if (remaining <= 0) break;
        final sweep = math.min(share * 2 * math.pi, remaining);
        canvas.drawArc(
          rect,
          start,
          sweep,
          false,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke
            ..strokeCap = StrokeCap.butt,
        );
        start += sweep;
        remaining -= sweep;
      }
    }

    // Collar ring and hub, like the inner lip of a plate.
    canvas.drawCircle(
      c,
      r - stroke / 2 - 4,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(c, r - stroke / 2 - 5, Paint()..color = hub);
  }

  @override
  bool shouldRepaint(covariant _PlatePainter old) =>
      old.progress != progress ||
      old.segments != segments ||
      old.track != track ||
      old.fallback != fallback;
}
