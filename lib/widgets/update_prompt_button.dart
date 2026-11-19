import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/pwa_update_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class UpdatePromptButton extends StatelessWidget {
  final bool compact;

  const UpdatePromptButton({
    super.key,
    this.compact = false,
  });

  void _confirmAndApplyUpdate(BuildContext context, PwaUpdateProvider pwaProvider, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF332009) : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.system_update_rounded, color: Color(0xFFF59E0B), size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              'Update Available',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Text(
          'A newer version of PulseFit is available. Would you like to refresh and apply the update now? Your logged workouts and splits are safely saved.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later'),
          ),
          ElevatedButton.icon(
            onPressed: pwaProvider.isUpdating
                ? null
                : () async {
                    Navigator.pop(ctx);
                    await pwaProvider.applyUpdate();
                  },
            icon: pwaProvider.isUpdating
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : const Icon(Icons.refresh_rounded, size: 16),
            label: Text(pwaProvider.isUpdating ? 'Updating...' : 'Update Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pwaProvider = Provider.of<PwaUpdateProvider>(context);

    // If no update is available, do not display the button
    if (!pwaProvider.isUpdateAvailable) {
      return const SizedBox.shrink();
    }

    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);

    if (compact) {
      return Tooltip(
        message: 'New update available! Tap to reload app.',
        child: InkWell(
          onTap: () => _confirmAndApplyUpdate(context, pwaProvider, isDark),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF332009) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (pwaProvider.isUpdating)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFFF59E0B)),
                  )
                else
                  const Icon(Icons.system_update_rounded, color: Color(0xFFF59E0B), size: 14),
                const SizedBox(width: 5),
                Text(
                  pwaProvider.isUpdating ? 'Updating...' : 'Update App',
                  style: GoogleFonts.plusJakartaSans(
                    color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF291804) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.system_update_rounded, color: Color(0xFFF59E0B), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Update Available',
                  style: GoogleFonts.plusJakartaSans(
                    color: isDark ? Colors.white : const Color(0xFF92400E),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'A newer version of the web app is ready.',
                  style: GoogleFonts.plusJakartaSans(
                    color: isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: pwaProvider.isUpdating
                ? null
                : () => _confirmAndApplyUpdate(context, pwaProvider, isDark),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(
              pwaProvider.isUpdating ? 'Updating...' : 'Update',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
