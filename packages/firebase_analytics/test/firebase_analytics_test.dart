// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';

void main() {
  final FirebaseAnalytics analytics = FirebaseAnalytics();
  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_analytics');
  MethodCall methodCall;

  setUp(() async {
    channel.setMockMethodCallHandler((MethodCall m) async {
      methodCall = m;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
    methodCall = null;
  });

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

  group('FirebaseAnalytics', () {
    test('setUserId', () async {
      await analytics.setUserId('test-user-id');
      expect(
        methodCall,
        isMethodCall(
          'setUserId',
          arguments: 'test-user-id',
        ),
      );
    });

    test('setCurrentScreen', () async {
      await analytics.setCurrentScreen(
        screenName: 'test-screen-name',
        screenClassOverride: 'test-class-override',
      );
      expect(
        methodCall,
        isMethodCall(
          'setCurrentScreen',
          arguments: <String, String>{
            'screenName': 'test-screen-name',
            'screenClassOverride': 'test-class-override',
          },
        ),
      );
    });

    test('setUserProperty', () async {
      await analytics.setUserProperty(name: 'test_name', value: 'test-value');
      expect(
        methodCall,
        isMethodCall(
          'setUserProperty',
          arguments: <String, String>{
            'name': 'test_name',
            'value': 'test-value',
          },
        ),
      );
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
      await analytics.setAnalyticsCollectionEnabled(false);
      expect(
        methodCall,
        isMethodCall(
          'setAnalyticsCollectionEnabled',
          arguments: false,
        ),
      );
    });

    test('setSessionTimeoutDuration', () async {
      await analytics.android.setSessionTimeoutDuration(234);
      expect(
        methodCall,
        isMethodCall(
          'setSessionTimeoutDuration',
          arguments: 234,
        ),
      );
    });

    test('resetAnalyticsData', () async {
      await analytics.resetAnalyticsData();
      expect(
        methodCall,
        isMethodCall(
          'resetAnalyticsData',
          arguments: null,
        ),
      );
    });
  });

  group('FirebaseAnalytics analytics events', () {
    test('logEvent log events', () async {
      await analytics.logEvent(
        name: 'test-event',
        parameters: <String, dynamic>{'a': 'b'},
      );
      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{
            'name': 'test-event',
            'parameters': <String, dynamic>{'a': 'b'},
          },
        ),
      );
    });

    test('logEvent rejects events with reserved names', () async {
      expect(analytics.logEvent(name: 'app_clear_data'), throwsArgumentError);
    });

    test('logEvent rejects events with reserved prefix', () async {
      expect(analytics.logEvent(name: 'firebase_foo'), throwsArgumentError);
    });

    void smokeTest(String testFunctionName, Future<void> testFunction()) {
      test('$testFunctionName works', () async {
        await testFunction();
        expect(methodCall.arguments['name'], testFunctionName);
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

    smokeTest(
        'level_start',
        () => analytics.logLevelStart(
              levelName: 'level-name',
            ));

    smokeTest(
        'level_end',
        () => analytics.logLevelEnd(
              levelName: 'level-name',
              success: 1,
            ));

    smokeTest('login', () => analytics.logLogin());

    smokeTest(
        'login',
        () => analytics.logLogin(
              loginMethod: 'email',
            ));

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
              method: 'test method',
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

    smokeTest('set_checkout_option', () {
      return analytics.logSetCheckoutOption(
          checkoutStep: 1, checkoutOption: 'some credit card');
    });

    void testRequiresValueAndCurrencyTogether(
        String methodName, Future<void> testFn()) {
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

    testRequiresValueAndCurrencyTogether('logRemoveFromCart', () {
      return analytics.logRemoveFromCart(
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
