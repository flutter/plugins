// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@testable import quick_actions_ios

final class MockShortcutStateManager: ShortcutStateManaging {
  var setShortcutItemsStub: (([[String: Any]]) -> Void)?

  func setShortcutItems(_ items: [[String : Any]]) {
    setShortcutItemsStub?(items)
  }
}
