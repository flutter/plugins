import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:sensors/sensors.dart';
import 'package:test/test.dart';

void main() {
  test('$accelerometerEvents are streamed', () async {
    const String channelName = 'plugins.flutter.io/sensors/accelerometer';
    const List<double> sensorData = <double>[1.0, 2.0, 3.0];

    const StandardMethodCodec standardMethod = StandardMethodCodec();

    void emitEvent(ByteData event) {
      BinaryMessages.handlePlatformMessage(
        channelName,
        event,
        (ByteData reply) {},
      );
    }

    bool isCanceled = false;
    BinaryMessages.setMockMessageHandler(channelName, (ByteData message) async {
      final MethodCall methodCall = standardMethod.decodeMethodCall(message);
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

    final AccelerometerEvent event = await accelerometerEvents.first;
    expect(event.x, 1.0);
    expect(event.y, 2.0);
    expect(event.z, 3.0);

    await Future<Null>.delayed(Duration.zero);
    expect(isCanceled, isTrue);
  });
}
