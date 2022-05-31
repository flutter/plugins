// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can create InAppPurchaseStoreKit instance',
      (WidgetTester tester) async {
    InAppPurchaseStoreKitPlatform.registerPlatform();
    final InAppPurchasePlatform androidPlatform =
        InAppPurchasePlatform.instance;
    expect(androidPlatform, isNotNull);
  });
}
