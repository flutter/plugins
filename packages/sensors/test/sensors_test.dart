import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:sensors/sensors.dart';
import 'package:test/test.dart';

void main() {
  test('$accelerometerEvents are streamed', () async {
    const channelName = 'plugins.flutter.io/sensors/accelerometer';
    const sensorData = const <double>[1.0, 2.0, 3.0];

    const standardMethod = const StandardMethodCodec();
    const channel = const EventChannel(channelName);

    void emitEvent(ByteData event) {
      BinaryMessages.handlePlatformMessage(
        channelName,
        event,
        (ByteData reply) {},
      );
    }

    bool isCanceled = false;
    BinaryMessages.setMockMessageHandler(channelName, (message) async {
      final methodCall = standardMethod.decodeMethodCall(message);
      if (methodCall.method == 'listen') {
        emitEvent(standardMethod.encodeSuccessEnvelope(sensorData));
        emitEvent(null);
        return standardMethod.encodeSuccessEnvelope(null);
      } else if (methodCall.method == 'cancel') {
        isCanceled = true;
        return standardMethod.encodeSuccessEnvelope(null);
      } else {
        fail('Expected listen or cancel');
      }
    });

    final event = await accelerometerEvents.first;
    expect(event.x, 1.0);
    expect(event.y, 2.0);
    expect(event.z, 3.0);

    await new Future<Null>.delayed(Duration.zero);
    expect(isCanceled, isTrue);
  });
}
