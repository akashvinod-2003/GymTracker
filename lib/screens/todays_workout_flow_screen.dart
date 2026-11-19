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

/// Redesigned Guided Workout Flow & Real-Time Tracking Experience:
/// - Step 1: Explicitly select a workout split
/// - Step 2: Review previous session performance & targets
/// - Step 3: Live interactive workout tracking: pick body parts, add exercises,
///           log weight/reps set-by-set during exercise, confirm completion explicitly,
///           persist drafts automatically, and confirm before finishing.
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

  // Workflow steps:
  // 1: Select Split
  // 2: Review Last Workout
  // 3: Live Actual Workout Tracking
  int _currentStep = 1;

  SplitGroup? _selectedSplit;
  WorkoutSession? _lastSession;
  SessionProgressComparison? _progressComparison;

  // Active workout tracking state (Step 3)
  List<Exercise> _activeExercises = [];
  String? _selectedBodyPart;
  bool _isInitialized = false;
  bool _isSaving = false;

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

    // Check if an active workout draft is already in progress for today
    final draft = wp.activeWorkoutDraft;
    if (draft != null && (draft.exercises.isNotEmpty || draft.splitId != null)) {
      // Restore from draft directly into Step 3
      SplitGroup? matchingSplit;
      if (draft.splitId != null) {
        matchingSplit = wp.splitGroups.where((g) => g.id == draft.splitId).firstOrNull;
      }
      matchingSplit ??= wp.splitGroups.where((g) => g.name == draft.splitName).firstOrNull;
      matchingSplit ??= wp.splitGroups.isNotEmpty ? wp.splitGroups.first : null;

      _selectedSplit = matchingSplit;
      _activeExercises = draft.exercises.map((e) => e.copyWith()).toList();
      _selectedBodyPart = matchingSplit?.partNames.isNotEmpty == true ? matchingSplit!.partNames.first : null;

      if (matchingSplit != null) {
        _loadLastSessionForSplit(matchingSplit);
      }

      setState(() {
        _currentStep = 3; // Resume active workout
        _isInitialized = true;
      });
      return;
    }

    // New workout flow starting from Step 1
    SplitGroup? initial;
    if (widget.initialSplitId != null) {
      initial = wp.splitGroups.where((g) => g.id == widget.initialSplitId).firstOrNull;
    }

    setState(() {
      _selectedSplit = initial;
      _currentStep = 1; // Always start at Step 1 for explicit selection
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

  void _startActualWorkout() {
    if (_selectedSplit == null) return;
    final wp = Provider.of<WorkoutProvider>(context, listen: false);

    _selectedBodyPart = _selectedSplit!.partNames.isNotEmpty ? _selectedSplit!.partNames.first : null;

    // Initialize active workout draft if empty
    if (_activeExercises.isEmpty) {
      wp.startActiveWorkout(_selectedSplit!);
    }

    setState(() {
      _currentStep = 3;
    });
  }

  // --- Draft Auto-Persistence ---

  void _syncDraft() {
    if (_selectedSplit == null) return;
    final wp = Provider.of<WorkoutProvider>(context, listen: false);
    final session = WorkoutSession(
      date: StreakService.todayKeyIST,
      splitId: _selectedSplit!.id,
      splitName: _selectedSplit!.name,
      splitShortName: _selectedSplit!.effectiveShortName,
      exercises: _activeExercises,
    );
    wp.saveActiveWorkoutDraft(session);
  }

  // --- Step 3 Live Exercise & Set Tracking ---

  void _addExerciseToWorkout(String exerciseName, String partName) {
    final alreadyExists = _activeExercises.any(
      (e) => e.name.trim().toLowerCase() == exerciseName.trim().toLowerCase(),
    );
    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$exerciseName is already in this workout.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    // Determine suggestion from previous workout
    double suggestedWeight = 20.0;
    int suggestedReps = _selectedSplit?.defaultReps ?? 10;
    if (_lastSession != null) {
      for (var ex in _lastSession!.exercises) {
        if (ex.name.trim().toLowerCase() == exerciseName.trim().toLowerCase() && ex.sets.isNotEmpty) {
          suggestedWeight = ex.sets.last.weight;
          suggestedReps = ex.sets.last.reps;
          break;
        }
      }
    }

    // Start with 1 set: NOT completed automatically
    final newExercise = Exercise(
      id: 'ex-${DateTime.now().millisecondsSinceEpoch}-${_uuid.v4().substring(0, 4)}',
      name: exerciseName,
      group: _selectedSplit?.name ?? 'Custom',
      part: partName,
      equipment: 'Dumbbell',
      sets: [
        WorkoutSet(
          setNumber: 1,
          weight: suggestedWeight,
          reps: suggestedReps,
          completed: false, // Must be confirmed explicitly by user
        ),
      ],
    );

    setState(() {
      _activeExercises.add(newExercise);
    });
    _syncDraft();
  }

  void _promptAddCustomExercise() {
    final nameCtrl = TextEditingController();
    final weightCtrl = TextEditingController(text: '20');
    final repsCtrl = TextEditingController(text: '10');
    String equipment = 'Dumbbell';
    String part = _selectedBodyPart ?? (_selectedSplit?.partNames.isNotEmpty == true ? _selectedSplit!.partNames.first : 'General');

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
              title: Text(
                'Add Exercise to $part',
                style: GoogleFonts.plusJakartaSans(color: titleCol, fontWeight: FontWeight.w800, fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      autofocus: true,
                      decoration: const InputDecoration(labelText: 'Exercise Name', hintText: 'e.g. Incline Bench Press'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: weightCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Starting Weight (kg)'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: repsCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Target Reps'),
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
                        WorkoutSet(setNumber: 1, weight: w, reps: r, completed: false),
                      ],
                    );
                    setState(() {
                      _activeExercises.add(newEx);
                    });
                    _syncDraft();
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
    final ex = _activeExercises[exerciseIndex];
    final lastSet = ex.sets.isNotEmpty ? ex.sets.last : null;
    final newSet = WorkoutSet(
      setNumber: ex.sets.length + 1,
      weight: lastSet?.weight ?? 20.0,
      reps: lastSet?.reps ?? 10,
      completed: false, // Explicit confirmation required
    );
    setState(() {
      ex.sets.add(newSet);
    });
    _syncDraft();
  }

  void _removeSetFromExercise(int exerciseIndex, int setIndex) {
    setState(() {
      _activeExercises[exerciseIndex].sets.removeAt(setIndex);
      for (int i = 0; i < _activeExercises[exerciseIndex].sets.length; i++) {
        _activeExercises[exerciseIndex].sets[i] = _activeExercises[exerciseIndex].sets[i].copyWith(setNumber: i + 1);
      }
    });
    _syncDraft();
  }

  void _toggleSetCompletion(int exerciseIndex, int setIndex) {
    setState(() {
      final cur = _activeExercises[exerciseIndex].sets[setIndex];
      _activeExercises[exerciseIndex].sets[setIndex] = cur.copyWith(completed: !cur.completed);
    });
    _syncDraft();
  }

  void _adjustWeight(int exerciseIndex, int setIndex, double delta) {
    setState(() {
      final cur = _activeExercises[exerciseIndex].sets[setIndex];
      final newWeight = (cur.weight + delta).clamp(0.0, 500.0);
      _activeExercises[exerciseIndex].sets[setIndex] = cur.copyWith(weight: newWeight);
    });
    _syncDraft();
  }

  void _adjustReps(int exerciseIndex, int setIndex, int delta) {
    setState(() {
      final cur = _activeExercises[exerciseIndex].sets[setIndex];
      final newReps = (cur.reps + delta).clamp(1, 100);
      _activeExercises[exerciseIndex].sets[setIndex] = cur.copyWith(reps: newReps);
    });
    _syncDraft();
  }

  void _removeExercise(int index) {
    setState(() {
      _activeExercises.removeAt(index);
    });
    _syncDraft();
  }

  // --- Finish Workout & Confirmation ---

  Future<void> _confirmAndFinishWorkout() async {
    if (_isSaving) return;

    if (_activeExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add at least one exercise before finishing the workout.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final completedSetsCount = _activeExercises.fold(0, (sum, e) => sum + e.completedSetsCount);
    final totalSetsCount = _activeExercises.fold(0, (sum, e) => sum + e.sets.length);
    final volume = _activeExercises.fold(0.0, (sum, e) => sum + e.totalVolume);

    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode(context);

    final shouldFinish = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24),
            const SizedBox(width: 8),
            Text(
              'Finish Workout?',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 17),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary for today\'s ${_selectedSplit?.name}:',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5),
            ),
            const SizedBox(height: 10),
            Text('• ${_activeExercises.length} Exercises performed'),
            Text('• $completedSetsCount of $totalSetsCount Sets completed'),
            Text('• ${volume.toStringAsFixed(0)} kg Total lifted volume'),
            if (completedSetsCount < totalSetsCount) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFF92400E), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have ${totalSetsCount - completedSetsCount} uncompleted sets. Only completed sets count toward your streak and volume statistics.',
                        style: GoogleFonts.plusJakartaSans(color: const Color(0xFF92400E), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Training'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Finish & Save'),
          ),
        ],
      ),
    );

    if (shouldFinish != true) return;
    if (!mounted) return;

    setState(() {
      _isSaving = true;
    });

    final wp = Provider.of<WorkoutProvider>(context, listen: false);
    final todayKey = StreakService.todayKeyIST;

    final completedSession = WorkoutSession(
      date: todayKey,
      splitId: _selectedSplit?.id,
      splitName: _selectedSplit?.name,
      splitShortName: _selectedSplit?.effectiveShortName,
      exercises: _activeExercises,
    );

    final success = await wp.saveWorkoutSession(completedSession);

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${_selectedSplit?.name ?? "Workout"} finished & saved! 🔥 ${wp.currentStreak} Day Streak.',
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
            if (_currentStep == 2) {
              _goToStep(1);
            } else if (_currentStep == 3) {
              // Minimize or go back while preserving draft
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentStep == 3 ? 'LIVE WORKOUT TRACKER' : 'TODAY\'S WORKOUT FLOW',
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
                      : 'Step 3: Training ${_selectedSplit?.name ?? ""}',
              style: GoogleFonts.plusJakartaSans(
                color: titleColor,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          if (_currentStep == 3 && _selectedSplit != null)
            TextButton.icon(
              onPressed: () => LastWorkoutSheet.show(context, _selectedSplit!, session: _lastSession),
              icon: const Icon(Icons.history_rounded, size: 16),
              label: const Text('Last Workout'),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
              ),
            ),
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
                          : _buildStep3LiveTracking(isDark, cardBg, borderColor, titleColor, subColor),
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
          _buildStepItem(1, 'Select Split', _currentStep >= 1, _currentStep == 1, isDark),
          _buildStepDivider(_currentStep >= 2, isDark),
          _buildStepItem(2, 'Review Last', _currentStep >= 2, _currentStep == 2, isDark),
          _buildStepDivider(_currentStep >= 3, isDark),
          _buildStepItem(3, 'Train Now', _currentStep >= 3, _currentStep == 3, isDark),
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
                  'Select your workout split',
                  style: GoogleFonts.plusJakartaSans(
                    color: titleColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose what you are training today to review past weights and start live set tracking.',
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
                          Text('No workout splits configured', style: GoogleFonts.plusJakartaSans(color: titleColor, fontWeight: FontWeight.w800)),
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
                            // Short Name Badge Pill
                            Container(
                              width: 48,
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                                    : (isDark ? const Color(0xFF162344) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                split.effectiveShortName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  color: isSelected
                                      ? (isDark ? Colors.black : Colors.white)
                                      : (isDark ? AppTheme.tealLight : AppTheme.tealPrimary),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
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

        // Bottom Navigation Bar
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
                  label: Text(
                    'Continue to Review',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                  ),
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

  // --- Step 2: Review Last Workout ---

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PREVIOUS WORKOUT BENCHMARK',
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
                          'This will be your first session for ${split.name}! Tap Start Workout below to begin logging sets in real time.',
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
                  onPressed: _startActualWorkout,
                  icon: const Icon(Icons.play_arrow_rounded, size: 22),
                  label: Text('Start Workout', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
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

  // --- Step 3: Live Actual Workout Tracking (In-Gym Session) ---

  Widget _buildStep3LiveTracking(
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color titleColor,
    Color subColor,
  ) {
    final split = _selectedSplit;

    // Body parts in this split
    final bodyParts = split?.partNames ?? [];
    if (_selectedBodyPart == null && bodyParts.isNotEmpty) {
      _selectedBodyPart = bodyParts.first;
    }

    // Exercises for the selected body part
    final exercisesInSelectedPart = _selectedBodyPart != null ? (split?.getExercisesForPart(_selectedBodyPart!) ?? []) : <String>[];

    final double totalVolume = _activeExercises.fold(0.0, (sum, e) => sum + e.totalVolume);
    final int completedSets = _activeExercises.fold(0, (sum, e) => sum + e.completedSetsCount);
    final int totalSets = _activeExercises.fold(0, (sum, e) => sum + e.sets.length);

    return Column(
      children: [
        // Live Workout Stats Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF10B981))),
                    const SizedBox(width: 6),
                    Text(
                      'ACTIVE WORKOUT',
                      style: GoogleFonts.plusJakartaSans(color: const Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        split?.name ?? 'Workout',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(color: titleColor, fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (split != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F3635) : AppTheme.tealBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          split.effectiveShortName,
                          style: GoogleFonts.plusJakartaSans(
                            color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (split != null) {
                    LastWorkoutSheet.show(context, split, session: _lastSession);
                  }
                },
                icon: const Icon(Icons.history_rounded, size: 14),
                label: const Text('Last Workout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF162344) : const Color(0xFFF1F5F9),
                  foregroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),

        // Live stats ribbon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('${_activeExercises.length} Exercises', style: GoogleFonts.plusJakartaSans(color: subColor, fontSize: 11.5, fontWeight: FontWeight.w700)),
              Text('•', style: TextStyle(color: subColor)),
              Text('$completedSets / $totalSets Sets Done', style: GoogleFonts.plusJakartaSans(color: completedSets > 0 ? const Color(0xFF10B981) : subColor, fontSize: 11.5, fontWeight: FontWeight.w800)),
              Text('•', style: TextStyle(color: subColor)),
              Text('${totalVolume.toStringAsFixed(0)} kg Lifted', style: GoogleFonts.plusJakartaSans(color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary, fontSize: 11.5, fontWeight: FontWeight.w800)),
            ],
          ),
        ),

        // Body Part Selector & Exercises
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Body Part Tabs
                if (bodyParts.isNotEmpty) ...[
                  Text(
                    'BODY PARTS IN THIS SPLIT',
                    style: GoogleFonts.plusJakartaSans(
                      color: subColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: bodyParts.map((part) {
                        final isPartSelected = part == _selectedBodyPart;
                        final exerciseCountInActive = _activeExercises.where((e) => e.part == part).length;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(part),
                                if (exerciseCountInActive > 0) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: isPartSelected
                                          ? (isDark ? Colors.black : Colors.white)
                                          : (isDark ? const Color(0xFF0F3635) : AppTheme.tealBg),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$exerciseCountInActive',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: isPartSelected
                                            ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                                            : (isDark ? AppTheme.tealLight : AppTheme.tealPrimary),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            selected: isPartSelected,
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  _selectedBodyPart = part;
                                });
                              }
                            },
                            selectedColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                            labelStyle: GoogleFonts.plusJakartaSans(
                              color: isPartSelected
                                  ? (isDark ? Colors.black : Colors.white)
                                  : titleColor,
                              fontSize: 12,
                              fontWeight: isPartSelected ? FontWeight.w800 : FontWeight.w600,
                            ),
                            backgroundColor: cardBg,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Exercises Catalog for the Selected Body Part
                  if (_selectedBodyPart != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'EXERCISES FOR $_selectedBodyPart',
                          style: GoogleFonts.plusJakartaSans(
                            color: subColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _promptAddCustomExercise,
                          icon: const Icon(Icons.add_rounded, size: 15),
                          label: const Text('Add Custom'),
                          style: TextButton.styleFrom(
                            foregroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...exercisesInSelectedPart.map((exName) {
                          final isAdded = _activeExercises.any(
                            (e) => e.name.trim().toLowerCase() == exName.trim().toLowerCase(),
                          );

                          // Previous weight suggestion if available
                          double? prevW;
                          int? prevR;
                          if (_lastSession != null) {
                            for (var ex in _lastSession!.exercises) {
                              if (ex.name.trim().toLowerCase() == exName.trim().toLowerCase() && ex.sets.isNotEmpty) {
                                prevW = ex.sets.last.weight;
                                prevR = ex.sets.last.reps;
                                break;
                              }
                            }
                          }

                          return ActionChip(
                            avatar: Icon(
                              isAdded ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                              size: 16,
                              color: isAdded
                                  ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary)
                                  : subColor,
                            ),
                            label: Text(
                              prevW != null ? '$exName (${prevW.toStringAsFixed(prevW % 1 == 0 ? 0 : 1)}kg×$prevR)' : exName,
                            ),
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
                            onPressed: () => _addExerciseToWorkout(exName, _selectedBodyPart!),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ],

                // Active Exercises Set-Entry Interface
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LOGGED EXERCISES',
                      style: GoogleFonts.plusJakartaSans(
                        color: subColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      '${_activeExercises.length} in session',
                      style: GoogleFonts.plusJakartaSans(color: subColor, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (_activeExercises.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.fitness_center_rounded, size: 40, color: subColor),
                        const SizedBox(height: 12),
                        Text(
                          'No exercises in this workout yet',
                          style: GoogleFonts.plusJakartaSans(color: titleColor, fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select a body part above and tap an exercise to start logging your sets.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(color: subColor, fontSize: 12.5),
                        ),
                      ],
                    ),
                  )
                else
                  ..._activeExercises.asMap().entries.map((entry) {
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
                          // Exercise Title & Part Tag
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

                          // Sets Table Header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Row(
                              children: [
                                SizedBox(width: 32, child: Text('SET', style: GoogleFonts.plusJakartaSans(color: subColor, fontSize: 10, fontWeight: FontWeight.w800))),
                                Expanded(flex: 3, child: Text('WEIGHT (KG)', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(color: subColor, fontSize: 10, fontWeight: FontWeight.w800))),
                                const SizedBox(width: 8),
                                Expanded(flex: 3, child: Text('REPS', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(color: subColor, fontSize: 10, fontWeight: FontWeight.w800))),
                                const SizedBox(width: 8),
                                SizedBox(width: 44, child: Text('DONE', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(color: subColor, fontSize: 10, fontWeight: FontWeight.w800))),
                                const SizedBox(width: 24),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Live Sets List
                          ...ex.sets.asMap().entries.map((setEntry) {
                            final setIndex = setEntry.key;
                            final setItem = setEntry.value;

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: setItem.completed
                                    ? (isDark ? const Color(0xFF0F3635).withValues(alpha: 0.4) : AppTheme.tealBg.withValues(alpha: 0.4))
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  // Set Number
                                  SizedBox(
                                    width: 32,
                                    child: Text(
                                      '${setItem.setNumber}',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: setItem.completed ? (isDark ? AppTheme.tealLight : AppTheme.tealPrimary) : titleColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),

                                  // Weight input with steppers
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF162344) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: borderColor),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                            onTap: () => _adjustWeight(exIndex, setIndex, -2.5),
                                            borderRadius: BorderRadius.circular(6),
                                            child: Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Icon(Icons.remove_rounded, size: 14, color: subColor),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              final ctrl = TextEditingController(text: '${setItem.weight}');
                                              final val = await showDialog<double>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text('Edit Weight (kg)'),
                                                  content: TextField(
                                                    controller: ctrl,
                                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                    autofocus: true,
                                                  ),
                                                  actions: [
                                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                                    ElevatedButton(
                                                      onPressed: () => Navigator.pop(ctx, double.tryParse(ctrl.text)),
                                                      child: const Text('Set'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (val != null) {
                                                setState(() {
                                                  ex.sets[setIndex] = ex.sets[setIndex].copyWith(weight: val);
                                                });
                                                _syncDraft();
                                              }
                                            },
                                            child: Text(
                                              setItem.weight.toStringAsFixed(setItem.weight % 1 == 0 ? 0 : 1),
                                              style: GoogleFonts.plusJakartaSans(
                                                color: titleColor,
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => _adjustWeight(exIndex, setIndex, 2.5),
                                            borderRadius: BorderRadius.circular(6),
                                            child: Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Icon(Icons.add_rounded, size: 14, color: subColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Reps input with steppers
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF162344) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: borderColor),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                            onTap: () => _adjustReps(exIndex, setIndex, -1),
                                            borderRadius: BorderRadius.circular(6),
                                            child: Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Icon(Icons.remove_rounded, size: 14, color: subColor),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              final ctrl = TextEditingController(text: '${setItem.reps}');
                                              final val = await showDialog<int>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text('Edit Reps'),
                                                  content: TextField(
                                                    controller: ctrl,
                                                    keyboardType: TextInputType.number,
                                                    autofocus: true,
                                                  ),
                                                  actions: [
                                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                                    ElevatedButton(
                                                      onPressed: () => Navigator.pop(ctx, int.tryParse(ctrl.text)),
                                                      child: const Text('Set'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (val != null) {
                                                setState(() {
                                                  ex.sets[setIndex] = ex.sets[setIndex].copyWith(reps: val);
                                                });
                                                _syncDraft();
                                              }
                                            },
                                            child: Text(
                                              '${setItem.reps}',
                                              style: GoogleFonts.plusJakartaSans(
                                                color: titleColor,
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => _adjustReps(exIndex, setIndex, 1),
                                            borderRadius: BorderRadius.circular(6),
                                            child: Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Icon(Icons.add_rounded, size: 14, color: subColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Explicit Set Completion Button (Never marked automatically)
                                  SizedBox(
                                    width: 44,
                                    child: Center(
                                      child: InkWell(
                                        onTap: () => _toggleSetCompletion(exIndex, setIndex),
                                        borderRadius: BorderRadius.circular(10),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 150),
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: setItem.completed
                                                ? const Color(0xFF10B981)
                                                : (isDark ? const Color(0xFF162344) : const Color(0xFFF1F5F9)),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: setItem.completed
                                                  ? const Color(0xFF059669)
                                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Icon(
                                            setItem.completed ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                                            size: 18,
                                            color: setItem.completed ? Colors.white : subColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Delete Set Button
                                  SizedBox(
                                    width: 24,
                                    child: ex.sets.length > 1
                                        ? IconButton(
                                            icon: const Icon(Icons.close_rounded, size: 14),
                                            color: subColor,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () => _removeSetFromExercise(exIndex, setIndex),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => _addSetToExercise(exIndex),
                            icon: const Icon(Icons.add_rounded, size: 15),
                            label: const Text('Add Set'),
                            style: TextButton.styleFrom(
                              foregroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

        // Bottom Finish Workout Action Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(top: BorderSide(color: borderColor)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: () async {
                  final discard = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Discard Active Workout?'),
                      content: const Text('This will reset today\'s workout session. All logged sets in this session will be removed.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep Training')),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
                          child: const Text('Discard'),
                        ),
                      ],
                    ),
                  );
                  if (discard == true) {
                    if (!mounted) return;
                    final wp = Provider.of<WorkoutProvider>(context, listen: false);
                    await wp.discardActiveWorkout();
                    if (mounted) Navigator.pop(context);
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFF87171)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Icon(Icons.delete_sweep_rounded, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _confirmAndFinishWorkout,
                  icon: _isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle_rounded, size: 20),
                  label: Text(
                    _isSaving ? 'Saving Workout...' : 'Finish Workout ($completedSets/$totalSets)',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
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
