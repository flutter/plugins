// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity/connectivity.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Connectivity test driver', () {
    Connectivity _connectivity;

    setUpAll(() async {
      _connectivity = Connectivity();
    });

    testWidgets('test connectivity result', (WidgetTester tester) async {
      final ConnectivityResult result = await _connectivity.checkConnectivity();
      expect(result, isNotNull);
    });

    testWidgets('test onConnectivityChanged', (WidgetTester tester) async {
      final subscription =
          _connectivity.onConnectivityChanged.listen((event) { });
      expect(subscription, isNotNull);
      await subscription.cancel();
    });
  });
}
