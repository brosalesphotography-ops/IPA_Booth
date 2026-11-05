
import 'package:flutter_test/flutter_test.dart';
import 'package:palomitopty_snap/main.dart';

void main() {
  testWidgets('PALOMITOPTY SNAP inicia correctamente',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PalomitoptySnap());

    expect(find.text('PALOMITOPTY'), findsOneWidget);
  });
}
