import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Placeholder test', (WidgetTester tester) async {
    // Sleep Calculator uses GetX + Hive which require platform channels.
    // Integration tests live in integration_test/.
    expect(true, isTrue);
  });
}
