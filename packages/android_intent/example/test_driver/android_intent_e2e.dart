import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';

import 'package:android_intent_example/main.dart';

/// This is a smoke test that verifies that the example app builds and loads.
/// Because this plugin works by launching Android platform UIs it's not
/// possible to meaningfully test it through its Dart interface currently. There
/// are more useful unit tests for the platform logic under android/src/test/.
void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Embedding example app loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the new embedding example app builds
    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is Text && widget.data.startsWith('Tap here'),
      ),
      findsNWidgets(2),
    );
  });
}
