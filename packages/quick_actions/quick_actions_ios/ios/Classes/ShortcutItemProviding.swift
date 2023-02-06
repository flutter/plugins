// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit

/// Provides the capability to get and set the app's home screen shortcut items.
protocol ShortcutItemProviding: AnyObject {

  /// An array of shortcut items for home screen.
  var shortcutItems: [UIApplicationShortcutItem]? { get set }
}

/// A default implementation of the `ShortcutItemProviding` protocol.
extension UIApplication: ShortcutItemProviding {}
