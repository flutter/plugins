// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore: avoid_classes_with_only_static_members
/// The interface that platform implementations must implement when they want to
/// provide platform specific in_app_purchase features.
abstract class InAppPurchaseAddition {
  /// The instance containing the platform specific in_app_purchase features.
  static InAppPurchaseAddition? instance;
}
