import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perakende_satis/main.dart' as app;

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: app.MyApp()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}