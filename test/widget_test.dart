// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:vision_iq_project/main.dart';

void main() {
  testWidgets('Vision IQ app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VisionIQApp());

    // Verify that the app loads with proper title
    expect(find.text('Vision IQ'), findsOneWidget);

    // Verify that the main sections are present
    expect(find.text('Intelligent Background Verification'), findsOneWidget);
    expect(find.text('Start Analysis'), findsOneWidget);
  });

  testWidgets('Navigation test', (WidgetTester tester) async {
    await tester.pumpWidget(const VisionIQApp());

    // Find and tap the background verification button
    final backgroundVerificationButton = find.text('Background Verification');
    expect(backgroundVerificationButton, findsOneWidget);

    await tester.tap(backgroundVerificationButton);
    await tester.pumpAndSettle();

    // Verify navigation to background verification page
    expect(find.text('Background Verification'), findsOneWidget);
  });
}
