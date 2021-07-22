// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: deprecated_member_use_from_same_package

// This file preserves the tests for the deprecated methods as they were before
// the migration. See image_picker_test.dart for the current tests.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$ImagePicker', () {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/image_picker');

    final List<MethodCall> log = <MethodCall>[];

    final picker = ImagePicker();

    test('ImagePicker platform instance overrides the actual platform used',
        () {
      final ImagePickerPlatform savedPlatform = ImagePickerPlatform.instance;
      final MockPlatform mockPlatform = MockPlatform();
      ImagePickerPlatform.instance = mockPlatform;
      expect(ImagePicker.platform, mockPlatform);
      ImagePickerPlatform.instance = savedPlatform;
    });

    group('#Single image/video', () {
      setUp(() {
        channel.setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
          return '';
        });

        log.clear();
      });

      group('#pickImage', () {
        test('passes the image source argument correctly', () async {
          await picker.getImage(source: ImageSource.camera);
          await picker.getImage(source: ImageSource.gallery);

          expect(
            log,
            <Matcher>[
              isMethodCall('pickImage', arguments: <String, dynamic>{
                'source': 0,
                'maxWidth': null,
                'maxHeight': null,
                'imageQuality': null,
                'cameraDevice': 0
              }),
              isMethodCall('pickImage', arguments: <String, dynamic>{
                'source': 1,
                'maxWidth': null,
                'maxHeight': null,
                'imageQuality': null,
                'cameraDevice': 0
              }),
            ],
          );
        });

        test('passes the width and height arguments correctly', () async {
          await picker.getImage(source: ImageSource.camera);
          await picker.getImage(
            source: ImageSource.camera,
            maxWidth: 10.0,
          );
          await picker.getImage(
            source: ImageSource.camera,
            maxHeight: 10.0,
          );
          await picker.getImage(
            source: ImageSource.camera,
            maxWidth: 10.0,
            maxHeight: 20.0,
          );
          await picker.getImage(
              source: ImageSource.camera, maxWidth: 10.0, imageQuality: 70);
          await picker.getImage(
              source: ImageSource.camera, maxHeight: 10.0, imageQuality: 70);
          await picker.getImage(
              source: ImageSource.camera,
              maxWidth: 10.0,
              maxHeight: 20.0,
              imageQuality: 70);

          expect(
            log,
            <Matcher>[
              isMethodCall('pickImage', arguments: <String, dynamic>{
                'source': 0,
                'maxWidth': null,
                'maxHeight': null,
                'imageQuality': null,
                'cameraDevice': 0
              }),
              isMethodCall('pickImage', arguments: <String, dynamic>{
                'source': 0,
                'maxWidth': 10.0,
                'maxHeight': null,
                'imageQuality': null,
                'cameraDevice': 0
              }),
              isMethodCall('pickImage', arguments: <String, dynamic>{
                'source': 0,
                'maxWidth': null,
                'maxHeight': 10.0,
                'imageQuality': null,
                'cameraDevice': 0
              }),
              isMethodCall('pickImage', arguments: <String, dynamic>{
                'source': 0,
                'maxWidth': 10.0,
                'maxHeight': 20.0,
                'imageQuality': null,
                'cameraDevice': 0
              }),
              isMethodCall('pickImage', arguments: <String, dynamic>{
                'source': 0,
                'maxWidth': 10.0,
                'maxHeight': null,
                'imageQuality': 70,
                'cameraDevice': 0
              }),
              isMethodCall('pickImage', arguments: <String, dynamic>{
                'source': 0,
                'maxWidth': null,
                'maxHeight': 10.0,
                'imageQuality': 70,
                'cameraDevice': 0
              }),
              isMethodCall('pickImage', arguments: <String, dynamic>{
                'source': 0,
                'maxWidth': 10.0,
                'maxHeight': 20.0,
                'imageQuality': 70,
                'cameraDevice': 0
              }),
            ],
          );
        });

        test('does not accept a negative width or height argument', () {
          expect(
            picker.getImage(source: ImageSource.camera, maxWidth: -1.0),
            throwsArgumentError,
          );

          expect(
            picker.getImage(source: ImageSource.camera, maxHeight: -1.0),
            throwsArgumentError,
          );
        });

        test('handles a null image path response gracefully', () async {
          channel.setMockMethodCallHandler((MethodCall methodCall) => null);

          expect(await picker.getImage(source: ImageSource.gallery), isNull);
          expect(await picker.getImage(source: ImageSource.camera), isNull);
        });

        test('camera position defaults to back', () async {
          await picker.getImage(source: ImageSource.camera);

          expect(
            log,
            <Matcher>[
              isMethodCall('pickImage', arguments: <String, dynamic>{
                'source': 0,
                'maxWidth': null,
                'maxHeight': null,
                'imageQuality': null,
                'cameraDevice': 0,
              }),
            ],
          );
        });

        test('camera position can set to front', () async {
          await picker.getImage(
              source: ImageSource.camera,
              preferredCameraDevice: CameraDevice.front);

          expect(
            log,
            <Matcher>[
              isMethodCall('pickImage', arguments: <String, dynamic>{
                'source': 0,
                'maxWidth': null,
                'maxHeight': null,
                'imageQuality': null,
                'cameraDevice': 1,
              }),
            ],
          );
        });
      });

      group('#pickVideo', () {
        test('passes the image source argument correctly', () async {
          await picker.getVideo(source: ImageSource.camera);
          await picker.getVideo(source: ImageSource.gallery);

          expect(
            log,
            <Matcher>[
              isMethodCall('pickVideo', arguments: <String, dynamic>{
                'source': 0,
                'cameraDevice': 0,
                'maxDuration': null,
              }),
              isMethodCall('pickVideo', arguments: <String, dynamic>{
                'source': 1,
                'cameraDevice': 0,
                'maxDuration': null,
              }),
            ],
          );
        });

        test('passes the duration argument correctly', () async {
          await picker.getVideo(source: ImageSource.camera);
          await picker.getVideo(
              source: ImageSource.camera,
              maxDuration: const Duration(seconds: 10));
          await picker.getVideo(
              source: ImageSource.camera,
              maxDuration: const Duration(minutes: 1));
          await picker.getVideo(
              source: ImageSource.camera,
              maxDuration: const Duration(hours: 1));
          expect(
            log,
            <Matcher>[
              isMethodCall('pickVideo', arguments: <String, dynamic>{
                'source': 0,
                'maxDuration': null,
                'cameraDevice': 0,
              }),
              isMethodCall('pickVideo', arguments: <String, dynamic>{
                'source': 0,
                'maxDuration': 10,
                'cameraDevice': 0,
              }),
              isMethodCall('pickVideo', arguments: <String, dynamic>{
                'source': 0,
                'maxDuration': 60,
                'cameraDevice': 0,
              }),
              isMethodCall('pickVideo', arguments: <String, dynamic>{
                'source': 0,
                'maxDuration': 3600,
                'cameraDevice': 0,
              }),
            ],
          );
        });

        test('handles a null video path response gracefully', () async {
          channel.setMockMethodCallHandler((MethodCall methodCall) => null);

          expect(await picker.getVideo(source: ImageSource.gallery), isNull);
          expect(await picker.getVideo(source: ImageSource.camera), isNull);
        });

        test('camera position defaults to back', () async {
          await picker.getVideo(source: ImageSource.camera);

          expect(
            log,
            <Matcher>[
              isMethodCall('pickVideo', arguments: <String, dynamic>{
                'source': 0,
                'cameraDevice': 0,
                'maxDuration': null,
              }),
            ],
          );
        });

        test('camera position can set to front', () async {
          await picker.getVideo(
              source: ImageSource.camera,
              preferredCameraDevice: CameraDevice.front);

          expect(
            log,
            <Matcher>[
              isMethodCall('pickVideo', arguments: <String, dynamic>{
                'source': 0,
                'maxDuration': null,
                'cameraDevice': 1,
              }),
            ],
          );
        });
      });

      group('#retrieveLostData', () {
        test('retrieveLostData get success response', () async {
          channel.setMockMethodCallHandler((MethodCall methodCall) async {
            return <String, String>{
              'type': 'image',
              'path': '/example/path',
            };
          });
          final LostData response = await picker.getLostData();
          expect(response.type, RetrieveType.image);
          expect(response.file!.path, '/example/path');
        });

        test('retrieveLostData get error response', () async {
          channel.setMockMethodCallHandler((MethodCall methodCall) async {
            return <String, String>{
              'type': 'video',
              'errorCode': 'test_error_code',
              'errorMessage': 'test_error_message',
            };
          });
          final LostData response = await picker.getLostData();
          expect(response.type, RetrieveType.video);
          expect(response.exception!.code, 'test_error_code');
          expect(response.exception!.message, 'test_error_message');
        });

        test('retrieveLostData get null response', () async {
          channel.setMockMethodCallHandler((MethodCall methodCall) async {
            return null;
          });
          expect((await picker.getLostData()).isEmpty, true);
        });

        test('retrieveLostData get both path and error should throw', () async {
          channel.setMockMethodCallHandler((MethodCall methodCall) async {
            return <String, String>{
              'type': 'video',
              'errorCode': 'test_error_code',
              'errorMessage': 'test_error_message',
              'path': '/example/path',
            };
          });
          expect(picker.getLostData(), throwsAssertionError);
        });
      });
    });

    group('Multi images', () {
      setUp(() {
        channel.setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
          return [];
        });
        log.clear();
      });

      group('#pickMultiImage', () {
        test('passes the width and height arguments correctly', () async {
          await picker.getMultiImage();
          await picker.getMultiImage(
            maxWidth: 10.0,
          );
          await picker.getMultiImage(
            maxHeight: 10.0,
          );
          await picker.getMultiImage(
            maxWidth: 10.0,
            maxHeight: 20.0,
          );
          await picker.getMultiImage(
            maxWidth: 10.0,
            imageQuality: 70,
          );
          await picker.getMultiImage(
            maxHeight: 10.0,
            imageQuality: 70,
          );
          await picker.getMultiImage(
              maxWidth: 10.0, maxHeight: 20.0, imageQuality: 70);

          expect(
            log,
            <Matcher>[
              isMethodCall('pickMultiImage', arguments: <String, dynamic>{
                'maxWidth': null,
                'maxHeight': null,
                'imageQuality': null,
              }),
              isMethodCall('pickMultiImage', arguments: <String, dynamic>{
                'maxWidth': 10.0,
                'maxHeight': null,
                'imageQuality': null,
              }),
              isMethodCall('pickMultiImage', arguments: <String, dynamic>{
                'maxWidth': null,
                'maxHeight': 10.0,
                'imageQuality': null,
              }),
              isMethodCall('pickMultiImage', arguments: <String, dynamic>{
                'maxWidth': 10.0,
                'maxHeight': 20.0,
                'imageQuality': null,
              }),
              isMethodCall('pickMultiImage', arguments: <String, dynamic>{
                'maxWidth': 10.0,
                'maxHeight': null,
                'imageQuality': 70,
              }),
              isMethodCall('pickMultiImage', arguments: <String, dynamic>{
                'maxWidth': null,
                'maxHeight': 10.0,
                'imageQuality': 70,
              }),
              isMethodCall('pickMultiImage', arguments: <String, dynamic>{
                'maxWidth': 10.0,
                'maxHeight': 20.0,
                'imageQuality': 70,
              }),
            ],
          );
        });

        test('does not accept a negative width or height argument', () {
          expect(
            picker.getMultiImage(maxWidth: -1.0),
            throwsArgumentError,
          );

          expect(
            picker.getMultiImage(maxHeight: -1.0),
            throwsArgumentError,
          );
        });

        test('handles a null image path response gracefully', () async {
          channel.setMockMethodCallHandler((MethodCall methodCall) => null);

          expect(await picker.getMultiImage(), isNull);
          expect(await picker.getMultiImage(), isNull);
        });
      });
    });
  });
}

class MockPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements ImagePickerPlatform {}
