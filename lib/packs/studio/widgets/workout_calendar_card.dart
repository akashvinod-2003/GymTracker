import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gym_tracker/models/workout_session.dart';
import 'package:gym_tracker/providers/theme_provider.dart';
import 'package:gym_tracker/services/streak_service.dart';
import '../theme/app_theme.dart';

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
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final cardBg = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subColor = isDark ? AppTheme.darkTextSecondary : const Color(0xFF5F5F66);

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
                      fontSize: 11,
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

              return InkWell(
                onTap: () => widget.onDateSelected(date),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? const Color(0xFF3A2416) : AppTheme.tealBg)
                        : (hasWorkout
                            ? (isDark ? const Color(0xFF1C2840) : const Color(0xFFFBEDE4))
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                          : (isToday
                              ? AppTheme.orangeEnd
                              : (hasWorkout
                                  ? (isDark ? const Color(0xFFBF460A) : const Color(0xFFF3CDB5))
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
                                  : (isSunday ? const Color(0xFF76767E) : titleColor)),
                          fontSize: 12,
                          fontWeight: (hasWorkout || isSelected || isToday)
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (hasWorkout)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                          ),
                        )
                      else if (isSunday)
                        Text(
                          'REST',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF76767E),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
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
                      color: isDark ? const Color(0xFF5F5F66) : const Color(0xFF76767E),
                      fontSize: 11,
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
          color: isSunday ? const Color(0xFFF43F5E) : const Color(0xFF76767E),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
