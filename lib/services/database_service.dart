import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/split_group.dart';
import '../models/workout_session.dart';
import '../models/exercise.dart';
import '../models/workout_set.dart';
import '../models/body_weight_entry.dart';
import 'streak_service.dart';

class DatabaseService {
  final String userId;
  FirebaseFirestore? _firestore;
  bool _isFirestoreAvailable = false;

  DatabaseService({required this.userId}) {
    try {
      _firestore = FirebaseFirestore.instance;
      _isFirestoreAvailable = true;
    } catch (e) {
      debugPrint("Firestore not initialized, fallback to local storage: $e");
      _isFirestoreAvailable = false;
    }
  }

  String get _localSplitsKey => 'splits_data_$userId';
  String get _localSessionsKey => 'sessions_data_$userId';
  String get _baselineMonthKey => 'baseline_month_$userId';
  String get _localWeightLogsKey => 'weight_logs_$userId';

  // Public Local Storage Fast-Path Helpers
  Future<List<SplitGroup>> loadLocalSplits() => _loadSplitsLocally();
  Future<void> saveLocalSplits(List<SplitGroup> groups) => _saveSplitsLocally(groups);

  Future<Map<String, WorkoutSession>> loadLocalSessions() => _loadSessionsLocally();
  Future<void> saveLocalSessions(Map<String, WorkoutSession> sessions) => _saveSessionsLocally(sessions);

  Future<List<BodyWeightEntry>> loadLocalWeightLogs() => _loadWeightLogsLocally();
  Future<void> saveLocalWeightLogs(List<BodyWeightEntry> logs) => _saveWeightLogsLocally(logs);

  // ----------------------------------------------------
  // SPLITS & MUSCLE GROUPS & EXERCISES CATALOG
  // ----------------------------------------------------

  static const Set<String> _legacyDefaultGroupIds = {
    'grp-upper',
    'grp-front',
    'grp-back',
    'grp-lower',
  };

  Stream<List<SplitGroup>> streamSplitGroups() {
    if (!_isFirestoreAvailable || _firestore == null || userId.isEmpty) {
      return const Stream.empty();
    }
    return _firestore!
        .collection('users')
        .doc(userId)
        .collection('splits')
        .snapshots()
        .map((snap) {
          final groups = <SplitGroup>[];
          for (var doc in snap.docs) {
            if (!_legacyDefaultGroupIds.contains(doc.id)) {
              final data = doc.data();
              data['id'] = doc.id;
              groups.add(SplitGroup.fromMap(data));
            }
          }
          groups.sort((a, b) => a.order.compareTo(b.order));
          if (groups.isNotEmpty) {
            _saveSplitsLocally(groups);
          }
          return groups;
        });
  }

  Future<List<SplitGroup>> getSplitGroups() async {
    if (_isFirestoreAvailable && _firestore != null && userId.isNotEmpty) {
      try {
        final snap = await _firestore!
            .collection('users')
            .doc(userId)
            .collection('splits')
            .get()
            .timeout(const Duration(milliseconds: 2500));

        if (snap.docs.isNotEmpty) {
          final groups = <SplitGroup>[];
          for (var doc in snap.docs) {
            if (_legacyDefaultGroupIds.contains(doc.id)) {
              try {
                await doc.reference.delete();
              } catch (_) {}
            } else {
              final data = doc.data();
              data['id'] = doc.id;
              groups.add(SplitGroup.fromMap(data));
            }
          }
          groups.sort((a, b) => a.order.compareTo(b.order));
          await _saveSplitsLocally(groups);
          return groups;
        }
      } catch (e) {
        debugPrint("Error/timeout fetching splits from Firestore, using cache: $e");
      }
    }

    final local = await _loadSplitsLocally();
    local.sort((a, b) => a.order.compareTo(b.order));
    return local;
  }

