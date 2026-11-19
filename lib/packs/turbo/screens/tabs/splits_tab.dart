import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:gym_tracker/models/split_group.dart';
import 'package:gym_tracker/providers/theme_provider.dart';
import 'package:gym_tracker/providers/workout_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/add_muscle_dialog.dart';
import '../../widgets/add_split_dialog.dart';
import 'package:gym_tracker/widgets/edit_split_dialog.dart';

class SplitsTab extends StatelessWidget {
  const SplitsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    final cardBg = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subColor = isDark ? AppTheme.darkTextSecondary : AppTheme.n550;

    final groups = workoutProvider.splitGroups;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 140),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
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
                            'Splits & Exercises',
                            style: GoogleFonts.interTight(
                              color: titleColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
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
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.n850 : AppTheme.n050,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark ? AppTheme.n700 : AppTheme.n200,
                                  ),
                                ),
                                child: Icon(
                                  Icons.delete_sweep_sharp,
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
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppTheme.turbo,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.create_new_folder_sharp,
                                size: 19,
                                color: Colors.white,
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
                  '3-tier training catalog: Split Group → Body Part → Specific Exercise Movements.',
                  style: GoogleFonts.inter(
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
                            color: isDark ? AppTheme.n800 : AppTheme.n050,
                            borderRadius: BorderRadius.circular(10),
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
                        color: isDark ? AppTheme.n800.withValues(alpha: 0.4) : AppTheme.n050,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.fitness_center_sharp,
                            size: 44,
                            color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No Split Groups Yet',
                            style: GoogleFonts.interTight(
                              color: titleColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Create a split group, then add body parts and exercises to build your own training library.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
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
                            icon: const Icon(Icons.add_sharp, size: 18),
                            label: const Text('Create First Split Group'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.turbo,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Delete All Split Groups?',
          style: GoogleFonts.interTight(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'This will remove all split groups, muscle parts, and exercise templates so you can build your own library completely from scratch.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.n550,
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    final current = widget.group.effectiveShortName;
    final initialText = current == 'UPP' ? 'UP' : current;
    final controller = TextEditingController(text: initialText);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(
              Icons.short_text_sharp,
              color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Edit Abbreviation',
                style: GoogleFonts.interTight(fontSize: 16, fontWeight: FontWeight.w800),
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
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.n550,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 8,
              textCapitalization: TextCapitalization.characters,
              style: GoogleFonts.interTight(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Abbreviation',
                hintText: 'e.g. UP, PUSH, LEG',
                counterText: '',
                filled: true,
                fillColor: isDark ? AppTheme.n800 : AppTheme.n050,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                }
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.turbo,
              foregroundColor: Colors.white,
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
        backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Add Exercise to $partName',
          style: GoogleFonts.interTight(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. Incline Dumbbell Press',
            hintStyle: GoogleFonts.inter(fontSize: 13),
            filled: true,
            fillColor: isDark ? AppTheme.n800 : AppTheme.n050,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
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
              backgroundColor: AppTheme.turbo,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmRemovePart(BuildContext context, WorkoutProvider provider, String partName, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Remove $partName?',
          style: GoogleFonts.interTight(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'This removes $partName and its exercises from ${widget.group.name}.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.removePartFromGroup(widget.group.id, partName);
              if (_expandedPart == partName) setState(() => _expandedPart = null);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);

    final cardBg = isDark ? AppTheme.n800 : AppTheme.n050;
    final borderColor = isDark ? AppTheme.n800 : AppTheme.n150;
    final badgeBg = isDark ? AppTheme.n800 : AppTheme.lightCard;
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subColor = isDark ? AppTheme.darkTextSecondary : AppTheme.n550;

    final pastel = AppTheme.pastelStyles[widget.index % AppTheme.pastelStyles.length];
    final initials = widget.group.effectiveShortName;

    final parts = widget.group.partNames;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tooltip(
                message: 'Tap to edit abbreviation',
                child: InkWell(
                  onTap: () => _showEditAbbreviationDialog(context, workoutProvider, isDark),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: pastel.bg(isDark),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: pastel.border(isDark)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.interTight(
                        color: pastel.text(isDark),
                        fontSize: 11.5,
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
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Text(
                          widget.group.name,
                          style: GoogleFonts.interTight(
                            color: titleColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Tooltip(
                          message: 'Tap to edit abbreviation',
                          child: InkWell(
                            onTap: () => _showEditAbbreviationDialog(context, workoutProvider, isDark),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.t800 : AppTheme.tealBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isDark ? AppTheme.t300 : AppTheme.t050,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.group.effectiveShortName,
                                    style: GoogleFonts.interTight(
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
                    const SizedBox(height: 3),
                    Text(
                      '${parts.length} body part${parts.length == 1 ? '' : 's'} configured',
                      style: GoogleFonts.inter(
                        color: subColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                      padding: const EdgeInsets.all(5),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(width: 2),
                  // Delete Split
                  Tooltip(
                    message: 'Delete Split',
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline_sharp, size: 19),
                      color: isDark ? Colors.redAccent.shade100 : Colors.red.shade400,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            title: Text(
                              'Delete ${widget.group.name}?',
                              style: GoogleFonts.interTight(fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            content: Text(
                              'This will delete the split group and all exercise movements under it.',
                              style: GoogleFonts.inter(
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
                      padding: const EdgeInsets.all(5),
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
                      color: isDark ? AppTheme.t800 : AppTheme.tealBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark ? AppTheme.t300 : AppTheme.t050,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_sharp,
                          size: 11,
                          color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.group.days.join(', '),
                            style: GoogleFonts.inter(
                              color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (widget.group.defaultSets > 0)
                  Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.n800 : AppTheme.n050,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${widget.group.defaultSets} sets × ${widget.group.defaultReps} reps',
                    style: GoogleFonts.inter(
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
              style: GoogleFonts.inter(
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
                  borderRadius: BorderRadius.circular(10),
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
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_down_sharp
                                  : Icons.keyboard_arrow_right_sharp,
                              size: 18,
                              color: subColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                partName,
                                style: GoogleFonts.interTight(
                                  color: titleColor,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.n800 : AppTheme.n050,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${exercises.length} exercise${exercises.length == 1 ? '' : 's'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    color: subColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Tooltip(
                              message: 'Add exercise',
                              child: InkWell(
                                onTap: () => _showAddExerciseDialog(context, partName),
                                customBorder: const CircleBorder(),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.add_circle_outline_sharp,
                                    size: 20,
                                    color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Tooltip(
                              message: 'Remove body part',
                              child: InkWell(
                                onTap: () => _confirmRemovePart(context, workoutProvider, partName, isDark),
                                customBorder: const CircleBorder(),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.close_sharp,
                                    size: 18,
                                    color: subColor,
                                  ),
                                ),
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
                                  style: GoogleFonts.inter(color: subColor, fontSize: 11),
                                ),
                              )
                            else
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: exercises.map((exName) {
                                  return Container(
                                    padding: const EdgeInsets.only(left: 8, right: 2, top: 1, bottom: 1),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppTheme.n800 : AppTheme.n050,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            exName,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              color: titleColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        InkWell(
                                          onTap: () => workoutProvider.removeExerciseFromPart(
                                              widget.group.id, partName, exName),
                                          customBorder: const CircleBorder(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Icon(
                                              Icons.close_sharp,
                                              size: 14,
                                              color: subColor,
                                            ),
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
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_sharp,
                    size: 16,
                    color: isDark ? AppTheme.tealLight : AppTheme.tealPrimary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Add Body Part',
                    style: GoogleFonts.inter(
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
