import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gym_tracker/models/exercise.dart';
import 'package:gym_tracker/models/workout_set.dart';
import 'package:gym_tracker/providers/workout_provider.dart';
import '../theme/app_theme.dart';
import '../theme/motion.dart';

/// One exercise in today's session. The set rows are the instrument of this
/// app, so they get the space: 44 pt fields, a 44 pt finish button, and
/// column headers instead of a unit label repeated in every field.
class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final int index;

  /// Plate colour slot for this exercise's muscle group.
  final int plateIndex;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.index,
    this.plateIndex = 0,
  });

  IconData _equipmentIcon(String equip) {
    switch (equip.toLowerCase()) {
      case 'dumbbell':
        return Icons.fitness_center_rounded;
      case 'machine':
        return Icons.precision_manufacturing_rounded;
      case 'barbell':
        return Icons.fitness_center_rounded;
      case 'cable':
        return Icons.cable_rounded;
      case 'bodyweight':
        return Icons.accessibility_new_rounded;
      default:
        return Icons.bolt_rounded;
    }
  }

  void _remove(BuildContext context) {
    final wp = context.read<WorkoutProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final removed = exercise;
    final at = index;
    Haptics.warn();
    wp.deleteExercise(exercise.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Removed ${removed.name}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => wp.restoreExercise(removed, at),
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final t = Theme.of(context).textTheme;
    final wp = context.read<WorkoutProvider>();
    final plate = p.plate(plateIndex);
    final done = exercise.completedSetsCount;
    final total = exercise.sets.length;
    final allDone = total > 0 && done == total;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: allDone ? p.success.withValues(alpha: 0.5) : p.separator),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 4, 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: plate.bg(p.dark),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _equipmentIcon(exercise.equipment),
                    color: plate.text(p.dark),
                    size: 22,
                    semanticLabel: exercise.equipment,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: t.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_cap(exercise.part)} · ${exercise.equipment}',
                        style: t.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${NumberFormat('#,###').format(exercise.totalVolume.round())} kg',
                      style: t.titleSmall?.copyWith(fontFeatures: tabularFigures),
                    ),
                    Text(
                      '$done of $total done',
                      style: t.labelMedium?.copyWith(
                        color: allDone ? p.success : p.text2,
                        fontWeight: allDone ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  tooltip: 'More for ${exercise.name}',
                  icon: Icon(Icons.more_horiz_rounded, color: p.text2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: p.surface2,
                  onSelected: (v) {
                    if (v == 'remove') _remove(context);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, color: p.danger, size: 20),
                          const SizedBox(width: 10),
                          Text('Remove Exercise', style: t.bodyLarge?.copyWith(color: p.danger)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Column headers ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ExcludeSemantics(
              child: Row(
                children: [
                  SizedBox(width: 36, child: Text('SET', style: t.labelSmall)),
                  const SizedBox(width: 8),
                  Expanded(child: Text('KG', style: t.labelSmall, textAlign: TextAlign.center)),
                  const SizedBox(width: 24),
                  Expanded(child: Text('REPS', style: t.labelSmall, textAlign: TextAlign.center)),
                  const SizedBox(width: 12),
                  const SizedBox(width: 44),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),

          // ── Sets ─────────────────────────────────────────────────
          for (var i = 0; i < exercise.sets.length; i++)
            _SetRow(
              key: ValueKey('${exercise.id}-$i-${exercise.sets.length}'),
              exerciseId: exercise.id,
              exerciseName: exercise.name,
              setIndex: i,
              set: exercise.sets[i],
              canDelete: exercise.sets.length > 1,
            ),

          // ── Add set ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
            child: TextButton.icon(
              onPressed: () {
                Haptics.commit();
                wp.addSet(exercise.id);
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add Set'),
              style: TextButton.styleFrom(minimumSize: const Size.fromHeight(44)),
            ),
          ),
        ],
      ),
    );
  }
}

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

class _SetRow extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;
  final int setIndex;
  final WorkoutSet set;
  final bool canDelete;

  const _SetRow({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.setIndex,
    required this.set,
    required this.canDelete,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late final TextEditingController _w =
      TextEditingController(text: _fmt(widget.set.weight));
  late final TextEditingController _r =
      TextEditingController(text: '${widget.set.reps}');

  static String _fmt(double v) => v % 1 == 0 ? v.toInt().toString() : v.toString();

  @override
  void didUpdateWidget(covariant _SetRow old) {
    super.didUpdateWidget(old);
    if (double.tryParse(_w.text) != widget.set.weight) {
      _w.text = _fmt(widget.set.weight);
    }
    if (int.tryParse(_r.text) != widget.set.reps) {
      _r.text = '${widget.set.reps}';
    }
  }

  @override
  void dispose() {
    _w.dispose();
    _r.dispose();
    super.dispose();
  }

  void _toggle() {
    final wp = context.read<WorkoutProvider>();
    if (!widget.set.completed) {
      Haptics.success();
    } else {
      Haptics.select();
    }
    FocusScope.of(context).unfocus();
    wp.toggleSetCompleted(widget.exerciseId, widget.setIndex);
  }

  void _delete() {
    final wp = context.read<WorkoutProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final removed = widget.set;
    final at = widget.setIndex;
    final id = widget.exerciseId;
    Haptics.warn();
    wp.deleteSet(id, at);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Removed set ${at + 1}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => wp.restoreSet(id, at, removed),
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final t = Theme.of(context).textTheme;
    final wp = context.read<WorkoutProvider>();
    final done = widget.set.completed;
    final n = widget.setIndex + 1;

    final row = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: done ? p.successTint : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '$n',
              style: t.titleSmall?.copyWith(
                color: done ? p.success : p.text2,
                fontFeatures: tabularFigures,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _NumberField(
              controller: _w,
              label: 'Set $n weight in kilograms',
              decimal: true,
              onChanged: (v) => wp.updateSet(
                widget.exerciseId,
                widget.setIndex,
                weight: double.tryParse(v) ?? 0,
              ),
            ),
          ),
          SizedBox(
            width: 24,
            child: Text('×', textAlign: TextAlign.center, style: t.bodyLarge?.copyWith(color: p.text3)),
          ),
          Expanded(
            child: _NumberField(
              controller: _r,
              label: 'Set $n reps',
              onChanged: (v) => wp.updateSet(
                widget.exerciseId,
                widget.setIndex,
                reps: int.tryParse(v) ?? 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _DoneButton(done: done, onTap: _toggle, setNumber: n),
        ],
      ),
    );

    if (!widget.canDelete) return row;

    // Swipe left to remove; the semantics action is the non-gesture path.
    return Semantics(
      customSemanticsActions: {
        CustomSemanticsAction(label: 'Delete set $n'): _delete,
      },
      child: Dismissible(
        key: ValueKey('dismiss-${widget.key}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _delete(),
        background: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.only(right: 20),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
            color: p.danger,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.delete_outline_rounded, color: p.dark ? Colors.black : Colors.white),
        ),
        child: row,
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool decimal;
  final ValueChanged<String> onChanged;

  const _NumberField({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.decimal = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final t = Theme.of(context).textTheme;
    return Semantics(
      label: label,
      textField: true,
      child: SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        expands: true,
        maxLines: null,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(decimal ? r'[0-9.]' : r'[0-9]')),
        ],
        style: t.titleMedium?.copyWith(fontFeatures: tabularFigures),
        onTap: () => controller.selection =
            TextSelection(baseOffset: 0, extentOffset: controller.text.length),
        decoration: InputDecoration(
          hintText: '0',
          isDense: true,
          contentPadding: EdgeInsets.zero,
          fillColor: p.surface2,
        ),
        onChanged: onChanged,
      ),
      ),
    );
  }
}

class _DoneButton extends StatelessWidget {
  final bool done;
  final VoidCallback onTap;
  final int setNumber;

  const _DoneButton({required this.done, required this.onTap, required this.setNumber});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Semantics(
      button: true,
      toggled: done,
      label: done ? 'Set $setNumber finished' : 'Finish set $setNumber',
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        pressedScale: 0.88,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: done ? p.success : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: done ? p.success : p.text3, width: 2),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: done
                ? Icon(Icons.check_rounded, key: const ValueKey(1), size: 24, color: p.onSuccess)
                : const SizedBox(key: ValueKey(0)),
          ),
        ),
      ),
    );
  }
}
