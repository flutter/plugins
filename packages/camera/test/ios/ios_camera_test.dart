// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camera/ios_camera.dart';
import 'package:camera/src/camera_testing.dart';
import 'package:camera/src/common/camera_abstraction.dart';

void main() {
  group('iOS Camera', () {
    final List<MethodCall> log = <MethodCall>[];

    setUpAll(() {
      CameraTesting.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'CaptureDevice#getDevices':
          case 'CaptureDiscoverySession#devices':
            return <Map<dynamic, dynamic>>[
              <dynamic, dynamic>{
                'uniqueId': 'apple',
                'position': CaptureDevicePosition.back.toString(),
              },
              <dynamic, dynamic>{
                'uniqueId': 'banana',
                'position': CaptureDevicePosition.unspecified.toString(),
              }
            ];
          case 'CaptureSession#running':
            return true;
          case 'CaptureSession#addOutput':
            return null;
          case 'CaptureSession#removeOutput':
            return null;
          case 'CaptureSession#addInput':
            return null;
          case 'CaptureSession#removeInput':
            return null;
          case 'CaptureSession#startRunning':
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

        expect(log, <Matcher>[
          isMethodCall(
            '$CaptureDiscoverySession#devices',
            arguments: <String, dynamic>{
              'deviceTypes': <String>[
                CaptureDeviceType.builtInWideAngleCamera.toString()
              ],
              'mediaType': MediaType.video.toString(),
              'position': CaptureDevicePosition.front.toString(),
            },
          )
        ]);

        expect(devices, hasLength(2));
        expect(devices[0].uniqueId, 'apple');
        expect(devices[0].position, CaptureDevicePosition.back);
        expect(devices[0].direction, LensDirection.back);
        expect(devices[1].uniqueId, 'banana');
        expect(devices[1].position, CaptureDevicePosition.unspecified);
        expect(devices[1].direction, LensDirection.external);
      });
    });

    group('$CaptureDevice', () {
      test('getDevices', () async {
        final List<CaptureDevice> devices = await CaptureDevice.getDevices(
          MediaType.video,
        );

        expect(log, <Matcher>[
          isMethodCall(
            '$CaptureDevice#getDevices',
            arguments: <String, dynamic>{
              'mediaType': MediaType.video.toString(),
            },
          )
        ]);

        expect(devices, hasLength(2));
        expect(devices[0].uniqueId, 'apple');
        expect(devices[0].position, CaptureDevicePosition.back);
        expect(devices[0].direction, LensDirection.back);
        expect(devices[1].uniqueId, 'banana');
        expect(devices[1].position, CaptureDevicePosition.unspecified);
        expect(devices[1].direction, LensDirection.external);
      });
    });

    group('$CaptureSession', () {
      CaptureSession session;

      setUp(() {
        session = CaptureSession();
      });

      test('addOutput', () async {
        final CaptureVideoDataOutput output = CaptureVideoDataOutput();

        session.startRunning();
        log.clear();
        session.addOutput(output);

        expect(log, <Matcher>[
          isMethodCall(
            '$CaptureSession#addOutput',
            arguments: <String, dynamic>{'handle': 0, 'output': output.asMap()},
          )
        ]);
      });

      test('removeOutput', () async {
        final CaptureVideoDataOutput output = CaptureVideoDataOutput();

        session.addOutput(output);
        session.startRunning();
        log.clear();
        session.removeOutput(output);

        expect(log, <Matcher>[
          isMethodCall(
            '$CaptureSession#removeOutput',
            arguments: <String, dynamic>{'handle': 0, 'output': output.asMap()},
          )
        ]);
      });

      test('addInput', () async {
        final List<CaptureDevice> devices =
            await CaptureDevice.getDevices(MediaType.video);
        final CaptureDeviceInput input = CaptureDeviceInput(device: devices[0]);

        session.startRunning();
        log.clear();
        session.addInput(input);

        expect(log, <Matcher>[
          isMethodCall(
            '$CaptureSession#addInput',
            arguments: <String, dynamic>{'handle': 0, 'input': input.asMap()},
          )
        ]);
      });

      test('removeInput', () async {
        final List<CaptureDevice> devices =
            await CaptureDevice.getDevices(MediaType.video);
        final CaptureDeviceInput input = CaptureDeviceInput(device: devices[0]);

        session.startRunning();
        session.addInput(input);
        log.clear();
        session.removeInput(input);

        expect(log, <Matcher>[
          isMethodCall(
            '$CaptureSession#removeInput',
            arguments: <String, dynamic>{'handle': 0, 'input': input.asMap()},
          )
        ]);
      });
    });
  });
}
