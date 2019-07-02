// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camera/src/camera_testing.dart';
import 'package:camera/support_android_camera.dart';

void main() {
  group('Support Android Camera', () {
    group('$SupportAndroidCamera', () {
      final List<MethodCall> log = <MethodCall>[];
      setUpAll(() {
        CameraTesting.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'SupportAndroidCamera#getNumberOfCameras':
              return 3;
            case 'SupportAndroidCamera#open':
              return null;
            case 'SupportAndroidCamera#getCameraInfo':
              return <dynamic, dynamic>{
                'id': 3,
                'orientation': 90,
                'facing': Facing.front.toString(),
              };
            case 'SupportAndroidCamera#startPreview':
              return null;
            case 'SupportAndroidCamera#stopPreview':
              return null;
            case 'SupportAndroidCamera#release':
              return null;
          }

          throw ArgumentError.value(
            methodCall.method,
            'methodCall.method',
            'No method found for',
          );
        });
      });

      setUp(() {
        log.clear();
        CameraTesting.nextHandle = 0;
      });

      test('getNumberOfCameras', () async {
        final int result = await SupportAndroidCamera.getNumberOfCameras();

        expect(result, 3);
        expect(log, <Matcher>[
          isMethodCall(
            '$SupportAndroidCamera#getNumberOfCameras',
            arguments: null,
          )
        ]);
      });

      test('open', () {
        SupportAndroidCamera.open(14);

        expect(log, <Matcher>[
          isMethodCall(
            '$SupportAndroidCamera#open',
            arguments: <String, dynamic>{
              'cameraId': 14,
              'cameraHandle': 0,
            },
          )
        ]);
      });

      test('getCameraInfo', () async {
        final CameraInfo info = await SupportAndroidCamera.getCameraInfo(14);

        expect(info.id, 3);
        expect(info.orientation, 90);
        expect(info.facing, Facing.front);

        expect(log, <Matcher>[
          isMethodCall(
            '$SupportAndroidCamera#getCameraInfo',
            arguments: <String, dynamic>{'cameraId': 14},
          )
        ]);
      });

      test('startPreview', () {
        final SupportAndroidCamera camera = SupportAndroidCamera.open(0);

        log.clear();
        camera.startPreview();

        expect(log, <Matcher>[
          isMethodCall(
            '$SupportAndroidCamera#startPreview',
            arguments: <String, dynamic>{
              'handle': 0,
            },
          )
        ]);
      });

      test('stopPreview', () {
        final SupportAndroidCamera camera = SupportAndroidCamera.open(0);

        log.clear();
        camera.stopPreview();

        expect(log, <Matcher>[
          isMethodCall(
            '$SupportAndroidCamera#stopPreview',
            arguments: <String, dynamic>{
              'handle': 0,
            },
          )
        ]);
      });

      test('release', () {
        final SupportAndroidCamera camera = SupportAndroidCamera.open(0);

        log.clear();
        camera.release();

        expect(log, <Matcher>[
          isMethodCall(
            '$SupportAndroidCamera#release',
            arguments: <String, dynamic>{
              'handle': 0,
            },
          )
        ]);
      });
    });
  });
}
