//
//  MockShortcutItemParser.swift
//  RunnerTests
//
//  Created by Huan Lin on 11/3/22.
//  Copyright © 2022 The Flutter Authors. All rights reserved.
//

import Foundation

@testable import quick_actions_ios

final class MockShortcutItemParser: ShortcutItemParser {

  var parseShortcutItemsStub: ((_ items: [[String: Any]]) -> [UIApplicationShortcutItem])? = nil

  func parseShortcutItems(_ items: [[String: Any]]) -> [UIApplicationShortcutItem] {
    return parseShortcutItemsStub?(items) ?? []
  }
}
