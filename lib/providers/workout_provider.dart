import 'dart:async';
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

  StreamSubscription<List<SplitGroup>>? _splitsSub;
  StreamSubscription<WorkoutSession?>? _sessionSub;
  bool _isAnalyticsLoaded = false;
  bool _isLoadingAnalytics = false;

  DateTime get currentDate => _currentDate;
  String get currentDateKey => DateFormat('yyyy-MM-dd').format(_currentDate);
  List<SplitGroup> get splitGroups => _splitGroups;
  Map<String, WorkoutSession> get sessions => _sessions;
  List<BodyWeightEntry> get weightLogs => _weightLogs;
  bool get isLoading => _isLoading;
  bool get isAnalyticsLoaded => _isAnalyticsLoaded;
  bool get isLoadingAnalytics => _isLoadingAnalytics;

  int get currentStreak => StreakService.calculateCurrentStreak(_sessions);
  int get bestStreak => StreakService.calculateBestStreak(_sessions);

  WorkoutSession? _activeWorkoutDraft;
  WorkoutSession? get activeWorkoutDraft => _activeWorkoutDraft;
  bool get hasActiveWorkoutDraft => _activeWorkoutDraft != null && _activeWorkoutDraft!.exercises.isNotEmpty;

  WorkoutSession get currentSession {
    return _sessions[currentDateKey] ??
        WorkoutSession(date: currentDateKey, exercises: []);
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }

  void _cancelSubscriptions() {
    _splitsSub?.cancel();
    _splitsSub = null;
    _sessionSub?.cancel();
    _sessionSub = null;
  }

  void updateUserId(String uid) {
    if (_userId != uid) {
      _userId = uid;
      _db = DatabaseService(userId: uid);
      _cancelSubscriptions();
      _isAnalyticsLoaded = false;
      loadStartupData();
    }
  }

  /// Backwards compatible alias for loadStartupData
  Future<void> loadData() => loadStartupData();

  /// Fast Cache-First Startup Loader:
  /// 1. Reads local cache in < 5ms so UI displays immediately.
  /// 2. Streams and fast-fetches users/{uid}/splits and users/{uid}/sessions/{currentDateKey} asynchronously.
  /// 3. Never fetches full sessions history on startup (deferred to Analytics tab).
  Future<void> loadStartupData() async {
    if (_db != null) {
      // Step 1: Cache-First Instant Local Retrieval
      final cachedSplits = await _db!.loadLocalSplits();
      final cachedSessions = await _db!.loadLocalSessions();

      if (cachedSplits.isNotEmpty || cachedSessions.isNotEmpty) {
        _splitGroups = cachedSplits.isNotEmpty ? cachedSplits : SplitGroup.defaultGroups;
        _sessions = cachedSessions;
        _isLoading = false;
        notifyListeners();
      } else {
        _isLoading = true;
        notifyListeners();
      }
    } else {
      _splitGroups = SplitGroup.defaultGroups;
      _sessions = {};
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (!_sessions.containsKey(currentDateKey)) {
      _sessions[currentDateKey] = WorkoutSession(date: currentDateKey, exercises: []);
    }

    // Step 2: Stream & Fast-Fetch Splits Asynchronously
    _listenToSplits();

    // Step 3: Stream & Fast-Fetch Current Session Asynchronously
    _listenToCurrentSession();

    // Step 4: Restore active workout draft if one was in progress today
    loadActiveWorkoutDraft();

    // Safety timeout: ensure offline cold-start never hangs in loading state
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (_isLoading) {
        _isLoading = false;
        if (_splitGroups.isEmpty) {
          _splitGroups = SplitGroup.defaultGroups;
        }
        notifyListeners();
      }
    });
  }

  void _listenToSplits() {
    if (_db == null) return;
    _splitsSub?.cancel();
    _splitsSub = _db!.streamSplitGroups().listen(
      (groups) {
        if (groups.isNotEmpty) {
          _splitGroups = groups;
          _isLoading = false;
          notifyListeners();
        }
      },
      onError: (e) {
        debugPrint("Splits stream note: $e");
        if (_isLoading) {
          _isLoading = false;
          notifyListeners();
        }
      },
    );

    // Fast one-shot query with 2.5s timeout fallback
    _db!.getSplitGroups().then((groups) {
      if (groups.isNotEmpty) {
        _splitGroups = groups;
        _isLoading = false;
        notifyListeners();
      }
    }).catchError((_) {});
  }

  void _listenToCurrentSession() {
    if (_db == null) return;
    _sessionSub?.cancel();
    final dateKey = currentDateKey;

    _sessionSub = _db!.streamSession(dateKey).listen(
      (session) {
        if (session != null) {
          _sessions[dateKey] = session;
          _isLoading = false;
          notifyListeners();
        }
      },
      onError: (e) {
        debugPrint("Session stream note: $e");
      },
    );

    // Fast one-shot query with 2.5s timeout fallback
    _db!.getSession(dateKey).then((session) {
      if (session != null) {
        _sessions[dateKey] = session;
        _isLoading = false;
        notifyListeners();
      }
    }).catchError((_) {});
  }

  void setDate(DateTime date) {
    _currentDate = date;
    if (!_sessions.containsKey(currentDateKey)) {
      _sessions[currentDateKey] = WorkoutSession(date: currentDateKey, exercises: []);
    }
    _listenToCurrentSession();
    notifyListeners();
  }

  /// Lazy-Loaded: Only invoked when the user opens the Analytics tab.
  /// Fetches full history of sessions and weight logs asynchronously without blocking startup.
  Future<void> loadAnalyticsData() async {
    if (_isAnalyticsLoaded || _isLoadingAnalytics) return;
    _isLoadingAnalytics = true;
    notifyListeners();

    if (_db != null) {
      // Cache-first for body weight logs
      final localWeight = await _db!.loadLocalWeightLogs();
      if (localWeight.isNotEmpty) {
        _weightLogs = localWeight;
        notifyListeners();
      }

      try {
        final results = await Future.wait([
          _db!.getAllSessions(),
          _db!.getWeightLogs(),
        ]);

        final fetchedSessions = results[0] as Map<String, WorkoutSession>;
        final fetchedWeights = results[1] as List<BodyWeightEntry>;

        if (fetchedSessions.isNotEmpty) {
          _sessions.addAll(fetchedSessions);
        }
        if (fetchedWeights.isNotEmpty) {
          _weightLogs = fetchedWeights;
        }
      } catch (e) {
        debugPrint("Analytics data load note: $e");
      }
    }

    _isLoadingAnalytics = false;
    _isAnalyticsLoaded = true;
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
    String? sId = session.splitId;
    String? sName = session.splitName;
    if (sId == null && group != 'Custom' && group != 'General') {
      final matching = _splitGroups.where((g) => g.name.trim().toLowerCase() == group.trim().toLowerCase()).toList();
      if (matching.isNotEmpty) {
        sId = matching.first.id;
        sName = matching.first.name;
      }
    }

    final updatedSession = session.copyWith(
      exercises: updatedExercises,
      splitId: sId,
      splitName: sName,
    );
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

  /// Puts back an exercise removed from the current session (used by Undo).
  Future<void> restoreExercise(Exercise exercise, int index) async {
    final session = currentSession;
    if (session.exercises.any((e) => e.id == exercise.id)) return;
    final updatedExercises = List<Exercise>.from(session.exercises)
      ..insert(index.clamp(0, session.exercises.length), exercise);
    final updatedSession = session.copyWith(exercises: updatedExercises);
    _sessions[currentDateKey] = updatedSession;
    notifyListeners();
    if (_db != null) {
      await _db!.saveSession(updatedSession);
    }
  }

  /// Puts back a set removed from an exercise (used by Undo).
  Future<void> restoreSet(String exerciseId, int setIndex, WorkoutSet set) async {
    final session = currentSession;
    final exIndex = session.exercises.indexWhere((e) => e.id == exerciseId);
    if (exIndex == -1) return;
    final ex = session.exercises[exIndex];
    final updatedSets = List<WorkoutSet>.from(ex.sets)
      ..insert(setIndex.clamp(0, ex.sets.length), set);
    for (int i = 0; i < updatedSets.length; i++) {
      updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
    }
    final updatedExercises = List<Exercise>.from(session.exercises);
    updatedExercises[exIndex] = ex.copyWith(sets: updatedSets);
    final updatedSession = session.copyWith(exercises: updatedExercises);
    _sessions[currentDateKey] = updatedSession;
    notifyListeners();
    if (_db != null) {
      await _db!.saveSession(updatedSession);
    }
  }

  // ----------------------------------------------------
  // DRAFT WORKOUT PERSISTENCE (Requirement 6)
  // ----------------------------------------------------



  // ----------------------------------------------------
  // SPLITS, BODY PARTS & EXERCISES HIERARCHY
  // ----------------------------------------------------

  /// Returns the split assigned to a given weekday from configured splits.
  SplitGroup? getScheduledSplitForDate(DateTime date) {
    for (final group in _splitGroups) {
      if (group.isScheduledForDateTime(date)) {
        return group;
      }
    }
    return null;
  }

  /// Resolves the relevant SplitGroup for a given date:
  /// 1. If completed session has a splitId, matches that split directly.
  /// 2. For scheduled workouts without a completed session, matches split by day-of-week assignment (Mon..Sun).
  /// 3. Fallback: matches split by exercise groups.
  SplitGroup? getSplitForDate(DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final session = _sessions[dateKey];
    final hasCompleted = session != null && session.exercises.any((e) => e.sets.isNotEmpty);

    // Priority 1: Match by session.splitId if completed
    if (hasCompleted && session.splitId != null && session.splitId!.isNotEmpty) {
      final match = _splitGroups.where((g) => g.id == session.splitId);
      if (match.isNotEmpty) return match.first;
    }

    // Priority 2: Check assigned days of week (Mon..Sun) - scheduled split for that weekday
    final scheduled = getScheduledSplitForDate(date);
    if (scheduled != null) {
      return scheduled;
    }

    // Priority 3: Fallback check logged exercise groups for legacy sessions
    if (hasCompleted && session.exercises.isNotEmpty) {
      for (final ex in session.exercises) {
        if (ex.group.isNotEmpty && ex.group != 'General' && ex.group != 'Custom') {
          final match = _splitGroups.where((g) => g.name.toLowerCase() == ex.group.toLowerCase());
          if (match.isNotEmpty) return match.first;
        }
      }
    }

    return null;
  }

  /// Returns the full display split name for a given date (for detailed views / banners).
  /// Requirement 1:
  /// - For completed workouts, display "WorkoutSession.splitName" (preserving historical name).
  /// - For scheduled workouts without a completed session, display split assigned to weekday.
  /// - Does not depend exclusively on exercise group names.
  /// - Renamed splits display current name for scheduled dates.
  String getSplitNameForDate(DateTime date, {WorkoutSession? session}) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final resolvedSession = session ?? _sessions[dateKey];
    final hasCompletedWorkout = resolvedSession != null && resolvedSession.exercises.any((e) => e.sets.isNotEmpty);

    if (hasCompletedWorkout) {
      // 1. Preserved historical splitName on the completed session
      if (resolvedSession.splitName != null && resolvedSession.splitName!.trim().isNotEmpty) {
        return resolvedSession.splitName!.trim();
      }
      // 2. Lookup via splitId
      if (resolvedSession.splitId != null && resolvedSession.splitId!.isNotEmpty) {
        final match = _splitGroups.where((g) => g.id == resolvedSession.splitId);
        if (match.isNotEmpty) return match.first.name;
      }
      // 3. Fallback to exercise groups if legacy
      final groups = resolvedSession.exercises
          .map((e) => e.group)
          .where((g) => g.isNotEmpty && g != 'General' && g != 'Custom')
          .toSet()
          .toList();
      if (groups.isNotEmpty) return groups.join(' & ');

      // 4. Fallback to scheduled split
      final scheduled = getScheduledSplitForDate(date);
      if (scheduled != null) return scheduled.name;

      return 'Completed Workout';
    }

    // Scheduled workouts without a completed session: display split assigned to that weekday
    final scheduled = getScheduledSplitForDate(date);
    if (scheduled != null) {
      return scheduled.name;
    }

    if (date.weekday == DateTime.sunday) {
      return 'Rest & Recovery Day';
    }
    return 'Rest / Off Day';
  }

  /// Returns the compact short abbreviation for calendar day cells / small badges.
  /// Requirement 9: Display short name where compact layout requires it.
  String getSplitShortNameForDate(DateTime date, {WorkoutSession? session}) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final resolvedSession = session ?? _sessions[dateKey];
    final hasCompletedWorkout = resolvedSession != null && resolvedSession.exercises.any((e) => e.sets.isNotEmpty);

    if (hasCompletedWorkout) {
      if (resolvedSession.splitShortName != null && resolvedSession.splitShortName!.trim().isNotEmpty) {
        return resolvedSession.splitShortName!.trim().toUpperCase();
      }
      if (resolvedSession.splitId != null && resolvedSession.splitId!.isNotEmpty) {
        final match = _splitGroups.where((g) => g.id == resolvedSession.splitId);
        if (match.isNotEmpty) return match.first.effectiveShortName;
      }
      if (resolvedSession.splitName != null && resolvedSession.splitName!.trim().isNotEmpty) {
        final name = resolvedSession.splitName!.trim();
        return name.length <= 6 ? name.toUpperCase() : name.substring(0, 4).toUpperCase();
      }
      final groups = resolvedSession.exercises
          .map((e) => e.group)
          .where((g) => g.isNotEmpty && g != 'General' && g != 'Custom')
          .toList();
      if (groups.isNotEmpty) {
        final g = groups.first;
        return g.length <= 5 ? g.toUpperCase() : g.substring(0, 4).toUpperCase();
      }
      return 'WOD';
    }

    final scheduled = getScheduledSplitForDate(date);
    if (scheduled != null) {
      return scheduled.effectiveShortName;
    }

    if (date.weekday == DateTime.sunday) {
      return 'REST';
    }
    return '';
  }

  Future<void> addSplitGroup({
    required String name,
    String? shortName,
    required String desc,
    Map<String, List<String>>? parts,
    List<String>? days,
    int? defaultSets,
    int? defaultReps,
  }) async {
    final newGroup = SplitGroup(
      id: 'grp-${DateTime.now().millisecondsSinceEpoch}-${_uuid.v4().substring(0, 4)}',
      name: name,
      shortName: shortName ?? '',
      desc: desc,
      parts: parts ?? {},
      days: days ?? [],
      defaultSets: defaultSets ?? 3,
      defaultReps: defaultReps ?? 10,
      order: _splitGroups.length,
    );

    _splitGroups.add(newGroup);
    notifyListeners();

    if (_db != null) {
      await _db!.saveSplitGroup(newGroup);
    }
  }

  /// Updates an existing split group in-place with immediate UI reactivity & persistence.
  Future<void> updateSplitGroup(SplitGroup updated) async {
    final idx = _splitGroups.indexWhere((g) => g.id == updated.id);
    if (idx != -1) {
      _splitGroups[idx] = updated;
    } else {
      _splitGroups.add(updated);
    }
    _splitGroups.sort((a, b) => a.order.compareTo(b.order));
    notifyListeners();

    if (_db != null) {
      await _db!.saveSplitGroup(updated);
    }
  }

  /// Inserts a duplicated or new split group directly ABOVE the specified target split.
  Future<void> addSplitAbove({
    required String targetGroupId,
    required SplitGroup newGroup,
  }) async {
    final targetIdx = _splitGroups.indexWhere((g) => g.id == targetGroupId);
    final insertIdx = targetIdx >= 0 ? targetIdx : 0;

    _splitGroups.insert(insertIdx, newGroup);

    // Re-index all orders sequentially
    for (int i = 0; i < _splitGroups.length; i++) {
      _splitGroups[i] = _splitGroups[i].copyWith(order: i);
    }

    notifyListeners();

    if (_db != null) {
      await _db!.saveAllSplitGroups(_splitGroups);
    }
  }

  /// Duplicates an existing workout split including all its days, parts, exercises, sets & reps,
  /// generates a brand-new unique ID, and inserts it directly above the original split.
  Future<SplitGroup?> duplicateSplitAbove(String targetGroupId, {String? customName}) async {
    final targetIdx = _splitGroups.indexWhere((g) => g.id == targetGroupId);
    if (targetIdx == -1) return null;

    final target = _splitGroups[targetIdx];
    final newId = 'grp-${DateTime.now().millisecondsSinceEpoch}-${_uuid.v4().substring(0, 4)}';
    final newName = customName ?? '${target.name} (Copy)';

    // Deep copy parts and exercise lists
    final clonedParts = <String, List<String>>{};
    target.parts.forEach((part, exercises) {
      clonedParts[part] = List<String>.from(exercises);
    });

    final duplicated = SplitGroup(
      id: newId,
      name: newName,
      shortName: target.shortName,
      desc: target.desc,
      parts: clonedParts,
      days: List<String>.from(target.days),
      defaultSets: target.defaultSets,
      defaultReps: target.defaultReps,
      order: targetIdx,
    );

    await addSplitAbove(targetGroupId: targetGroupId, newGroup: duplicated);
    return duplicated;
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

  // ----------------------------------------------------
  // WORKOUT FLOW & SPLIT HISTORY METHODS
  // ----------------------------------------------------

  /// Ensures historical workout sessions are loaded into memory for split history lookups.
  Future<void> ensureHistoryLoaded() async {
    if (_db != null && !_isAnalyticsLoaded) {
      final localSessions = await _db!.loadLocalSessions();
      if (localSessions.isNotEmpty) {
        _sessions.addAll(localSessions);
        notifyListeners();
      }
      try {
        final fetched = await _db!.getAllSessions();
        if (fetched.isNotEmpty) {
          _sessions.addAll(fetched);
          _isAnalyticsLoaded = true;
          notifyListeners();
        }
      } catch (e) {
        debugPrint("ensureHistoryLoaded note: $e");
      }
    }
  }

  /// Sets or updates the split association for a workout session.
  Future<void> setSessionSplit(String splitId, String splitName, {String? dateKey}) async {
    final key = dateKey ?? currentDateKey;
    final session = _sessions[key] ?? WorkoutSession(date: key, exercises: []);
    final updated = session.copyWith(splitId: splitId, splitName: splitName);
    _sessions[key] = updated;
    notifyListeners();

    // Only persist if the session contains exercises, avoiding saving empty sessions prematurely
    if (_db != null && updated.exercises.isNotEmpty) {
      await _db!.saveSession(updated);
    }
  }

  /// Retrieves the most recent completed workout session associated with a specific split.
  WorkoutSession? getLastWorkoutForSplit(String splitId, {String? splitName, String? excludeDate}) {
    final exclude = excludeDate ?? currentDateKey;
    final matching = _sessions.values.where((s) {
      if (s.date == exclude) return false;
      if (!s.exercises.any((e) => e.sets.isNotEmpty)) return false;
      return s.matchesSplit(splitId, targetSplitName: splitName);
    }).toList();

    if (matching.isEmpty) return null;
    matching.sort((a, b) => b.date.compareTo(a.date)); // descending: latest first
    return matching.first;
  }

  /// Retrieves the session immediately preceding the given session for the same split.
  WorkoutSession? getPreviousWorkoutBeforeSession(WorkoutSession currentSession, {String? splitId, String? splitName}) {
    final sId = splitId ?? currentSession.splitId ?? '';
    final sName = splitName ?? currentSession.splitName;
    final matching = _sessions.values.where((s) {
      if (s.date.compareTo(currentSession.date) >= 0) return false;
      if (!s.exercises.any((e) => e.sets.isNotEmpty)) return false;
      return s.matchesSplit(sId, targetSplitName: sName);
    }).toList();

    if (matching.isEmpty) return null;
    matching.sort((a, b) => b.date.compareTo(a.date));
    return matching.first;
  }

  bool _isFinishingWorkout = false;
  bool get isFinishingWorkout => _isFinishingWorkout;

  Future<void> loadActiveWorkoutDraft() async {
    if (_db != null) {
      final draft = await _db!.loadActiveWorkoutDraft();
      if (draft != null) {
        _activeWorkoutDraft = draft;
        notifyListeners();
      }
    }
  }

  void startActiveWorkout(SplitGroup split, {String? dateKey}) {
    final key = dateKey ?? currentDateKey;
    _activeWorkoutDraft = WorkoutSession(
      date: key,
      splitId: split.id,
      splitName: split.name,
      splitShortName: split.effectiveShortName,
      exercises: [],
    );
    notifyListeners();
    if (_db != null) {
      _db!.saveActiveWorkoutDraft(_activeWorkoutDraft!);
    }
  }

  void updateActiveWorkoutExercises(List<Exercise> exercises) {
    if (_activeWorkoutDraft != null) {
      _activeWorkoutDraft = _activeWorkoutDraft!.copyWith(exercises: exercises);
      notifyListeners();
      if (_db != null) {
        _db!.saveActiveWorkoutDraft(_activeWorkoutDraft!);
      }
    }
  }

  Future<void> saveActiveWorkoutDraft(WorkoutSession session) async {
    _activeWorkoutDraft = session;
    notifyListeners();
    if (_db != null) {
      await _db!.saveActiveWorkoutDraft(session);
    }
  }

  Future<void> clearActiveWorkoutDraft() async {
    _activeWorkoutDraft = null;
    notifyListeners();
    if (_db != null) {
      await _db!.clearActiveWorkoutDraft();
    }
  }

  Future<void> discardActiveWorkout() async {
    await clearActiveWorkoutDraft();
  }

  /// Atomically updates today's session exercises and split info, and saves to database.
  Future<bool> saveWorkoutSession(WorkoutSession session) async {
    if (_isFinishingWorkout) return false;
    _isFinishingWorkout = true;
    notifyListeners();

    try {
      _sessions[session.date] = session;
      _activeWorkoutDraft = null;
      notifyListeners();

      if (_db != null) {
        await Future.wait([
          _db!.saveSession(session),
          _db!.clearActiveWorkoutDraft(),
        ]);
      }
      return true;
    } catch (e) {
      debugPrint("Error saving workout session: $e");
      return false;
    } finally {
      _isFinishingWorkout = false;
      notifyListeners();
    }
  }
}
