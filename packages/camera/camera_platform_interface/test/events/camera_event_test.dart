// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_platform_interface/src/types/exposure_mode.dart';
import 'package:camera_platform_interface/src/types/focus_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CameraInitializedEvent tests', () {
    test('Constructor should initialize all properties', () {
      final event = CameraInitializedEvent(
          1, 1024, 640, ExposureMode.auto, true, FocusMode.auto, true);

      expect(event.cameraId, 1);
      expect(event.previewWidth, 1024);
      expect(event.previewHeight, 640);
      expect(event.exposureMode, ExposureMode.auto);
      expect(event.focusMode, FocusMode.auto);
      expect(event.exposurePointSupported, true);
      expect(event.focusPointSupported, true);
    });

    test('fromJson should initialize all properties', () {
      final event = CameraInitializedEvent.fromJson(<String, dynamic>{
        'cameraId': 1,
        'previewWidth': 1024.0,
        'previewHeight': 640.0,
        'exposureMode': 'auto',
        'exposurePointSupported': true,
        'focusMode': 'auto',
        'focusPointSupported': true
      });

      expect(event.cameraId, 1);
      expect(event.previewWidth, 1024);
      expect(event.previewHeight, 640);
      expect(event.exposureMode, ExposureMode.auto);
      expect(event.exposurePointSupported, true);
      expect(event.focusMode, FocusMode.auto);
      expect(event.focusPointSupported, true);
    });

    test('toJson should return a map with all fields', () {
      final event = CameraInitializedEvent(
          1, 1024, 640, ExposureMode.auto, true, FocusMode.auto, true);

      final jsonMap = event.toJson();

      expect(jsonMap.length, 7);
      expect(jsonMap['cameraId'], 1);
      expect(jsonMap['previewWidth'], 1024);
      expect(jsonMap['previewHeight'], 640);
      expect(jsonMap['exposureMode'], 'auto');
      expect(jsonMap['exposurePointSupported'], true);
      expect(jsonMap['focusMode'], 'auto');
      expect(jsonMap['focusPointSupported'], true);
    });

    test('equals should return true if objects are the same', () {
      final firstEvent = CameraInitializedEvent(
          1, 1024, 640, ExposureMode.auto, true, FocusMode.auto, true);
      final secondEvent = CameraInitializedEvent(
          1, 1024, 640, ExposureMode.auto, true, FocusMode.auto, true);

      expect(firstEvent == secondEvent, true);
    });

    test('equals should return false if cameraId is different', () {
      final firstEvent = CameraInitializedEvent(
          1, 1024, 640, ExposureMode.auto, true, FocusMode.auto, true);
      final secondEvent = CameraInitializedEvent(
          2, 1024, 640, ExposureMode.auto, true, FocusMode.auto, true);

      expect(firstEvent == secondEvent, false);
    });

    test('equals should return false if previewWidth is different', () {
      final firstEvent = CameraInitializedEvent(
          1, 1024, 640, ExposureMode.auto, true, FocusMode.auto, true);
      final secondEvent = CameraInitializedEvent(
          1, 2048, 640, ExposureMode.auto, true, FocusMode.auto, true);

      expect(firstEvent == secondEvent, false);
    });

    test('equals should return false if previewHeight is different', () {
      final firstEvent = CameraInitializedEvent(
          1, 1024, 640, ExposureMode.auto, true, FocusMode.auto, true);
      final secondEvent = CameraInitializedEvent(
          1, 1024, 980, ExposureMode.auto, true, FocusMode.auto, true);

      expect(firstEvent == secondEvent, false);
    });

    test('equals should return false if exposureMode is different', () {
      final firstEvent = CameraInitializedEvent(
          1, 1024, 640, ExposureMode.auto, true, FocusMode.auto, true);
      final secondEvent = CameraInitializedEvent(
          1, 1024, 640, ExposureMode.locked, true, FocusMode.auto, true);

      expect(firstEvent == secondEvent, false);
    });

    test('equals should return false if exposurePointSupported is different',
        () {
      final firstEvent = CameraInitializedEvent(
          1, 1024, 640, ExposureMode.auto, true, FocusMode.auto, true);
      final secondEvent = CameraInitializedEvent(
          1, 1024, 640, ExposureMode.auto, false, FocusMode.auto, true);

      expect(firstEvent == secondEvent, false);
    });

    test('equals should return false if focusMode is different', () {
      final firstEvent = CameraInitializedEvent(
          1, 1024, 640, ExposureMode.auto, true, FocusMode.auto, true);
      final secondEvent = CameraInitializedEvent(
          1, 1024, 640, ExposureMode.auto, true, FocusMode.locked, true);

      expect(firstEvent == secondEvent, false);
    });

    test('equals should return false if focusPointSupported is different', () {
      final firstEvent = CameraInitializedEvent(
          1, 1024, 640, ExposureMode.auto, true, FocusMode.auto, true);
      final secondEvent = CameraInitializedEvent(
          1, 1024, 640, ExposureMode.auto, true, FocusMode.auto, false);

      expect(firstEvent == secondEvent, false);
    });

    test('hashCode should match hashCode of all properties', () {
      final event = CameraInitializedEvent(
          1, 1024, 640, ExposureMode.auto, true, FocusMode.auto, true);
      final expectedHashCode = event.cameraId.hashCode ^
          event.previewWidth.hashCode ^
          event.previewHeight.hashCode ^
          event.exposureMode.hashCode ^
          event.exposurePointSupported.hashCode ^
          event.focusMode.hashCode ^
          event.focusPointSupported.hashCode;

      expect(event.hashCode, expectedHashCode);
    });
  });

  group('CameraResolutionChangesEvent tests', () {
    test('Constructor should initialize all properties', () {
      final event = CameraResolutionChangedEvent(1, 1024, 640);

      expect(event.cameraId, 1);
      expect(event.captureWidth, 1024);
      expect(event.captureHeight, 640);
    });

    test('fromJson should initialize all properties', () {
      final event = CameraResolutionChangedEvent.fromJson(<String, dynamic>{
        'cameraId': 1,
        'captureWidth': 1024.0,
        'captureHeight': 640.0,
      });

      expect(event.cameraId, 1);
      expect(event.captureWidth, 1024);
      expect(event.captureHeight, 640);
    });

    test('toJson should return a map with all fields', () {
      final event = CameraResolutionChangedEvent(1, 1024, 640);

      final jsonMap = event.toJson();

      expect(jsonMap.length, 3);
      expect(jsonMap['cameraId'], 1);
      expect(jsonMap['captureWidth'], 1024);
      expect(jsonMap['captureHeight'], 640);
    });

    test('equals should return true if objects are the same', () {
      final firstEvent = CameraResolutionChangedEvent(1, 1024, 640);
      final secondEvent = CameraResolutionChangedEvent(1, 1024, 640);

      expect(firstEvent == secondEvent, true);
    });

    test('equals should return false if cameraId is different', () {
      final firstEvent = CameraResolutionChangedEvent(1, 1024, 640);
      final secondEvent = CameraResolutionChangedEvent(2, 1024, 640);

      expect(firstEvent == secondEvent, false);
    });

    test('equals should return false if captureWidth is different', () {
      final firstEvent = CameraResolutionChangedEvent(1, 1024, 640);
      final secondEvent = CameraResolutionChangedEvent(1, 2048, 640);

      expect(firstEvent == secondEvent, false);
    });

    test('equals should return false if captureHeight is different', () {
      final firstEvent = CameraResolutionChangedEvent(1, 1024, 640);
      final secondEvent = CameraResolutionChangedEvent(1, 1024, 980);

      expect(firstEvent == secondEvent, false);
    });

    test('hashCode should match hashCode of all properties', () {
      final event = CameraResolutionChangedEvent(1, 1024, 640);
      final expectedHashCode = event.cameraId.hashCode ^
          event.captureWidth.hashCode ^
          event.captureHeight.hashCode;

      expect(event.hashCode, expectedHashCode);
    });
  });

  group('CameraClosingEvent tests', () {
    test('Constructor should initialize all properties', () {
      final event = CameraClosingEvent(1);

      expect(event.cameraId, 1);
    });

    test('fromJson should initialize all properties', () {
      final event = CameraClosingEvent.fromJson(<String, dynamic>{
        'cameraId': 1,
      });

      expect(event.cameraId, 1);
    });

    test('toJson should return a map with all fields', () {
      final event = CameraClosingEvent(1);

      final jsonMap = event.toJson();

      expect(jsonMap.length, 1);
      expect(jsonMap['cameraId'], 1);
    });

    test('equals should return true if objects are the same', () {
      final firstEvent = CameraClosingEvent(1);
      final secondEvent = CameraClosingEvent(1);

      expect(firstEvent == secondEvent, true);
    });

    test('equals should return false if cameraId is different', () {
      final firstEvent = CameraClosingEvent(1);
      final secondEvent = CameraClosingEvent(2);

      expect(firstEvent == secondEvent, false);
    });

    test('hashCode should match hashCode of all properties', () {
      final event = CameraClosingEvent(1);
      final expectedHashCode = event.cameraId.hashCode;

      expect(event.hashCode, expectedHashCode);
    });
  });

  group('CameraErrorEvent tests', () {
    test('Constructor should initialize all properties', () {
      final event = CameraErrorEvent(1, 'Error');

      expect(event.cameraId, 1);
      expect(event.description, 'Error');
    });

    test('fromJson should initialize all properties', () {
      final event = CameraErrorEvent.fromJson(
          <String, dynamic>{'cameraId': 1, 'description': 'Error'});

      expect(event.cameraId, 1);
      expect(event.description, 'Error');
    });

    test('toJson should return a map with all fields', () {
      final event = CameraErrorEvent(1, 'Error');

      final jsonMap = event.toJson();

      expect(jsonMap.length, 2);
      expect(jsonMap['cameraId'], 1);
      expect(jsonMap['description'], 'Error');
    });

    test('equals should return true if objects are the same', () {
      final firstEvent = CameraErrorEvent(1, 'Error');
      final secondEvent = CameraErrorEvent(1, 'Error');

      expect(firstEvent == secondEvent, true);
    });

    test('equals should return false if cameraId is different', () {
      final firstEvent = CameraErrorEvent(1, 'Error');
      final secondEvent = CameraErrorEvent(2, 'Error');

      expect(firstEvent == secondEvent, false);
    });

    test('equals should return false if description is different', () {
      final firstEvent = CameraErrorEvent(1, 'Error');
      final secondEvent = CameraErrorEvent(1, 'Ooops');

      expect(firstEvent == secondEvent, false);
    });

    test('hashCode should match hashCode of all properties', () {
      final event = CameraErrorEvent(1, 'Error');
      final expectedHashCode =
          event.cameraId.hashCode ^ event.description.hashCode;

      expect(event.hashCode, expectedHashCode);
    });
  });
}
