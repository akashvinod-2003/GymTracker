class SplitGroup {
  final String id;
  String name;
  String desc;
  // Map of Body Part Name -> List of Exercise Names in that part
  Map<String, List<String>> parts;
  // Assigned days of the week for this workout split: 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  List<String> days;
  int defaultSets;
  int defaultReps;
  int order;

  SplitGroup({
    required this.id,
    required this.name,
    this.desc = '',
    required this.parts,
    this.days = const [],
    this.defaultSets = 3,
    this.defaultReps = 10,
    this.order = 0,
  });

  List<String> get partNames => parts.keys.toList();

  List<String> getExercisesForPart(String part) => parts[part] ?? [];

  /// Checks if this split is scheduled for a given day name (e.g. 'Mon', 'Monday')
  bool isScheduledForDay(String dayName) {
    if (days.isEmpty) return false;
    final normalized = dayName.trim().toLowerCase();
    return days.any((d) {
      final dNorm = d.trim().toLowerCase();
      return dNorm == normalized ||
          (dNorm.length >= 3 && normalized.startsWith(dNorm.substring(0, 3))) ||
          (normalized.length >= 3 && dNorm.startsWith(normalized.substring(0, 3)));
    });
  }

  /// Checks if this split is scheduled for a given DateTime (using 1=Mon .. 7=Sun)
  bool isScheduledForDateTime(DateTime date) {
    const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (date.weekday >= 1 && date.weekday <= 7) {
      return isScheduledForDay(weekdayNames[date.weekday - 1]);
    }
    return false;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'parts': parts.map((key, list) => MapEntry(key, list)),
      'days': days,
      'defaultSets': defaultSets,
      'defaultReps': defaultReps,
      'order': order,
    };
  }

  factory SplitGroup.fromMap(Map<String, dynamic> map) {
    final rawParts = map['parts'];
    Map<String, List<String>> parsedParts = {};

    if (rawParts is Map) {
      rawParts.forEach((key, val) {
        if (val is List) {
          parsedParts[key.toString()] = val.map((e) => e.toString()).toList();
        } else {
          parsedParts[key.toString()] = [];
        }
      });
    } else if (rawParts is List) {
      // Legacy format fallback: list of part names
      for (var p in rawParts) {
        parsedParts[p.toString()] = [];
      }
    }

    final rawDays = map['days'];
    List<String> parsedDays = [];
    if (rawDays is List) {
      parsedDays = rawDays.map((e) => e.toString()).toList();
    }

    return SplitGroup(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      desc: map['desc'] as String? ?? '',
      parts: parsedParts,
      days: parsedDays,
      defaultSets: (map['defaultSets'] as num?)?.toInt() ?? 3,
      defaultReps: (map['defaultReps'] as num?)?.toInt() ?? 10,
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  SplitGroup copyWith({
    String? id,
    String? name,
    String? desc,
    Map<String, List<String>>? parts,
    List<String>? days,
    int? defaultSets,
    int? defaultReps,
    int? order,
  }) {
    return SplitGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      parts: parts ?? Map<String, List<String>>.from(this.parts),
      days: days ?? List<String>.from(this.days),
      defaultSets: defaultSets ?? this.defaultSets,
      defaultReps: defaultReps ?? this.defaultReps,
      order: order ?? this.order,
    );
  }

  static List<SplitGroup> get defaultGroups => const [];
}
