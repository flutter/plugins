// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:integration_test_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('verify text', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    app.main();

    // Trigger a frame.
    await tester.pumpAndSettle();

    final Finder finder = find.byKey(const Key('platform'));
    final Text platformText = tester.widget(finder);

    // Verify that platform is retrieved.
    expect(finder, findsOneWidget);
    expect(platformText.data, 'Platform: ${html.window.navigator.platform}\n');
  });

  testWidgets('verify event dispatching works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    app.main();

    // Trigger a frame.
    await tester.pumpAndSettle();

    final Finder finderButton = find.byKey(const Key('button'));
    expect(finderButton, findsOneWidget);

    final Offset offset = tester.getCenter(finderButton);

    dispatchEventToMouseLocation((offset.dx).toInt(), (offset.dy).toInt());
    await tester.pumpAndSettle();

    final Finder finder = find.byKey(const Key('counter'));
    final Text counter = tester.widget(finder);

    // Verify that counter is clicked.
    expect(finder, findsOneWidget);
    expect(counter.data, '1');
  });
}

void dispatchEventToMouseLocation(int mouseX, int mouseY) {
  final html.EventTarget target =
      html.document.elementFromPoint(mouseX, mouseY);

  dispatchPointerEvent(target, 'pointerdown', <String, dynamic>{
    'bubbles': true,
    'cancelable': true,
    'screenX': mouseX,
    'screenY': mouseY,
    'clientX': mouseX,
    'clientY': mouseY,
  });

  dispatchPointerEvent(target, 'pointerup', <String, dynamic>{
    'bubbles': true,
    'cancelable': true,
    'screenX': mouseX,
    'screenY': mouseY,
    'clientX': mouseX,
    'clientY': mouseY,
  });
}

html.PointerEvent dispatchPointerEvent(
    html.EventTarget target, String type, Map<String, dynamic> args) {
  final dynamic jsPointerEvent =
      js_util.getProperty(html.window, 'PointerEvent');
  final List<dynamic> eventArgs = <dynamic>[
    type,
    args,
  ];

  final html.PointerEvent event = js_util.callConstructor(
          jsPointerEvent, js_util.jsify(eventArgs) as List<dynamic>)
      as html.PointerEvent;
  target.dispatchEvent(event);

  return event;
}
