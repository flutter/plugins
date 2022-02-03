// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

/// Method channel for the plugin's platform<-->Dart calls.
const MethodChannel channel =
    MethodChannel('plugins.flutter.io/in_app_purchase');

/// Method channel used to deliver the payment queue delegate system calls to
/// Dart.
const MethodChannel paymentQueueDelegateChannel =
    MethodChannel('plugins.flutter.io/in_app_purchase_payment_queue_delegate');
