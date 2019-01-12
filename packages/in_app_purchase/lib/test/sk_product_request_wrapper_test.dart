// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "package:test/test.dart";
import 'package:in_app_purchase/src/store_kit_wrappers/sk_product_request_wrapper.dart';

void main() {
  setUpAll(() {});

  setUp(() {});

  test(
      'SKProductSubscriptionPeriodWrapper should have property values consistent with json',
      () {
    final Map<dynamic, dynamic> json = <dynamic, dynamic>{
      "numberOfUnits": 0,
      "unit": 1
    };
    final SKProductSubscriptionPeriodWrapper wrapper =
        SKProductSubscriptionPeriodWrapper.fromJson(json);
    assert(wrapper.numberOfUnits == 0);
    assert(wrapper.unit == 1);
  });
}
