import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class DailyTabSkeleton extends StatefulWidget {
  const DailyTabSkeleton({super.key});

  @override
  State<DailyTabSkeleton> createState() => _DailyTabSkeletonState();
}

class _DailyTabSkeletonState extends State<DailyTabSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _opacityAnim = Tween<double>(begin: 0.35, end: 0.75).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final cardBg = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final boneColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final boneAccent = isDark ? const Color(0xFF0F3635) : const Color(0xFFCCFBF1);

    Widget bone({
      required double width,
      required double height,
      double radius = 12,
      Color? color,
    }) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color ?? boneColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _opacityAnim,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 96),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Volume Card Skeleton
                    Container(
                      width: double.infinity,
                      height: 146,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              bone(width: 110, height: 18, radius: 8),
                              bone(width: 80, height: 28, radius: 14, color: boneAccent),
                            ],
                          ),
                          bone(width: 160, height: 32, radius: 8),
                          Row(
                            children: [
                              bone(width: 90, height: 14, radius: 6),
                              const SizedBox(width: 16),
                              bone(width: 90, height: 14, radius: 6),
                              const SizedBox(width: 16),
                              bone(width: 90, height: 14, radius: 6),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category Pills Row Skeleton
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          bone(width: 96, height: 38, radius: 20, color: boneAccent),
                          const SizedBox(width: 8),
                          bone(width: 108, height: 38, radius: 20),
                          const SizedBox(width: 8),
                          bone(width: 90, height: 38, radius: 20),
                          const SizedBox(width: 8),
                          bone(width: 112, height: 38, radius: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section Header Skeleton
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            bone(width: 130, height: 20, radius: 6),
                            const SizedBox(width: 8),
                            bone(width: 28, height: 20, radius: 10, color: boneAccent),
                          ],
                        ),
                        bone(width: 110, height: 32, radius: 16),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Exercise Cards Skeleton
                    for (int i = 0; i < 2; i++) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    bone(width: 180, height: 18, radius: 6),
                                    const SizedBox(height: 6),
                                    bone(width: 120, height: 12, radius: 4),
                                  ],
                                ),
                                bone(width: 32, height: 32, radius: 10),
                              ],
                            ),
                            const SizedBox(height: 14),
                            bone(width: double.infinity, height: 34, radius: 8),
                            const SizedBox(height: 8),
                            bone(width: double.infinity, height: 34, radius: 8),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
