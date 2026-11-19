import 'exercise.dart';
import 'workout_session.dart';

/// Progress and comparison metrics for an individual exercise between sessions.
class ExerciseProgressComparison {
  final String exerciseName;
  final bool hasPreviousData;
  final double? previousMaxWeight;
  final double currentMaxWeight;
  final int? previousMaxReps;
  final int currentMaxReps;
  final int? previousTotalSets;
  final int currentTotalSets;
  final double? weightDiff;
  final int? repsDiff;
  final int? setsDiff;
  final bool isPersonalBest;
  final String? previousDate;

  ExerciseProgressComparison({
    required this.exerciseName,
    required this.hasPreviousData,
    this.previousMaxWeight,
    required this.currentMaxWeight,
    this.previousMaxReps,
    required this.currentMaxReps,
    this.previousTotalSets,
    required this.currentTotalSets,
    this.weightDiff,
    this.repsDiff,
    this.setsDiff,
    this.isPersonalBest = false,
    this.previousDate,
  });

  /// Factory to compute comparison between an exercise and an optional previous instance
  /// plus historical sessions to determine all-time personal best.
  factory ExerciseProgressComparison.compute({
    required Exercise currentExercise,
    Exercise? previousExercise,
    String? previousDate,
    List<WorkoutSession> allHistoricalSessions = const [],
  }) {
    final curSets = currentExercise.sets;
    final curMaxWeight = curSets.fold(0.0, (max, s) => s.weight > max ? s.weight : max);
    final curMaxReps = curSets.fold(0, (max, s) => s.reps > max ? s.reps : max);
    final curTotalSets = curSets.length;

    if (previousExercise == null || previousExercise.sets.isEmpty) {
      // Check if current max weight is a new PR anyway across historical data
      bool isPR = false;
      if (curMaxWeight > 0 && allHistoricalSessions.isNotEmpty) {
        double allTimeMax = 0.0;
        for (var s in allHistoricalSessions) {
          for (var e in s.exercises) {
            if (e.name.trim().toLowerCase() == currentExercise.name.trim().toLowerCase()) {
              for (var st in e.sets) {
                if (st.weight > allTimeMax) allTimeMax = st.weight;
              }
            }
          }
        }
        if (curMaxWeight >= allTimeMax && curMaxWeight > 0) {
          isPR = true;
        }
      }

      return ExerciseProgressComparison(
        exerciseName: currentExercise.name,
        hasPreviousData: false,
        currentMaxWeight: curMaxWeight,
        currentMaxReps: curMaxReps,
        currentTotalSets: curTotalSets,
        isPersonalBest: isPR,
      );
    }

    final prevSets = previousExercise.sets;
    final prevMaxWeight = prevSets.fold(0.0, (max, s) => s.weight > max ? s.weight : max);
    final prevMaxReps = prevSets.fold(0, (max, s) => s.reps > max ? s.reps : max);
    final prevTotalSets = prevSets.length;

    final wDiff = curMaxWeight - prevMaxWeight;
    final rDiff = curMaxReps - prevMaxReps;
    final sDiff = curTotalSets - prevTotalSets;

    // Check all-time personal best
    double allTimeMax = prevMaxWeight;
    for (var s in allHistoricalSessions) {
      for (var e in s.exercises) {
        if (e.name.trim().toLowerCase() == currentExercise.name.trim().toLowerCase()) {
          for (var st in e.sets) {
            if (st.weight > allTimeMax) allTimeMax = st.weight;
          }
        }
      }
    }
    final isPR = curMaxWeight > allTimeMax;

    return ExerciseProgressComparison(
      exerciseName: currentExercise.name,
      hasPreviousData: true,
      previousMaxWeight: prevMaxWeight,
      currentMaxWeight: curMaxWeight,
      previousMaxReps: prevMaxReps,
      currentMaxReps: curMaxReps,
      previousTotalSets: prevTotalSets,
      currentTotalSets: curTotalSets,
      weightDiff: wDiff,
      repsDiff: rDiff,
      setsDiff: sDiff,
      isPersonalBest: isPR,
      previousDate: previousDate,
    );
  }
}

/// Full workout session progress comparison against its preceding session.
class SessionProgressComparison {
  final WorkoutSession currentSession;
  final WorkoutSession? previousSession;
  final List<ExerciseProgressComparison> comparisons;
  final double? volumeDiff;
  final int? setsDiff;
  final int personalBestsCount;

  SessionProgressComparison({
    required this.currentSession,
    this.previousSession,
    required this.comparisons,
    this.volumeDiff,
    this.setsDiff,
    required this.personalBestsCount,
  });

  factory SessionProgressComparison.compute({
    required WorkoutSession current,
    WorkoutSession? previous,
    List<WorkoutSession> allHistoricalSessions = const [],
  }) {
    final comparisons = <ExerciseProgressComparison>[];
    int prCount = 0;

    for (var curEx in current.exercises) {
      Exercise? matchedPrevEx;
      if (previous != null) {
        for (var pEx in previous.exercises) {
          if (pEx.name.trim().toLowerCase() == curEx.name.trim().toLowerCase()) {
            matchedPrevEx = pEx;
            break;
          }
        }
      }

      final comp = ExerciseProgressComparison.compute(
        currentExercise: curEx,
        previousExercise: matchedPrevEx,
        previousDate: previous?.date,
        allHistoricalSessions: allHistoricalSessions,
      );
      if (comp.isPersonalBest) prCount++;
      comparisons.add(comp);
    }

    final double? volDiff = previous != null ? current.totalVolume - previous.totalVolume : null;
    final int? sDiff = previous != null ? current.completedSets - previous.completedSets : null;

    return SessionProgressComparison(
      currentSession: current,
      previousSession: previous,
      comparisons: comparisons,
      volumeDiff: volDiff,
      setsDiff: sDiff,
      personalBestsCount: prCount,
    );
  }
}