  Future<void> saveSplitGroup(SplitGroup group) async {
    final current = await _loadSplitsLocally();
    final idx = current.indexWhere((g) => g.id == group.id);
    if (idx >= 0) {
      current[idx] = group;
    } else {
      current.add(group);
    }
    await _saveSplitsLocally(current);

    if (_isFirestoreAvailable && _firestore != null && userId.isNotEmpty) {
      try {
        await _firestore!
            .collection('users')
            .doc(userId)
            .collection('splits')
            .doc(group.id)
            .set(group.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint("Error saving split group to Firestore: $e");
      }
    }
  }

  Future<void> saveAllSplitGroups(List<SplitGroup> groups) async {
    for (int i = 0; i < groups.length; i++) {
      groups[i].order = i;
    }
    await _saveSplitsLocally(groups);

    if (_isFirestoreAvailable && _firestore != null && userId.isNotEmpty) {
      try {
        final batch = _firestore!.batch();
        for (var group in groups) {
          final docRef = _firestore!
              .collection('users')
              .doc(userId)
              .collection('splits')
              .doc(group.id);
          batch.set(docRef, group.toMap(), SetOptions(merge: true));
        }
        await batch.commit();
      } catch (e) {
        debugPrint("Error saving all split groups to Firestore: $e");
      }
    }
  }

  Future<void> deleteSplitGroup(String groupId) async {
    final current = await _loadSplitsLocally();
    current.removeWhere((g) => g.id == groupId);
    await _saveSplitsLocally(current);

    if (_isFirestoreAvailable && _firestore != null && userId.isNotEmpty) {
      try {
        await _firestore!
            .collection('users')
            .doc(userId)
            .collection('splits')
            .doc(groupId)
            .delete();
      } catch (e) {
        debugPrint("Error deleting split group from Firestore: $e");
      }
    }
  }

  Future<void> clearAllSplitGroups() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localSplitsKey);

    if (_isFirestoreAvailable && _firestore != null && userId.isNotEmpty) {
      try {
        final snap = await _firestore!
            .collection('users')
            .doc(userId)
            .collection('splits')
            .get();
        for (var doc in snap.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        debugPrint("Error clearing splits from Firestore: $e");
      }
    }
  }

