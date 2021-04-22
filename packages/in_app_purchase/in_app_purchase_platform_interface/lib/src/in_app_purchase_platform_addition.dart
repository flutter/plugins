// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that platform implementations must implement when they want to
/// provide platform specific in_app_purchase features.
///
/// Platform implementations should extend this class rather than implement it as `in_app_purchase`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [InAppPurchasePlatformAddition] methods.
abstract class InAppPurchasePlatformAddition extends PlatformInterface {

  /// Constructs a InAppPurchasePlatform.
  InAppPurchasePlatformAddition() : super(token: _token);

  static final Object _token = Object();

  // Should only be accessed after setter is called.
  static late InAppPurchasePlatformAddition _instance;

  /// The instance containing the platform-specific in_app_purchase
  /// functionality.
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
  static InAppPurchasePlatformAddition get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [InAppPurchasePlatformAddition] when they register themselves.
  static set instance(InAppPurchasePlatformAddition instance) {
    PlatformInterface.verifyToken(instance, _token);
    assert(instance.runtimeType is! InAppPurchasePlatform);
    _instance = instance;
  }
}
