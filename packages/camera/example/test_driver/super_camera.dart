// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

//import 'package:flutter/foundation.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
//import 'package:permission_handler/permission_handler.dart';
//import 'package:camera/camera.dart';
//import 'package:camera/android_camera.dart';
//import 'package:camera/ios_camera.dart';
//import 'package:camera/support_android_camera.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

// We comment out these tests because they only pass on physical devices.
/*
  group('super_camera', () {
    setUpAll(() async => await _getCameraPermission());

    group(
      'Support Android Camera',
      () {
        group('$SupportAndroidCamera', () {
          test('getNumberOfCameras', () {
            expectLater(
              SupportAndroidCamera.getNumberOfCameras(),
              completion(greaterThan(0)),
            );
          });

          test('getCameraInfo', () async {
            final CameraInfo info = await SupportAndroidCamera.getCameraInfo(0);

            expect(info.id, 0);
            expect(info.facing, Facing.back);
            expect(info.direction, LensDirection.back);
            expect(info.orientation, anyOf(0, 90, 180, 270));
          });

          test('open', () {
            final SupportAndroidCamera camera = SupportAndroidCamera.open(0);
            camera.release();
          });

          test('startPreview', () async {
            final SupportAndroidCamera camera = SupportAndroidCamera.open(0);
            expect(camera.startPreview(), completes);

            camera.release();
          });

          test('stopPreview', () async {
            final SupportAndroidCamera camera = SupportAndroidCamera.open(0);
            expect(camera.stopPreview(), completes);

            camera.release();
          });

          test('platformTexture', () async {
            final SupportAndroidCamera camera = SupportAndroidCamera.open(0);

            final NativeTexture texture = await NativeTexture.allocate();
            expect(texture.textureId, isNotNull);

            camera.previewTexture = texture;
            texture.release();
          });
        });
      },
      skip: defaultTargetPlatform != TargetPlatform.android
          ? 'Requires an Android device.'
          : null,
    );

    group(
      'Android Camera',
      () {
        final CameraManager manager = CameraManager.instance;

        group('$CameraManager', () {
          test('getCameraIdList', () async {
            final List<String> idList = await manager.getCameraIdList();

            expect(idList, isNotEmpty);
            expect(idList, everyElement(isNotNull));
          });

          test('getCameraCharacteristics', () async {
            final List<String> idList = await manager.getCameraIdList();

            final CameraCharacteristics chars =
                await manager.getCameraCharacteristics(idList[0]);

            expect(chars.id, idList[0]);
            expect(chars.direction, isNotNull);
            expect(chars.lensFacing, isNotNull);
            expect(chars.sensorOrientation, anyOf(0, 90, 180, 270));
          });

          test('openCamera', () async {
            final List<String> idList = await manager.getCameraIdList();

            final Completer<CameraDevice> completer = Completer<CameraDevice>();

            manager.openCamera(
              idList[0],
              (CameraDeviceState state, CameraDevice device) {
                completer.complete(device);
              },
            );

            final CameraDevice device = await completer.future;

            expect(device, isNotNull);
            expect(device.id, idList[0]);

            device.close();
          });
        });

        group('$CameraDevice', () {
          CameraDevice device;

          setUpAll(() async {
            final List<String> cameraIds = await manager.getCameraIdList();

            final Completer<CameraDevice> deviceCompleter =
                Completer<CameraDevice>();

            manager.openCamera(
              cameraIds[0],
              (CameraDeviceState state, CameraDevice device) {
                deviceCompleter.complete(device);
              },
            );

            device = await deviceCompleter.future;
          });

          tearDownAll(() {
            device.close();
          });

          test('createCaptureSession', () async {
            final NativeTexture nativeTexture = await NativeTexture.allocate();
            final SurfaceTexture surfaceTexture = const SurfaceTexture();
            final PreviewTexture previewTexture = PreviewTexture(
              nativeTexture: nativeTexture,
              surfaceTexture: surfaceTexture,
            );

            final Completer<CameraCaptureSession> sessionCompleter =
                Completer<CameraCaptureSession>();

            device.createCaptureSession(
              <Surface>[previewTexture],
              (CameraCaptureSessionState state, CameraCaptureSession session) {
                sessionCompleter.complete(session);
              },
            );

            final CameraCaptureSession session = await sessionCompleter.future;

            expect(session, isNotNull);

            session.close();
            nativeTexture.release();
          });
        });

        group('$CameraCaptureSession', () {
          CameraDevice device;
          CameraCaptureSession session;
          NativeTexture nativeTexture;
          List<Surface> surfaces;

          setUpAll(() async {
            final List<String> cameraIds = await manager.getCameraIdList();

            final Completer<CameraDevice> deviceCompleter =
                Completer<CameraDevice>();

            manager.openCamera(
              cameraIds[0],
              (CameraDeviceState state, CameraDevice device) {
                deviceCompleter.complete(device);
              },
            );

            device = await deviceCompleter.future;

            nativeTexture = await NativeTexture.allocate();
            final SurfaceTexture surfaceTexture = const SurfaceTexture();
            final PreviewTexture previewTexture = PreviewTexture(
              nativeTexture: nativeTexture,
              surfaceTexture: surfaceTexture,
            );

            surfaces = <Surface>[previewTexture];

            final Completer<CameraCaptureSession> sessionCompleter =
                Completer<CameraCaptureSession>();

            device.createCaptureSession(
              surfaces,
              (CameraCaptureSessionState state, CameraCaptureSession session) {
                sessionCompleter.complete(session);
              },
            );

            session = await sessionCompleter.future;
          });

          tearDownAll(() {
            device.close();
            session.close();
            nativeTexture.release();
          });

          test('setRepeatingRequest', () async {
            CaptureRequest request = device.createCaptureRequest(
              Template.preview,
            );

            request = request.copyWith(targets: surfaces);
            await session.setRepeatingRequest(request: request);
          });
        });
      },
      skip: defaultTargetPlatform != TargetPlatform.android
          ? 'Requries an Android device.'
          : null,
    );

    group(
      'Ios Camera',
      () {
        group('$CaptureDiscoverySession', () {
          test('devices', () async {
            final CaptureDiscoverySession session = CaptureDiscoverySession(
              deviceTypes: <CaptureDeviceType>[
                CaptureDeviceType.builtInWideAngleCamera
              ],
              position: CaptureDevicePosition.front,
              mediaType: MediaType.video,
            );

            final List<CaptureDevice> devices = await session.devices;

            expect(devices, hasLength(1));
            expect(devices[0].uniqueId, isNotEmpty);
            expect(devices[0].position, CaptureDevicePosition.front);
          });
        });

        group('$CaptureSession', () {
          CaptureInput input;

          setUpAll(() async {
            final CaptureDiscoverySession session = CaptureDiscoverySession(
              deviceTypes: <CaptureDeviceType>[
                CaptureDeviceType.builtInWideAngleCamera
              ],
              position: CaptureDevicePosition.front,
              mediaType: MediaType.video,
            );

            final List<CaptureDevice> devices = await session.devices;

            input = CaptureDeviceInput(device: devices[0]);
          });

          test('startRunning', () async {
            final CaptureSession session = CaptureSession();
            session.addInput(input);

            final NativeTexture texture = await NativeTexture.allocate();

            final CaptureVideoDataOutput output = CaptureVideoDataOutput(
              delegate: CaptureVideoDataOutputSampleBufferDelegate(
                texture: texture,
              ),
              formatType: PixelFormatType.bgra32,
            );

            session.addOutput(output);

            await expectLater(session.startRunning(), completes);
            await expectLater(session.stopRunning(), completes);
          });
        });
      },
      skip: defaultTargetPlatform != TargetPlatform.iOS
          ? 'Requires an iOS device.'
          : null,
    );

    group('SuperCamera', () {
      test('availableCameras', () async {
        final List<CameraDescription> descriptions =
            await CameraController.availableCameras();
        expect(descriptions, isNotEmpty);
      });

      test('createPlatformTexture', () async {
        final NativeTexture texture = await NativeTexture.allocate();
        expect(texture.textureId, greaterThan(-1));
      });
    });

    group('$CameraController', () {
      test('Starting and stopping does not cause a crash', () async {
        final List<CameraDescription> descriptions =
            await CameraController.availableCameras();

        final CameraController controller = CameraController(
          description: descriptions[0],
        );

        await expectLater(controller.api, isNotNull);
        await expectLater(
          controller.configurator.addPreviewTexture(),
          completes,
        );
        await expectLater(controller.start(), completes);
        await expectLater(controller.stop(), completes);
        await expectLater(controller.dispose(), completes);
      });

      test(
        '$SupportAndroidCameraConfigurator does not crash',
        () async {
          final CameraInfo info = await SupportAndroidCamera.getCameraInfo(0);

          final CameraController controller =
              CameraController.customConfigurator(
            description: info,
            configurator: SupportAndroidCameraConfigurator(info),
          );

          await expectLater(controller.api, isNotNull);
          await expectLater(
            controller.configurator.addPreviewTexture(),
            completes,
          );
          await expectLater(controller.start(), completes);
          await expectLater(controller.stop(), completes);
          await expectLater(controller.dispose(), completes);
        },
        skip: defaultTargetPlatform != TargetPlatform.android,
      );
    });
  });
  */
}

/*
Future<bool> _getCameraPermission() async {
  final PermissionStatus permission =
      await PermissionHandler().checkPermissionStatus(
    PermissionGroup.camera,
  );

  if (permission == PermissionStatus.granted) {
    return true;
  }

  final Map<PermissionGroup, PermissionStatus> permissions =
      await PermissionHandler().requestPermissions(
    <PermissionGroup>[PermissionGroup.camera],
  );

  return permissions[PermissionGroup.camera] == PermissionStatus.granted;
}
*/
