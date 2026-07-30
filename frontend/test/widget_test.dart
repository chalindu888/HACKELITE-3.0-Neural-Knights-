import 'package:flutter_test/flutter_test.dart';
import 'package:medisense_ai/main.dart';

void main() {
  testWidgets('MediSenseApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MediSenseApp());
    expect(find.byType(MediSenseApp), findsOneWidget);
  });
}
