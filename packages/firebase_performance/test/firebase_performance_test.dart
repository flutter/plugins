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

    setUp(() {
      FirebasePerformance.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'FirebasePerformance#isPerformanceCollectionEnabled':
            return true;
          default:
            return null;
        }
      });
      log.clear();
    });

    test('isPerformanceCollectionEnabled', () async {
      final bool enabled = await performance.isPerformanceCollectionEnabled();

      expect(enabled, isTrue);
      expect(log, <Matcher>[
        isMethodCall(
          'FirebasePerformance#isPerformanceCollectionEnabled',
          arguments: null,
        ),
      ]);
    });

    test('setPerformanceCollectionEnabled', () async {
      await performance.setPerformanceCollectionEnabled(true);
      await performance.setPerformanceCollectionEnabled(false);

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

      await pumpEventQueue();

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

    test('newHttpMetric', () async {
      final String url = 'https://google.com';

      final HttpMetric metric = performance.newHttpMetric(
        url,
        HttpMethod.Connect,
      );

      await pumpEventQueue();

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

    test('$HttpMethod', () async {
      final String url = 'https://google.com';

      for (HttpMethod method in HttpMethod.values) {
        final HttpMetric metric = performance.newHttpMetric(
          'https://google.com',
          method,
        );

        await pumpEventQueue();

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

        log.clear();
      }
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

      test('start', () async {
        await pumpEventQueue();

        await testTrace.start();

        expect(traceLog, <Matcher>[
          isMethodCall('Trace#start', arguments: null),
        ]);
      });

      test('stop', () async {
        await pumpEventQueue();

        await testTrace.stop();

        expect(traceLog, <Matcher>[
          isMethodCall('Trace#stop', arguments: null),
        ]);
      });

      test('incrementMetric', () async {
        await pumpEventQueue();

        final String name = 'counter1';
        final int value = 45;

        testTrace.incrementMetric(name, value);

        expect(traceLog, <Matcher>[
          isMethodCall(
            'Trace#incrementMetric',
            arguments: <String, dynamic>{
              'name': name,
              'value': value,
            },
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

      test('start', () async {
        await pumpEventQueue();

        await testMetric.start();

        expect(httpMetricLog, <Matcher>[
          isMethodCall('HttpMetric#start', arguments: null),
        ]);
      });

      test('stop', () async {
        await pumpEventQueue();

        await testMetric.stop();

        expect(httpMetricLog, <Matcher>[
          isMethodCall('HttpMetric#stop', arguments: null),
        ]);
      });
    });

    group('$PerformanceAttributes', () {
      final PerformanceAttributes attributes = MockPerformanceAttributes();
      final List<MethodCall> attributeLog = <MethodCall>[];
      final Map<dynamic, dynamic> getAttributesResult = <dynamic, dynamic>{
        'a1': 'hello',
        'a2': 'friend',
      };

      setUp(() {
        MockPerformanceAttributes._channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          attributeLog.add(methodCall);
          if (methodCall.method == 'PerformanceAttributes#getAttributes') {
            return getAttributesResult;
          }

          return null;
        });
        attributeLog.clear();
      });

      test('putAttribute', () async {
        final String attribute = 'attr1';
        final String value = 'apple';
        await attributes.putAttribute(attribute, value);

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

      test('removeAttribute', () async {
        final String attribute = 'attr1';
        await attributes.removeAttribute(attribute);

        expect(attributeLog, <Matcher>[
          isMethodCall(
            'PerformanceAttributes#removeAttribute',
            arguments: attribute,
          ),
        ]);
      });

      test('getAttributes', () async {
        final Map<String, String> result = await attributes.getAttributes();

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

class MockPerformanceAttributes extends PerformanceAttributes {
  static MethodChannel _channel = const MethodChannel('testMethodChannel');

  @override
  MethodChannel get methodChannel => _channel;
}
