// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'package:firebase_performance/firebase_performance.dart';

void main() {
  group('$FirebasePerformance', () {
    FirebasePerformance performance;

    String invokedMethod;
    dynamic arguments;

    setUp(() {
      final MockPlatformChannel mockChannel = new MockPlatformChannel();

      when(mockChannel.invokeMethod(typed(any)))
          .thenAnswer((Invocation invocation) {
        invokedMethod = invocation.positionalArguments[0];
      });

      when(mockChannel.invokeMethod(typed(any), any))
          .thenAnswer((Invocation invocation) {
        invokedMethod = invocation.positionalArguments[0];
        arguments = invocation.positionalArguments[1];
      });

      performance = FirebasePerformance.private(mockChannel);
    });

    test('isPerformanceCollectionEnabled', () async {
      await performance.isPerformanceCollectionEnabled();
      expect(
          invokedMethod, 'FirebasePerformance#isPerformanceCollectionEnabled');
    });

    test('setPerformanceCollectionEnabled', () async {
      await performance.setPerformanceCollectionEnabled(true);
      expect(
          invokedMethod, 'FirebasePerformance#setPerformanceCollectionEnabled');
      expect(arguments, true);

      await performance.setPerformanceCollectionEnabled(false);
      expect(
          invokedMethod, 'FirebasePerformance#setPerformanceCollectionEnabled');
      expect(arguments, false);
    });

    group('$Trace', () {
      Trace testTrace;

      setUp(() async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        testTrace = await performance.newTrace('test');
      });

      test('android is null on non-android devices', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        Trace trace = await performance.newTrace('android-trace');
        expect(trace.android, isNotNull);

        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        trace = await performance.newTrace('iOS-trace');
        expect(trace.android, isNull);

        debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
        trace = await performance.newTrace('fuschia-trace');
        expect(trace.android, isNull);
      });

      test('incrementCounter', () {
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
      });

      test('newTrace', () async {
        await performance.newTrace('test-trace');
        expect(invokedMethod, 'FirebasePerformance#newTrace');
        expect(arguments, 'test-trace');
      });

      test('start', () async {
        await testTrace.start();
        expect(invokedMethod, 'Trace#start');
        expect(arguments, null);
      });

      test('stop', () async {
        testTrace.incrementCounter('counter1');
        testTrace.android.putAttribute('attr1', 'apple');
        await testTrace.stop();

        expect(invokedMethod, 'Trace#stop');
        expect(arguments, <String, dynamic>{
          'id': null,
          'name': 'test',
          'counters': <String, int>{'counter1': 1},
          'attributes': <String, String>{'attr1': 'apple'},
        });
      });

      group('$TraceAndroid', () {
        test('putAttribute', () {
          testTrace.android.putAttribute('attr1', 'apple');
          testTrace.android.putAttribute('attr2', 'are');
          expect(testTrace.android.attributes, <String, String>{
            'attr1': 'apple',
            'attr2': 'are',
          });

          testTrace.android.putAttribute('attr1', 'delicious');
          expect(testTrace.android.attributes, <String, String>{
            'attr1': 'delicious',
            'attr2': 'are',
          });
        });

        test('removeAttribute', () {
          testTrace.android.putAttribute('attr1', 'apple');
          testTrace.android.putAttribute('attr2', 'are');
          testTrace.android.removeAttribute('no-attr');
          expect(testTrace.android.attributes, <String, String>{
            'attr1': 'apple',
            'attr2': 'are',
          });

          testTrace.android.removeAttribute('attr1');
          expect(testTrace.android.attributes, <String, String>{
            'attr2': 'are',
          });
        });

        test('getAttribute', () {
          testTrace.android.putAttribute('attr1', 'apple');
          testTrace.android.putAttribute('attr2', 'are');
          expect(testTrace.android.getAttribute('attr1'), 'apple');

          expect(testTrace.android.getAttribute('attr3'), isNull);
        });
      });
    });
  });
}

class MockPlatformChannel extends Mock implements MethodChannel {}
