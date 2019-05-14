// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$FirebasePerformance', () {
    final List<MethodCall> performanceLog = <MethodCall>[];

    FirebasePerformance performance;
    int firebasePerformanceHandle;

    int nextHandle = 0;

    bool isPerformanceCollectionEnabledResult;

    setUpAll(() {
      FirebasePerformance.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        performanceLog.add(methodCall);
        switch (methodCall.method) {
          case 'FirebasePerformance#isPerformanceCollectionEnabled':
            return isPerformanceCollectionEnabledResult;
          default:
            return null;
        }
      });
    });

    setUp(() {
      performanceLog.clear();
    });

    test('instance', () {
      firebasePerformanceHandle = nextHandle++;
      performance = FirebasePerformance.instance;

      expect(performanceLog, <Matcher>[
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

      expect(performanceLog, <Matcher>[
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

      expect(performanceLog, <Matcher>[
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

      expect(performanceLog, <Matcher>[
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
      performance.newHttpMetric('https://google.com', HttpMethod.Connect);

      expect(performanceLog, <Matcher>[
        isMethodCall(
          'FirebasePerformance#newHttpMetric',
          arguments: <String, dynamic>{
            'handle': firebasePerformanceHandle,
            'httpMetricHandle': nextHandle++,
            'url': 'https://google.com',
            'httpMethod': HttpMethod.Connect.toString(),
          },
        ),
      ]);
    });

    test('startTrace', () {
      final int currentHandle = nextHandle++;
      FirebasePerformance.startTrace('test-start-trace');

      expect(performanceLog, <Matcher>[
        isMethodCall(
          'FirebasePerformance#newTrace',
          arguments: <String, dynamic>{
            'handle': firebasePerformanceHandle,
            'traceHandle': currentHandle,
            'name': 'test-start-trace',
          },
        ),
        isMethodCall(
          'Trace#start',
          arguments: <String, dynamic>{'handle': currentHandle},
        ),
      ]);
    });

    test('$HttpMethod', () {
      performance.newHttpMetric('https://google.com', HttpMethod.Delete);

      expect(performanceLog, <Matcher>[
        isMethodCall(
          'FirebasePerformance#newHttpMetric',
          arguments: <String, dynamic>{
            'handle': firebasePerformanceHandle,
            'httpMetricHandle': nextHandle++,
            'url': 'https://google.com',
            'httpMethod': HttpMethod.Delete.toString(),
          },
        ),
      ]);
    });

    group('$Trace', () {
      final List<MethodCall> traceLog = <MethodCall>[];

      Trace testTrace;
      int currentTestTraceHandle;

      setUpAll(() {
        FirebasePerformance.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          traceLog.add(methodCall);
          switch (methodCall.method) {
            case 'FirebasePerformance#isPerformanceCollectionEnabled':
              return isPerformanceCollectionEnabledResult;
            default:
              return null;
          }
        });
      });

      setUp(() {
        testTrace = performance.newTrace('test');
        currentTestTraceHandle = nextHandle++;

        traceLog.clear();
      });

      test('start', () {
        testTrace.start();

        expect(traceLog, <Matcher>[
          isMethodCall(
            'Trace#start',
            arguments: <String, dynamic>{'handle': currentTestTraceHandle},
          ),
        ]);
      });

      test('stop', () {
        testTrace.start();
        traceLog.clear();

        testTrace.stop();

        expect(traceLog, <Matcher>[
          isMethodCall(
            'Trace#stop',
            arguments: <String, dynamic>{'handle': currentTestTraceHandle},
          ),
        ]);
      });

      test('incrementMetric', () {
        testTrace.start();
        traceLog.clear();

        testTrace.incrementMetric('metric1', 3);

        expect(traceLog, <Matcher>[
          isMethodCall(
            'Trace#incrementMetric',
            arguments: <String, dynamic>{
              'handle': currentTestTraceHandle,
              'name': 'metric1',
              'value': 3,
            },
          ),
        ]);
      });

      test('setMetric', () {
        testTrace.start();
        traceLog.clear();

        testTrace.setMetric('metric3', 5);

        expect(traceLog, <Matcher>[
          isMethodCall(
            'Trace#setMetric',
            arguments: <String, dynamic>{
              'handle': currentTestTraceHandle,
              'name': 'metric3',
              'value': 5,
            },
          ),
        ]);
      });

      test('getMetric', () {
        testTrace.getMetric('metric4');

        expect(traceLog, <Matcher>[
          isMethodCall(
            'Trace#getMetric',
            arguments: <String, dynamic>{
              'handle': currentTestTraceHandle,
              'name': 'metric4',
            },
          ),
        ]);
      });

      test('invokeMethod not called if trace hasn\'t started', () {
        testTrace.incrementMetric('any', 211);
        testTrace.setMetric('what', 23);

        expect(traceLog, isEmpty);
      });

      test('invokeMethod not called if trace has stopped', () {
        testTrace.start();
        testTrace.stop();
        traceLog.clear();

        testTrace.start();
        testTrace.stop();
        testTrace.incrementMetric('any', 211);
        testTrace.setMetric('what', 23);
        testTrace.getMetric('efser');

        expect(traceLog, isEmpty);
      });
    });

    group('$HttpMetric', () {
      final List<MethodCall> httpMetricLog = <MethodCall>[];

      HttpMetric testMetric;
      int currentTestMetricHandle;

      setUpAll(() {
        FirebasePerformance.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          httpMetricLog.add(methodCall);
          switch (methodCall.method) {
            case 'FirebasePerformance#isPerformanceCollectionEnabled':
              return isPerformanceCollectionEnabledResult;
            default:
              return null;
          }
        });
      });

      setUp(() {
        testMetric = performance.newHttpMetric(
          'https://google.com',
          HttpMethod.Get,
        );
        currentTestMetricHandle = nextHandle++;

        httpMetricLog.clear();
      });

      test('start', () {
        testMetric.start();

        expect(httpMetricLog, <Matcher>[
          isMethodCall(
            'HttpMetric#start',
            arguments: <String, dynamic>{'handle': currentTestMetricHandle},
          ),
        ]);
      });

      test('stop', () {
        testMetric.start();
        httpMetricLog.clear();

        testMetric.stop();

        expect(httpMetricLog, <Matcher>[
          isMethodCall(
            'HttpMetric#stop',
            arguments: <String, dynamic>{'handle': currentTestMetricHandle},
          ),
        ]);
      });

      test('httpResponseCode', () {
        testMetric.httpResponseCode = 45;

        expect(httpMetricLog, <Matcher>[
          isMethodCall(
            'HttpMetric#httpResponseCode',
            arguments: <String, dynamic>{
              'handle': currentTestMetricHandle,
              'httpResponseCode': 45,
            },
          ),
        ]);
      });

      test('requestPayloadSize', () {
        testMetric.requestPayloadSize = 436;

        expect(httpMetricLog, <Matcher>[
          isMethodCall(
            'HttpMetric#requestPayloadSize',
            arguments: <String, dynamic>{
              'handle': currentTestMetricHandle,
              'requestPayloadSize': 436,
            },
          ),
        ]);
      });

      test('responseContentType', () {
        testMetric.responseContentType = 'hi';

        expect(httpMetricLog, <Matcher>[
          isMethodCall(
            'HttpMetric#responseContentType',
            arguments: <String, dynamic>{
              'handle': currentTestMetricHandle,
              'responseContentType': 'hi',
            },
          ),
        ]);
      });

      test('responsePayloadSize', () {
        testMetric.responsePayloadSize = 12;

        expect(httpMetricLog, <Matcher>[
          isMethodCall(
            'HttpMetric#responsePayloadSize',
            arguments: <String, dynamic>{
              'handle': currentTestMetricHandle,
              'responsePayloadSize': 12,
            },
          ),
        ]);
      });

      test('invokeMethod not called if httpMetric has stopped', () {
        testMetric.start();
        testMetric.stop();
        httpMetricLog.clear();

        testMetric.start();
        testMetric.stop();
        testMetric.httpResponseCode = 12;
        testMetric.requestPayloadSize = 23;
        testMetric.responseContentType = 'potato';
        testMetric.responsePayloadSize = 123;

        expect(httpMetricLog, isEmpty);
      });
    });

    group('$PerformanceAttributes', () {
      final List<MethodCall> attributeLog = <MethodCall>[];

      Trace attributeTrace;
      int currentTraceHandle;

      setUpAll(() {
        FirebasePerformance.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          attributeLog.add(methodCall);
          switch (methodCall.method) {
            case 'PerformanceAttributes#getAttributes':
              return <dynamic, dynamic>{
                'a1': 'hello',
                'a2': 'friend',
              };
            default:
              return null;
          }
        });
      });

      setUp(() {
        attributeTrace = performance.newTrace('trace');
        currentTraceHandle = nextHandle++;

        attributeLog.clear();
      });

      test('putAttribute', () {
        attributeTrace.putAttribute('attr1', 'apple');

        expect(attributeLog, <Matcher>[
          isMethodCall(
            'PerformanceAttributes#putAttribute',
            arguments: <String, dynamic>{
              'handle': currentTraceHandle,
              'name': 'attr1',
              'value': 'apple',
            },
          ),
        ]);
      });

      test('removeAttribute', () {
        attributeTrace.removeAttribute('attr14');

        expect(attributeLog, <Matcher>[
          isMethodCall(
            'PerformanceAttributes#removeAttribute',
            arguments: <String, dynamic>{
              'handle': currentTraceHandle,
              'name': 'attr14',
            },
          ),
        ]);
      });

      test('getAttributes', () async {
        final Map<String, String> result = await attributeTrace.getAttributes();

        expect(attributeLog, <Matcher>[
          isMethodCall(
            'PerformanceAttributes#getAttributes',
            arguments: <String, dynamic>{'handle': currentTraceHandle},
          ),
        ]);

        expect(result, <dynamic, dynamic>{'a1': 'hello', 'a2': 'friend'});
      });

      test('invokeMethod not called if trace has stopped', () {
        attributeTrace.start();
        attributeTrace.stop();
        attributeLog.clear();

        attributeTrace.putAttribute('tonto', 'orale');
        attributeTrace.removeAttribute('ewfo');
        attributeTrace.getAttributes();

        expect(attributeLog, isEmpty);
      });
    });
  });
}
