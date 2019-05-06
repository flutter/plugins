// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:flutter/widgets.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

void main() {
  group('FirebaseAnalyticsObserver', () {
    FirebaseAnalytics analytics;
    FirebaseAnalyticsObserver observer;
    final List<String> printLog = <String>[];

    void overridePrint(void Function() func) {
      final ZoneSpecification spec =
          ZoneSpecification(print: (_, __, ___, String msg) {
        // Add to log instead of printing to stdout
        printLog.add(msg);
      });
      return Zone.current.fork(specification: spec).run(func);
    }

    setUp(() {
      printLog.clear();
      analytics = MockFirebaseAnalytics();
      observer = FirebaseAnalyticsObserver(analytics: analytics);
      when(analytics.setCurrentScreen(screenName: anyNamed('screenName')))
          .thenAnswer((Invocation invocation) => Future<void>.value());
    });

    test('setCurrentScreen on route pop', () {
      final PageRoute<dynamic> route = MockPageRoute();
      final PageRoute<dynamic> previousRoute = MockPageRoute();
      when(previousRoute.settings)
          .thenReturn(const RouteSettings(name: 'previousRoute'));

      observer.didPop(route, previousRoute);

      verify(analytics.setCurrentScreen(screenName: 'previousRoute')).called(1);
    });

    test('setCurrentScreen on route push', () {
      final PageRoute<dynamic> route = MockPageRoute();
      final PageRoute<dynamic> previousRoute = MockPageRoute();
      when(route.settings).thenReturn(const RouteSettings(name: 'route'));

      observer.didPush(route, previousRoute);

      verify(analytics.setCurrentScreen(screenName: 'route')).called(1);
    });

    test('setCurrentScreen on route pushReplacement', () {
      final PageRoute<dynamic> route = MockPageRoute();
      final PageRoute<dynamic> previousRoute = MockPageRoute();
      when(route.settings).thenReturn(const RouteSettings(name: 'route'));

      observer.didReplace(newRoute: route, oldRoute: previousRoute);

      verify(analytics.setCurrentScreen(screenName: 'route')).called(1);
    });

    test('uses nameExtractor', () {
      observer = FirebaseAnalyticsObserver(
        analytics: analytics,
        nameExtractor: (RouteSettings settings) => 'foo',
      );
      final PageRoute<dynamic> route = MockPageRoute();
      final PageRoute<dynamic> previousRoute = MockPageRoute();

      observer.didPush(route, previousRoute);

      verify(analytics.setCurrentScreen(screenName: 'foo')).called(1);
    });

    test('handles only ${PlatformException}s', () async {
      observer = FirebaseAnalyticsObserver(
        analytics: analytics,
        nameExtractor: (RouteSettings settings) => 'foo',
      );

      final PageRoute<dynamic> route = MockPageRoute();
      final PageRoute<dynamic> previousRoute = MockPageRoute();

      // Throws non-PlatformExceptions
      when(analytics.setCurrentScreen(screenName: anyNamed('screenName')))
          .thenThrow(ArgumentError());

      expect(() => observer.didPush(route, previousRoute), throwsArgumentError);

      // Print PlatformExceptions
      Future<void> throwPlatformException() async =>
          throw PlatformException(code: 'a');

      when(analytics.setCurrentScreen(screenName: anyNamed('screenName')))
          .thenAnswer((Invocation invocation) => throwPlatformException());

      overridePrint(() => observer.didPush(route, previousRoute));

      await pumpEventQueue();
      expect(
        printLog,
        <String>['$FirebaseAnalyticsObserver: ${PlatformException(code: 'a')}'],
      );
    });

    test('runs onError', () async {
      PlatformException passedException;

      final void Function(PlatformException error) handleError =
          (PlatformException error) {
        passedException = error;
      };

      observer = FirebaseAnalyticsObserver(
        analytics: analytics,
        nameExtractor: (RouteSettings settings) => 'foo',
        onError: handleError,
      );

      final PageRoute<dynamic> route = MockPageRoute();
      final PageRoute<dynamic> previousRoute = MockPageRoute();

      final PlatformException thrownException = PlatformException(code: 'b');
      Future<void> throwPlatformException() async => throw thrownException;

      when(analytics.setCurrentScreen(screenName: anyNamed('screenName')))
          .thenAnswer((Invocation invocation) => throwPlatformException());

      observer.didPush(route, previousRoute);

      await pumpEventQueue();
      expect(passedException, thrownException);
    });
  });
}

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockPageRoute extends Mock implements PageRoute<dynamic> {}
