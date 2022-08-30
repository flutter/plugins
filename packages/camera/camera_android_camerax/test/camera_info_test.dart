// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camera_info.dart';
import 'package:camera_android_camerax/src/camerax_library.pigeon.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';

import 'camera_info_test.mocks.dart';
import 'test_camerax_library.pigeon.dart';

@GenerateMocks(<Type>[TestCameraInfoHostApi])
void main() {
  TextWidgetsFlutterBinding.ensureInitialized();

  group('CameraInfo', () {
    tearDown(() => TestCameraInfoHostApi.setup(null));

    test('getSensorRotationDegreesTest', () {
      final MockTestCameraInfoHostApi mockApi = MockTestCameraInfoHostApi();
      TestCameraInfoHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      // Create a MyClass instance and add to the instanceManager with
      // identifier = 1.
      final CameraInfo cameraInfo = CameraInfo.detached(
        instanceManager: instanceManager,
      );
      instanceManager.addHostCreatedInstance(
        cameraInfo,
        0,
        onCopy: (_) => CameraInfo.detached(),
      );

      // Call my method.
      cameraInfo.getSensorRotationDegrees();

      // Verify mock host api received the correct values.
      verify(mockApi.getSensorRotationDegrees(0, 'myMethodString'));
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
