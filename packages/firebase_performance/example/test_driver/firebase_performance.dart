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

    test('setPerformanceCollectionEnabled', () async {
      await performance.setPerformanceCollectionEnabled(true);

      final bool enabled = await performance.isPerformanceCollectionEnabled();
      expect(enabled, isTrue);

      await performance.setPerformanceCollectionEnabled(false);
      final bool disabled = await performance.isPerformanceCollectionEnabled();
      expect(disabled, isFalse);
    });
  });
}
