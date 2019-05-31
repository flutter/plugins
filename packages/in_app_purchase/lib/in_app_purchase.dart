<<<<<<< HEAD
import 'dart:async';

import 'package:flutter/services.dart';

class InAppPurchase {
  static const MethodChannel _channel = MethodChannel('in_app_purchase');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
=======
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

export 'src/in_app_purchase/in_app_purchase_connection.dart';
export 'src/in_app_purchase/product_details.dart';
export 'src/in_app_purchase/purchase_details.dart';
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
