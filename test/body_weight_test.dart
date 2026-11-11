import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/models/body_weight_entry.dart';

void main() {
  group('BodyWeightEntry tests', () {
    test('serialization toMap and fromMap works as expected', () {
      final now = DateTime(2026, 11, 9, 8, 30);
      final entry = BodyWeightEntry(
        id: 'bw-1',
        weightKg: 74.5,
        date: now,
        note: 'Morning fasted',
      );

      final map = entry.toMap();
      expect(map['id'], 'bw-1');
      expect(map['weightKg'], 74.5);
      expect(map['date'], now.toIso8601String());
      expect(map['note'], 'Morning fasted');

      final fromMap = BodyWeightEntry.fromMap(map);
      expect(fromMap.id, 'bw-1');
      expect(fromMap.weightKg, 74.5);
      expect(fromMap.date, now);
      expect(fromMap.note, 'Morning fasted');
    });

    test('copyWith updates fields properly', () {
      final entry = BodyWeightEntry(
        id: 'bw-1',
        weightKg: 74.5,
        date: DateTime(2026, 11, 9),
      );

      final updated = entry.copyWith(weightKg: 75.0, note: 'Post dinner');
      expect(updated.id, 'bw-1');
      expect(updated.weightKg, 75.0);
      expect(updated.note, 'Post dinner');
    });
  });
}
