// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.9

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensors/sensors.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can subscript to accelerometerEvents and get non-null events',
      (WidgetTester tester) async {
    final Completer<AccelerometerEvent> completer =
        Completer<AccelerometerEvent>();
    StreamSubscription<AccelerometerEvent> subscription;
    subscription = accelerometerEvents.listen((AccelerometerEvent event) {
      completer.complete(event);
      subscription.cancel();
    });
    expect(await completer.future, isNotNull);
  });
}
