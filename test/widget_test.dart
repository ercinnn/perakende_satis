import 'package:flutter_test/flutter_test.dart';
import 'package:perakende_satis/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Ana Sayfa'), findsOneWidget);
  });
}