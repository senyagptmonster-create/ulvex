import 'package:flutter_test/flutter_test.dart';
import 'package:ulvex/ulvex_app.dart';

void main() {
  testWidgets('UlvexMeterApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UlvexMeterApp());
    expect(find.byType(UlvexMeterApp), findsOneWidget);
  });
}