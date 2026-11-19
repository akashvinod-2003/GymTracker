import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gym_tracker/providers/theme_provider.dart';
import 'package:gym_tracker/providers/workout_provider.dart';
import '../theme/app_theme.dart';

class LogWeightDialog extends StatefulWidget {
  final double? initialWeight;

  const LogWeightDialog({
    super.key,
    this.initialWeight,
  });

  @override
  State<LogWeightDialog> createState() => _LogWeightDialogState();
}

class _LogWeightDialogState extends State<LogWeightDialog> {
  late TextEditingController _weightController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final startWeight = widget.initialWeight ?? 70.0;
    _weightController = TextEditingController(text: startWeight.toStringAsFixed(1));
    _noteController = TextEditingController();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _adjustWeight(double delta) {
    final current = double.tryParse(_weightController.text) ?? 70.0;
    final next = (current + delta).clamp(10.0, 350.0);
    setState(() {
      _weightController.text = next.toStringAsFixed(1);
      _errorText = null;
    });
  }

  Future<void> _pickDate() async {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: isDark ? ThemeData.dark() : ThemeData.light(),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    final weight = double.tryParse(_weightController.text.trim());
    if (weight == null || weight <= 10.0 || weight > 350.0) {
      setState(() {
        _errorText = 'Please enter a valid weight (10 - 350 kg)';
      });
      return;
    }

    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    workoutProvider.logBodyWeight(
      weightKg: weight,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_sharp, color: AppTheme.successDark, size: 20),
            const SizedBox(width: 8),
            Text(
              'Logged ${weight.toStringAsFixed(1)} kg for ${DateFormat('MMM d').format(_selectedDate)}',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppTheme.n950,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final lastLogged = workoutProvider.latestBodyWeightEntry;

    final dialogBg = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subColor = isDark ? AppTheme.darkTextSecondary : AppTheme.n550;
    final fieldBg = isDark ? AppTheme.n800 : AppTheme.n050;

    final isToday = DateFormat('yyyy-MM-dd').format(_selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    final formattedDate = isToday ? 'Today, ${DateFormat('MMM d').format(_selectedDate)}' : DateFormat('EEE, MMM d, yyyy').format(_selectedDate);

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.turbo,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.monitor_weight_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Log Body Weight',
                            style: GoogleFonts.interTight(
                              color: titleColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Whenever you check your scale',
                            style: GoogleFonts.inter(
                              color: subColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_sharp, color: subColor, size: 20),
                    splashRadius: 20,
                  ),
                ],
              ),

              if (lastLogged != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.t900 : AppTheme.t050,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? AppTheme.t800 : AppTheme.t200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.history_sharp,
                        size: 16,
                        color: isDark ? AppTheme.t300 : AppTheme.turbo,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Last check-in: ${lastLogged.weightKg.toStringAsFixed(1)} kg (${DateFormat('MMM d').format(lastLogged.date)})',
                          style: GoogleFonts.inter(
                            color: isDark ? AppTheme.t200 : AppTheme.t600,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Weight Input Hero Stepper
              Center(
                child: Text(
                  'CURRENT WEIGHT (KG)',
                  style: GoogleFonts.interTight(
                    color: subColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: fieldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _errorText != null ? Colors.redAccent : borderColor),
                ),
                child: Row(
                  children: [
                    // - 0.5 Button
                    _StepperButton(
                      label: '-0.5',
                      onTap: () => _adjustWeight(-0.5),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    _StepperButton(
                      label: '-0.1',
                      onTap: () => _adjustWeight(-0.1),
                      isDark: isDark,
                    ),

                    // Numeric Field
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.interTight(
                          color: titleColor,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          suffixText: 'kg',
                          suffixStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.n500,
                          ),
                        ),
                        onChanged: (_) {
                          if (_errorText != null) {
                            setState(() => _errorText = null);
                          }
                        },
                      ),
                    ),

                    // + Stepper buttons
                    _StepperButton(
                      label: '+0.1',
                      onTap: () => _adjustWeight(0.1),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    _StepperButton(
                      label: '+0.5',
                      onTap: () => _adjustWeight(0.5),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              if (_errorText != null) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    _errorText!,
                    style: GoogleFonts.inter(
                      color: Colors.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Date Picker Field
              Text(
                'CHECK-IN DATE',
                style: GoogleFonts.interTight(
                  color: subColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),

              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: fieldBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_sharp,
                        size: 16,
                        color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: GoogleFonts.inter(
                            color: titleColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        'Change',
                        style: GoogleFonts.inter(
                          color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Optional Note Field
              Text(
                'NOTE (OPTIONAL)',
                style: GoogleFonts.interTight(
                  color: subColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _noteController,
                style: GoogleFonts.inter(
                  color: titleColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Morning fasted, post-workout...',
                  hintStyle: GoogleFonts.inter(
                    color: subColor.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: fieldBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppTheme.tealPrimary, width: 1.5),
                  ),
                ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: borderColor),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          color: subColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: AppTheme.turbo,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'Save Check-in',
                            style: GoogleFonts.interTight(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
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

class _StepperButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _StepperButton({
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.n800 : AppTheme.n150,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.interTight(
            color: isDark ? AppTheme.n500 : AppTheme.n600,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
