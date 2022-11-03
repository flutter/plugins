// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit

/// A parser that parses an array of raw shortcut items.
protocol ShortcutItemParser {

  /// Parses an array of raw shortcut items into an array of UIApplicationShortcutItems
  ///
  /// - Parameter items an array of raw shortcut items to be parsed.
  /// - Returns an array of parsed shortcut items to be set.
  ///
  func parseShortcutItems(_ items: [[String: Any]]) -> [UIApplicationShortcutItem]
}

final class DefaultShortcutItemParser: ShortcutItemParser {

  func parseShortcutItems(_ items: [[String: Any]]) -> [UIApplicationShortcutItem] {
    return items.compactMap { deserializeShortcutItem(with: $0) }
  }

  private func deserializeShortcutItem(with serialized: [String: Any]) -> UIApplicationShortcutItem
  {

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
