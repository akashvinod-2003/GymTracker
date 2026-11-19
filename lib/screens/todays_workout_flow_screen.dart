import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/exercise.dart';
import '../models/exercise_progress_comparison.dart';
import '../models/split_group.dart';
import '../models/workout_session.dart';
import '../models/workout_set.dart';
import '../providers/theme_provider.dart';
import '../providers/workout_provider.dart';
import '../services/streak_service.dart';
import '../theme/app_theme.dart';
import '../widgets/add_split_dialog.dart';
import '../widgets/last_workout_sheet.dart';

/// Guided 3-step workout entry workflow for today's session:
/// Step 1: Select Workout Split
/// Step 2: Review Last Workout for Selected Split
/// Step 3: Enter Today's Workout
class TodaysWorkoutFlowScreen extends StatefulWidget {
  final String? initialSplitId;

  const TodaysWorkoutFlowScreen({super.key, this.initialSplitId});

  static Future<void> start(BuildContext context, {String? initialSplitId}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => TodaysWorkoutFlowScreen(initialSplitId: initialSplitId),
      ),
    );
  }

  @override
  State<TodaysWorkoutFlowScreen> createState() => _TodaysWorkoutFlowScreenState();
}

class _TodaysWorkoutFlowScreenState extends State<TodaysWorkoutFlowScreen> {
  final _uuid = const Uuid();
  int _currentStep = 1; // 1: Select Split, 2: Review Last, 3: Enter Workout

  SplitGroup? _selectedSplit;
  WorkoutSession? _lastSession;
  SessionProgressComparison? _progressComparison;

