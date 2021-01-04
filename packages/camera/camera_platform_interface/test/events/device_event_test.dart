// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceOrientationChangedEvent tests', () {
    test('Constructor should initialize all properties', () {
      final event = DeviceOrientationChangedEvent(DeviceOrientation.portrait);

      expect(event.orientation, DeviceOrientation.portrait);
    });

    test('fromJson should initialize all properties', () {
      final event = DeviceOrientationChangedEvent.fromJson(<String, dynamic>{
        'orientation': 'portrait',
      });

      expect(event.orientation, DeviceOrientation.portrait);
    });

    test('toJson should return a map with all fields', () {
      final event = DeviceOrientationChangedEvent(DeviceOrientation.portrait);

      final jsonMap = event.toJson();

      expect(jsonMap.length, 1);
      expect(jsonMap['orientation'], 'portrait');
    });

    test('equals should return true if objects are the same', () {
      final firstEvent =
          DeviceOrientationChangedEvent(DeviceOrientation.portrait);
      final secondEvent =
          DeviceOrientationChangedEvent(DeviceOrientation.portrait);

      expect(firstEvent == secondEvent, true);
    });

    test('equals should return false if orientation is different', () {
      final firstEvent =
          DeviceOrientationChangedEvent(DeviceOrientation.portrait);
      final secondEvent =
          DeviceOrientationChangedEvent(DeviceOrientation.landscapeLeft);

      expect(firstEvent == secondEvent, false);
    });

    test('hashCode should match hashCode of all properties', () {
      final event = DeviceOrientationChangedEvent(DeviceOrientation.portrait);
      final expectedHashCode = event.orientation.hashCode;

      expect(event.hashCode, expectedHashCode);
    });
  });
}
