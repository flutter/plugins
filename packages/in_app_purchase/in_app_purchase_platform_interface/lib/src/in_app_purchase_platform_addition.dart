// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

// ignore: avoid_classes_with_only_static_members
/// The interface that platform implementations must implement when they want to
/// provide platform-specific in_app_purchase features.
///
/// Platforms that wants to introduce platform-specific public APIs should create
/// a class that either extend or implements [InAppPurchasePlatformAddition]. Then set
/// the [InAppPurchasePlatformAddition.instance] to an instance of that class.
///
/// All the APIs added by [InAppPurchasePlatformAddition] implementations will be accessed from
/// [InAppPurchasePlatformAdditionProvider.getPlatformAddition] by the client APPs.
/// To avoid clients directly calling [InAppPurchasePlatform] APIs,
/// an [InAppPurchasePlatformAddition] implementation should not be a type of [InAppPurchasePlatform].
abstract class InAppPurchasePlatformAddition {
  static InAppPurchasePlatformAddition? _instance;

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
  static InAppPurchasePlatformAddition? get instance => _instance;

  /// Sets the instance to a desired [InAppPurchasePlatformAddition] implementation.
  ///
  /// The `instance` should not be a type of [InAppPurchasePlatform].
  static set instance(InAppPurchasePlatformAddition? instance) {
    assert(instance is! InAppPurchasePlatform);
    _instance = instance;
  }
}