  // Working copy of today's exercises during Step 3
  List<Exercise> _todayExercises = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initWorkflow();
    });
  }

  Future<void> _initWorkflow() async {
    final wp = Provider.of<WorkoutProvider>(context, listen: false);
    await wp.ensureHistoryLoaded();

    final today = StreakService.nowIST;
    final scheduledSplit = wp.getSplitForDate(today);

    SplitGroup? initial;
    if (widget.initialSplitId != null) {
      initial = wp.splitGroups.firstWhere(
        (g) => g.id == widget.initialSplitId,
        orElse: () => wp.splitGroups.isNotEmpty ? wp.splitGroups.first : SplitGroup.defaultGroups.first,
      );
    } else if (scheduledSplit != null) {
      initial = scheduledSplit;
    } else if (wp.currentSession.splitId != null) {
      initial = wp.splitGroups.firstWhere(
        (g) => g.id == wp.currentSession.splitId,
        orElse: () => wp.splitGroups.isNotEmpty ? wp.splitGroups.first : SplitGroup.defaultGroups.first,
      );
    } else if (wp.splitGroups.isNotEmpty) {
      initial = wp.splitGroups.first;
    }

    // Load existing exercises from today's session if any
    final existingSession = wp.currentSession;
    _todayExercises = existingSession.exercises.map((e) => e.copyWith()).toList();

    setState(() {
      _selectedSplit = initial;
      _isInitialized = true;
    });

    if (initial != null) {
      _loadLastSessionForSplit(initial);
    }
  }

  void _loadLastSessionForSplit(SplitGroup split) {
    final wp = Provider.of<WorkoutProvider>(context, listen: false);
    final last = wp.getLastWorkoutForSplit(split.id, splitName: split.name);
    SessionProgressComparison? comp;
    if (last != null) {
      final preceding = wp.getPreviousWorkoutBeforeSession(
        last,
        splitId: split.id,
        splitName: split.name,
      );
      comp = SessionProgressComparison.compute(
        current: last,
        previous: preceding,
        allHistoricalSessions: wp.sessions.values.toList(),
      );
    }

    setState(() {
      _lastSession = last;
      _progressComparison = comp;
    });
  }

  void _onSplitSelected(SplitGroup split) {
    setState(() {
      _selectedSplit = split;
    });
    _loadLastSessionForSplit(split);
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
  }

  // --- Step 3 Exercise Manipulation ---

  void _addExerciseFromSplit(String exerciseName, String partName) {
    // Avoid duplicate addition if already added today
    final alreadyExists = _todayExercises.any((e) => e.name.trim().toLowerCase() == exerciseName.trim().toLowerCase());
    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$exerciseName is already in today\'s workout.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    final targetSets = _selectedSplit?.defaultSets ?? 3;
    final targetReps = _selectedSplit?.defaultReps ?? 10;

    // Check last workout for weight recommendation
    double recommendedWeight = 20.0;
    if (_lastSession != null) {
      for (var ex in _lastSession!.exercises) {
        if (ex.name.trim().toLowerCase() == exerciseName.trim().toLowerCase() && ex.sets.isNotEmpty) {
          recommendedWeight = ex.sets.last.weight;
          break;
        }
      }
    }

    final newEx = Exercise(
      id: 'ex-${DateTime.now().millisecondsSinceEpoch}-${_uuid.v4().substring(0, 4)}',
      name: exerciseName,
      group: _selectedSplit?.name ?? 'Custom',
      part: partName,
      equipment: 'Dumbbell',
      sets: List.generate(
        targetSets,
        (index) => WorkoutSet(
          setNumber: index + 1,
          weight: recommendedWeight,
          reps: targetReps,
          completed: index == 0,
        ),
      ),
    );

    setState(() {
      _todayExercises.add(newEx);
    });
  }

  void _promptAddCustomExercise() {
    final nameCtrl = TextEditingController();
    final weightCtrl = TextEditingController(text: '20');
    final repsCtrl = TextEditingController(text: '10');
    String equipment = 'Dumbbell';
    String part = _selectedSplit?.partNames.isNotEmpty == true ? _selectedSplit!.partNames.first : 'General';

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Provider.of<ThemeProvider>(ctx).isDarkMode(ctx);
        final bg = isDark ? AppTheme.darkCard : Colors.white;
        final titleCol = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              backgroundColor: bg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('Add Custom Exercise', style: GoogleFonts.plusJakartaSans(color: titleCol, fontWeight: FontWeight.w800, fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Exercise Name', hintText: 'e.g. Incline Bench Press'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: weightCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Weight (kg)'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: repsCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Reps'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    final w = double.tryParse(weightCtrl.text) ?? 20.0;
                    final r = int.tryParse(repsCtrl.text) ?? 10;
                    final newEx = Exercise(
                      id: 'ex-${DateTime.now().millisecondsSinceEpoch}-${_uuid.v4().substring(0, 4)}',
                      name: name,
                      group: _selectedSplit?.name ?? 'Custom',
                      part: part,
                      equipment: equipment,
                      sets: [
                        WorkoutSet(setNumber: 1, weight: w, reps: r, completed: true),
                      ],
                    );
                    setState(() {
                      _todayExercises.add(newEx);
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Add Exercise'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addSetToExercise(int exerciseIndex) {
    final ex = _todayExercises[exerciseIndex];
    final lastSet = ex.sets.isNotEmpty ? ex.sets.last : null;
    final newSet = WorkoutSet(
      setNumber: ex.sets.length + 1,
      weight: lastSet?.weight ?? 20.0,
      reps: lastSet?.reps ?? 10,
      completed: false,
    );
    setState(() {
      ex.sets.add(newSet);
    });
  }

  void _removeSetFromExercise(int exerciseIndex, int setIndex) {
    setState(() {
      _todayExercises[exerciseIndex].sets.removeAt(setIndex);
      // Re-number remaining sets
      for (int i = 0; i < _todayExercises[exerciseIndex].sets.length; i++) {
        _todayExercises[exerciseIndex].sets[i] = _todayExercises[exerciseIndex].sets[i].copyWith(setNumber: i + 1);
      }
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _todayExercises.removeAt(index);
    });
  }

  Future<void> _finishAndSaveWorkout() async {
    if (_todayExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one exercise before saving today\'s workout.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final wp = Provider.of<WorkoutProvider>(context, listen: false);
    final todayKey = StreakService.todayKeyIST;

    final updatedSession = WorkoutSession(
      date: todayKey,
      splitId: _selectedSplit?.id,
      splitName: _selectedSplit?.name,
      exercises: _todayExercises,
    );

    await wp.saveWorkoutSession(updatedSession);

    if (!mounted) return;
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Today\'s ${_selectedSplit?.name ?? "Workout"} saved! 🔥 ${wp.currentStreak} Day Streak.',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final wp = Provider.of<WorkoutProvider>(context);

    final bg = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final cardBg = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subColor = isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: titleColor,
          onPressed: () {
            if (_currentStep > 1) {
              _goToStep(_currentStep - 1);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TODAY\'S WORKOUT FLOW',
              style: GoogleFonts.plusJakartaSans(
                color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              _currentStep == 1
                  ? 'Step 1: Select Split'
                  : _currentStep == 2
                      ? 'Step 2: Review Last Workout'
                      : 'Step 3: Enter Today\'s Workout',
              style: GoogleFonts.plusJakartaSans(
                color: titleColor,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            color: subColor,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildStepIndicator(isDark, titleColor, subColor),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: !_isInitialized
                  ? const Center(child: CircularProgressIndicator())
                  : _currentStep == 1
                      ? _buildStep1SelectSplit(wp, isDark, cardBg, borderColor, titleColor, subColor)
                      : _currentStep == 2
                          ? _buildStep2ReviewLast(isDark, cardBg, borderColor, titleColor, subColor)
                          : _buildStep3EnterWorkout(isDark, cardBg, borderColor, titleColor, subColor),
            ),
          ),
        ),
      ),
    );
  }

  // --- Step Indicator ---

  Widget _buildStepIndicator(bool isDark, Color titleColor, Color subColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildStepItem(1, 'Split', _currentStep >= 1, _currentStep == 1, isDark),
          _buildStepDivider(_currentStep >= 2, isDark),
          _buildStepItem(2, 'Review', _currentStep >= 2, _currentStep == 2, isDark),
          _buildStepDivider(_currentStep >= 3, isDark),
          _buildStepItem(3, 'Workout', _currentStep >= 3, _currentStep == 3, isDark),
        ],
      ),
    );
  }

  Widget _buildStepItem(int stepNumber, String label, bool isDoneOrActive, bool isActive, bool isDark) {
    final activeColor = isDark ? AppTheme.tealLight : AppTheme.tealPrimary;
    final inactiveColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textCol = isActive
        ? activeColor
        : (isDoneOrActive ? (isDark ? Colors.white : Colors.black87) : const Color(0xFF94A3B8));

    return InkWell(
      onTap: () {
        // Can jump back to previous steps
        if (stepNumber < _currentStep) {
          _goToStep(stepNumber);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isActive
                  ? activeColor
                  : (isDoneOrActive ? (isDark ? const Color(0xFF0F3635) : AppTheme.tealBg) : inactiveColor),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: GoogleFonts.plusJakartaSans(
                  color: isActive
                      ? (isDark ? Colors.black : Colors.white)
                      : (isDoneOrActive ? activeColor : const Color(0xFF94A3B8)),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: textCol,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider(bool isCompleted, bool isDark) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isCompleted
            ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
    );
  }

  // --- Step 1: Select Workout Split ---

  Widget _buildStep1SelectSplit(
    WorkoutProvider wp,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color titleColor,
    Color subColor,
  ) {
    final splits = wp.splitGroups;
    final today = StreakService.nowIST;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What are you training today?',
                  style: GoogleFonts.plusJakartaSans(
                    color: titleColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select your workout split below. We\'ll load your last performance so you can beat your targets.',
                  style: GoogleFonts.plusJakartaSans(
                    color: subColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),

                if (splits.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.splitscreen_rounded, size: 48, color: subColor),
                          const SizedBox(height: 12),
                          Text('No workout splits found', style: GoogleFonts.plusJakartaSans(color: titleColor, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => const AddSplitDialog(),
                              );
                            },
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Create a Workout Split'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...splits.map((split) {
                    final isSelected = _selectedSplit?.id == split.id;
                    final isScheduledToday = split.isScheduledForDateTime(today);

                    return InkWell(
                      onTap: () => _onSplitSelected(split),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? const Color(0xFF0F3635) : AppTheme.tealBg)
                              : cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                                : borderColor,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                                    : (isDark ? const Color(0xFF162344) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.fitness_center_rounded,
                                color: isSelected
                                    ? (isDark ? Colors.black : Colors.white)
                                    : (isDark ? AppTheme.tealLight : AppTheme.tealPrimary),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          split.name,
                                          style: GoogleFonts.plusJakartaSans(
                                            color: titleColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      if (isScheduledToday) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF3C7),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFFFDE68A)),
                                          ),
                                          child: Text(
                                            'Today\'s Scheduled',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: const Color(0xFF92400E),
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (split.desc.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      split.desc,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: subColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      ...split.partNames.map((part) => Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF162344) : const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              part,
                                              style: GoogleFonts.plusJakartaSans(
                                                color: subColor,
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          )),
                                      if (split.days.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF16324F) : const Color(0xFFE0F2FE),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            split.days.join(', '),
                                            style: GoogleFonts.plusJakartaSans(
                                              color: isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0284C7),
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                                      : borderColor,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: isDark ? Colors.black : Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),

        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Cancel', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _selectedSplit != null ? () => _goToStep(2) : null,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text('Next: Review Last Workout', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Step 2: Review Last Workout for Selected Split ---

  Widget _buildStep2ReviewLast(
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color titleColor,
    Color subColor,
  ) {
    final split = _selectedSplit;
    if (split == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () => _goToStep(1),
          child: const Text('Please select a split first'),
        ),
      );
    }

    final session = _lastSession;
    final progress = _progressComparison;

    String formattedDate = '';
    String relativeTime = '';
    if (session != null) {
      try {
        final parsedDate = DateTime.parse(session.date);
        formattedDate = DateFormat('EEEE, MMM d, yyyy').format(parsedDate);
        final diffDays = DateTime.now().difference(parsedDate).inDays;
        relativeTime = diffDays == 0 ? 'Today' : (diffDays == 1 ? 'Yesterday' : '$diffDays days ago');
      } catch (_) {
        formattedDate = session.date;
      }
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Split Eyebrow & Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PREVIOUS PERFORMANCE',
                          style: GoogleFonts.plusJakartaSans(
                            color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          'Last ${split.name} Session',
                          style: GoogleFonts.plusJakartaSans(
                            color: titleColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => _goToStep(1),
                      icon: const Icon(Icons.edit_rounded, size: 14),
                      label: const Text('Change Split'),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (session == null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F3635) : AppTheme.tealBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.history_toggle_off_rounded,
                            size: 32,
                            color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No previous workout found for this split.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: titleColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'This will be your first session for ${split.name}! Tap Next to start entering today\'s exercises.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: subColor,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  // Date banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF162344) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month_rounded, size: 16, color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary),
                        const SizedBox(width: 8),
                        Text(
                          '$formattedDate ($relativeTime)',
                          style: GoogleFonts.plusJakartaSans(
                            color: titleColor,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Metrics Summary
                  Row(
                    children: [
                      _buildMetricCard(
                        'Total Volume',
                        '${session.totalVolume.toStringAsFixed(0)} kg',
                        progress?.volumeDiff != null && progress!.volumeDiff != 0
                            ? '${progress.volumeDiff! > 0 ? "+" : ""}${progress.volumeDiff!.toStringAsFixed(0)} kg'
                            : null,
                        (progress?.volumeDiff ?? 0) >= 0,
                        isDark,
                        cardBg,
                        borderColor,
                        titleColor,
                      ),
                      const SizedBox(width: 10),
                      _buildMetricCard(
                        'Completed Sets',
                        '${session.completedSets}',
                        progress?.setsDiff != null && progress!.setsDiff != 0
                            ? '${progress.setsDiff! > 0 ? "+" : ""}${progress.setsDiff} sets'
                            : null,
                        (progress?.setsDiff ?? 0) >= 0,
                        isDark,
                        cardBg,
                        borderColor,
                        titleColor,
                      ),
                      const SizedBox(width: 10),
                      _buildMetricCard(
                        'Exercises',
                        '${session.exercises.length}',
                        progress != null && progress.personalBestsCount > 0 ? '${progress.personalBestsCount} PBs 🏆' : null,
                        true,
                        isDark,
                        cardBg,
                        borderColor,
                        titleColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Exercises list
                  Text(
                    'EXERCISES FROM LAST SESSION',
                    style: GoogleFonts.plusJakartaSans(
                      color: subColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ...session.exercises.map((exercise) {
                    final comp = progress?.comparisons.firstWhere(
                      (c) => c.exerciseName.trim().toLowerCase() == exercise.name.trim().toLowerCase(),
                      orElse: () => ExerciseProgressComparison.compute(currentExercise: exercise),
                    );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  exercise.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: titleColor,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (comp != null && comp.isPersonalBest) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('🏆 PR', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF92400E), fontSize: 10, fontWeight: FontWeight.w800)),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F3635) : AppTheme.tealBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  exercise.equipment,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (comp != null && comp.hasPreviousData && (comp.weightDiff != 0 || comp.repsDiff != 0)) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Progress vs earlier: ${comp.weightDiff != null && comp.weightDiff != 0 ? (comp.weightDiff! > 0 ? "+${comp.weightDiff!.toStringAsFixed(1)} kg" : "${comp.weightDiff!.toStringAsFixed(1)} kg") : ""} ${comp.repsDiff != null && comp.repsDiff != 0 ? (comp.repsDiff! > 0 ? "+${comp.repsDiff} reps" : "${comp.repsDiff} reps") : ""}',
                              style: GoogleFonts.plusJakartaSans(
                                color: (comp.weightDiff ?? 0) >= 0 ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: exercise.sets.map((s) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF162344) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Text(
                                  'Set ${s.setNumber}: ${s.weight.toStringAsFixed(s.weight % 1 == 0 ? 0 : 1)} kg × ${s.reps}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: titleColor,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),

        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _goToStep(1),
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: Text('Back', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => _goToStep(3),
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: Text('Start Today\'s Workout', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String? subtitle,
    bool isPositive,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color titleColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.plusJakartaSans(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 10.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.plusJakartaSans(color: titleColor, fontSize: 15, fontWeight: FontWeight.w800)),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- Step 3: Enter Today's Workout ---

  Widget _buildStep3EnterWorkout(
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color titleColor,
    Color subColor,
  ) {
    final split = _selectedSplit;

    // Split configured catalog exercises for quick addition
    final List<MapEntry<String, String>> catalogExercises = [];
    if (split != null) {
      split.parts.forEach((part, exList) {
        for (var exName in exList) {
          catalogExercises.add(MapEntry(exName, part));
        }
      });
    }

    final double totalVolume = _todayExercises.fold(0.0, (sum, e) => sum + e.totalVolume);
    final int completedSets = _todayExercises.fold(0, (sum, e) => sum + e.completedSetsCount);
    final int totalSets = _todayExercises.fold(0, (sum, e) => sum + e.sets.length);

    return Column(
      children: [
        // Top Split Banner with "Last Workout" Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F3635) : AppTheme.tealBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.fitness_center_rounded, color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE SPLIT',
                      style: GoogleFonts.plusJakartaSans(
                        color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      split?.name ?? 'Today\'s Workout',
                      style: GoogleFonts.plusJakartaSans(
                        color: titleColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              // "Last Workout" Button
              ElevatedButton.icon(
                onPressed: () {
                  if (split != null) {
                    LastWorkoutSheet.show(context, split, session: _lastSession);
                  }
                },
                icon: const Icon(Icons.history_rounded, size: 15),
                label: const Text('Last Workout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF162344) : const Color(0xFFF1F5F9),
                  foregroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFCBD5E1)),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Realtime stats bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('${_todayExercises.length} Exercises', style: GoogleFonts.plusJakartaSans(color: subColor, fontSize: 11.5, fontWeight: FontWeight.w700)),
              Text('•', style: TextStyle(color: subColor)),
              Text('$completedSets / $totalSets Sets Done', style: GoogleFonts.plusJakartaSans(color: subColor, fontSize: 11.5, fontWeight: FontWeight.w700)),
              Text('•', style: TextStyle(color: subColor)),
              Text('${totalVolume.toStringAsFixed(0)} kg Lifted', style: GoogleFonts.plusJakartaSans(color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary, fontSize: 11.5, fontWeight: FontWeight.w800)),
            ],
          ),
        ),

        // Exercises Editor
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Add Chips from Selected Split
                if (catalogExercises.isNotEmpty) ...[
                  Text(
                    'QUICK ADD FROM ${split?.name.toUpperCase()}',
                    style: GoogleFonts.plusJakartaSans(
                      color: subColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: catalogExercises.map((entry) {
                      final exName = entry.key;
                      final part = entry.value;
                      final isAdded = _todayExercises.any((e) => e.name.trim().toLowerCase() == exName.trim().toLowerCase());

                      return ActionChip(
                        avatar: Icon(
                          isAdded ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                          size: 16,
                          color: isAdded
                              ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                              : subColor,
                        ),
                        label: Text(exName),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          color: isAdded ? titleColor : subColor,
                          fontSize: 11.5,
                          fontWeight: isAdded ? FontWeight.w800 : FontWeight.w600,
                        ),
                        backgroundColor: isAdded
                            ? (isDark ? const Color(0xFF0F3635) : AppTheme.tealBg)
                            : cardBg,
                        side: BorderSide(
                          color: isAdded
                              ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                              : borderColor,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onPressed: () => _addExerciseFromSplit(exName, part),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                ],

                // Action to Add Custom
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TODAY\'S EXERCISES',
                      style: GoogleFonts.plusJakartaSans(
                        color: subColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _promptAddCustomExercise,
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add Custom Exercise'),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (_todayExercises.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.playlist_add_rounded, size: 40, color: subColor),
                        const SizedBox(height: 12),
                        Text('No exercises added yet', style: GoogleFonts.plusJakartaSans(color: titleColor, fontWeight: FontWeight.w800, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text('Tap a quick add chip above or add a custom exercise to begin today\'s log.', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(color: subColor, fontSize: 12.5)),
                      ],
                    ),
                  )
                else
                  ..._todayExercises.asMap().entries.map((entry) {
                    final exIndex = entry.key;
                    final ex = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Exercise title & remove button
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ex.name,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: titleColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      '${ex.part} • ${ex.equipment}',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: subColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                color: const Color(0xFFEF4444),
                                onPressed: () => _removeExercise(exIndex),
                                tooltip: 'Remove exercise',
                              ),
                            ],
                          ),
                          const Divider(height: 16),

                          // Sets list
                          ...ex.sets.asMap().entries.map((setEntry) {
                            final setIndex = setEntry.key;
                            final setItem = setEntry.value;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  // Set indicator
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF162344) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${setItem.setNumber}',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: titleColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Weight input
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            if (setItem.weight > 0) {
                                              setState(() {
                                                setItem.weight = (setItem.weight - 2.5).clamp(0, 500);
                                              });
                                            }
                                          },
                                          borderRadius: BorderRadius.circular(6),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Icon(Icons.remove_rounded, size: 16, color: subColor),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${setItem.weight.toStringAsFixed(setItem.weight % 1 == 0 ? 0 : 1)} kg',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: titleColor,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              setItem.weight += 2.5;
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(6),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Icon(Icons.add_rounded, size: 16, color: subColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Reps input
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            if (setItem.reps > 1) {
                                              setState(() {
                                                setItem.reps--;
                                              });
                                            }
                                          },
                                          borderRadius: BorderRadius.circular(6),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Icon(Icons.remove_rounded, size: 16, color: subColor),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${setItem.reps} reps',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: titleColor,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              setItem.reps++;
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(6),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Icon(Icons.add_rounded, size: 16, color: subColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Checkbox for Completed
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        setItem.completed = !setItem.completed;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: setItem.completed
                                            ? (isDark ? const Color(0xFF0F3635) : AppTheme.tealBg)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: setItem.completed
                                              ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                                              : borderColor,
                                        ),
                                      ),
                                      child: Icon(
                                        setItem.completed ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                                        size: 16,
                                        color: setItem.completed
                                            ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                                            : subColor,
                                      ),
                                    ),
                                  ),

                                  // Delete set button
                                  if (ex.sets.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, size: 14),
                                      color: subColor,
                                      padding: const EdgeInsets.all(4),
                                      constraints: const BoxConstraints(),
                                      onPressed: () => _removeSetFromExercise(exIndex, setIndex),
                                    ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => _addSetToExercise(exIndex),
                              icon: const Icon(Icons.add_rounded, size: 14),
                              label: const Text('Add Set'),
                              style: TextButton.styleFrom(
                                foregroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),

        // Bottom Save / Finish Action Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _goToStep(2),
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: Text('Back to Review', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _finishAndSaveWorkout,
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: Text('Save & Finish Workout', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
