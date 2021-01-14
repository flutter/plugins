// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pathproviderexample/main.dart';

void main() {
  group('Test linux path provider example', () {
    setUpAll(() async {
      await WidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('Finds tmp directory', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.runAsync(() async {
        await tester.pumpWidget(MyApp());
        await Future.delayed(Duration(milliseconds: 20));
        await tester.pump();

        // Verify that temporary directory is retrieved.
        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is Text &&
                widget.data.startsWith('Temp Directory: /tmp'),
          ),
          findsOneWidget,
        );
      });
    });
    testWidgets('Finds documents directory', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.runAsync(() async {
        await tester.pumpWidget(MyApp());
        await Future.delayed(Duration(milliseconds: 20));
        await tester.pump();

        // Verify that documents directory is retrieved.
        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is Text &&
                widget.data.startsWith('Documents Directory: /'),
          ),
          findsOneWidget,
        );
      });
    });
    testWidgets('Finds downloads directory', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.runAsync(() async {
        await tester.pumpWidget(MyApp());
        await Future.delayed(Duration(milliseconds: 20));
        await tester.pump();

        // Verify that downloads directory is retrieved.
        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is Text &&
                widget.data.startsWith('Downloads Directory: /'),
          ),
          findsOneWidget,
        );
      });
    });
    testWidgets('Finds application support directory',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.runAsync(() async {
        await tester.pumpWidget(MyApp());
        await Future.delayed(Duration(milliseconds: 20));
        await tester.pump();

        // Verify that Application Support Directory is retrieved.
        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is Text &&
                widget.data.startsWith('Application Support Directory: /'),
          ),
          findsOneWidget,
        );
      });
    });
  });
}
