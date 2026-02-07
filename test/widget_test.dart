import 'package:flutter_test/flutter_test.dart';
import 'package:wordle_game/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WordleApp());
    expect(find.text('WORDLE'), findsOneWidget);
  });
}
