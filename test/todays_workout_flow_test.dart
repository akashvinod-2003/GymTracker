import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/models/exercise.dart';
import 'package:gym_tracker/models/exercise_progress_comparison.dart';
import 'package:gym_tracker/models/split_group.dart';
import 'package:gym_tracker/models/workout_session.dart';
import 'package:gym_tracker/models/workout_set.dart';
import 'package:gym_tracker/providers/workout_provider.dart';

void main() {
  group('WorkoutSession Split Association & Compatibility', () {
    test('serializes and deserializes splitId and splitName properly', () {
      final session = WorkoutSession(
        date: '2026-11-19',
        splitId: 'split-push-1',
        splitName: 'Push Day A',
        exercises: [
          Exercise(
            id: 'ex-1',
            name: 'Bench Press',
            group: 'Push Day A',
            part: 'Chest',
            equipment: 'Barbell',
            sets: [WorkoutSet(setNumber: 1, weight: 80, reps: 8, completed: true)],
          ),
        ],
      );

      final map = session.toMap();
      expect(map['date'], '2026-11-19');
      expect(map['splitId'], 'split-push-1');
      expect(map['splitName'], 'Push Day A');

      final reconstructed = WorkoutSession.fromMap(map);
      expect(reconstructed.date, '2026-11-19');
      expect(reconstructed.splitId, 'split-push-1');
      expect(reconstructed.splitName, 'Push Day A');
      expect(reconstructed.exercises.length, 1);
    });

    test('matchesSplit accurately handles splitId match, splitName match, and legacy exercise groups', () {
      final modernSession = WorkoutSession(
        date: '2026-11-19',
        splitId: 'split-100',
        splitName: 'Pull Heavy',
        exercises: [],
      );

      // Matches exact split ID even if name is renamed
      expect(modernSession.matchesSplit('split-100', targetSplitName: 'Renamed Pull'), isTrue);
      // Fails for unrelated split ID
      expect(modernSession.matchesSplit('split-999', targetSplitName: 'Legs'), isFalse);

      // Legacy session without splitId
      final legacySession = WorkoutSession(
        date: '2026-10-15',
        exercises: [
          Exercise(
            id: 'ex-2',
            name: 'Barbell Row',
            group: 'Pull Day',
            part: 'Back',
            equipment: 'Barbell',
            sets: [WorkoutSet(setNumber: 1, weight: 65, reps: 10, completed: true)],
          ),
        ],
      );

      // Matches by legacy exercise group
      expect(legacySession.matchesSplit('split-random', targetSplitName: 'Pull Day'), isTrue);
      expect(legacySession.matchesSplit('split-random', targetSplitName: 'Leg Day'), isFalse);
    });
  });

  group('Progress Comparison & Metrics Calculation', () {
    test('calculates weight, rep, and set increases accurately against previous session', () {
      final prevExercise = Exercise(
        id: 'ex-prev',
        name: 'Incline Dumbbell Press',
        group: 'Chest',
        part: 'Chest',
        equipment: 'Dumbbell',
        sets: [
          WorkoutSet(setNumber: 1, weight: 26, reps: 8, completed: true),
          WorkoutSet(setNumber: 2, weight: 26, reps: 8, completed: true),
        ],
      );

      final curExercise = Exercise(
        id: 'ex-cur',
        name: 'Incline Dumbbell Press',
        group: 'Chest',
        part: 'Chest',
        equipment: 'Dumbbell',
        sets: [
          WorkoutSet(setNumber: 1, weight: 28, reps: 10, completed: true),
          WorkoutSet(setNumber: 2, weight: 28, reps: 10, completed: true),
          WorkoutSet(setNumber: 3, weight: 28, reps: 8, completed: true),
        ],
      );

      final comparison = ExerciseProgressComparison.compute(
        currentExercise: curExercise,
        previousExercise: prevExercise,
        previousDate: '2026-11-10',
      );

      expect(comparison.hasPreviousData, isTrue);
      expect(comparison.weightDiff, 2.0); // 28 - 26
      expect(comparison.repsDiff, 2); // 10 - 8
      expect(comparison.setsDiff, 1); // 3 - 2
      expect(comparison.previousDate, '2026-11-10');
    });

    test('detects all-time personal best correctly and does not fabricate missing data', () {
      final historicSession = WorkoutSession(
        date: '2026-11-01',
        exercises: [
          Exercise(
            id: 'ex-h1',
            name: 'Deadlift',
            group: 'Pull',
            part: 'Back',
            equipment: 'Barbell',
            sets: [WorkoutSet(setNumber: 1, weight: 140, reps: 5, completed: true)],
          ),
        ],
      );

      final newPR = Exercise(
        id: 'ex-pr',
        name: 'Deadlift',
        group: 'Pull',
        part: 'Back',
        equipment: 'Barbell',
        sets: [WorkoutSet(setNumber: 1, weight: 150, reps: 5, completed: true)],
      );

      final prComparison = ExerciseProgressComparison.compute(
        currentExercise: newPR,
        allHistoricalSessions: [historicSession],
      );

      expect(prComparison.hasPreviousData, isFalse);
      expect(prComparison.isPersonalBest, isTrue);
      expect(prComparison.weightDiff, isNull); // Never fabricated

      final sessionComp = SessionProgressComparison.compute(
        current: WorkoutSession(date: '2026-11-19', exercises: [newPR]),
        allHistoricalSessions: [historicSession],
      );

      expect(sessionComp.personalBestsCount, 1);
      expect(sessionComp.volumeDiff, isNull); // No preceding session provided
    });
  });

  group('WorkoutProvider Split History & Guided Flow State', () {
    test('getLastWorkoutForSplit ignores current date and returns latest completed session for target split', () {
      final wp = WorkoutProvider();

      final pushSplit = SplitGroup(
        id: 'split-push',
        name: 'Push Day',
        parts: {'Chest': ['Bench Press']},
      );

      final oldPush = WorkoutSession(
        date: '2026-11-05',
        splitId: 'split-push',
        splitName: 'Push Day',
        exercises: [
          Exercise(
            id: 'ex-1',
            name: 'Bench Press',
            group: 'Push Day',
            part: 'Chest',
            equipment: 'Barbell',
            sets: [WorkoutSet(setNumber: 1, weight: 70, reps: 10, completed: true)],
          ),
        ],
      );

      final recentPush = WorkoutSession(
        date: '2026-11-12',
        splitId: 'split-push',
        splitName: 'Push Day',
        exercises: [
          Exercise(
            id: 'ex-2',
            name: 'Bench Press',
            group: 'Push Day',
            part: 'Chest',
            equipment: 'Barbell',
            sets: [WorkoutSet(setNumber: 1, weight: 75, reps: 8, completed: true)],
          ),
        ],
      );

      final otherLegs = WorkoutSession(
        date: '2026-11-15',
        splitId: 'split-legs',
        splitName: 'Leg Day',
        exercises: [
          Exercise(
            id: 'ex-3',
            name: 'Squat',
            group: 'Leg Day',
            part: 'Legs',
            equipment: 'Barbell',
            sets: [WorkoutSet(setNumber: 1, weight: 100, reps: 5, completed: true)],
          ),
        ],
      );

      // Populate provider sessions
      wp.sessions['2026-11-05'] = oldPush;
      wp.sessions['2026-11-12'] = recentPush;
      wp.sessions['2026-11-15'] = otherLegs;

      // When looking for push split, returns the most recent one (Nov 12, not Legs Nov 15)
      final lastPush = wp.getLastWorkoutForSplit('split-push', splitName: 'Push Day');
      expect(lastPush, isNotNull);
      expect(lastPush!.date, '2026-11-12');
      expect(lastPush.exercises.first.sets.first.weight, 75);

      // When looking for a split with no history, returns null
      final lastArms = wp.getLastWorkoutForSplit('split-arms', splitName: 'Arms');
      expect(lastArms, isNull);

      wp.dispose();
    });
  });
}
