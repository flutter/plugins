// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camera_info.dart';
import 'package:camera_android_camerax/src/camera_selector.dart';
import 'package:camera_android_camerax/src/camerax_library.pigeon.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'camera_selector_test.mocks.dart';
import 'test_camerax_library.pigeon.dart';

@GenerateMocks(<Type>[TestCameraSelectorHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CameraInfo', () {
    tearDown(() => TestCameraSelectorHostApi.setup(null));

    test('requireLensFacingTest', () {
      final MockTestCameraSelectorHostApi mockApi =
          MockTestCameraSelectorHostApi();
      TestCameraSelectorHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final CameraSelector cameraSelector = CameraSelector.detached(
        instanceManager: instanceManager,
      );
      final CameraSelector modifiedCameraSelector = CameraSelector.detached(
          instanceManager: instanceManager,
          lensFacing: CameraSelector.LENS_FACING_BACK);

      instanceManager.addHostCreatedInstance(
        cameraSelector,
        0,
        onCopy: (_) => CameraSelector.detached(),
      );
      instanceManager.addHostCreatedInstance(
        modifiedCameraSelector,
        2,
        onCopy: (_) => CameraSelector.detached(
            lensFacing: CameraSelector.LENS_FACING_BACK),
      );

      when(mockApi.requireLensFacing(CameraSelector.LENS_FACING_BACK))
          .thenReturn(2);
      cameraSelector.requireLensFacing(CameraSelector.LENS_FACING_BACK);

      verify(mockApi.requireLensFacing(CameraSelector.LENS_FACING_BACK));
    });

    test('filterTest', () {
      final MockTestCameraSelectorHostApi mockApi =
          MockTestCameraSelectorHostApi();
      TestCameraSelectorHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final CameraSelector cameraSelector = CameraSelector.detached(
        instanceManager: instanceManager,
      );
      const int cameraInfoId = 3;
      final CameraInfo cameraInfo =
          CameraInfo.detached(instanceManager: instanceManager);

      instanceManager.addHostCreatedInstance(
        cameraSelector,
        0,
        onCopy: (_) => CameraSelector.detached(),
      );
      instanceManager.addHostCreatedInstance(
        cameraInfo,
        cameraInfoId,
        onCopy: (_) => CameraInfo.detached(),
      );

      when(mockApi.filter(instanceManager.getIdentifier(cameraSelector),
          <int>[cameraInfoId])).thenReturn(<int>[cameraInfoId]);
      cameraSelector.filter(<CameraInfo>[cameraInfo]);

      verify(mockApi.filter(0, <int>[cameraInfoId]));
    });

    test('flutterApiCreateTest', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final CameraSelectorFlutterApi flutterApi = CameraSelectorFlutterApiImpl(
        instanceManager: instanceManager,
      );

      flutterApi.create(0, CameraSelector.LENS_FACING_BACK);

      expect(instanceManager.getInstanceWithWeakReference(0),
          isA<CameraSelector>());
      expect(
          (instanceManager.getInstanceWithWeakReference(0)! as CameraSelector)
              .lensFacing,
          equals(CameraSelector.LENS_FACING_BACK));
    });
  });
}
