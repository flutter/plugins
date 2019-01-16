// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import '../channel.dart';

/// A wrapper around [`SKPaymentQueue`](https://developer.apple.com/documentation/storekit/skpaymentqueue?language=objc).
class SKPaymentQueueWrapper {
  /// Calls [`-[SKPaymentQueue canMakePayments:]`](https://developer.apple.com/documentation/storekit/skpaymentqueue/1506139-canmakepayments?language=objc).
  static Future<bool> canMakePayments() async =>
      await channel.invokeMethod('-[SKPaymentQueue canMakePayments:]');
}
