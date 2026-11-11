import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/exercise.dart';
import '../models/split_group.dart';
import '../models/workout_session.dart';
import '../models/workout_set.dart';
import '../models/body_weight_entry.dart';
import '../services/database_service.dart';
import '../services/streak_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  DatabaseService? _db;
  String _userId = '';

  DateTime _currentDate = StreakService.nowIST;
  List<SplitGroup> _splitGroups = [];
  Map<String, WorkoutSession> _sessions = {};
  List<BodyWeightEntry> _weightLogs = [];
  bool _isLoading = true;

  DateTime get currentDate => _currentDate;
  String get currentDateKey => DateFormat('yyyy-MM-dd').format(_currentDate);
  List<SplitGroup> get splitGroups => _splitGroups;
  Map<String, WorkoutSession> get sessions => _sessions;
  List<BodyWeightEntry> get weightLogs => _weightLogs;
  bool get isLoading => _isLoading;

  int get currentStreak => StreakService.calculateCurrentStreak(_sessions);
  int get bestStreak => StreakService.calculateBestStreak(_sessions);

  WorkoutSession get currentSession {
    return _sessions[currentDateKey] ??
        WorkoutSession(date: currentDateKey, exercises: []);
  }

  void updateUserId(String uid) {
    if (_userId != uid) {
      _userId = uid;
      _db = DatabaseService(userId: uid);
      loadData();
    }
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    if (_db != null) {
      _splitGroups = await _db!.getSplitGroups();
      _sessions = await _db!.getAllSessions();
      _weightLogs = await _db!.getWeightLogs();
    } else {
      _splitGroups = SplitGroup.defaultGroups;
      _sessions = {};
      _weightLogs = [];
    }

    if (!_sessions.containsKey(currentDateKey)) {
      _sessions[currentDateKey] = WorkoutSession(date: currentDateKey, exercises: []);
    }

    _isLoading = false;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _currentDate = date;
    if (!_sessions.containsKey(currentDateKey)) {
      _sessions[currentDateKey] = WorkoutSession(date: currentDateKey, exercises: []);
    }
    notifyListeners();
  }

  // ----------------------------------------------------
  // EXERCISES & SETS
  // ----------------------------------------------------

  Future<void> addExercise({
    required String name,
    required String group,
    required String part,
    required String equipment,
    required double initialWeight,
    required int initialReps,
  }) async {
    final session = currentSession;
    final newExercise = Exercise(
      id: 'ex-${DateTime.now().millisecondsSinceEpoch}-${_uuid.v4().substring(0, 4)}',
      name: name,
      group: group,
      part: part,
      equipment: equipment,
      sets: [
        WorkoutSet(
          setNumber: 1,
          weight: initialWeight,
          reps: initialReps,
          completed: true,
        ),
      ],
    );

    final updatedExercises = List<Exercise>.from(session.exercises)..add(newExercise);
    final updatedSession = session.copyWith(exercises: updatedExercises);
    _sessions[currentDateKey] = updatedSession;
    notifyListeners();

    if (_db != null) {
      await _db!.saveSession(updatedSession);
    }
  }

  Future<void> deleteExercise(String exerciseId) async {
    final session = currentSession;
    final updatedExercises = session.exercises.where((e) => e.id != exerciseId).toList();
    final updatedSession = session.copyWith(exercises: updatedExercises);
    _sessions[currentDateKey] = updatedSession;
    notifyListeners();

    if (_db != null) {
      await _db!.saveSession(updatedSession);
    }
  }

  Future<void> addSet(String exerciseId) async {
    final session = currentSession;
    final exIndex = session.exercises.indexWhere((e) => e.id == exerciseId);
    if (exIndex == -1) return;

    final ex = session.exercises[exIndex];
    final lastSet = ex.sets.isNotEmpty ? ex.sets.last : null;
    final newWeight = lastSet?.weight ?? 20.0;
    final newReps = lastSet?.reps ?? 10;

    final newSet = WorkoutSet(
      setNumber: ex.sets.length + 1,
      weight: newWeight,
      reps: newReps,
      completed: false,
    );

    final updatedSets = List<WorkoutSet>.from(ex.sets)..add(newSet);
    final updatedEx = ex.copyWith(sets: updatedSets);

    final updatedExercises = List<Exercise>.from(session.exercises);
    updatedExercises[exIndex] = updatedEx;

    final updatedSession = session.copyWith(exercises: updatedExercises);
    _sessions[currentDateKey] = updatedSession;
    notifyListeners();

    if (_db != null) {
      await _db!.saveSession(updatedSession);
    }
  }

  Future<void> updateSet(
    String exerciseId,
    int setIndex, {
    double? weight,
    int? reps,
  }) async {
    final session = currentSession;
    final exIndex = session.exercises.indexWhere((e) => e.id == exerciseId);
    if (exIndex == -1) return;

    final ex = session.exercises[exIndex];
    if (setIndex < 0 || setIndex >= ex.sets.length) return;

    final targetSet = ex.sets[setIndex];
    final updatedSet = targetSet.copyWith(
      weight: weight ?? targetSet.weight,
      reps: reps ?? targetSet.reps,
    );

    final updatedSets = List<WorkoutSet>.from(ex.sets);
    updatedSets[setIndex] = updatedSet;
    final updatedEx = ex.copyWith(sets: updatedSets);

    final updatedExercises = List<Exercise>.from(session.exercises);
    updatedExercises[exIndex] = updatedEx;

    final updatedSession = session.copyWith(exercises: updatedExercises);
    _sessions[currentDateKey] = updatedSession;
    notifyListeners();

    if (_db != null) {
      await _db!.saveSession(updatedSession);
    }
  }

  Future<void> toggleSetCompleted(String exerciseId, int setIndex) async {
    final session = currentSession;
    final exIndex = session.exercises.indexWhere((e) => e.id == exerciseId);
    if (exIndex == -1) return;

    final ex = session.exercises[exIndex];
    if (setIndex < 0 || setIndex >= ex.sets.length) return;

    final targetSet = ex.sets[setIndex];
    final updatedSet = targetSet.copyWith(completed: !targetSet.completed);

    final updatedSets = List<WorkoutSet>.from(ex.sets);
    updatedSets[setIndex] = updatedSet;
    final updatedEx = ex.copyWith(sets: updatedSets);

    final updatedExercises = List<Exercise>.from(session.exercises);
    updatedExercises[exIndex] = updatedEx;

    final updatedSession = session.copyWith(exercises: updatedExercises);
    _sessions[currentDateKey] = updatedSession;
    notifyListeners();

    if (_db != null) {
      await _db!.saveSession(updatedSession);
    }
  }

  Future<void> deleteSet(String exerciseId, int setIndex) async {
    final session = currentSession;
    final exIndex = session.exercises.indexWhere((e) => e.id == exerciseId);
    if (exIndex == -1) return;

    final ex = session.exercises[exIndex];
    if (ex.sets.length <= 1) return;

    final updatedSets = List<WorkoutSet>.from(ex.sets)..removeAt(setIndex);
    for (int i = 0; i < updatedSets.length; i++) {
      updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
    }
    final updatedEx = ex.copyWith(sets: updatedSets);

    final updatedExercises = List<Exercise>.from(session.exercises);
    updatedExercises[exIndex] = updatedEx;

    final updatedSession = session.copyWith(exercises: updatedExercises);
    _sessions[currentDateKey] = updatedSession;
    notifyListeners();

    if (_db != null) {
      await _db!.saveSession(updatedSession);
    }
  }

  // ----------------------------------------------------
  // SPLITS, BODY PARTS & EXERCISES HIERARCHY
  // ----------------------------------------------------

  Future<void> addSplitGroup({
    required String name,
    required String desc,
    Map<String, List<String>>? parts,
  }) async {
    final newGroup = SplitGroup(
      id: 'grp-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      desc: desc,
      parts: parts ?? {},
    );

    _splitGroups.add(newGroup);
    notifyListeners();

    if (_db != null) {
      await _db!.saveSplitGroup(newGroup);
    }
  }

  Future<void> deleteSplitGroup(String groupId) async {
    _splitGroups.removeWhere((g) => g.id == groupId);
    notifyListeners();

    if (_db != null) {
      await _db!.deleteSplitGroup(groupId);
    }
  }

  Future<void> clearAllSplitGroups() async {
    _splitGroups.clear();
    notifyListeners();

    if (_db != null) {
      await _db!.clearAllSplitGroups();
    }
  }

  Future<void> addPartToGroup(String groupId, String partName) async {
    final idx = _splitGroups.indexWhere((g) => g.id == groupId);
    if (idx == -1) return;

    final grp = _splitGroups[idx];
    if (grp.parts.containsKey(partName)) return;

    final updatedParts = Map<String, List<String>>.from(grp.parts);
    updatedParts[partName] = [];
    final updatedGrp = grp.copyWith(parts: updatedParts);
    _splitGroups[idx] = updatedGrp;
    notifyListeners();

    if (_db != null) {
      await _db!.saveSplitGroup(updatedGrp);
    }
  }

  Future<void> removePartFromGroup(String groupId, String partName) async {
    final idx = _splitGroups.indexWhere((g) => g.id == groupId);
    if (idx == -1) return;

    final grp = _splitGroups[idx];
    final updatedParts = Map<String, List<String>>.from(grp.parts)..remove(partName);
    final updatedGrp = grp.copyWith(parts: updatedParts);
    _splitGroups[idx] = updatedGrp;
    notifyListeners();

    if (_db != null) {
      await _db!.saveSplitGroup(updatedGrp);
    }
  }

  Future<void> addExerciseToPart(String groupId, String partName, String exerciseName) async {
    final idx = _splitGroups.indexWhere((g) => g.id == groupId);
    if (idx == -1) return;

    final grp = _splitGroups[idx];
    final existingList = grp.parts[partName] ?? [];
    if (existingList.any((e) => e.toLowerCase() == exerciseName.toLowerCase())) return;

    final updatedParts = Map<String, List<String>>.from(grp.parts);
    updatedParts[partName] = List<String>.from(existingList)..add(exerciseName);
    final updatedGrp = grp.copyWith(parts: updatedParts);
    _splitGroups[idx] = updatedGrp;
    notifyListeners();

    if (_db != null) {
      await _db!.saveSplitGroup(updatedGrp);
    }
  }

  Future<void> removeExerciseFromPart(String groupId, String partName, String exerciseName) async {
    final idx = _splitGroups.indexWhere((g) => g.id == groupId);
    if (idx == -1) return;

    final grp = _splitGroups[idx];
    final existingList = grp.parts[partName] ?? [];
    final updatedParts = Map<String, List<String>>.from(grp.parts);
    updatedParts[partName] = List<String>.from(existingList)..remove(exerciseName);
    final updatedGrp = grp.copyWith(parts: updatedParts);
    _splitGroups[idx] = updatedGrp;
    notifyListeners();

    if (_db != null) {
      await _db!.saveSplitGroup(updatedGrp);
    }
  }

  // ----------------------------------------------------
  // STREAK MILESTONES (10, 20, 30 days...)
  // ----------------------------------------------------

  Future<int?> checkAndMarkStreakMilestone() async {
    final streak = currentStreak;
    if (streak > 0 && streak % 10 == 0) {
      final prefs = await SharedPreferences.getInstance();
      final key = 'notified_milestone_${_userId}_$streak';
      final alreadyNotified = prefs.getBool(key) ?? false;
      if (!alreadyNotified) {
        await prefs.setBool(key, true);
        return streak;
      }
    }
    return null;
  }

  // ----------------------------------------------------
  // ANALYTICS & METRICS HELPERS
  // ----------------------------------------------------

  Map<String, int> get muscleSetCountsForCurrentSession {
    final Map<String, int> counts = {};
    for (var ex in currentSession.exercises) {
      counts[ex.part] = (counts[ex.part] ?? 0) + ex.sets.length;
    }
    return counts;
  }

  Map<String, int> get allTimeMuscleSetCounts {
    final Map<String, int> counts = {};
    for (var s in _sessions.values) {
      for (var ex in s.exercises) {
        counts[ex.part] = (counts[ex.part] ?? 0) + ex.sets.length;
      }
    }
    return counts;
  }

  List<MapEntry<String, double>> get recentSevenDaysVolumes {
    final sortedDates = _sessions.keys.toList()..sort();
    final recentDates = sortedDates.length > 7
        ? sortedDates.sublist(sortedDates.length - 7)
        : sortedDates;

    if (recentDates.isEmpty) {
      return [MapEntry(currentDateKey, 0.0)];
    }

    return recentDates.map((d) {
      final s = _sessions[d]!;
      return MapEntry(d, s.totalVolume);
    }).toList();
  }

  // ----------------------------------------------------
  // BODY WEIGHT LOGGING & METRICS (On-demand check-ins)
  // ----------------------------------------------------

  List<BodyWeightEntry> get sortedWeightLogsAsc {
    final list = List<BodyWeightEntry>.from(_weightLogs);
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  List<BodyWeightEntry> get sortedWeightLogsDesc {
    final list = List<BodyWeightEntry>.from(_weightLogs);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  BodyWeightEntry? get latestBodyWeightEntry {
    if (_weightLogs.isEmpty) return null;
    return sortedWeightLogsDesc.first;
  }

  double? get currentWeightKg => latestBodyWeightEntry?.weightKg;

  BodyWeightEntry? get startingBodyWeightEntry {
    if (_weightLogs.isEmpty) return null;
    return sortedWeightLogsAsc.first;
  }

  double? get startingWeightKg => startingBodyWeightEntry?.weightKg;

  double? get totalWeightChangeKg {
    if (_weightLogs.length < 2) return null;
    final latest = latestBodyWeightEntry!.weightKg;
    final starting = startingBodyWeightEntry!.weightKg;
    return latest - starting;
  }

  double? get minBodyWeightKg {
    if (_weightLogs.isEmpty) return null;
    return _weightLogs.map((e) => e.weightKg).reduce((a, b) => a < b ? a : b);
  }

  double? get maxBodyWeightKg {
    if (_weightLogs.isEmpty) return null;
    return _weightLogs.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b);
  }

  Future<void> logBodyWeight({
    required double weightKg,
    DateTime? date,
    String? note,
  }) async {
    final entry = BodyWeightEntry(
      id: 'bw-${DateTime.now().millisecondsSinceEpoch}-${_uuid.v4().substring(0, 4)}',
      weightKg: weightKg,
      date: date ?? DateTime.now(),
      note: note,
    );

    _weightLogs.add(entry);
    _weightLogs.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();

    if (_db != null) {
      await _db!.saveWeightLog(entry);
    }
  }

  Future<void> deleteBodyWeightLog(String id) async {
    _weightLogs.removeWhere((e) => e.id == id);
    notifyListeners();

    if (_db != null) {
      await _db!.deleteWeightLog(id);
    }
  }
}
