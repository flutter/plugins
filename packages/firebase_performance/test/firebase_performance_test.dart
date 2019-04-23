// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$FirebasePerformance', () {
    final FirebasePerformance performance = FirebasePerformance.instance;
    final List<MethodCall> log = <MethodCall>[];
    bool isPerformanceCollectionEnabledResult;

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
          arguments: null,
        ),
        isMethodCall(
          'FirebasePerformance#isPerformanceCollectionEnabled',
          arguments: null,
        ),
      ]);
    });

    test('setPerformanceCollectionEnabled', () {
      performance.setPerformanceCollectionEnabled(true);
      performance.setPerformanceCollectionEnabled(false);

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

    test('newTrace', () {
      final Trace trace = performance.newTrace('test-trace');

      expect(log, <Matcher>[
        isMethodCall(
          'FirebasePerformance#newTrace',
          arguments: <String, dynamic>{
            'channelName': trace.channel.name,
            'traceName': 'test-trace',
          },
        ),
      ]);
    });

    test('newHttpMetric', () {
      final String url = 'https://google.com';

      final HttpMetric metric = performance.newHttpMetric(
        url,
        HttpMethod.Connect,
      );

      expect(log, <Matcher>[
        isMethodCall(
          'FirebasePerformance#newHttpMetric',
          arguments: <String, dynamic>{
            'channelName': metric.channel.name,
            'url': url,
            'httpMethod': HttpMethod.Connect.toString(),
          },
        ),
      ]);
    });

    test('$HttpMethod', () {
      final String url = 'https://google.com';
      final HttpMethod method = HttpMethod.Connect;

      final HttpMetric metric = performance.newHttpMetric(
        'https://google.com',
        method,
      );

      expect(log, <Matcher>[
        isMethodCall(
          'FirebasePerformance#newHttpMetric',
          arguments: <String, dynamic>{
            'channelName': metric.channel.name,
            'url': url,
            'httpMethod': method.toString(),
          },
        ),
      ]);
    });

    group('$Trace', () {
      Trace testTrace;
      final List<MethodCall> traceLog = <MethodCall>[];

      setUp(() {
        testTrace = performance.newTrace('test');
        testTrace.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          traceLog.add(methodCall);
          switch (methodCall.method) {
            case 'FirebasePerformance#isPerformanceCollectionEnabled':
              return true;
            default:
              return null;
          }
        });
        traceLog.clear();
      });

      test('start', () {
        testTrace.start();

        expect(traceLog, <Matcher>[
          isMethodCall('Trace#start', arguments: null),
        ]);
      });

      test('stop', () {
        testTrace.stop();

        expect(traceLog, <Matcher>[
          isMethodCall('Trace#stop', arguments: null),
        ]);
      });

      test('incrementMetric', () {
        final String name = 'counter1';
        final int value = 45;
        final int increment = 3;

        testTrace.start();
        testTrace.putMetric(name, value);
        traceLog.clear();

        testTrace.incrementMetric(name, increment);

        expect(traceLog, <Matcher>[
          isMethodCall(
            'Trace#incrementMetric',
            arguments: <String, dynamic>{'name': name, 'value': increment},
          ),
        ]);
      });
    });

    group('$HttpMetric', () {
      HttpMetric testMetric;
      final List<MethodCall> httpMetricLog = <MethodCall>[];

      setUp(() {
        testMetric = performance.newHttpMetric(
          'https://google.com',
          HttpMethod.Get,
        );
        testMetric.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          httpMetricLog.add(methodCall);
          switch (methodCall.method) {
            case 'FirebasePerformance#isPerformanceCollectionEnabled':
              return true;
            default:
              return null;
          }
        });
        httpMetricLog.clear();
      });

      test('start', () {
        testMetric.start();

        expect(httpMetricLog, <Matcher>[
          isMethodCall('HttpMetric#start', arguments: null),
        ]);
      });

      test('stop', () {
        testMetric.stop();

        expect(httpMetricLog, <Matcher>[
          isMethodCall('HttpMetric#stop', arguments: null),
        ]);
      });
    });

    group('$PerformanceAttributes', () {
      Trace attributeTrace;
      final List<MethodCall> attributeLog = <MethodCall>[];
      final Map<dynamic, dynamic> getAttributesResult = <dynamic, dynamic>{
        'a1': 'hello',
        'a2': 'friend',
      };

      setUp(() {
        attributeTrace = performance.newTrace('trace');
        attributeTrace.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          attributeLog.add(methodCall);
          if (methodCall.method == 'PerformanceAttributes#getAttributes') {
            return getAttributesResult;
          }

          return null;
        });

        attributeTrace.start();
        attributeLog.clear();
      });

      test('putAttribute', () {
        final String attribute = 'attr1';
        final String value = 'apple';

        attributeTrace.putAttribute(attribute, value);

        expect(attributeLog, <Matcher>[
          isMethodCall(
            'PerformanceAttributes#putAttribute',
            arguments: <String, dynamic>{
              'attribute': attribute,
              'value': value,
            },
          ),
        ]);
      });

      test('removeAttribute', () {
        final String attribute = 'attr1';
        attributeTrace.removeAttribute(attribute);

        expect(attributeLog, <Matcher>[
          isMethodCall(
            'PerformanceAttributes#removeAttribute',
            arguments: attribute,
          ),
        ]);
      });

      test('getAttributes', () async {
        final Map<String, String> result = await attributeTrace.getAttributes();

        expect(attributeLog, <Matcher>[
          isMethodCall(
            'PerformanceAttributes#getAttributes',
            arguments: null,
          ),
        ]);

        expect(result, getAttributesResult);
      });
    });
  });
}
