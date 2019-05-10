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

    test('metric', () async {
      final Trace trace = performance.newTrace('test');
      trace.putAttribute('testAttribute', 'foo');
      trace.attributes['testAttribute2'] = 'bar';
      await trace.start();
      trace.incrementMetric('testMetric', 1);
      await trace.stop();
      expect(trace.getAttribute('testAttribute'), 'foo');
      expect(trace.attributes['testAttribute'], 'foo');
      expect(trace.getAttribute('testAttribute2'), null);
      expect(trace.getAttribute('testMetric'), null);
    });
  });
}
