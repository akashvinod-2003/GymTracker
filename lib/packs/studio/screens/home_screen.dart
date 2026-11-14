import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gym_tracker/providers/workout_provider.dart';
import 'package:gym_tracker/services/streak_service.dart';
import '../theme/app_theme.dart';
import '../theme/motion.dart';
import '../widgets/custom_bottom_nav.dart';
import 'profile_drawer.dart';
import 'tabs/analytics_tab.dart';
import 'tabs/daily_tab.dart';
import 'tabs/splits_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _titles = ['Today', 'Splits', 'Progress'];

  void _select(int index) {
    if (index == _tab) return;
    Haptics.select();
    setState(() => _tab = index);
  }

  Future<void> _pickDate() async {
    final wp = context.read<WorkoutProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: wp.currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) wp.setDate(picked);
  }

  void _shiftDay(int days) {
    final wp = context.read<WorkoutProvider>();
    Haptics.select();
    wp.setDate(wp.currentDate.add(Duration(days: days)));
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final wp = context.watch<WorkoutProvider>();

    final isToday =
        DateFormat('yyyy-MM-dd').format(wp.currentDate) == StreakService.todayKeyIST;
    final title = _tab == 0 && !isToday
        ? DateFormat('EEE, MMM d').format(wp.currentDate)
        : _titles[_tab];
    final eyebrow = _tab == 0
        ? (isToday
            ? DateFormat('EEEE, MMM d').format(wp.currentDate).toUpperCase()
            : 'PAST SESSION')
        : null;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: p.bg,
      extendBody: true,
      drawer: const ProfileDrawer(),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              children: [
                _Header(
                  title: title,
                  eyebrow: eyebrow,
                  onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                  trailing: _tab == 0
                      ? _DateControls(
                          onPrev: () => _shiftDay(-1),
                          onPick: _pickDate,
                          onNext: () => _shiftDay(1),
                          showToday: !isToday,
                          onToday: () => wp.setDate(StreakService.nowIST),
                        )
                      : null,
                ),
                Expanded(
                  child: IndexedStack(
                    index: _tab,
                    children: [
                      DailyTab(onNavigateToSplits: () => _select(1)),
                      const SplitsTab(),
                      AnalyticsTab(onSelectSession: () => _select(0)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _tab,
        onTabSelected: _select,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String? eyebrow;
  final VoidCallback onMenu;
  final Widget? trailing;

  const _Header({
    required this.title,
    required this.eyebrow,
    required this.onMenu,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 12, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            onPressed: onMenu,
            tooltip: 'Profile and settings',
            icon: Icon(Icons.account_circle_rounded, color: p.text2, size: 30),
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: eyebrow == null
                      ? const SizedBox.shrink()
                      : Text(
                          eyebrow!,
                          key: ValueKey(eyebrow),
                          style: t.labelSmall?.copyWith(
                            color: p.text2,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: Text(
                    title,
                    key: ValueKey(title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.headlineLarge,
                    semanticsLabel: title,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _DateControls extends StatelessWidget {
  final VoidCallback onPrev;
  final VoidCallback onPick;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final bool showToday;

  const _DateControls({
    required this.onPrev,
    required this.onPick,
    required this.onNext,
    required this.onToday,
    required this.showToday,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    Widget btn(IconData icon, String tip, VoidCallback onTap) => IconButton(
          onPressed: onTap,
          tooltip: tip,
          icon: Icon(icon, size: 22, color: p.text),
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        );

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.separator),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.chevron_left_rounded, 'Previous day', onPrev),
          if (showToday)
            TextButton(
              onPressed: onToday,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
              child: const Text('Today'),
            )
          else
            btn(Icons.calendar_month_rounded, 'Choose date', onPick),
          btn(Icons.chevron_right_rounded, 'Next day', onNext),
        ],
      ),
    );
  }
}
