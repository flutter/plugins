// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camerax_library.g.dart'
    show CameraPermissionsErrorData;
import 'package:camera_android_camerax/src/system_services.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart'
    show CameraException, DeviceOrientationChangedEvent;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'system_services_test.mocks.dart';
import 'test_camerax_library.g.dart';

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

      when(mockApi.requestCameraPermissions(true))
          .thenAnswer((_) async => null);

      await SystemServices.requestCameraPermissions(true);
      verify(mockApi.requestCameraPermissions(true));
    });

    test(
        'requestCameraPermissionsFromInstance throws CameraException if there was a request error',
        () {
      final MockTestSystemServicesHostApi mockApi =
          MockTestSystemServicesHostApi();
      TestSystemServicesHostApi.setup(mockApi);
      final CameraPermissionsErrorData error = CameraPermissionsErrorData(
        errorCode: 'Test error code',
        description: 'Test error description',
      );

      when(mockApi.requestCameraPermissions(true))
          .thenAnswer((_) async => error);

      expect(
          () async => SystemServices.requestCameraPermissions(true),
          throwsA(isA<CameraException>()
              .having((CameraException e) => e.code, 'code', 'Test error code')
              .having((CameraException e) => e.description, 'description',
                  'Test error description')));
      verify(mockApi.requestCameraPermissions(true));
    });

    test('startListeningForDeviceOrientationChangeTest', () async {
      final MockTestSystemServicesHostApi mockApi =
          MockTestSystemServicesHostApi();
      TestSystemServicesHostApi.setup(mockApi);

      SystemServices.startListeningForDeviceOrientationChange(true, 90);
      verify(mockApi.startListeningForDeviceOrientationChange(true, 90));
    });

    test('stopListeningForDeviceOrientationChangeTest', () async {
      final MockTestSystemServicesHostApi mockApi =
          MockTestSystemServicesHostApi();
      TestSystemServicesHostApi.setup(mockApi);

      SystemServices.stopListeningForDeviceOrientationChange();
      verify(mockApi.stopListeningForDeviceOrientationChange());
    });

    test('onDeviceOrientationChanged adds new orientation to stream', () {
      SystemServices.deviceOrientationChangedStreamController.stream
          .listen((DeviceOrientationChangedEvent event) {
        expect(event.orientation, equals(DeviceOrientation.landscapeLeft));
      });
      SystemServicesFlutterApiImpl()
          .onDeviceOrientationChanged('LANDSCAPE_LEFT');
    });

    test(
        'onDeviceOrientationChanged throws error if new orientation is invalid',
        () {
      expect(
          () => SystemServicesFlutterApiImpl()
              .onDeviceOrientationChanged('FAKE_ORIENTATION'),
          throwsA(isA<ArgumentError>().having(
              (ArgumentError e) => e.message,
              'message',
              '"FAKE_ORIENTATION" is not a valid DeviceOrientation value')));
    });

    test('onCameraError adds new error to stream', () {
      const String testErrorDescription = 'Test error description!';
      SystemServices.cameraErrorStreamController.stream
          .listen((String errorDescription) {
        expect(errorDescription, equals(testErrorDescription));
      });
      SystemServicesFlutterApiImpl().onCameraError(testErrorDescription);
    });
  });
}
