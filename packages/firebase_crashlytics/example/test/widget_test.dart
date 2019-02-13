// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_crashlytics_example/main.dart';

void main() {
  testWidgets('Verify displayed buttons', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that buttons are displayed.
    expect(
      find.widgetWithText(FlatButton, 'Log'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(FlatButton, 'Key'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(FlatButton, 'Crash'),
      findsOneWidget,
    );
  });
}
