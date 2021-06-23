// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_ios/src/channel.dart';
import 'package:in_app_purchase_ios/store_kit_wrappers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final FakeIOSPlatform fakeIOSPlatform = FakeIOSPlatform();

  setUpAll(() {
    SystemChannels.platform
        .setMockMethodCallHandler(fakeIOSPlatform.onMethodCall);
  });

  test(
      'handlePaymentQueueDelegateCallbacks should call SKPaymentQueueDelegateWrapper.shouldContinueTransaction',
      () async {
    SKPaymentQueueWrapper queue = SKPaymentQueueWrapper();
    TestPaymentQueueDelegate testDelegate = TestPaymentQueueDelegate();
    await queue.setDelegate(testDelegate);

    final Map<String, dynamic> arguments = <String, dynamic>{
      'storefront': <String, String>{
        'countryCode': 'USA',
        'identifier': 'unique_identifier',
      },
      'transaction': <String, dynamic>{
        'payment': <String, dynamic>{
          'productIdentifier': 'product_identifier',
        }
      },
    };

    final result = await queue.handlePaymentQueueDelegateCallbacks(
      MethodCall('shouldContinueTransaction', arguments),
    );

    expect(result, false);
    expect(
      testDelegate.log,
      <Matcher>{
        equals('shouldContinueTransaction'),
      },
    );
  });

  test(
      'handlePaymentQueueDelegateCallbacks should call SKPaymentQueueDelegateWrapper.shouldShowPriceConsent',
      () async {
    SKPaymentQueueWrapper queue = SKPaymentQueueWrapper();
    TestPaymentQueueDelegate testDelegate = TestPaymentQueueDelegate();
    await queue.setDelegate(testDelegate);

    final result = await queue.handlePaymentQueueDelegateCallbacks(
      MethodCall('shouldShowPriceConsent'),
    );

    expect(result, false);
    expect(
      testDelegate.log,
      <Matcher>{
        equals('shouldShowPriceConsent'),
      },
    );
  });
}

class TestPaymentQueueDelegate extends SKPaymentQueueDelegateWrapper {
  final List<String> log = <String>[];

  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    log.add('shouldContinueTransaction');
    return false;
  }

  @override
  bool shouldShowPriceConsent() {
    log.add('shouldShowPriceConsent');
    return false;
  }
}

class FakeIOSPlatform {
  FakeIOSPlatform() {
    channel.setMockMethodCallHandler(onMethodCall);
  }

  // indicate if the payment queue delegate is registered
  bool isPaymentQueueDelegateRegistered = false;

  Future<dynamic> onMethodCall(MethodCall call) {
    switch (call.method) {
      case '-[SKPaymentQueue registerDelegate]':
        isPaymentQueueDelegateRegistered = true;
        return Future<void>.sync(() {});
      case '-[SKPaymentQueue removeDelegate]':
        isPaymentQueueDelegateRegistered = false;
        return Future<void>.sync(() {});
    }
    return Future.error('method not mocked');
  }
}
