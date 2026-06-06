import 'package:flutter_test/flutter_test.dart';
import 'package:water_tracker/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const RainDropApp());
    expect(find.text('RainDrop'), findsOneWidget);
  });
}
