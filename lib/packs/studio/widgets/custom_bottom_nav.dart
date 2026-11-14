import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/motion.dart';

/// Floating translucent tab bar. Tabs only navigate; actions (add exercise,
/// finish workout) live on the Today screen where they apply.
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  static const _items = [
    (Icons.today_outlined, Icons.today_rounded, 'Today'),
    (Icons.grid_view_outlined, Icons.grid_view_rounded, 'Splits'),
    (Icons.insights_outlined, Icons.insights_rounded, 'Progress'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final reduceTransparency = MediaQuery.highContrastOf(context);

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 8),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: reduceTransparency
                    ? ImageFilter.blur()
                    : ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: reduceTransparency ? p.surface : p.chrome,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: p.chromeEdge),
                  ),
                  child: LayoutBuilder(builder: (context, c) {
                    final w = c.maxWidth / _items.length;
                    return Stack(
                      children: [
                        // Selection pill glides between tabs on a spring and
                        // can be redirected mid-flight.
                        SpringValue(
                          value: currentIndex.toDouble(),
                          builder: (_, v) => Positioned(
                            left: v * w,
                            top: 0,
                            bottom: 0,
                            width: w,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: p.accentTint,
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            for (var i = 0; i < _items.length; i++)
                              Expanded(
                                child: _Tab(
                                  icon: _items[i].$1,
                                  selectedIcon: _items[i].$2,
                                  label: _items[i].$3,
                                  selected: i == currentIndex,
                                  onTap: () => onTabSelected(i),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final color = selected ? p.accent : p.text2;
    return Semantics(
      selected: selected,
      label: '$label tab',
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, size: 24, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
