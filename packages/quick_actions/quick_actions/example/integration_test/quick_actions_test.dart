// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quick_actions/quick_actions.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can set shortcuts', (WidgetTester tester) async {
    const QuickActions quickActions = QuickActions();
    await quickActions.initialize((String _) {});

    const ShortcutItem shortCutItem = ShortcutItem(
      type: 'action_one',
      localizedTitle: 'Action one',
      icon: 'AppIcon',
    );
    expect(
        quickActions.setShortcutItems(<ShortcutItem>[shortCutItem]), completes);
  });
}
