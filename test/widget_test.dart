// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:preppro/main.dart';

void main() {
  testWidgets('App loads and shows Quick actions and suggested recipes', (WidgetTester tester) async {
    await tester.pumpWidget(const PrepProApp());
    await tester.pumpAndSettle();

    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.text('Suggested recipes'), findsOneWidget);
  });
}
