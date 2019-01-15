import 'package:test/test.dart';

import 'package:in_app_purchase/src/channel.dart';
import 'package:in_app_purchase/src/in_app_purchase_connection/app_store_connection.dart';
import '../fake_in_app_purchase_platform.dart';

void main() {
  final FakeInAppPurchasePlatform fakePlatform = FakeInAppPurchasePlatform();

  setUpAll(() =>
      channel.setMockMethodCallHandler(fakePlatform.fakeMethodCallHandler));

  group('isAvailable', () {
    test('true', () async {
      fakePlatform.addResponse(
          name: '-[SKPaymentQueue canMakePayments:]', value: true);
      expect(await AppStoreConnection.instance.isAvailable(), isTrue);
    });

    test('false', () async {
      fakePlatform.addResponse(
          name: '-[SKPaymentQueue canMakePayments:]', value: false);
      expect(await AppStoreConnection.instance.isAvailable(), isFalse);
    });
  });
}
