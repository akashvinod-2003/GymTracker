import 'exercise.dart';

class WorkoutSession {
  final String date; // YYYY-MM-DD
  List<Exercise> exercises;

  WorkoutSession({
    required this.date,
    required this.exercises,
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

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    var rawExercises = map['exercises'] as List<dynamic>? ?? [];
    return WorkoutSession(
      date: map['date'] as String? ?? '',
      exercises: rawExercises
          .map((e) => Exercise.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  WorkoutSession copyWith({
    String? date,
    List<Exercise>? exercises,
  }) {
    return WorkoutSession(
      date: date ?? this.date,
      exercises: exercises ?? this.exercises.map((e) => e.copyWith()).toList(),
    );
  }
}
