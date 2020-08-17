// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:device_info_platform_interface/device_info_platform_interface.dart';

import 'package:device_info_platform_interface/method_channel/method_channel_device_info.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("$MethodChannelDeviceInfo", () {
    MethodChannelDeviceInfo methodChannelDeviceInfo;

    setUp(() async {
      methodChannelDeviceInfo = MethodChannelDeviceInfo();

      methodChannelDeviceInfo.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getAndroidDeviceInfo':
            return ({
              "brand": "Google",
            });
          case 'getIosDeviceInfo':
            return ({
              "name": "iPhone 10",
            });
          default:
            return null;
        }
      });
    });

    test("androidInfo", () async {
      final AndroidDeviceInfo result =
          await methodChannelDeviceInfo.androidInfo();
      expect(result.brand, "Google");
    });

    test("iosInfo", () async {
      final IosDeviceInfo result = await methodChannelDeviceInfo.iosInfo();
      expect(result.name, "iPhone 10");
    });
  });
}
