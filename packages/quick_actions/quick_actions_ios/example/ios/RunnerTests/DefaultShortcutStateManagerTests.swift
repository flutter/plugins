// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest
@testable import quick_actions_ios

class ShortcutStateManagerTests: XCTestCase {

  func testSetShortcutItems_shouldSetItem() {
    let rawItem = [
      "type" : "SearchTheThing",
      "localizedTitle" : "Search the thing",
      "icon" : "search_the_thing.png",
    ]

    let expectedItem = UIApplicationShortcutItem(
      type: "SearchTheThing",
      localizedTitle: "Search the thing",
      localizedSubtitle: nil,
      icon: UIApplicationShortcutIcon(templateImageName: "search_the_thing.png"),
      userInfo: nil)

    let mockShortcutItemService = MockShortcutItemService()
    let manager = DefaultShortcutStateManager(service: mockShortcutItemService)

    manager.setShortcutItems([rawItem])

    XCTAssertEqual(mockShortcutItemService.shortcutItems, [expectedItem])

  }

  func testSetShortcutItems_shouldSetItemWithoutIcon() {
    let rawItem: [String: Any] = [
      "type" : "SearchTheThing",
      "localizedTitle" : "Search the thing",
      "icon" : NSNull(),
    ]

    let expectedItem = UIApplicationShortcutItem(
      type: "SearchTheThing",
      localizedTitle: "Search the thing",
      localizedSubtitle: nil,
      icon: nil,
      userInfo: nil)

    let mockShortcutItemService = MockShortcutItemService()
    let manager = DefaultShortcutStateManager(service: mockShortcutItemService)

    manager.setShortcutItems([rawItem])

    XCTAssertEqual(mockShortcutItemService.shortcutItems, [expectedItem])
  }
}
