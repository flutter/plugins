// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/src/types/focus_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FocusMode should contain 2 options', () {
    final values = FocusMode.values;

    expect(values.length, 2);
  });

  test("FocusMode enum should have items in correct index", () {
    final values = FocusMode.values;

    expect(values[0], FocusMode.continuous);
    expect(values[1], FocusMode.auto);
  });

  test("serializeFocusMode() should serialize correctly", () {
    expect(serializeFocusMode(FocusMode.continuous), "continuous");
    expect(serializeFocusMode(FocusMode.auto), "auto");
  });

  test("deserializeFocusMode() should deserialize correctly", () {
    expect(deserializeFocusMode('continuous'), FocusMode.continuous);
    expect(deserializeFocusMode('auto'), FocusMode.auto);
  });
}
