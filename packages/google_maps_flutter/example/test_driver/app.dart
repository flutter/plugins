// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:google_maps_flutter_example/main.dart' as app;

final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

Future<String> modelString(String message) async {
  if (message != "modelName") {
    throw Exception('Unknown message: $message');
  }
  if (Platform.isAndroid) {
    final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
    return androidInfo.model;
  } else if (Platform.isIOS) {
    final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
    return iosInfo.model;
  } else {
    return Platform.operatingSystem;
  }
}

void main() {
  enableFlutterDriverExtension(handler: modelString);
  app.main();
}
