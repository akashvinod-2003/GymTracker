import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GymTrackerApp());
    expect(find.byType(GymTrackerApp), findsOneWidget);
  });
}
