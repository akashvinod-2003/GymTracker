import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/workout_session.dart';
import '../providers/theme_provider.dart';
import '../providers/workout_provider.dart';
import '../services/streak_service.dart';
import '../theme/app_theme.dart';
import '../screens/todays_workout_flow_screen.dart';

class WorkoutCalendarCard extends StatefulWidget {
  final Map<String, WorkoutSession> sessions;
  final String selectedDateKey;
  final Function(DateTime) onDateSelected;

  const WorkoutCalendarCard({
    super.key,
    required this.sessions,
    required this.selectedDateKey,
    required this.onDateSelected,
  });

  @override
  State<WorkoutCalendarCard> createState() => _WorkoutCalendarCardState();
}

class _WorkoutCalendarCardState extends State<WorkoutCalendarCard> {
  late DateTime _viewMonth;

  @override
  void initState() {
    super.initState();
    final today = StreakService.nowIST;
    _viewMonth = DateTime(today.year, today.month, 1);
  }

  void _prevMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final cardBg = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subColor = isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B);

    final monthTitle = DateFormat('MMMM yyyy').format(_viewMonth);

    final daysInMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;
    final firstDayWeekday = _viewMonth.weekday; // 1 = Mon, 7 = Sun
    final leadingBlanks = firstDayWeekday - 1; // 0 for Mon, 6 for Sun

    final todayKey = StreakService.todayKeyIST;

    // Monthly stats
    int workoutsThisMonth = 0;
    widget.sessions.forEach((dateStr, session) {
      if (dateStr.startsWith(DateFormat('yyyy-MM').format(_viewMonth))) {
        if (session.exercises.any((e) => e.sets.isNotEmpty)) {
          workoutsThisMonth++;
        }
      }
    });

    return Container(
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
          // Month Header & Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WORKOUT CALENDAR',
                    style: GoogleFonts.plusJakartaSans(
                      color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    monthTitle,
                    style: GoogleFonts.plusJakartaSans(
                      color: titleColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _prevMonth,
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: subColor,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                  IconButton(
                    onPressed: _nextMonth,
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: subColor,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Integrated Split Information for Selected Date
          Builder(
            builder: (context) {
              final workoutProvider = Provider.of<WorkoutProvider>(context);
              final selectedDate = DateTime.tryParse(widget.selectedDateKey) ?? StreakService.nowIST;
              final selectedFormattedDate = DateFormat('EEE, MMM d').format(selectedDate);

              final session = widget.sessions[widget.selectedDateKey];
              final hasWorkout = session != null && session.exercises.any((e) => e.sets.isNotEmpty);
              final splitName = workoutProvider.getSplitNameForDate(selectedDate, session: session);
              final split = workoutProvider.getSplitForDate(selectedDate);
              final isSunday = selectedDate.weekday == DateTime.sunday;
              final shortName = workoutProvider.getSplitShortNameForDate(selectedDate, session: session);

              final String splitTitle;
              final String splitSubtitle;
              final String badgeLabel;
              final Color badgeColor;
              final IconData badgeIcon;

              if (hasWorkout) {
                // Requirement 1: For completed workouts, display WorkoutSession.splitName (preserving historical name)
                splitTitle = splitName;
                splitSubtitle = '${session.exercises.length} exercises · ${session.completedSets} sets';
                badgeLabel = 'Completed';
                badgeColor = const Color(0xFF10B981);
                badgeIcon = Icons.fitness_center_rounded;
              } else if (split != null) {
                // Requirement 1: For scheduled workouts without a completed session, display split assigned to weekday
                splitTitle = splitName;
                splitSubtitle = split.partNames.isNotEmpty
                    ? 'Scheduled: ${split.partNames.join(', ')}'
                    : '${split.defaultSets} sets × ${split.defaultReps} reps target';
                badgeLabel = 'Scheduled Split';
                badgeColor = isDark ? AppTheme.tealLight : AppTheme.tealPrimary;
                badgeIcon = Icons.event_available_rounded;
              } else if (isSunday) {
                splitTitle = splitName;
                splitSubtitle = 'Sunday rest preserved — streak protected';
                badgeLabel = 'Rest Day';
                badgeColor = const Color(0xFF818CF8);
                badgeIcon = Icons.self_improvement_rounded;
              } else {
                splitTitle = splitName;
                splitSubtitle = 'No workouts scheduled or logged for this date';
                badgeLabel = 'Off Day';
                badgeColor = const Color(0xFF94A3B8);
                badgeIcon = Icons.pause_circle_outline_rounded;
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF162344) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasWorkout
                        ? (isDark ? const Color(0xFF134E4A) : const Color(0xFF99F6E4))
                        : (isDark ? const Color(0xFF23355C) : const Color(0xFFE2E8F0)),
                    width: hasWorkout ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: isDark ? 0.22 : 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(badgeIcon, color: badgeColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  splitTitle,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: titleColor,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (shortName.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF0F3635) : AppTheme.tealBg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF134E4A) : const Color(0xFF99F6E4),
                                    ),
                                  ),
                                  child: Text(
                                    shortName,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: isDark ? 0.25 : 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  badgeLabel,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: badgeColor,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$selectedFormattedDate · $splitSubtitle',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              color: subColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.selectedDateKey == todayKey) ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          TodaysWorkoutFlowScreen.start(context, initialSplitId: split?.id);
                        },
                        icon: const Icon(Icons.add_circle_rounded, size: 15),
                        label: Text(
                          hasWorkout ? 'Edit Workout' : 'Add Workout',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Days of Week Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _WeekdayLabel(text: 'M'),
              _WeekdayLabel(text: 'T'),
              _WeekdayLabel(text: 'W'),
              _WeekdayLabel(text: 'T'),
              _WeekdayLabel(text: 'F'),
              _WeekdayLabel(text: 'S'),
              _WeekdayLabel(text: 'S', isSunday: true),
            ],
          ),
          const SizedBox(height: 10),

          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingBlanks + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              if (index < leadingBlanks) {
                return const SizedBox.shrink();
              }

              final day = index - leadingBlanks + 1;
              final date = DateTime(_viewMonth.year, _viewMonth.month, day);
              final dateKey = DateFormat('yyyy-MM-dd').format(date);

              final session = widget.sessions[dateKey];
              final hasWorkout = session != null && session.exercises.any((e) => e.sets.isNotEmpty);
              final isSunday = date.weekday == DateTime.sunday;
              final isToday = dateKey == todayKey;
              final isSelected = dateKey == widget.selectedDateKey;

              final shortName = workoutProvider.getSplitShortNameForDate(date, session: session);

              return InkWell(
                onTap: () => widget.onDateSelected(date),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? const Color(0xFF0F3635) : AppTheme.tealBg)
                        : (hasWorkout
                            ? (isDark ? const Color(0xFF16324F) : const Color(0xFFF0FDFA))
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                          : (isToday
                              ? AppTheme.orangeEnd
                              : (hasWorkout
                                  ? (isDark ? const Color(0xFF0D9488) : const Color(0xFF99F6E4))
                                  : Colors.transparent)),
                      width: isSelected || isToday ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: GoogleFonts.plusJakartaSans(
                          color: isSelected
                              ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                              : (hasWorkout
                                  ? (isDark ? Colors.white : AppTheme.tealPrimary)
                                  : (isSunday ? const Color(0xFF94A3B8) : titleColor)),
                          fontSize: 11.5,
                          fontWeight: (hasWorkout || isSelected || isToday)
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (shortName.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppTheme.tealPrimary.withValues(alpha: 0.3) : AppTheme.tealPrimary.withValues(alpha: 0.15))
                                : (hasWorkout
                                    ? (isDark ? const Color(0xFF0F3635) : const Color(0xFFCCFBF1))
                                    : Colors.transparent),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            shortName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              color: isSelected
                                  ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                                  : (hasWorkout
                                      ? (isDark ? const Color(0xFF34D399) : const Color(0xFF0D9488))
                                      : (isSunday ? const Color(0xFF94A3B8) : subColor)),
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.2,
                            ),
                          ),
                        )
                      else if (hasWorkout)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                          ),
                        )
                      else
                        const SizedBox(height: 4),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          Divider(color: borderColor, height: 1),
          const SizedBox(height: 12),

          // Monthly Summary Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$workoutsThisMonth Sessions this Month',
                    style: GoogleFonts.plusJakartaSans(
                      color: subColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Sundays Rest (Skipped)',
                    style: GoogleFonts.plusJakartaSans(
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String text;
  final bool isSunday;

  const _WeekdayLabel({required this.text, this.isSunday = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          color: isSunday ? const Color(0xFFF43F5E) : const Color(0xFF94A3B8),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
