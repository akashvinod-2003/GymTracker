import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Rolling monthly purge logic correctly preserves baseline starting month', () {
    const String baselineMonth = '2025-01'; // Year 1 Month 1 (Permanent Starting Month)

    // Current time: Year 2 Month 3 (2026-03)
    const currentYear = 2026;
    const currentMonth = 3;

    // Rolling 1-year cutoff (12 months ago):
    final cutoffYear = currentYear - 1; // 2025
    final cutoffMonth = currentMonth.toString().padLeft(2, '0'); // 03
    final cutoffMonthKey = '$cutoffYear-$cutoffMonth'; // "2025-03"

    final testSessions = [
      '2025-01-10', // Year 1 Month 1 (Baseline) -> MUST BE PRESERVED
      '2025-01-25', // Year 1 Month 1 (Baseline) -> MUST BE PRESERVED
      '2025-02-14', // Year 1 Month 2 -> Older than 2025-03 -> PURGED
      '2025-03-05', // Year 1 Month 3 -> Reached 1 year (<= 2025-03) -> PURGED
      '2025-04-12', // Year 1 Month 4 -> Less than 1 year (> 2025-03) -> KEPT
      '2025-12-20', // Year 1 Month 12 -> Less than 1 year -> KEPT
      '2026-01-15', // Year 2 Month 1 -> Less than 1 year -> KEPT
      '2026-02-18', // Year 2 Month 2 -> Less than 1 year -> KEPT
      '2026-03-01', // Year 2 Month 3 -> Current Month -> KEPT
    ];

    final preserved = <String>[];
    final purged = <String>[];

    for (var dateStr in testSessions) {
      final sessionMonth = dateStr.substring(0, 7);

      // Rule 1: Baseline Month is permanent
      if (sessionMonth == baselineMonth) {
        preserved.add(dateStr);
        continue;
      }

      // Rule 2: Rolling purge for months reached 1 year ago
      if (sessionMonth.compareTo(cutoffMonthKey) <= 0) {
        purged.add(dateStr);
      } else {
        preserved.add(dateStr);
      }
    }

    // Assert baseline month is preserved
    expect(preserved.contains('2025-01-10'), isTrue);
    expect(preserved.contains('2025-01-25'), isTrue);

    // Assert Month 2 and Month 3 of Year 1 are purged
    expect(purged.contains('2025-02-14'), isTrue);
    expect(purged.contains('2025-03-05'), isTrue);

    // Assert Month 4 and newer are kept
    expect(preserved.contains('2025-04-12'), isTrue);
    expect(preserved.contains('2025-12-20'), isTrue);
    expect(preserved.contains('2026-03-01'), isTrue);
  });
}
