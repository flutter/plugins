// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit

/// Manages the shortcut related states.
protocol ShortcutStateManaging {

  /// Sets the list of shortcut items.
  ///
  /// - Parameter items the list of shortcut items to be parsed and set.
  func setShortcutItems(_ items: [[String:Any]])
}

/// A default implementation of `ShortcutStateManaging` protocol.
final class DefaultShortcutStateManager: ShortcutStateManaging {

  private let service: ShortcutItemServicing

  /// Creates a ShortcutStateManager
  /// - Parameter service a shortcut item service, with `UIApplication.shared` as default.
  init(service: ShortcutItemServicing = UIApplication.shared) {
    self.service = service
  }

  func setShortcutItems(_ items: [[String : Any]]) {
    service.shortcutItems = items.compactMap { deserializeShortcutItem(with:$0) }
  }

  private func deserializeShortcutItem(with serialized: [String: Any]) -> UIApplicationShortcutItem {

    let icon = (serialized["icon"] as? String).map {
      UIApplicationShortcutIcon(templateImageName: $0)
    }

    // type and localizedTitle are required.
    return UIApplicationShortcutItem(
      type: serialized["type"] as! String,
      localizedTitle: serialized["localizedTitle"] as! String,
      localizedSubtitle: nil,
      icon: icon,
      userInfo: nil)
  }
}
