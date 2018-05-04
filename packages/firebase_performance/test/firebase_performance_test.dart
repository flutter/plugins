// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$FirebasePerformance', () {
    final FirebasePerformance performance = FirebasePerformance.instance;
    final List<MethodCall> log = <MethodCall>[];
    bool performanceCollectionEnable = true;
    int currentTraceHandle;

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
        isMethodCall('FirebasePerformance#isPerformanceCollectionEnabled',
            arguments: null),
      ]);
    });

    test('setPerformanceCollectionEnabled', () async {
      await performance.setPerformanceCollectionEnabled(true);
      performanceCollectionEnable = true;

      await performance.setPerformanceCollectionEnabled(false);
      performanceCollectionEnable = false;

      expect(log, <Matcher>[
        isMethodCall('FirebasePerformance#setPerformanceCollectionEnabled',
            arguments: true),
        isMethodCall('FirebasePerformance#setPerformanceCollectionEnabled',
            arguments: false),
      ]);
    });

    test('newTrace', () async {
      final Trace trace = performance.newTrace('test-trace');
      await trace.start();

      expect(log, <Matcher>[
        isMethodCall('Trace#start', arguments: <String, Object>{
          'handle': currentTraceHandle,
          'name': 'test-trace',
        }),
      ]);
    });

    test('startTrace', () async {
      await FirebasePerformance.startTrace('startTrace-test');

      expect(log, <Matcher>[
        isMethodCall('Trace#start', arguments: <String, Object>{
          'handle': currentTraceHandle,
          'name': 'startTrace-test',
        }),
      ]);
    });

    group('$Trace', () {
      Trace testTrace;

      setUp(() {
        testTrace = performance.newTrace('test');
      });

      test('start', () async {
        await testTrace.start();

        expect(log, <Matcher>[
          isMethodCall('Trace#start', arguments: <String, Object>{
            'handle': currentTraceHandle,
            'name': 'test',
          }),
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
          isMethodCall('Trace#stop', arguments: <String, dynamic>{
            'handle': currentTraceHandle,
            'name': 'test',
            'counters': <String, int>{},
            'attributes': <String, String>{},
          }),
        ]);
      });

      test('incrementCounter', () async {
        final Trace trace = performance.newTrace("test");
        trace.incrementCounter('counter1');

        trace.incrementCounter('counter2');
        trace.incrementCounter('counter2');

        trace.incrementCounter('counter3', 5);
        trace.incrementCounter('counter3', 5);

        trace.incrementCounter('counter4', -5);

        await trace.start();
        await trace.stop();

        expect(log, <Matcher>[
          isMethodCall('Trace#start', arguments: <String, Object>{
            'handle': currentTraceHandle,
            'name': 'test',
          }),
          isMethodCall('Trace#stop', arguments: <String, dynamic>{
            'handle': currentTraceHandle,
            'name': 'test',
            'counters': <String, int>{
              'counter1': 1,
              'counter2': 2,
              'counter3': 10,
              'counter4': -5,
            },
            'attributes': <String, String>{},
          }),
        ]);
      });

      test('putAttribute', () async {
        testTrace.putAttribute('attr1', 'apple');
        testTrace.putAttribute('attr2', 'are');
        expect(testTrace.attributes, <String, String>{
          'attr1': 'apple',
          'attr2': 'are',
        });

        testTrace.putAttribute('attr1', 'delicious');
        expect(testTrace.attributes, <String, String>{
          'attr1': 'delicious',
          'attr2': 'are',
        });
      });

      test('removeAttribute', () async {
        testTrace.putAttribute('attr1', 'apple');
        testTrace.putAttribute('attr2', 'are');
        testTrace.removeAttribute('no-attr');
        expect(testTrace.attributes, <String, String>{
          'attr1': 'apple',
          'attr2': 'are',
        });

        testTrace.removeAttribute('attr1');
        expect(testTrace.attributes, <String, String>{
          'attr2': 'are',
        });
      });

      test('getAttribute', () {
        testTrace.putAttribute('attr1', 'apple');
        testTrace.putAttribute('attr2', 'are');
        expect(testTrace.getAttribute('attr1'), 'apple');

        expect(testTrace.getAttribute('attr3'), isNull);
      });
    });
  });
}
