// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camerax_library.pigeon.dart';
import 'package:camera_android_camerax/src/camera_info.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/process_camera_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'process_camera_provider_test.mocks.dart';
import 'test_camerax_library.pigeon.dart';

@GenerateMocks(<Type>[TestProcessCameraProviderHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProcessCameraProvider', () {
    tearDown(() => TestCameraSelectorHostApi.setup(null));

    test('getInstanceTest', () {
      final MockTestProcessCameraProviderHostApi mockApi =
          MockTestProcessCameraProviderHostApi();
      TestProcessCameraProviderHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      instanceManager.addHostCreatedInstance(
        ProcessCameraProvider.detached(),
        0,
        onCopy: (_) => ProcessCameraProvider.detached(),
      );
      when(mockApi.getInstance()).thenAnswer((_) async => 0);
      ProcessCameraProvider.getInstance(instanceManager: instanceManager);

      verify(mockApi.getInstance());
    });

    test('getAvailableCameraInfosTest', () {
      final MockTestProcessCameraProviderHostApi mockApi =
          MockTestProcessCameraProviderHostApi();
      TestProcessCameraProviderHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final ProcessCameraProvider processCameraProvider =
          ProcessCameraProvider.detached();

      instanceManager.addHostCreatedInstance(
        processCameraProvider,
        0,
        onCopy: (_) => ProcessCameraProvider.detached(),
      );
      instanceManager.addHostCreatedInstance(
        CameraInfo.detached(),
        1,
        onCopy: (_) => CameraInfo.detached(),
      );

      when(mockApi.getAvailableCameraInfos(0)).thenReturn(<int>[1]);
      processCameraProvider.getAvailableCameraInfos(
          instanceManager: instanceManager);

      verify(mockApi.getAvailableCameraInfos(
          0)); // TODO(camillesimon): ensure evaluation is correct
    });

    test('flutterApiCreateTest', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final ProcessCameraProviderFlutterApi flutterApi =
          ProcessCameraProviderFlutterApiImpl(
        instanceManager: instanceManager,
      );

      flutterApi.create(0);

      expect(instanceManager.getInstanceWithWeakReference(0),
          isA<ProcessCameraProvider>());
    });
  });
}
