# Workout tab + Home dashboard

## Goal
Remove the "Active workout in progress · Resume" banner from the Daily tab. Move all
current-workout UI into a new Workout tab. Turn Home into a progress dashboard.

## Nav
- Base pack: `Daily · Workout · (+) · Splits · Analytics`. Finish leaves the nav and
  becomes a button inside the Workout tab (same `_triggerFinishSession` logic).
- Studio pack: `Today · Workout · Splits · Progress` (no FAB there).
- Analytics/Progress stays lazy-built on first visit (index moves 2 → 3).

## Workout tab (`tabs/workout_tab.dart`, one per pack, own palette)
1. Session card. When `hasActiveWorkoutDraft`: "In progress · <split> · N exercises"
   plus **Resume** (`TodaysWorkoutFlowScreen.start`). Otherwise: **Start Guided
   Workout** plus **Quick Setup**.
2. Today's Exercises header (count, split chip, Last Workout, Add), moved unchanged.
3. Exercise list or empty state, moved unchanged.
4. **Finish Workout** button at the bottom, shown when exercises exist.

## Home dashboard (`tabs/daily_tab.dart`, per pack)
1. Hero volume card (unchanged): volume, exercises, sets, finished, streak.
2. Today's split card: split name, "x/y sets done" bar, **Go to workout** (switches tab).
3. Two tiles: streak (current vs best) and body weight (latest plus change since start).
   They stack vertically below about 340px of content width.
4. 7-day volume strip: 7 calendar days ending at `currentDate`
   (`lastSevenCalendarDayVolumes`), not the last 7 session keys.
5. Muscle-group breakdown (`CategoryPillsRow`; in studio it is inside the hero card).

The 7-day strip and body weight both load lazily. Until `isAnalyticsLoaded`, each one
shows a tap-to-load control that calls `loadAnalyticsData()`, which also runs when
Analytics is opened. Nothing new is fetched at startup.

The Analytics session tap now opens the Workout tab, which shows that day's exercises.
Studio date controls show on both Today and Workout.

## Done
The banner is gone and the Workout tab can resume a draft. Neither pack overflows at
360px. `flutter analyze` is clean and `flutter test` passes.
