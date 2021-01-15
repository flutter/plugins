// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart' show TestWidgetsFlutterBinding;
import 'package:sensors/sensors.dart';
import 'package:test/test.dart';

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

  void _emitEvent(ByteData event) {
    ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
      channelName,
      event,
      (ByteData reply) {},
    );
  }

  ServicesBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(channelName, (ByteData message) async {
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
