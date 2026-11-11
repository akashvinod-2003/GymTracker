import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/workout_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/body_weight_analytics_view.dart';
import '../../widgets/streak_milestone_dialog.dart';
import '../../widgets/workout_calendar_card.dart';

class AnalyticsTab extends StatefulWidget {
  final VoidCallback onSelectSession;

  const AnalyticsTab({
    super.key,
    required this.onSelectSession,
  });

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  int _selectedSection = 0; // 0: Workout Performance, 1: Body Weight

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkMilestone();
    });
  }

  void _checkMilestone() async {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    final milestone = await workoutProvider.checkAndMarkStreakMilestone();
    if (milestone != null && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => StreakMilestoneDialog(streakDays: milestone),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    final cardBg = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subColor = isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B);

    final volumeData = workoutProvider.recentSevenDaysVolumes;
    final muscleCounts = workoutProvider.allTimeMuscleSetCounts;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 96),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Segmented Switcher: Workout Volume vs Body Weight Analytics
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF162344) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _AnalyticsTabSwitchItem(
                        label: 'Workout Volume',
                        icon: Icons.fitness_center_rounded,
                        isSelected: _selectedSection == 0,
                        onTap: () => setState(() => _selectedSection = 0),
                        isDark: isDark,
                      ),
                    ),
                    Expanded(
                      child: _AnalyticsTabSwitchItem(
                        label: 'Body Weight',
                        icon: Icons.monitor_weight_outlined,
                        isSelected: _selectedSection == 1,
                        onTap: () => setState(() => _selectedSection = 1),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_selectedSection == 1)
                const BodyWeightAnalyticsView()
              else ...[
                // Dark Styled Volume Performance Card
                Container(
                  padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1329),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF1E293B)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VOLUME PERFORMANCE',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF94A3B8),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Lift Progress',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF042F2E),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF115E59)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.trending_up_rounded, size: 14, color: Color(0xFF2DD4BF)),
                              const SizedBox(width: 4),
                              Text(
                                'Active',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF2DD4BF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Line Chart
                    SizedBox(
                      height: 180,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 500,
                            getDrawingHorizontalLine: (val) => const FlLine(
                              color: Color(0x1AFFFFFF),
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 38,
                                getTitlesWidget: (val, meta) {
                                  return Text(
                                    val >= 1000 ? '${(val / 1000).toStringAsFixed(1)}k' : '${val.toInt()}',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF94A3B8),
                                      fontSize: 10,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 24,
                                interval: 1,
                                getTitlesWidget: (val, meta) {
                                  final idx = val.toInt();
                                  if (idx >= 0 && idx < volumeData.length) {
                                    final parts = volumeData[idx].key.split('-');
                                    final label = parts.length >= 3 ? '${parts[1]}/${parts[2]}' : volumeData[idx].key;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        label,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFF94A3B8),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: (volumeData.length - 1).toDouble().clamp(1.0, 10.0),
                          minY: 0,
                          maxY: _calculateMaxY(volumeData),
                          lineBarsData: [
                            LineChartBarData(
                              spots: volumeData.asMap().entries.map((entry) {
                                return FlSpot(entry.key.toDouble(), entry.value.value);
                              }).toList(),
                              isCurved: true,
                              color: const Color(0xFF2DD4BF),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: const Color(0xFF2DD4BF),
                                    strokeWidth: 1.5,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0xFF2DD4BF).withValues(alpha: 0.15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Interactive Streak Calendar (Replacing the old log list)
              WorkoutCalendarCard(
                sessions: workoutProvider.sessions,
                selectedDateKey: workoutProvider.currentDateKey,
                onDateSelected: (date) {
                  workoutProvider.setDate(date);
                  widget.onSelectSession();
                },
              ),
              const SizedBox(height: 16),

              // Donut Body Part Distribution Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(28),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.pie_chart_rounded,
                          size: 18,
                          color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Body Parts Share',
                          style: GoogleFonts.plusJakartaSans(
                            color: titleColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (muscleCounts.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No muscle data recorded yet.',
                            style: GoogleFonts.plusJakartaSans(color: subColor, fontSize: 12),
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          // Donut Pie Chart
                          SizedBox(
                            width: 130,
                            height: 130,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 36,
                                sections: _buildPieSections(muscleCounts),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),

                          // Legend
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: muscleCounts.entries.take(5).map((e) {
                                final idx = muscleCounts.keys.toList().indexOf(e.key);
                                final color = _getPieColor(idx);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          e.key,
                                          style: GoogleFonts.plusJakartaSans(
                                            color: titleColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${e.value} sets',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: subColor,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
            ],
          ),
        ),
      ),
    );
  }

  double _calculateMaxY(List<MapEntry<String, double>> data) {
    double max = 100.0;
    for (var item in data) {
      if (item.value > max) {
        max = item.value;
      }
    }
    return (max * 1.25).ceilToDouble();
  }

  List<PieChartSectionData> _buildPieSections(Map<String, int> counts) {
    final total = counts.values.fold(0, (sum, val) => sum + val);
    int idx = 0;
    return counts.entries.map((e) {
      final color = _getPieColor(idx++);
      final isLarge = idx == 1;
      return PieChartSectionData(
        color: color,
        value: e.value.toDouble(),
        title: '${((e.value / (total == 0 ? 1 : total)) * 100).round()}%',
        radius: isLarge ? 28 : 24,
        titleStyle: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getPieColor(int index) {
    const colors = [
      Color(0xFF0D9488),
      Color(0xFF0284C7),
      Color(0xFFD97706),
      Color(0xFFE11D48),
      Color(0xFF9333EA),
      Color(0xFF10B981),
      Color(0xFF6366F1),
    ];
    return colors[index % colors.length];
  }
}

class _AnalyticsTabSwitchItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _AnalyticsTabSwitchItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = isDark ? const Color(0xFF0F1A33) : Colors.white;
    final activeTextColor = isDark ? Colors.white : AppTheme.lightTextPrimary;
    final activeIconColor = isDark ? AppTheme.tealLight : AppTheme.tealPrimary;
    final inactiveColor = const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? activeIconColor : inactiveColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? activeTextColor : inactiveColor,
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
