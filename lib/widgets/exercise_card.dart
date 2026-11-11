import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../providers/theme_provider.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final int index;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.index,
  });

  IconData _getEquipmentIcon(String equip) {
    switch (equip.toLowerCase()) {
      case 'dumbbell':
        return Icons.fitness_center_rounded;
      case 'machine':
        return Icons.settings_accessibility_rounded;
      case 'barbell':
        return Icons.sports_gymnastics_rounded;
      case 'cable':
        return Icons.cable_rounded;
      case 'bodyweight':
        return Icons.accessibility_new_rounded;
      default:
        return Icons.bolt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);

    final cardBg = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subColor = isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B);

    final pastel = AppTheme.pastelStyles[index % AppTheme.pastelStyles.length];
    final totalVol = exercise.totalVolume;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
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
          // Header Row
          Row(
            children: [
              // Equipment Avatar
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: pastel.bg(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: pastel.border(isDark)),
                ),
                child: Icon(
                  _getEquipmentIcon(exercise.equipment),
                  color: pastel.text(isDark),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Title and Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: GoogleFonts.plusJakartaSans(
                        color: titleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: AppTheme.tealPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          exercise.part,
                          style: GoogleFonts.plusJakartaSans(
                            color: subColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F3635) : AppTheme.tealBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            exercise.equipment,
                            style: GoogleFonts.plusJakartaSans(
                              color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Volume Summary & Delete Action
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        NumberFormat('#,###').format(totalVol.round()),
                        style: GoogleFonts.plusJakartaSans(
                          color: titleColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'kg',
                        style: GoogleFonts.plusJakartaSans(
                          color: subColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${exercise.sets.length} sets',
                    style: GoogleFonts.plusJakartaSans(
                      color: subColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                color: isDark ? Colors.redAccent.shade100 : Colors.red.shade400,
                onPressed: () => _confirmDelete(context, workoutProvider),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                splashRadius: 18,
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 12),

          // Sets List
          ...exercise.sets.asMap().entries.map((entry) {
            final sIdx = entry.key;
            final set = entry.value;

            return _SetItemRow(
              exerciseId: exercise.id,
              setIndex: sIdx,
              setNumber: set.setNumber,
              weight: set.weight,
              reps: set.reps,
              completed: set.completed,
              canDelete: exercise.sets.length > 1,
            );
          }),

          const SizedBox(height: 8),

          // Add Set Button
          InkWell(
            onTap: () => workoutProvider.addSet(exercise.id),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F2338) : const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF134E4A) : const Color(0xFF99F6E4),
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 16,
                    color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Add Set',
                    style: GoogleFonts.plusJakartaSans(
                      color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WorkoutProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Remove Exercise?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: Text(
          'Are you sure you want to remove "${exercise.name}" from today\'s workout?',
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteExercise(exercise.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _SetItemRow extends StatefulWidget {
  final String exerciseId;
  final int setIndex;
  final int setNumber;
  final double weight;
  final int reps;
  final bool completed;
  final bool canDelete;

  const _SetItemRow({
    required this.exerciseId,
    required this.setIndex,
    required this.setNumber,
    required this.weight,
    required this.reps,
    required this.completed,
    required this.canDelete,
  });

  @override
  State<_SetItemRow> createState() => _SetItemRowState();
}

class _SetItemRowState extends State<_SetItemRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: _formatNum(widget.weight));
    _repsController = TextEditingController(text: '${widget.reps}');
  }

  @override
  void didUpdateWidget(covariant _SetItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weight != widget.weight) {
      if (double.tryParse(_weightController.text) != widget.weight) {
        _weightController.text = _formatNum(widget.weight);
      }
    }
    if (oldWidget.reps != widget.reps) {
      if (int.tryParse(_repsController.text) != widget.reps) {
        _repsController.text = '${widget.reps}';
      }
    }
  }

  String _formatNum(double val) {
    return val % 1 == 0 ? val.toInt().toString() : val.toString();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);

    final rowBg = isDark ? const Color(0xFF162344) : const Color(0xFFF8FAFC);
    final inputBg = isDark ? const Color(0xFF0F1A33) : Colors.white;
    final borderColor = isDark ? const Color(0xFF23355C) : const Color(0xFFE2E8F0);
    final textCol = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: rowBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Set #
          SizedBox(
            width: 24,
            child: Text(
              '#${widget.setNumber}',
              style: GoogleFonts.plusJakartaSans(
                color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // Weight Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 38,
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.plusJakartaSans(
                      color: textCol,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      final w = double.tryParse(val) ?? 0.0;
                      workoutProvider.updateSet(widget.exerciseId, widget.setIndex, weight: w);
                    },
                  ),
                ),
                Text(
                  'kg',
                  style: GoogleFonts.plusJakartaSans(
                    color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '×',
              style: GoogleFonts.plusJakartaSans(
                color: isDark ? AppTheme.darkTextSecondary : const Color(0xFFCBD5E1),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Reps Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 30,
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.plusJakartaSans(
                      color: textCol,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      final r = int.tryParse(val) ?? 0;
                      workoutProvider.updateSet(widget.exerciseId, widget.setIndex, reps: r);
                    },
                  ),
                ),
                Text(
                  'reps',
                  style: GoogleFonts.plusJakartaSans(
                    color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Complete Button Checkmark
          InkWell(
            onTap: () => workoutProvider.toggleSetCompleted(widget.exerciseId, widget.setIndex),
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.completed
                    ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                    : inputBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.completed
                      ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                      : borderColor,
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 18,
                color: widget.completed
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Delete Set Button
          if (widget.canDelete)
            InkWell(
              onTap: () => workoutProvider.deleteSet(widget.exerciseId, widget.setIndex),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                child: Icon(
                  Icons.remove_rounded,
                  size: 16,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
              ),
            )
          else
            const SizedBox(width: 26),
        ],
      ),
    );
  }
}
