// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:e2e/e2e.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can create InAppPurchaseConnection instance',
      (WidgetTester tester) async {
    final InAppPurchaseConnection connection = InAppPurchaseConnection.instance;
    expect(connection, isNotNull);
  });
}
