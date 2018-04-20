// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:flutter/services.dart';

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
    });
  });
}

class MockPlatformChannel extends Mock implements MethodChannel {}
