import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gym_tracker/models/body_weight_entry.dart';
import 'package:gym_tracker/providers/theme_provider.dart';
import 'package:gym_tracker/providers/workout_provider.dart';
import '../theme/app_theme.dart';
import 'log_weight_dialog.dart';

class BodyWeightAnalyticsView extends StatelessWidget {
  const BodyWeightAnalyticsView({super.key});

  void _openLogDialog(BuildContext context, {double? currentWeight}) {
    showDialog(
      context: context,
      builder: (ctx) => LogWeightDialog(initialWeight: currentWeight),
    );
  }

  void _confirmDelete(BuildContext context, BodyWeightEntry entry) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
        ),
        title: Text(
          'Delete Entry?',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to remove the log of ${entry.weightKg.toStringAsFixed(1)} kg from ${DateFormat('MMM d, yyyy').format(entry.date)}?',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.n550,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: AppTheme.n500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              workoutProvider.deleteBodyWeightLog(entry.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    final cardBg = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subColor = isDark ? AppTheme.darkTextSecondary : AppTheme.n550;

    final weightLogsAsc = workoutProvider.sortedWeightLogsAsc;
    final weightLogsDesc = workoutProvider.sortedWeightLogsDesc;
    final currentWeight = workoutProvider.currentWeightKg;
    final startingWeight = workoutProvider.startingWeightKg;
    final totalChange = workoutProvider.totalWeightChangeKg;
    final minWeight = workoutProvider.minBodyWeightKg;
    final maxWeight = workoutProvider.maxBodyWeightKg;
    final latestEntry = workoutProvider.latestBodyWeightEntry;

    if (weightLogsAsc.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.n800 : AppTheme.n050,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.monitor_weight_outlined,
                size: 32,
                color: AppTheme.n500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Body Weight Logs Yet',
              style: GoogleFonts.interTight(
                color: titleColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                'Track your weight on your own schedule whenever you step on the scale. No daily input required!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: subColor,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _openLogDialog(context),
              icon: const Icon(Icons.add_sharp, size: 18, color: Colors.white),
              label: Text(
                'Log Current Weight',
                style: GoogleFonts.interTight(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.tealPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Action Header with Log button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEIGHT PROGRESSION',
                  style: GoogleFonts.interTight(
                    color: subColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  'On-Demand Check-ins',
                  style: GoogleFonts.interTight(
                    color: titleColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _openLogDialog(context, currentWeight: currentWeight),
              icon: const Icon(Icons.add_sharp, size: 16, color: Colors.white),
              label: Text(
                'Log Weight',
                style: GoogleFonts.interTight(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.tealPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Metrics 4-Box Summary Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _WeightStatTile(
                      label: 'CURRENT',
                      value: '${currentWeight?.toStringAsFixed(1) ?? '--'} kg',
                      subtext: latestEntry != null
                          ? DateFormat('MMM d, yyyy').format(latestEntry.date)
                          : '',
                      valueColor: isDark ? Colors.white : AppTheme.lightTextPrimary,
                      isDark: isDark,
                    ),
                  ),
                  Container(width: 1, height: 44, color: borderColor),
                  Expanded(
                    child: _WeightStatTile(
                      label: 'TOTAL CHANGE',
                      value: totalChange != null
                          ? '${totalChange > 0 ? '+' : ''}${totalChange.toStringAsFixed(1)} kg'
                          : 'Baseline',
                      subtext: startingWeight != null
                          ? 'From ${startingWeight.toStringAsFixed(1)} kg'
                          : '',
                      valueColor: totalChange == null
                          ? subColor
                          : (totalChange < 0
                              ? (isDark ? AppTheme.successDark : AppTheme.successLight)
                              : (isDark ? AppTheme.t300 : AppTheme.t500)),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: borderColor, height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _WeightStatTile(
                      label: 'LOWEST',
                      value: '${minWeight?.toStringAsFixed(1) ?? '--'} kg',
                      subtext: 'All-time min',
                      valueColor: isDark ? AppTheme.t300 : AppTheme.turbo,
                      isDark: isDark,
                    ),
                  ),
                  Container(width: 1, height: 44, color: borderColor),
                  Expanded(
                    child: _WeightStatTile(
                      label: 'HIGHEST',
                      value: '${maxWeight?.toStringAsFixed(1) ?? '--'} kg',
                      subtext: 'All-time max',
                      valueColor: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Body Weight Trend Line Chart Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.n950,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.n800),
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
                        'BODY WEIGHT TREND',
                        style: GoogleFonts.interTight(
                          color: AppTheme.n500,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Scale History',
                        style: GoogleFonts.interTight(
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
                      color: AppTheme.n950,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.n700),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.scale_sharp, size: 14, color: AppTheme.t400),
                        const SizedBox(width: 4),
                        Text(
                          '${weightLogsAsc.length} check-${weightLogsAsc.length == 1 ? 'in' : 'ins'}',
                          style: GoogleFonts.inter(
                            color: AppTheme.t400,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // FlChart LineChart
              SizedBox(
                height: 180,
                child: _buildWeightLineChart(weightLogsAsc),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Check-in History Log List
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.format_list_bulleted_sharp,
                    size: 18,
                    color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recorded Check-ins',
                    style: GoogleFonts.interTight(
                      color: titleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${weightLogsDesc.length} total',
                    style: GoogleFonts.inter(
                      color: subColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: borderColor, height: 1),
              const SizedBox(height: 8),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: weightLogsDesc.length,
                separatorBuilder: (_, _) => Divider(color: borderColor, height: 1),
                itemBuilder: (context, idx) {
                  final entry = weightLogsDesc[idx];
                  // Compare to next chronological entry (which is at idx + 1 in descending list)
                  final prevEntry = (idx + 1 < weightLogsDesc.length) ? weightLogsDesc[idx + 1] : null;
                  final delta = prevEntry != null ? entry.weightKg - prevEntry.weightKg : null;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.n800 : AppTheme.n050,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.monitor_weight_outlined,
                            size: 20,
                            color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEEE, MMM d, yyyy').format(entry.date),
                                style: GoogleFonts.inter(
                                  color: titleColor,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (entry.note != null && entry.note!.isNotEmpty)
                                Text(
                                  entry.note!,
                                  style: GoogleFonts.inter(
                                    color: subColor,
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${entry.weightKg.toStringAsFixed(1)} kg',
                              style: GoogleFonts.interTight(
                                color: titleColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (delta != null)
                              Text(
                                '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)} kg',
                                style: GoogleFonts.inter(
                                  color: delta == 0
                                      ? subColor
                                      : (delta < 0
                                          ? (isDark ? AppTheme.successDark : AppTheme.successLight)
                                          : (isDark ? AppTheme.t300 : AppTheme.t500)),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _confirmDelete(context, entry),
                          icon: const Icon(Icons.delete_outline_sharp, size: 18),
                          color: AppTheme.n500,
                          splashRadius: 18,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeightLineChart(List<BodyWeightEntry> logs) {
    if (logs.length == 1) {
      // If only one data point, create duplicate for horizontal trend preview
      final single = logs.first;
      logs = [
        single,
        single.copyWith(id: 'preview', date: single.date.add(const Duration(hours: 1))),
      ];
    }

    double minVal = logs.first.weightKg;
    double maxVal = logs.first.weightKg;
    for (var l in logs) {
      if (l.weightKg < minVal) minVal = l.weightKg;
      if (l.weightKg > maxVal) maxVal = l.weightKg;
    }

    final double minY = (minVal - 2.0).floorToDouble().clamp(0.0, 350.0);
    final double maxY = (maxVal + 2.0).ceilToDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: ((maxY - minY) / 4).clamp(1.0, 10.0),
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
              interval: ((maxY - minY) / 4).clamp(1.0, 10.0),
              getTitlesWidget: (val, meta) {
                return Text(
                  '${val.toInt()}',
                  style: GoogleFonts.inter(
                    color: AppTheme.n500,
                    fontSize: 11,
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
                if (idx >= 0 && idx < logs.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('MM/dd').format(logs[idx].date),
                      style: GoogleFonts.inter(
                        color: AppTheme.n500,
                        fontSize: 11,
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
        maxX: (logs.length - 1).toDouble().clamp(1.0, 20.0),
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppTheme.n800,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final idx = spot.spotIndex;
                final dateStr = (idx >= 0 && idx < logs.length)
                    ? DateFormat('MMM d').format(logs[idx].date)
                    : '';
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)} kg\n$dateStr',
                  GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: logs.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.weightKg);
            }).toList(),
            isCurved: true,
            color: AppTheme.t300, // Warm orange gradient to contrast with Teal lift chart
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.t300,
                  strokeWidth: 1.5,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.t300.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightStatTile extends StatelessWidget {
  final String label;
  final String value;
  final String subtext;
  final Color valueColor;
  final bool isDark;

  const _WeightStatTile({
    required this.label,
    required this.value,
    required this.subtext,
    required this.valueColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final subColor = isDark ? AppTheme.darkTextSecondary : AppTheme.n550;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.interTight(
            color: subColor,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.interTight(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (subtext.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtext,
            style: GoogleFonts.inter(
              color: subColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
