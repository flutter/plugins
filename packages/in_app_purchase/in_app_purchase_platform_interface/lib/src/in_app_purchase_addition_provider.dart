// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_platform_interface/src/in_app_purchase_addition.dart';

/// The [InAppPurchaseAdditionProvider] is responsible for providing
/// a platform specific [InAppPurchaseAddition].
///
/// [InAppPurchaseAddition] implementation contain platform specific
/// features that are not available from the platform idiomatic
/// [InAppPurchasePlatform] API.
abstract class InAppPurchaseAdditionProvider {
  /// Provides a platform specific implementation of the [InAppPurchaseAddition]
  /// class.
  T getPlatformAddition<T extends InAppPurchaseAddition>();
}
