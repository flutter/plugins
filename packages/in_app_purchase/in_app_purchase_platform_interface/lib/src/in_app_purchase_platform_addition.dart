// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that platform implementations must implement when they want to
/// provide platform-specific in_app_purchase features.
///
/// Platforms that wants to introduce platform-specific public APIs should create
/// a class that either extend or implements [InAppPurchasePlatformAddition]. Then replace
/// the [InAppPurchasePlatformAddition.instance] with an instance of that class.
///
/// All the APIs added by [InAppPurchasePlatformAddition] implementers will be accessed from
/// [InAppPurchasePlatformAdditionProvider.getPlatformAddition] by the client APPs.
/// To avoid client APPs to directly call the [InAppPurchasePlatform] APIs, we highly recommand to not have [InAppPurchasePlatformAddition] and [InAppPurchasePlatform]
/// being the same class.
abstract class InAppPurchasePlatformAddition {
  /// The instance containing the platform-specific in_app_purchase
  /// functionality.
  ///
  /// Returns `null` by default.
  ///
  /// To implement additional functionality extend
  /// [`InAppPurchasePlatformAddition`][3] with the platform-specific
  /// functionality, and when the plugin is registered, set the
  /// `InAppPurchasePlatformAddition.instance` with the new addition
  /// implementation instance.
  ///
  /// Example implementation might look like this:
  /// ```dart
  /// class InAppPurchaseMyPlatformAddition extends InAppPurchasePlatformAddition {
  ///   Future<void> myPlatformMethod() {}
  /// }
  /// ```
  ///
  /// The following snippet shows how to register the `InAppPurchaseMyPlatformAddition`:
  /// ```dart
  /// class InAppPurchaseMyPlatformPlugin {
  ///   static void registerWith(Registrar registrar) {
  ///     // Register the platform-specific implementation of the idiomatic
  ///     // InAppPurchase API.
  ///     InAppPurchasePlatform.instance = InAppPurchaseMyPlatformPlugin();
  ///
  ///     // Register the [InAppPurchaseMyPlatformAddition] containing the
  ///     // platform-specific functionality.
  ///     InAppPurchasePlatformAddition.instance = InAppPurchaseMyPlatformAddition();
  ///   }
  /// }
  /// ```
  static InAppPurchasePlatformAddition? instance;
}
