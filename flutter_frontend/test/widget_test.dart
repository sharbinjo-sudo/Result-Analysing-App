import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:result_analysis_app/screens/login_page.dart';

void main() {
  testWidgets('Login screen renders key fields', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.pump();

    expect(find.text('V V College of Engineering'), findsOneWidget);
    expect(find.text('Result and Analysis Portal'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Login'), findsOneWidget);
  });
}
