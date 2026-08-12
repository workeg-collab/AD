import 'package:flutter_test/flutter_test.dart';
import 'package:ad_landing/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ADApp());
    expect(find.byType(ADApp), findsOneWidget);
  });
}
