// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:flutter/widgets.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

void main() {
  group('FirebaseAnalyticsObserver', () {
    FirebaseAnalytics analytics;
    FirebaseAnalyticsObserver observer;

    setUp(() {
      analytics = new MockFirebaseAnalytics();
      observer = new FirebaseAnalyticsObserver(analytics: analytics);
    });

    test('setCurrentScreen on route pop', () {
      final PageRoute<dynamic> route = new MockPageRoute();
      final PageRoute<dynamic> previousRoute = new MockPageRoute();
      when(previousRoute.settings)
          .thenReturn(const RouteSettings(name: 'previousRoute'));

      observer.didPop(route, previousRoute);

      verify(analytics.setCurrentScreen(screenName: 'previousRoute')).called(1);
    });

    test('setCurrentScreen on route push', () {
      final PageRoute<dynamic> route = new MockPageRoute();
      final PageRoute<dynamic> previousRoute = new MockPageRoute();
      when(route.settings).thenReturn(const RouteSettings(name: 'route'));

      observer.didPush(route, previousRoute);

      verify(analytics.setCurrentScreen(screenName: 'route')).called(1);
    });

    test('uses nameExtractor', () {
      observer = new FirebaseAnalyticsObserver(
        analytics: analytics,
        nameExtractor: (RouteSettings settings) => 'foo',
      );
      final PageRoute<dynamic> route = new MockPageRoute();
      final PageRoute<dynamic> previousRoute = new MockPageRoute();

      observer.didPush(route, previousRoute);

      verify(analytics.setCurrentScreen(screenName: 'foo')).called(1);
    });
  });
}

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockPageRoute extends Mock implements PageRoute<dynamic> {}
