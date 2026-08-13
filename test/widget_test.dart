import 'package:flutter_test/flutter_test.dart';
import 'package:sa_landing/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SAApp());
    expect(find.byType(SAApp), findsOneWidget);
  });
}
