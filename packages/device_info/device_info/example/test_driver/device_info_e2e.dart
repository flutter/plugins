// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:device_info/device_info.dart';
import 'package:e2e/e2e.dart';
import 'package:device_info_linux/models/LinuxDeviceInfo.dart';
import 'package:device_info_linux/device_info_linux.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  IosDeviceInfo iosInfo;
  AndroidDeviceInfo androidInfo;
  LinuxDeviceInfo linuxInfo;

  setUpAll(() async {
    if (Platform.isIOS) {
      iosInfo = await DeviceInfoPlugin().iosInfo;
    } else if (Platform.isAndroid) {
      androidInfo = await DeviceInfoPlugin().androidInfo;
    } else if (Platform.isLinux) {
      linuxInfo = await DeviceInfoLinux().linuxInfo;
    }
  });

  testWidgets('Can get non-null device model', (WidgetTester tester) async {
    if (Platform.isIOS) {
      expect(iosInfo.model, isNotNull);
    } else if (Platform.isAndroid) {
      expect(androidInfo.model, isNotNull);
    } else if (Platform.isLinux) {
      expect(linuxInfo.os, isNotNull);
    }
  });
}

