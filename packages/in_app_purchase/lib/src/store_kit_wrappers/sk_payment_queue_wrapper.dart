import 'dart:async';

import 'package:flutter/services.dart';

const MethodChannel _channel =
    MethodChannel('plugins.flutter.io/in_app_purchase');

/// https://developer.apple.com/documentation/storekit/skpaymentqueue?language=objc
class SKPaymentQueueWrapper {
  static Future<bool> get canMakePayments async =>
      await _channel.invokeMethod('-[SKPaymentQueue canMakePayments:]');

}
