import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/split_group.dart';
import '../providers/theme_provider.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';

class EditSplitDialog extends StatefulWidget {
  final SplitGroup splitGroup;

  const EditSplitDialog({
    super.key,
    required this.splitGroup,
  });

  @override
  State<EditSplitDialog> createState() => _EditSplitDialogState();
}

class _EditSplitDialogState extends State<EditSplitDialog> {
  late TextEditingController _nameController;
  late TextEditingController _shortNameController;
  late TextEditingController _descController;
  late List<String> _selectedDays;
  late int _defaultSets;
  late int _defaultReps;
  late Map<String, List<String>> _parts;

  final List<String> _allDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.splitGroup.name);
    _shortNameController = TextEditingController(
      text: widget.splitGroup.shortName.isNotEmpty
          ? widget.splitGroup.shortName
          : widget.splitGroup.effectiveShortName,
    );
    _descController = TextEditingController(text: widget.splitGroup.desc);
    _selectedDays = List<String>.from(widget.splitGroup.days);
    _defaultSets = widget.splitGroup.defaultSets;
    _defaultReps = widget.splitGroup.defaultReps;
    _parts = {};
    widget.splitGroup.parts.forEach((k, v) {
      _parts[k] = List<String>.from(v);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  void _promptAddPart() {
    final partController = TextEditingController();
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add Body Part',
          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: partController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. Chest, Quads, Delts',
            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13),
            filled: true,
            fillColor: isDark ? const Color(0xFF162344) : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = partController.text.trim();
              if (text.isNotEmpty && !_parts.containsKey(text)) {
                setState(() {
                  _parts[text] = [];
                });
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
              foregroundColor: isDark ? Colors.black : Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _promptAddExercise(String part) {
    final exController = TextEditingController();
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add Exercise to $part',
          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: exController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. Incline Dumbbell Press',
            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13),
            filled: true,
            fillColor: isDark ? const Color(0xFF162344) : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = exController.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _parts[part] ??= [];
                  if (!_parts[part]!.any((e) => e.toLowerCase() == text.toLowerCase())) {
                    _parts[part]!.add(text);
                  }
                });
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
              foregroundColor: isDark ? Colors.black : Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _promptEditExercise(String part, int exIndex) {
    final currentName = _parts[part]?[exIndex] ?? '';
    final exController = TextEditingController(text: currentName);
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Exercise',
          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: exController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Exercise name',
            filled: true,
            fillColor: isDark ? const Color(0xFF162344) : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = exController.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _parts[part]?[exIndex] = text;
                });
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
              foregroundColor: isDark ? Colors.black : Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveChanges() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a split name.')),
      );
      return;
    }

    String shortName = _shortNameController.text.trim().toUpperCase();
    if (shortName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a short name (2 to 8 characters).'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final updated = widget.splitGroup.copyWith(
      name: name,
      shortName: shortName,
      desc: _descController.text.trim(),
      days: _selectedDays,
      defaultSets: _defaultSets,
      defaultReps: _defaultReps,
      parts: _parts,
    );

    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    await provider.updateSplitGroup(updated);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Updated split "$name [$shortName]" successfully!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final dialogBg = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subColor = isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B);
    final inputBg = isDark ? const Color(0xFF162344) : const Color(0xFFF8FAFC);

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 780),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F3635) : AppTheme.tealBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.edit_note_rounded,
                          color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Edit Workout Split',
                        style: GoogleFonts.plusJakartaSans(
                          color: titleColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 22),
                    color: subColor,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Scrollable Edit Form
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Split Name & Short Name Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SPLIT NAME',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: subColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  decoration: BoxDecoration(
                                    color: inputBg,
                                    borderRadius: BorderRadius.circular(14),
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
                                      hintText: 'e.g. Upper Body, Push',
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ABBREVIATION',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: subColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  decoration: BoxDecoration(
                                    color: inputBg,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: TextField(
                                    controller: _shortNameController,
                                    maxLength: 8,
                                    textCapitalization: TextCapitalization.characters,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      hintText: 'e.g. UP, PUSH',
                                      hintStyle: GoogleFonts.plusJakartaSans(
                                        color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                                        fontSize: 12,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description Field
                      Text(
                        'DESCRIPTION / NOTES',
                        style: GoogleFonts.plusJakartaSans(
                          color: subColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                        ),
                        child: TextField(
                          controller: _descController,
                          style: GoogleFonts.plusJakartaSans(
                            color: titleColor,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Optional workout notes or focus areas',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Assigned Workout Days Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SCHEDULED WORKOUT DAYS',
                            style: GoogleFonts.plusJakartaSans(
                              color: subColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            _selectedDays.isEmpty ? 'Unassigned' : '${_selectedDays.length} days / week',
                            style: GoogleFonts.plusJakartaSans(
                              color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allDays.map((day) {
                          final isSelected = _selectedDays.contains(day);
                          return InkWell(
                            onTap: () => _toggleDay(day),
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? const Color(0xFF0F3635) : AppTheme.tealBg)
                                    : inputBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                                      : borderColor,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                day,
                                style: GoogleFonts.plusJakartaSans(
                                  color: isSelected
                                      ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                                      : subColor,
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // Default Target Sets & Reps
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DEFAULT SETS',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: subColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: inputBg,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_rounded, size: 18),
                                        onPressed: () {
                                          if (_defaultSets > 1) {
                                            setState(() => _defaultSets--);
                                          }
                                        },
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(6),
                                      ),
                                      Text(
                                        '$_defaultSets',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: titleColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_rounded, size: 18),
                                        onPressed: () {
                                          if (_defaultSets < 15) {
                                            setState(() => _defaultSets++);
                                          }
                                        },
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(6),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DEFAULT REPS',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: subColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: inputBg,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_rounded, size: 18),
                                        onPressed: () {
                                          if (_defaultReps > 1) {
                                            setState(() => _defaultReps--);
                                          }
                                        },
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(6),
                                      ),
                                      Text(
                                        '$_defaultReps',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: titleColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_rounded, size: 18),
                                        onPressed: () {
                                          if (_defaultReps < 50) {
                                            setState(() => _defaultReps++);
                                          }
                                        },
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(6),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Body Parts & Exercises Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'BODY PARTS & EXERCISES',
                            style: GoogleFonts.plusJakartaSans(
                              color: subColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          InkWell(
                            onTap: _promptAddPart,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add_circle_outline_rounded,
                                    size: 16,
                                    color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Add Part',
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
                      const SizedBox(height: 10),

                      if (_parts.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(
                            'No body parts added yet. Tap "+ Add Part" above to add muscle groups.',
                            style: GoogleFonts.plusJakartaSans(
                              color: subColor,
                              fontSize: 12,
                            ),
                          ),
                        )
                      else
                        ..._parts.entries.map((entry) {
                          final partName = entry.key;
                          final exercises = entry.value;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: inputBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                        const SizedBox(width: 8),
                                        Text(
                                          partName,
                                          style: GoogleFonts.plusJakartaSans(
                                            color: titleColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '(${exercises.length})',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: subColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.add_rounded,
                                            size: 18,
                                            color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                                          ),
                                          tooltip: 'Add exercise to $partName',
                                          onPressed: () => _promptAddExercise(partName),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(4),
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18,
                                            color: Colors.red.shade400,
                                          ),
                                          tooltip: 'Delete $partName',
                                          onPressed: () {
                                            setState(() {
                                              _parts.remove(partName);
                                            });
                                          },
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(4),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (exercises.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: List.generate(exercises.length, (exIdx) {
                                      final exName = exercises[exIdx];
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF0B1329) : Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: borderColor),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: () => _promptEditExercise(partName, exIdx),
                                              child: Text(
                                                exName,
                                                style: GoogleFonts.plusJakartaSans(
                                                  color: titleColor,
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _parts[partName]?.removeAt(exIdx);
                                                });
                                              },
                                              child: Icon(
                                                Icons.close_rounded,
                                                size: 14,
                                                color: subColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              // Bottom Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(
                        color: subColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(
                      'Save Changes',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
