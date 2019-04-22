// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';

class MockPerformanceAttributes extends PerformanceAttributes {}

void main() {
  group('$FirebasePerformance', () {
    final FirebasePerformance performance = FirebasePerformance.instance;
    final List<MethodCall> log = <MethodCall>[];
    bool performanceCollectionEnable = true;
    int currentTraceHandle;
    int currentHttpMetricHandle;

    setUp(() {
      FirebasePerformance.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'FirebasePerformance#isPerformanceCollectionEnabled':
            return performanceCollectionEnable;
          case 'FirebasePerformance#setPerformanceCollectionEnabled':
            performanceCollectionEnable = methodCall.arguments;
            return null;
          case 'Trace#start':
            currentTraceHandle = methodCall.arguments['handle'];
            return null;
          case 'Trace#stop':
            return null;
          case 'HttpMetric#start':
            currentHttpMetricHandle = methodCall.arguments['handle'];
            return null;
          case 'HttpMetric#stop':
            return null;
          default:
            return null;
        }
      });
      log.clear();
    });

    test('isPerformanceCollectionEnabled', () async {
      final bool enabled = await performance.isPerformanceCollectionEnabled();

      expect(performanceCollectionEnable, enabled);
      expect(log, <Matcher>[
        isMethodCall(
          'FirebasePerformance#isPerformanceCollectionEnabled',
          arguments: null,
        ),
      ]);
    });

    test('setPerformanceCollectionEnabled', () async {
      await performance.setPerformanceCollectionEnabled(true);
      performanceCollectionEnable = true;

      await performance.setPerformanceCollectionEnabled(false);
      performanceCollectionEnable = false;

      expect(log, <Matcher>[
        isMethodCall(
          'FirebasePerformance#setPerformanceCollectionEnabled',
          arguments: true,
        ),
        isMethodCall(
          'FirebasePerformance#setPerformanceCollectionEnabled',
          arguments: false,
        ),
      ]);
    });

    test('newTrace', () async {
      final Trace trace = performance.newTrace('test-trace');
      await trace.start();

      expect(log, <Matcher>[
        isMethodCall(
          'Trace#start',
          arguments: <String, Object>{
            'handle': currentTraceHandle,
            'name': 'test-trace',
          },
        ),
      ]);
    });

    test('newHttpMetric', () async {
      final HttpMetric metric = performance.newHttpMetric(
        'https://google.com',
        HttpMethod.Connect,
      );
      await metric.start();

      expect(log, <Matcher>[
        isMethodCall(
          'HttpMetric#start',
          arguments: <String, Object>{
            'handle': currentTraceHandle,
            'url': 'https://google.com',
            'httpMethod': HttpMethod.Connect.index,
          },
        ),
      ]);
    });

    test('startTrace', () async {
      await FirebasePerformance.startTrace('startTrace-test');

      expect(log, <Matcher>[
        isMethodCall(
          'Trace#start',
          arguments: <String, Object>{
            'handle': currentTraceHandle,
            'name': 'startTrace-test',
          },
        ),
      ]);
    });

    test('$HttpMethod', () async {
      expect(HttpMethod.Connect.index, 0);
      expect(HttpMethod.Delete.index, 1);
      expect(HttpMethod.Get.index, 2);
      expect(HttpMethod.Head.index, 3);
      expect(HttpMethod.Options.index, 4);
      expect(HttpMethod.Patch.index, 5);
      expect(HttpMethod.Post.index, 6);
      expect(HttpMethod.Put.index, 7);
      expect(HttpMethod.Trace.index, 8);
    });

    group('$Trace', () {
      Trace testTrace;

      setUp(() {
        testTrace = performance.newTrace('test');
      });

      test('start', () async {
        await testTrace.start();

        expect(log, <Matcher>[
          isMethodCall(
            'Trace#start',
            arguments: <String, Object>{
              'handle': currentTraceHandle,
              'name': 'test',
            },
          ),
        ]);
      });

      test('stop', () async {
        await testTrace.start();
        await testTrace.stop();

        expect(log, <Matcher>[
          isMethodCall('Trace#start', arguments: <String, Object>{
            'handle': currentTraceHandle,
            'name': 'test',
          }),
          isMethodCall(
            'Trace#stop',
            arguments: <String, dynamic>{
              'handle': currentTraceHandle,
              'name': 'test',
              'metrics': <String, int>{},
              'attributes': <String, String>{},
            },
          ),
        ]);
      });

      test('incrementCounter', () async {
        final Trace trace = performance.newTrace('test');

        // ignore: deprecated_member_use_from_same_package
        trace.incrementCounter('counter1');

        // ignore: deprecated_member_use_from_same_package
        trace.incrementCounter('counter2');
        // ignore: deprecated_member_use_from_same_package
        trace.incrementCounter('counter2');

        // ignore: deprecated_member_use_from_same_package
        trace.incrementCounter('counter3', 5);
        // ignore: deprecated_member_use_from_same_package
        trace.incrementCounter('counter3', 5);

        // ignore: deprecated_member_use_from_same_package
        trace.incrementCounter('counter4', -5);

        await trace.start();
        await trace.stop();

        expect(log, <Matcher>[
          isMethodCall(
            'Trace#start',
            arguments: <String, Object>{
              'handle': currentTraceHandle,
              'name': 'test',
            },
          ),
          isMethodCall(
            'Trace#stop',
            arguments: <String, dynamic>{
              'handle': currentTraceHandle,
              'name': 'test',
              'metrics': <String, int>{
                'counter1': 1,
                'counter2': 2,
                'counter3': 10,
                'counter4': -5,
              },
              'attributes': <String, String>{},
            },
          ),
        ]);
      });

      test('incrementMetric', () async {
        final Trace trace = performance.newTrace('test');
        trace.incrementMetric('metric1', 1);

        trace.incrementMetric('metric2', 1);
        trace.incrementMetric('metric2', 1);

        trace.incrementMetric('metric3', 5);
        trace.incrementMetric('metric3', 5);

        trace.incrementMetric('metric4', -5);

        await trace.start();
        await trace.stop();

        expect(log, <Matcher>[
          isMethodCall(
            'Trace#start',
            arguments: <String, Object>{
              'handle': currentTraceHandle,
              'name': 'test',
            },
          ),
          isMethodCall(
            'Trace#stop',
            arguments: <String, dynamic>{
              'handle': currentTraceHandle,
              'name': 'test',
              'metrics': <String, int>{
                'metric1': 1,
                'metric2': 2,
                'metric3': 10,
                'metric4': -5,
              },
              'attributes': <String, String>{},
            },
          ),
        ]);
      });
    });

    group('$HttpMetric', () {
      HttpMetric testMetric;

      setUp(() {
        testMetric = performance.newHttpMetric(
          'https://google.com',
          HttpMethod.Get,
        );
      });

      test('start', () async {
        await testMetric.start();

        expect(log, <Matcher>[
          isMethodCall(
            'HttpMetric#start',
            arguments: <String, Object>{
              'handle': currentHttpMetricHandle,
              'url': 'https://google.com',
              'httpMethod': HttpMethod.Get.index,
            },
          ),
        ]);
      });

      test('stop', () async {
        testMetric.httpResponseCode = 1;
        testMetric.requestPayloadSize = 5000000;
        testMetric.responseContentType = 'text/html';
        testMetric.responsePayloadSize = 1992304820934820;

        await testMetric.start();
        await testMetric.stop();

        expect(log, <Matcher>[
          isMethodCall(
            'HttpMetric#start',
            arguments: <String, Object>{
              'handle': currentHttpMetricHandle,
              'url': 'https://google.com',
              'httpMethod': HttpMethod.Get.index,
            },
          ),
          isMethodCall(
            'HttpMetric#stop',
            arguments: <String, dynamic>{
              'handle': currentHttpMetricHandle,
              'httpResponseCode': 1,
              'requestPayloadSize': 5000000,
              'responseContentType': 'text/html',
              'responsePayloadSize': 1992304820934820,
              'attributes': <String, String>{},
            },
          ),
        ]);
      });
    });

    group('$PerformanceAttributes', () {
      PerformanceAttributes attributes;

      setUp(() {
        attributes = MockPerformanceAttributes();
      });

      test('putAttribute', () async {
        attributes.putAttribute('attr1', 'apple');
        attributes.putAttribute('attr2', 'are');
        expect(attributes.attributes, <String, String>{
          'attr1': 'apple',
          'attr2': 'are',
        });

        attributes.putAttribute('attr1', 'delicious');
        expect(attributes.attributes, <String, String>{
          'attr1': 'delicious',
          'attr2': 'are',
        });
      });

      test('removeAttribute', () async {
        attributes.putAttribute('attr1', 'apple');
        attributes.putAttribute('attr2', 'are');
        attributes.removeAttribute('no-attr');
        expect(attributes.attributes, <String, String>{
          'attr1': 'apple',
          'attr2': 'are',
        });

        attributes.removeAttribute('attr1');
        expect(attributes.attributes, <String, String>{
          'attr2': 'are',
        });
      });

      test('getAttribute', () {
        attributes.putAttribute('attr1', 'apple');
        attributes.putAttribute('attr2', 'are');
        expect(attributes.getAttribute('attr1'), 'apple');

        expect(attributes.getAttribute('attr3'), isNull);
      });
    });
  });
}
