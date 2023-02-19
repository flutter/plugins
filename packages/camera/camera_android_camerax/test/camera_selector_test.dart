// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camera_info.dart';
import 'package:camera_android_camerax/src/camera_selector.dart';
import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'camera_selector_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[TestCameraSelectorHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CameraSelector', () {
    tearDown(() => TestCameraSelectorHostApi.setup(null));

    test('detachedCreateTest', () async {
      final MockTestCameraSelectorHostApi mockApi =
          MockTestCameraSelectorHostApi();
      TestCameraSelectorHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      CameraSelector.detached(
        instanceManager: instanceManager,
      );

      verifyNever(mockApi.create(argThat(isA<int>()), null));
    });

    test('createTestWithoutLensSpecified', () async {
      final MockTestCameraSelectorHostApi mockApi =
          MockTestCameraSelectorHostApi();
      TestCameraSelectorHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      CameraSelector(
        instanceManager: instanceManager,
      );

      verify(mockApi.create(argThat(isA<int>()), null));
    });

    test('createTestWithLensSpecified', () async {
      final MockTestCameraSelectorHostApi mockApi =
          MockTestCameraSelectorHostApi();
      TestCameraSelectorHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      CameraSelector(
          instanceManager: instanceManager,
          lensFacing: CameraSelector.lensFacingBack);

      verify(
          mockApi.create(argThat(isA<int>()), CameraSelector.lensFacingBack));
    });

    test('filterTest', () async {
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
      expect(await cameraSelector.filter(<CameraInfo>[cameraInfo]),
          equals(<CameraInfo>[cameraInfo]));

      verify(mockApi.filter(0, <int>[cameraInfoId]));
    });

    test('flutterApiCreateTest', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final CameraSelectorFlutterApi flutterApi = CameraSelectorFlutterApiImpl(
        instanceManager: instanceManager,
      );

      flutterApi.create(0, CameraSelector.lensFacingBack);

      expect(instanceManager.getInstanceWithWeakReference(0),
          isA<CameraSelector>());
      expect(
          (instanceManager.getInstanceWithWeakReference(0)! as CameraSelector)
              .lensFacing,
          equals(CameraSelector.lensFacingBack));
    });
  });
}
