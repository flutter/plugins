import 'dart:async';

import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('firebase_performance test driver', () {
    final FirebaseVision vision = FirebaseVision.instance;

    test('setPerformanceCollectionEnabled', () async {});
  });
}
