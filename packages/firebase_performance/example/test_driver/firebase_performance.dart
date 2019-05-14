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

  final FirebasePerformance performance = FirebasePerformance.instance;

  group('firebase_performance', () {
    group('$FirebasePerformance', () {
      setUpAll(() {
        performance.setPerformanceCollectionEnabled(true);
      });

      test('setPerformanceCollectionEnabled', () async {
        final bool enabled = await performance.isPerformanceCollectionEnabled();
        expect(enabled, isTrue);

        await performance.setPerformanceCollectionEnabled(false);
        final bool disabled =
            await performance.isPerformanceCollectionEnabled();
        expect(disabled, isFalse);
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
      test('incrementMetric', () async {
        final Trace testTrace = performance.newTrace('test-trace');
        testTrace.start();
        testTrace.incrementMetric('metric', 14);

        final int value = await testTrace.getMetric('metric');
        expect(value, 14);

        testTrace.incrementMetric('metric', 45);
        final int value2 = await testTrace.getMetric('metric');
        expect(value2, 59);

        testTrace.stop();
      });

      test('setMetric', () async {
        final Trace testTrace = performance.newTrace('test-trace');
        testTrace.start();
        testTrace.setMetric('metric2', 37);

        final int value = await testTrace.getMetric('metric2');
        expect(value, 37);

        testTrace.stop();
      });

      test('putAttribute', () async {
        final Trace testTrace = performance.newTrace('test-trace');
        testTrace.start();

        testTrace.putAttribute('apple', 'sauce');
        testTrace.putAttribute('banana', 'pie');

        final Map<String, String> attributes = await testTrace.getAttributes();
        expect(attributes, <String, String>{'apple': 'sauce', 'banana': 'pie'});

        testTrace.stop();
      });

      test('removeAttribute', () async {
        final Trace testTrace = performance.newTrace('test-trace');
        testTrace.start();

        testTrace.putAttribute('sponge', 'bob');
        testTrace.putAttribute('patrick', 'start');
        testTrace.removeAttribute('sponge');

        final Map<String, String> attributes = await testTrace.getAttributes();
        expect(attributes, <String, String>{'patrick': 'start'});

        testTrace.stop();
      });

      test('getAttributes', () async {
        final Trace testTrace = performance.newTrace('test-trace');
        testTrace.start();

        testTrace.putAttribute('yu-gi', '-oh');

        final Map<String, String> attributes = await testTrace.getAttributes();
        expect(attributes, <String, String>{'yu-gi': '-oh'});

        testTrace.stop();

        final Map<String, String> attributes2 = await testTrace.getAttributes();
        expect(attributes2, <String, String>{'yu-gi': '-oh'});
      });

      test('make sure all methods won\'t cause a crash', () {
        final Trace testTrace = performance.newTrace('test-trace');
        testTrace.start();
        testTrace.setMetric('34', 23);
        testTrace.incrementMetric('er', 234);
        testTrace.getMetric('er');
        testTrace.putAttribute('234', 'erwr');
        testTrace.removeAttribute('234');
        testTrace.getAttributes();
        testTrace.stop();
      });
    });

    group('$HttpMetric', () {
      test('putAttribute', () async {
        final HttpMetric testMetric = performance.newHttpMetric(
          'https://www.google.com/',
          HttpMethod.Delete,
        );
        testMetric.start();

        testMetric.putAttribute('apple', 'sauce');
        testMetric.putAttribute('banana', 'pie');

        final Map<String, String> attributes = await testMetric.getAttributes();
        expect(attributes, <String, String>{'apple': 'sauce', 'banana': 'pie'});

        testMetric.stop();
      });

      test('removeAttribute', () async {
        final HttpMetric testMetric = performance.newHttpMetric(
          'https://www.insidejob.org/',
          HttpMethod.Connect,
        );
        testMetric.start();

        testMetric.putAttribute('sponge', 'bob');
        testMetric.putAttribute('patrick', 'start');
        testMetric.removeAttribute('sponge');

        final Map<String, String> attributes = await testMetric.getAttributes();
        expect(attributes, <String, String>{'patrick': 'start'});

        testMetric.stop();
      });

      test('getAttributes', () async {
        final HttpMetric testMetric = performance.newHttpMetric(
          'https://www.flutter.dev/',
          HttpMethod.Trace,
        );
        testMetric.start();

        testMetric.putAttribute('yu-gi', '-oh');

        final Map<String, String> attributes = await testMetric.getAttributes();
        expect(attributes, <String, String>{'yu-gi': '-oh'});

        testMetric.stop();

        final Map<String, String> attributes2 =
            await testMetric.getAttributes();
        expect(attributes2, <String, String>{'yu-gi': '-oh'});
      });

      test('make sure all methods won\'t cause a crash', () {
        final HttpMetric testMetric = performance.newHttpMetric(
          'https://www.whereswaldo.do/',
          HttpMethod.Head,
        );
        testMetric.start();
        testMetric.httpResponseCode = 443;
        testMetric.requestPayloadSize = 56734;
        testMetric.responseContentType = '1984';
        testMetric.responsePayloadSize = 4949;
        testMetric.putAttribute('234', 'erwr');
        testMetric.removeAttribute('234');
        testMetric.getAttributes();
        testMetric.stop();
      });
    });
  });
}
