// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensors/sensors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('$accelerometerEvents are streamed', () async {
    const String channelName = 'plugins.flutter.io/sensors/accelerometer';
    const List<double> sensorData = <double>[1.0, 2.0, 3.0];
    _initializeFakeSensorChannel(channelName, sensorData);

    final AccelerometerEvent event = await accelerometerEvents.first;

    expect(event.x, sensorData[0]);
    expect(event.y, sensorData[1]);
    expect(event.z, sensorData[2]);
  });

  test('$gyroscopeEvents are streamed', () async {
    const String channelName = 'plugins.flutter.io/sensors/gyroscope';
    const List<double> sensorData = <double>[3.0, 4.0, 5.0];
    _initializeFakeSensorChannel(channelName, sensorData);

    final GyroscopeEvent event = await gyroscopeEvents.first;

    expect(event.x, sensorData[0]);
    expect(event.y, sensorData[1]);
    expect(event.z, sensorData[2]);
  });

  test('$userAccelerometerEvents are streamed', () async {
    const String channelName = 'plugins.flutter.io/sensors/user_accel';
    const List<double> sensorData = <double>[6.0, 7.0, 8.0];
    _initializeFakeSensorChannel(channelName, sensorData);

    final UserAccelerometerEvent event = await userAccelerometerEvents.first;

    expect(event.x, sensorData[0]);
    expect(event.y, sensorData[1]);
    expect(event.z, sensorData[2]);
  });
}

void _initializeFakeSensorChannel(String channelName, List<double> sensorData) {
  const StandardMethodCodec standardMethod = StandardMethodCodec();

  void _emitEvent(ByteData? event) {
    _ambiguate(ServicesBinding.instance)!
        .defaultBinaryMessenger
        .handlePlatformMessage(
          channelName,
          event,
          (ByteData? reply) {},
        );
  }

  _ambiguate(ServicesBinding.instance)!
      .defaultBinaryMessenger
      .setMockMessageHandler(channelName, (ByteData? message) async {
    final MethodCall methodCall = standardMethod.decodeMethodCall(message);
    if (methodCall.method == 'listen') {
      _emitEvent(standardMethod.encodeSuccessEnvelope(sensorData));
      _emitEvent(null);
      return standardMethod.encodeSuccessEnvelope(null);
    } else if (methodCall.method == 'cancel') {
      return standardMethod.encodeSuccessEnvelope(null);
    } else {
      fail('Expected listen or cancel');
    }
  });
}

/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.
// TODO(ianh): Remove this once we roll stable in late 2021.
T? _ambiguate<T>(T? value) => value;
