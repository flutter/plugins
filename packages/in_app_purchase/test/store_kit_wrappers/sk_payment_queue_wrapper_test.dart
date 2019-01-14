import 'package:flutter/services.dart';
import 'package:test/test.dart';

import 'package:in_app_purchase/store_kit_wrappers.dart';
import 'package:in_app_purchase/src/channel.dart';
import '../fake_platform_views_controller.dart';

void main() {
  final FakePlatformViewsController fakePlatformViewsController =
      FakePlatformViewsController();

  setUpAll(() {
    Channel.override = SystemChannels.platform_views;
    SystemChannels.platform_views.setMockMethodCallHandler(
        fakePlatformViewsController.fakePlatformViewsMethodHandler);
  });

  group('canMakePayments', () {
    test('YES', () async {
      fakePlatformViewsController.addCall(
          name: '-[SKPaymentQueue canMakePayments:]', value: true);
      expect(await SKPaymentQueueWrapper.canMakePayments(), isTrue);
    });

    test('NO', () async {
      fakePlatformViewsController.addCall(
          name: '-[SKPaymentQueue canMakePayments:]', value: false);
      expect(await SKPaymentQueueWrapper.canMakePayments(), isFalse);
    });
  });
}
