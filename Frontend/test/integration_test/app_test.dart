import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:namer_app/main_test.dart' as app; // Use the testing entry point

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    app.main();
    await tester.pumpAndSettle(); // Wait for the widget tree to stabilize

    // Debugging: Print the widget tree to verify its structure
    debugDumpApp();

    // Verify that the counter starts at 0
    expect(find.text('0'), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle(); // Wait for the widget tree to stabilize after the tap

    // Verify that the counter has incremented to 1
    expect(find.text('1'), findsOneWidget);
  });
}