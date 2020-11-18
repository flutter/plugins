// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:image_picker_platform_interface/src/method_channel/method_channel_image_picker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$MethodChannelImagePicker', () {
    MethodChannelImagePicker picker = MethodChannelImagePicker();

    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      picker.channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return '';
      });

      log.clear();
    });

    group('#pickImage', () {
      test('passes the image source argument correctly', () async {
        await picker.pickImage(source: ImageSource.camera);
        await picker.pickImage(source: ImageSource.gallery);

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
        await picker.pickImage(source: ImageSource.camera);
        await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 10.0,
        );
        await picker.pickImage(
          source: ImageSource.camera,
          maxHeight: 10.0,
        );
        await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 10.0,
          maxHeight: 20.0,
        );
        await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 10.0,
          imageQuality: 70,
        );
        await picker.pickImage(
          source: ImageSource.camera,
          maxHeight: 10.0,
          imageQuality: 70,
        );
        await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 10.0,
          maxHeight: 20.0,
          imageQuality: 70,
        );

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
          () => picker.pickImage(source: ImageSource.camera, maxWidth: -1.0),
          throwsArgumentError,
        );

        expect(
          () => picker.pickImage(source: ImageSource.camera, maxHeight: -1.0),
          throwsArgumentError,
        );
      });

      test('handles a null image path response gracefully', () async {
        picker.channel
            .setMockMethodCallHandler((MethodCall methodCall) => null);

        expect(await picker.pickImage(source: ImageSource.gallery), isNull);
        expect(await picker.pickImage(source: ImageSource.camera), isNull);
      });

      test('camera position defaults to back', () async {
        await picker.pickImage(source: ImageSource.camera);

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
        await picker.pickImage(
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

    group('#pickVideoPath', () {
      test('passes the image source argument correctly', () async {
        await picker.pickVideo(source: ImageSource.camera);
        await picker.pickVideo(source: ImageSource.gallery);

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
        await picker.pickVideo(source: ImageSource.camera);
        await picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(seconds: 10),
        );
        await picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(minutes: 1),
        );
        await picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(hours: 1),
        );
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
        picker.channel
            .setMockMethodCallHandler((MethodCall methodCall) => null);

        expect(await picker.pickVideo(source: ImageSource.gallery), isNull);
        expect(await picker.pickVideo(source: ImageSource.camera), isNull);
      });

      test('camera position defaults to back', () async {
        await picker.pickVideo(source: ImageSource.camera);

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
        await picker.pickVideo(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front,
        );

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
        picker.channel.setMockMethodCallHandler((MethodCall methodCall) async {
          return <String, String>{
            'type': 'image',
            'path': '/example/path',
          };
        });
        // ignore: deprecated_member_use_from_same_package
        final LostData response = await picker.retrieveLostData();
        expect(response.type, RetrieveType.image);
        expect(response.file.path, '/example/path');
      });

      test('retrieveLostData get error response', () async {
        picker.channel.setMockMethodCallHandler((MethodCall methodCall) async {
          return <String, String>{
            'type': 'video',
            'errorCode': 'test_error_code',
            'errorMessage': 'test_error_message',
          };
        });
        // ignore: deprecated_member_use_from_same_package
        final LostData response = await picker.retrieveLostData();
        expect(response.type, RetrieveType.video);
        expect(response.exception.code, 'test_error_code');
        expect(response.exception.message, 'test_error_message');
      });

      test('retrieveLostData get null response', () async {
        picker.channel.setMockMethodCallHandler((MethodCall methodCall) async {
          return null;
        });
        expect((await picker.retrieveLostData()).isEmpty, true);
      });

      test('retrieveLostData get both path and error should throw', () async {
        picker.channel.setMockMethodCallHandler((MethodCall methodCall) async {
          return <String, String>{
            'type': 'video',
            'errorCode': 'test_error_code',
            'errorMessage': 'test_error_message',
            'path': '/example/path',
          };
        });
        expect(picker.retrieveLostData(), throwsAssertionError);
      });
    });
  });
}
