// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('$WifiInfo test driver', () {
    late WifiInfo _wifiInfo;

    setUpAll(() async {
      _wifiInfo = WifiInfo();
    });

    testWidgets('test location methods, iOS only', (WidgetTester tester) async {
      expect(
        (await _wifiInfo.getLocationServiceAuthorization()),
        LocationAuthorizationStatus.notDetermined,
      );
    }, skip: !Platform.isIOS);
  });
}
