import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/split_group.dart';
import '../../providers/theme_provider.dart';
import '../../providers/workout_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/add_muscle_dialog.dart';
import '../../widgets/add_split_dialog.dart';
import '../../widgets/edit_split_dialog.dart';

class SplitsTab extends StatelessWidget {
  const SplitsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    final cardBg = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subColor = isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B);

    final groups = workoutProvider.splitGroups;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 96),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(28),
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
                // Top Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EXERCISE HIERARCHY',
                            style: GoogleFonts.plusJakartaSans(
                              color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Splits & Exercises',
                            style: GoogleFonts.plusJakartaSans(
                              color: titleColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (groups.isNotEmpty) ...[
                          Tooltip(
                            message: 'Clear All Splits',
                            child: InkWell(
                              onTap: () => _confirmClearAll(context, workoutProvider, isDark),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF2D1619) : const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA),
                                  ),
                                ),
                                child: Icon(
                                  Icons.delete_sweep_rounded,
                                  size: 19,
                                  color: isDark ? Colors.redAccent.shade100 : Colors.red.shade600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Tooltip(
                          message: 'New Split Group',
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => const AddSplitDialog(),
                              );
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.tealPrimary.withValues(alpha: isDark ? 0.35 : 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.create_new_folder_rounded,
                                size: 19,
                                color: isDark ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '3-tier training catalog: Split Group &rarr; Body Part &rarr; Specific Exercise Movements.',
                  style: GoogleFonts.plusJakartaSans(
                    color: subColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),

                // Splits Cards List
                if (workoutProvider.isLoading && groups.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: List.generate(
                        3,
                        (i) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          height: 72,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  )
                else if (groups.isEmpty)
                  Center(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF162344).withValues(alpha: 0.4) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.fitness_center_rounded,
                            size: 44,
                            color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No Split Groups Yet',
                            style: GoogleFonts.plusJakartaSans(
                              color: titleColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'All default templates have been cleared. Tap "New Split" above to add your own custom split groups, muscles, and exercises.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              color: subColor,
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => const AddSplitDialog(),
                              );
                            },
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Create First Split Group'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                              foregroundColor: isDark ? Colors.black : Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: groups.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, idx) {
                      return _SplitGroupCard(
                        group: groups[idx],
                        index: idx,
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context, WorkoutProvider provider, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete All Split Groups?',
          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'This will remove all split groups, muscle parts, and exercise templates so you can build your own library completely from scratch.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearAllSplitGroups();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All split templates deleted.'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _SplitGroupCard extends StatefulWidget {
  final SplitGroup group;
  final int index;

  const _SplitGroupCard({
    required this.group,
    required this.index,
  });

  @override
  State<_SplitGroupCard> createState() => _SplitGroupCardState();
}

class _SplitGroupCardState extends State<_SplitGroupCard> {
  String? _expandedPart;

  void _showEditAbbreviationDialog(BuildContext context, WorkoutProvider provider, bool isDark) {
    final controller = TextEditingController(
      text: widget.group.shortName.isNotEmpty ? widget.group.shortName : widget.group.effectiveShortName,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.short_text_rounded,
              color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Edit Abbreviation',
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set the abbreviation for "${widget.group.name}". This is shown on calendar day cells (e.g. UP for Upper Body, PUSH, LEG).',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 8,
              textCapitalization: TextCapitalization.characters,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Abbreviation',
                hintText: 'e.g. UP, PUSH, LEG',
                counterText: '',
                filled: true,
                fillColor: isDark ? const Color(0xFF162344) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newAbbr = controller.text.trim().toUpperCase();
              if (newAbbr.isNotEmpty) {
                final updated = widget.group.copyWith(shortName: newAbbr);
                await provider.updateSplitGroup(updated);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Updated abbreviation to "$newAbbr" for "${widget.group.name}"'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
              foregroundColor: isDark ? Colors.black : Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context, String partName) {
    final controller = TextEditingController();
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add Exercise to $partName',
          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. Incline Dumbbell Press',
            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13),
            filled: true,
            fillColor: isDark ? const Color(0xFF162344) : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                workoutProvider.addExerciseToPart(widget.group.id, partName, name);
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
              foregroundColor: isDark ? Colors.black : Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _promptDuplicateAbove(BuildContext context, WorkoutProvider provider, bool isDark) {
    final nameController = TextEditingController(text: '${widget.group.name} (Copy)');
    final shortNameController = TextEditingController(text: widget.group.effectiveShortName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.arrow_upward_rounded,
              color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Add Split Above',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duplicates all days, body parts, exercises, sets and reps, and inserts the new split directly above "${widget.group.name}".',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'NEW SPLIT NAME',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: nameController,
              autofocus: true,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF162344) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'SHORT NAME / ABBREVIATION',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: shortNameController,
              maxLength: 8,
              textCapitalization: TextCapitalization.characters,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: 'e.g. PUSH',
                filled: true,
                fillColor: isDark ? const Color(0xFF162344) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) return;
              String shortN = shortNameController.text.trim().toUpperCase();
              if (shortN.isEmpty) {
                shortN = newName.length <= 6 ? newName.toUpperCase() : newName.substring(0, 5).toUpperCase();
              }
              Navigator.pop(ctx);
              final duplicated = await provider.duplicateSplitAbove(widget.group.id, customName: newName);
              if (duplicated != null && shortN.isNotEmpty) {
                await provider.updateSplitGroup(duplicated.copyWith(shortName: shortN));
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Inserted "$newName [$shortN]" directly above "${widget.group.name}"'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
              foregroundColor: isDark ? Colors.black : Colors.white,
            ),
            child: const Text('Add Above'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);

    final cardBg = isDark ? const Color(0xFF162344) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF23355C) : const Color(0xFFE2E8F0);
    final badgeBg = isDark ? const Color(0xFF0F1A33) : Colors.white;
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subColor = isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B);

    final pastel = AppTheme.pastelStyles[widget.index % AppTheme.pastelStyles.length];
    final initials = widget.group.effectiveShortName;

    final parts = widget.group.partNames;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Tooltip(
                message: 'Tap to edit abbreviation',
                child: InkWell(
                  onTap: () => _showEditAbbreviationDialog(context, workoutProvider, isDark),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 46,
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: pastel.bg(isDark),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: pastel.border(isDark)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: pastel.text(isDark),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.group.name,
                            style: GoogleFonts.plusJakartaSans(
                              color: titleColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Tooltip(
                          message: 'Tap to edit abbreviation',
                          child: InkWell(
                            onTap: () => _showEditAbbreviationDialog(context, workoutProvider, isDark),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F3635) : AppTheme.tealBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF134E4A) : const Color(0xFF99F6E4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.group.effectiveShortName,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 10,
                                    color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${parts.length} body parts configured',
                      style: GoogleFonts.plusJakartaSans(
                        color: subColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Add Split Above (Duplicate Split)
                  Tooltip(
                    message: 'Add Split Above',
                    child: InkWell(
                      onTap: () => _promptDuplicateAbove(context, workoutProvider, isDark),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F3635) : AppTheme.tealBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? const Color(0xFF134E4A) : const Color(0xFF99F6E4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_upward_rounded,
                              size: 14,
                              color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Add Above',
                              style: GoogleFonts.plusJakartaSans(
                                color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Edit Split
                  Tooltip(
                    message: 'Edit Split',
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 19),
                      color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => EditSplitDialog(splitGroup: widget.group),
                        );
                      },
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Delete Split
                  Tooltip(
                    message: 'Delete Split',
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 19),
                      color: isDark ? Colors.redAccent.shade100 : Colors.red.shade400,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: Text(
                              'Delete ${widget.group.name}?',
                              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            content: Text(
                              'This will delete the split group and all exercise movements under it.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: subColor,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  workoutProvider.deleteSplitGroup(widget.group.id);
                                  Navigator.pop(ctx);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade600,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Scheduled Days & Target Sets/Reps Badges
          if (widget.group.days.isNotEmpty || widget.group.defaultSets > 0) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (widget.group.days.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F3635) : AppTheme.tealBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF134E4A) : const Color(0xFF99F6E4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 11,
                          color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.group.days.join(', '),
                          style: GoogleFonts.plusJakartaSans(
                            color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${widget.group.defaultSets} sets × ${widget.group.defaultReps} reps',
                    style: GoogleFonts.plusJakartaSans(
                      color: subColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (widget.group.desc.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.group.desc,
              style: GoogleFonts.plusJakartaSans(
                color: subColor,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Body Parts & Their Exercise Libraries (Level 2 & Level 3)
          Column(
            children: parts.map((partName) {
              final exercises = widget.group.getExercisesForPart(partName);
              final isExpanded = _expandedPart == partName;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    // Part Header Row
                    InkWell(
                      onTap: () {
                        setState(() {
                          _expandedPart = isExpanded ? null : partName;
                        });
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_down_rounded
                                  : Icons.keyboard_arrow_right_rounded,
                              size: 18,
                              color: subColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                partName,
                                style: GoogleFonts.plusJakartaSans(
                                  color: titleColor,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF162344) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${exercises.length} exercises',
                                style: GoogleFonts.plusJakartaSans(
                                  color: subColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _showAddExerciseDialog(context, partName),
                              child: Icon(
                                Icons.add_circle_outline_rounded,
                                size: 18,
                                color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => workoutProvider.removePartFromGroup(widget.group.id, partName),
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: subColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Expanded Exercise List (Level 3)
                    if (isExpanded)
                      Container(
                        padding: const EdgeInsets.only(left: 36, right: 12, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(color: borderColor, height: 1),
                            const SizedBox(height: 8),
                            if (exercises.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  'No exercises added yet. Tap (+) to add.',
                                  style: GoogleFonts.plusJakartaSans(color: subColor, fontSize: 11),
                                ),
                              )
                            else
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: exercises.map((exName) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF162344) : const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          exName,
                                          style: GoogleFonts.plusJakartaSans(
                                            color: titleColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        InkWell(
                                          onTap: () => workoutProvider.removeExerciseFromPart(
                                              widget.group.id, partName, exName),
                                          child: Icon(
                                            Icons.close_rounded,
                                            size: 12,
                                            color: subColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          // Add Muscle Button
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AddMuscleDialog(
                  groupId: widget.group.id,
                  groupName: widget.group.name,
                ),
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 16,
                    color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Add Body Part',
                    style: GoogleFonts.plusJakartaSans(
                      color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
