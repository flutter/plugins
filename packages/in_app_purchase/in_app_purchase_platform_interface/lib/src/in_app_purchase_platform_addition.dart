// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore: avoid_classes_with_only_static_members
/// The interface that platform implementations must implement when they want to
/// provide platform specific in_app_purchase features.
abstract class InAppPurchasePlatformAddition {
  /// The instance containing the platform-specific in_app_purchase
  /// functionality.
  ///
  /// To implement additional functionality extend
  /// [`InAppPurchasePlatformAddition`][3] with the platform-specific
  /// functionality, and when the plugin is registered, set the
  /// `InAppPurchasePlatformAddition.instance` with the new addition
  /// implementationinstance.
  ///
  /// Example implementation might look like this:
  /// ```dart
  /// class InAppPurchaseMyPlatformAddition extends InAppPurchasePlatformAddition {
  ///   Future<void> myPlatformMethod() {}
  /// }
  /// ```
  ///
  /// The following snippit shows how to register the `InAppPurchaseMyPlatformAddition`:
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
