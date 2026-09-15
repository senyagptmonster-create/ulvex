import 'package:flutter_test/flutter_test.dart';
import 'package:ulvex/main.dart';

void main() {
  testWidgets('UlvexApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UlvexApp());
    expect(find.text('ULVEX SOUND METER'), findsOneWidget);
    expect(find.text('DECIBELS (dBA)'), findsOneWidget);
  });
}