  Future<List<SplitGroup>> _loadSplitsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localSplitsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(raw);
        final groups = list
            .map((item) => SplitGroup.fromMap(Map<String, dynamic>.from(item)))
            .where((g) => !_legacyDefaultGroupIds.contains(g.id))
            .toList();
        await _saveSplitsLocally(groups);
        return groups;
      } catch (e) {
        debugPrint("Error decoding local splits: $e");
      }
    }
    return [];
  }

  Future<void> _saveSplitsLocally(List<SplitGroup> groups) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(groups.map((g) => g.toMap()).toList());
    await prefs.setString(_localSplitsKey, jsonStr);
  }

  // ----------------------------------------------------
  // WORKOUT SESSIONS & ANNUAL RETENTION POLICY
  // ----------------------------------------------------

  Stream<WorkoutSession?> streamSession(String dateKey) {
    if (!_isFirestoreAvailable || _firestore == null || userId.isEmpty) {
      return const Stream.empty();
    }
    return _firestore!
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .doc(dateKey)
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            data['date'] = doc.id;
            final session = WorkoutSession.fromMap(data);
            _loadSessionsLocally().then((local) {
              local[dateKey] = session;
              _saveSessionsLocally(local);
            });
            return session;
          }
          return null;
        });
  }

  Future<WorkoutSession?> getSession(String dateKey, {Duration timeout = const Duration(milliseconds: 2500)}) async {
    if (_isFirestoreAvailable && _firestore != null && userId.isNotEmpty) {
      try {
        final doc = await _firestore!
            .collection('users')
            .doc(userId)
            .collection('sessions')
            .doc(dateKey)
            .get()
            .timeout(timeout);

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          data['date'] = doc.id;
          final session = WorkoutSession.fromMap(data);
          final local = await _loadSessionsLocally();
          local[dateKey] = session;
          await _saveSessionsLocally(local);
          return session;
        }
      } catch (e) {
        debugPrint("Error/timeout fetching single session $dateKey from Firestore: $e");
      }
    }
    final local = await _loadSessionsLocally();
    return local[dateKey];
  }

  Future<Map<String, WorkoutSession>> getAllSessions() async {
    Map<String, WorkoutSession> sessions = {};

    if (_isFirestoreAvailable && _firestore != null && userId.isNotEmpty) {
      try {
        final snap = await _firestore!
            .collection('users')
            .doc(userId)
            .collection('sessions')
            .get()
            .timeout(const Duration(milliseconds: 3500));

        if (snap.docs.isNotEmpty) {
          for (var doc in snap.docs) {
            final data = doc.data();
            data['date'] = doc.id;
            sessions[doc.id] = WorkoutSession.fromMap(data);
          }
          await _saveSessionsLocally(sessions);
        }
      } catch (e) {
        debugPrint("Error/timeout fetching sessions from Firestore: $e");
      }
    }

    if (sessions.isEmpty) {
      sessions = await _loadSessionsLocally();
    }

    // Apply Annual Data Retention Policy (Never delete starting baseline month)
    sessions = await _applyAnnualRetention(sessions);

    return sessions;
  }

  Future<void> saveSession(WorkoutSession session) async {
    final sessions = await _loadSessionsLocally();
    sessions[session.date] = session;
    await _saveSessionsLocally(sessions);

    // Record baseline month if not yet recorded
    await _ensureBaselineMonth(session.date);

    if (_isFirestoreAvailable && _firestore != null && userId.isNotEmpty) {
      try {
        await _firestore!
            .collection('users')
            .doc(userId)
            .collection('sessions')
            .doc(session.date)
            .set(session.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint("Error saving session to Firestore: $e");
      }
    }
  }

  Future<void> deleteSession(String dateKey) async {
    final sessions = await _loadSessionsLocally();
    sessions.remove(dateKey);
    await _saveSessionsLocally(sessions);

    if (_isFirestoreAvailable && _firestore != null && userId.isNotEmpty) {
      try {
        await _firestore!
            .collection('users')
            .doc(userId)
            .collection('sessions')
            .doc(dateKey)
            .delete();
      } catch (e) {
        debugPrint("Error deleting session from Firestore: $e");
      }
    }
  }

  // ----------------------------------------------------
  // ROLLING MONTHLY RETENTION LOGIC:
  // After 1 year, purge rolling month-by-month (Month 2, then Month 3...).
  // The original starting month (Year 1 Month 1) is NEVER deleted, no matter
  // how many years pass, so the athlete always knows where they started.
  // ----------------------------------------------------

  Future<void> _ensureBaselineMonth(String sessionDate) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_baselineMonthKey)) {
      final monthKey = sessionDate.substring(0, 7); // e.g. "2025-01"
      await prefs.setString(_baselineMonthKey, monthKey);

      if (_isFirestoreAvailable && _firestore != null && userId.isNotEmpty) {
        try {
          await _firestore!.collection('users').doc(userId).set({
            'baselineMonth': monthKey,
          }, SetOptions(merge: true));
        } catch (_) {}
      }
    }
  }

  Future<Map<String, WorkoutSession>> _applyAnnualRetention(
      Map<String, WorkoutSession> sessions) async {
    if (sessions.isEmpty) return sessions;

    final prefs = await SharedPreferences.getInstance();
    String? baselineMonth = prefs.getString(_baselineMonthKey);

    // If not in local prefs, check Firestore user profile first
    if ((baselineMonth == null || baselineMonth.isEmpty) &&
        _isFirestoreAvailable &&
        _firestore != null &&
        userId.isNotEmpty) {
      try {
        final userDoc = await _firestore!.collection('users').doc(userId).get();
        if (userDoc.exists && userDoc.data()?['baselineMonth'] != null) {
          baselineMonth = userDoc.data()!['baselineMonth'] as String;
          await prefs.setString(_baselineMonthKey, baselineMonth);
        }
      } catch (_) {}
    }

    // If still not set, lock the earliest recorded month in history as the permanent baseline
    if (baselineMonth == null || baselineMonth.isEmpty) {
      final sortedDates = sessions.keys.toList()..sort();
      if (sortedDates.isNotEmpty) {
        baselineMonth = sortedDates.first.substring(0, 7);
        await prefs.setString(_baselineMonthKey, baselineMonth);

        if (_isFirestoreAvailable && _firestore != null && userId.isNotEmpty) {
          try {
            await _firestore!.collection('users').doc(userId).set({
              'baselineMonth': baselineMonth,
            }, SetOptions(merge: true));
          } catch (_) {}
        }
      }
    }

    final nowIST = StreakService.nowIST;
    // Exactly 12 months ago in IST (rolling 1-year cutoff):
    // e.g. If current is 2026-02, cutoff is 2025-02 (Month 2 of Year 1 is 1 year old -> purged).
    // If current is 2026-03, cutoff is 2025-03 (Month 3 of Year 1 is purged).
    final cutoffYear = nowIST.year - 1;
    final cutoffMonth = nowIST.month.toString().padLeft(2, '0');
    final cutoffMonthKey = '$cutoffYear-$cutoffMonth';

    final List<String> toDelete = [];

    sessions.forEach((dateStr, session) {
      try {
        final sessionMonth = dateStr.substring(0, 7); // "YYYY-MM"

        // Rule 1: Baseline Starting Month is PERMANENT. Never delete it!
        if (sessionMonth == baselineMonth) {
          return;
        }

        // Rule 2: Rolling Monthly Purge.
        // Any session whose month reached 1 year ago (<= cutoffMonthKey) is purged!
        if (sessionMonth.compareTo(cutoffMonthKey) <= 0) {
          toDelete.add(dateStr);
        }
      } catch (_) {}
    });

    if (toDelete.isNotEmpty) {
      debugPrint("Rolling Purge: Cleaning up ${toDelete.length} sessions older than 1 year (<= $cutoffMonthKey). Permanent Baseline preserved: $baselineMonth");
      for (var d in toDelete) {
        sessions.remove(d);
        if (_isFirestoreAvailable && _firestore != null && userId.isNotEmpty) {
          _firestore!
              .collection('users')
              .doc(userId)
              .collection('sessions')
              .doc(d)
              .delete()
              .catchError((_) {});
        }
      }
      await _saveSessionsLocally(sessions);
    }

    return sessions;
  }

  Future<Map<String, WorkoutSession>> _loadSessionsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localSessionsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final Map<String, dynamic> map = jsonDecode(raw);
        final Map<String, WorkoutSession> result = {};
        map.forEach((key, val) {
          result[key] = WorkoutSession.fromMap(Map<String, dynamic>.from(val));
        });
        return result;
      } catch (e) {
        debugPrint("Error decoding local sessions: $e");
      }
    }

    // Default Seed Session (using India Time)
    final todayKey = StreakService.todayKeyIST;
    final seed = {
      todayKey: WorkoutSession(
        date: todayKey,
        exercises: [
          Exercise(
            id: 'ex-1',
            name: 'Incline Dumbbell Press',
            group: 'Upper Body',
            part: 'Chest',
            equipment: 'Dumbbell',
            sets: [
              WorkoutSet(setNumber: 1, weight: 24, reps: 12, completed: true),
              WorkoutSet(setNumber: 2, weight: 26, reps: 10, completed: true),
              WorkoutSet(setNumber: 3, weight: 28, reps: 8, completed: false),
            ],
          ),
          Exercise(
            id: 'ex-2',
            name: 'Seated Cable Lateral Raise',
            group: 'Upper Body',
            part: 'Shoulders',
            equipment: 'Cable',
            sets: [
              WorkoutSet(setNumber: 1, weight: 12, reps: 15, completed: true),
              WorkoutSet(setNumber: 2, weight: 14, reps: 12, completed: false),
            ],
          ),
        ],
      )
    };
    await _saveSessionsLocally(seed);
    return seed;
  }

  Future<void> _saveSessionsLocally(Map<String, WorkoutSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> map = {};
    sessions.forEach((key, val) {
      map[key] = val.toMap();
    });
    await prefs.setString(_localSessionsKey, jsonEncode(map));
  }

  // ----------------------------------------------------
  // ACTIVE WORKOUT DRAFT PERSISTENCE
  // ----------------------------------------------------

  String get _activeWorkoutDraftKey => 'active_workout_draft_$userId';

  Future<WorkoutSession?> loadActiveWorkoutDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_activeWorkoutDraftKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final Map<String, dynamic> map = jsonDecode(raw);
        return WorkoutSession.fromMap(map);
      } catch (e) {
        debugPrint("Error decoding active workout draft: $e");
      }
    }
    return null;
  }

  Future<void> saveActiveWorkoutDraft(WorkoutSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeWorkoutDraftKey, jsonEncode(session.toMap()));
  }

  Future<void> clearActiveWorkoutDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeWorkoutDraftKey);
  }

  // ----------------------------------------------------
  // USER BODY WEIGHT LOGS (On-demand, sporadic check-ins)
  // ----------------------------------------------------

  Future<List<BodyWeightEntry>> getWeightLogs() async {
    if (_isFirestoreAvailable && _firestore != null && userId.isNotEmpty) {
      try {
        final snap = await _firestore!
            .collection('users')
            .doc(userId)
            .collection('weight_logs')
            .orderBy('date', descending: false)
            .get()
            .timeout(const Duration(milliseconds: 2500));

        if (snap.docs.isNotEmpty) {
          final logs = snap.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return BodyWeightEntry.fromMap(data);
          }).toList();
          await _saveWeightLogsLocally(logs);
          return logs;
        }
      } catch (e) {
        debugPrint("Error/timeout fetching weight logs from Firestore: $e");
      }
    }

    return await _loadWeightLogsLocally();
  }

  Future<void> saveWeightLog(BodyWeightEntry entry) async {
    final current = await _loadWeightLogsLocally();
    final idx = current.indexWhere((e) => e.id == entry.id);
    if (idx >= 0) {
      current[idx] = entry;
    } else {
      current.add(entry);
    }
    current.sort((a, b) => a.date.compareTo(b.date));
    await _saveWeightLogsLocally(current);

    if (_isFirestoreAvailable && _firestore != null && userId.isNotEmpty) {
      try {
        await _firestore!
            .collection('users')
            .doc(userId)
            .collection('weight_logs')
            .doc(entry.id)
            .set(entry.toMap(), SetOptions(merge: true));

        await _firestore!.collection('users').doc(userId).set({
          'currentBodyWeight': current.last.weightKg,
          'lastWeightCheckDate': current.last.date.toIso8601String(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Error saving weight log to Firestore: $e");
      }
    }
  }

  Future<void> deleteWeightLog(String logId) async {
    final current = await _loadWeightLogsLocally();
    current.removeWhere((e) => e.id == logId);
    await _saveWeightLogsLocally(current);

    if (_isFirestoreAvailable && _firestore != null && userId.isNotEmpty) {
      try {
        await _firestore!
            .collection('users')
            .doc(userId)
            .collection('weight_logs')
            .doc(logId)
            .delete();

        if (current.isNotEmpty) {
          await _firestore!.collection('users').doc(userId).set({
            'currentBodyWeight': current.last.weightKg,
            'lastWeightCheckDate': current.last.date.toIso8601String(),
          }, SetOptions(merge: true));
        } else {
          await _firestore!.collection('users').doc(userId).update({
            'currentBodyWeight': FieldValue.delete(),
            'lastWeightCheckDate': FieldValue.delete(),
          }).catchError((_) {});
        }
      } catch (e) {
        debugPrint("Error deleting weight log from Firestore: $e");
      }
    }
  }

  Future<List<BodyWeightEntry>> _loadWeightLogsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localWeightLogsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(raw);
        final logs = list
            .map((item) => BodyWeightEntry.fromMap(Map<String, dynamic>.from(item)))
            .toList();
        logs.sort((a, b) => a.date.compareTo(b.date));
        return logs;
      } catch (e) {
        debugPrint("Error decoding local weight logs: $e");
      }
    }
    return [];
  }

  Future<void> _saveWeightLogsLocally(List<BodyWeightEntry> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(logs.map((e) => e.toMap()).toList());
    await prefs.setString(_localWeightLogsKey, jsonStr);
  }
}
