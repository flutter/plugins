// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera/new/src/support_android/camera_info.dart';
import 'package:camera/new/src/support_android/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera/new/src/camera_testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Support Android Camera', () {
    group('$Camera', () {
      final List<MethodCall> log = <MethodCall>[];
      setUpAll(() {
        CameraTesting.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'Camera#getNumberOfCameras':
              return 3;
            case 'Camera#open':
              return null;
            case 'Camera#getCameraInfo':
              return <dynamic, dynamic>{
                'id': 3,
                'orientation': 90,
                'facing': Facing.front.toString(),
              };
            case 'Camera#startPreview':
              return null;
            case 'Camera#stopPreview':
              return null;
            case 'Camera#release':
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
        final int result = await Camera.getNumberOfCameras();

        expect(result, 3);
        expect(log, <Matcher>[
          isMethodCall(
            '$Camera#getNumberOfCameras',
            arguments: null,
          )
        ]);
      });

      test('open', () {
        Camera.open(14);

        expect(log, <Matcher>[
          isMethodCall(
            '$Camera#open',
            arguments: <String, dynamic>{
              'cameraId': 14,
              'cameraHandle': 0,
            },
          )
        ]);
      });

      test('getCameraInfo', () async {
        final CameraInfo info = await Camera.getCameraInfo(14);

        expect(info.id, 3);
        expect(info.orientation, 90);
        expect(info.facing, Facing.front);

        expect(log, <Matcher>[
          isMethodCall(
            '$Camera#getCameraInfo',
            arguments: <String, dynamic>{'cameraId': 14},
          )
        ]);
      });

      test('startPreview', () {
        final Camera camera = Camera.open(0);

        log.clear();
        camera.startPreview();

        expect(log, <Matcher>[
          isMethodCall(
            '$Camera#startPreview',
            arguments: <String, dynamic>{
              'handle': 0,
            },
          )
        ]);
      });

      test('stopPreview', () {
        final Camera camera = Camera.open(0);

        log.clear();
        camera.stopPreview();

        expect(log, <Matcher>[
          isMethodCall(
            '$Camera#stopPreview',
            arguments: <String, dynamic>{
              'handle': 0,
            },
          )
        ]);
      });

      test('release', () {
        final Camera camera = Camera.open(0);

        log.clear();
        camera.release();

        expect(log, <Matcher>[
          isMethodCall(
            '$Camera#release',
            arguments: <String, dynamic>{
              'handle': 0,
            },
          )
        ]);
      });
    });
  });
}
