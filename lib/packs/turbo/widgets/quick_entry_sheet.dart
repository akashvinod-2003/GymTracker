import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:gym_tracker/providers/theme_provider.dart';
import 'package:gym_tracker/providers/workout_provider.dart';
import '../theme/app_theme.dart';
import 'add_split_dialog.dart';

class QuickEntrySheet extends StatefulWidget {
  const QuickEntrySheet({super.key});

  @override
  State<QuickEntrySheet> createState() => _QuickEntrySheetState();
}

class _QuickEntrySheetState extends State<QuickEntrySheet> {
  final _nameController = TextEditingController();
  final _weightController = TextEditingController(text: '20');
  final _repsController = TextEditingController(text: '10');

  String? _selectedGroupName;
  String? _selectedPart;
  String _selectedEquipment = 'Dumbbell';

  final List<String> _equipmentOptions = [
    'Dumbbell',
    'Machine',
    'Barbell',
    'Cable',
    'Bodyweight',
  ];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    if (provider.splitGroups.isNotEmpty) {
      final firstGroup = provider.splitGroups.first;
      _selectedGroupName = firstGroup.name;
      if (firstGroup.partNames.isNotEmpty) {
        _selectedPart = firstGroup.partNames.first;
        final exercises = firstGroup.getExercisesForPart(_selectedPart!);
        if (exercises.isNotEmpty) {
          _nameController.text = exercises.first;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  IconData _getEquipmentIcon(String equip) {
    switch (equip.toLowerCase()) {
      case 'dumbbell':
        return Icons.fitness_center_sharp;
      case 'machine':
        return Icons.settings_accessibility_sharp;
      case 'barbell':
        return Icons.sports_gymnastics_sharp;
      case 'cable':
        return Icons.cable_sharp;
      case 'bodyweight':
        return Icons.accessibility_new_sharp;
      default:
        return Icons.bolt_sharp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    final sheetBg = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subColor = isDark ? AppTheme.darkTextSecondary : AppTheme.n550;

    final hasGroups = workoutProvider.splitGroups.isNotEmpty;
    final selectedGroup = hasGroups
        ? workoutProvider.splitGroups.firstWhere(
            (g) => g.name == _selectedGroupName,
            orElse: () => workoutProvider.splitGroups.first,
          )
        : null;

    if (_selectedGroupName == null && selectedGroup != null) {
      _selectedGroupName = selectedGroup.name;
    }

    final availableParts = selectedGroup?.partNames ?? [];
    if (_selectedPart == null && availableParts.isNotEmpty) {
      _selectedPart = availableParts.first;
    }

    final exercisesForPart = (selectedGroup != null && _selectedPart != null)
        ? selectedGroup.getExercisesForPart(_selectedPart!)
        : <String>[];

    return Container(
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.n700 : AppTheme.n150,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sheet Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Exercise',
                      style: GoogleFonts.interTight(
                        color: titleColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_sharp),
                  color: subColor,
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? AppTheme.n800 : AppTheme.n050,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Starting Weight & Reps Hero Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.t800 : AppTheme.t050,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppTheme.t500 : AppTheme.t200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'STARTING WEIGHT & REPS',
                        style: GoogleFonts.interTight(
                          color: isDark ? AppTheme.tealLight : AppTheme.t500,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.t800 : AppTheme.t100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Set #1',
                          style: GoogleFonts.interTight(
                            color: isDark ? AppTheme.tealLight : AppTheme.t500,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Weight
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.n900 : AppTheme.lightCard,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WEIGHT (KG)',
                                style: GoogleFonts.interTight(
                                  color: subColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextField(
                                controller: _weightController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: GoogleFonts.interTight(
                                  color: titleColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Reps
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.n900 : AppTheme.lightCard,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'REPS',
                                style: GoogleFonts.interTight(
                                  color: subColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextField(
                                controller: _repsController,
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.interTight(
                                  color: titleColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Group Split Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GROUP SPLIT',
                  style: GoogleFonts.interTight(
                    color: subColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => const AddSplitDialog(),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_sharp,
                        size: 14,
                        color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'New',
                        style: GoogleFonts.inter(
                          color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (workoutProvider.splitGroups.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.n800.withValues(alpha: 0.5) : AppTheme.n050,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'No split groups configured yet.',
                        style: GoogleFonts.inter(
                          color: subColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => const AddSplitDialog(),
                        );
                      },
                      icon: const Icon(Icons.add_sharp, size: 16),
                      label: const Text('Add Split'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.turbo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: workoutProvider.splitGroups.map((g) {
                  final isSelected = g.name == _selectedGroupName;
                  return ChoiceChip(
                    label: Text(g.name),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        _selectedGroupName = g.name;
                        if (g.partNames.isNotEmpty) {
                          _selectedPart = g.partNames.first;
                          final ex = g.getExercisesForPart(_selectedPart!);
                          if (ex.isNotEmpty) _nameController.text = ex.first;
                        }
                      });
                    },
                    selectedColor: AppTheme.turbo,
                    backgroundColor: isDark ? AppTheme.n800 : AppTheme.n050,
                    labelStyle: GoogleFonts.inter(
                      color: isSelected
                          ? Colors.white
                          : titleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : borderColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 18),

            // Body Part Grid
            Text(
              'BODY PART',
              style: GoogleFonts.interTight(
                color: subColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            if (availableParts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No muscles configured in this split.',
                  style: GoogleFonts.inter(color: subColor, fontSize: 12),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.15,
                ),
                itemCount: availableParts.length,
                itemBuilder: (context, idx) {
                  final part = availableParts[idx];
                  final isSelected = part == _selectedPart;
                  final pastel = AppTheme.pastelStyles[idx % AppTheme.pastelStyles.length];

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPart = part;
                        final ex = selectedGroup?.getExercisesForPart(part) ?? [];
                        if (ex.isNotEmpty) _nameController.text = ex.first;
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? AppTheme.t800 : Colors.white)
                            : (isDark ? AppTheme.n800 : AppTheme.n050),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                              : borderColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: pastel.bg(isDark),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              pastel.icon,
                              color: pastel.text(isDark),
                              size: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            part,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.interTight(
                              color: titleColor,
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 18),

            // Selectable Exercises Catalog for this Part (Level 3)
            if (exercisesForPart.isNotEmpty) ...[
              Text(
                'SELECT EXERCISE FROM $_selectedPart',
                style: GoogleFonts.interTight(
                  color: subColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: exercisesForPart.map((exName) {
                  final isSelected = _nameController.text == exName;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _nameController.text = exName;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? AppTheme.t800 : AppTheme.tealBg)
                            : (isDark ? AppTheme.n800 : AppTheme.n050),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                              : borderColor,
                        ),
                      ),
                      child: Text(
                        exName,
                        style: GoogleFonts.interTight(
                          color: isSelected
                              ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                              : titleColor,
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
            ],

            // Custom Exercise Name Input
            Text(
              'EXERCISE NAME',
              style: GoogleFonts.interTight(
                color: subColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.n800 : AppTheme.n050,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: _nameController,
                style: GoogleFonts.inter(
                  color: titleColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Incline Dumbbell Press',
                  hintStyle: GoogleFonts.inter(
                    color: isDark ? AppTheme.n600 : AppTheme.n500,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.edit_note_sharp,
                    color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Equipment Type
            Text(
              'EQUIPMENT TYPE',
              style: GoogleFonts.interTight(
                color: subColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _equipmentOptions.map((equip) {
                final isSelected = equip == _selectedEquipment;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedEquipment = equip;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.turbo
                          : (isDark ? AppTheme.n800 : AppTheme.n050),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : borderColor,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getEquipmentIcon(equip),
                          size: 14,
                          color: isSelected
                              ? Colors.white
                              : subColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          equip,
                          style: GoogleFonts.inter(
                            color: isSelected
                                ? Colors.white
                                : titleColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        color: subColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saveExercise,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppTheme.turbo,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppTheme.tealPrimary.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_sharp, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Add to Session',
                          style: GoogleFonts.interTight(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveExercise() {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an exercise name.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    final part = _selectedPart ?? 'General';
    final group = _selectedGroupName ?? 'Custom';

    final weight = double.tryParse(_weightController.text) ?? 20.0;
    final reps = int.tryParse(_repsController.text) ?? 10;

    workoutProvider.addExercise(
      name: name,
      group: group,
      part: part,
      equipment: _selectedEquipment,
      initialWeight: weight,
      initialReps: reps,
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $name!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
