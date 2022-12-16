// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

@testable import quick_actions_ios

final class MockShortcutItemParser: ShortcutItemParser {

  var parseShortcutItemsStub: ((_ items: [[String: Any]]) -> [UIApplicationShortcutItem])? = nil

  func parseShortcutItems(_ items: [[String: Any]]) -> [UIApplicationShortcutItem] {
    return parseShortcutItemsStub?(items) ?? []
  }
}
