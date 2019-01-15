import 'package:test/test.dart';

import 'package:in_app_purchase/store_kit_wrappers.dart';
import 'package:in_app_purchase/src/channel.dart';
import '../fake_in_app_purchase_platform.dart';

void main() {
  final FakeInAppPurchasePlatform fakePlatform = FakeInAppPurchasePlatform();

  setUpAll(() =>
      channel.setMockMethodCallHandler(fakePlatform.fakeMethodCallHandler));

  group('canMakePayments', () {
    test('YES', () async {
      fakePlatform.addResponse(
          name: '-[SKPaymentQueue canMakePayments:]', value: true);
      expect(await SKPaymentQueueWrapper.canMakePayments(), isTrue);
    });

    test('NO', () async {
      fakePlatform.addResponse(
          name: '-[SKPaymentQueue canMakePayments:]', value: false);
      expect(await SKPaymentQueueWrapper.canMakePayments(), isFalse);
    });
  });
}
