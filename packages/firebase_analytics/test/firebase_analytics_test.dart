// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:flutter/services.dart';

import 'package:firebase_analytics/firebase_analytics.dart';

void main() {
  group('filterOutNulls', () {
    test('filters out null values', () {
      final Map<String, dynamic> original = <String, dynamic>{
        'a': 1,
        'b': null,
        'c': 'd'
      };
      final Map<String, dynamic> filtered = filterOutNulls(original);

      expect(filtered, isNot(same(original)));
      expect(original, <String, dynamic>{'a': 1, 'b': null, 'c': 'd'});
      expect(filtered, <String, dynamic>{'a': 1, 'c': 'd'});
    });
  });

  group('$FirebaseAnalytics', () {
    FirebaseAnalytics analytics;

    String invokedMethod;
    dynamic arguments;

    setUp(() {
      final MockPlatformChannel mockChannel = MockPlatformChannel();

      invokedMethod = null;
      arguments = null;

      when(mockChannel.invokeMethod(any, any))
          .thenAnswer((Invocation invocation) {
        invokedMethod = invocation.positionalArguments[0];
        arguments = invocation.positionalArguments[1];
        return Future<void>.value();
      });

      analytics = FirebaseAnalytics.private(mockChannel);
    });

    test('setUserId', () async {
      await analytics.setUserId('test-user-id');
      expect(invokedMethod, 'setUserId');
      expect(arguments, 'test-user-id');
    });

    test('setCurrentScreen', () async {
      await analytics.setCurrentScreen(
          screenName: 'test-screen-name',
          screenClassOverride: 'test-class-override');
      expect(invokedMethod, 'setCurrentScreen');
      expect(arguments, <String, String>{
        'screenName': 'test-screen-name',
        'screenClassOverride': 'test-class-override',
      });
    });

    test('setUserProperty', () async {
      await analytics.setUserProperty(name: 'test_name', value: 'test-value');
      expect(invokedMethod, 'setUserProperty');
      expect(arguments, <String, String>{
        'name': 'test_name',
        'value': 'test-value',
      });
    });

    test('setUserProperty rejects invalid names', () async {
      // invalid character
      expect(analytics.setUserProperty(name: 'test-name', value: 'test-value'),
          throwsArgumentError);
      // non-alpha first character
      expect(analytics.setUserProperty(name: '0test', value: 'test-value'),
          throwsArgumentError);
      // null
      expect(analytics.setUserProperty(name: null, value: 'test-value'),
          throwsArgumentError);
      // blank
      expect(analytics.setUserProperty(name: '', value: 'test-value'),
          throwsArgumentError);
      // reserved prefix
      expect(
          analytics.setUserProperty(name: 'firebase_test', value: 'test-value'),
          throwsArgumentError);
    });

    test('setAnalyticsCollectionEnabled', () async {
      await analytics.android.setAnalyticsCollectionEnabled(false);
      expect(invokedMethod, 'setAnalyticsCollectionEnabled');
      expect(arguments, false);
    });

    test('setMinimumSessionDuration', () async {
      await analytics.android.setMinimumSessionDuration(123);
      expect(invokedMethod, 'setMinimumSessionDuration');
      expect(arguments, 123);
    });

    test('setSessionTimeoutDuration', () async {
      await analytics.android.setSessionTimeoutDuration(234);
      expect(invokedMethod, 'setSessionTimeoutDuration');
      expect(arguments, 234);
    });
  });

  group('$FirebaseAnalytics analytics events', () {
    FirebaseAnalytics analytics;

    String name;
    Map<String, dynamic> parameters;

    setUp(() {
      final MockPlatformChannel mockChannel = MockPlatformChannel();

      name = null;
      parameters = null;

      when(mockChannel.invokeMethod('logEvent', any))
          .thenAnswer((Invocation invocation) {
        final Map<String, dynamic> args = invocation.positionalArguments[1];
        name = args['name'];
        parameters = args['parameters'];
        expect(args.keys, unorderedEquals(<String>['name', 'parameters']));
        return Future<void>.value();
      });

      when(mockChannel.invokeMethod(argThat(isNot('logEvent')), any))
          .thenThrow(ArgumentError('Only logEvent invocations expected'));

      analytics = FirebaseAnalytics.private(mockChannel);
    });

    test('logEvent log events', () async {
      await analytics.logEvent(
          name: 'test-event', parameters: <String, dynamic>{'a': 'b'});
      expect(name, 'test-event');
      expect(parameters, <String, dynamic>{'a': 'b'});
    });

    test('logEvent rejects events with reserved names', () async {
      expect(analytics.logEvent(name: 'app_clear_data'), throwsArgumentError);
    });

    test('logEvent rejects events with reserved prefix', () async {
      expect(analytics.logEvent(name: 'firebase_foo'), throwsArgumentError);
    });

    void smokeTest(String testFunctionName, Future<Null> testFunction()) {
      test('$testFunctionName works', () async {
        await testFunction();
        expect(name, testFunctionName);
      });
    }

    smokeTest('add_payment_info', () => analytics.logAddPaymentInfo());

    smokeTest(
        'add_to_cart',
        () => analytics.logAddToCart(
              itemId: 'test-id',
              itemName: 'test-name',
              itemCategory: 'test-category',
              quantity: 5,
            ));

    smokeTest(
        'add_to_wishlist',
        () => analytics.logAddToWishlist(
              itemId: 'test-id',
              itemName: 'test-name',
              itemCategory: 'test-category',
              quantity: 5,
            ));

    smokeTest('app_open', () => analytics.logAppOpen());

    smokeTest('begin_checkout', () => analytics.logBeginCheckout());

    smokeTest(
        'campaign_details',
        () => analytics.logCampaignDetails(
              source: 'test-source',
              medium: 'test-medium',
              campaign: 'test-campaign',
            ));

    smokeTest(
        'earn_virtual_currency',
        () => analytics.logEarnVirtualCurrency(
              virtualCurrencyName: 'bitcoin',
              value: 34,
            ));

    smokeTest('ecommerce_purchase', () => analytics.logEcommercePurchase());

    smokeTest('generate_lead', () => analytics.logGenerateLead());

    smokeTest(
        'join_group',
        () => analytics.logJoinGroup(
              groupId: 'test-group-id',
            ));

    smokeTest(
        'level_up',
        () => analytics.logLevelUp(
              level: 56,
            ));

    smokeTest('login', () => analytics.logLogin());

    smokeTest(
        'post_score',
        () => analytics.logPostScore(
              score: 34,
            ));

    smokeTest(
        'present_offer',
        () => analytics.logPresentOffer(
              itemId: 'test-id',
              itemName: 'test-name',
              itemCategory: 'test-category',
              quantity: 5,
            ));

    smokeTest('purchase_refund', () => analytics.logPurchaseRefund());

    smokeTest(
        'search',
        () => analytics.logSearch(
              searchTerm: 'test search term',
            ));

    smokeTest(
        'select_content',
        () => analytics.logSelectContent(
              contentType: 'test content type',
              itemId: 'test item id',
            ));

    smokeTest(
        'share',
        () => analytics.logShare(
              contentType: 'test content type',
              itemId: 'test item id',
            ));

    smokeTest(
        'sign_up',
        () => analytics.logSignUp(
              signUpMethod: 'test sign-up method',
            ));

    smokeTest(
        'spend_virtual_currency',
        () => analytics.logSpendVirtualCurrency(
              itemName: 'test-item-name',
              virtualCurrencyName: 'bitcoin',
              value: 345,
            ));

    smokeTest('tutorial_begin', () => analytics.logTutorialBegin());

    smokeTest('tutorial_complete', () => analytics.logTutorialComplete());

    smokeTest(
        'unlock_achievement',
        () => analytics.logUnlockAchievement(
              id: 'firebase analytics api coverage',
            ));

    smokeTest(
        'view_item',
        () => analytics.logViewItem(
              itemId: 'test-id',
              itemName: 'test-name',
              itemCategory: 'test-category',
            ));

    smokeTest(
        'view_item_list',
        () => analytics.logViewItemList(
              itemCategory: 'test-category',
            ));

    smokeTest(
        'view_search_results',
        () => analytics.logViewSearchResults(
              searchTerm: 'test search term',
            ));

    void testRequiresValueAndCurrencyTogether(
        String methodName, Future<Null> testFn()) {
      test('$methodName requires value and currency together', () async {
        try {
          testFn();
          fail('Expected ArgumentError');
        } on ArgumentError catch (error) {
          expect(error.message, valueAndCurrencyMustBeTogetherError);
        }
      });
    }

    testRequiresValueAndCurrencyTogether('logAddToCart', () {
      return analytics.logAddToCart(
        itemId: 'test-id',
        itemName: 'test-name',
        itemCategory: 'test-category',
        quantity: 5,
        value: 123.90,
      );
    });

    testRequiresValueAndCurrencyTogether('logAddToWishlist', () {
      return analytics.logAddToWishlist(
        itemId: 'test-id',
        itemName: 'test-name',
        itemCategory: 'test-category',
        quantity: 5,
        value: 123.90,
      );
    });

    testRequiresValueAndCurrencyTogether('logBeginCheckout', () {
      return analytics.logBeginCheckout(
        value: 123.90,
      );
    });

    testRequiresValueAndCurrencyTogether('logEcommercePurchase', () {
      return analytics.logEcommercePurchase(
        value: 123.90,
      );
    });

    testRequiresValueAndCurrencyTogether('logGenerateLead', () {
      return analytics.logGenerateLead(
        value: 123.90,
      );
    });

    testRequiresValueAndCurrencyTogether('logPresentOffer', () {
      return analytics.logPresentOffer(
        itemId: 'test-id',
        itemName: 'test-name',
        itemCategory: 'test-category',
        quantity: 5,
        value: 123.90,
      );
    });

    testRequiresValueAndCurrencyTogether('logPurchaseRefund', () {
      return analytics.logPurchaseRefund(
        value: 123.90,
      );
    });

    testRequiresValueAndCurrencyTogether('logViewItem', () {
      return analytics.logViewItem(
        itemId: 'test-id',
        itemName: 'test-name',
        itemCategory: 'test-category',
        value: 123.90,
      );
    });
  });
}

class MockPlatformChannel extends Mock implements MethodChannel {}
