// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_web/src/types/types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CameraMetadata', () {
    test('supports value equality', () {
      expect(
        CameraMetadata(
          deviceId: 'deviceId',
          facingMode: 'environment',
        ),
        equals(
          CameraMetadata(
            deviceId: 'deviceId',
            facingMode: 'environment',
          ),
        ),
      );
    });
  });
}
