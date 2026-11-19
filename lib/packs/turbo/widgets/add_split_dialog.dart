import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:gym_tracker/providers/theme_provider.dart';
import 'package:gym_tracker/providers/workout_provider.dart';
import '../theme/app_theme.dart';

class AddSplitDialog extends StatefulWidget {
  const AddSplitDialog({super.key});

  @override
  State<AddSplitDialog> createState() => _AddSplitDialogState();
}

class _AddSplitDialogState extends State<AddSplitDialog> {
  final _nameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _descController = TextEditingController();
  final List<String> _selectedDays = [];
  final List<String> _allDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);

    final dialogBg = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subColor = isDark ? AppTheme.darkTextSecondary : AppTheme.n550;
    final inputBg = isDark ? AppTheme.n800 : AppTheme.n050;

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.create_new_folder_sharp,
                      color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'New Split Group',
                      style: GoogleFonts.interTight(
                        color: titleColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_sharp, size: 20),
                  color: subColor,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Group Name & Short Name Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GROUP NAME',
                        style: GoogleFonts.interTight(
                          color: subColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                        ),
                        child: TextField(
                          controller: _nameController,
                          style: GoogleFonts.inter(
                            color: titleColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g. Upper Body, Push',
                            hintStyle: GoogleFonts.inter(
                              color: isDark ? AppTheme.n600 : AppTheme.n500,
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
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ABBREVIATION',
                        style: GoogleFonts.interTight(
                          color: subColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                        ),
                        child: TextField(
                          controller: _shortNameController,
                          maxLength: 8,
                          textCapitalization: TextCapitalization.characters,
                          style: GoogleFonts.interTight(
                            color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: 'e.g. UP, PUSH',
                            hintStyle: GoogleFonts.inter(
                              color: isDark ? AppTheme.n600 : AppTheme.n500,
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
            const SizedBox(height: 14),

            // Description
            Text(
              'DESCRIPTION (OPTIONAL)',
              style: GoogleFonts.interTight(
                color: subColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: _descController,
                style: GoogleFonts.inter(
                  color: titleColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Compound presses and anterior work',
                  hintStyle: GoogleFonts.inter(
                    color: isDark ? AppTheme.n600 : AppTheme.n500,
                    fontSize: 12,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Workout Days
            Text(
              'SCHEDULED DAYS (OPTIONAL)',
              style: GoogleFonts.interTight(
                color: subColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _allDays.map((day) {
                final isSelected = _selectedDays.contains(day);
                return InkWell(
                  onTap: () => _toggleDay(day),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppTheme.t800 : AppTheme.tealBg)
                          : inputBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                            : borderColor,
                      ),
                    ),
                    child: Text(
                      day,
                      style: GoogleFonts.interTight(
                        color: isSelected
                            ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                            : subColor,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      color: subColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
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
                        const SnackBar(content: Text('Please enter a short name (2 to 8 characters).')),
                      );
                      return;
                    }

                    workoutProvider.addSplitGroup(
                      name: name,
                      shortName: shortName,
                      desc: _descController.text.trim(),
                      days: _selectedDays,
                    );
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Created split "$name [$shortName]" successfully!'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.turbo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                  child: Text(
                    'Create',
                    style: GoogleFonts.interTight(
                      fontWeight: FontWeight.w800,
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
}
