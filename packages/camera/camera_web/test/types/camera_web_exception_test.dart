// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_web/src/types/types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CameraWebException', () {
    test('sets all properties', () {
      final cameraId = 1;
      final code = CameraErrorCode.notFound;
      final description = 'The camera is not found.';

      final exception = CameraWebException(cameraId, code, description);

      expect(exception.cameraId, equals(cameraId));
      expect(exception.code, equals(code));
      expect(exception.description, equals(description));
    });

    test('toString includes all properties', () {
      final cameraId = 2;
      final code = CameraErrorCode.notReadable;
      final description = 'The camera is not readable.';

      final exception = CameraWebException(cameraId, code, description);

      expect(
        exception.toString(),
        equals('CameraWebException($cameraId, $code, $description)'),
      );
    });
  });
}
