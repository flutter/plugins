import 'package:test/test.dart';
import 'package:flutter/services.dart';

import 'package:in_app_purchase/src/channel.dart';
import 'package:in_app_purchase/src/in_app_purchase_connection/app_store_connection.dart';
import '../fake_platform_views_controller.dart';

void main() {
  final FakePlatformViewsController controller = FakePlatformViewsController();

  setUpAll(() {
    Channel.override = SystemChannels.platform_views;
    SystemChannels.platform_views
        .setMockMethodCallHandler(controller.fakePlatformViewsMethodHandler);
  });

  group('isAvailable', () {
    test('true', () async {
      controller.addCall(
          name: '-[SKPaymentQueue canMakePayments:]', value: true);
      expect(await AppStoreConnection.instance.isAvailable(), isTrue);
    });

    test('false', () async {
      controller.addCall(
          name: '-[SKPaymentQueue canMakePayments:]', value: false);
      expect(await AppStoreConnection.instance.isAvailable(), isFalse);
    });
  });
}
