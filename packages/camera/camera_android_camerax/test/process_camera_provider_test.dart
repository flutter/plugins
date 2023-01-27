// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camera.dart';
import 'package:camera_android_camerax/src/camera_info.dart';
import 'package:camera_android_camerax/src/camera_selector.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/process_camera_provider.dart';
import 'package:camera_android_camerax/src/use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'process_camera_provider_test.mocks.dart';
import 'test_camerax_library.pigeon.dart';

@GenerateMocks(<Type>[TestProcessCameraProviderHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProcessCameraProvider', () {
    tearDown(() => TestProcessCameraProviderHostApi.setup(null));

    test('getInstanceTest', () async {
      final MockTestProcessCameraProviderHostApi mockApi =
          MockTestProcessCameraProviderHostApi();
      TestProcessCameraProviderHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final ProcessCameraProvider processCameraProvider =
          ProcessCameraProvider.detached(
        instanceManager: instanceManager,
      );

      instanceManager.addHostCreatedInstance(
        processCameraProvider,
        0,
        onCopy: (_) => ProcessCameraProvider.detached(),
      );

      when(mockApi.getInstance()).thenAnswer((_) async => 0);
      expect(
          await ProcessCameraProvider.getInstance(
              instanceManager: instanceManager),
          equals(processCameraProvider));
      verify(mockApi.getInstance());
    });

    test('getAvailableCameraInfosTest', () async {
      final MockTestProcessCameraProviderHostApi mockApi =
          MockTestProcessCameraProviderHostApi();
      TestProcessCameraProviderHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final ProcessCameraProvider processCameraProvider =
          ProcessCameraProvider.detached(
        instanceManager: instanceManager,
      );

      instanceManager.addHostCreatedInstance(
        processCameraProvider,
        0,
        onCopy: (_) => ProcessCameraProvider.detached(),
      );
      final CameraInfo fakeAvailableCameraInfo =
          CameraInfo.detached(instanceManager: instanceManager);
      instanceManager.addHostCreatedInstance(
        fakeAvailableCameraInfo,
        1,
        onCopy: (_) => CameraInfo.detached(),
      );

      when(mockApi.getAvailableCameraInfos(0)).thenReturn(<int>[1]);
      expect(await processCameraProvider.getAvailableCameraInfos(),
          equals(<CameraInfo>[fakeAvailableCameraInfo]));
      verify(mockApi.getAvailableCameraInfos(0));
    });

    test('bindToLifecycleTest', () async {
      final MockTestProcessCameraProviderHostApi mockApi =
          MockTestProcessCameraProviderHostApi();
      TestProcessCameraProviderHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final ProcessCameraProvider processCameraProvider =
          ProcessCameraProvider.detached(
        instanceManager: instanceManager,
      );
      final CameraSelector fakeCameraSelector =
          CameraSelector.detached(instanceManager: instanceManager);
      final UseCase fakeUseCase =
          UseCase.detached(instanceManager: instanceManager);
      final Camera fakeCamera =
          Camera.detached(instanceManager: instanceManager);

      instanceManager.addHostCreatedInstance(
        processCameraProvider,
        0,
        onCopy: (_) => ProcessCameraProvider.detached(),
      );
      instanceManager.addHostCreatedInstance(
        fakeCameraSelector,
        1,
        onCopy: (_) => CameraSelector.detached(),
      );
      instanceManager.addHostCreatedInstance(
        fakeUseCase,
        2,
        onCopy: (_) => UseCase.detached(),
      );
      instanceManager.addHostCreatedInstance(
        fakeCamera,
        3,
        onCopy: (_) => Camera.detached(),
      );

      when(mockApi.bindToLifecycle(0, 1, <int>[2])).thenReturn(3);
      expect(
          await processCameraProvider
              .bindToLifecycle(fakeCameraSelector, <UseCase>[fakeUseCase]),
          equals(fakeCamera));
      verify(mockApi.bindToLifecycle(0, 1, <int>[2]));
    });

    test('unbindTest', () async {
      final MockTestProcessCameraProviderHostApi mockApi =
          MockTestProcessCameraProviderHostApi();
      TestProcessCameraProviderHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final ProcessCameraProvider processCameraProvider =
          ProcessCameraProvider.detached(
        instanceManager: instanceManager,
      );
      final UseCase fakeUseCase =
          UseCase.detached(instanceManager: instanceManager);

      instanceManager.addHostCreatedInstance(
        processCameraProvider,
        0,
        onCopy: (_) => ProcessCameraProvider.detached(),
      );
      instanceManager.addHostCreatedInstance(
        fakeUseCase,
        1,
        onCopy: (_) => UseCase.detached(),
      );

      processCameraProvider.unbind(<UseCase>[fakeUseCase]);
      verify(mockApi.unbind(0, <int>[1]));
    });

    test('unbindAllTest', () async {
      final MockTestProcessCameraProviderHostApi mockApi =
          MockTestProcessCameraProviderHostApi();
      TestProcessCameraProviderHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final ProcessCameraProvider processCameraProvider =
          ProcessCameraProvider.detached(
        instanceManager: instanceManager,
      );
      final UseCase fakeUseCase =
          UseCase.detached(instanceManager: instanceManager);

      instanceManager.addHostCreatedInstance(
        processCameraProvider,
        0,
        onCopy: (_) => ProcessCameraProvider.detached(),
      );
      instanceManager.addHostCreatedInstance(
        fakeUseCase,
        1,
        onCopy: (_) => UseCase.detached(),
      );

      processCameraProvider.unbind(<UseCase>[fakeUseCase]);
      verify(mockApi.unbind(0, <int>[1]));
    });

    test('flutterApiCreateTest', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final ProcessCameraProviderFlutterApiImpl flutterApi =
          ProcessCameraProviderFlutterApiImpl(
        instanceManager: instanceManager,
      );

      flutterApi.create(0);

      expect(instanceManager.getInstanceWithWeakReference(0),
          isA<ProcessCameraProvider>());
    });
  });
}
