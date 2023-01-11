// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camerax_library.pigeon.dart'
    show CameraPermissionsErrorData;
import 'package:camera_android_camerax/src/system_services.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart'
    show CameraException, DeviceOrientationChangedEvent;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'system_services_test.mocks.dart';
import 'test_camerax_library.pigeon.dart';

@GenerateMocks(<Type>[TestSystemServicesHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SystemServices', () {
    tearDown(() => TestProcessCameraProviderHostApi.setup(null));

    test(
        'requestCameraPermissionsFromInstance completes normally without errors test',
        () async {
      final MockTestSystemServicesHostApi mockApi =
          MockTestSystemServicesHostApi();
      TestSystemServicesHostApi.setup(mockApi);
      const bool enableAudio = true;

      when(mockApi.requestCameraPermissions(enableAudio))
          .thenAnswer((_) async => null);

      await SystemServices.requestCameraPermissions(enableAudio);
      verify(mockApi.requestCameraPermissions(enableAudio));
    });

    test(
        'requestCameraPermissionsFromInstance throws CameraException if there was a request error',
        () {
      final MockTestSystemServicesHostApi mockApi =
          MockTestSystemServicesHostApi();
      TestSystemServicesHostApi.setup(mockApi);
      const bool enableAudio = true;
      final CameraPermissionsErrorData error = CameraPermissionsErrorData(
        errorCode: 'Test error code',
        description: 'Test error description',
      );

      when(mockApi.requestCameraPermissions(enableAudio))
          .thenAnswer((_) async => error);

      expect(
          () async => SystemServices.requestCameraPermissions(enableAudio),
          throwsA(isA<CameraException>()
              .having((CameraException e) => e.code, 'code', 'Test error code')
              .having((CameraException e) => e.description, 'description',
                  'Test error description')));
      verify(mockApi.requestCameraPermissions(enableAudio));
    });

    test('startListeningForDeviceOrientationChangeTest', () async {
      final MockTestSystemServicesHostApi mockApi =
          MockTestSystemServicesHostApi();
      TestSystemServicesHostApi.setup(mockApi);
      const bool isFrontFacing = true;
      const int sensorOrientation = 90;

      SystemServices.startListeningForDeviceOrientationChange(
          isFrontFacing, sensorOrientation);
      verify(mockApi.startListeningForDeviceOrientationChange(
          isFrontFacing, sensorOrientation));
    });

    test('onDeviceOrientationChanged adds new orientation to stream', () {
      const String orientation = 'LANDSCAPE_LEFT';

      SystemServices.deviceOrientationChangedStreamController.stream
          .listen((DeviceOrientationChangedEvent event) {
        expect(event.orientation, equals(DeviceOrientation.landscapeLeft));
      });
      SystemServicesFlutterApiImpl().onDeviceOrientationChanged(orientation);
    });

    test(
        'onDeviceOrientationChanged throws error if new orientation is invalid',
        () {
      const String orientation = 'FAKE_ORIENTATION';

      expect(
          () => SystemServicesFlutterApiImpl()
              .onDeviceOrientationChanged(orientation),
          throwsA(isA<ArgumentError>().having(
              (ArgumentError e) => e.message,
              'message',
              '"FAKE_ORIENTATION" is not a valid DeviceOrientation value')));
    });
  });
}
