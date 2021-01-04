// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DeviceOrientation should contain 4 options', () {
    final values = DeviceOrientation.values;

    expect(values.length, 4);
  });

  test("DeviceOrientation enum should have items in correct index", () {
    final values = DeviceOrientation.values;

    expect(values[0], DeviceOrientation.portrait);
    expect(values[1], DeviceOrientation.portraitUpsideDown);
    expect(values[2], DeviceOrientation.landscapeRight);
    expect(values[3], DeviceOrientation.landscapeLeft);
  });

  test("serializeDeviceOrientation() should serialize correctly", () {
    expect(serializeDeviceOrientation(DeviceOrientation.portrait), "portrait");
    expect(serializeDeviceOrientation(DeviceOrientation.portraitUpsideDown),
        "portraitUpsideDown");
    expect(serializeDeviceOrientation(DeviceOrientation.landscapeRight),
        "landscapeRight");
    expect(serializeDeviceOrientation(DeviceOrientation.landscapeLeft),
        "landscapeLeft");
  });

  test("deserializeDeviceOrientation() should deserialize correctly", () {
    expect(
        deserializeDeviceOrientation('portrait'), DeviceOrientation.portrait);
    expect(deserializeDeviceOrientation('portraitUpsideDown'),
        DeviceOrientation.portraitUpsideDown);
    expect(deserializeDeviceOrientation('landscapeRight'),
        DeviceOrientation.landscapeRight);
    expect(deserializeDeviceOrientation('landscapeLeft'),
        DeviceOrientation.landscapeLeft);
  });
}
