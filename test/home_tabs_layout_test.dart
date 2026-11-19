import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:gym_tracker/models/body_weight_entry.dart';
import 'package:gym_tracker/models/exercise.dart';
import 'package:gym_tracker/models/split_group.dart';
import 'package:gym_tracker/models/workout_session.dart';
import 'package:gym_tracker/models/workout_set.dart';
import 'package:gym_tracker/providers/theme_provider.dart';
import 'package:gym_tracker/providers/workout_provider.dart';
import 'package:gym_tracker/theme/app_theme.dart';
import 'package:gym_tracker/screens/tabs/daily_tab.dart';
import 'package:gym_tracker/screens/tabs/workout_tab.dart';
import 'package:gym_tracker/widgets/custom_bottom_nav.dart';
import 'package:gym_tracker/packs/studio/widgets/custom_bottom_nav.dart' as studio;
import 'package:gym_tracker/packs/studio/theme/app_theme.dart' as studio;
import 'package:gym_tracker/packs/studio/screens/tabs/daily_tab.dart' as studio;
import 'package:gym_tracker/packs/studio/screens/tabs/workout_tab.dart' as studio;

/// Flutter SDK root, derived from the running `flutter_tester` binary
/// (`<root>/bin/cache/artifacts/engine/<platform>/flutter_tester`).
String _flutterRoot() {
  var dir = File(Platform.resolvedExecutable).parent;
  while (dir.path != dir.parent.path) {
    if (Directory('${dir.path}/bin/cache/artifacts/material_fonts').existsSync()) return dir.path;
    dir = dir.parent;
  }
  return '';
}

const _longSplit = 'Upper Body Hypertrophy Push Pull Superset Marathon';

Exercise _exercise(String id) => Exercise(
      id: id,
      name: 'Incline Dumbbell Bench Press With Pause',
      group: _longSplit,
      part: 'Chest',
      equipment: 'Dumbbell',
      sets: [
        WorkoutSet(setNumber: 1, weight: 30, reps: 10, completed: true),
        WorkoutSet(setNumber: 2, weight: 30, reps: 8),
      ],
    );

WorkoutProvider _provider({required bool withData}) {
  final wp = WorkoutProvider()..loadStartupData();
  if (withData) {
    wp.sessions[wp.currentDateKey] = WorkoutSession(
      date: wp.currentDateKey,
      splitName: _longSplit,
      exercises: [_exercise('a'), _exercise('b')],
    );
    wp.startActiveWorkout(SplitGroup(id: 'long', name: _longSplit, parts: const {}));
    wp.updateActiveWorkoutExercises([_exercise('c')]);
  }
  return wp;
}

