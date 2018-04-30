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
            arguments: null)
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
            arguments: false)
      ]);
    });

    test('newTrace', () {
      final Trace trace = performance.newTrace('test-trace');
      expect(trace.name, 'test-trace');
    });

    group('$Trace', () {
      Trace testTrace;

      setUp(() {
        testTrace = performance.newTrace('test');
      });

      test('startTrace', () async {
        final Trace trace = await performance.startTrace('startTrace-test');
        expect(trace.name, 'startTrace-test');

        expect(log, <Matcher>[
          isMethodCall('Trace#start', arguments: <String, Object>{
            'id': trace.id,
            'name': 'startTrace-test',
          })
        ]);
      });

      test('start', () async {
        final int ret = await testTrace.start();
        expect(ret, null);
        expect(log, <Matcher>[
          isMethodCall('Trace#start', arguments: <String, Object>{
            'id': testTrace.id,
            'name': 'test',
          })
        ]);
        expect(testTrace.hasStarted, true);
      });

      test('stop', () async {
        testTrace.incrementCounter('counter1');
        testTrace.putAttribute('attr1', 'apple');

        int ret = await testTrace.start();
        expect(ret, null);
        ret = await testTrace.stop();
        expect(ret, null);

        expect(log, <Matcher>[
          isMethodCall('Trace#start', arguments: <String, Object>{
            'id': testTrace.id,
            'name': 'test',
          }),
          isMethodCall('Trace#stop', arguments: <String, dynamic>{
            'id': testTrace.id,
            'name': 'test',
            'counters': <String, int>{'counter1': 1},
            'attributes': <String, String>{'attr1': 'apple'},
          })
        ]);
        expect(testTrace.hasStarted, true);
        expect(testTrace.hasStopped, true);
      });

      test('start and stop called in wrong order', () async {
        Trace trace = performance.newTrace("test");
        await trace.stop();
        expect(trace.hasStarted, false);
        expect(trace.hasStopped, false);

        trace = performance.newTrace("test");
        await trace.start();
        await trace.start();
        expect(trace.hasStarted, true);
        expect(trace.hasStopped, false);

        trace = performance.newTrace("test");
        await trace.start();
        await trace.stop();
        await trace.stop();
        expect(trace.hasStarted, true);
        expect(trace.hasStopped, true);
      });

      test('incrementCounter', () async {
        testTrace.incrementCounter('counter1');
        expect(testTrace.counters, <String, int>{
          'counter1': 1,
        });

        testTrace.incrementCounter('counter1');
        expect(testTrace.counters['counter1'], 2);

        testTrace.incrementCounter('counter1', 10);
        expect(testTrace.counters['counter1'], 12);

        testTrace.incrementCounter('counter1', -13);
        expect(testTrace.counters['counter1'], -1);

        testTrace.incrementCounter('counter2');
        expect(testTrace.counters, <String, int>{
          'counter1': -1,
          'counter2': 1,
        });

        testTrace.incrementCounter('counter3', 25);
        expect(testTrace.counters, <String, int>{
          'counter1': -1,
          'counter2': 1,
          'counter3': 25,
        });

        // Don't increment counters after trace has stopped.
        await testTrace.start();
        await testTrace.stop();
        testTrace.incrementCounter('counter3');
        expect(testTrace.counters, <String, int>{
          'counter1': -1,
          'counter2': 1,
          'counter3': 25,
        });
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

        await testTrace.start();
        await testTrace.stop();
        testTrace.putAttribute('attr3', 'yes');
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

        await testTrace.start();
        await testTrace.stop();
        testTrace.removeAttribute('attr2');
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