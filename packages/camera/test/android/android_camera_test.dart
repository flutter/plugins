// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camera/android_camera.dart';
import 'package:camera/src/camera_testing.dart';
import 'package:camera/src/common/native_texture.dart';

void main() {
  group('Android Camera', () {
    final List<MethodCall> log = <MethodCall>[];

    setUpAll(() {
      CameraTesting.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'CameraManager()':
            return null;
          case 'CameraManager#getCameraCharacteristics':
            return <dynamic, dynamic>{
              'id': 'apple',
              'sensorOrientation': 90,
              'lensFacing': LensFacing.back.toString(),
            };
          case 'CameraManager#getCameraIdList':
            return <dynamic>['1', '2', '3'];
          case 'CameraManager#openCamera':
            return null;
          case 'CameraDevice#close':
            return null;
          case 'CameraDevice#createCaptureSession':
            return null;
          case 'NativeTexture#allocate':
            return 15;
          case 'CameraCaptureSession#close':
            return null;
          case 'CameraCaptureSession#setRepeatingRequest':
            return null;
        }

        throw ArgumentError.value(
          methodCall.method,
          'methodCall.method',
          'Method not found in test mock method call handler',
        );
      });
    });

    setUp(() {
      log.clear();
      CameraTesting.nextHandle = 0;
    });

    group('$CameraManager', () {
      test('instance', () {
        final CameraManager manager = CameraManager.instance;

        expect(log, <Matcher>[
          isMethodCall(
            '$CameraManager()',
            arguments: <String, dynamic>{'managerHandle': 0},
          )
        ]);

        manager.getCameraIdList();
      });

      test('getCameraCharacteristics', () async {
        final CameraCharacteristics characteristics =
            await CameraManager.instance.getCameraCharacteristics('hello');

        expect(characteristics.id, 'apple');
        expect(characteristics.sensorOrientation, 90);
        expect(characteristics.lensFacing, LensFacing.back);
        expect(log, <Matcher>[
          isMethodCall(
            '$CameraManager#getCameraCharacteristics',
            arguments: <String, dynamic>{'cameraId': 'hello', 'handle': 0},
          )
        ]);
      });

      test('getCameraIdList', () async {
        final List<String> ids = await CameraManager.instance.getCameraIdList();

        expect(ids, <String>['1', '2', '3']);
        expect(log, <Matcher>[
          isMethodCall(
            '$CameraManager#getCameraIdList',
            arguments: <String, dynamic>{
              'handle': 0,
            },
          )
        ]);
      });

      test('openCamera', () async {
        CameraDevice cameraDevice;
        CameraManager.instance.openCamera(
          'hello',
          (CameraDeviceState state, CameraDevice device) {
            expect(state, CameraDeviceState.opened);
            cameraDevice = device;
          },
        );

        expect(log, <Matcher>[
          isMethodCall(
            '$CameraManager#openCamera',
            arguments: <String, dynamic>{
              'handle': 0,
              'cameraId': 'hello',
              'cameraHandle': 0,
            },
          )
        ]);

        await _makeCallback(
          <dynamic, dynamic>{
            'handle': 0,
            '$CameraDeviceState': CameraDeviceState.opened.toString(),
          },
        );

        expect(cameraDevice.id, 'hello');
        cameraDevice.close();
      });
    });

    group('$CameraDevice', () {
      CameraDevice cameraDevice;

      setUpAll(() async {
        CameraTesting.nextHandle = 0;
        CameraManager.instance.openCamera(
          '',
          (CameraDeviceState state, CameraDevice device) {
            cameraDevice = device;
          },
        );

        await _makeCallback(<dynamic, dynamic>{
          'handle': 0,
          '$CameraDeviceState': CameraDeviceState.opened.toString()
        });

        assert(cameraDevice != null);
      });

      tearDownAll(() {
        cameraDevice?.close();
      });

      test('createCaptureRequest', () async {
        final CaptureRequest request = cameraDevice.createCaptureRequest(
          Template.preview,
        );

        expect(request.template, Template.preview);
        expect(request.targets, isEmpty);
        expect(request.jpegQuality, isNull);
      });

      test('createCaptureSession', () async {
        final NativeTexture nativeTexture = await NativeTexture.allocate();
        final SurfaceTexture surfaceTexture = const SurfaceTexture();
        final PreviewTexture previewTexture = PreviewTexture(
          nativeTexture: nativeTexture,
          surfaceTexture: surfaceTexture,
        );

        log.clear();
        CameraTesting.nextHandle = 1;

        CameraCaptureSession captureSession;
        cameraDevice.createCaptureSession(
          <Surface>[previewTexture],
          (CameraCaptureSessionState state, CameraCaptureSession session) {
            expect(state, CameraCaptureSessionState.configured);
            captureSession = session;
          },
        );

        await _makeCallback(<dynamic, dynamic>{
          'handle': 1,
          '$CameraCaptureSessionState':
              CameraCaptureSessionState.configured.toString(),
        });

        expect(log, <Matcher>[
          isMethodCall(
            '$CameraDevice#createCaptureSession',
            arguments: <String, dynamic>{
              'handle': 0,
              'sessionHandle': 1,
              'outputs': <Map<dynamic, dynamic>>[previewTexture.asMap()],
            },
          )
        ]);

        captureSession.close();
      });

      test('close', () {
        cameraDevice.close();

        expect(log, <Matcher>[
          isMethodCall(
            '$CameraDevice#close',
            arguments: <String, dynamic>{'handle': 0},
          )
        ]);
      });
    });

    group('$CameraCaptureSession', () {
      CameraDevice cameraDevice;
      CameraCaptureSession captureSession;
      List<Surface> surfaces;

      setUpAll(() async {
        CameraTesting.nextHandle = 1;

        CameraManager.instance.openCamera(
          '',
          (CameraDeviceState state, CameraDevice device) {
            cameraDevice = device;
          },
        );

        await _makeCallback(<dynamic, dynamic>{
          'handle': 1,
          '$CameraDeviceState': CameraDeviceState.opened.toString(),
        });

        final NativeTexture nativeTexture = await NativeTexture.allocate();
        final SurfaceTexture surfaceTexture = const SurfaceTexture();
        final PreviewTexture previewTexture = PreviewTexture(
          nativeTexture: nativeTexture,
          surfaceTexture: surfaceTexture,
        );

        surfaces = <Surface>[previewTexture];

        CameraTesting.nextHandle = 0;
        cameraDevice.createCaptureSession(
          surfaces,
          (CameraCaptureSessionState state, CameraCaptureSession session) {
            captureSession = session;
          },
        );

        await _makeCallback(<dynamic, dynamic>{
          'handle': 0,
          '$CameraCaptureSessionState':
              CameraCaptureSessionState.configured.toString(),
        });

        assert(captureSession != null);
      });

      tearDownAll(() {
        cameraDevice?.close();
        captureSession?.close();
      });

      test('setRepeatingRequest', () async {
        CaptureRequest request = cameraDevice.createCaptureRequest(
          Template.preview,
        );

        request = request.copyWith(targets: surfaces);
        captureSession.setRepeatingRequest(request: request);

        expect(log, <Matcher>[
          isMethodCall(
            '$CameraCaptureSession#setRepeatingRequest',
            arguments: <String, dynamic>{
              'handle': 0,
              'cameraDeviceHandle': 1,
              'captureRequest': request.asMap(),
            },
          ),
        ]);
      });

      test('close', () {
        captureSession.close();

        expect(log, <Matcher>[
          isMethodCall(
            '$CameraCaptureSession#close',
            arguments: <String, dynamic>{'handle': 0},
          ),
        ]);
      });
    });
  });
}

// Simulates passing back a callback to Camera
Future<void> _makeCallback(dynamic arguments) {
  return defaultBinaryMessenger.handlePlatformMessage(
    CameraTesting.channel.name,
    CameraTesting.channel.codec.encodeMethodCall(
      MethodCall('handleCallback', arguments),
    ),
    (ByteData reply) {},
  );
}
