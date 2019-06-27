// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('$FirebaseAnalytics', () {
    FirebaseAnalytics analytics;

    setUp(() {
      analytics = FirebaseAnalytics();
    });

    test('Android-only functionality', () async {
      if (Platform.isIOS) {
        expect(analytics.android, isNull);
      }
      if (Platform.isAndroid) {
        await analytics.android.setMinimumSessionDuration(9000);
      }
    });

    test('logging', () async {
      expect(analytics.setAnalyticsCollectionEnabled(true), completes);
      expect(analytics.setCurrentScreen(screenName: 'testing'), completes);
      expect(analytics.logEvent(name: 'testing'), completes);
    });
  });
}
