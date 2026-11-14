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
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    final sheetBg = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subColor = isDark ? AppTheme.darkTextSecondary : const Color(0xFF5F5F66);

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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                  color: isDark ? const Color(0xFF45484F) : const Color(0xFFE0DED8),
                  borderRadius: BorderRadius.circular(10),
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
                      'QUICK ENTRY',
                      style: GoogleFonts.plusJakartaSans(
                        color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Add Exercise',
                      style: GoogleFonts.plusJakartaSans(
                        color: titleColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: subColor,
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF2E3034) : const Color(0xFFF3F2EE),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Starting Weight & Reps Hero Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F2D32) : const Color(0xFFFBEDE4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFFA33B08) : const Color(0xFFF3CDB5),
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
                        style: GoogleFonts.plusJakartaSans(
                          color: isDark ? AppTheme.tealLight : const Color(0xFFA33B08),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF5A3418) : const Color(0xFFF8DCCB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Set #1',
                          style: GoogleFonts.plusJakartaSans(
                            color: isDark ? AppTheme.tealLight : const Color(0xFFA33B08),
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
                            color: isDark ? const Color(0xFF1C1D20) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WEIGHT (KG)',
                                style: GoogleFonts.plusJakartaSans(
                                  color: subColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextField(
                                controller: _weightController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: GoogleFonts.plusJakartaSans(
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
                            color: isDark ? const Color(0xFF1C1D20) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'REPS',
                                style: GoogleFonts.plusJakartaSans(
                                  color: subColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextField(
                                controller: _repsController,
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.plusJakartaSans(
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
                  style: GoogleFonts.plusJakartaSans(
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
                        Icons.add_rounded,
                        size: 14,
                        color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'New',
                        style: GoogleFonts.plusJakartaSans(
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
                  color: isDark ? const Color(0xFF27282C).withValues(alpha: 0.5) : const Color(0xFFF3F2EE),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'No split groups configured yet.',
                        style: GoogleFonts.plusJakartaSans(
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
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add Split'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    selectedColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                    backgroundColor: isDark ? const Color(0xFF27282C) : const Color(0xFFF3F2EE),
                    labelStyle: GoogleFonts.plusJakartaSans(
                      color: isSelected
                          ? (isDark ? Colors.black : Colors.white)
                          : titleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
              style: GoogleFonts.plusJakartaSans(
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
                  style: GoogleFonts.plusJakartaSans(color: subColor, fontSize: 12),
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
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF1C2840) : Colors.white)
                            : (isDark ? const Color(0xFF27282C) : const Color(0xFFF7F6F3)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                              : borderColor,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.tealPrimary.withValues(alpha: 0.18),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: pastel.bg(isDark),
                              borderRadius: BorderRadius.circular(10),
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
                            style: GoogleFonts.plusJakartaSans(
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
                style: GoogleFonts.plusJakartaSans(
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
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF3A2416) : AppTheme.tealBg)
                            : (isDark ? const Color(0xFF27282C) : const Color(0xFFF3F2EE)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                              : borderColor,
                        ),
                      ),
                      child: Text(
                        exName,
                        style: GoogleFonts.plusJakartaSans(
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
              style: GoogleFonts.plusJakartaSans(
                color: subColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF27282C) : const Color(0xFFF7F6F3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: _nameController,
                style: GoogleFonts.plusJakartaSans(
                  color: titleColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Incline Dumbbell Press',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: isDark ? const Color(0xFF4B4F58) : const Color(0xFF76767E),
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.edit_note_rounded,
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
              style: GoogleFonts.plusJakartaSans(
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
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                          : (isDark ? const Color(0xFF27282C) : const Color(0xFFF3F2EE)),
                      borderRadius: BorderRadius.circular(14),
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
                              ? (isDark ? Colors.black : Colors.white)
                              : subColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          equip,
                          style: GoogleFonts.plusJakartaSans(
                            color: isSelected
                                ? (isDark ? Colors.black : Colors.white)
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
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(
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
                      backgroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      elevation: 4,
                      shadowColor: AppTheme.tealPrimary.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Add to Session',
                          style: GoogleFonts.plusJakartaSans(
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
