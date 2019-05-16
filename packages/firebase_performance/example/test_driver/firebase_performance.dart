// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_performance/firebase_performance.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('firebase_performance', () {
    final FirebasePerformance performance = FirebasePerformance.instance;

    group('$FirebasePerformance', () {
      test('setPerformanceCollectionEnabled', () {
        performance.setPerformanceCollectionEnabled(true);
        expect(
          performance.isPerformanceCollectionEnabled(),
          completion(isTrue),
        );

        performance.setPerformanceCollectionEnabled(false);
        expect(
          performance.isPerformanceCollectionEnabled(),
          completion(isFalse),
        );
      });
    });

    group('$HttpMethod', () {
      test('test all values', () {
        for (HttpMethod method in HttpMethod.values) {
          final HttpMetric testMetric = performance.newHttpMetric(
            'https://www.google.com/',
            method,
          );
          testMetric.start();
          testMetric.stop();
        }
      });
    });

    group('$Trace', () {
      Trace testTrace;

      setUpAll(() {
        performance.setPerformanceCollectionEnabled(true);
      });

      setUp(() {
        testTrace = performance.newTrace('test-trace');
      });

      tearDown(() {
        testTrace.stop();
        testTrace = null;
      });

      test('incrementMetric', () {
        testTrace.start();

        testTrace.incrementMetric('metric', 14);
        expectLater(testTrace.getMetric('metric'), completion(14));

        testTrace.incrementMetric('metric', 45);
        expect(testTrace.getMetric('metric'), completion(59));
      });

      test('setMetric', () {
        testTrace.start();

        testTrace.setMetric('metric2', 37);
        expect(testTrace.getMetric('metric2'), completion(37));
      });

      test('putAttribute', () {
        testTrace.putAttribute('apple', 'sauce');
        testTrace.putAttribute('banana', 'pie');

        expect(
          testTrace.getAttributes(),
          completion(<String, String>{'apple': 'sauce', 'banana': 'pie'}),
        );
      });

      test('removeAttribute', () {
        testTrace.putAttribute('sponge', 'bob');
        testTrace.putAttribute('patrick', 'star');
        testTrace.removeAttribute('sponge');

        expect(
          testTrace.getAttributes(),
          completion(<String, String>{'patrick': 'star'}),
        );
      });

      test('getAttributes', () {
        testTrace.putAttribute('yugi', 'oh');

        expect(
          testTrace.getAttributes(),
          completion(<String, String>{'yugi': 'oh'}),
        );

        testTrace.start();
        testTrace.stop();
        expect(
          testTrace.getAttributes(),
          completion(<String, String>{'yugi': 'oh'}),
        );
      });
    });

    group('$HttpMetric', () {
      HttpMetric testMetric;

      setUpAll(() {
        performance.setPerformanceCollectionEnabled(true);
      });

      setUp(() {
        testMetric = performance.newHttpMetric(
          'https://www.google.com/',
          HttpMethod.Delete,
        );
      });

      test('putAttribute', () {
        testMetric.putAttribute('apple', 'sauce');
        testMetric.putAttribute('banana', 'pie');

        expect(
          testMetric.getAttributes(),
          completion(<String, String>{'apple': 'sauce', 'banana': 'pie'}),
        );
      });

      test('removeAttribute', () {
        testMetric.putAttribute('sponge', 'bob');
        testMetric.putAttribute('patrick', 'star');
        testMetric.removeAttribute('sponge');

        expect(
          testMetric.getAttributes(),
          completion(<String, String>{'patrick': 'star'}),
        );
      });

      test('getAttributes', () {
        testMetric.putAttribute('yugi', 'oh');

        expect(
          testMetric.getAttributes(),
          completion(<String, String>{'yugi': 'oh'}),
        );

        testMetric.start();
        testMetric.stop();
        expect(
          testMetric.getAttributes(),
          completion(<String, String>{'yugi': 'oh'}),
        );
      });

      test('http setters shouldn\'t cause a crash', () async {
        testMetric.start();

        testMetric.httpResponseCode = 443;
        testMetric.requestPayloadSize = 56734;
        testMetric.responseContentType = '1984';
        testMetric.responsePayloadSize = 4949;

        await pumpEventQueue();
      });
    });
  });
}
