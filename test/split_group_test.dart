import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/models/split_group.dart';

void main() {
  group('SplitGroup Model Tests', () {
    test('serialization toMap and fromMap preserves all fields including days and order', () {
      final split = SplitGroup(
        id: 'split-1',
        name: 'Push Pull Legs',
        desc: '3-day split',
        days: const ['Monday', 'Wednesday', 'Friday'],
        defaultSets: 4,
        defaultReps: 10,
        order: 2,
        parts: {
          'Chest': ['Bench Press', 'Incline Dumbbell Press'],
          'Triceps': ['Cable Pushdown'],
        },
      );

      final map = split.toMap();
      expect(map['id'], 'split-1');
      expect(map['name'], 'Push Pull Legs');
      expect(map['desc'], '3-day split');
      expect(map['days'], ['Monday', 'Wednesday', 'Friday']);
      expect(map['defaultSets'], 4);
      expect(map['defaultReps'], 10);
      expect(map['order'], 2);
      expect(map['parts']['Chest'], ['Bench Press', 'Incline Dumbbell Press']);

      final reconstructed = SplitGroup.fromMap(map);
      expect(reconstructed.id, 'split-1');
      expect(reconstructed.name, 'Push Pull Legs');
      expect(reconstructed.desc, '3-day split');
      expect(reconstructed.days, ['Monday', 'Wednesday', 'Friday']);
      expect(reconstructed.defaultSets, 4);
      expect(reconstructed.defaultReps, 10);
      expect(reconstructed.order, 2);
      expect(reconstructed.parts.length, 2);
      expect(reconstructed.getExercisesForPart('Chest'), ['Bench Press', 'Incline Dumbbell Press']);
    });

    test('isScheduledForDay and isScheduledForDateTime check matching weekday correctly', () {
      final split = SplitGroup(
        id: 'split-1',
        name: 'Push Day',
        days: const ['Monday', 'Thursday'],
        parts: const {},
      );

      // 2026-11-16 was a Monday
      final monday = DateTime(2026, 11, 16);
      expect(split.isScheduledForDateTime(monday), isTrue);
      expect(split.isScheduledForDay('Monday'), isTrue);
      expect(split.isScheduledForDay('monday'), isTrue);
      expect(split.isScheduledForDay('Mon'), isTrue);

      // 2026-11-17 was a Tuesday
      final tuesday = DateTime(2026, 11, 17);
      expect(split.isScheduledForDateTime(tuesday), isFalse);
      expect(split.isScheduledForDay('Tuesday'), isFalse);
    });

    test('copyWith produces independent copy with modified fields', () {
      final original = SplitGroup(
        id: 'split-orig',
        name: 'Upper Body',
        days: const ['Monday'],
        order: 0,
        parts: {
          'Back': ['Pull Up'],
        },
      );

      final duplicated = original.copyWith(
        id: 'split-dup',
        name: 'Upper Body (Copy)',
        order: 1,
      );

      expect(duplicated.id, 'split-dup');
      expect(duplicated.name, 'Upper Body (Copy)');
      expect(duplicated.order, 1);
      expect(duplicated.parts['Back'], ['Pull Up']);
      expect(original.id, 'split-orig');
      expect(original.name, 'Upper Body');
      expect(original.order, 0);
    });

    test('shortName serialization and effectiveShortName fallback logic', () {
      final splitWithShort = SplitGroup(
        id: 'split-s1',
        name: 'Push Pull Legs',
        shortName: 'PPL',
        parts: const {},
      );
      expect(splitWithShort.shortName, 'PPL');
      expect(splitWithShort.effectiveShortName, 'PPL');

      final map = splitWithShort.toMap();
      expect(map['shortName'], 'PPL');
      final reconstructed = SplitGroup.fromMap(map);
      expect(reconstructed.shortName, 'PPL');
      expect(reconstructed.effectiveShortName, 'PPL');

      // Without explicit shortName, defaults to standard fitness abbreviations
      final upperBody = SplitGroup(id: 'split-s2', name: 'Upper Body', parts: const {});
      expect(upperBody.effectiveShortName, 'UP');

      // User custom abbreviation takes precedence
      final customUpper = SplitGroup(id: 'split-s2b', name: 'Upper Body', shortName: 'UP', parts: const {});
      expect(customUpper.effectiveShortName, 'UP');

      final lowerBody = SplitGroup(id: 'split-s2c', name: 'Lower Body', parts: const {});
      expect(lowerBody.effectiveShortName, 'LOW');

      final singleWord = SplitGroup(id: 'split-s3', name: 'Legs', parts: const {});
      expect(singleWord.effectiveShortName, 'LEG');

      final longWord = SplitGroup(id: 'split-s4', name: 'Conditioning', parts: const {});
      expect(longWord.effectiveShortName, 'CONDI');
    });
  });
}
