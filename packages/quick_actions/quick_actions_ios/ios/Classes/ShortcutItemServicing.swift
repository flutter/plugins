// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit

/// Controls shortcut items.
protocol ShortcutItemServicing: AnyObject {

  /// An array of shortcut items for home screen.
  var shortcutItems: [UIApplicationShortcutItem]? { get set }
}

/// A default implementation of the `ShortcutItemServicing` protocol. 
extension UIApplication: ShortcutItemServicing {}
