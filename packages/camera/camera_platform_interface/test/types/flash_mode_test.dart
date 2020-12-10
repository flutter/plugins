// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FlashMode should contain 3 options', () {
    final values = FlashMode.values;

    expect(values.length, 3);
  });

  test("FlashMode enum should have items in correct index", () {
    final values = FlashMode.values;

    expect(values[0], FlashMode.off);
    expect(values[1], FlashMode.auto);
    expect(values[2], FlashMode.always);
  });
}
