import 'exercise.dart';

class WorkoutSession {
  final String date; // YYYY-MM-DD
  List<Exercise> exercises;
  String? splitId;
  String? splitName;

  WorkoutSession({
    required this.date,
    required this.exercises,
    this.splitId,
    this.splitName,
  });

  double get totalVolume {
    return exercises.fold(0.0, (sum, ex) => sum + ex.totalVolume);
  }

  int get totalSets {
    return exercises.fold(0, (sum, ex) => sum + ex.sets.length);
  }

  int get completedSets {
    return exercises.fold(0, (sum, ex) => sum + ex.completedSetsCount);
  }

  /// Checks if this session corresponds to a given split ID or split name,
  /// with fallbacks for legacy sessions that stored group/part in exercises.
  bool matchesSplit(String targetSplitId, {String? targetSplitName}) {
    if (splitId != null && splitId == targetSplitId) return true;
    if (splitName != null &&
        targetSplitName != null &&
        splitName!.trim().toLowerCase() == targetSplitName.trim().toLowerCase()) {
      return true;
    }
    if (targetSplitName != null) {
      final tNorm = targetSplitName.trim().toLowerCase();
      return exercises.any((e) =>
          e.group.trim().toLowerCase() == tNorm ||
          e.part.trim().toLowerCase() == tNorm);
    }
    return false;
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      if (splitId != null) 'splitId': splitId,
      if (splitName != null) 'splitName': splitName,
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    var rawExercises = map['exercises'] as List<dynamic>? ?? [];
    return WorkoutSession(
      date: map['date'] as String? ?? '',
      splitId: map['splitId'] as String?,
      splitName: map['splitName'] as String?,
      exercises: rawExercises
          .map((e) => Exercise.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  WorkoutSession copyWith({
    String? date,
    List<Exercise>? exercises,
    String? splitId,
    String? splitName,
  }) {
    return WorkoutSession(
      date: date ?? this.date,
      exercises: exercises ?? this.exercises.map((e) => e.copyWith()).toList(),
      splitId: splitId ?? this.splitId,
      splitName: splitName ?? this.splitName,
    );
  }
}
