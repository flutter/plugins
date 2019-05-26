// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$FirebasePerformance', () {
    FirebasePerformance performance;
    final List<MethodCall> log = <MethodCall>[];
    bool isPerformanceCollectionEnabledResult;

    int firebasePerformanceHandle;
    int nextHandle = 0;

    setUp(() {
      FirebasePerformance.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'FirebasePerformance#isPerformanceCollectionEnabled':
            return isPerformanceCollectionEnabledResult;
          default:
            return null;
        }
      });
      log.clear();
    });

    test('instance', () {
      firebasePerformanceHandle = nextHandle++;

      performance = FirebasePerformance.instance;

      expect(log, <Matcher>[
        isMethodCall(
          'FirebasePerformance#instance',
          arguments: <String, dynamic>{'handle': firebasePerformanceHandle},
        ),
      ]);
    });

    test('isPerformanceCollectionEnabled', () async {
      isPerformanceCollectionEnabledResult = true;
      final bool enabled = await performance.isPerformanceCollectionEnabled();
      expect(enabled, isTrue);

      isPerformanceCollectionEnabledResult = false;
      final bool disabled = await performance.isPerformanceCollectionEnabled();
      expect(disabled, isFalse);

      expect(log, <Matcher>[
        isMethodCall(
          'FirebasePerformance#isPerformanceCollectionEnabled',
          arguments: <String, dynamic>{'handle': firebasePerformanceHandle},
        ),
        isMethodCall(
          'FirebasePerformance#isPerformanceCollectionEnabled',
          arguments: <String, dynamic>{'handle': firebasePerformanceHandle},
        ),
      ]);
    });

    test('setPerformanceCollectionEnabled', () {
      performance.setPerformanceCollectionEnabled(true);
      performance.setPerformanceCollectionEnabled(false);

      expect(log, <Matcher>[
        isMethodCall(
          'FirebasePerformance#setPerformanceCollectionEnabled',
          arguments: <String, dynamic>{
            'handle': firebasePerformanceHandle,
            'enable': true,
          },
        ),
        isMethodCall(
          'FirebasePerformance#setPerformanceCollectionEnabled',
          arguments: <String, dynamic>{
            'handle': firebasePerformanceHandle,
            'enable': false,
          },
        ),
      ]);
    });

    test('newTrace', () {
      performance.newTrace('test-trace');

      expect(log, <Matcher>[
        isMethodCall(
          'FirebasePerformance#newTrace',
          arguments: <String, dynamic>{
            'handle': firebasePerformanceHandle,
            'traceHandle': nextHandle++,
            'name': 'test-trace',
          },
        ),
      ]);
    });

    test('newHttpMetric', () {
      final String url = 'https://google.com';
      performance.newHttpMetric(url, HttpMethod.Connect);

      expect(log, <Matcher>[
        isMethodCall(
          'FirebasePerformance#newHttpMetric',
          arguments: <String, dynamic>{
            'handle': firebasePerformanceHandle,
            'httpMetricHandle': nextHandle++,
            'url': url,
            'httpMethod': HttpMethod.Connect.toString(),
          },
        ),
      ]);
    });

    test('$HttpMethod', () {
      final String url = 'https://google.com';
      final HttpMethod method = HttpMethod.Connect;

      performance.newHttpMetric('https://google.com', method);

      expect(log, <Matcher>[
        isMethodCall(
          'FirebasePerformance#newHttpMetric',
          arguments: <String, dynamic>{
            'handle': firebasePerformanceHandle,
            'httpMetricHandle': nextHandle++,
            'url': url,
            'httpMethod': method.toString(),
          },
        ),
      ]);
    });

    group('$Trace', () {
      Trace testTrace;
      int currentTestTraceHandle;

      setUp(() {
        testTrace = performance.newTrace('test');
        currentTestTraceHandle = nextHandle++;
        log.clear();
      });

      test('start', () {
        testTrace.start();

        expect(log, <Matcher>[
          isMethodCall(
            'Trace#start',
            arguments: <String, dynamic>{'handle': currentTestTraceHandle},
          ),
        ]);
      });

      test('stop', () {
        testTrace.start();
        log.clear();

        testTrace.stop();

        expect(log, <Matcher>[
          isMethodCall(
            'Trace#stop',
            arguments: <String, dynamic>{'handle': currentTestTraceHandle},
          ),
        ]);
      });

      test('incrementMetric', () {
        testTrace.start();
        log.clear();

        final String name = 'metric1';
        final int increment = 3;
        testTrace.incrementMetric(name, increment);

        expect(log, <Matcher>[
          isMethodCall(
            'Trace#incrementMetric',
            arguments: <String, dynamic>{
              'handle': currentTestTraceHandle,
              'name': name,
              'value': increment,
            },
          ),
        ]);
      });
    });

    group('$HttpMetric', () {
      HttpMetric testMetric;
      int currentTestMetricHandle;

      setUp(() {
        testMetric = performance.newHttpMetric(
          'https://google.com',
          HttpMethod.Get,
        );
        currentTestMetricHandle = nextHandle++;
        log.clear();
      });

      test('start', () {
        testMetric.start();

        expect(log, <Matcher>[
          isMethodCall(
            'HttpMetric#start',
            arguments: <String, dynamic>{'handle': currentTestMetricHandle},
          ),
        ]);
      });

      test('stop', () {
        testMetric.start();
        log.clear();

        testMetric.stop();

        expect(log, <Matcher>[
          isMethodCall(
            'HttpMetric#stop',
            arguments: <String, dynamic>{'handle': currentTestMetricHandle},
          ),
        ]);
      });
    });

    group('$PerformanceAttributes', () {
      Trace attributeTrace;
      int currentTraceHandle;

      final Map<dynamic, dynamic> getAttributesResult = <dynamic, dynamic>{
        'a1': 'hello',
        'a2': 'friend',
      };

      setUp(() {
        FirebasePerformance.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'PerformanceAttributes#getAttributes':
              return getAttributesResult;
            default:
              return null;
          }
        });

        attributeTrace = performance.newTrace('trace');
        currentTraceHandle = nextHandle++;
        attributeTrace.start();
        log.clear();
      });

      test('putAttribute', () {
        final String name = 'attr1';
        final String value = 'apple';

        attributeTrace.putAttribute(name, value);

        expect(log, <Matcher>[
          isMethodCall(
            'PerformanceAttributes#putAttribute',
            arguments: <String, dynamic>{
              'handle': currentTraceHandle,
              'name': name,
              'value': value,
            },
          ),
        ]);
      });

      test('removeAttribute', () {
        final String name = 'attr1';
        attributeTrace.removeAttribute(name);

        expect(log, <Matcher>[
          isMethodCall(
            'PerformanceAttributes#removeAttribute',
            arguments: <String, dynamic>{
              'handle': currentTraceHandle,
              'name': name,
            },
          ),
        ]);
      });

      test('getAttributes', () async {
        final Map<String, String> result = await attributeTrace.getAttributes();

        expect(log, <Matcher>[
          isMethodCall(
            'PerformanceAttributes#getAttributes',
            arguments: <String, dynamic>{'handle': currentTraceHandle},
          ),
        ]);

        expect(result, getAttributesResult);
      });
    });
  });
}
