import 'dart:async';
import 'package:flutter/services.dart';

import '../channel.dart';

/// A wrapper around [`SKPaymentQueue`](https://developer.apple.com/documentation/storekit/skpaymentqueue?language=objc).
class SKPaymentQueueWrapper {
  static MethodChannel _channel = Channel.instance;

  /// Calls [`-[SKPaymentQueue canMakePayments:]`](https://developer.apple.com/documentation/storekit/skpaymentqueue/1506139-canmakepayments?language=objc).
  static Future<bool> canMakePayments() async =>
      await _channel.invokeMethod('-[SKPaymentQueue canMakePayments:]');
}
