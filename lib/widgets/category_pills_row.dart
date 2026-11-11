import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class CategoryPillsRow extends StatelessWidget {
  final Map<String, int> muscleSetCounts;
  final VoidCallback onManageTap;

  const CategoryPillsRow({
    super.key,
    required this.muscleSetCounts,
    required this.onManageTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final cardBg = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

    final totalSets = muscleSetCounts.values.fold(0, (sum, val) => sum + val);
    final parts = muscleSetCounts.keys.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SPLIT BREAKDOWN',
                    style: GoogleFonts.plusJakartaSans(
                      color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Muscle Groups',
                    style: GoogleFonts.plusJakartaSans(
                      color: titleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onManageTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'Manage',
                        style: GoogleFonts.plusJakartaSans(
                          color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Pills Row
          if (parts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'No muscle activity yet for this session.',
                  style: GoogleFonts.plusJakartaSans(
                    color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 105,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: parts.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final part = parts[index];
                  final sets = muscleSetCounts[part] ?? 0;
                  final pct = totalSets > 0 ? ((sets / totalSets) * 100).round() : 0;
                  final style = AppTheme.pastelStyles[index % AppTheme.pastelStyles.length];

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Circular Icon Ring
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: style.bg(isDark),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: style.border(isDark),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: style.text(isDark).withValues(alpha: 0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          style.icon,
                          size: 22,
                          color: style.text(isDark),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 72,
                        child: Text(
                          part,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            color: titleColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '$sets sets',
                        style: GoogleFonts.plusJakartaSans(
                          color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: GoogleFonts.plusJakartaSans(
                          color: style.text(isDark),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
