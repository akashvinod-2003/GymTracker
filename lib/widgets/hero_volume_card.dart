import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/streak_service.dart';
import '../theme/app_theme.dart';

class HeroVolumeCard extends StatelessWidget {
  final double volume;
  final int exercisesCount;
  final int totalSets;
  final int completedSets;
  final int currentStreak;
  final DateTime date;
  final VoidCallback onAddPressed;
  final VoidCallback onQuickActionPressed;

  const HeroVolumeCard({
    super.key,
    required this.volume,
    required this.exercisesCount,
    required this.totalSets,
    required this.completedSets,
    required this.currentStreak,
    required this.date,
    required this.onAddPressed,
    required this.onQuickActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final todayKeyIST = StreakService.todayKeyIST;
    final isToday = DateFormat('yyyy-MM-dd').format(date) == todayKeyIST;

    final formattedDate = isToday
        ? 'Today (IST) • ${DateFormat('EEE, MMM d').format(date)}'
        : 'Logged for ${DateFormat('EEE, MMM d').format(date)}';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const RadialGradient(
          center: Alignment(0.85, -0.6),
          radius: 1.2,
          colors: [
            AppTheme.heroBlue1,
            AppTheme.heroBlue2,
            AppTheme.heroBlue3,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C2563).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ambient Glow Circle
          Positioned(
            right: -24,
            top: -24,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withValues(alpha: 0.12),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Tag, Streak & Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Daily Volume Tag & Pulsing Dot
                    Flexible(
                      child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF34D399),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF34D399),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                          'DAILY LIFTED VOLUME',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFBFDBFE),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                        ),
                      ],
                    ),
                    ),
                    const SizedBox(width: 8),

                    // Actions & Streak Badge
                    Row(
                      children: [
                        // Streak Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: currentStreak > 0
                                  ? AppTheme.orangeEnd.withValues(alpha: 0.6)
                                  : Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentStreak > 0 ? '🔥' : '⚡',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$currentStreak d streak',
                                style: GoogleFonts.plusJakartaSans(
                                  color: currentStreak > 0
                                      ? const Color(0xFFFDBA74)
                                      : const Color(0xFFBFDBFE),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _HeroActionButton(
                          icon: Icons.bolt_rounded,
                          iconColor: const Color(0xFFFBBF24),
                          onTap: onQuickActionPressed,
                        ),
                        const SizedBox(width: 6),
                        _HeroActionButton(
                          icon: Icons.add_rounded,
                          iconColor: Colors.white,
                          backgroundColor: const Color(0xFF2563EB),
                          onTap: onAddPressed,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Big Volume Metric
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      NumberFormat('#,###').format(volume.round()),
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'kg',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFBFDBFE),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF93C5FD).withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // 3-Column Pill Sub-Card
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      _StatColumn(
                        count: '$exercisesCount',
                        label: 'EXERCISES',
                        valueColor: Colors.white,
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      _StatColumn(
                        count: '$totalSets',
                        label: 'TOTAL SETS',
                        valueColor: Colors.white,
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      _StatColumn(
                        count: '$completedSets',
                        label: 'FINISHED',
                        valueColor: const Color(0xFF6EE7B7),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final VoidCallback onTap;

  const _HeroActionButton({
    required this.icon,
    required this.iconColor,
    this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 18),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String count;
  final String label;
  final Color valueColor;

  const _StatColumn({
    required this.count,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: GoogleFonts.plusJakartaSans(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFBFDBFE),
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
