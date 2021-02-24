import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ios_platform_images_example/main.dart';

void main() {
  testWidgets('Verify loads image', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that platform version is retrieved.
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Image && (Platform.isIOS ? widget.image != null : true),
      ),
      findsOneWidget,
    );
  });
}
