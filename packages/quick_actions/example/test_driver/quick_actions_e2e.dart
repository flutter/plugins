
// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';
import 'package:quick_actions/quick_actions.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can initialize', (WidgetTester tester) async {
    final QuickActions quickActions = QuickActions();
    Completer completer = Completer<>();
    quickActions.initialize(null);
  });
}