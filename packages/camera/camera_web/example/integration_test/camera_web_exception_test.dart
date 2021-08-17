// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_web/src/types/types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('CameraWebException', () {
    testWidgets('sets all properties', (tester) async {
      final cameraId = 1;
      final code = CameraErrorCode.notFound;
      final description = 'The camera is not found.';

      final exception = CameraWebException(cameraId, code, description);

      expect(exception.cameraId, equals(cameraId));
      expect(exception.code, equals(code));
      expect(exception.description, equals(description));
    });

    testWidgets('toString includes all properties', (tester) async {
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
