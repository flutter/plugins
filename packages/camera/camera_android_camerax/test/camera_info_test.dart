// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camera_info.dart';
import 'package:camera_android_camerax/src/camerax_library.pigeon.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'camera_info_test.mocks.dart';
import 'test_camerax_library.pigeon.dart';

@GenerateMocks(<Type>[TestCameraInfoHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CameraInfo', () {
    tearDown(() => TestCameraInfoHostApi.setup(null));

    test('getSensorRotationDegreesTest', () async {
      final MockTestCameraInfoHostApi mockApi = MockTestCameraInfoHostApi();
      TestCameraInfoHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final CameraInfo cameraInfo = CameraInfo.detached(
        instanceManager: instanceManager,
      );
      instanceManager.addHostCreatedInstance(
        cameraInfo,
        0,
        onCopy: (_) => CameraInfo.detached(),
      );

      when(mockApi.getSensorRotationDegrees(
              instanceManager.getIdentifier(cameraInfo)))
          .thenReturn(90);
      expect(await cameraInfo.getSensorRotationDegrees(), equals(90));

      verify(mockApi.getSensorRotationDegrees(0));
    });

    test('flutterApiCreateTest', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final CameraInfoFlutterApi flutterApi = CameraInfoFlutterApiImpl(
        instanceManager: instanceManager,
      );

      flutterApi.create(0);

      expect(
          instanceManager.getInstanceWithWeakReference(0), isA<CameraInfo>());
    });
  });
}
