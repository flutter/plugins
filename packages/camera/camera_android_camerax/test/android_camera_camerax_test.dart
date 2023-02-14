// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:async/async.dart';
import 'package:camera_android_camerax/camera_android_camerax.dart';
import 'package:camera_android_camerax/src/camera.dart';
import 'package:camera_android_camerax/src/camera_info.dart';
import 'package:camera_android_camerax/src/camera_selector.dart';
import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/preview.dart';
import 'package:camera_android_camerax/src/process_camera_provider.dart';
import 'package:camera_android_camerax/src/system_services.dart';
import 'package:camera_android_camerax/src/use_case.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'android_camera_camerax_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<Camera>(),
  MockSpec<CameraInfo>(),
  MockSpec<CameraSelector>(),
  MockSpec<Preview>(),
  MockSpec<ProcessCameraProvider>(),
])
@GenerateMocks(<Type>[BuildContext])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Should fetch CameraDescription instances for available cameras',
      () async {
    // Arrange
    final MockAndroidCameraCamerax camera = MockAndroidCameraCamerax();
    camera.processCameraProvider = MockProcessCameraProvider();
    final List<dynamic> returnData = <dynamic>[
      <String, dynamic>{
        'name': 'Camera 0',
        'lensFacing': 'back',
        'sensorOrientation': 0
      },
      <String, dynamic>{
        'name': 'Camera 1',
        'lensFacing': 'front',
        'sensorOrientation': 90
      }
    ];

    // Create mocks to use
    final MockCameraInfo mockFrontCameraInfo = MockCameraInfo();
    final MockCameraInfo mockBackCameraInfo = MockCameraInfo();

    // Mock calls to native platform
    when(camera.processCameraProvider!.getAvailableCameraInfos()).thenAnswer(
        (_) async => <MockCameraInfo>[mockBackCameraInfo, mockFrontCameraInfo]);
    when(camera.mockBackCameraSelector
            .filter(<MockCameraInfo>[mockFrontCameraInfo]))
        .thenAnswer((_) async => <MockCameraInfo>[]);
    when(camera.mockBackCameraSelector
            .filter(<MockCameraInfo>[mockBackCameraInfo]))
        .thenAnswer((_) async => <MockCameraInfo>[mockBackCameraInfo]);
    when(camera.mockFrontCameraSelector
            .filter(<MockCameraInfo>[mockBackCameraInfo]))
        .thenAnswer((_) async => <MockCameraInfo>[]);
    when(camera.mockFrontCameraSelector
            .filter(<MockCameraInfo>[mockFrontCameraInfo]))
        .thenAnswer((_) async => <MockCameraInfo>[mockFrontCameraInfo]);
    when(mockBackCameraInfo.getSensorRotationDegrees())
        .thenAnswer((_) async => 0);
    when(mockFrontCameraInfo.getSensorRotationDegrees())
        .thenAnswer((_) async => 90);

    final List<CameraDescription> cameraDescriptions =
        await camera.availableCameras();

    expect(cameraDescriptions.length, returnData.length);
    for (int i = 0; i < returnData.length; i++) {
      final Map<String, Object?> typedData =
          (returnData[i] as Map<dynamic, dynamic>).cast<String, Object?>();
      final CameraDescription cameraDescription = CameraDescription(
        name: typedData['name']! as String,
        lensDirection: (typedData['lensFacing']! as String) == 'front'
            ? CameraLensDirection.front
            : CameraLensDirection.back,
        sensorOrientation: typedData['sensorOrientation']! as int,
      );
      expect(cameraDescriptions[i], cameraDescription);
    }
  });

  test(
      'createCamera requests permissions, starts listening for device orientation changes, and returns flutter surface texture ID',
      () async {
    final MockAndroidCameraCamerax camera = MockAndroidCameraCamerax();
    camera.processCameraProvider = MockProcessCameraProvider();
    const CameraLensDirection testLensDirection = CameraLensDirection.back;
    const int testSensorOrientation = 90;
    const CameraDescription testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation);
    const ResolutionPreset testResolutionPreset = ResolutionPreset.veryHigh;
    const bool enableAudio = true;
    const int testSurfaceTextureId = 6;

    when(camera.testPreview.setSurfaceProvider())
        .thenAnswer((_) async => testSurfaceTextureId);

    expect(
        await camera.createCamera(testCameraDescription, testResolutionPreset,
            enableAudio: enableAudio),
        equals(testSurfaceTextureId));

    // Verify permissions are requested and the camera starts listening for device orientation changes.
    expect(camera.cameraPermissionsRequested, isTrue);
    expect(camera.startedListeningForDeviceOrientationChanges, isTrue);

    // Verify CameraSelector is set with appropriate lens direction.
    expect(camera.cameraSelector, equals(camera.mockBackCameraSelector));

    // Verify the camera's Preview instance is instantiated properly.
    expect(camera.preview, equals(camera.testPreview));

    // Verify the camera's Preview instance has its surface provider set.
    verify(camera.preview!.setSurfaceProvider());
  });

  test(
      'initializeCamera throws AssertionError when createCamera has not been called before initializedCamera',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    expect(() => camera.initializeCamera(3), throwsAssertionError);
  });

  test('initializeCamera sends expected CameraInitializedEvent', () async {
    final MockAndroidCameraCamerax camera = MockAndroidCameraCamerax();
    camera.processCameraProvider = MockProcessCameraProvider();
    const int cameraId = 10;
    const CameraLensDirection testLensDirection = CameraLensDirection.back;
    const int testSensorOrientation = 90;
    const CameraDescription testCameraDescription = CameraDescription(
        name: 'cameraName',
        lensDirection: testLensDirection,
        sensorOrientation: testSensorOrientation);
    const ResolutionPreset testResolutionPreset = ResolutionPreset.veryHigh;
    const bool enableAudio = true;
    const int resolutionWidth = 350;
    const int resolutionHeight = 750;
    final Camera mockCamera = MockCamera();
    final ResolutionInfo testResolutionInfo =
        ResolutionInfo(width: resolutionWidth, height: resolutionHeight);

    // TODO(camsim99): Modify this when camera configuration is supported and
    // defualt values no longer being used.
    // https://github.com/flutter/flutter/issues/120468
    // https://github.com/flutter/flutter/issues/120467
    final CameraInitializedEvent testCameraInitializedEvent =
        CameraInitializedEvent(
            cameraId,
            resolutionWidth.toDouble(),
            resolutionHeight.toDouble(),
            ExposureMode.auto,
            false,
            FocusMode.auto,
            false);

    // Call createCamera.
    when(camera.testPreview.setSurfaceProvider())
        .thenAnswer((_) async => cameraId);
    await camera.createCamera(testCameraDescription, testResolutionPreset,
        enableAudio: enableAudio);

    when(camera.processCameraProvider!.bindToLifecycle(
            camera.cameraSelector!, <UseCase>[camera.testPreview]))
        .thenAnswer((_) async => mockCamera);
    when(camera.testPreview.getResolutionInfo())
        .thenAnswer((_) async => testResolutionInfo);

    // Start listening to camera events stream to verify the proper CameraInitializedEvent is sent.
    camera.cameraEventStreamController.stream.listen((CameraEvent event) {
      expect(event, const TypeMatcher<CameraInitializedEvent>());
      expect(event, equals(testCameraInitializedEvent));
    });

    await camera.initializeCamera(cameraId);

    // Verify preview was bound and unbound to get preview resolution information.
    verify(camera.processCameraProvider!.bindToLifecycle(
        camera.cameraSelector!, <UseCase>[camera.testPreview]));
    verify(camera.processCameraProvider!.unbind(<UseCase>[camera.testPreview]));

    // Check camera instance was received, but preview is no longer bound.
    expect(camera.camera, equals(mockCamera));
    expect(camera.previewIsBound, isFalse);
  });

  test('dispose releases Flutter surface texture and unbinds all use cases',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();

    camera.preview = MockPreview();
    camera.processCameraProvider = MockProcessCameraProvider();

    camera.dispose(3);

    verify(camera.preview!.releaseFlutterSurfaceTexture());
    verify(camera.processCameraProvider!.unbindAll());
  });

  test('onCameraInitialized stream emits CameraInitializedEvents', () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 16;
    final Stream<CameraInitializedEvent> eventStream =
        camera.onCameraInitialized(cameraId);
    final StreamQueue<CameraInitializedEvent> streamQueue =
        StreamQueue<CameraInitializedEvent>(eventStream);
    const CameraInitializedEvent testEvent = CameraInitializedEvent(
        cameraId, 320, 80, ExposureMode.auto, false, FocusMode.auto, false);

    camera.cameraEventStreamController.add(testEvent);

    expect(await streamQueue.next, testEvent);
    await streamQueue.cancel();
  });

  test('onCameraError stream emits errors caught by system services', () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int cameraId = 27;
    const String testErrorDescription = 'Test error description!';
    final Stream<CameraErrorEvent> eventStream = camera.onCameraError(cameraId);
    final StreamQueue<CameraErrorEvent> streamQueue =
        StreamQueue<CameraErrorEvent>(eventStream);

    SystemServices.cameraErrorStreamController.add(testErrorDescription);

    expect(await streamQueue.next,
        equals(const CameraErrorEvent(cameraId, testErrorDescription)));
    await streamQueue.cancel();
  });

  test(
      'onDeviceOrientationChanged stream emits changes in device oreintation detected by system services',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    final Stream<DeviceOrientationChangedEvent> eventStream =
        camera.onDeviceOrientationChanged();
    final StreamQueue<DeviceOrientationChangedEvent> streamQueue =
        StreamQueue<DeviceOrientationChangedEvent>(eventStream);
    const DeviceOrientationChangedEvent testEvent =
        DeviceOrientationChangedEvent(DeviceOrientation.portraitDown);

    SystemServices.deviceOrientationChangedStreamController.add(testEvent);

    expect(await streamQueue.next, testEvent);
    await streamQueue.cancel();
  });

  test(
      'pausePreview unbinds preview from lifecycle when preview is nonnull and has been bound to lifecycle',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();

    camera.processCameraProvider = MockProcessCameraProvider();
    camera.preview = MockPreview();
    camera.previewIsBound = true;

    await camera.pausePreview(579);

    verify(camera.processCameraProvider!.unbind(<UseCase>[camera.preview!]));
    expect(camera.previewIsBound, isFalse);
  });

  test(
      'pausePreview does not unbind preview from lifecycle when preview has not been bound to lifecycle',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();

    camera.processCameraProvider = MockProcessCameraProvider();
    camera.preview = MockPreview();

    await camera.pausePreview(632);

    verifyNever(
        camera.processCameraProvider!.unbind(<UseCase>[camera.preview!]));
  });

  test('resumePreview does not bind preview to lifecycle if already bound',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();

    camera.processCameraProvider = MockProcessCameraProvider();
    camera.cameraSelector = MockCameraSelector();
    camera.preview = MockPreview();
    camera.previewIsBound = true;

    await camera.resumePreview(78);

    verifyNever(camera.processCameraProvider!
        .bindToLifecycle(camera.cameraSelector!, <UseCase>[camera.preview!]));
  });

  test('resumePreview binds preview to lifecycle if not already bound',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();

    camera.processCameraProvider = MockProcessCameraProvider();
    camera.cameraSelector = MockCameraSelector();
    camera.preview = MockPreview();

    await camera.resumePreview(78);

    verify(camera.processCameraProvider!
        .bindToLifecycle(camera.cameraSelector!, <UseCase>[camera.preview!]));
  });

  test(
      'buildPreview returns a FutureBuilder that does not return a Texture until the preview is bound to the lifecycle',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int textureId = 75;

    camera.processCameraProvider = MockProcessCameraProvider();
    camera.cameraSelector = MockCameraSelector();
    camera.preview = MockPreview();

    final FutureBuilder<void> previewWidget =
        camera.buildPreview(textureId) as FutureBuilder<void>;

    expect(
        previewWidget.builder(
            MockBuildContext(), const AsyncSnapshot<void>.nothing()),
        isA<SizedBox>());
    expect(
        previewWidget.builder(
            MockBuildContext(), const AsyncSnapshot<void>.waiting()),
        isA<SizedBox>());
    expect(
        previewWidget.builder(MockBuildContext(),
            const AsyncSnapshot<void>.withData(ConnectionState.active, null)),
        isA<SizedBox>());
  });

  test(
      'buildPreview returns a FutureBuilder that returns a Texture once the preview is bound to the lifecycle',
      () async {
    final AndroidCameraCameraX camera = AndroidCameraCameraX();
    const int textureId = 75;

    camera.processCameraProvider = MockProcessCameraProvider();
    camera.cameraSelector = MockCameraSelector();
    camera.preview = MockPreview();

    final FutureBuilder<void> previewWidget =
        camera.buildPreview(textureId) as FutureBuilder<void>;

    final Texture previewTexture = previewWidget.builder(MockBuildContext(),
            const AsyncSnapshot<void>.withData(ConnectionState.done, null))
        as Texture;
    expect(previewTexture.textureId, equals(textureId));
  });
}

/// Mock of [AndroidCameraCameraX] that stubs behavior of some methods for
/// testing.
class MockAndroidCameraCamerax extends AndroidCameraCameraX {
  bool cameraPermissionsRequested = false;
  bool startedListeningForDeviceOrientationChanges = false;
  final MockPreview testPreview = MockPreview();
  final MockCameraSelector mockBackCameraSelector = MockCameraSelector();
  final MockCameraSelector mockFrontCameraSelector = MockCameraSelector();

  @override
  Future<void> requestCameraPermissions(bool enableAudio) async {
    cameraPermissionsRequested = true;
  }

  @override
  void startListeningForDeviceOrientationChange(
      bool cameraIsFrontFacing, int sensorOrientation) {
    startedListeningForDeviceOrientationChanges = true;
    return;
  }

  @override
  CameraSelector createCameraSelector(int cameraSelectorLensDirection) {
    switch (cameraSelectorLensDirection) {
      case CameraSelector.lensFacingFront:
        return mockFrontCameraSelector;
      case CameraSelector.lensFacingBack:
      default:
        return mockBackCameraSelector;
    }
  }

  @override
  Preview createPreview(int targetRotation, ResolutionInfo? targetResolution) {
    return testPreview;
  }
}
