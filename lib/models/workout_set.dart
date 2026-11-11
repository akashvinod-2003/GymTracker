class WorkoutSet {
  int setNumber;
  double weight;
  int reps;
  bool completed;

  WorkoutSet({
    required this.setNumber,
    required this.weight,
    required this.reps,
    this.completed = false,
  });

  double get volume => weight * reps;

  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
      'completed': completed,
    };
  }

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      setNumber: (map['setNumber'] as num?)?.toInt() ?? 1,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      reps: (map['reps'] as num?)?.toInt() ?? 0,
      completed: map['completed'] as bool? ?? false,
    );
  }

  WorkoutSet copyWith({
    int? setNumber,
    double? weight,
    int? reps,
    bool? completed,
  }) {
    return WorkoutSet(
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      completed: completed ?? this.completed,
    );
  }
}
