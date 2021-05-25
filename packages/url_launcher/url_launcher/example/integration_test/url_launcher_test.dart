// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('canLaunch', (WidgetTester _) async {
    expect(await canLaunch('randomstring'), false);

    // Generally all devices should have some default browser.
    expect(await canLaunch('http://flutter.dev'), true);

    // SMS handling is available by default on most platforms.
    if (kIsWeb || !(Platform.isLinux || Platform.isWindows)) {
      expect(await canLaunch('sms:5555555555'), true);
    }

    // tel: and mailto: links may not be openable on every device. iOS
    // simulators notably can't open these link types.
  });
}
