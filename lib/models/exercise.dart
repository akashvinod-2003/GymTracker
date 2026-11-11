import 'workout_set.dart';

class Exercise {
  final String id;
  String name;
  String group;
  String part;
  String equipment;
  List<WorkoutSet> sets;

  Exercise({
    required this.id,
    required this.name,
    required this.group,
    required this.part,
    required this.equipment,
    required this.sets,
  });

  double get totalVolume {
    return sets.fold(0.0, (sum, set) => sum + set.volume);
  }

  int get completedSetsCount {
    return sets.where((s) => s.completed).length;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'group': group,
      'part': part,
      'equipment': equipment,
      'sets': sets.map((s) => s.toMap()).toList(),
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    var rawSets = map['sets'] as List<dynamic>? ?? [];
    return Exercise(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Exercise',
      group: map['group'] as String? ?? 'General',
      part: map['part'] as String? ?? 'Chest',
      equipment: map['equipment'] as String? ?? 'Dumbbell',
      sets: rawSets.map((s) => WorkoutSet.fromMap(Map<String, dynamic>.from(s))).toList(),
    );
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? group,
    String? part,
    String? equipment,
    List<WorkoutSet>? sets,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      group: group ?? this.group,
      part: part ?? this.part,
      equipment: equipment ?? this.equipment,
      sets: sets ?? this.sets.map((s) => s.copyWith()).toList(),
    );
  }
}
