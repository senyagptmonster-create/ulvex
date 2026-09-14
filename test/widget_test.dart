import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ulvex/product/product_app.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProductApp()));
    expect(find.byType(ProductApp), findsOneWidget);
  });
}