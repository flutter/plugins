// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';

import 'package:e2e_example/main.dart' as app;

// Tests the failure behavior of the E2EWidgetsFlutterBinding
//
// This test fails intentionally! It should be run using a test runner that
// expects failure.
void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('success', (WidgetTester tester) async {
    expect(1 + 1, 2); // This should pass
  });

  testWidgets('failure 1', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    app.main();

    // Verify that platform version is retrieved.
    await expectLater(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Text && widget.data.startsWith('This should fail'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('failure 2', (WidgetTester tester) async {
    expect(1 + 1, 3); // This should fail
  });
}
