import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:result_analysis_app/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app inside a test Material context.
    await tester.pumpWidget(const MaterialApp(
      home: VVCollegeApp(),
    ));

    // Wait for all widgets to settle.
    await tester.pumpAndSettle();

    // Verify that the login page title is visible.
    expect(find.textContaining('V V College'), findsOneWidget);

    // Verify that Login button is visible.
    expect(find.text('Login'), findsOneWidget);
  });
}
