class BodyWeightEntry {
  final String id;
  final double weightKg;
  final DateTime date;
  final String? note;

  BodyWeightEntry({
    required this.id,
    required this.weightKg,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weightKg': weightKg,
      'date': date.toIso8601String(),
      'note': note ?? '',
    };
  }

  factory BodyWeightEntry.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    try {
      final dateVal = map['date'];
      if (dateVal is String) {
        parsedDate = DateTime.parse(dateVal);
      } else {
        parsedDate = DateTime.now();
      }
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return BodyWeightEntry(
      id: map['id'] as String? ?? '',
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      date: parsedDate,
      note: map['note'] as String?,
    );
  }

  BodyWeightEntry copyWith({
    String? id,
    double? weightKg,
    DateTime? date,
    String? note,
  }) {
    return BodyWeightEntry(
      id: id ?? this.id,
      weightKg: weightKg ?? this.weightKg,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
