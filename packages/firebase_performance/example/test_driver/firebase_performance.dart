import 'dart:async';

import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_performance/firebase_performance.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('firebase_performance test driver', () {
    final FirebasePerformance performance = FirebasePerformance.instance;

    setUp(() async {
      await performance.setPerformanceCollectionEnabled(true);
    });

    test('setPerformanceCollectionEnabled', () async {
      final bool enabled = await performance.isPerformanceCollectionEnabled();
      expect(enabled, isTrue);

      await performance.setPerformanceCollectionEnabled(false);
      final bool disabled = await performance.isPerformanceCollectionEnabled();
      expect(disabled, isFalse);
    });

    test('trace', () async {
      final Trace trace = performance.newTrace('test');

      await trace.start();

      trace.putAttribute('testAttribute', 'foo');
      final Map<String, String> attributes = await trace.getAttributes();
      expect(attributes, <String, String>{'testAttribute': 'foo'});

      trace.incrementMetric('testMetric', 22);
      final int metric = await trace.getMetric('testMetric');
      expect(metric, 22);

      trace.setMetric('testMetric2', 33);
      final int metric2 = await trace.getMetric('testMetric2');
      expect(metric2, 33);

      await trace.stop();
    });

    test('httpmetric', () async {
      final HttpMetric httpMetric = performance.newHttpMetric(
        'https://www.google.com',
        HttpMethod.Connect,
      );

      await httpMetric.start();

      httpMetric.putAttribute('testAttribute', 'foo');
      final Map<String, String> attributes = await httpMetric.getAttributes();
      expect(attributes, <String, String>{'testAttribute': 'foo'});

      httpMetric.httpResponseCode = 45;
      httpMetric.requestPayloadSize = 45;
      httpMetric.responseContentType = 'testString';
      httpMetric.responsePayloadSize = 45;

      await httpMetric.stop();
    });
  });
}
