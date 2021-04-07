// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'in_app_purchase_platform.dart';

/// Temporary no-operation implementation of the [InAppPurchasePlatform] which
/// was added to return as default implementation for  the [InAppPurchasePlatform.instance]
/// property.
class NoopInAppPurchase extends InAppPurchasePlatform {}