Future<void> _pump(
  WidgetTester tester, {
  required Widget child,
  required WorkoutProvider wp,
  required ThemeData light,
  required ThemeData dark,
  required Brightness brightness,
}) async {
  // 345 wide leaves headroom under the 360px target: Roboto stands in for the
  // slightly wider Plus Jakarta Sans. (ExerciseCard set rows need ~332px.)
  // Tall enough that lazy lists lay out every child.
  tester.view.physicalSize = const Size(345, 3000);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider.value(value: wp),
      ],
      child: MaterialApp(
        theme: light,
        darkTheme: dark,
        themeMode: ThemeMode.system,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    // The default test font draws every glyph as a full em square, which
    // overstates text width. Load the SDK's Roboto under the app's font
    // names so widths are close to real Plus Jakarta Sans.
    final sdkFonts = '${Platform.environment['FLUTTER_ROOT'] ?? _flutterRoot()}'
        '/bin/cache/artifacts/material_fonts';
    Future<void> load(String family, List<String> files) async {
      final loader = FontLoader(family);
      for (final f in files) {
        final file = File('$sdkFonts/$f');
        if (file.existsSync()) {
          loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
        }
      }
      await loader.load();
    }

    const all = ['roboto-regular.ttf', 'roboto-medium.ttf', 'roboto-bold.ttf', 'roboto-black.ttf'];
    await load('Roboto', all);
    await load('Plus Jakarta Sans', all);
    // google_fonts asks for one family per weight, e.g. PlusJakartaSans_700.
    await load('PlusJakartaSans_regular', ['roboto-regular.ttf']);
    for (final w in [100, 200, 300, 400, 500, 600, 700, 800, 900]) {
      await load('PlusJakartaSans_$w', [
        w >= 800 ? 'roboto-black.ttf' : w >= 600 ? 'roboto-bold.ttf' : w == 500 ? 'roboto-medium.ttf' : 'roboto-regular.ttf',
      ]);
    }
  });
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final packs = <String, (ThemeData, ThemeData, Widget Function(), Widget Function())>{
    'classic': (
      AppTheme.lightTheme,
      AppTheme.darkTheme,
      () => DailyTab(onNavigateToSplits: () {}, onNavigateToWorkout: () {}),
      () => WorkoutTab(onFinish: () {}),
    ),
    'studio': (
      studio.AppTheme.lightTheme,
      studio.AppTheme.darkTheme,
      () => studio.DailyTab(onNavigateToSplits: () {}, onNavigateToWorkout: () {}),
      () => const studio.WorkoutTab(),
    ),
  };

  for (final pack in packs.entries) {
    for (final brightness in Brightness.values) {
      for (final withData in [false, true]) {
        final label = '${pack.key} ${brightness.name} ${withData ? 'with draft' : 'empty'}';
        final (light, dark, daily, workout) = pack.value;

        testWidgets('dashboard fits 360px: $label', (tester) async {
          await _pump(tester,
              child: daily(), wp: _provider(withData: withData), light: light, dark: dark, brightness: brightness);
          expect(find.textContaining('ACTIVE WORKOUT IN PROGRESS'), findsNothing);
        });

        testWidgets('workout tab fits 360px: $label', (tester) async {
          await _pump(tester,
              child: workout(), wp: _provider(withData: withData), light: light, dark: dark, brightness: brightness);
          expect(find.text('Resume'), withData ? findsOneWidget : findsNothing);
        });
      }
    }

    final (light, dark, _, _) = pack.value;

    testWidgets('bottom nav fits 360px: ${pack.key}', (tester) async {
      final tapped = <int>[];
      final nav = pack.key == 'classic'
          ? CustomBottomNav(currentIndex: 1, onTabSelected: tapped.add, onCenterFabPressed: () {})
          : studio.CustomBottomNav(currentIndex: 1, onTabSelected: tapped.add);
      await _pump(tester,
          child: Align(alignment: Alignment.bottomCenter, child: nav),
          wp: _provider(withData: false),
          light: light,
          dark: dark,
          brightness: Brightness.light);
      expect(find.text('Workout'), findsOneWidget);
      expect(find.text('Finish'), findsNothing);
      await tester.tap(find.text('Workout'));
      expect(tapped, [1]);
    });

    testWidgets('loading skeleton fits 360px: ${pack.key}', (tester) async {
      // Provider not started yet: isLoading stays true, skeleton shows.
      await _pump(tester,
          child: pack.value.$3(), wp: WorkoutProvider(), light: light, dark: dark, brightness: Brightness.light);
    });

    testWidgets('dashboard with loaded history fits 360px: ${pack.key}', (tester) async {
      final wp = _provider(withData: true);
      final today = wp.currentDate;
      for (final back in [1, 3, 5]) {
        final key = DateFormat('yyyy-MM-dd').format(today.subtract(Duration(days: back)));
        wp.sessions[key] = WorkoutSession(date: key, exercises: [_exercise('h$back')]);
      }
      wp.weightLogs.addAll([
        BodyWeightEntry(id: 'w1', weightKg: 82.4, date: today.subtract(const Duration(days: 30))),
        BodyWeightEntry(id: 'w2', weightKg: 80.1, date: today),
      ]);
      await wp.loadAnalyticsData();
      await _pump(tester, child: pack.value.$3(), wp: wp, light: light, dark: dark, brightness: Brightness.dark);
      expect(find.text('80.1 kg'), findsOneWidget);
      expect(find.textContaining('since start'), findsOneWidget);
      expect(find.text('Tap to load'), findsNothing);
    });

    testWidgets('dashboard opens workout tab: ${pack.key}', (tester) async {
      var opened = 0;
      final dashboard = pack.key == 'classic'
          ? DailyTab(onNavigateToSplits: () {}, onNavigateToWorkout: () => opened++)
          : studio.DailyTab(onNavigateToSplits: () {}, onNavigateToWorkout: () => opened++);
      await _pump(tester,
          child: dashboard, wp: _provider(withData: false), light: light, dark: dark, brightness: Brightness.light);
      await tester.tap(find.text('Go to workout'));
      expect(opened, 1);
    });
  }
}
