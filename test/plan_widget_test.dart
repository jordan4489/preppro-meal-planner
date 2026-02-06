import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preppro/features/plan/plan_page.dart';

void main(){
  // Skipped: depends on async services; enable with proper mocks.
  testWidgets('Generate without profile shows set goal message', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PlanPage()));
    await tester.pumpAndSettle();

    expect(find.text('Generate plan'), findsOneWidget);

    // Call the private generate method directly on state to ensure behavior
    // Tap the generate button and expect a SnackBar to be displayed
    await tester.tap(find.text('Generate plan'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  }, skip: true);
}
