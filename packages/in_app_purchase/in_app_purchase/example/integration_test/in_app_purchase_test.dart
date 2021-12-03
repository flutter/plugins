// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can create InAppPurchase instance', (WidgetTester tester) async {
    final InAppPurchase iapInstance = InAppPurchase.instance;
    expect(iapInstance, isNotNull);
  });
}
